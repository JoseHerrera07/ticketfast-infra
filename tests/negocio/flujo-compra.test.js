const { mockClient } = require('aws-sdk-client-mock');
const { SQSClient, SendMessageCommand } = require('../../lambdas/recepcion/node_modules/@aws-sdk/client-sqs');
const { DynamoDBDocumentClient, PutCommand } = require('../../lambdas/procesamiento/node_modules/@aws-sdk/lib-dynamodb');
const { SESClient, SendEmailCommand } = require('../../lambdas/procesamiento/node_modules/@aws-sdk/client-ses');

const sqsMock = mockClient(SQSClient);
const ddbMock = mockClient(DynamoDBDocumentClient);
const sesMock = mockClient(SESClient);

process.env.QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/123456789012/test-queue';
process.env.TABLE_NAME = 'test-tickets';
process.env.SENDER_EMAIL = 'no-reply@test.com';

const recepcion = require('../../lambdas/recepcion/index');
const procesamiento = require('../../lambdas/procesamiento/index');

beforeEach(() => {
  sqsMock.reset();
  ddbMock.reset();
  sesMock.reset();
});

function buildHttpEvent(compra) {
  return { body: JSON.stringify(compra) };
}

function buildSqsRecordFromRecepcion(sentMessageBody, messageId = 'msg-1') {
  return { Records: [{ messageId, body: sentMessageBody }] };
}

describe('Flujo completo de compra (recepcion -> cola -> procesamiento)', () => {
  test('una compra valida se encola, se guarda en DynamoDB y se confirma por correo', async () => {
    sqsMock.on(SendMessageCommand).resolves({ MessageId: 'sqs-1' });

    const compra = { event_id: 'evt1', seat_id: 'A1', user_id: 'cliente@test.com', price: 80 };
    const respuestaRecepcion = await recepcion.handler(buildHttpEvent(compra));

    expect(respuestaRecepcion.statusCode).toBe(202);
    expect(sqsMock.calls()).toHaveLength(1);

    const mensajeEncolado = sqsMock.call(0).args[0].input.MessageBody;

    ddbMock.on(PutCommand).resolves({});
    sesMock.on(SendEmailCommand).resolves({ MessageId: 'ses-1' });

    const respuestaProcesamiento = await procesamiento.handler(
      buildSqsRecordFromRecepcion(mensajeEncolado)
    );

    expect(respuestaProcesamiento.batchResults[0].status).toBe('ok');
    expect(ddbMock.calls()).toHaveLength(1);
    expect(sesMock.calls()).toHaveLength(1);

    const itemGuardado = ddbMock.call(0).args[0].input.Item;
    expect(itemGuardado.seat_id).toBe('A1');
    expect(itemGuardado.event_id).toBe('evt1');
  });

  test('dos compras simultaneas al mismo asiento: solo una tiene exito', async () => {
    sqsMock.on(SendMessageCommand).resolves({ MessageId: 'sqs-1' });

    const compraA = { event_id: 'evt1', seat_id: 'A1', user_id: 'cliente1@test.com', price: 80 };
    const compraB = { event_id: 'evt1', seat_id: 'A1', user_id: 'cliente2@test.com', price: 80 };

    await recepcion.handler(buildHttpEvent(compraA));
    await recepcion.handler(buildHttpEvent(compraB));

    const mensajeA = sqsMock.call(0).args[0].input.MessageBody;
    const mensajeB = sqsMock.call(1).args[0].input.MessageBody;

    const conditionalError = new Error('The conditional request failed');
    conditionalError.name = 'ConditionalCheckFailedException';

    ddbMock.on(PutCommand).resolvesOnce({}).rejectsOnce(conditionalError);
    sesMock.on(SendEmailCommand).resolves({ MessageId: 'ses-1' });

    const resultadoA = await procesamiento.handler(buildSqsRecordFromRecepcion(mensajeA, 'msg-A'));
    const resultadoB = await procesamiento.handler(buildSqsRecordFromRecepcion(mensajeB, 'msg-B'));

    expect(resultadoA.batchResults[0].status).toBe('ok');
    expect(resultadoB.batchResults[0].status).toBe('asiento_ocupado');
    expect(sesMock.calls()).toHaveLength(1);
  });

  test('una compra con datos incompletos nunca llega a generar un mensaje en la cola', async () => {
    const compraIncompleta = { event_id: 'evt1', seat_id: 'A1' };

    const respuesta = await recepcion.handler(buildHttpEvent(compraIncompleta));

    expect(respuesta.statusCode).toBe(400);
    expect(sqsMock.calls()).toHaveLength(0);
  });

  test('si DynamoDB falla temporalmente, el mensaje no se pierde (se relanza para reintento SQS)', async () => {
    sqsMock.on(SendMessageCommand).resolves({ MessageId: 'sqs-1' });

    const compra = { event_id: 'evt1', seat_id: 'B2', user_id: 'cliente@test.com', price: 60 };
    await recepcion.handler(buildHttpEvent(compra));

    const mensajeEncolado = sqsMock.call(0).args[0].input.MessageBody;

    ddbMock.on(PutCommand).rejects(new Error('ProvisionedThroughputExceededException'));

    await expect(
      procesamiento.handler(buildSqsRecordFromRecepcion(mensajeEncolado))
    ).rejects.toThrow();

    expect(sesMock.calls()).toHaveLength(0);
  });
});
