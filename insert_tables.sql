use project;

DELIMITER $$

DROP PROCEDURE IF EXISTS ProcessTransactions$$

CREATE PROCEDURE ProcessTransactions()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_TransactionID INT;
    DECLARE v_UserID INT;
    DECLARE v_StockID INT;
    DECLARE v_Quantity INT;
    DECLARE v_Price DECIMAL(10,2);
    DECLARE v_BuySell ENUM('Buy', 'Sell');
    DECLARE v_PortfolioID INT;
    DECLARE v_Balance DECIMAL(10,2);
    DECLARE v_OwnedShares INT DEFAULT 0;
    DECLARE v_TotalCost BIGINT;

    -- Cursor for PENDING transactions
    DECLARE txn_cursor CURSOR FOR
        SELECT TransactionID, UserID, StockID, PortfolioID, Quantity, Price, Buy_Sell
        FROM Transaction
        WHERE Status = 'PENDING';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN txn_cursor;

    txn_loop: LOOP
        FETCH txn_cursor INTO v_TransactionID, v_UserID, v_StockID, v_PortfolioID, v_Quantity, v_Price, v_BuySell;

        IF done THEN
            LEAVE txn_loop;
        END IF;

        SET v_TotalCost = v_Quantity * v_Price;

        SELECT Virtual_Balance INTO v_Balance FROM User WHERE UserID = v_UserID;

        SELECT Quantity INTO v_OwnedShares
        FROM Portfolio
        WHERE UserID = v_UserID AND StockID = v_StockID;

        -- Buy Logic
        IF v_BuySell = 'Buy' THEN
            IF v_Balance < v_TotalCost THEN
                UPDATE Transaction
                SET Status = 'CANCELLED', Remarks = 'Insufficient funds'
                WHERE TransactionID = v_TransactionID;
            ELSE
                UPDATE User
                SET Virtual_Balance = Virtual_Balance - v_TotalCost
                WHERE UserID = v_UserID;

                INSERT INTO Portfolio (PortfolioID, UserID, StockID, Quantity)
                VALUES (v_PortfolioID, v_UserID, v_StockID, v_Quantity)
                ON DUPLICATE KEY UPDATE Quantity = Quantity + v_Quantity;

                UPDATE Transaction
                SET Status = 'EXECUTED', Remarks = 'N/A'
                WHERE TransactionID = v_TransactionID;
            END IF;

        -- Sell Logic
        ELSEIF v_BuySell = 'Sell' THEN
            IF v_OwnedShares IS NULL OR v_OwnedShares < v_Quantity THEN
                UPDATE Transaction
                SET Status = 'CANCELLED', Remarks = 'Insufficient stocks'
                WHERE TransactionID = v_TransactionID;
            ELSE
                UPDATE User
                SET Virtual_Balance = Virtual_Balance + v_TotalCost
                WHERE UserID = v_UserID;

                UPDATE Portfolio
                SET Quantity = Quantity - v_Quantity
                WHERE UserID = v_UserID AND StockID = v_StockID;

                DELETE FROM Portfolio
                WHERE UserID = v_UserID AND StockID = v_StockID AND Quantity = 0;

                UPDATE Transaction
                SET Status = 'EXECUTED', Remarks = 'N/A'
                WHERE TransactionID = v_TransactionID;
            END IF;
        END IF;

    END LOOP;

    CLOSE txn_cursor;
END$$

DELIMITER ;

INSERT INTO Admin (UserID, Name, Email, Password) VALUES
(001, 'Ramesh Gupta', 'ramesh.gupta@example.com', 'password123'),
(002, 'Anita Sharma', 'anita.sharma@example.com', 'securepass'),
(003, 'Vikram Singh', 'vikram.singh@example.com', 'vikram@2023');

INSERT INTO User (UserID, Name, Email, Password, Virtual_Balance) VALUES
(101, 'Amit Verma', 'amit.verma@example.com', 'pass123', 50000.00),
(102, 'Neha Patel', 'neha.patel@example.com', 'neha@pass', 60000.00),
(103, 'Rajesh Kumar', 'rajesh.kumar@example.com', 'raj123', 75000.00),
(104, 'Priya Mehta', 'priya.mehta@example.com', 'priya456', 80000.00),
(105, 'Suresh Iyer', 'suresh.iyer@example.com', 'suresh@789', 55000.00),
(106, 'Kiran Joshi', 'kiran.joshi@example.com', 'kiran999', 70000.00),
(107, 'Deepak Malhotra', 'deepak.malhotra@example.com', 'deepak321', 65000.00),
(108, 'Anjali Nair', 'anjali.nair@example.com', 'anjali@pass', 90000.00),
(109, 'Rohit Sharma', 'rohit.sharma@example.com', 'rohit789', 72000.00),
(110, 'Sneha Kapoor', 'sneha.kapoor@example.com', 'sneha123', 68000.00),
(111, 'Tarun Aggarwal', 'tarun.aggarwal@example.com', 'tarun@321', 58000.00),
(112, 'Megha Reddy', 'megha.reddy@example.com', 'megha@pass', 75000.00),
(113, 'Kunal Singh', 'kunal.singh@example.com', 'kunal@999', 90000.00),
(114, 'Divya Jain', 'divya.jain@example.com', 'divya@123', 82000.00),
(115, 'Piyush Chawla', 'piyush.chawla@example.com', 'piyush@pass', 62000.00),
(116, 'Ritika Saxena', 'ritika.saxena@example.com', 'ritika@555', 84000.00),
(117, 'Arun Prasad', 'arun.prasad@example.com', 'arun@888', 69000.00),
(118, 'Shweta Bansal', 'shweta.bansal@example.com', 'shweta@000', 73000.00),
(119, 'Harsh Vardhan', 'harsh.vardhan@example.com', 'harsh@321', 59000.00),
(120, 'Payal Dutta', 'payal.dutta@example.com', 'payal@777', 88000.00),
(121, 'Aarav Kapoor', 'aarav.kapoor@example.com', 'aarav@pass', 72000.00),
(122, 'Rohan Bhatia', 'rohan.bhatia@example.com', 'rohan@999', 65000.00),
(123, 'Sanya Sharma', 'sanya.sharma@example.com', 'sanya@123', 85000.00),
(124, 'Vikas Gupta', 'vikas.gupta@example.com', 'vikas@321', 78000.00),
(125, 'Aditi Nair', 'aditi.nair@example.com', 'aditi@000', 89000.00),
(126, 'Manoj Saxena', 'manoj.saxena@example.com', 'manoj@pass', 67000.00),
(127, 'Nikhil Verma', 'nikhil.verma@example.com', 'nikhil@555', 72000.00),
(128, 'Pooja Mehta', 'pooja.mehta@example.com', 'pooja@888', 94000.00),
(129, 'Rahul Prasad', 'rahul.prasad@example.com', 'rahul@pass', 59000.00),
(130, 'Tanya Aggarwal', 'tanya.aggarwal@example.com', 'tanya@777', 82000.00),
(131, 'Sahil Joshi', 'sahil.joshi@example.com', 'sahil@321', 70000.00),
(132, 'Meera Iyer', 'meera.iyer@example.com', 'meera@999', 88000.00),
(133, 'Arjun Desai', 'arjun.desai@example.com', 'arjun@000', 72000.00),
(134, 'Neha Kothari', 'neha.kothari@example.com', 'neha@123', 81000.00),
(135, 'Rajeev Sinha', 'rajeev.sinha@example.com', 'rajeev@pass', 69000.00),
(136, 'Kiran Reddy', 'kiran.reddy@example.com', 'kiran@555', 73000.00),
(137, 'Ananya Rao', 'ananya.rao@example.com', 'ananya@888', 92000.00),
(138, 'Harsh Malhotra', 'harsh.malhotra@example.com', 'harsh@pass', 64000.00),
(139, 'Simran Gill', 'simran.gill@example.com', 'simran@777', 86000.00),
(140, 'Yash Tandon', 'yash.tandon@example.com', 'yash@321', 71000.00),
(141, 'Priya Menon', 'priya.menon@example.com', 'priya@999', 89000.00),
(142, 'Ravi Narang', 'ravi.narang@example.com', 'ravi@000', 76000.00),
(143, 'Swati Banerjee', 'swati.banerjee@example.com', 'swati@123', 83000.00),
(144, 'Gaurav Bajaj', 'gaurav.bajaj@example.com', 'gaurav@pass', 72000.00),
(145, 'Nisha Sharma', 'nisha.sharma@example.com', 'nisha@555', 77000.00),
(146, 'Amit Khanna', 'amit.khanna@example.com', 'amit@888', 94000.00),
(147, 'Deepika Chauhan', 'deepika.chauhan@example.com', 'deepika@pass', 66000.00),
(148, 'Kunal Anand', 'kunal.anand@example.com', 'kunal@777', 82000.00),
(149, 'Siddharth Patil', 'siddharth.patil@example.com', 'siddharth@321', 74000.00),
(150, 'Shruti Joshi', 'shruti.joshi@example.com', 'shruti@999', 90000.00),
(151, 'Aditya Bhatt', 'aditya.bhatt@example.com', 'aditya@000', 78000.00),
(152, 'Pallavi Ghosh', 'pallavi.ghosh@example.com', 'pallavi@123', 87000.00),
(153, 'Vivek Chawla', 'vivek.chawla@example.com', 'vivek@pass', 73000.00),
(154, 'Juhi Srivastava', 'juhi.srivastava@example.com', 'juhi@555', 81000.00),
(155, 'Kartikeya Rao', 'kartikeya.rao@example.com', 'kartikeya@888', 95000.00),
(156, 'Sonali Saxena', 'sonali.saxena@example.com', 'sonali@pass', 70000.00),
(157, 'Nitin Trivedi', 'nitin.trivedi@example.com', 'nitin@777', 83000.00),
(158, 'Bhavna Mehta', 'bhavna.mehta@example.com', 'bhavna@321', 76000.00),
(159, 'Harish Nair', 'harish.nair@example.com', 'harish@999', 92000.00),
(160, 'Shivani Kapoor', 'shivani.kapoor@example.com', 'shivani@000', 79000.00),
(161, 'Ashwin Joshi', 'ashwin.joshi@example.com', 'ashwin@123', 86000.00),
(162, 'Ritika Taneja', 'ritika.taneja@example.com', 'ritika@pass', 73000.00),
(163, 'Chetan Mishra', 'chetan.mishra@example.com', 'chetan@555', 88000.00),
(164, 'Priyanka Jindal', 'priyanka.jindal@example.com', 'priyanka@888', 96000.00),
(165, 'Gautam Deshmukh', 'gautam.deshmukh@example.com', 'gautam@pass', 71000.00),
(166, 'Akash Anand', 'akash.anand@example.com', 'akash@777', 85000.00),
(167, 'Sneha Pillai', 'sneha.pillai@example.com', 'sneha@321', 78000.00),
(168, 'Omkar Sinha', 'omkar.sinha@example.com', 'omkar@999', 91000.00),
(169, 'Varun Malhotra', 'varun.malhotra@example.com', 'varun@2024', 75000.00),
(170, 'Divya Sen', 'divya.sen@example.com', 'divya@sen',86000.00);


INSERT INTO Stock (StockID, Symbol, Stock_Name, Market_Cap, Current_Price) VALUES
(1, 'TCS', 'Tata Consultancy Services', 1200000.50, 3850.25),
(2, 'INFY', 'Infosys', 750000.75, 1605.50),
(3, 'RELI', 'Reliance Industries', 1700000.30, 2405.75),
(4, 'HDFC', 'HDFC Bank', 900000.20, 1550.60),
(5, 'ICICIB', 'ICICI Bank', 800000.60, 925.40),
(6, 'SBIN', 'State Bank of India', 700000.45, 645.25),
(7, 'LT', 'Larsen & Toubro', 600000.80, 2285.90),
(8, 'SUNPH', 'Sun Pharma', 500000.35, 1120.75),
(9, 'WIPRO', 'Wipro Ltd.', 400000.50, 550.30),
(10, 'BAJAJ', 'Bajaj Auto', 450000.40, 4200.25),
(11, 'ITC', 'ITC Ltd.', 370000.90, 460.50),
(12, 'ONGC', 'Oil & Natural Gas Corp.', 340000.70, 180.75),
(13, 'MARUTI', 'Maruti Suzuki', 500000.60, 9600.90),
(14, 'COAL', 'Coal India Ltd.', 310000.20, 200.40),
(15, 'TITAN', 'Titan Company', 600000.10, 3450.70),
(16, 'ULTRACEM', 'UltraTech Cement', 700000.80, 8500.55),
(17, 'ADANIP', 'Adani Ports', 530000.40, 750.25),
(18, 'HCLT', 'HCL Technologies', 620000.30, 1150.60),
(19, 'ASIANP', 'Asian Paints', 580000.90, 2900.80),
(20, 'DRREDDY', 'Dr. Reddys Laboratories', 540000.70, 5050.20),
(21, 'TATAMOT', 'Tata Motors', 450000.75, 620.40),
(22, 'HDFCLIFE', 'HDFC Life Insurance', 390000.60, 565.20),
(23, 'TECHM', 'Tech Mahindra', 470000.90, 1100.35),
(24, 'POWERG', 'Power Grid Corp.', 500000.80, 280.75),
(25, 'JSWSTEEL', 'JSW Steel', 520000.50, 750.90),
(26, 'BOSCHLTD', 'Bosch Ltd.', 480000, 18600.50),
(27, 'HAVELLS', 'Havells India', 460000, 1400.30),
(28, 'RELIANCE', 'Reliance Industries', 1750000.45, 2500.90),
(29, 'GODREJCP', 'Godrej Consumer Products', 470000, 1220.75),
(30, 'ICICIBANK', 'ICICI Bank', 800000.65, 920.80),
(31, 'PIIND', 'PI Industries', 510000, 3200.40),
(32, 'AXISBANK', 'Axis Bank', 630000.20, 820.45),
(33, 'KOTAKBANK', 'Kotak Mahindra Bank', 700000.90, 1820.30),
(34, 'AMBUJACEM', 'Ambuja Cements', 520000, 540.20),
(35, 'BERGEPAINT', 'Berger Paints', 530001, 710.60),
(36, 'M&M', 'Mahindra & Mahindra', 600000.10, 1460.80),
(37, 'BAJAJ-AUTO', 'Bajaj Auto', 550000.90, 5600.75),
(38, 'HERO', 'Hero MotoCorp', 500000.40, 3100.50),
(39, 'EICHERMOT', 'Eicher Motors', 480000.60, 3400.80),
(40, 'DMART', 'Avenue Supermarts (Dmart)', 930000, 4100.90),
(41, 'COALINDIA', 'Coal India', 650000.90, 245.50),
(42, 'NTPC', 'NTPC Ltd.', 740000.75, 210.30),
(43, 'BPCL', 'Bharat Petroleum', 600000.40, 410.90),
(44, 'IOC', 'Indian Oil Corp.', 580000.10, 145.70),
(45, 'SUNPHARMA', 'Sun Pharma', 560000.20, 1250.35),
(46, 'CIPLA', 'Cipla', 530000.50, 1120.65),
(47, 'SIEMENS', 'Siemens Ltd.', 780000, 3750.40),
(48, 'DIVISLAB', 'Divi’s Laboratories', 490000.90, 3650.80),
(49, 'PERSISTENT', 'Persistent Systems', 500000, 6900.60),
(50, 'NESTLEIND', 'Nestle India', 870000.30, 22500.60),
(51, 'HUL', 'Hindustan Unilever', 890000.40, 2700.90),
(52, 'MPHASIS', 'Mphasis Ltd.', 540000, 2400.75),
(53, 'ASIANPAINT', 'Asian Paints', 950000.10, 2900.40),
(54, 'ULTRACEMCO', 'UltraTech Cement', 700000.60, 8500.80),
(55, 'GRASIM', 'Grasim Industries', 750000.90, 1900.30),
(56, 'BAJFINANCE', 'Bajaj Finance', 1200000.75, 7300.90),
(57, 'BAJAJFINSV', 'Bajaj Finserv', 1000000.80, 1600.75),
(58, 'HDFCAMC', 'HDFC Asset Management', 680000.40, 3600.30),
(59, 'ICICIPRULI', 'ICICI Prudential Life', 550000.50, 630.70),
(60, 'SBILIFE', 'SBI Life Insurance', 540000.30, 1240.60),
(61, 'GAIL', 'GAIL India', 490000.10, 110.20),
(62, 'TATACHEM', 'Tata Chemicals', 460000.60, 930.50),
(63, 'TATASTEEL', 'Tata Steel', 700000.90, 1320.75),
(64, 'VEDL', 'Vedanta Ltd.', 680000.20, 285.40),
(65, 'NMDC', 'NMDC Ltd.', 640000.30, 190.80),
(66, 'ADANIPORTS', 'Adani Ports & SEZ', 900000.60, 1290.90),
(67, 'ADANITRANS', 'Adani Transmission', 850000.20, 2750.80),
(68, 'ADANIPOWER', 'Adani Power', 780000.10, 580.70),
(69, 'ADANIG', 'Adani Green Energy', 600000.10, 3200.60),
(70, 'DABUR', 'Dabur India', 470000.40,520.70);

INSERT INTO Stock_History (stock_id, recorded_at, open_price, close_price, high_price, low_price, volume_traded) VALUES
(1, '2024-03-01 09:00:00', 3800.00, 3850.25, 3875.00, 3780.00, 500000),
(2, '2024-03-01 09:00:00', 1580.00, 1605.50, 1620.00, 1575.00, 300000),
(3, '2024-03-01 09:00:00', 2350.00, 2405.75, 2430.00, 2340.00, 400000),
(4, '2024-03-01 09:00:00', 1500.00, 1550.60, 1570.00, 1495.00, 350000),
(5, '2024-03-01 09:00:00', 900.00, 925.40, 940.00, 895.00, 250000),
(6, '2024-03-01 09:00:00', 600.00, 645.25, 670.00, 590.00, 200000),
(7, '2024-03-01 09:00:00', 2200.00, 2285.90, 2300.00, 2185.00, 150000),
(8, '2024-03-01 09:00:00', 1100.00, 1120.75, 1150.00, 1085.00, 180000),
(9, '2024-03-01 09:00:00', 530.00, 550.30, 565.00, 525.00, 160000),
(10, '2024-03-01 09:00:00', 4100.00, 4200.25, 4300.00, 4050.00, 140000),
(11, '2024-03-01 09:00:00', 450.00, 460.50, 475.00, 440.00, 130000),
(12, '2024-03-01 09:00:00', 175.00, 180.75, 190.00, 170.00, 90000),
(13, '2024-03-01 09:00:00', 9500.00, 9600.90, 9700.00, 9400.00, 85000),
(14, '2024-03-01 09:00:00', 195.00, 200.40, 210.00, 190.00, 70000),
(15, '2024-03-01 09:00:00', 3400.00, 3450.70, 3500.00, 3350.00, 60000),
(16, '2024-03-01 09:00:00', 8450.00, 8500.55, 8600.00, 8400.00, 50000),
(17, '2024-03-01 09:00:00', 725.00, 750.25, 770.00, 715.00, 40000),
(18, '2024-03-01 09:00:00', 1120.00, 1150.60, 1180.00, 1105.00, 35000),
(19, '2024-03-01 09:00:00', 2850.00, 2900.80, 2950.00, 2800.00, 30000),
(20, '2024-03-01 09:00:00', 5000.00, 5050.20, 5100.00, 4950.00, 25000),
(21, '2024-03-01 09:00:00', 600.00, 620.40, 635.00, 590.00, 24000),
(22, '2024-03-01 09:00:00', 550.00, 565.20, 580.00, 530.00, 23000),
(23, '2024-03-01 09:00:00', 1075.00, 1100.35, 1125.00, 1050.00, 22000),
(24, '2024-03-01 09:00:00', 270.00, 280.75, 290.00, 260.00, 21000),
(25, '2024-03-01 09:00:00', 730.00, 750.90, 770.00, 720.00, 20000),
(26, '2024-03-01 09:00:00', 18500.00, 18600.50, 18700.00, 18400.00, 19500),
(27, '2024-03-01 09:00:00', 1380.00, 1400.30, 1420.00, 1370.00, 19000),
(28, '2024-03-01 09:00:00', 2450.00, 2500.90, 2550.00, 2400.00, 18500),
(29, '2024-03-01 09:00:00', 1200.00, 1220.75, 1240.00, 1180.00, 18000),
(30, '2024-03-01 09:00:00', 900.00, 920.80, 940.00, 890.00, 17500),
(31, '2024-03-01 09:00:00', 3150.00, 3200.40, 3250.00, 3100.00, 17000),
(32, '2024-03-01 09:00:00', 800.00, 820.45, 840.00, 790.00, 16500),
(33, '2024-03-01 09:00:00', 1800.00, 1820.30, 1850.00, 1780.00, 16000),
(34, '2024-03-01 09:00:00', 520.00, 540.20, 560.00, 510.00, 15000),
(35, '2024-03-01 09:00:00', 690.00, 710.60, 730.00, 680.00, 14500),
(36, '2024-03-01 09:00:00', 1440.00, 1460.80, 1480.00, 1420.00, 14000),
(37, '2024-03-01 09:00:00', 5550.00, 5600.75, 5650.00, 5500.00, 13500),
(38, '2024-03-01 09:00:00', 3050.00, 3100.50, 3150.00, 3000.00, 13000),
(39, '2024-03-01 09:00:00', 3350.00, 3400.80, 3450.00, 3300.00, 12500),
(40, '2024-03-01 09:00:00', 4050.00, 4100.90, 4150.00, 4000.00, 12000),
(41, '2024-03-01 09:00:00', 240.00, 245.50, 250.00, 235.00, 11500),
(42, '2024-03-01 09:00:00', 205.00, 210.30, 215.00, 200.00, 11000),
(43, '2024-03-01 09:00:00', 400.00, 410.90, 420.00, 395.00, 10500),
(44, '2024-03-01 09:00:00', 140.00, 145.70, 150.00, 135.00, 10000),
(45, '2024-03-01 09:00:00', 1230.00, 1250.35, 1270.00, 1220.00, 9500),
(46, '2024-03-01 09:00:00', 1100.00, 1120.65, 1140.00, 1090.00, 9000),
(47, '2024-03-01 09:00:00', 3700.00, 3750.40, 3800.00, 3680.00, 8500),
(48, '2024-03-01 09:00:00', 3600.00, 3650.80, 3700.00, 3580.00, 8000),
(49, '2024-03-01 09:00:00', 6850.00, 6900.60, 6950.00, 6800.00, 7500),
(50, '2024-03-01 09:00:00', 22400.00, 22500.60, 22600.00, 22300.00, 7000),
(51, '2024-03-01 09:00:00', 2650.00, 2700.90, 2750.00, 2600.00, 6500),
(52, '2024-03-01 09:00:00', 2350.00, 2400.75, 2450.00, 2300.00, 6000),
(53, '2024-03-01 09:00:00', 2850.00, 2900.40, 2950.00, 2800.00, 5500),
(54, '2024-03-01 09:00:00', 8450.00, 8500.80, 8550.00, 8400.00, 5000),
(55, '2024-03-01 09:00:00', 1850.00, 1900.30, 1950.00, 1840.00, 4800),
(56, '2024-03-01 09:00:00', 7250.00, 7300.90, 7350.00, 7200.00, 4600),
(57, '2024-03-01 09:00:00', 1550.00, 1600.75, 1650.00, 1540.00, 4400),
(58, '2024-03-01 09:00:00', 3550.00, 3600.30, 3650.00, 3500.00, 4200),
(59, '2024-03-01 09:00:00', 610.00, 630.70, 650.00, 600.00, 4000),
(60, '2024-03-01 09:00:00', 1220.00, 1240.60, 1260.00, 1210.00, 3800),
(61, '2024-03-01 09:00:00', 105.00, 110.20, 115.00, 100.00, 3600),
(62, '2024-03-01 09:00:00', 910.00, 930.50, 950.00, 900.00, 3400),
(63, '2024-03-01 09:00:00', 1300.00, 1320.75, 1340.00, 1290.00, 3200),
(64, '2024-03-01 09:00:00', 280.00, 285.40, 290.00, 275.00, 3000),
(65, '2024-03-01 09:00:00', 185.00, 190.80, 195.00, 180.00, 2800),
(66, '2024-03-01 09:00:00', 1270.00, 1290.90, 1310.00, 1260.00, 2600),
(67, '2024-03-01 09:00:00', 2700.00, 2750.80, 2800.00, 2680.00, 2400),
(68, '2024-03-01 09:00:00', 560.00, 580.70, 600.00, 550.00, 2200),
(69, '2024-03-01 09:00:00', 3150.00, 3200.60, 3250.00, 3100.00, 2000),
(70, '2024-03-01 09:00:00', 510.00, 520.70, 530.00, 500.00, 1800);


INSERT INTO Portfolio (PortfolioID, UserID, StockID, Quantity) VALUES
(1, 101, 68, 10),    -- User 101 owns 10 of Stock 68 (after selling 5 in transactions)
(2, 102, 32, 6),     -- User 102 owns 6 of Stock 32 (after buying 6 in transactions)
(2, 102, 70, 12),    -- User 102 owns 12 of Stock 70 (after selling 8 in transactions)
(3, 103, 10, 8),     -- User 103 owns 8 of Stock 10 (after selling 3 in transactions)
(3, 103, 40, 15),    -- User 103 owns 15 of Stock 40 (after selling 5 in transactions)
(4, 104, 63, 8),     -- User 104 owns 8 of Stock 63 (from buying 8 in transactions)
(5, 105, 36, 7),     -- User 105 owns 7 of Stock 36 (from buying 7 in transactions)
(6, 106, 20, 10),    -- User 106 owns 10 of Stock 20 (after selling 7 in transactions)
(6, 106, 27, 5),     -- User 106 owns 5 of Stock 27 (after selling 1 in transactions)
(7, 107, 4, 3),      -- User 107 owns 3 of Stock 4 (after selling 5 in transactions)
(7, 107, 48, 9),     -- User 107 owns 9 of Stock 48 (after selling 2 in transactions)
(8, 108, 19, 10),    -- User 108 owns 10 of Stock 19 (from buying 10 in transactions)
(8, 108, 25, 6),     -- User 108 owns 6 of Stock 25 (from buying 6 in transactions)
(9, 109, 54, 7),     -- User 109 owns 7 of Stock 54 (after selling 2 in transactions)
(10, 110, 9, 2),     -- User 110 owns 2 of Stock 9 (from buying 2 in transactions)
(10, 110, 15, 1),    -- User 110 owns 1 of Stock 15 (from buying 1 in transactions)
(11, 111, 38, 5),    -- User 111 owns 5 of Stock 38 (after selling 9 in transactions)
(12, 112, 16, 4),    -- User 112 owns 4 of Stock 16 (after selling 9 in transactions)
(13, 113, 14, 4),    -- User 113 owns 4 of Stock 14 (from buying 4 in transactions)
(13, 113, 23, 9),    -- User 113 owns 9 of Stock 23 (from buying 9 in transactions)
(14, 114, 37, 8),    -- User 114 owns 8 of Stock 37 (after selling 4 in transactions)
(15, 115, 17, 4),    -- User 115 owns 4 of Stock 17 (from buying 4 in transactions)
(15, 115, 30, 3),    -- User 115 owns 3 of Stock 30 (from buying 3 in transactions)
(16, 116, 52, 9),    -- User 116 owns 9 of Stock 52 (after selling 3 in transactions)
(17, 117, 61, 6),    -- User 117 owns 6 of Stock 61 (from buying 6 in transactions)
(18, 118, 65, 7),    -- User 118 owns 7 of Stock 65 (from buying 7 in transactions)
(19, 119, 4, 6),     -- User 119 owns 6 of Stock 4 (from buying 6 in transactions)
(20, 120, 34, 8),    -- User 120 owns 8 of Stock 34 (from buying 8 in transactions)
(21, 121, 6, 1),     -- User 121 owns 1 of Stock 6 (after selling 1 in transactions)
(21, 121, 55, 14),   -- User 121 owns 14 of Stock 55 (after selling 4 in transactions)
(22, 122, 39, 12),   -- User 122 owns 12 of Stock 39 (after selling 7 in transactions)
(23, 123, 59, 9),    -- User 123 owns 9 of Stock 59 (from buying 9 in transactions)
(24, 124, 51, 6),    -- User 124 owns 6 of Stock 51 (from buying 6 in transactions)
(25, 125, 6, 10),    -- User 125 owns 10 of Stock 6 (from buying 10 in transactions)
(25, 125, 11, 7),    -- User 125 owns 7 of Stock 11 (from buying 7 in transactions)
(26, 126, 56, 11),   -- User 126 owns 11 of Stock 56 (after selling 4 in transactions)
(27, 127, 3, 7),     -- User 127 owns 7 of Stock 3 (from buying 7 in transactions)
(28, 128, 20, 9),    -- User 128 owns 9 of Stock 20 (after selling 6 in transactions)
(29, 129, 66, 13),   -- User 129 owns 13 of Stock 66 (after selling 4 in transactions)
(30, 130, 26, 4),    -- User 130 owns 4 of Stock 26 (after selling 4 in transactions)
(30, 130, 31, 8),    -- User 130 owns 8 of Stock 31 (after selling 3 in transactions)
(31, 131, 58, 9),    -- User 131 owns 9 of Stock 58 (after selling 1 in transactions)
(32, 132, 11, 5),    -- User 132 owns 5 of Stock 11 (after selling 7 in transactions)
(32, 132, 12, 10),   -- User 132 owns 10 of Stock 12 (after selling 2 in transactions)
(33, 133, 9, 3),     -- User 133 owns 3 of Stock 9 (after selling 7 in transactions)
(34, 134, 22, 2),    -- User 134 owns 2 of Stock 22 (from buying 2 in transactions)
(35, 135, 1, 6),     -- User 135 owns 6 of Stock 1 (from buying 6 in transactions)
(35, 135, 12, 5),    -- User 135 owns 5 of Stock 12 (from buying 5 in transactions)
(36, 136, 55, 7),    -- User 136 owns 7 of Stock 55 (from buying 7 in transactions)
(37, 137, 21, 2),    -- User 137 owns 2 of Stock 21 (from buying 2 in transactions)
(37, 137, 35, 7),    -- User 137 owns 7 of Stock 35 (from buying 7 in transactions)
(38, 138, 2, 9),     -- User 138 owns 9 of Stock 2 (from buying 9 in transactions)
(38, 138, 7, 6),     -- User 138 owns 6 of Stock 7 (from buying 6 in transactions)
(39, 139, 23, 3),    -- User 139 owns 3 of Stock 23 (after selling 8 in transactions)
(40, 140, 5, 4),     -- User 140 owns 4 of Stock 5 (after selling 6 in transactions)
(40, 140, 18, 7),    -- User 140 owns 7 of Stock 18 (after selling 8 in transactions)
(41, 141, 27, 8),    -- User 141 owns 8 of Stock 27 (from buying 8 in transactions)
(41, 141, 45, 5),    -- User 141 owns 5 of Stock 45 (from buying 5 in transactions)
(42, 142, 2, 8),     -- User 142 owns 8 of Stock 2 (after selling 2 in transactions)
(42, 142, 25, 9),    -- User 142 owns 9 of Stock 25 (after selling 3 in transactions)
(43, 143, 60, 15),   -- User 143 owns 15 of Stock 60 (after selling 5 in transactions)
(44, 144, 28, 4),    -- User 144 owns 4 of Stock 28 (from buying 4 in transactions)
(45, 145, 5, 8),     -- User 145 owns 8 of Stock 5 (from buying 8 in transactions)
(46, 146, 13, 4),    -- User 146 owns 4 of Stock 13 (from buying 4 in transactions)
(47, 147, 16, 3),    -- User 147 owns 3 of Stock 16 (after selling 6 in transactions)
(47, 147, 21, 10),   -- User 147 owns 10 of Stock 21 (after selling 5 in transactions)
(48, 148, 64, 11),   -- User 148 owns 11 of Stock 64 (after selling 2 in transactions)
(49, 149, 17, 8),    -- User 149 owns 8 of Stock 17 (after selling 5 in transactions)
(50, 150, 8, 9),     -- User 150 owns 9 of Stock 8 (after selling 4 in transactions)
(50, 150, 18, 12),   -- User 150 owns 12 of Stock 18 (after selling 6 in transactions)
(51, 151, 57, 8),    -- User 151 owns 8 of Stock 57 (from buying 8 in transactions)
(52, 152, 41, 10),   -- User 152 owns 10 of Stock 41 (from buying 10 in transactions)
(53, 153, 53, 5),    -- User 153 owns 5 of Stock 53 (from buying 5 in transactions)
(54, 154, 47, 3),    -- User 154 owns 3 of Stock 47 (from buying 3 in transactions)
(55, 155, 22, 7),    -- User 155 owns 7 of Stock 22 (after selling 5 in transactions)
(55, 155, 42, 3),    -- User 155 owns 3 of Stock 42 (after selling 8 in transactions)
(56, 156, 8, 5),     -- User 156 owns 5 of Stock 8 (after selling 9 in transactions)
(57, 157, 13, 5),    -- User 157 owns 5 of Stock 13 (from buying 5 in transactions)
(57, 157, 24, 4),    -- User 157 owns 4 of Stock 24 (from buying 4 in transactions)
(58, 158, 46, 10),   -- User 158 owns 10 of Stock 46 (after selling 2 in transactions)
(59, 159, 5, 9),     -- User 159 owns 9 of Stock 5 (from buying 9 in transactions)
(59, 159, 7, 8),     -- User 159 owns 8 of Stock 7 (from buying 8 in transactions)
(60, 160, 44, 5),    -- User 160 owns 5 of Stock 44 (from buying 5 in transactions)
(61, 161, 15, 9),    -- User 161 owns 9 of Stock 15 (from buying 9 in transactions)
(61, 161, 19, 3),    -- User 161 owns 3 of Stock 19 (from buying 3 in transactions)
(62, 162, 9, 8),     -- User 162 owns 8 of Stock 9 (from buying 8 in transactions)
(62, 162, 29, 3),    -- User 162 owns 3 of Stock 29 (from buying 3 in transactions)
(63, 163, 43, 10),   -- User 163 owns 10 of Stock 43 (after selling 3 in transactions)
(64, 164, 24, 8),    -- User 164 owns 8 of Stock 24 (after selling 1 in transactions)
(64, 164, 50, 9),    -- User 164 owns 9 of Stock 50 (after selling 2 in transactions)
(65, 165, 62, 7),    -- User 165 owns 7 of Stock 62 (after selling 3 in transactions)
(66, 166, 10, 8),    -- User 166 owns 8 of Stock 10 (from buying 8 in transactions)
(67, 167, 49, 5),    -- User 167 owns 5 of Stock 49 (after selling 1 in transactions)
(68, 168, 3, 7),     -- User 168 owns 7 of Stock 3 (from buying 7 in transactions)
(68, 168, 33, 8),    -- User 168 owns 7 of Stock 33 (from buying 7 in transactions)
(69, 169, 1, 4),     -- User 169 owns 4 of Stock 1 (after selling 8 in transactions)
(69, 169, 14, 5),    -- User 169 owns 5 of Stock 14 (after selling 9 in transactions)
(69, 169, 69, 3),    -- User 169 owns 3 of Stock 69 (from buying 3 in transactions)
(70, 170, 26, 5),    -- User 170 owns 5 of Stock 26 (after selling 5 in transactions)
(70, 170, 67, 10);   -- User 170 owns 10 of Stock 67 (from buying 10 in transactions)


INSERT INTO Transaction (UserID, StockID, PortfolioID, Quantity, Price, Date_Time, Buy_Sell) VALUES
(135, 12, 35, 5, 180.75, '2024-03-02 10:15:30', 'Buy'),
(142, 25, 42, 3, 750.90, '2024-03-02 11:45:20', 'Sell'),
(168, 33, 68, 7, 1820.30, '2024-03-02 13:30:50', 'Buy'),
(107, 48, 7, 2, 3650.80, '2024-03-02 14:10:15', 'Sell'),
(159, 7, 59, 8, 2285.90, '2024-03-02 09:55:45', 'Buy'),
(121, 55, 21, 4, 1900.30, '2024-03-02 15:20:05', 'Sell'),
(138, 2, 38, 9, 1605.50, '2024-03-02 16:40:35', 'Buy'),
(150, 18, 50, 6, 1150.60, '2024-03-02 08:25:50', 'Sell'),
(162, 29, 62, 3, 1220.75, '2024-03-02 12:05:10', 'Buy'),
(103, 40, 3, 5, 4100.90, '2024-03-02 14:55:40', 'Sell'),
(125, 6, 25, 10, 645.25, '2024-03-02 11:30:25', 'Buy'),
(132, 11, 32, 7, 460.50, '2024-03-02 10:10:10', 'Sell'),
(157, 24, 57, 4, 280.75, '2024-03-02 09:40:30', 'Buy'),
(169, 1, 69, 8, 3850.25, '2024-03-02 13:15:20', 'Sell'),
(110, 9, 10, 2, 550.30, '2024-03-02 15:50:05', 'Buy'),
(147, 21, 47, 5, 620.40, '2024-03-02 14:05:50', 'Sell'),
(115, 30, 15, 3, 920.80, '2024-03-02 10:30:40', 'Buy'),
(140, 5, 40, 6, 925.40, '2024-03-02 11:25:15', 'Sell'),
(161, 15, 61, 9, 3450.70, '2024-03-02 12:35:20', 'Buy'),
(106, 27, 6, 1, 1400.30, '2024-03-02 14:20:30', 'Sell'),
(137, 35, 37, 7, 710.60, '2024-03-02 13:50:45', 'Buy'),
(155, 42, 55, 8, 210.30, '2024-03-02 16:05:10', 'Sell'),
(113, 14, 13, 4, 200.40, '2024-03-02 08:45:20', 'Buy'),
(164, 50, 64, 2, 22500.60, '2024-03-02 10:20:50', 'Sell'),
(108, 19, 8, 10, 2900.80, '2024-03-02 11:10:35', 'Buy'),
(130, 31, 30, 3, 3200.40, '2024-03-02 12:25:45', 'Sell'),
(141, 45, 41, 5, 1250.35, '2024-03-02 09:50:55', 'Buy'),
(122, 39, 22, 7, 3400.80, '2024-03-02 13:10:25', 'Sell'),
(166, 10, 66, 8, 4200.25, '2024-03-02 15:35:50', 'Buy'),
(128, 20, 28, 6, 5050.20, '2024-03-02 14:10:15', 'Sell'),
(144, 28, 44, 4, 2500.90, '2024-03-02 12:50:35', 'Buy'),
(156, 8, 56, 9, 1120.75, '2024-03-02 09:30:20', 'Sell'),
(134, 22, 34, 2, 565.20, '2024-03-02 11:55:30', 'Buy'),
(170, 26, 70, 5, 18600.50, '2024-03-02 14:25:40', 'Sell'),
(105, 36, 5, 7, 1460.80, '2024-03-02 16:10:20', 'Buy'),
(163, 43, 63, 3, 410.90, '2024-03-02 08:40:50', 'Sell'),
(119, 4, 19, 6, 1550.60, '2024-03-02 10:15:25', 'Buy'),
(139, 23, 39, 8, 1100.35, '2024-03-02 12:05:40', 'Sell'),
(152, 41, 52, 10, 245.50, '2024-03-02 09:55:30', 'Buy'),
(112, 16, 12, 9, 8500.55, '2024-03-02 11:40:25', 'Sell'),
(146, 13, 46, 4, 9600.90, '2024-03-02 10:10:15', 'Buy'),
(158, 46, 58, 2, 1120.65, '2024-03-02 12:20:30', 'Sell'),
(127, 3, 27, 7, 2405.75, '2024-03-02 14:30:40', 'Buy'),
(149, 17, 49, 5, 750.25, '2024-03-02 09:45:50', 'Sell'),
(120, 34, 20, 8, 540.20, '2024-03-02 11:10:20', 'Buy'),
(167, 49, 67, 1, 6900.60, '2024-03-02 15:20:35', 'Sell'),
(102, 32, 2, 6, 820.45, '2024-03-02 13:35:50', 'Buy'),
(114, 37, 14, 4, 5600.75, '2024-03-02 12:45:25', 'Sell'),
(154, 47, 54, 3, 3750.40, '2024-03-02 14:55:40', 'Buy'),
(111, 38, 11, 9, 3100.50, '2024-03-02 09:40:15', 'Sell'),
(160, 44, 60, 5, 145.70, '2024-03-02 11:55:30', 'Buy'),
(133, 9, 33, 7, 550.30, '2024-03-02 15:25:40', 'Sell'),
(145, 5, 45, 8, 925.40, '2024-03-02 13:15:10', 'Buy'),
(124, 51, 24, 6, 2700.90, '2024-03-02 09:20:15', 'Buy'),
(116, 52, 16, 3, 2400.75, '2024-03-02 13:45:30', 'Sell'),
(153, 53, 53, 5, 2900.40, '2024-03-02 11:20:25', 'Buy'),
(109, 54, 9, 2, 8500.80, '2024-03-02 14:35:45', 'Sell'),
(136, 55, 36, 7, 1900.30, '2024-03-02 10:50:10', 'Buy'),
(126, 56, 26, 4, 7300.90, '2024-03-02 15:15:20', 'Sell'),
(151, 57, 51, 8, 1600.75, '2024-03-02 12:30:45', 'Buy'),
(131, 58, 31, 1, 3600.30, '2024-03-02 09:55:35', 'Sell'),
(123, 59, 23, 9, 630.70, '2024-03-02 11:40:20', 'Buy'),
(143, 60, 43, 5, 1240.60, '2024-03-02 14:25:50', 'Sell'),
(117, 61, 17, 6, 110.20, '2024-03-02 15:50:30', 'Buy'),
(165, 62, 65, 3, 930.50, '2024-03-02 10:15:45', 'Sell'),
(104, 63, 4, 8, 1320.75, '2024-03-02 13:20:10', 'Buy'),
(148, 64, 48, 2, 285.40, '2024-03-02 16:45:30', 'Sell'),
(118, 65, 18, 7, 190.80, '2024-03-02 09:30:15', 'Buy'),
(129, 66, 29, 4, 1290.90, '2024-03-02 12:55:40', 'Sell'),
(170, 67, 70, 10, 2750.80, '2024-03-02 15:20:15', 'Buy'),
(101, 68, 1, 5, 580.70, '2024-03-02 10:45:25', 'Sell'),
(169, 69, 69, 3, 3200.60, '2024-03-02 13:10:50', 'Buy'),
(102, 70, 2, 8, 520.70, '2024-03-02 16:35:20', 'Sell'),
(135, 1, 35, 6, 3850.25, '2024-03-02 09:50:35', 'Buy'),
(142, 2, 42, 2, 1605.50, '2024-03-02 12:15:45', 'Sell'),
(168, 3, 68, 7, 2405.75, '2024-03-02 15:30:10', 'Buy'),
(107, 4, 7, 5, 1550.60, '2024-03-02 10:55:40', 'Sell'),
(159, 5, 59, 9, 925.40, '2024-03-02 13:20:25', 'Buy'),
(121, 6, 21, 1, 645.25, '2024-03-02 16:45:35', 'Sell'),
(138, 7, 38, 6, 2285.90, '2024-03-02 09:10:50', 'Buy'),
(150, 8, 50, 4, 1120.75, '2024-03-02 12:35:15', 'Sell'),
(162, 9, 62, 8, 550.30, '2024-03-02 15:50:30', 'Buy'),
(103, 10, 3, 3, 4200.25, '2024-03-02 10:15:55', 'Sell'),
(125, 11, 25, 7, 460.50, '2024-03-02 13:40:20', 'Buy'),
(132, 12, 32, 2, 180.75, '2024-03-02 16:05:45', 'Sell'),
(157, 13, 57, 5, 9600.90, '2024-03-02 09:30:10', 'Buy'),
(169, 14, 69, 9, 200.40, '2024-03-02 12:55:35', 'Sell'),
(110, 15, 10, 1, 3450.70, '2024-03-02 15:20:50', 'Buy'),
(147, 16, 47, 6, 8500.55, '2024-03-02 10:45:15', 'Sell'),
(115, 17, 15, 4, 750.25, '2024-03-02 13:10:40', 'Buy'),
(140, 18, 40, 8, 1150.60, '2024-03-02 16:35:55', 'Sell'),
(161, 19, 61, 3, 2900.80, '2024-03-02 09:00:20', 'Buy'),
(106, 20, 6, 7, 5050.20, '2024-03-02 12:25:45', 'Sell'),
(137, 21, 37, 2, 620.40, '2024-03-02 15:50:10', 'Buy'),
(155, 22, 55, 5, 565.20, '2024-03-02 10:15:35', 'Sell'),
(113, 23, 13, 9, 1100.35, '2024-03-02 13:40:50', 'Buy'),
(164, 24, 64, 1, 280.75, '2024-03-02 16:05:15', 'Sell'),
(108, 25, 8, 6, 750.90, '2024-03-02 09:30:40', 'Buy'),
(130, 26, 30, 4, 18600.50, '2024-03-02 12:55:55', 'Sell'),
(141, 27, 41, 8, 1400.30, '2024-03-02 15:20:10', 'Buy');
CALL ProcessTransactions();