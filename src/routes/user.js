// Import necessary modules
const Router = require("express-promise-router"); // A router supporting promises/async functions, for cleaner async code handling
const router = new Router(); // Initialize a new router instance for defining routes
const { authenticate, registerUser, viewMenu } = require("../models/user"); // Import the User model to interact with user data
const LocalStrategy = require("passport-local"); // A Passport strategy for username and password authentication
const passport = require("passport"); // Authentication middleware for Node.js

// Define the strategy passport uses for local authentication
passport.use(
  new LocalStrategy(async function verify(username, password, done) {
    // This asynchronous function is called during the login attempt
    try {
      // Attempt to authenticate the user by username and password. This waits for the database query to complete.
      const authenticatedUser = await authenticate(username, password);

      // If authentication is successful, pass the username and administrator status to be saved in session.
      return done(null, {
        username: authenticatedUser.username,
        isAdmin: authenticatedUser.position ? true : false,
      });
    } catch (err) {
      done(err);
    }
  })
);

// Serialize user information into the session. Useful for minimizing session data stored.
passport.serializeUser(function (user, done) {
  done(null, user); // Store user in the session
});

// Deserialize the user data from the session. This is the reverse of serializeUser.
passport.deserializeUser(function (user, done) {
  // Pass the user data to the done function, effectively restoring the user object from the session store
  return done(null, user);
});

// Define a route for GET requests on '/login' to display the login page
router.get("/login", (req, res) => {
  // Render the login view using the template engine (e.g., EJS, Pug)
  res.render("login");
});

// Define a route for POST requests on '/login' to handle login attempts
router.post(
  "/login",
  passport.authenticate("local", {
    // Use passport to authenticate using the local strategy defined above
    successRedirect: "/menu", // On successful login, redirect to the menu page
    failureRedirect: "/login", // On failure, redirect back to the login page
    failureMessage: true, // Allow passport to handle failure messages
  })
);

// Define a route for POST requests on '/logout' to handle logout functionality
router.post("/logout", function (req, res, next) {
  req.logout(function (err) {
    // Passport provides the logout method to remove the user from the session
    if (err) {
      return next(err); // Pass errors to the next middleware (error handler)
    }
    req.session.messages = ["You have been logged out."];
    res.redirect("/login"); // Redirect to the home page after logging out
  });
});

// Route to display the registration page
router.get("/register", function (req, res, next) {
  res.render("register");
});

// Route for processing registration form submissions
router.post("/register", async function (req, res, next) {
  const { username, password, firstName, lastName, confirmPassword } = req.body;

  try {
    const newUser = await registerUser(
      username,
      password,
      confirmPassword,
      firstName,
      lastName
    );

    // Upon successful registration, log the user into the system by hooking into passport.js
    req.login(
      { username: newUser.username, password: newUser.password },
      (err) => {
        // passport.js provided login function. Saves user information to the session
        if (err) {
          return next(err);
        }

        res.status(201).redirect("/menu");
      }
    );
  } catch (err) {
    next(err);
  }
});

// Define a GET route for the menu path ('/menu')
router.get("/menu", async (req, res, next) => {
  // This is an asynchronous function, meaning it can perform operations that take some time to complete, like fetching data from a database

  // Await the ViewMenu function or method, passing in the username of the currently logged-in user
  // The ViewMenu function is expected to return an object containing the data
  const menuData = await viewMenu(req.user.username);

  menuData.isAdmin = req.user.isAdmin;

  // This response renders the menu view with the data fetched from the database
  res.render("menu", menuData);
});

// Export the router to make it available for use in other parts of the application
module.exports = router;
