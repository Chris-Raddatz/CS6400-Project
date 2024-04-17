const db = require("../database/connection");
const DisplayError = require("../utils/DisplayError");
const ItemConditions = require("../utils/ItemConditions");

const CategoryNamesQuery = `
SELECT CategoryName FROM "Category";
`;

async function getItemCategories() {
  const { rows } = await db.query(CategoryNamesQuery);
  const data = rows;

  return data;
}

function getItemConditions() {
  return [
    { condition: ItemConditions.POOR },
    { condition: ItemConditions.FAIR },
    { condition: ItemConditions.GOOD },
    { condition: ItemConditions.VERYGOOD },
    { condition: ItemConditions.NEW },
  ];
}

const InsertItemQuery = `
INSERT INTO "Item" (ItemName, OwnerUsername, ItemDescription, CategoryName, Condition, IsReturnable)
VALUES ($1, $2, $3, $4, cast ($5 AS conditionenum), $6) RETURNING ID;
`;

const InsertAuctionQuery = `INSERT INTO "Auction"
(ItemID, StartingBid, MinSalePrice, EndTime, GetNowPrice)
VALUES
((SELECT MAX(ID) FROM "Item"), $1, $2, ( SELECT NOW() + $3 * INTERVAL '1 day'), $4 );
`;

async function insertItem(
  itemName,
  username,
  description,
  category,
  condition,
  isReturnAccepted,
  startBiddingAmount,
  minimumSalePrice,
  auctionEndsInDays,
  getItNowPrice
) {
  const missingFields = [];

  if (!itemName) {
    missingFields.push("Item Name");
  }
  if (!username) {
    missingFields.push("Username");
  }
  if (!description) {
    missingFields.push("Description");
  }
  if (!category) {
    missingFields.push("Category");
  }
  if (condition == null) {
    missingFields.push("Condition");
  }
  if (startBiddingAmount == null) {
    missingFields.push("Start auction bidding at $");
  }
  if (minimumSalePrice == null) {
    missingFields.push("Minimum sale price $");
  }
  if (auctionEndsInDays == null) {
    missingFields.push("Auction ends in");
  }

  if (missingFields.length > 0) {
    const errorMessage = `${missingFields.join(", ")} ${missingFields.length > 1 ? "are" : "is"} required`;
    throw new DisplayError(errorMessage);
  }

  if (minimumSalePrice < startBiddingAmount) {
    throw new DisplayError(
      "Minimum sale price must be greater than or equal to the start bidding amount"
    );
  }

  if (
    getItNowPrice > 0 &&
    (getItNowPrice < minimumSalePrice || getItNowPrice < startBiddingAmount)
  ) {
    throw new DisplayError(
      "Get It Now Price must be greater than the minimum sale price and starting bidding at amount"
    );
  }

  if (isReturnAccepted == null) {
    isReturnAccepted = false;
  } else {
    isReturnAccepted = true;
  }

  try {
    const { rows } = await db.query(InsertItemQuery, [
      itemName,
      username,
      description,
      category,
      condition,
      isReturnAccepted,
    ]);

    const itemID = rows[0].id;

    await db.query(InsertAuctionQuery, [
      startBiddingAmount,
      minimumSalePrice,
      auctionEndsInDays,
      getItNowPrice == 0 ? null : getItNowPrice,
    ]);

    return itemID;
  } catch (error) {
    console.log(error);
    throw new DisplayError("Something went wrong creating the item for sale");
  }
}

const ViewItemQuery = `
SELECT i.ID as "itemID", i.OwnerUsername, i.ItemName, i.ItemDescription, i.CategoryName, i.Condition, i.IsReturnable, a.GetNowPrice, a.EndTime, a.CancelTime, a.MinSalePrice, a.StartingBid
FROM "Item" i
JOIN "Auction" a ON i.ID = a.ItemID
WHERE i.ID = $1
`;

const TopItemBidsQuery = `
SELECT b.Amount, b.BidTime, b.UserID
FROM "Bid" b
JOIN "Auction" a ON b.ItemID = a.ItemID
WHERE b.ItemID = $1
ORDER BY 2 DESC
LIMIT 4;
`;

async function fetchItem(itemID) {
  const { rows: itemRows } = await db.query(ViewItemQuery, [itemID]);

  if (itemRows.length === 0) {
    throw new DisplayError("The item does not exist");
  }

  const data = itemRows[0];
  const { rows: bidRows } = await db.query(TopItemBidsQuery, [itemID]);
  data.bids = bidRows;

  return data;
}

const itemResultsQuery = `
SELECT I.ID, I.ItemName, A.GetNowPrice, A.EndTime, COALESCE(B.UserID, '-') AS HighestBidUser, COALESCE(MAX(B.Amount), A.StartingBid) AS HighestBidAmount 
FROM  "Item" I LEFT JOIN "Auction" A ON A.ItemID = I.ID 
LEFT JOIN "Bid" B ON B.ItemID = I.ID AND B.Amount = (SELECT MAX(C.Amount) 
FROM "Bid" C 
WHERE C.ItemID = I.ID) 
WHERE A.EndTime > NOW() AND A.CancelTime IS NULL AND ( 
I.ItemName LIKE $1 OR $1 IS NULL OR I.ItemDescription LIKE $1) 
AND (I.CategoryName LIKE $2 OR $2 IS NULL) 
AND (COALESCE(B.Amount, A.StartingBid) >= $3 OR $3 IS NULL) 
AND (COALESCE(B.Amount, A.StartingBid) <= $4 OR $4 IS NULL) 
AND (I.Condition >= cast ($5 AS conditionenum) OR cast ($5 AS conditionenum) IS NULL) 
GROUP BY I.ID, I.ItemName, A.GetNowPrice, A.EndTime, B.UserID, A.StartingBid 
ORDER BY A.EndTime ASC; 
`;

async function viewSearchResults(
  keyword,
  category,
  minimum_price,
  maximum_price,
  condition
) {
  const { rows } = await db.query(itemResultsQuery, [
    keyword,
    category,
    minimum_price,
    maximum_price,
    condition,
  ]);
  const data = rows;

  if (data.length == 0) throw new DisplayError("No items found");

  return data;
}

async function updateItemDescription(itemID, newDescription) {
  // Basic validation
  if (
    !itemID ||
    typeof newDescription !== "string" ||
    newDescription.trim() === ""
  ) {
    throw new DisplayError(
      "Invalid request: Item ID and new description are required."
    );
  }

  const query = `
          UPDATE "Item"
          SET ItemDescription = $1
          WHERE ID = $2
          RETURNING *;
      `;

  // Execute the query with parameterized inputs
  const result = await db.query(query, [newDescription, itemID]);

  // Check if any row is updated
  if (result.rows.length > 0) {
    return result.rows[0]; // Return the first (and should be only) updated row
  } else {
    return null; // No rows updated, item ID might not exist
  }
}

module.exports = {
  getItemCategories,
  getItemConditions,
  insertItem,
  fetchItem,
  viewSearchResults,
  updateItemDescription,
};
