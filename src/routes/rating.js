const Router = require("express-promise-router");
const router = new Router();
const {
  addRating,
  deleteRating,
  viewRating,
  getWinnerOfItemUsername,
  getNameOfItem,
} = require("../models/rating");

router.get("/", async (req, res) => {
  const { itemID } = req.query;
  const itemName = await getNameOfItem(itemID);
  const ratingData = await viewRating(itemID);

  let itemWinnerUsername = await getWinnerOfItemUsername(itemID);

  ratingData.mainitem = {
    id: itemID,
    itemname: itemName,
    averagerating: ratingData[0] != null ? ratingData[0].averagerating: null,
  };

  ratingData.canAdd = false;

  if (req.user.username == itemWinnerUsername) {
    ratingData.canAdd = true;
  }

  for (let i = 0; i < ratingData.length; i++) {
    itemWinnerUsername = await getWinnerOfItemUsername(ratingData[i].id);

    ratingData[i].canDelete = false;

    if (ratingData[i].id == itemID) {
      ratingData.canAdd = false;
    }

    if (req.user.username == itemWinnerUsername) {
      ratingData[i].canDelete = true;
    }

    if (req.user.isAdmin) {
      ratingData[i].canDelete = true;
    }
  }

  res.render("view_ratings", { ratingData });
});

router.post("/", async (req, res) => {
  const { itemID, ratingValue, ratingComment, action } = req.body;

  if (action === "add") {
    await addRating(itemID, ratingValue, ratingComment);
  } else if (action === "delete") {
    await deleteRating(itemID);
  }

  setTimeout(() => {
    res.redirect(req.get("Referrer"));
  }, 1000);
});

module.exports = router;
