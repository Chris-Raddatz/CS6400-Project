const Router = require("express-promise-router");
const router = new Router();
const {
  viewCategoryReport,
  viewUserReport,
  viewTopRatedItems,
  viewAuctionStatistics,
  viewCancelledDetails,
} = require("../models/admin");

router.get("/categories", async (req, res) => {
  const category_report_data = await viewCategoryReport();

  res.render("category_report", { data: category_report_data });
});

router.get("/users", async (req, res) => {
  const user_data = await viewUserReport();

  res.render("user_report", { data: user_data });
});

router.get("/top-items", async (req, res) => {
  const topratedItems = await viewTopRatedItems();
  res.render("top_rated_items", { data: topratedItems });
});

router.get("/auction-stats", async (req, res) => {
  const auctionStats = await viewAuctionStatistics();
  res.render("auction_statistics", { data: auctionStats });
});

router.get("/cancelled-auctions", async (req, res) => {
  const cancelledDetails = await viewCancelledDetails();
  new_details = cancelledDetails;

  for (let i = 0; i <= new_details.length - 1; i++) {
    date = new_details[i].Cancelled_Date;
    dateString = new Date(date).toLocaleString("en-US");
    new_details[i].Cancelled_Date = dateString;
  }

  res.render("cancelled_auction_details", { data: new_details });
});

module.exports = router;
