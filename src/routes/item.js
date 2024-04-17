const Router = require("express-promise-router");
const router = new Router();
const DisplayError = require("../utils/DisplayError");
const {
  getItemCategories,
  getItemConditions,
  insertItem,
  fetchItem,
  viewSearchResults,
  updateItemDescription,
} = require("../models/item");

router.get("/list-item", async (req, res) => {
  const categories = await getItemCategories();
  const conditions = getItemConditions();
  res.render("list_item", { categories, conditions });
});

router.post("/list-item", async (req, res) => {
  //Save item
  const {
    itemName,
    description,
    category,
    condition,
    startBiddingAmount,
    minimumSalePrice,
    auctionEndsInDays,
    getItNowPrice,
    isReturnAccepted,
  } = req.body;

  const username = req.user.username;

  const itemID = await insertItem(
    itemName,
    username,
    description,
    category,
    condition,
    isReturnAccepted,
    Number(startBiddingAmount),
    Number(minimumSalePrice),
    Number(auctionEndsInDays),
    Number(getItNowPrice)
  );

  res.redirect("view?itemID=" + itemID);
});

router.get("/search", async (req, res) => {
  const categories = await getItemCategories();
  const conditions = getItemConditions();

  res.render("search", { data: categories, data2: conditions });
});

router.get("/search/result", async (req, res) => {
  const { keyword, category, minimum_price, maximum_price, condition } =
    req.query;
  keyword_send = "%" + keyword + "%";

  let condition_send = null,
    category_send = null,
    minimum_price_send = null,
    maximum_price_send = null;

  if (condition !== "") {
    condition_send = condition;
  }

  if (category !== "") {
    category_send = category;
  }

  if (minimum_price !== "") {
    minimum_price_send = Number(minimum_price);
  }

  if (maximum_price !== "") {
    maximum_price_send = Number(maximum_price);
  }

  const item_results = await viewSearchResults(
    keyword_send,
    category_send,
    minimum_price_send,
    maximum_price_send,
    condition_send
  );

  res.render("item_results", { data: item_results });
});

router.get("/view", async (req, res) => {
  const { itemID } = req.query;

  try {
    const itemData = await fetchItem(itemID);
    itemData.itemID = itemID;
    const isAdmin = req.user.isAdmin;

    let isActiveItem = false;
    const currentDate = new Date(Date.now());
    const endDate = new Date(itemData.endtime);

    if (itemData.canceltime == null && currentDate < endDate) {
      isActiveItem = true;
    }

    itemData.isOwnedByLoggedInUser =
      req.user.username === itemData.ownerusername;

    res.render("item_for_sale", { itemData, isAdmin, isActiveItem });
  } catch (error) {
    req.session.messages = [`No active items found for itemID ${itemID}.`];
    res.redirect("/menu");
  }
});

router.post("/description", async (req, res) => {
  const { itemID, newDescription } = req.body;

  // Assuming the updateItemDescription function returns the updated item or null if the item doesn't exist
  const result = await updateItemDescription(itemID, newDescription.trim());

  res.redirect(`/item/view?itemID=${itemID}`);
});

module.exports = router;
