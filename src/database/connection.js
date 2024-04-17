const { Pool } = require("pg");
const dotenv = require("dotenv");

dotenv.config(); // load environment variables

// Determine the environment and set the database connection string accordingly
const connectionString =
  process.env.NODE_ENV === "test"
    ? process.env.TEST_DATABASE_URL
    : process.env.DEV_DATABASE_URL;

console.log(`Starting in ${process.env.NODE_ENV}`);

const db = new Pool({
  connectionString,
});

const query = (query, params) => {
  console.log(`Query: ${query}\nParams: ${params}`);
  return db.query(query, params);
};

const end = () => {
  db.end();
};

module.exports = { query, end };
