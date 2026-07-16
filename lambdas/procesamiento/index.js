const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');
const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');

const ddbClient = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const sesClient = new SESClient({});

const TABLE_NAME = process.env.TABLE_NAME;
const SENDER_EMAIL = process.env.SENDER_EMAIL;

exports.handler = async (event) => {
  const results = [];

  for (const record of event.Records) {
    try {
      await processRecord(record);
      results.push({ messageId: record.messageId, status: 'ok' });
    } catch (err) {
      if (err.name === 'ConditionalCheckFailedException') {
        console.warn(`Asiento ya vendido, descartando mensaje: ${record.messageId}`);
        results.push({ messageId: record.messageId, status: 'asiento_ocupado' });
        continue;
      }
      console.error(`Error procesando mensaje ${record.messageId}`, err);
      throw err;
    }
  }

  return { batchResults: results };
};

async function processRecord(record) {
  const purchase = JSON.parse(record.body);

  await ddbClient.send(
    new PutCommand({
      TableName: TABLE_NAME,
      Item: {
        event_id: purchase.event_id,
        seat_id: purchase.seat_id,
        user_id: purchase.user_id,
        price: purchase.price,
        purchased_at: new Date().toISOString(),
      },
      ConditionExpression: 'attribute_not_exists(seat_id)',
    })
  );

  await sendConfirmationEmail(purchase);
}

async function sendConfirmationEmail(purchase) {
  try {
    await sesClient.send(
      new SendEmailCommand({
        Source: SENDER_EMAIL,
        Destination: { ToAddresses: [purchase.user_id] },
        Message: {
          Subject: { Data: 'Confirmación de compra - Ticketfast' },
          Body: {
            Text: {
              Data: `Tu compra fue confirmada.\nEvento: ${purchase.event_id}\nAsiento: ${purchase.seat_id}\nPrecio: ${purchase.price}`,
            },
          },
        },
      })
    );
  } catch (err) {
    console.error('El ticket se guardo pero el correo de confirmacion fallo', err);
  }
}
