const sql = require('mssql');
require('dotenv').config();

const requiredEnvironmentVariables = [
  'DB_SERVER',
  'DB_PORT',
  'DB_DATABASE',
  'DB_USER',
  'DB_PASSWORD'
];

for (const variableName of requiredEnvironmentVariables) {
  if (!process.env[variableName]) {
    throw new Error(`Missing required environment variable: ${variableName}`);
  }
}

const databaseConfig = {
  server: process.env.DB_SERVER,
  port: Number(process.env.DB_PORT),
  database: process.env.DB_DATABASE,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    encrypt: process.env.DB_ENCRYPT === 'true',
    trustServerCertificate:
      process.env.DB_TRUST_SERVER_CERTIFICATE === 'true'
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  },
  requestTimeout: 30000,
  connectionTimeout: 15000
};

let connectionPool;

async function getDatabasePool() {
  if (connectionPool?.connected) {
    return connectionPool;
  }

  if (connectionPool?.connecting) {
    return connectionPool.connect();
  }

  connectionPool = new sql.ConnectionPool(databaseConfig);

  connectionPool.on('error', (error) => {
    console.error('SQL Server pool error:', error.message);
  });

  await connectionPool.connect();

  return connectionPool;
}

async function closeDatabasePool() {
  if (connectionPool) {
    await connectionPool.close();
    connectionPool = null;
  }
}

module.exports = {
  sql,
  getDatabasePool,
  closeDatabasePool
};