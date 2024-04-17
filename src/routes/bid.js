const Router = require("express-promise-router");
const router = new Router();
const { insertBid } = require("../models/bid");

router.post("/place", async (req, res) => {
  const username = req.user.username;
  const { itemID, bidAmount, getItNowFlag } = req.body;

  await insertBid(username, itemID, bidAmount, getItNowFlag);
  res.redirect(`/item/view?itemID=${itemID}`);
});

module.exports = router;
