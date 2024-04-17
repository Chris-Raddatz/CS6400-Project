// Import necessary libraries
const express = require("express"); // Express.js library for building web servers
const app = express(); // Create an instance of an Express app
const session = require("express-session"); // Library to handle user sessions
const passport = require("passport"); // Authentication library
const createError = require("http-errors"); // Utility to create HTTP errors
var path = require("path"); // Utility to handle and transform file paths

// Define the port to run the server on, either from an environment variable or default to 3000
const port = process.env.PORT || 3000;

// Middleware to parse data from forms submitted through POST requests
app.use(express.urlencoded({ extended: false }));

// Serve static files (like images, CSS, JavaScript) from the 'public' directory
app.use(express.static(path.join(__dirname, "public")));

// Set the view engine to EJS for rendering templates
app.set("view engine", "ejs");
// Define the directory where the view templates are located
app.set("views", "./src/views");

// Configure session middleware with options for security and functionality
app.use(
  session({
    secret: "keyboard", // A secret key used to sign the session ID cookie, replace it with a random, secure string
    resave: false, // Don't save session if unmodified
    saveUninitialized: true, // Don't create session until something stored
  })
);

// Initialize Passport for authentication and use session for storing user info
app.use(passport.authenticate("session"));

// Middleware to flash messages, useful for showing success or error messages between redirects
app.use((req, res, next) => {
  var msgs = req.session.messages || []; // Retrieve messages from session
  res.locals.messages = msgs; // Make messages accessible to the views
  res.locals.hasMessages = !!msgs.length; // Boolean flag for if there are messages
  req.session.messages = []; // Clear messages after displaying
  next(); // Continue to next middleware
});

// Middleware to protect routes
app.use((req, res, next) => {
  if (req.isAuthenticated()) {
    // Check if user is authenticated
    return next(); // Proceed if authenticated
  }

  const allowList = ["/login", "/register"]; // List of routes that don't require authentication
  if (allowList.indexOf(req.url) > -1) {
    // Check if the requested URL is in the allow list
    return next(); // Requested URL is accessible without authentication, proceed
  }

  res.redirect("/login"); // Redirect unauthenticated users to login page
});

// Define a route for GET requests on the root URL
app.get("/", (req, res, next) => {
  if (req.isAuthenticated()) {
    // If the user is signed on
    res.redirect("/menu"); // Redirect to the menu page
  }

  res.redirect("/login"); // Else, redirect to the login page
});

// Import and use routes for application
const DisplayError = require("./utils/DisplayError"); // Custom error handler to distinguish between expected errors crashes
const MountRoutes = require("./routes");
MountRoutes(app); // Apply the routes to the Express application

// Middleware to catch 404 (Not Found) errors and forward to error handler
app.use(function (req, res, next) {
  next(createError(404));
});

// General error handler middleware
app.use(function (err, req, res, next) {
  if (err instanceof DisplayError) {
    req.session.messages = [err.message]; // Store error message in session for display
    res.redirect(req.get("Referrer")); // Redirect to the original URL to display the message
  } else {
    // Set locals, only providing error in development
    res.locals.message = err.message; // Error message
    res.locals.error = req.app.get("env") === "development" ? err : {}; // Error details
    // Render the error page
    res.status(err.status || 500);
    res.render("error");
  }
});

// Start the server
app.listen(port, () => console.log(`App listening on port ${port}`));

// Export the app for use in other files (like tests)
module.exports = app;
