--  Ranking customers by total loan exposure
WITH customer_loans AS (
    SELECT
        c.CustomerID,
        CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
        COUNT(l.LoanID) AS NumberOfLoans,
        SUM(l.PrincipalAmount) AS TotalLoanExposure
    FROM customers_clean c
    JOIN accounts_clean a
        ON c.CustomerID = a.CustomerID
    JOIN loans_clean l
        ON a.AccountID = l.AccountID
    GROUP BY
        c.CustomerID,
        c.FirstName,
        c.LastName
)

SELECT
    CustomerID,
    CustomerName,
    NumberOfLoans,
    ROUND(TotalLoanExposure, 2) AS TotalLoanExposure,
    RANK() OVER (
        ORDER BY TotalLoanExposure DESC
    ) AS LoanExposureRank
FROM customer_loans
ORDER BY LoanExposureRank;

--  Comparing each customer's loan exposure with their total account balance
WITH customer_balances AS (
    SELECT
        CustomerID,
        SUM(Balance) AS TotalBalance
    FROM accounts_clean
    GROUP BY CustomerID
),

customer_loans AS (
    SELECT
        a.CustomerID,
        SUM(l.PrincipalAmount) AS TotalLoanExposure
    FROM accounts_clean a
    JOIN loans_clean l
        ON a.AccountID = l.AccountID
    GROUP BY a.CustomerID
)

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    ROUND(cb.TotalBalance, 2) AS TotalBalance,
    ROUND(cl.TotalLoanExposure, 2) AS TotalLoanExposure,
    ROUND(
        cl.TotalLoanExposure / NULLIF(cb.TotalBalance, 0),
        2
    ) AS LoanToBalanceRatio
FROM customers_clean c
JOIN customer_balances cb
    ON c.CustomerID = cb.CustomerID
JOIN customer_loans cl
    ON c.CustomerID = cl.CustomerID
ORDER BY LoanToBalanceRatio DESC;

--  Now comparing overdue loan exposure with each customer's total balance
WITH customer_balances AS (
    SELECT
        CustomerID,
        SUM(Balance) AS TotalBalance
    FROM accounts_clean
    GROUP BY CustomerID
),

overdue_loans AS (
    SELECT
        a.CustomerID,
        COUNT(l.LoanID) AS NumberOfOverdueLoans,
        SUM(l.PrincipalAmount) AS OverdueLoanExposure
    FROM accounts_clean a
    JOIN loans_clean l
        ON a.AccountID = l.AccountID
    JOIN loan_statuses ls
        ON l.LoanStatusID = ls.LoanStatusID
    WHERE ls.StatusName = 'Overdue'
    GROUP BY a.CustomerID
)

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    ROUND(cb.TotalBalance, 2) AS TotalBalance,
    ol.NumberOfOverdueLoans,
    ROUND(ol.OverdueLoanExposure, 2) AS OverdueLoanExposure,
    ROUND(
        ol.OverdueLoanExposure / NULLIF(cb.TotalBalance, 0),
        2
    ) AS OverdueExposureToBalanceRatio
FROM customers_clean c
JOIN customer_balances cb
    ON c.CustomerID = cb.CustomerID
JOIN overdue_loans ol
    ON c.CustomerID = ol.CustomerID
ORDER BY OverdueExposureToBalanceRatio DESC;

-- Investigating loan exposure by customer type
SELECT
    ct.TypeName AS CustomerType,
    COUNT(DISTINCT c.CustomerID) AS CustomersWithLoans,
    COUNT(l.LoanID) AS NumberOfLoans,
    ROUND(SUM(l.PrincipalAmount), 2) AS TotalLoanExposure,
    ROUND(AVG(l.PrincipalAmount), 2) AS AverageLoanAmount,
    ROUND(SUM(
        CASE
            WHEN ls.StatusName = 'Overdue'
            THEN l.PrincipalAmount
            ELSE 0
        END
    ), 2) AS OverdueLoanExposure
FROM customers_clean c
JOIN customer_types ct
    ON c.CustomerTypeID = ct.CustomerTypeID
JOIN accounts_clean a
    ON c.CustomerID = a.CustomerID
JOIN loans_clean l
    ON a.AccountID = l.AccountID
JOIN loan_statuses ls
    ON l.LoanStatusID = ls.LoanStatusID
GROUP BY ct.TypeName
ORDER BY TotalLoanExposure DESC;


--  Ranking customers by overdue loan exposure
WITH overdue_exposure AS (
    SELECT
        c.CustomerID,
        CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
        COUNT(l.LoanID) AS NumberOfOverdueLoans,
        SUM(l.PrincipalAmount) AS OverdueLoanExposure
    FROM customers_clean c
    JOIN accounts_clean a
        ON c.CustomerID = a.CustomerID
    JOIN loans_clean l
        ON a.AccountID = l.AccountID
    JOIN loan_statuses ls
        ON l.LoanStatusID = ls.LoanStatusID
    WHERE ls.StatusName = 'Overdue'
    GROUP BY
        c.CustomerID,
        c.FirstName,
        c.LastName
)

SELECT
    CustomerID,
    CustomerName,
    NumberOfOverdueLoans,
    ROUND(OverdueLoanExposure, 2) AS OverdueLoanExposure,
    RANK() OVER (
        ORDER BY OverdueLoanExposure DESC
    ) AS OverdueExposureRank
FROM overdue_exposure
ORDER BY OverdueExposureRank;


--  Built customer loan risk summary
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(l.LoanID) AS NumberOfLoans,
    ROUND(SUM(l.PrincipalAmount), 2) AS TotalLoanExposure,

    COUNT(
        CASE
            WHEN ls.StatusName = 'Overdue'
            THEN l.LoanID
        END
    ) AS NumberOfOverdueLoans,

    ROUND(SUM(
        CASE
            WHEN ls.StatusName = 'Overdue'
            THEN l.PrincipalAmount
            ELSE 0
        END
    ), 2) AS OverdueLoanExposure,

    ROUND(
        100.0 * COUNT(
            CASE
                WHEN ls.StatusName = 'Overdue'
                THEN l.LoanID
            END
        ) / NULLIF(COUNT(l.LoanID), 0),
        2
    ) AS OverdueLoanPercentage

FROM customers_clean c
JOIN accounts_clean a
    ON c.CustomerID = a.CustomerID
JOIN loans_clean l
    ON a.AccountID = l.AccountID
JOIN loan_statuses ls
    ON l.LoanStatusID = ls.LoanStatusID

GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName

ORDER BY OverdueLoanExposure DESC;