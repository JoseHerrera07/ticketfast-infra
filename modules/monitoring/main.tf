data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "monitoring" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "monitoring" {
  key_name   = "${var.name_prefix}-monitoring-key"
  public_key = tls_private_key.monitoring.public_key_openssh
  tags       = var.common_tags
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.monitoring.private_key_pem
  filename        = "${path.module}/../../${var.name_prefix}-monitoring-key.pem"
  file_permission = "0400"
}

resource "aws_launch_template" "monitoring" {
  name_prefix   = "${var.name_prefix}-monitoring-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.monitoring.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.monitoring_sg_id]
    subnet_id                   = var.public_subnet_id
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.common_tags, { Name = "${var.name_prefix}-monitoring" })
  }

  tags = var.common_tags
}

resource "aws_autoscaling_group" "monitoring" {
  name_prefix         = "${var.name_prefix}-monitoring-"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = [var.public_subnet_id]
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.monitoring.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-monitoring"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.common_tags["Project"]
    propagate_at_launch = true
  }
}

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${var.name_prefix}-dlq-messages-visible"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Se dispara cuando hay mensajes en la DLQ, indicando compras que fallaron repetidamente"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]

  dimensions = {
    QueueName = var.dlq_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_procesamiento_errors" {
  alarm_name          = "${var.name_prefix}-lambda-procesamiento-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Se dispara cuando la Lambda de procesamiento arroja errores"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]

  dimensions = {
    FunctionName = var.lambda_procesamiento_function_name
  }

  tags = var.common_tags
}
