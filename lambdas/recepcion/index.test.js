const { mockClient } = require('aws-sdk-client-mock');
const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');

const sqsMock = mockClient(SQSClient);
process.env.QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/123456789012/test-queue';

const { handler } = require('./index');

beforeEach(() => {
  sqsMock.reset();
});

function buildEvent(bodyObj) {
  return { body: JSON.stringify(bodyObj) };
}

test('rechaza JSON invalido con 400', async () => {
  const res = await handler({ body: '{ esto no es json' });
  expect(res.statusCode).toBe(400);
});

test('rechaza si faltan campos requeridos', async () => {
  const res = await handler(buildEvent({ event_id: 'evt1' }));
  const body = JSON.parse(res.body);
  expect(res.statusCode).toBe(400);
  expect(body.error).toContain('seat_id');
});

test('encola correctamente una compra valida', async () => {
  sqsMock.on(SendMessageCommand).resolves({ MessageId: 'abc-123' });

  const res = await handler(
    buildEvent({ event_id: 'evt1', seat_id: 'A1', user_id: 'user1', price: 50 })
  );

  expect(res.statusCode).toBe(202);
  expect(sqsMock.calls()).toHaveLength(1);
  const sentCommand = sqsMock.call(0).args[0];
  const sentBody = JSON.parse(sentCommand.input.MessageBody);
  expect(sentBody.seat_id).toBe('A1');
});

test('devuelve 502 si SQS falla', async () => {
  sqsMock.on(SendMessageCommand).rejects(new Error('SQS down'));

  const res = await handler(
    buildEvent({ event_id: 'evt1', seat_id: 'A1', user_id: 'user1', price: 50 })
  );

  expect(res.statusCode).toBe(502);
});
