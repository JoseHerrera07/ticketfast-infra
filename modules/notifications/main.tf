resource "aws_ses_email_identity" "sender" {
  email = var.ses_sender_email
}

resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-purchases-alerts"
  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
