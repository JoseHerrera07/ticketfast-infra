const { mockClient } = require('aws-sdk-client-mock');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');
const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');

const ddbMock = mockClient(DynamoDBDocumentClient);
const sesMock = mockClient(SESClient);

process.env.TABLE_NAME = 'test-tickets';
process.env.SENDER_EMAIL = 'no-reply@test.com';

const { handler } = require('./index');

beforeEach(() => {
  ddbMock.reset();
  sesMock.reset();
});

function buildSqsEvent(purchase, messageId = 'msg-1') {
  return {
    Records: [{ messageId, body: JSON.stringify(purchase) }],
  };
}

test('guarda el ticket en DynamoDB y envia el correo de confirmacion', async () => {
  ddbMock.on(PutCommand).resolves({});
  sesMock.on(SendEmailCommand).resolves({ MessageId: 'ses-1' });

  const purchase = { event_id: 'evt1', seat_id: 'A1', user_id: 'cliente@test.com', price: 50 };
  const res = await handler(buildSqsEvent(purchase));

  expect(ddbMock.calls()).toHaveLength(1);
  expect(sesMock.calls()).toHaveLength(1);
  expect(res.batchResults[0].status).toBe('ok');
});

test('descarta el mensaje si el asiento ya fue vendido (ConditionalCheckFailedException)', async () => {
  const conditionalError = new Error('The conditional request failed');
  conditionalError.name = 'ConditionalCheckFailedException';
  ddbMock.on(PutCommand).rejects(conditionalError);

  const purchase = { event_id: 'evt1', seat_id: 'A1', user_id: 'cliente@test.com', price: 50 };
  const res = await handler(buildSqsEvent(purchase));

  expect(res.batchResults[0].status).toBe('asiento_ocupado');
  expect(sesMock.calls()).toHaveLength(0);
});

test('relanza el error si DynamoDB falla por otra razon (para que SQS reintente)', async () => {
  ddbMock.on(PutCommand).rejects(new Error('DynamoDB no disponible'));

  const purchase = { event_id: 'evt1', seat_id: 'A1', user_id: 'cliente@test.com', price: 50 };

  await expect(handler(buildSqsEvent(purchase))).rejects.toThrow('DynamoDB no disponible');
});

test('el ticket se guarda aunque el correo de confirmacion falle', async () => {
  ddbMock.on(PutCommand).resolves({});
  sesMock.on(SendEmailCommand).rejects(new Error('SES no disponible'));

  const purchase = { event_id: 'evt1', seat_id: 'A1', user_id: 'cliente@test.com', price: 50 };
  const res = await handler(buildSqsEvent(purchase));

  expect(res.batchResults[0].status).toBe('ok');
});
