
-- Total transactions - 12319
SELECT 	COUNT(*) AS total_transactions
FROM transactions;

-- checking for any missing values
SELECT 
 SUM(TransactionID IS NULL) AS missing_transaction_id,
 SUM(AccountOriginID IS NULL) AS missing_account_origin_id,
 SUM(AccountDestinationID IS NULL) AS missing_account_destination_id,
 SUM(TransactionTypeID IS NULL) AS missing_transation_id,
 SUM(Amount IS NULL) AS missing_amount,
 SUM(TRIM(TransactionDate) = ' ') AS blank_transaction_date
FROM transactions;

-- Duplicate transaction Ids

SELECT
TransactionID,
COUNT(*) AS duplicate_count
FROM transactions
GROUP BY TransactionID
HAVING COUNT(TransactionID) > 1
ORDER BY duplicate_count DESC;

-- Investigating duplicate records found

SELECT *
FROM transactions
WHERE TransactionID IN (
    SELECT TransactionID
    FROM transactions
    GROUP BY TransactionID
    HAVING COUNT(*) > 1
)
ORDER BY TransactionID;

--  clean transactions table without duplicates
CREATE TABLE Transactions_clean AS
WITH deduplicated AS (
SELECT *,
      ROW_NUMBER() OVER(PARTITION BY transactionID
      ORDER BY transactionID
      ) 
      AS row_num
FROM transactions 
)
SELECT  TransactionID,
AccountOriginID,
AccountdestinationID,
TransactionTypeId,
TransactionDate,
Amount,
BranchID,
Description
FROM deduplicated 
WHERE row_num = 1;

-- validate

SELECT 
COUNT(*) AS transaction_count
FROM transactions_clean
GROUP BY TransactionID
HAVING COUNT(*) > 1;

--  Comparison of number of transactions before and after removing duplicates
SELECT
    (SELECT COUNT(*) FROM transactions) AS raw_transactions,
    (SELECT COUNT(*) FROM transactions_clean) AS clean_transactions;
    
-- 23 duplicate transactions removed

-- checking transaction Date formats

SELECT
    CASE
        WHEN TransactionDate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
		THEN 'Standard Timestamp'
        WHEN TransactionDate LIKE '%T%'
		THEN 'ISO Timestamp'
        WHEN TransactionDate REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
		THEN 'YYYY/MM/DD'
        WHEN TransactionDate REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
		THEN 'Slash Format'
        ELSE 'Other'
    END AS date_format,
    COUNT(*) AS number_of_transactions
FROM transactions_clean
WHERE TransactionDate IS NOT NULL
GROUP BY date_format;

-- transaction dates that do not match the expected formats
SELECT
    TransactionID,
    TransactionDate
FROM transactions_clean
WHERE TransactionDate IS NOT NULL
  AND NOT (
      TransactionDate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
      OR TransactionDate LIKE '%T%'
      OR TransactionDate REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
      OR TransactionDate REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
  );
  
  -- replacing blank transaction dates with null
SET SQL_SAFE_UPDATES = 0;

UPDATE transactions_clean
SET TransactionDate = NULL
WHERE TRIM(TransactionDate) = '';

SET SQL_SAFE_UPDATES = 1;

-- validate blanks date are removed
SELECT
    SUM(TransactionDate IS NULL) AS missing_transaction_dates,
    SUM(TRIM(TransactionDate) = '') AS blank_transaction_dates
FROM transactions_clean;

--  clean transaction date column
ALTER TABLE transactions_clean
ADD COLUMN CleanTransactionDate DATE;

-- Conversion of transaction timestamp in preferred date format
SET SQL_SAFE_UPDATES = 0;

UPDATE transactions_clean
SET CleanTransactionDate =
    STR_TO_DATE(LEFT(TransactionDate, 10), '%Y-%m-%d')
WHERE TransactionDate IS NOT NULL;

SET SQL_SAFE_UPDATES = 1;

-- checking if transaction dates were converted correctly
SELECT
    COUNT(*) AS total_transactions,
    SUM(TransactionDate IS NULL) AS missing_original_dates,
    SUM(CleanTransactionDate IS NULL) AS missing_clean_dates
FROM transactions_clean;
-- The number of missing clean dates matches the original missing dates,
-- so no additional dates were lost during the conversion.


-- reviewing transaction dates validity (testing for future dates)
SELECT
    TransactionID,
    TransactionDate,
    CleanTransactionDate
FROM transactions_clean
WHERE CleanTransactionDate > CURDATE();

-- Range of transaction amounts
SELECT
    MIN(Amount) AS minimum_amount,
    MAX(Amount) AS maximum_amount,
    AVG(Amount) AS average_amount,
    SUM(Amount < 0) AS negative_amounts,
    SUM(Amount = 0) AS zero_amounts
FROM transactions_clean;

-- Transaction amounts were checked and no zero or negative values were found.
-- No changes were needed.

--  Thorough check of the cleaned transactions table
SELECT
    COUNT(*) AS total_clean_transactions,
    SUM(CleanTransactionDate IS NULL) AS missing_transaction_dates,
    SUM(Amount <= 0) AS invalid_amounts
FROM transactions_clean;

-- last transaction check
-- 23 exact duplicate transactions were removed.
-- 222 transactions had missing dates and were kept as NULL.
-- No future transaction dates or invalid transaction amounts were found.
-- Transaction type, account and address references were also checked.