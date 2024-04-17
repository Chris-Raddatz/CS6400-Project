const db = require("../database/connection");
const DisplayError = require("../utils/DisplayError");

const verifyBidQuery = `
SELECT A.EndTime, A.StartingBid, A.GetNowPrice, I.ownerusername, MAX(B.Amount)
FROM "Auction" A
LEFT JOIN "Bid" B ON B.ItemID = A.ItemID
LEFT JOIN "Item" I ON I.ID = A.ItemID
GROUP BY A.ItemID, I.ID
HAVING A.ItemID = $1;
`;

const insertBidquery = `
INSERT INTO "Bid" (UserID, ItemID, Amount, BidTime) 
VALUES ($1, $2, $3, NOW()); 
`;

async function insertBid(username, itemID, bidAmount, getItNowFlag) {
  // Check if the bid is acceptable for the item’s auction
  getItNowFlag = getItNowFlag === "true" ? true : false;
  if (!bidAmount && !getItNowFlag) {
    throw new DisplayError("Bid amount cannot be empty");
  }

  const { rows: bidVerificationInfo } = await db.query(verifyBidQuery, [
    itemID,
  ]);

  let { endtime, startingbid, getnowprice, ownerusername, max } =
    bidVerificationInfo[0];

  startingbid = Number(startingbid);
  max = Number(max);

  if (getnowprice !== null) {
    getnowprice = Number(getnowprice);
  }

  if (username === ownerusername) {
    throw new DisplayError("You cannot bid on an item you've listed");
  }

  if (new Date(endtime) < new Date()) {
    throw new DisplayError("The auction has ended");
  }

  if (max !== null && bidAmount < max + 1) {
    throw new DisplayError(
      "Bid must be 1 dollar greater than the current highest bid"
    );
  }

  if (max === null && bidAmount < startingbid) {
    throw new DisplayError(
      "Bid must be at least the starting bid amount of $" + startingbid
    );
  }

  if (!getItNowFlag && getnowprice !== null && bidAmount > getnowprice - 1) {
    throw new DisplayError(
      "The bid amount must be less than the get it now price."
    );
  }

  if (getItNowFlag) {
    if (getnowprice === null) {
      throw new DisplayError("Get it now price is not set for this item.");
    }

    bidAmount = getnowprice;

    await getNow(itemID);
  }

  await db.query(insertBidquery, [username, itemID, bidAmount]);
  return true;
}

const updateAuctionGetNow = `
UPDATE "Auction" SET EndTime = NOW() WHERE ItemID = $1;
`;

async function getNow(itemID) {
  await db.query(updateAuctionGetNow, [itemID]);
  return true;
}

module.exports = { insertBid, getNow };
