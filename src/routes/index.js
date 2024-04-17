const user = require("./user");
const admin = require("./admin");
const item = require("./item");
const bid = require("./bid");
const auction = require("./auction");
const rating = require("./rating");

const MountRoutes = (app) => {
  app.use("/", user);
  app.use("/admin", admin);
  app.use("/item", item);
  app.use("/bid", bid);
  app.use("/auction", auction);
  app.use("/rating", rating);
};

module.exports = MountRoutes;
