const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');

const sqsClient = new SQSClient({});
const QUEUE_URL = process.env.QUEUE_URL;

const REQUIRED_FIELDS = ['event_id', 'seat_id', 'user_id', 'price'];

exports.handler = async (event) => {
  let body;
  try {
    body = JSON.parse(event.body || '{}');
  } catch (err) {
    return respond(400, { error: 'JSON inválido en el body de la solicitud' });
  }

  const missing = REQUIRED_FIELDS.filter((field) => !body[field]);
  if (missing.length > 0) {
    return respond(400, { error: `Faltan campos requeridos: ${missing.join(', ')}` });
  }

  const message = {
    event_id: body.event_id,
    seat_id: body.seat_id,
    user_id: body.user_id,
    price: body.price,
    requested_at: new Date().toISOString(),
  };

  try {
    await sqsClient.send(
      new SendMessageCommand({
        QueueUrl: QUEUE_URL,
        MessageBody: JSON.stringify(message),
      })
    );
  } catch (err) {
    console.error('Error enviando mensaje a SQS', err);
    return respond(502, { error: 'No se pudo encolar la compra, intenta de nuevo' });
  }

  return respond(202, {
    message: 'Compra recibida, se está procesando',
    event_id: message.event_id,
    seat_id: message.seat_id,
  });
};

function respond(statusCode, bodyObj) {
  return {
    statusCode,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(bodyObj),
  };
}
