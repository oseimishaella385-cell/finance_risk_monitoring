SELECT * FROM finance.accounts;

-- Account Table Cleaning --

SELECT COUNT(*) AS total_accounts,
SUM(AccountID IS NULL) AS missing_account_id,
SUM(CustomerID IS NULL) AS missing_customer_id,
SUM(AccountTypeID IS NULL) AS missing_account_type,
    SUM(Balance IS NULL) AS missing_balance,
    SUM(OpeningDate IS NULL) AS missing_opening_date
FROM accounts;


--  Check for Blank Opening Dates
SELECT
    SUM(TRIM(OpeningDate) = '') AS blank_opening_dates
FROM accounts;

--  Identify Duplicate Account IDs
SELECT
    AccountID,
    COUNT(*) AS account_count
FROM accounts
GROUP BY AccountID
HAVING COUNT(*) > 1;

-- Investigate Duplicate Account Records
SELECT *
FROM accounts
WHERE AccountID IN (
    SELECT AccountID
    FROM accounts
    GROUP BY AccountID
    HAVING COUNT(*) > 1
)
ORDER BY AccountID;

--  Created Clean Accounts Table and without Duplicates
CREATE TABLE accounts_clean AS

WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY AccountID
            ORDER BY AccountID
        ) AS row_num
    FROM accounts
)

SELECT
    AccountID,
    CustomerID,
    AccountTypeID,
    Balance,
    OpeningDate
FROM deduplicated
WHERE row_num = 1;


--  Validated Duplicates were removed 
SELECT
    AccountID,
    COUNT(*) AS account_count
FROM accounts_clean
GROUP BY AccountID
HAVING COUNT(*) > 1;

-- comparison between raw and cleaned Account counts
SELECT
    (SELECT COUNT(*) FROM accounts) AS raw_accounts,
    (SELECT COUNT(*) FROM accounts_clean) AS clean_accounts;
    
-- Standardise Blank Opening dates to NULL

SET SQL_SAFE_UPDATES = 0;

UPDATE accounts_clean
SET OpeningDate = NULL
WHERE TRIM(OpeningDate) = '';

SET SQL_SAFE_UPDATES = 1;


-- validated missing opening dates

SELECT SUM(openingDate IS NULL) AS Null_opening_date,
SUM(TRIM(OpeningDate) = ' ') AS blank_opening_dates
FROM accounts_clean;

-- Profile OpeningDates Formats

SELECT
    CASE
        WHEN OpeningDate REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
            THEN 'YYYY/MM/DD'

        WHEN OpeningDate REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN 'DD/MM or MM/DD'

        WHEN OpeningDate REGEXP '^[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}$'
            THEN 'Dot Format'

        WHEN OpeningDate LIKE '%T%'
            THEN 'ISO Timestamp'

        WHEN OpeningDate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
            THEN 'Standard Timestamp'

        WHEN OpeningDate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN 'YYYY-MM-DD'

        ELSE 'Other'
    END AS date_format,
    COUNT(*) AS number_of_records
FROM accounts_clean
WHERE OpeningDate IS NOT NULL
GROUP BY date_format;



-- create standardise OpeningDate column
ALTER TABLE accounts_clean
ADD COLUMN CleanOpeningDate DATE;


-- Standardise Opening Date Timestamp Format
SET SQL_SAFE_UPDATES = 0;

UPDATE accounts_clean
SET CleanOpeningDate = STR_TO_DATE(
    LEFT(OpeningDate, 10),
    '%Y-%m-%d'
)
WHERE OpeningDate IS NOT NULL;

SET SQL_SAFE_UPDATES = 1;

-- Validate standardised opening dates
SELECT 
 OpeningDate,
 CleanOpeningDate
 FROM accounts_clean
 WHERE OpeningDate IS NOT NULL 
 LIMIT  20;
 
 -- Check for invalid opening dates (future dates)
SELECT
    AccountID,
    CustomerID,
    OpeningDate,
    CleanOpeningDate
FROM accounts_clean
WHERE CleanOpeningDate > CURDATE();


-- Review Account Opening Date Range
SELECT
    MIN(CleanOpeningDate) AS earliest_opening_date,
    MAX(CleanOpeningDate) AS latest_opening_date
FROM accounts_clean
WHERE CleanOpeningDate IS NOT NULL;




-- Account Balances --

-- Profile account distribution
SELECT 
  MIN(Balance) AS minimum_balance,
  MAX(Balance) AS maximun_balance,
  AVG(Balance) AS average_balmce,
  SUM(Balance < 0) AS negative_balance_accounts,
  SUM(Balance = 0) AS zero_balance_accounts,
  SUM(BALANCE > 0) AS Positive_balance_accounts
   FROM accounts_clean;

--  Investigate Negative Account Balances
SELECT
    AccountID,
    CustomerID,
    AccountTypeID,
    Balance,
    CleanOpeningDate
FROM accounts_clean
WHERE Balance < 0
ORDER BY Balance ASC;

-- Negative balances were reviewed and retained as crucial financial values.
-- These may represent overdrawn accounts and will be used as a potential financial vulnerability indicator during risk analysis.

-- checking for invalid Account type IDs or invalid customer IDs
SELECT
    a.AccountID,
    a.AccountTypeID
FROM accounts_clean a
LEFT JOIN account_types at
    ON a.AccountTypeID = at.AccountTypeID
WHERE at.AccountTypeID IS NULL;

SELECT
    a.AccountID,
    a.CustomerID
FROM accounts_clean a
LEFT JOIN customers_clean c
    ON a.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;


-- last accounts cleaning validation
SELECT
    COUNT(*) AS total_clean_accounts,
    SUM(OpeningDate IS NULL) AS missing_opening_dates,
    SUM(CleanOpeningDate IS NULL) AS unresolved_clean_opening_dates,
    SUM(Balance < 0) AS negative_balance_accounts
FROM accounts_clean;