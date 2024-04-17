const db = require("../database/connection");
const DisplayError = require("../utils/DisplayError");

const CategoryReport = `
SELECT * FROM (SELECT
  I.CategoryName as "Category",
  COUNT(I.ID) as "Total_Items"
FROM
  "Item" I
  LEFT JOIN "Auction" A ON A.ItemID = I.ID
GROUP BY
  I.CategoryName
ORDER BY
  I.CategoryName ) as itemcount
NATURAL LEFT JOIN (
SELECT
  I.CategoryName as "Category",
  MIN(A.GetNowPrice) as "Min_Price",
  MAX(A.GetNowPrice) as "Max_Price",
  ROUND(AVG(A.GetNowPrice), 2) as "Average_Price"
FROM
  "Auction" A
  LEFT JOIN "Item" I ON A.ItemID = I.ID
WHERE
  A.CancelTime IS NULL
  AND A.GetNowPrice IS NOT NULL
GROUP BY
  I.CategoryName
ORDER BY
  I.CategoryName ASC
) as finances
`;

async function viewCategoryReport() {
  const { rows } = await db.query(CategoryReport);
  const categorydata = rows;
  return categorydata;
}

const UserReport = `
SELECT COL1.Username, COL2.total_listed, COL3.total_sold, COL4.total_won, COL5.total_rated, COL6.most_listed_condition
FROM "User" COL1 
LEFT JOIN (SELECT I.OwnerUsername as Username, COUNT(*) as total_listed 
FROM "Item" I 
GROUP BY I.OwnerUsername ) AS COL2 ON COL2.Username = COL1.Username 
LEFT JOIN ( SELECT I.OwnerUsername as Username, COUNT(*) as total_sold 
FROM "Item" I 
JOIN "Auction" A ON A.ItemID = I.ID 
JOIN "Bid" B ON B.ItemID = I.ID 
WHERE NOW() >= A.EndTime AND A.CancelTime IS NULL  
AND B.amount = (SELECT MAX(amount) FROM "Bid" GROUP BY itemid HAVING itemid = A.itemID)
AND A.MinSalePrice <= (SELECT MAX(Amount) FROM "Bid" GROUP BY itemid HAVING itemid = A.itemID) 
GROUP BY I.OwnerUsername ) AS COL3 ON COL3.Username = COL1.Username 
LEFT JOIN (SELECT U.Username as Username, COUNT(*) as total_won 
FROM "User" U 
JOIN "Bid" B ON B.UserID = U.Username 
JOIN "Auction" A ON A.ItemID = B.ItemID 
WHERE NOW() >= A.EndTime AND A.CancelTime IS NULL 
AND A.MinSalePrice <= ( 
SELECT MAX(Amount) 
FROM "Bid" 
WHERE ItemID = A.ItemID) 
AND U.Username = ( 
SELECT UserID 
FROM "Bid" 
WHERE ItemID = A.ItemID  
AND Amount = ( SELECT MAX(Amount) FROM "Bid" 
 WHERE ItemID = A.ItemID)) 
GROUP BY U.Username ) AS COL4 ON COL4.Username = COL1.Username 
LEFT JOIN 
(SELECT U.Username as Username, COUNT(*) as total_rated 
FROM "User" U 
INNER JOIN (SELECT B.userid as Username, A.itemID FROM "Bid" B
    JOIN "Auction" A ON A.itemid = B.itemid
	  INNER JOIN "Rating" R ON R.itemid = A.itemid
    WHERE A.endtime <= NOW()
    AND A.canceltime IS NULL
    AND B.amount >= A.minsaleprice
    AND B.amount = (SELECT MAX(amount) FROM "Bid" GROUP BY itemid HAVING itemid = A.itemID)) as winner ON winner.Username = U.Username 
GROUP BY U.Username ) AS COL5 ON COL5.Username = COL1.Username 
LEFT JOIN 
(SELECT U.Username as Username, MODE() WITHIN GROUP ( ORDER BY I.Condition ) AS most_listed_condition 
FROM "User" U 
LEFT JOIN "Item" I ON I.OwnerUsername = U.Username 
GROUP BY U.Username ) AS COL6 ON COL6.Username = COL1.Username 
ORDER BY COL2.total_listed DESC NULLS LAST; 
`;

async function viewUserReport() {
  const { rows } = await db.query(UserReport);
  const userdata = rows;
  return userdata;
}

const topRatedItems = `
SELECT I.ItemName, ROUND(AVG(R.RatingValue), 1) as avgRating, COUNT(R.RatingValue) as ratingCount
FROM "Item" I
JOIN "Rating" R ON I.ID = R.ItemID
GROUP BY I.ItemName
ORDER BY avgRating DESC, 1 ASC
LIMIT 10;
`;

async function viewTopRatedItems() {
  const { rows } = await db.query(topRatedItems);
  const toprated = rows;
  return toprated;
}

const auctionStats = `
WITH AuctionStats AS ( 
  SELECT COUNT(*) FILTER (WHERE Auction.CancelTime IS NULL AND Auction.EndTime > NOW()) AS AuctionsActive, 
      COUNT(*) FILTER (WHERE Auction.CancelTime IS NULL AND Auction.EndTime <= NOW()) AS AuctionsFinished, 
      COUNT(*) FILTER (WHERE Auction.CancelTime IS NOT NULL) AS AuctionsCancelled, 
      COUNT(*) FILTER (WHERE  Auction.CancelTime IS NULL AND Auction.EndTime <= NOW() AND EXISTS ( 
                  SELECT 1 FROM "Bid" Bid 
                  WHERE Bid.ItemID = Auction.ItemID AND Bid.Amount >= Auction.MinSalePrice 
              )) AS AuctionsWon 
  FROM "Auction" Auction 
), 
RatingStats AS ( 
  SELECT COUNT(DISTINCT Item.ID) FILTER ( 
          WHERE EXISTS (SELECT 1 FROM "Rating" Rating WHERE Rating.ItemID = Item.ID ) 
      ) AS ItemsRated, 
      COUNT(DISTINCT Item.ID) FILTER ( 
          WHERE NOT EXISTS (SELECT 1 FROM "Rating" Rating WHERE Rating.ItemID = Item.ID) 
      ) AS ItemsNotRated 
  FROM "Item" Item 
) 
SELECT 
  COALESCE(AuctionStats.AuctionsActive, 0) AS AuctionsActive, 
  COALESCE(AuctionStats.AuctionsFinished, 0) AS AuctionsFinished, 
  COALESCE(AuctionStats.AuctionsWon, 0) AS AuctionsWon, 
  COALESCE(AuctionStats.AuctionsCancelled, 0) AS AuctionsCancelled, 
  COALESCE(RatingStats.ItemsRated, 0) AS ItemsRated, 
  COALESCE(RatingStats.ItemsNotRated, 0) AS ItemsNotRated 
FROM 
  AuctionStats, RatingStats; 
`;

async function viewAuctionStatistics() {
  const { rows } = await db.query(auctionStats);
  const auctionstat = rows;
  return auctionstat;
}

const cancelledDetails = `
SELECT a.ItemID AS "ID", i.OwnerUsername AS "Listed_By", a.CancelTime AS "Cancelled_Date", a.CancelReason AS "Reason"
FROM "Auction" a
INNER JOIN "Item" i ON a.ItemID = i.ID
WHERE a.CancelTime IS NOT NULL
ORDER BY 1 DESC
`;

async function viewCancelledDetails() {
  const { rows } = await db.query(cancelledDetails);
  const cancelledDetail = rows;
  return cancelledDetail;
}

module.exports = {
  viewCategoryReport,
  viewUserReport,
  viewTopRatedItems,
  viewAuctionStatistics,
  viewCancelledDetails,
};
