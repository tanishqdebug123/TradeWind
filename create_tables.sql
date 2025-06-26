use project;

DROP TABLE Admin, User, Stock, Portfolio, Transaction, Stock_History;

CREATE TABLE Admin (
    UserID INT PRIMARY KEY CHECK (UserID BETWEEN 1 AND 99), 
    Name VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Password VARCHAR(255) NOT NULL
);

CREATE TABLE User (
    UserID INT PRIMARY KEY CHECK (UserID > 100), 
    Name VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Virtual_Balance DECIMAL(10,2) CHECK (Virtual_Balance >= 0)
);

CREATE TABLE Stock (
    StockID INT PRIMARY KEY,
    Symbol VARCHAR(10) UNIQUE,
    Stock_Name VARCHAR(100),
    Market_Cap BIGINT,
    Current_Price DECIMAL(10,2) CHECK (Current_Price > 0)
);

CREATE TABLE Portfolio (
    PortfolioID INT,
    UserID INT,
    StockID INT,
    Quantity INT CHECK (Quantity >= 0),
    PRIMARY KEY (PortfolioID, StockID),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (StockID) REFERENCES Stock(StockID) ON DELETE CASCADE
);

CREATE TABLE Transaction (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    StockID INT,
    PortfolioID INT,
    Quantity INT,
    Price DECIMAL(10,2) CHECK (Price > 0),
    Date_Time DATETIME DEFAULT CURRENT_TIMESTAMP,
    Buy_Sell ENUM('Buy', 'Sell'),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (StockID) REFERENCES Stock(StockID) ON DELETE CASCADE,
    FOREIGN KEY (PortfolioID) REFERENCES Portfolio(PortfolioID) ON DELETE CASCADE
);

ALTER TABLE Transaction
ADD COLUMN Status ENUM('PENDING', 'EXECUTED', 'CANCELLED') DEFAULT 'PENDING',
ADD COLUMN Remarks VARCHAR(255) DEFAULT 'N/A';


CREATE TABLE Stock_History (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    stock_id INT NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    open_price DECIMAL(10,2) NOT NULL,
    close_price DECIMAL(10,2) NOT NULL,
    high_price DECIMAL(10,2) NOT NULL,
    low_price DECIMAL(10,2) NOT NULL,
    volume_traded BIGINT,
    FOREIGN KEY (stock_id) REFERENCES Stock(StockID) ON DELETE CASCADE,
    INDEX idx_stock_id (stock_id),
    INDEX idx_recorded_at (recorded_at)
);
