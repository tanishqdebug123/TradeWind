use project;

-- 1 Find users who have made at least one transaction with a stock that has the highest market capitalization
SELECT DISTINCT U.UserID, U.Name
FROM User U
JOIN Transaction T ON U.UserID = T.UserID
WHERE T.StockID IN (
    SELECT StockID FROM Stock WHERE Market_Cap = (SELECT MAX(Market_Cap) FROM Stock)
);

-- 2 Display stocks along with the number of transactions they have
SELECT S.StockID, S.Stock_Name, COUNT(T.TransactionID) AS TransactionCount
FROM Stock S
LEFT JOIN Transaction T ON S.StockID = T.StockID
GROUP BY S.StockID, S.Stock_Name
ORDER BY TransactionCount DESC;

-- 3 Retrieve all stocks whose current price is greater than the average closing price of all stocks
SELECT StockID, Stock_Name, Current_Price
FROM Stock
WHERE Current_Price > (
    SELECT AVG(close_price) FROM Stock_History
);

 -- 4 Find the user who owns the highest number of shares of any single stock
 SELECT UserID, Name 
FROM User 
WHERE UserID = (
    SELECT UserID 
    FROM Portfolio 
    WHERE Quantity = (SELECT MAX(Quantity) FROM Portfolio)
    LIMIT 1
);

-- 5. Find the stock with the highest closing price recorded in the Stock_History table
SELECT StockID, Stock_Name 
FROM Stock 
WHERE StockID = (
    SELECT stock_id 
    FROM Stock_History 
    WHERE close_price = (SELECT MAX(close_price) FROM Stock_History)
);

-- 6 Find transactions where the price is higher than the average transaction price of the same stock
SELECT TransactionID, UserID, StockID, Price
FROM Transaction T1
WHERE T1.Status = 'EXECUTED'
AND Price >= (
    SELECT AVG(Price)
    FROM Transaction T2
    WHERE T2.StockID = T1.StockID
    AND T2.Status = 'EXECUTED'
);

-- 7. Find stocks whose price has increased the most over 1 day
SELECT S.StockID, S.Stock_Name, 
       (MAX(H.close_price) - MIN(H.open_price)) AS PriceIncrease
FROM Stock S
JOIN Stock_History H ON S.StockID = H.stock_id
GROUP BY S.StockID, S.Stock_Name
ORDER BY PriceIncrease DESC
LIMIT 5;

-- 8. Find users who have bought stocks but never sold any
SELECT  U.UserID, U.Name
FROM User U
WHERE U.UserID IN (
    SELECT T.UserID FROM Transaction T WHERE T.Buy_Sell = 'Buy'
)
AND U.UserID NOT IN (
    SELECT T.UserID FROM Transaction T WHERE T.Buy_Sell = 'Sell'
);

-- 9. Find the total portfolio value of each user, including only stocks that have been traded at least 2 times
SELECT U.UserID, U.Name, 
       SUM(P.Quantity * S.Current_Price) AS PortfolioValue
FROM User U
JOIN Portfolio P ON U.UserID = P.UserID
JOIN Stock S ON P.StockID = S.StockID
WHERE P.StockID IN (
    SELECT StockID FROM Transaction GROUP BY StockID HAVING COUNT(*) >= 2
)
GROUP BY U.UserID, U.Name
ORDER BY PortfolioValue DESC;

-- 10. Retrieve top 5 users with the highest returns (total spent - total received)
SELECT t.UserID, u.Name, 
       SUM(CASE 
               WHEN t.Buy_Sell = 'Buy' THEN -t.Price * t.Quantity 
               ELSE t.Price * t.Quantity 
           END) AS Net_Investment
FROM Transaction t
JOIN User u ON t.UserID = u.UserID
WHERE t.Status = 'EXECUTED'
GROUP BY t.UserID, u.Name
ORDER BY Net_Investment DESC
LIMIT 5;

-- 11 Find users who have traded at least 2 different stocks
SELECT T.UserID, U.Name, COUNT(DISTINCT T.StockID) AS UniqueStocks_Traded
FROM Transaction T
JOIN User U ON T.UserID = U.UserID
WHERE T.Status = 'EXECUTED'
GROUP BY T.UserID, U.Name
HAVING COUNT(DISTINCT T.StockID) >= 2
ORDER BY UniqueStocks_Traded DESC;

-- 12. View the portfolio of a particular user
-- Use with cursor.execute(query, (user_id,))
SELECT p.UserID, u.Name, s.Symbol, s.Stock_Name, p.Quantity, s.Current_Price,
       (p.Quantity * s.Current_Price) AS Current_Value
FROM Portfolio p
JOIN User u ON p.UserID = u.UserID
JOIN Stock s ON p.StockID = s.StockID
WHERE p.UserID = %s;

-- 13. View all transactions of a particular user
-- Use with cursor.execute(query, (user_id,))
SELECT t.*, s.Symbol, u.Name
FROM Transaction t
JOIN Stock s ON t.StockID = s.StockID
JOIN User u ON t.UserID = u.UserID
WHERE t.UserID = %s
ORDER BY t.Date_Time DESC;


-- 14. View all transactions for a specific stock
-- Use with cursor.execute(query, (stock_id,))
SELECT t.*, u.Name
FROM Transaction t
JOIN User u ON t.UserID = u.UserID
WHERE t.StockID = %s
ORDER BY t.Date_Time DESC;


-- 15. View all users who currently hold a specific stock (with quantity)
-- Use with cursor.execute(query, (stock_id,))
SELECT p.UserID, u.Name, s.Symbol, p.Quantity
FROM Portfolio p
JOIN User u ON p.UserID = u.UserID
JOIN Stock s ON p.StockID = s.StockID
WHERE p.StockID = %s
ORDER BY p.Quantity DESC;
