const db = require("../database/connection");
const DisplayError = require("../utils/DisplayError");

// SQL query to find a user by username.
// This query uses parameterized input to prevent SQL injection.
const LogInQuery = `
SELECT
    Username,
    UserPassword,
    Position
FROM
    "User" NATURAL LEFT JOIN "AdminUser"
WHERE
    Username = $1
`;

// Authenticates a user by checking their credentials against the database
// Throws an error if credentials are missing, incorrect, or if the user does not exist
async function authenticate(username, password) {
  if (!username || !password) {
    throw new DisplayError("Username and password must be provided.");
  }

  const { rows } = await db.query(LogInQuery, [username]);
  const foundUser = rows[0]; // The first row of the result is the user, if found

  if (!foundUser) {
    throw new DisplayError("Username not found.");
  }

  if (foundUser.userpassword !== password) {
    throw new DisplayError("Incorrect password.");
  }

  return foundUser; // Return the authenticated user's details
}

const RegisterQuery = `
INSERT INTO 
    "User" (Username, UserPassword, FirstName, LastName) 
VALUES ($1, $2, $3, $4); 
`;

// Registers a new user, checking for missing fields and password confirmation
// Throws errors for missing fields, password mismatch, or if the username already exists
async function registerUser(
  username,
  password,
  confirmPassword,
  firstName,
  lastName
) {
  const missingFields = [];

  if (!username) {
    missingFields.push("Username");
  }
  if (!password) {
    missingFields.push("Password");
  }
  if (!confirmPassword) {
    missingFields.push("Confirm Password");
  }
  if (!firstName) {
    missingFields.push("First Name");
  }
  if (!lastName) {
    missingFields.push("Last Name");
  }

  if (missingFields.length > 0) {
    const errorMessage = `${missingFields.join(", ")} ${missingFields.length > 1 ? "are" : "is"} required`;
    throw new DisplayError(errorMessage);
  }

  if (password !== confirmPassword) {
    throw new DisplayError("Passwords do not match");
  }

  try {
    await db.query(RegisterQuery, [username, password, firstName, lastName]);
  } catch (err) {
    if (err.code === "23505") {
      throw new DisplayError("Username already exists"); // Handle unique constraint violation
    } else {
      throw new Error("User registration failed.");
    }
  }

  // Return the newly registered user's username and password
  return { username, password };
}

const ViewMenuQuery = `
SELECT
    FirstName,
    LastName,
    Position
FROM
    "User" U
    LEFT JOIN "AdminUser" A ON U.Username = A.Username
WHERE
    U.Username = $1;
`;

// Fetches and returns menu data for the given user
async function viewMenu(username) {
  const { rows } = await db.query(ViewMenuQuery, [username]);
  const menuData = rows[0];
  return menuData;
}

module.exports = { registerUser, authenticate, viewMenu };
