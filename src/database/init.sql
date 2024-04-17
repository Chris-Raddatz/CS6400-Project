BEGIN;

DROP TABLE IF EXISTS "Rating";

DROP TABLE IF EXISTS "Bid";

DROP TABLE IF EXISTS "Auction";

DROP TABLE IF EXISTS "Item";

DROP TABLE IF EXISTS "Category";

DROP TABLE IF EXISTS "AdminUser";

DROP TABLE IF EXISTS "User";

DROP TYPE IF EXISTS ConditionEnum;

CREATE TABLE IF NOT EXISTS "User" (
    Username VARCHAR(255) NOT NULL,
    UserPassword VARCHAR(255) NOT NULL,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    PRIMARY KEY (Username)
);

CREATE TABLE IF NOT EXISTS "AdminUser" (
    Username VARCHAR(255) NOT NULL,
    Position VARCHAR(255) NOT NULL,
    PRIMARY KEY (Username),
    FOREIGN KEY (Username) REFERENCES "User" (Username)
);

CREATE TABLE IF NOT EXISTS "Category" (
    CategoryName VARCHAR(255) NOT NULL,
    PRIMARY KEY (CategoryName)
);

CREATE TYPE ConditionEnum AS ENUM ('Poor', 'Fair', 'Good', 'Very Good', 'New');

CREATE TABLE IF NOT EXISTS "Item" (
    ID SERIAL NOT NULL,
    OwnerUsername VARCHAR(255) NOT NULL,
    ItemName VARCHAR(255) NOT NULL,
    ItemDescription VARCHAR(255) NOT NULL,
    IsReturnable BOOLEAN NOT NULL,
    Condition ConditionEnum NOT NULL,
    CategoryName VARCHAR(255) NOT NULL,
    PRIMARY KEY (ID),
    FOREIGN KEY (OwnerUsername) REFERENCES "User" (Username),
    FOREIGN KEY (CategoryName) REFERENCES "Category" (CategoryName)
);

CREATE TABLE IF NOT EXISTS "Rating" (
    ItemID INTEGER NOT NULL,
    RatingTime TIMESTAMP WITH TIME ZONE NOT NULL,
    RatingValue INTEGER NOT NULL,
    Comment VARCHAR(255) NULL,
    PRIMARY KEY (ItemID, RatingTime),
    FOREIGN KEY (ItemID) REFERENCES "Item" (ID)
);

CREATE TABLE IF NOT EXISTS "Auction" (
    ItemID INTEGER NOT NULL,
    StartingBid DECIMAL(65, 2) NOT NULL,
    GetNowPrice DECIMAL(65, 2) NULL,
    MinSalePrice DECIMAL(65, 2) NOT NULL,
    EndTime TIMESTAMP WITH TIME ZONE NOT NULL,
    CancelTime TIMESTAMP WITH TIME ZONE NULL,
    CancelReason VARCHAR(255) NULL,
    PRIMARY KEY (ItemID),
    FOREIGN KEY (ItemID) REFERENCES "Item" (ID)
);

CREATE TABLE IF NOT EXISTS "Bid" (
    UserID VARCHAR(255) NOT NULL,
    ItemID INTEGER NOT NULL,
    Amount DECIMAL(65, 2) NOT NULL,
    BidTime TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (UserID, ItemID, Amount),
    FOREIGN KEY (UserID) REFERENCES "User" (Username),
    FOREIGN KEY (ItemID) REFERENCES "Auction" (ItemID)
);

TRUNCATE TABLE "Bid" CASCADE;

TRUNCATE TABLE "Auction" CASCADE;

TRUNCATE TABLE "Rating" CASCADE;

TRUNCATE TABLE "Item" CASCADE;

TRUNCATE TABLE "AdminUser" CASCADE;

TRUNCATE TABLE "User" CASCADE;

TRUNCATE TABLE "Category" CASCADE;

ALTER SEQUENCE "Item_id_seq" RESTART WITH 1;

-- Insert Users
-- INSERT INTO
--     "User" (Username, UserPassword, FirstName, LastName)
-- VALUES
--     ('john_doe', 'password123', 'John', 'Doe'),
--     ('jane_smith', 'password123', 'Jane', 'Smith'),
--     ('admin_user', 'adminPass', 'Admin', 'User'),
--     ('user1', 'pass1', 'FirstName1', 'LastName1'),
--     ('user2', 'pass2', 'FirstName2', 'LastName2'),
--     ('user3', 'pass3', 'FirstName3', 'LastName3'),
--     ('user4', 'pass4', 'FirstName4', 'LastName4'),
--     ('user5', 'pass5', 'FirstName5', 'LastName5'),
--     (
--         'admin1',
--         'adminPass1',
--         'AdminFirstName1',
--         'AdminLastName1'
--     ),
--     (
--         'admin2',
--         'adminPass2',
--         'AdminFirstName2',
--         'AdminLastName2'
--     );
-- -- Insert Admin Users
-- INSERT INTO
--     "AdminUser" (Username, Position)
-- VALUES
--     ('admin_user', 'Senior Administrator'),
--     ('admin1', 'System Administrator'),
--     ('admin2', 'Database Administrator');
-- -- Insert Categories
-- INSERT INTO
--     "Category" (CategoryName)
-- VALUES
--     ('Electronics'),
--     ('Books'),
--     ('Clothing'),
--     ('Technology'),
--     ('Literature'),
--     ('Fashion'),
--     ('Home Appliances'),
--     ('Sports & Outdoors');
-- -- Insert Items
-- INSERT INTO
--     "Item" (
--         OwnerUsername,
--         ItemName,
--         ItemDescription,
--         IsReturnable,
--         Condition,
--         CategoryName
--     )
-- VALUES
--     (
--         'john_doe',
--         'Laptop',
--         'A high-performance laptop.',
--         TRUE,
--         'New',
--         'Electronics'
--     ),
--     (
--         'jane_smith',
--         'Novel',
--         'A bestselling novel.',
--         FALSE,
--         'Fair',
--         'Books'
--     ),
--     (
--         'user1',
--         'Smartphone',
--         'Latest model smartphone with high specs.',
--         TRUE,
--         'New',
--         'Technology'
--     ),
--     (
--         'user2',
--         'Novel',
--         'A classic piece of literature.',
--         FALSE,
--         'Fair',
--         'Literature'
--     ),
--     (
--         'user3',
--         'Running Shoes',
--         'High-quality running shoes for athletes.',
--         TRUE,
--         'New',
--         'Sports & Outdoors'
--     ),
--     (
--         'user4',
--         'Blender',
--         'Kitchen blender suitable for all your cooking needs.',
--         FALSE,
--         'New',
--         'Home Appliances'
--     ),
--     (
--         'user5',
--         'Winter Jacket',
--         'Warm and comfortable winter jacket.',
--         TRUE,
--         'New',
--         'Fashion'
--     ),
--     (
--         'jane_smith',
--         'Another Novel',
--         'Another bestselling novel.',
--         FALSE,
--         'Poor',
--         'Books'
--     );
-- -- Insert Ratings
-- INSERT INTO
--     "Rating" (
--         ItemID,
--         CommentorUsername,
--         RatingTime,
--         RatingValue,
--         Comment
--     )
-- VALUES
--     (
--         1,
--         'jane_smith',
--         '2024-03-10 10:00:00',
--         5,
--         'Excellent product!'
--     ),
--     (
--         2,
--         'john_doe',
--         '2024-03-10 12:00:00',
--         4,
--         'Great read but slightly worn.'
--     ),
--     (
--         3,
--         'user2',
--         '2024-03-10 09:00:00',
--         5,
--         'Amazing smartphone, highly recommend!'
--     ),
--     (
--         4,
--         'user3',
--         '2024-03-11 08:30:00',
--         4,
--         'Love the novel, a bit worn out though.'
--     ),
--     (
--         5,
--         'user1',
--         '2024-03-12 10:15:00',
--         5,
--         'Excellent quality, fast shipping!'
--     ),
--     (
--         6,
--         'user5',
--         '2024-03-13 11:20:00',
--         3,
--         'Good but expected better performance.'
--     ),
--     (
--         7,
--         'user4',
--         '2024-03-14 12:25:00',
--         5,
--         'Perfect for winter! Very warm.'
--     );
-- -- Insert Auctions
-- INSERT INTO
--     "Auction" (
--         ItemID,
--         StartingBid,
--         GetNowPrice,
--         MinSalePrice,
--         EndTime,
--         CancelTime,
--         CancelReason
--     )
-- VALUES
--     (
--         1,
--         500.00,
--         700.00,
--         510.00,
--         '2024-05-15 10:00:00',
--         NULL,
--         NULL
--     ),
--     (
--         2,
--         10.00,
--         35.00,
--         15.00,
--         '2024-05-20 10:00:00',
--         NULL,
--         NULL
--     ),
--     (
--         3,
--         800.00,
--         1300.00,
--         1160.00,
--         '2024-05-10 20:00:00',
--         NULL,
--         NULL
--     ),
--     (
--         4,
--         20.00,
--         50.00,
--         25.00,
--         '2024-05-11 15:00:00',
--         NULL,
--         NULL
--     ),
--     (
--         5,
--         40.00,
--         80.00,
--         45.00,
--         '2024-03-24 18:00:00',
--         '2024-03-24 18:00:00',
--         'Cancelled for having too much sauce.'
--     ),
--     (
--         6,
--         30.00,
--         NULL,
--         30.00,
--         '2024-05-26 12:00:00',
--         NULL,
--         NULL
--     ),
--     (
--         7,
--         70.00,
--         100.00,
--         80.00,
--         '2024-05-28 14:00:00',
--         NULL,
--         NULL
--     );
-- -- Insert Bids
-- INSERT INTO
--     "Bid" (UserID, ItemID, Amount, BidTime)
-- VALUES
--     ('jane_smith', 1, 550.00, '2024-03-11 11:00:00'),
--     ('john_doe', 2, 12.00, '2024-03-12 09:00:00'),
--     ('user2', 3, 1050.00, '2024-03-09 09:00:00'),
--     ('user3', 4, 25.00, '2024-03-16 10:30:00'),
--     ('user5', 6, 35.00, '2024-03-18 13:00:00'),
--     ('user1', 7, 75.00, '2024-03-19 14:15:00'),
--     ('user3', 3, 1100.00, '2024-03-10 15:30:00'),
--     ('user4', 2, 30.00, '2024-03-21 16:45:00'),
--     ('user2', 7, 80.00, '2024-03-22 17:00:00');
-- Users from Demo Data
INSERT INTO
    "User" (Username, UserPassword, FirstName, LastName)
VALUES
    ('ablack', '1234', 'Alex', 'Black'),
    ('admin1', 'opensesame', 'Riley', 'Fuiss'),
    ('admin2', 'opensesayou', 'Tonnis', 'Kinser'),
    ('apink', '1234', 'Alice', 'Pink'),
    ('jbrian', '1234', 'James', 'O''Brian'),
    ('jgreen', '1234', 'John', 'Green'),
    ('jsmith', '1234', 'John', 'Smith'),
    ('mred', '12345', 'Michael', 'Red'),
    ('o''brian', '1234', 'Jack', 'Brian'),
    ('pbrown', '1234', 'Peter', 'Brown'),
    ('Pink', '1234', 'apink', 'Alice'),
    ('porange', '1234', 'Peter', 'Orange'),
    ('tblue', '1234', 'Tom', 'Blue'),
    ('trichards', '1234', 'Tom', 'Richards'),
    ('user1', 'pass1', 'Danite', 'Kelor'),
    ('user2', 'pass2', 'Dodra', 'Kiney'),
    ('user3', 'pass3', 'Peran', 'Bishop'),
    ('user4', 'pass4', 'Randy', 'Roran'),
    ('user5', 'pass5', 'Ashod', 'Iankel'),
    ('user6', 'pass6', 'Cany', 'Achant');

-- Query for inserting admin users into db
INSERT INTO
    "AdminUser" (Username, Position)
VALUES
    ('admin1', 'Technical Support'),
    ('admin2', 'Chief Techy'),
    ('mred', 'CEO');

-- Inserting category values from Demo Data
INSERT INTO
    "Category" (CategoryName)
VALUES
    ('Books'),
    ('Art'),
    ('Home & Garden'),
    ('Electronics'),
    ('Sporting Goods'),
    ('Other'),
    ('Toys');

-- Values from Items.tsv to be added into Item
INSERT INTO
    "Item" (
        OwnerUsername,
        ItemName,
        ItemDescription,
        IsReturnable,
        CategoryName,
        Condition
    )
VALUES
    (
        'pbrown',
        'good book',
        'good book',
        TRUE,
        'Books',
        'New'
    ),
    (
        'pbrown',
        'good book',
        'the best book',
        FALSE,
        'Books',
        'Good'
    ),
    (
        'mred',
        'painting',
        'good picture',
        TRUE,
        'Art',
        'Very Good'
    ),
    (
        'mred',
        'plant',
        'graet plant',
        FALSE,
        'Home & Garden',
        'Very Good'
    ),
    (
        'mred',
        'computer1',
        'old computer',
        TRUE,
        'Electronics',
        'Fair'
    ),
    (
        'jgreen',
        'skates',
        'for skating',
        FALSE,
        'Sporting Goods',
        'New'
    ),
    (
        'pbrown',
        'plant',
        'another plant',
        TRUE,
        'Other',
        'Good'
    ),
    (
        'tblue',
        'lego toy',
        '"very insteresting toy
this is not very informative description"',
        FALSE,
        'Toys',
        'Very Good'
    ),
    (
        'jgreen',
        'sculpture',
        'expensive',
        FALSE,
        'Art',
        'Very Good'
    ),
    (
        'tblue',
        'good book',
        'one more good book',
        TRUE,
        'Books',
        'New'
    ),
    (
        'tblue',
        'good book',
        'book posted after some time',
        FALSE,
        'Books',
        'Fair'
    ),
    (
        'mred',
        'item with really long name how would it show',
        'this is an item with really long nme to test if it would be acceptable in all creens',
        TRUE,
        'Other',
        'New'
    ),
    (
        'tblue',
        'Garmin GPS',
        'Brand new last model GPS',
        TRUE,
        'Electronics',
        'New'
    ),
    (
        'jgreen',
        'later GPS',
        'GPS listed later',
        FALSE,
        'Electronics',
        'New'
    ),
    (
        'jgreen',
        'still later GPS',
        'still later GPS',
        TRUE,
        'Electronics',
        'New'
    ),
    (
        'jgreen',
        'still still later GPS',
        'still still later GPS',
        TRUE,
        'Electronics',
        'New'
    ),
    (
        'ablack',
        'good book',
        'new book listed',
        TRUE,
        'Books',
        'New'
    ),
    (
        'ablack',
        'plant',
        'great gazebo',
        FALSE,
        'Home & Garden',
        'Good'
    ),
    (
        'tblue',
        'painting',
        'pretty good painting',
        FALSE,
        'Art',
        'New'
    ),
    (
        'tblue',
        'Art Albom',
        'Albom of classic art illustrations',
        FALSE,
        'Art',
        'New'
    ),
    (
        'jgreen',
        'Art Albom',
        'listed by jgreen',
        FALSE,
        'Art',
        'New'
    ),
    (
        'tblue',
        'ite with very long name just to see how it works',
        'item with long name',
        TRUE,
        'Other',
        'New'
    ),
    (
        'pbrown',
        'now i want to make the item name as long as i can and even longer than anyone of the iotems I amde before',
        'long name again',
        FALSE,
        'Other',
        'New'
    ),
    (
        'pbrown',
        'once again item with very long item name and how it will be seen in the tables which i will be creating',
        'again long item name',
        FALSE,
        'Other',
        'New'
    ),
    (
        'jgreen',
        'item to buy',
        'just to have it bought',
        TRUE,
        'Other',
        'New'
    ),
    (
        'mred',
        'furby',
        'old toy',
        FALSE,
        'Toys',
        'Good'
    ),
    (
        'pbrown',
        'Nexus',
        'tablet',
        TRUE,
        'Electronics',
        'New'
    ),
    (
        'pbrown',
        'once again just to buy',
        'just to buy',
        FALSE,
        'Other',
        'New'
    ),
    (
        'pbrown',
        'third one to buy',
        'third to buy',
        FALSE,
        'Other',
        'Poor'
    ),
    (
        'pbrown',
        'fourth to sell immediately',
        'to sell',
        FALSE,
        'Other',
        'Poor'
    ),
    (
        'pbrown',
        'fifth for sale immediate',
        'for sale immediate fifth',
        FALSE,
        'Other',
        'New'
    ),
    (
        'pbrown',
        'sixth to sell immediate',
        'sixth to sell immedaite',
        TRUE,
        'Other',
        'New'
    ),
    (
        'pbrown',
        'eigth to check for asale immediate',
        'eighth to sell',
        TRUE,
        'Other',
        'Poor'
    ),
    (
        'tblue',
        'ninth to sell',
        'ninth to sell',
        TRUE,
        'Art',
        'New'
    ),
    (
        'trichards',
        'detective novel',
        'Interesting spy novel',
        FALSE,
        'Books',
        'New'
    ),
    (
        'ablack',
        'sculpture',
        'ancient sculpture',
        FALSE,
        'Art',
        'Very Good'
    ),
    (
        'jgreen',
        'my item',
        'very simple item',
        TRUE,
        'Other',
        'Poor'
    ),
    (
        'jsmith',
        'good book',
        'Spanish-English',
        FALSE,
        'Books',
        'New'
    ),
    (
        'jsmith',
        'sculpture',
        'not so old sculpture',
        FALSE,
        'Art',
        'Very Good'
    ),
    (
        'ablack',
        'something',
        'strange thing',
        FALSE,
        'Other',
        'Good'
    ),
    (
        'ablack',
        'something',
        'even more strange thing',
        TRUE,
        'Other',
        'Fair'
    ),
    (
        'porange',
        'good book',
        'interesting book',
        TRUE,
        'Books',
        'Very Good'
    ),
    (
        'tblue',
        'sculpture',
        'good sculptutre',
        FALSE,
        'Art',
        'Good'
    ),
    (
        'user1',
        'Garmin GPS',
        'This is a great GPS.',
        FALSE,
        'Electronics',
        'Very Good'
    ),
    (
        'user1',
        'Canon Powershot',
        'Point and shoot!',
        FALSE,
        'Electronics',
        'Good'
    ),
    (
        'user2',
        'Nikon D3',
        'New and in box!',
        FALSE,
        'Electronics',
        'New'
    ),
    (
        'user3',
        'Danish Art Book',
        'Delicious Danish Art',
        TRUE,
        'Art',
        'Very Good'
    ),
    (
        'admin1',
        'SQL in 10 Minutes',
        'Learn SQL really fast!',
        FALSE,
        'Books',
        'Fair'
    ),
    (
        'admin2',
        'SQL in 8 Minutes',
        'Learn SQL even faster!',
        FALSE,
        'Books',
        'Good'
    ),
    (
        'user6',
        'Pull-up Bar',
        'Works on any door frame.',
        TRUE,
        'Sporting Goods',
        'New'
    ),
    (
        'jgreen',
        'painting',
        'round table',
        TRUE,
        'Home & Garden',
        'New'
    ),
    (
        'admin1',
        'good book',
        'very good thing',
        FALSE,
        'Other',
        'Good'
    ),
    (
        'jgreen',
        'thingy',
        'what is thingy?',
        FALSE,
        'Art',
        'New'
    );

INSERT INTO
    "Auction" (
        ItemID,
        StartingBid,
        GetNowPrice,
        MinSalePrice,
        EndTime,
        CancelTime,
        CancelReason
    )
VALUES
    (
        1,
        20.0,
        80.0,
        50.00,
        '2024-02-02 22:48:14',
        NULL,
        NULL
    ),
    (
        2,
        10.0,
        70.0,
        18.63,
        '2024-02-07 22:44:31',
        NULL,
        NULL
    ),
    (
        3,
        100.0,
        300.0,
        200.00,
        '2024-02-03 12:36:32',
        NULL,
        NULL
    ),
    (
        4,
        500.0,
        1000.0,
        538.16,
        '2024-02-06 15:21:29',
        NULL,
        NULL
    ),
    (
        5,
        300.0,
        750.0,
        500.00,
        '2024-02-04 16:32:22',
        '2024-02-03 20:09:19',
        'Item is no longer available.'
    ),
    (
        6,
        250.0,
        450.0,
        350.00,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        7,
        40.0,
        70.0,
        60.00,
        '2024-02-10 20:53:26',
        NULL,
        NULL
    ),
    (
        8,
        30.0,
        75.0,
        50.00,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        9,
        1000.0,
        3000.0,
        1058.53,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        10,
        50.0,
        NULL,
        58.93,
        '2024-02-11 10:59:05',
        NULL,
        'impossible to rate'
    ),
    (
        11,
        25.0,
        75.0,
        55.00,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        12,
        100.0,
        NULL,
        122.68,
        '2024-02-19 13:44:50',
        NULL,
        NULL
    ),
    (
        13,
        200.0,
        NULL,
        350.00,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        14,
        300.0,
        600.0,
        400.00,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        15,
        400.0,
        NULL,
        600.00,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        16,
        500.0,
        NULL,
        501.95,
        '2024-02-22 09:11:06',
        NULL,
        NULL
    ),
    (
        17,
        20.0,
        100.0,
        50.00,
        '2024-02-18 12:43:22',
        NULL,
        NULL
    ),
    (
        18,
        1000.0,
        3000.0,
        2000.00,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        19,
        300.0,
        700.0,
        500.00,
        '2024-02-18 13:33:38',
        NULL,
        NULL
    ),
    (
        20,
        250.0,
        750.0,
        250.81,
        '2024-02-27 16:38:54',
        NULL,
        NULL
    ),
    (
        21,
        100.0,
        NULL,
        200.00,
        '2024-02-27 16:44:17',
        '2024-02-26 07:27:49',
        'Item is no longer available.'
    ),
    (
        22,
        10.0,
        50.0,
        30.00,
        '2024-02-23 17:52:13',
        '2024-02-23 17:11:40',
        'User requested. Wrong minimum price.'
    ),
    (
        23,
        20.0,
        75.0,
        50.00,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        24,
        10.0,
        30.0,
        20.00,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        25,
        15.0,
        35.0,
        25.00,
        '2024-02-23 15:34:01',
        NULL,
        NULL
    ),
    (
        26,
        50.0,
        70.0,
        60.00,
        '2024-02-23 15:46:55',
        NULL,
        NULL
    ),
    (
        27,
        100.0,
        200.0,
        150.00,
        '2024-02-23 15:51:26',
        NULL,
        NULL
    ),
    (
        28,
        5.0,
        15.0,
        10.00,
        '2024-02-23 15:59:57',
        NULL,
        NULL
    ),
    (
        29,
        5.0,
        18.0,
        10.00,
        '2024-02-23 16:04:04',
        NULL,
        NULL
    ),
    (
        30,
        10.0,
        20.0,
        15.00,
        '2024-02-23 16:06:46',
        NULL,
        NULL
    ),
    (
        31,
        4.0,
        15.0,
        10.00,
        '2024-02-23 16:16:24',
        NULL,
        NULL
    ),
    (
        32,
        3.0,
        7.0,
        5.00,
        '2024-02-23 16:22:33',
        NULL,
        NULL
    ),
    (
        33,
        2.0,
        6.0,
        4.00,
        '2024-02-23 16:27:02',
        NULL,
        NULL
    ),
    (
        34,
        1.0,
        5.0,
        3.00,
        '2024-02-23 16:32:06',
        NULL,
        NULL
    ),
    (
        35,
        20.0,
        40.0,
        30.00,
        '2024-03-03 19:41:39',
        NULL,
        NULL
    ),
    (
        36,
        100.0,
        NULL,
        350.00,
        '2024-03-06 19:36:56',
        NULL,
        NULL
    ),
    (
        37,
        1.0,
        10.0,
        5.00,
        '2024-03-04 21:43:55',
        NULL,
        NULL
    ),
    (
        38,
        30.0,
        50.0,
        40.00,
        '2024-04-21 23:59:00',
        NULL,
        NULL
    ),
    (
        39,
        200.0,
        600.0,
        400.00,
        '2024-03-07 13:49:58',
        NULL,
        NULL
    ),
    (
        40,
        10.0,
        30.0,
        15.00,
        '2024-03-07 13:35:02',
        NULL,
        NULL
    ),
    (
        41,
        15.0,
        35.0,
        15.23,
        '2024-03-10 13:36:47',
        NULL,
        NULL
    ),
    (
        42,
        20.0,
        50.0,
        35.00,
        '2024-03-07 19:11:59',
        NULL,
        NULL
    ),
    (
        43,
        300.0,
        750.0,
        500.00,
        '2024-03-10 19:13:18',
        '2024-03-09 05:44:37',
        'User requested. Wrong minimum price.'
    ),
    (
        44,
        50.0,
        99.0,
        70.00,
        '2024-02-28 12:22:00',
        NULL,
        NULL
    ),
    (
        45,
        40.0,
        80.0,
        60.00,
        '2024-02-29 13:55:00',
        NULL,
        NULL
    ),
    (
        46,
        1500.0,
        2000.0,
        1589.35,
        '2024-03-04 09:19:00',
        NULL,
        NULL
    ),
    (
        47,
        10.0,
        15.0,
        10.00,
        '2024-03-04 15:33:00',
        '2024-03-02 11:41:18',
        'Buyer retracted their bid.'
    ),
    (
        48,
        5.0,
        12.0,
        10.00,
        '2024-03-04 16:48:00',
        NULL,
        NULL
    ),
    (
        49,
        5.0,
        10.0,
        8.00,
        '2024-03-07 10:01:00',
        NULL,
        NULL
    ),
    (
        50,
        20.0,
        40.0,
        25.00,
        '2024-03-08 22:09:00',
        NULL,
        NULL
    ),
    (
        51,
        300.0,
        750.0,
        500.00,
        '2024-03-11 18:17:33',
        NULL,
        NULL
    ),
    (
        52,
        35.0,
        75.0,
        36.21,
        '2024-03-16 18:18:46',
        NULL,
        NULL
    ),
    (
        53,
        20.0,
        50.0,
        30.00,
        '2024-03-14 18:28:45',
        '2024-03-14 07:05:17',
        'User requested. Wrong minimum price.'
    );

INSERT INTO
    "Bid" (UserID, ItemID, Amount, BidTime)
VALUES
    ('tblue', 1, 80.00, '2024-02-02 22:48:14'),
    ('mred', 2, 10.00, '2024-02-02 22:46:02'),
    ('user1', 2, 13.00, '2024-02-03 13:07:10'),
    ('admin2', 2, 15.00, '2024-02-03 13:07:36'),
    ('tblue', 2, 18.00, '2024-02-03 13:09:19'),
    ('user2', 2, 20.00, '2024-02-03 13:09:49'),
    ('tblue', 2, 22.00, '2024-02-03 13:10:11'),
    ('jsmith', 2, 24.00, '2024-02-03 13:10:32'),
    ('jgreen', 2, 30.00, '2024-02-03 16:35:57'),
    ('tblue', 3, 100.00, '2024-02-03 12:34:27'),
    ('jgreen', 3, 105.00, '2024-02-03 12:35:01'),
    ('pbrown', 3, 300.00, '2024-02-03 12:36:32'),
    ('jgreen', 4, 550.00, '2024-02-03 16:35:15'),
    ('jgreen', 4, 600.00, '2024-02-03 16:36:47'),
    ('pbrown', 4, 603.78, '2024-02-04 12:19:06'),
    ('pbrown', 4, 606.00, '2024-02-04 12:19:27'),
    ('user4', 5, 300.00, '2024-02-03 16:33:14'),
    ('mred', 10, 50.00, '2024-02-10 11:00:05'),
    ('mred', 10, 53.00, '2024-02-10 11:01:18'),
    ('jgreen', 10, 55.00, '2024-02-10 11:01:10'),
    ('mred', 10, 57.00, '2024-02-10 11:03:04'),
    ('mred', 10, 58.00, '2024-02-10 11:02:33'),
    ('mred', 10, 60.00, '2024-02-10 11:27:01'),
    ('mred', 10, 61.00, '2024-02-10 11:28:15'),
    ('mred', 10, 63.00, '2024-02-10 11:31:48'),
    ('mred', 10, 67.00, '2024-02-10 11:33:21'),
    ('pbrown', 10, 70.00, '2024-02-10 11:33:49'),
    ('Pink', 12, 101.00, '2024-02-14 13:48:54'),
    ('admin1', 12, 105.00, '2024-02-14 13:50:13'),
    ('pbrown', 12, 120.00, '2024-02-14 20:58:37'),
    ('pbrown', 12, 125.00, '2024-02-14 21:00:58'),
    ('ablack', 16, 508.00, '2024-02-18 11:39:10'),
    ('mred', 16, 515.00, '2024-02-19 15:10:57'),
    ('tblue', 16, 516.00, '2024-02-19 15:11:15'),
    ('mred', 16, 517.00, '2024-02-19 15:11:35'),
    ('jsmith', 17, 20.00, '2024-02-18 12:42:47'),
    ('trichards', 17, 25.00, '2024-02-18 12:43:00'),
    ('apink', 17, 100.00, '2024-02-18 12:43:22'),
    ('jsmith', 19, 300.00, '2024-02-18 13:31:53'),
    ('pbrown', 19, 305.00, '2024-02-18 13:32:05'),
    ('jgreen', 19, 310.00, '2024-02-18 13:32:59'),
    ('jbrian', 19, 700.00, '2024-02-18 13:33:38'),
    ('apink', 20, 255.00, '2024-02-22 16:39:23'),
    ('user6', 25, 35.00, '2024-02-23 15:34:01'),
    ('jbrian', 26, 52.00, '2024-02-23 15:43:40'),
    ('user1', 26, 55.00, '2024-02-23 15:44:03'),
    ('pbrown', 26, 70.00, '2024-02-23 15:46:55'),
    ('user5', 27, 200.00, '2024-02-23 15:51:26'),
    ('trichards', 28, 15.00, '2024-02-23 15:59:57'),
    ('apink', 29, 18.00, '2024-02-23 16:04:04'),
    ('user3', 30, 20.00, '2024-02-23 16:06:46'),
    ('user3', 31, 15.00, '2024-02-23 16:16:24'),
    ('mred', 32, 7.00, '2024-02-23 16:22:33'),
    ('o''brian', 33, 6.00, '2024-02-23 16:27:02'),
    ('admin2', 34, 5.00, '2024-02-23 16:32:06'),
    ('pbrown', 35, 22.00, '2024-03-03 19:35:20'),
    ('mred', 35, 25.00, '2024-03-03 19:38:29'),
    ('pbrown', 35, 28.00, '2024-03-03 19:39:06'),
    ('mred', 35, 30.00, '2024-03-03 19:39:34'),
    ('admin2', 35, 33.00, '2024-03-03 19:40:23'),
    ('pbrown', 35, 35.00, '2024-03-03 19:40:47'),
    ('pbrown', 35, 40.00, '2024-03-03 19:41:39'),
    ('mred', 36, 120.00, '2024-03-03 19:38:02'),
    ('pbrown', 36, 122.00, '2024-03-03 21:00:57'),
    ('pbrown', 36, 124.00, '2024-03-03 21:06:42'),
    ('mred', 36, 126.00, '2024-03-03 21:42:58'),
    ('pbrown', 39, 250.00, '2024-03-06 13:14:31'),
    ('mred', 39, 253.00, '2024-03-06 13:15:14'),
    ('jgreen', 39, 600.00, '2024-03-07 13:49:58'),
    ('tblue', 40, 10.00, '2024-03-07 13:34:11'),
    ('jgreen', 40, 11.00, '2024-03-07 13:34:28'),
    ('tblue', 40, 30.00, '2024-03-07 13:35:02'),
    ('pbrown', 41, 16.00, '2024-03-08 11:34:16'),
    ('tblue', 42, 20.00, '2024-03-07 19:09:36'),
    ('pbrown', 42, 21.00, '2024-03-07 19:11:03'),
    ('tblue', 42, 25.00, '2024-03-07 19:11:28'),
    ('tblue', 42, 50.00, '2024-03-07 19:11:59'),
    ('user4', 44, 50.00, '2024-02-27 14:53:00'),
    ('user5', 44, 55.00, '2024-02-27 16:45:00'),
    ('user4', 44, 75.00, '2024-02-27 19:28:00'),
    ('user5', 44, 85.00, '2024-02-28 10:00:00'),
    ('user6', 45, 80.00, '2024-02-29 13:55:00'),
    ('user1', 46, 1500.00, '2024-03-03 08:37:00'),
    ('user3', 46, 1501.00, '2024-03-03 09:15:00'),
    ('user1', 46, 1795.00, '2024-03-03 12:27:00'),
    ('user4', 50, 20.00, '2024-03-07 20:20:00'),
    ('user2', 50, 25.00, '2024-03-08 21:15:00'),
    ('user5', 51, 745.00, '2024-03-11 10:55:39'),
    ('admin1', 51, 750.00, '2024-03-11 18:17:33'),
    ('jgreen', 52, 35.00, '2024-03-11 18:24:28'),
    ('jgreen', 52, 37.00, '2024-03-11 18:24:51');

INSERT INTO
    "Rating" (
        ItemID,
        RatingTime,
        RatingValue,
        Comment
    )
VALUES
    (
        2,
        '2024-02-03 16:36:25',
        4.0,
        'very good book'
    ),
    (
        3,
        '2024-02-03 13:52:21',
        4.0,
        'maybe quite useful'
    ),
    (
        4,
        '2024-02-05 20:54:26',
        2.0,
        'this is review of another plant by pbrown'
    ),
    (
        10,
        '2024-02-11 05:16:01',
        0.0,
        'impossible to rate'
    ),
    (
        12,
        '2024-02-14 16:15:38',
        0.0,
        'and i will chamge this one'
    ),
    (16, '2024-02-19 15:10:07', 5.0, 'dfsd'),
    (
        17,
        '2024-02-20 12:31:05',
        1.0,
        'impossible to rate'
    ),
    (
        19,
        '2024-02-19 04:49:15',
        1.0,
        'never saw anything like that'
    ),
    (
        20,
        '2024-02-22 17:05:46',
        2.0,
        'no so great albom'
    ),
    (
        25,
        '2024-02-24 15:20:51',
        2.0,
        'one more useless comment'
    ),
    (
        27,
        '2024-02-26 02:52:59',
        0.0,
        'how would I rate it'
    ),
    (
        30,
        '2024-02-24 12:51:26',
        3.0,
        'never saw anything like that'
    ),
    (
        32,
        '2024-02-23 20:10:52',
        2.0,
        'let me think what I can write'
    ),
    (
        34,
        '2024-02-26 07:55:45',
        4.0,
        'let me think what I can write'
    ),
    (
        35,
        '2024-03-06 01:50:02',
        4.0,
        'something to look at'
    ),
    (
        39,
        '2024-03-06 13:14:02',
        0.0,
        'very bad sculpture'
    ),
    (
        40,
        '2024-03-09 16:11:46',
        1.0,
        'never saw anything like that'
    ),
    (
        41,
        '2024-03-07 13:37:42',
        0.0,
        'not so good something'
    ),
    (
        42,
        '2024-03-10 03:14:48',
        1.0,
        'very nice item'
    ),
    (
        44,
        '2024-02-27 17:00:00',
        5.0,
        'Great GPS!'
    ),
    (
        45,
        '2024-03-01 19:12:02',
        1.0,
        'never saw anything like that'
    ),
    (
        46,
        '2024-03-04 15:01:35',
        4.0,
        'never saw anything like that'
    ),
    (50, '2024-03-10 06:58:41', 5.0, 'so-so'),
    (
        51,
        '2024-03-11 18:16:52',
        3.0,
        'etetete'
    ),
    (
        52,
        '2024-03-11 18:26:36',
        4.0,
        'really bvery good'
    );

-- INSERT INTO "Item" (itemID, username_listed, name, description, start_price, condition, get_it_now_price, min_price, returns_accepted, scheduled_auction_end, category_name, cancellation_reason, cancellation_timestamp, rating_comment, num_stars, rate_timestamp)
-- VALUES
-- (1, 'pbrown', 'good book', 'good book', 20.00, 'New', 80.00, 50.00, 1, '2024-02-02 22:48:14', 'Books', NULL, NULL, NULL, NULL, NULL),
-- (2, 'pbrown', 'good book', 'the best book', 10.00, 'Good', 70.00, 18.63, 0, '2024-02-07 22:44:31', 'Books', NULL, NULL, 'very good book', 4, '2024-02-03 16:36:25'),
-- (3, 'mred', 'painting', 'good picture', 100.00, 'Very Good', 300.00, 200.00, 1, '2024-02-03 12:36:32', 'Art', NULL, NULL, 'maybe quite useful', 4, '2024-02-03 13:52:21'),
-- (4, 'mred', 'plant', 'graet plant', 500.00, 'Very Good', 1000.00, 538.16, 0, '2024-02-06 15:21:29', 'Home & Garden', NULL, NULL, 'this is review of another plant by pbrown', 2, '2024-02-05 20:54:26'),
-- (5, 'mred', 'computer1', 'old computer', 300.00, 'Fair', 750.00, 500.00, 1, '2024-02-04 16:32:22', 'Electronics', 'Item is no longer available.', '2024-02-03 20:09:19', NULL, NULL, NULL),
-- (6, 'jgreen', 'skates', 'for skating', 250.00, 'New', 450.00, 350.00, 0, '2024-04-21 23:59:00', 'Sporting Goods', NULL, NULL, NULL, NULL),
-- (7, 'pbrown', 'plant', 'another plant', 40.00, 'Good', 70.00, 60.00, 1, '2024-02-10 20:53:26', 'Other', NULL, NULL, NULL, NULL),
-- (8, 'tblue', 'lego toy', 'very insteresting toy
-- this is not very informative description', 30.00, 'Very Good', 75.00, 50.00, 0, '2024-04-21 23:59:00', 'Toys', NULL, NULL, NULL, NULL),
-- (9, 'jgreen', 'sculpture', 'expensive', 1000.00, 'Very Good', 3000.00, 1058.53, 0, '2024-04-21 23:59:00', 'Art', NULL, NULL, NULL, NULL),
-- (10, 'tblue', 'good book', 'one more good book', 50.00, 'New', NULL, 58.93, 1, '2024-02-11 10:59:05', 'Books', NULL, NULL, 'impossible to rate', 0, '2024-02-11 05:16:01'),
-- (11, 'tblue', 'good book', 'book posted after some time', 25.00, 'Fair', 75.00, 55.00, 0, '2024-04-21 23:59:00', 'Books', NULL, NULL, NULL, NULL),
-- (12, 'mred', 'item with really long name how would it show', 'this is an item with really long nme to test if it would be acceptable in all creens', 100.00, 'New', NULL, 122.68, 1, '2024-02-19 13:44:50', 'Other', NULL, NULL, 'and i will chamge this one ', 0, '2024-02-14 16:15:38'),
-- (13, 'tblue', 'Garmin GPS', 'Brand new last model GPS', 200.00, 'New', NULL, 350.00, 1, '2024-04-21 23:59:00', 'Electronics', NULL, NULL, NULL, NULL),
-- (14, 'jgreen', 'later GPS', 'GPS listed later', 300.00, 'New', 600.00, 400.00, 0, '2024-04-21 23:59:00', 'Electronics', NULL, NULL, NULL, NULL),
-- (15, 'jgreen', 'still later GPS', 'still later GPS', 400.00, 'New', NULL, 600.00, 1, '2024-04-21 23:59:00', 'Electronics', NULL, NULL, NULL, NULL),
-- (16, 'jgreen', 'still still later GPS', 'still still later GPS', 500.00, 'New', NULL, 501.95, 1, '2024-02-22 09:11:06', 'Electronics', 'dfsd', 5, '2024-02-19 15:10:07'),
-- (17, 'ablack', 'good book', 'new book listed ', 20.00, 'New', 100.00, 50.00, 1, '2024-02-18 12:43:22', 'Books', NULL, NULL, 'impossible to rate', 1, '2024-02-20 12:31:05'),
-- (18, 'ablack', 'plant', 'great gazebo', 1000.00, 'Good', 3000.00, 2000.00, 0, '2024-04-21 23:59:00', 'Home & Garden', NULL, NULL, NULL, NULL),
-- (19, 'tblue', 'painting', 'pretty good painting', 300.00, 'New', 700.00, 500.00, 0, '2024-02-18 13:33:38', 'Art', NULL, NULL, 'never saw anything like that', 1, '2024-02-19 04:49:15'),
-- (20, 'tblue', 'Art Albom', 'Albom of classic art illustrations', 250.00, 'New', 750.00, 250.81, 0, '2024-02-27 16:38:54', 'Art', NULL, NULL, 'no so great albom', 2, '2024-02-22 17:05:46'),
-- (21, 'jgreen', 'Art Albom', 'listed by jgreen', 100.00, 'New', NULL, 200.00, 0, '2024-02-27 16:44:17', 'Art', 'Item is no longer available.', '2024-02-26 07:27:49', NULL, NULL, NULL),
-- (22, 'tblue', 'ite with very long name just to see how it works', 'item with long name', 10.00, 'New', 50.00, 30.00, 1, '2024-02-23 17:52:13', 'Other', 'User requested. Wrong minimum price.', '2024-02-23 17:11:40', NULL, NULL, NULL),
-- (23, 'pbrown', 'now i want to make the item name as long as i can and even longer than anyone of the iotems I amde before', 'long name again', 20.00, 'New', 75.00, 50.00, 0, '2024-04-21 23:59:00', 'Other', NULL, NULL, 'never saw anything like that', 1, '2024-03-09 16:11:46'),
-- (24, 'pbrown', 'once again item with very long item name and how it will be seen in the tables which i will be creating', 'again long item name', 10.00, 'New', 30.00, 20.00, 0, '2024-04-21 23:59:00', 'Other', NULL, NULL, NULL, NULL),
-- (25, 'jgreen', 'item to buy', 'just to have it bought', 15.00, 'New', 35.00, 25.00, 1, '2024-02-23 15:34:01', 'Other', NULL, NULL, 'one more useless comment', 2, '2024-02-24 15:20:51'),
-- (26, 'mred', 'furby', 'old toy', 50.00, 'Good', 70.00, 60.00, 0, '2024-02-23 15:46:55', 'Toys', NULL, NULL, NULL, NULL),
-- (27, 'pbrown', 'Nexus', 'tablet', 100.00, 'New', 200.00, 150.00, 1, '2024-02-23 15:51:26', 'Electronics', NULL, NULL, 'how would I rate it', 0, '2024-02-26 02:52:59'),
-- (28, 'pbrown', 'once again just to buy', 'just to buy', 5.00, 'New', 15.00, 10.00, 0, '2024-02-23 15:59:57', 'Other', NULL, NULL, NULL, NULL),
-- (29, 'pbrown', 'third one to buy', 'third to buy', 5.00, 'Poor', 18.00, 10.00, 0, '2024-02-23 16:04:04', 'Other', NULL, NULL, NULL, NULL),
-- (30, 'pbrown', 'fourth to sell immediately', 'to sell', 10.00, 'Poor', 20.00, 15.00, 0, '2024-02-23 16:06:46', 'Other', NULL, NULL, 'never saw anything like that', 3, '2024-02-24 12:51:26'),
-- (31, 'pbrown', 'fifth for sale immediate', 'for sale immediate fifth', 4.00, 'New', 15.00, 10.00, 0, '2024-02-23 16:16:24', 'Other', NULL, NULL, NULL, NULL),
-- (32, 'pbrown', 'sixth to sell immediate', 'sixth to sell immedaite', 3.00, 'New', 7.00, 5.00, 1, '2024-02-23 16:22:33', 'Other', NULL, NULL, 'let me think what I can write', 2, '2024-02-23 20:10:52'),
-- (33, 'pbrown', 'eigth to check for asale immediate', 'eighth to sell', 2.00, 'Poor', 6.00, 4.00, 1, '2024-02-23 16:27:02', 'Other', NULL, NULL, NULL, NULL),
-- (34, 'tblue', 'ninth to sell', 'ninth to sell', 1.00, 'New', 5.00, 3.00, 1, '2024-02-23 16:32:06', 'Art', NULL, NULL, 'let me think what I can write', 4, '2024-02-26 07:55:45'),
-- (35, 'trichards', 'detective novel', 'Interesting spy novel', 20.00, 'New', 40.00, 30.00, 0, '2024-03-03 19:41:39', 'Books', NULL, NULL, 'something to look at', 4, '2024-03-06 01:50:02'),
-- (36, 'ablack', 'sculpture', 'ancient sculpture', 100.00, 'Very Good', NULL, 350.00, 0, '2024-03-06 19:36:56', 'Art', NULL, NULL, NULL, NULL),
-- (37, 'jgreen', 'my item', 'very simple item', 1.00, 'Poor', 10.00, 5.00, 1, '2024-03-04 21:43:55', 'Other', NULL, NULL, NULL, NULL),
-- (38, 'jsmith', 'good book', 'Spanish-English', 30.00, 'New', 50.00, 40.00, 0, '2024-04-21 23:59:00', 'Books', NULL, NULL, NULL, NULL),
-- (39, 'jsmith', 'sculpture', 'not so old sculpture', 200.00, 'Very Good', 600.00, 400.00, 0, '2024-03-07 13:49:58', 'Art', NULL, NULL, 'very bad sculpture', 0, '2024-03-06 13:14:02'),
-- (40, 'ablack', 'something', 'strange thing', 10.00, 'Good', 30.00, 15.00, 0, '2024-03-07 13:35:02', 'Other', NULL, NULL, 'never saw anything like that', 1, '2024-03-09 16:11:46'),
-- (41, 'ablack', 'something', 'even more strange thing', 15.00, 'Fair', 35.00, 15.23, 1, '2024-03-10 13:36:47', 'Other', NULL, NULL, 'not so good something', 0, '2024-03-07 13:37:42'),
-- (42, 'porange', 'good book', 'interesting book', 20.00, 'Very Good', 50.00, 35.00, 1, '2024-03-07 19:11:59', 'Books', NULL, NULL, 'very nice item', 1, '2024-03-10 03:14:48'),
-- (43, 'tblue', 'sculpture', 'good sculptutre', 300.00, 'Good', 750.00, 500.00, 0, '2024-03-10 19:13:18', 'Art', 'User requested. Wrong minimum price.', '2024-03-09 05:44:37', NULL, NULL, NULL),
-- (44, 'user1', 'Garmin GPS', 'This is a great GPS.', 50.00, 'Very Good', 99.00, 70.00, 0, '2024-02-28 12:22:00', 'Electronics', NULL, NULL, 'Great GPS!', 5, '2024-02-27 17:00:00'),
-- (45, 'user1', 'Canon Powershot', 'Point and shoot!', 40.00, 'Good', 80.00, 60.00, 0, '2024-02-29 13:55:00', 'Electronics', NULL, NULL, 'never saw anything like that', 1, '2024-03-01 19:12:02'),
-- (46, 'user2', 'Nikon D3', 'New and in box!', 1500.00, 'New', 2000.00, 1589.35, 0, '2024-03-04 09:19:00', 'Electronics', NULL, NULL, 'never saw anything like that', 4, '2024-03-04 15:01:35'),
-- (47, 'user3', 'Danish Art Book', 'Delicious Danish Art', 10.00, 'Very Good', 15.00, 10.00, 1, '2024-03-04 15:33:00', 'Art', NULL, '2024-03-02 11:41:18', NULL, NULL, NULL),
-- (48, 'admin1', 'SQL in 10 Minutes', 'Learn SQL really fast!', 5.00, 'Fair', 12.00, 10.00, 0, '2024-03-04 16:48:00', 'Books', NULL, NULL, NULL, NULL),
-- (49, 'admin2', 'SQL in 8 Minutes', 'Learn SQL even faster!', 5.00, 'Good', 10.00, 8.00, 0, '2024-03-07 10:01:00', 'Books', NULL, NULL, NULL, NULL),
-- (50, 'user6', 'Pull-up Bar', 'Works on any door frame.', 20.00, 'New', 40.00, 25.00, 1, '2024-03-08 22:09:00', 'Sporting Goods', NULL, NULL, 'so-so', 5, '2024-03-10 06:58:41'),
-- (51, 'jgreen', 'painting', 'round table', 300.00, 'New', 750.00, 500.00, 1, '2024-03-11 18:17:33', 'Home & Garden', NULL, NULL, 'etetete', 3, '2024-03-11 18:16:52'),
-- (52, 'admin1', 'good book', 'very good thing', 35.00, 'Good', 75.00, 36.21, 0, '2024-03-16 18:18:46', 'Other', NULL, NULL, 'really bvery good', 4, '2024-03-11 18:26:36'),
-- (53, 'jgreen', 'thingy', 'what is thingy?', 20.00, 'New', 50.00, 30.00, 0, '2024-03-14 18:28:45', 'Art', 'User can no longer be reached.', '2024-03-14 07:05:17', NULL, NULL, NULL);
-- INSERT INTO "Item" (itemID, username_listed, name, description, start_price, condition, get_it_now_price, min_price, returns_accepted, scheduled_auction_end, category_name, cancellation_reason, cancellation_timestamp, rating_comment, num_stars, rate_timestamp)
-- VALUES
-- (2, 'pbrown', 'good book', 'the best book', 10.00, 'Good', 70.00, 18.63, 0, '2024-02-07 22:44:31', 'Books', NULL, NULL, 'very good book', 4, '2024-02-03 16:36:25'),
-- (3, 'mred', 'painting', 'good picture', 100.00, 'Very Good', 300.00, 200.00, 1, '2024-02-03 12:36:32', 'Art', NULL, NULL, 'maybe quite useful', 4, '2024-02-03 13:52:21'),
-- (4, 'mred', 'plant', 'graet plant', 500.00, 'Very Good', 1000.00, 538.16, 0, '2024-02-06 15:21:29', 'Home & Garden', NULL, NULL, 'this is review of another plant by pbrown', 2, '2024-02-05 20:54:26'),
-- (16, 'jgreen', 'still still later GPS', 'still still later GPS', 500.00, 'New', NULL, 501.95, 1, '2024-02-22 09:11:06', 'Electronics', 'dfsd', 5, '2024-02-19 15:10:07'),
-- (17, 'ablack', 'good book', 'new book listed ', 20.00, 'New', 100.00, 50.00, 1, '2024-02-18 12:43:22', 'Books', NULL, NULL, 'impossible to rate', 1, '2024-02-20 12:31:05'),
-- (19, 'tblue', 'painting', 'pretty good painting', 300.00, 'New', 700.00, 500.00, 0, '2024-02-18 13:33:38', 'Art', NULL, NULL, 'never saw anything like that', 1, '2024-02-19 04:49:15'),
-- (22, 'tblue', 'ite with very long name just to see how it works', 'item with long name', 10.00, 'New', 50.00, 30.00, 1, '2024-02-23 17:52:13', 'Other', 'User requested. Wrong minimum price.', '2024-02-23 17:11:40', NULL, NULL, NULL),
-- (23, 'pbrown', 'now i want to make the item name as long as i can and even longer than anyone of the iotems I amde before', 'long name again', 20.00, 'New', 75.00, 50.00, 0, '2024-04-21 23:59:00', 'Other', NULL, NULL, 'never saw anything like that', 1, '2024-03-09 16:11:46'),
-- (25, 'jgreen', 'item to buy', 'just to have it bought', 15.00, 'New', 35.00, 25.00, 1, '2024-02-23 15:34:01', 'Other', NULL, NULL, 'one more useless comment', 2, '2024-02-24 15:20:51'),
-- (44, 'user1', 'Garmin GPS', 'This is a great GPS.', 50.00, 'Very Good', 99.00, 70.00, 0, '2024-02-28 12:22:00', 'Electronics', NULL, NULL, 'Great GPS!', 5, '2024-02-27 17:00:00'),
-- (45, 'user1', 'Canon Powershot', 'Point and shoot!', 40.00, 'Good', 80.00, 60.00, 0, '2024-02-29 13:55:00', 'Electronics', NULL, NULL, 'never saw anything like that', 1, '2024-03-01 19:12:02'),
-- (46, 'user2', 'Nikon D3', 'New and in box!', 1500.00, 'New', 2000.00, 1589.35, 0, '2024-03-04 09:19:00', 'Electronics', NULL, NULL, 'never saw anything like that', 4, '2024-03-04 15:01:35'),
-- (47, 'user3', 'Danish Art Book', 'Delicious Danish Art', 10.00, 'Very Good', 15.00, 10.00, 1, '2024-03-04 15:33:00', 'Art', NULL, '2024-03-02 11:41:18', NULL, NULL, NULL),
-- (50, 'user6', 'Pull-up Bar', 'Works on any door frame.', 20.00, 'New', 40.00, 25.00, 1, '2024-03-08 22:09:00', 'Sporting Goods', NULL, NULL, 'so-so', 5, '2024-03-10 06:58:41'),
-- (52, 'admin1', 'good book', 'very good thing', 35.00, 'Good', 75.00, 36.21, 0, '2024-03-16 18:18:46', 'Other', NULL, NULL, 'really bvery good', 4, '2024-03-11 18:26:36');
COMMIT;