const Router = require("express-promise-router");
const router = new Router();
const { cancelAuction, getAuctionResults } = require("../models/auction");

router.post("/cancel", async (req, res) => {
  const { cancelReason, itemID } = req.body;

  await cancelAuction(itemID, cancelReason);

  res.redirect("/item/view?itemID=" + itemID);
});

router.get("/results", async (req, res) => {
  const auction_data = await getAuctionResults();
  res.render("auction_results", { data: auction_data });
});

module.exports = router;
