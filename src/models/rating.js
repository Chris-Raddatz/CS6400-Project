const db = require("../database/connection");
const DisplayError = require("../utils/DisplayError");

const addRatingQuery = `
INSERT INTO "Rating" (ItemID, RatingTime, RatingValue,
Comment)
VALUES ($1, NOW(), $2,
$3);
`;

const deleteRatingQuery = `
DELETE FROM "Rating"
WHERE ItemID = $1
`;

const viewRatingQuery = `
WITH avgvalues (ItemName, AverageRating) AS ( SELECT DISTINCT i.itemname,
  ROUND(AVG(r.ratingvalue), 2) FROM "Rating" r JOIN "Item" i ON i.ID = r.ItemID GROUP
  BY 1),
  buyers (id, ItemName, CommentorUsername, RatingTime, RatingValue, Comment) AS
  (SELECT i.ID, i.ItemName, winner.CommentorUsername, r.RatingTime, r.RatingValue,
  r.Comment
  FROM "Item" i 
  INNER JOIN "Rating" r ON i.ID = r.ItemID and i.ItemName LIKE (SELECT ItemName from "Item" WHERE ID = $1)
  JOIN (SELECT B.userid as CommentorUsername, A.itemID FROM "Bid" B
    JOIN "Auction" A ON A.itemid = B.itemid
    WHERE A.endtime <= NOW()
    AND A.canceltime IS NULL
    AND B.amount >= A.minsaleprice
    AND B.amount = (SELECT MAX(amount) FROM "Bid" GROUP BY itemid HAVING itemid = A.itemID)) as winner ON i.ID = winner.ItemID)
  SELECT b.ID, b.ItemName, v.AverageRating, b.CommentorUsername, b.RatingTime,
  b.RatingValue, b.Comment
  FROM buyers b
  JOIN avgvalues v ON b.ItemName = v.ItemName
  ORDER BY b.ratingtime desc
  `;

async function addRating(ItemID, RatingValue, Comment) {
  const { rows } = await db.query(addRatingQuery, [
    ItemID,
    RatingValue,
    Comment,
  ]);
}

async function deleteRating(ItemID) {
  const { rows } = await db.query(deleteRatingQuery, [ItemID]);
}

async function viewRating(ItemID) {
  const { rows } = await db.query(viewRatingQuery, [ItemID]);

  return rows;
}

async function getNameOfItem(ItemID) {
  const { rows } = await db.query(
    `SELECT ItemName
    FROM "Item" WHERE ID = $1`,
    [ItemID]
  );

  return rows[0] != null ? rows[0].itemname : null;
}

async function getWinnerOfItemUsername(ItemID) {
  const { rows } = await db.query(
    `SELECT B.userid as winnerusername FROM "Bid" B
    JOIN "Auction" A ON A.itemid = B.itemid
    WHERE A.endtime <= NOW()
    AND A.canceltime IS NULL
    AND B.amount >= A.minsaleprice
    AND B.amount = (SELECT MAX(amount) FROM "Bid" GROUP BY itemid HAVING itemid = A.itemid)
    AND A.itemid = $1`,
    [ItemID]
  );
  return rows[0] != null ? rows[0].winnerusername: null;
}

module.exports = {
  addRating,
  deleteRating,
  viewRating,
  getWinnerOfItemUsername,
  getNameOfItem,
};
