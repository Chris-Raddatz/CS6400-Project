const fs = require("fs");
const path = require("path");
const db = require("./connection");

// get the contents of our init.sql file
const initPath = path.join(__dirname, "init.sql");
const initSQL = fs.readFileSync(initPath, "utf-8");

function build() {
  return db.query(initSQL).then(() => {
    console.log("Database built");
    db.end(); // close the connection as we're finished
    console.log("Connection closed");
  });
}

if (require.main === module) {
  build();
}

module.exports = build;
