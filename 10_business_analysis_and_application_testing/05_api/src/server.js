const express = require('express');
require('dotenv').config();

const {
  getDatabasePool,
  closeDatabasePool
} = require('./config/database');

const salesOrderRoutes = require(
  './routes/salesOrderRoutes'
);

const goodsReceiptRoutes = require(
  './routes/goodsReceiptRoutes'
);

const app = express();
const port = Number(process.env.PORT) || 3000;

app.disable('x-powered-by');
app.use(express.json());

app.get('/health', async (req, res) => {
  try {
    const pool = await getDatabasePool();

    const result = await pool.request().query(`
      SELECT
        DB_NAME() AS databaseName,
        GETUTCDATE() AS checkedAt
    `);

    return res.status(200).json({
      status: 'ok',
      service: 'aurevia-erp-control-api',
      database: {
        connected: true,
        name: result.recordset[0].databaseName,
        checkedAt: result.recordset[0].checkedAt
      }
    });
  } catch (error) {
    console.error('Health check failed:', error);

    return res.status(503).json({
      status: 'error',
      service: 'aurevia-erp-control-api',
      database: {
        connected: false
      },
      message:
        'Database connection could not be established.'
    });
  }
});

app.use(
  '/api/sales-orders',
  salesOrderRoutes
);

app.use(
  '/api/goods-receipts',
  goodsReceiptRoutes
);

app.use((req, res) => {
  return res.status(404).json({
    status: 'error',
    message: 'Route not found.'
  });
});

app.use((error, req, res, next) => {
  console.error(
    'Unhandled application error:',
    error
  );

  return res.status(500).json({
    status: 'error',
    message:
      'An unexpected application error occurred.'
  });
});

const server = app.listen(port, async () => {
  try {
    await getDatabasePool();

    console.log(
      `Aurevia API is running on port ${port}`
    );

    console.log(
      'SQL Server connection established'
    );
  } catch (error) {
    console.error(
      'Application startup failed:',
      error.message
    );

    process.exitCode = 1;
    server.close();
  }
});

async function shutdown(signal) {
  console.log(
    `${signal} received. Closing application.`
  );

  server.close(async () => {
    try {
      await closeDatabasePool();

      console.log(
        'Database connection closed'
      );

      process.exit(0);
    } catch (error) {
      console.error(
        'Shutdown error:',
        error.message
      );

      process.exit(1);
    }
  });
}

process.on(
  'SIGINT',
  () => shutdown('SIGINT')
);

process.on(
  'SIGTERM',
  () => shutdown('SIGTERM')
);