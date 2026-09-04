-- Loan Table Cleaning

SELECT 
COUNT(*) AS Total_loans,
SUM(loanID IS NULL) AS missing_loan_id,
SUM(AccountID IS NULL) AS missing_account_ID,
SUM(Principalamount IS NULL) AS missing_principal_amount,
SUM(InterestRate IS NULL) AS missing_interest_rate,
SUM(StartDate IS NULL) AS missing_start_date,
SUM(EstimatedEndDate IS NULL) AS missing_end_date,
SUM(LoanStatusID IS NULL) AS missing_loan_status
FROM loans;

-- Identify Duplicate Loan IDs
SELECT
    LoanID,
    COUNT(*) AS loan_count
FROM loans
GROUP BY LoanID
HAVING COUNT(*) > 1;

--  Investigating Duplicate Loan Records
SELECT *
FROM loans
WHERE LoanID IN (
    SELECT LoanID
    FROM loans
    GROUP BY LoanID
    HAVING COUNT(*) > 1
)
ORDER BY LoanID;

-- Created Clean Loans Table without Duplicates
CREATE TABLE loans_clean AS

WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LoanID
            ORDER BY LoanID
        ) AS row_num
    FROM loans
)

SELECT
    LoanID,
    AccountID,
    LoanStatusID,
    PrincipalAmount,
    InterestRate,
    StartDate,
    EstimatedEndDate
FROM deduplicated
WHERE row_num = 1;

-- Validated duplicate records
SELECT
    LoanID,
    COUNT(*) AS loan_count
FROM loans_clean
GROUP BY LoanID
HAVING COUNT(*) > 1;

SELECT
    (SELECT COUNT(*) FROM loans) AS raw_loans,
    (SELECT COUNT(*) FROM loans_clean) AS clean_loans;
    -- duplicates have been removed
    
    -- Check Missing and Blank Loan Dates
SELECT
    SUM(StartDate IS NULL) AS null_start_dates,
    SUM(TRIM(StartDate) = '') AS blank_start_dates,
    SUM(EstimatedEndDate IS NULL) AS null_end_dates,
    SUM(TRIM(EstimatedEndDate) = '') AS blank_end_dates
FROM loans_clean;

-- Validate Missing Loan Dates
SELECT
    SUM(StartDate IS NULL) AS null_start_dates,
    SUM(TRIM(StartDate) = '') AS blank_start_dates,
    SUM(EstimatedEndDate IS NULL) AS null_end_dates,
    SUM(TRIM(EstimatedEndDate) = '') AS blank_end_dates
FROM loans_clean;


-- Standardise Blank Loan Dates to NULL
SET SQL_SAFE_UPDATES = 0;

UPDATE loans_clean
SET StartDate = NULL
WHERE TRIM(StartDate) = '';

UPDATE loans_clean
SET EstimatedEndDate = NULL
WHERE TRIM(EstimatedEndDate) = '';

SET SQL_SAFE_UPDATES = 1;


-- Profile Loan Start Date Formats
SELECT
    CASE
        WHEN StartDate REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
            THEN 'YYYY/MM/DD'

        WHEN StartDate REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN 'DD/MM or MM/DD'

        WHEN StartDate REGEXP '^[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}$'
            THEN 'Dot Format'

        WHEN StartDate LIKE '%T%'
            THEN 'ISO Timestamp'

        WHEN StartDate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
            THEN 'Standard Timestamp'

        WHEN StartDate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN 'YYYY-MM-DD'

        ELSE 'Other'
    END AS date_format,
    COUNT(*) AS number_of_records
FROM loans_clean
WHERE StartDate IS NOT NULL
GROUP BY date_format;


-- Profile Estimated End Date Formats
SELECT
    CASE
        WHEN EstimatedEndDate REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
            THEN 'YYYY/MM/DD'

        WHEN EstimatedEndDate REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN 'DD/MM or MM/DD'

        WHEN EstimatedEndDate REGEXP '^[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}$'
            THEN 'Dot Format'

        WHEN EstimatedEndDate LIKE '%T%'
            THEN 'ISO Timestamp'

        WHEN EstimatedEndDate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} '
            THEN 'Standard Timestamp'

        WHEN EstimatedEndDate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN 'YYYY-MM-DD'

        ELSE 'Other'
    END AS date_format,
    COUNT(*) AS number_of_records
FROM loans_clean
WHERE EstimatedEndDate IS NOT NULL
GROUP BY date_format;


-- Created Loan Date Columns
ALTER TABLE loans_clean
ADD COLUMN CleanStartDate DATE,
ADD COLUMN CleanEstimatedEndDate DATE;


--  Standardise Loan Date Formats
SET SQL_SAFE_UPDATES = 0;

UPDATE loans_clean
SET CleanStartDate = STR_TO_DATE(
        LEFT(StartDate, 10),
        '%Y-%m-%d'
    ),
    CleanEstimatedEndDate = STR_TO_DATE(
        LEFT(EstimatedEndDate, 10),
        '%Y-%m-%d'
    );

SET SQL_SAFE_UPDATES = 1;


-- Validate Standardised Loan Dates
SELECT
    StartDate,
    CleanStartDate,
    EstimatedEndDate,
    CleanEstimatedEndDate
FROM loans_clean
LIMIT 20;

-- Checking for Future Loan start Date/ Estimated end Dates
SELECT
    LoanID,
    AccountID,
    CleanStartDate
FROM loans_clean
WHERE CleanStartDate > CURDATE();


SELECT
    LoanID,
    AccountID,
    CleanEstimatedEndDate
FROM loans_clean
WHERE CleanEstimatedEndDate > CURDATE();

-- End dates earlier than start dates
--  Check was done to see if End Dates Earlier Than Start Dates

SELECT
    LoanID,
    CleanStartDate,
    CleanEstimatedEndDate
FROM loans_clean
WHERE CleanEstimatedEndDate < CleanStartDate;

-- LoanID 400080 has a later start date than estimated end date which should not be possible

--  Investigating Invalid Loan Date Sequence and comparing to raw data
SELECT *
FROM loans_clean
WHERE LoanID = 400080;

SELECT *
FROM loans
WHERE LoanID = 400080;

-- Set Invalid Loan Date Sequence to NULL
SET SQL_SAFE_UPDATES = 0;

UPDATE loans_clean
SET CleanStartDate = NULL,
    CleanEstimatedEndDate = NULL
WHERE LoanID = 400080;

SET SQL_SAFE_UPDATES = 1;

-- Validate Invalid Date Cleaning
SELECT
    LoanID,
    StartDate,
    CleanStartDate,
    EstimatedEndDate,
    CleanEstimatedEndDate
FROM loans_clean
WHERE LoanID = 400080;

-- Profile Loan Financial Values
SELECT
    MIN(PrincipalAmount) AS minimum_principal,
    MAX(PrincipalAmount) AS maximum_principal,
    AVG(PrincipalAmount) AS average_principal,
    SUM(PrincipalAmount <= 0) AS non_positive_principal_count,
    MIN(InterestRate) AS minimum_interest_rate,
    MAX(InterestRate) AS maximum_interest_rate,
    AVG(InterestRate) AS average_interest_rate,
    SUM(InterestRate < 0) AS negative_interest_rate_count
FROM loans_clean;


SELECT
    LoanID,
    AccountID,
    PrincipalAmount,
    InterestRate
FROM loans_clean
WHERE PrincipalAmount <= 0
   OR InterestRate < 0;
   
   -- Checking for any invalid Loan Status IDs
SELECT
    l.LoanID,
    l.LoanStatusID
FROM loans_clean l
LEFT JOIN loan_statuses ls
    ON l.LoanStatusID = ls.LoanStatusID
WHERE ls.LoanStatusID IS NULL;

-- Loans Cleaning Validation
SELECT
    COUNT(*) AS total_clean_loans,
    SUM(CleanStartDate IS NULL) AS missing_or_unresolved_start_dates,
    SUM(CleanEstimatedEndDate IS NULL) AS missing_or_unresolved_end_dates,
    SUM(PrincipalAmount <= 0) AS invalid_principal_values,
    SUM(InterestRate < 0) AS invalid_interest_rates
FROM loans_clean;

-- Final check of the cleaned loans table
-- 330 loan records remain after removing duplicates.
-- 6 loans were missing their start and end dates.
-- 1 loan had an end date earlier than its start date, so the cleaned
-- dates were left as NULL rather than guessing what the correct dates were.
-- No issues were found with principal amounts or interest rates.

