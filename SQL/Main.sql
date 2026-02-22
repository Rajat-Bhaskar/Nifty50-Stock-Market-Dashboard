CREATE DATABASE nifty50_db;
USE nifty50_db;

CREATE TABLE Stock_Prices (
    Trade_Date DATE NOT NULL,
    Symbol VARCHAR(20) NOT NULL,
    Series VARCHAR(5) NOT NULL,
    Prev_Close DECIMAL(10,2),
    Open_Price DECIMAL(10,2),
    High_Price DECIMAL(10,2),
    Low_Price DECIMAL(10,2),
    Last_Price DECIMAL(10,2),
    Close_Price DECIMAL(10,2),
    VWAP DECIMAL(10,2),
    Volume BIGINT,
    Turnover DECIMAL(20,2),
    Trades VARCHAR(20),
    Deliverable_Volume VARCHAR(20),
    Percentage_Deliverable DECIMAL(6,4)
);

LOAD DATA LOCAL INFILE 'D:\\Stock Market Project\\NIFTY50.csv'
INTO TABLE stock_prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE stock_prices 
MODIFY Percentage_Deliverable VARCHAR(50),
MODIFY Trades VARCHAR(50),
MODIFY Deliverable_Volume VARCHAR(50);

TRUNCATE TABLE stock_prices;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NIFTY50.csv'
INTO TABLE stock_prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
@Trade_Date,
Symbol,
Series,
Prev_Close,
Open_Price,
High_Price,
Low_Price,
Last_Price,
Close_Price,
VWAP,
Volume,
Turnover,
Trades,
Deliverable_Volume,
Percentage_Deliverable
)
SET Trade_Date = STR_TO_DATE(@Trade_Date, '%d-%m-%Y');

UPDATE stock_prices
SET
Percentage_Deliverable = NULL
WHERE Percentage_Deliverable = '' 
   OR Percentage_Deliverable = 'NULL'
   OR Percentage_Deliverable = ' ';

UPDATE stock_prices
SET
Trades = NULL
WHERE Trades = '' OR Trades = 'NULL';

UPDATE stock_prices
SET
Deliverable_Volume = NULL
WHERE Deliverable_Volume = '' OR Deliverable_Volume = 'NULL';

SELECT Percentage_Deliverable
FROM stock_prices
WHERE Percentage_Deliverable IS NOT NULL
AND Percentage_Deliverable NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
LIMIT 50;

UPDATE stock_prices
SET Percentage_Deliverable = NULL
WHERE Percentage_Deliverable = '';

UPDATE stock_prices
SET Trades = NULL
WHERE Trades = '';

UPDATE stock_prices
SET Deliverable_Volume = NULL
WHERE Deliverable_Volume = '';


UPDATE stock_prices
SET Percentage_Deliverable = TRIM(Percentage_Deliverable);

UPDATE stock_prices
SET Trades = TRIM(Trades);

UPDATE stock_prices
SET Deliverable_Volume = TRIM(Deliverable_Volume);


ALTER TABLE stock_prices 
MODIFY Percentage_Deliverable DECIMAL(6,4),
MODIFY Trades BIGINT,
MODIFY Deliverable_Volume BIGINT;

UPDATE stock_prices
SET Percentage_Deliverable = CAST(Percentage_Deliverable AS DECIMAL(6,4))
WHERE Percentage_Deliverable IS NOT NULL;

ALTER TABLE stock_prices 
ADD COLUMN pd_clean DECIMAL(6,4);

UPDATE stock_prices
SET pd_clean = 
CASE
    WHEN Percentage_Deliverable REGEXP '^[0-9]+(\\.[0-9]+)?$'
    THEN CAST(Percentage_Deliverable AS DECIMAL(6,4))
    ELSE NULL
END;

ALTER TABLE stock_prices 
DROP COLUMN Percentage_Deliverable;

ALTER TABLE stock_prices 
CHANGE pd_clean Percentage_Deliverable DECIMAL(6,4);

ALTER TABLE stock_prices ADD COLUMN trades_clean BIGINT;

UPDATE stock_prices
SET trades_clean =
CASE
    WHEN Trades REGEXP '^[0-9]+$'
    THEN CAST(Trades AS UNSIGNED)
    ELSE NULL
END;

ALTER TABLE stock_prices DROP COLUMN Trades;

ALTER TABLE stock_prices CHANGE trades_clean Trades BIGINT;

ALTER TABLE stock_prices ADD COLUMN dv_clean BIGINT;

UPDATE stock_prices
SET dv_clean =
CASE
    WHEN Deliverable_Volume REGEXP '^[0-9]+$'
    THEN CAST(Deliverable_Volume AS UNSIGNED)
    ELSE NULL
END;

ALTER TABLE stock_prices DROP COLUMN Deliverable_Volume;

ALTER TABLE stock_prices CHANGE dv_clean Deliverable_Volume BIGINT;

DESCRIBE stock_prices;

ALTER TABLE stock_prices 
ADD COLUMN Trade_Date_New DATE;

UPDATE stock_prices
SET Trade_Date_New = STR_TO_DATE(Trade_Date, '%Y-%m-%d');

ALTER TABLE stock_prices DROP COLUMN Trade_Date;

ALTER TABLE stock_prices 
CHANGE Trade_Date_New Trade_Date DATE;

DESCRIBE stock_prices;

SELECT MIN(Trade_Date), MAX(Trade_Date)
FROM stock_prices;

SELECT 
COUNT(*) AS total_rows,
COUNT(DISTINCT Symbol) AS total_stocks,
MIN(Trade_Date) AS start_date,
MAX(Trade_Date) AS end_date
FROM stock_prices;

SELECT DISTINCT Symbol FROM Stock_Prices;








