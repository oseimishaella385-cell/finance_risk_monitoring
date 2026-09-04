-- Total addresses- 1222
SELECT 
COUNT(*) AS Total_addresses
FROM addresses;

-- investigating any missing values in the addresses table
SELECT
    SUM(AddressID IS NULL) AS missing_address_id,
    SUM(Street IS NULL) AS null_street,
    SUM(TRIM(Street) = '') AS blank_street,
    SUM(City IS NULL) AS null_city,
    SUM(TRIM(City) = '') AS blank_city,
    SUM(Country IS NULL) AS null_country,
    SUM(TRIM(Country) = '') AS blank_country
FROM addresses;

-- checking for duplicate address records
SELECT *
FROM addresses
WHERE AddressID IN (
    SELECT AddressID
    FROM addresses
    GROUP BY AddressID
    HAVING COUNT(*) > 1
)
ORDER BY AddressID;

-- Formation of cleaned address table
CREATE TABLE addresses_clean AS
WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY AddressID
            ORDER BY AddressID
        ) AS row_num
    FROM addresses
)
SELECT
    AddressID,
    Street,
    City,
    Country
FROM deduplicated
WHERE row_num = 1;

-- inspection of duplicates removal
SELECT
    AddressID,
    COUNT(*) AS address_count
FROM addresses_clean
GROUP BY AddressID
HAVING COUNT(*) > 1;

-- Check that duplicate Address IDs were removed
SELECT
    AddressID,
    COUNT(*) AS address_count
FROM addresses_clean
GROUP BY AddressID
HAVING COUNT(*) > 1;


--  Standardise blank address fields as NULL
SET SQL_SAFE_UPDATES = 0;

UPDATE addresses_clean
SET Street = NULL
WHERE TRIM(Street) = '';

UPDATE addresses_clean
SET City = NULL
WHERE TRIM(City) = '';

UPDATE addresses_clean
SET Country = NULL
WHERE TRIM(Country) = '';

SET SQL_SAFE_UPDATES = 1;


-- Checking blank address values were removed
SELECT
    SUM(Street IS NULL) AS missing_street,
    SUM(TRIM(Street) = '') AS blank_street,
    SUM(City IS NULL) AS missing_city,
    SUM(TRIM(City) = '') AS blank_city,
    SUM(Country IS NULL) AS missing_country,
    SUM(TRIM(Country) = '') AS blank_country
FROM addresses_clean;


-- last check of the cleaned addresses table
SELECT
    COUNT(*) AS total_clean_addresses,
    SUM(Street IS NULL) AS missing_street,
    SUM(City IS NULL) AS missing_city,
    SUM(Country IS NULL) AS missing_country
FROM addresses_clean;


-- Exact duplicate address records were removed.
-- Blank street, city and country values were standardised as NULL.
-- Missing address details were kept rather than guessed.