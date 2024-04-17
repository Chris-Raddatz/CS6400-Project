const db = require("../database/connection");
const DisplayError = require("../utils/DisplayError");

const CancelAuctionQuery = `
UPDATE "Auction"
SET CancelTime = NOW(), CancelReason = $1
WHERE ItemID = $2;
`;

async function cancelAuction(itemID, cancelReason) {
  if (!itemID || !cancelReason) {
    throw new DisplayError("Item ID and Cancel Reason must be provided.");
  }

  await db.query(CancelAuctionQuery, [cancelReason, itemID]);

  return true;
}

const auctionResultsQuery = `
SELECT I.ID, I.ItemName, B.Amount, B.UserID, COALESCE(A.CancelTime, A.EndTime) as endtime
FROM "Item" I
JOIN "Auction" A ON I.ID = A.ItemID 
JOIN "Bid" B ON I.ID = B.ItemID
WHERE B.Amount = (SELECT MAX(C.Amount) From "Bid" C WHERE C.ItemID = I.ID)
    AND B.Amount >= A.MinSalePrice
    AND NOW() >= A.EndTime
UNION SELECT I.ID, I.ItemName, NULL as Amount, NULL as UserID, COALESCE(A.CancelTime, A.EndTime) as endtime
FROM "Item" I
    JOIN "Auction" A ON I.ID = A.ItemID JOIN "Bid" B ON I.ID = B.ItemID
WHERE NOW() >= A.EndTime AND ( ( B.Amount < A.MinSalePrice
 AND B.Amount = (SELECT MAX(C.Amount) From "Bid" C WHERE C.ItemID = I.ID)
  ) OR B.Amount IS NULL) AND A.canceltime IS NULL
UNION SELECT I.ID, I.ItemName, NULL as Amount, 'cancelled' as UserID,  COALESCE(A.CancelTime, A.EndTime) as endtime
FROM "Item" I JOIN "Auction" A ON I.ID = A.ItemID
WHERE A.canceltime IS NOT NULL
ORDER BY EndTime DESC;
`;

async function getAuctionResults() {
  const { rows: auction_results_data } = await db.query(auctionResultsQuery);

  const data = auction_results_data;

  return data;
}

module.exports = { cancelAuction, getAuctionResults };
