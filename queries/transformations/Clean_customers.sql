SELECT COUNT(CustomerID) FROM Customers;

SELECT *
FROM customers
LIMIT 20;

-- Missing names
SELECT
    SUM(CustomerID IS NULL) AS null_customer_id,

    SUM(FirstName IS NULL) AS null_first_name,
    SUM(TRIM(FirstName) = '') AS blank_first_name,

    SUM(LastName IS NULL) AS null_last_name,
    SUM(TRIM(LastName) = '') AS blank_last_name,

    SUM(DateOfBirth IS NULL) AS null_dob,
    SUM(TRIM(DateOfBirth) = '') AS blank_dob

FROM customers;

-- Duplicate IDs
SELECT
    CustomerID,
    COUNT(*) AS occurrences
FROM customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-- Distinct values
SELECT DISTINCT FirstName
FROM customers
ORDER BY FirstName;

SELECT DISTINCT LastName
FROM customers
ORDER BY LastName;

-- Names with erros
SELECT
    CustomerID,
    FirstName,
    LastName
FROM customers_clean
WHERE FirstName REGEXP '[0-9]'
   OR LastName REGEXP '[0-9]';

-- name error - numerical value in name
SELECT
    CustomerID,
    FirstName,
    LastName,
    DateOfBirth,
    CustomerTypeID,
    AddressID
FROM customers_clean
WHERE LastName = '2aller';

-- Last name comparisons if not applicable, LastName = NULL
SELECT
    CustomerID,
    FirstName,
    LastName,
    DateOfBirth,
    CustomerTypeID,
    AddressID
FROM customers
WHERE LastName = 'Waller';

SET SQL_SAFE_UPDATES = 0;

UPDATE customers_clean
SET LastName = NULL
WHERE CustomerID = 10585
  AND LastName = '2aller';

SET SQL_SAFE_UPDATES = 1;  
 
-- Find Duplicate IDs
SELECT *
FROM customers
WHERE CustomerID IN (
    SELECT CustomerID
    FROM customers
    GROUP BY CustomerID
    HAVING COUNT(*) > 1
)
ORDER BY CustomerID;
 
 -- Find missing LastName 
SELECT *
FROM customers
WHERE LOWER(FirstName) LIKE '%teo%';

SELECT
    CustomerID,
    FirstName,
    LastName,
    DateOfBirth,
    CustomerTypeID,
    AddressID,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY
    CustomerID,
    FirstName,
    LastName,
    DateOfBirth,
    CustomerTypeID,
    AddressID
HAVING COUNT(*) > 1;

-- Create new table
CREATE TABLE customers_clean AS

WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID
            ORDER BY CustomerID
        ) AS row_num
    FROM customers
)

SELECT
    CustomerID,
    FirstName,
    LastName,
    DateOfBirth,
    CustomerTypeID,
    AddressID
FROM deduplicated
WHERE row_num = 1;


SELECT * FROM finance.customers_clean;


-- Record amissing names as NULL
SELECT
    CustomerID,
    FirstName,
    LastName
FROM customers_clean
WHERE
    FirstName IS NULL
    OR TRIM(FirstName) = ''
    OR LastName IS NULL
    OR TRIM(LastName) = '';
    
    -- counts - 22 missing last&Firstnames
    SELECT
    SUM(FirstName IS NULL OR TRIM(FirstName) = '') 
        AS missing_first_names,

    SUM(LastName IS NULL OR TRIM(LastName) = '') 
        AS missing_last_names

FROM customers_clean;

-- update blank spaces to null
UPDATE customers_clean
SET FirstName = NULL
WHERE TRIM(FirstName) = '';


-- update blank firstnames/Lastnames to null
SET SQL_SAFE_UPDATES = 0;

UPDATE customers_clean
SET FirstName = NULL
WHERE TRIM(FirstName) = '';

UPDATE customers_clean
SET LastName = NULL
WHERE TRIM(LastName) = '';

SET SQL_SAFE_UPDATES = 1;


-- Validating blank names show null
SELECT
    SUM(FirstName IS NULL) AS null_first_names,
    SUM(TRIM(FirstName) = '') AS blank_first_names,
    SUM(LastName IS NULL) AS null_last_names,
    SUM(TRIM(LastName) = '') AS blank_last_names
FROM customers_clean;


-- Date of Birth Cleaning and Standardisation --


-- Check D.0.B Formats 
SELECT DISTINCT DateOfBirth
FROM customers_clean;

SELECT
    COUNT(*) AS total_customers,
    SUM(DateOfBirth IS NULL) AS null_dob,
    SUM(TRIM(DateOfBirth) = '') AS blank_dob,
    SUM(TRIM(DateOfBirth) = 'NaT') AS nat_dob
FROM customers_clean;

-- 'NaT' is converted to null
SET SQL_SAFE_UPDATES = 0;

UPDATE customers_clean
SET DateOfBirth = NULL
WHERE TRIM(DateOfBirth) = 'NaT';

-- Validate 
SET SQL_SAFE_UPDATES = 1;

SELECT
    SUM(DateOfBirth IS NULL) AS null_dob,
    SUM(TRIM(DateOfBirth) = '') AS blank_dob,
    SUM(TRIM(DateOfBirth) = 'NaT') AS nat_dob
FROM customers_clean;

SELECT DISTINCT DateOfBirth
FROM customers_clean
WHERE DateOfBirth IS NOT NULL
ORDER BY DateOfBirth;

-- Removal of text in D.O.B Format
SELECT
    CustomerID,
    DateOfBirth
FROM customers_clean
WHERE DateOfBirth REGEXP '[A-Za-z]';

-- Check D.O.B Format inconsistencies
SELECT
    CASE
        WHEN DateOfBirth REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
            THEN 'YYYY/MM/DD'

        WHEN DateOfBirth REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN 'DD/MM or MM/DD'

        WHEN DateOfBirth REGEXP '^[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}$'
            THEN 'Dot Format'

        WHEN DateOfBirth LIKE '%T%'
            THEN 'ISO Timestamp'

        WHEN DateOfBirth REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
            THEN 'Standard Timestamp'

        ELSE 'Other'
    END AS date_format,
    COUNT(*) AS number_of_records
FROM customers_clean
WHERE DateOfBirth IS NOT NULL
GROUP BY date_format;

-- Validate missing D.O.B values
SELECT
    COUNT(*) AS total_customers,
    COUNT(DateOfBirth) AS non_null_dob,
    SUM(DateOfBirth IS NULL) AS null_dob
FROM customers_clean;

-- Identify other unrecognised D.O.B formats
SELECT CustomerID, DateOfBirth
FROM customers_clean
WHERE DateOfBirth IS NOT NULL
  AND NOT (
      DateOfBirth REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
      OR DateOfBirth REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
      OR DateOfBirth REGEXP '^[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}$'
      OR DateOfBirth LIKE '%T%'
      OR DateOfBirth REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
  );
  
  -- Created standardised DOB column
  ALTER TABLE customers_clean
ADD COLUMN CleanDateOfBirth DATE;

-- Standardise Timestamp DOB Format
SET SQL_SAFE_UPDATES = 0;

UPDATE customers_clean
SET CleanDateOfBirth = STR_TO_DATE(
    LEFT(DateOfBirth, 10),
    '%Y-%m-%d'
)
WHERE DateOfBirth REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
  AND CleanDateOfBirth IS NULL;

SET SQL_SAFE_UPDATES = 1;

-- Validate Standardised Timestamp DOBs
SELECT
    DateOfBirth,
    CleanDateOfBirth
FROM customers_clean
WHERE DateOfBirth REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
LIMIT 20;

-- Standardise YYYY/MM/DD Format
SET SQL_SAFE_UPDATES = 0;

UPDATE customers_clean
SET CleanDateOfBirth = STR_TO_DATE(
    DateOfBirth,
    '%Y/%m/%d'
)
WHERE DateOfBirth REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
  AND CleanDateOfBirth IS NULL;

SET SQL_SAFE_UPDATES = 1;

--  Validate YYYY/MM/DD Conversion
SELECT
    CustomerID,
    DateOfBirth,
    CleanDateOfBirth
FROM customers_clean
WHERE DateOfBirth REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$';

  --  Standardise ISO Timestamp Format
SET SQL_SAFE_UPDATES = 0;

UPDATE customers_clean
SET CleanDateOfBirth = STR_TO_DATE(
    LEFT(DateOfBirth, 10),
    '%Y-%m-%d'
)
WHERE DateOfBirth LIKE '%T%'
  AND CleanDateOfBirth IS NULL;

SET SQL_SAFE_UPDATES = 1;


--  Validate ISO Timestamp Conversion
SELECT
    CustomerID,
    DateOfBirth,
    CleanDateOfBirth
FROM customers_clean
WHERE DateOfBirth LIKE '%T%';

-- Check dot format for D.O.B
SELECT
    CustomerID,
    DateOfBirth
FROM customers_clean
WHERE DateOfBirth REGEXP '^[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}$';

-- Standardise MM.DD.YYYY Format
SET SQL_SAFE_UPDATES = 0;

UPDATE customers_clean
SET CleanDateOfBirth = STR_TO_DATE(
    DateOfBirth,
    '%m.%d.%Y'
)
WHERE DateOfBirth REGEXP '^[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}$'
  AND CleanDateOfBirth IS NULL;

SET SQL_SAFE_UPDATES = 1;

-- Validate Dot Format Conversion
SELECT
    CustomerID,
    DateOfBirth,
    CleanDateOfBirth
FROM customers_clean
WHERE DateOfBirth REGEXP '^[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}$';


-- Investigate Ambiguous Slash Format DOBs
SELECT
    CustomerID,
    FirstName,
    LastName,
    DateOfBirth,
    CustomerTypeID,
    AddressID
FROM customers_clean
WHERE DateOfBirth REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$';

-- Ambiguous DD/MM/YYYY or MM/DD/YYYY values were retained
-- in the raw DOB field and left NULL in CleanDateOfBirth 
-- toV avoid unsupported assumptions.

-- Identify Malformed DOB Values
SELECT
    CustomerID,
    DateOfBirth,
    CleanDateOfBirth
FROM customers_clean
WHERE DateOfBirth IN ('1962-15-01', '1974-31-01');

-- Malformed DOB values were retained in the original DateOfBirth column.
-- CleanDateOfBirth was left NULL because the intended date could not be determined

-- Final DOB Cleaning Validation
SELECT
    COUNT(*) AS total_customers,
    COUNT(CleanDateOfBirth) AS cleaned_dob_count,
    SUM(CleanDateOfBirth IS NULL) AS missing_or_unresolved_dob
FROM customers_clean;

-- Checking for impossible DOBs (Future) and Unrealistic Ages
SELECT
    CustomerID,
    DateOfBirth,
    CleanDateOfBirth,
    TIMESTAMPDIFF(YEAR, CleanDateOfBirth, CURDATE()) AS age
FROM customers_clean
WHERE CleanDateOfBirth IS NOT NULL
  AND (
      CleanDateOfBirth > CURDATE()
      OR TIMESTAMPDIFF(YEAR, CleanDateOfBirth, CURDATE()) > 110
  );

--  Review Customer Age Range
SELECT
    MIN(TIMESTAMPDIFF(YEAR, CleanDateOfBirth, CURDATE())) AS youngest_age,
    MAX(TIMESTAMPDIFF(YEAR, CleanDateOfBirth, CURDATE())) AS oldest_age,
    AVG(TIMESTAMPDIFF(YEAR, CleanDateOfBirth, CURDATE())) AS average_age
FROM customers_clean
WHERE CleanDateOfBirth IS NOT NULL;

-- Investigate the customer under18
SELECT
   CustomerId,
   FirstName,
   LastName,
   DateOfBirth,
   CleanDateOfBirth,
   TIMESTAMPDIFF(YEAR, CleanDateOfBirth, CURDATE()) AS age,
   CustomerTypeID
FROM customers_clean
WHERE TIMESTAMPDIFF(YEAR, CleanDateOfBirth, CURDATE()) < 18
ORDER BY age;

-- Review Under18 Customers by Customer Type
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.CleanDateOfBirth,
    TIMESTAMPDIFF(YEAR, c.CleanDateOfBirth, CURDATE()) AS age,
    c.CustomerTypeID,
    ct.TypeName AS customer_type
FROM customers_clean c
LEFT JOIN customer_types ct
    ON c.CustomerTypeID = ct.CustomerTypeID
WHERE TIMESTAMPDIFF(YEAR, c.CleanDateOfBirth, CURDATE()) < 18
ORDER BY age;
   
   -- Last DOB Quality Check
SELECT
    COUNT(*) AS total_customers,
    COUNT(CleanDateOfBirth) AS valid_clean_dobs,
    SUM(CleanDateOfBirth IS NULL) AS missing_or_unresolved_dobs,
    MIN(CleanDateOfBirth) AS earliest_dob,
    MAX(CleanDateOfBirth) AS latest_dob
FROM customers_clean;

-- Validate the customer types and Address references
-- + Checking for Invalid Customer Type IDs,
SELECT
    SUM(CustomerTypeID IS NULL) AS missing_customer_type,
    SUM(AddressID IS NULL) AS missing_address_id
FROM customers_clean;

SELECT
    c.CustomerID,
    c.CustomerTypeID
FROM customers_clean c
LEFT JOIN customer_types ct
    ON c.CustomerTypeID = ct.CustomerTypeID
WHERE ct.CustomerTypeID IS NULL;

-- Check for Invalid Address IDs
SELECT
    c.CustomerID,
    c.AddressID
FROM customers_clean c
LEFT JOIN addresses a
    ON c.AddressID = a.AddressID
WHERE a.AddressID IS NULL;