

-- How much money does each customer hold + how many accounts do they have?
--  account balances summary for each customer
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(a.AccountID) AS NumberOfAccounts,
    ROUND(SUM(a.Balance), 2) AS TotalBalance,
    ROUND(AVG(a.Balance), 2) AS AverageBalance,
    ROUND(MIN(a.Balance), 2) AS LowestAccountBalance,
    ROUND(MAX(a.Balance), 2) AS HighestAccountBalance
FROM customers_clean c
LEFT JOIN accounts_clean a
    ON c.CustomerID = a.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY TotalBalance DESC;


-- customers with at least one negative account balance
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(a.AccountID) AS NumberOfAccounts,
    ROUND(SUM(a.Balance), 2) AS TotalBalance,
    ROUND(MIN(a.Balance), 2) AS LowestAccountBalance
    
FROM customers_clean c
JOIN accounts_clean a
    ON c.CustomerID = a.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
HAVING MIN(a.Balance) < 0
ORDER BY LowestAccountBalance ASC;

-- 10 customers have at least one account with a negative balance.
-- Some still have a high total balance, so a negative balance will be
-- treated as one risk indicator rather than evidence of high risk on its own.

-- Comparing negative balance accounts by customer type
SELECT
    ct.TypeName,
    COUNT(DISTINCT c.CustomerID) AS TotalCustomers,
    COUNT(DISTINCT CASE
        WHEN a.Balance < 0 THEN c.CustomerID
    END) AS CustomersWithNegativeBalance,
    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN a.Balance < 0 THEN c.CustomerID
        END) / COUNT(DISTINCT c.CustomerID),
        2
    ) AS NegativeBalancePercentage
FROM customers_clean c
JOIN customer_types ct
    ON c.CustomerTypeID = ct.CustomerTypeID
LEFT JOIN accounts_clean a
    ON c.CustomerID = a.CustomerID
GROUP BY ct.TypeName
ORDER BY NegativeBalancePercentage DESC;


-- Summary of loan exposure for each customer
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(l.LoanID) AS NumberOfLoans,
    ROUND(SUM(l.PrincipalAmount), 2) AS TotalLoanAmount,
    ROUND(AVG(l.PrincipalAmount), 2) AS AverageLoanAmount,
    ROUND(MAX(l.PrincipalAmount), 2) AS LargestLoan
FROM customers_clean c
JOIN accounts_clean a
    ON c.CustomerID = a.CustomerID
JOIN loans_clean l
    ON a.AccountID = l.AccountID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY TotalLoanAmount DESC;


-- number and value of loans by status
SELECT
    ls.StatusName,
    COUNT(l.LoanID) AS NumberOfLoans,
    ROUND(SUM(l.PrincipalAmount), 2) AS TotalLoanAmount,
    ROUND(AVG(l.PrincipalAmount), 2) AS AverageLoanAmount
FROM loans_clean l
JOIN loan_statuses ls
    ON l.LoanStatusID = ls.LoanStatusID
GROUP BY ls.StatusName
ORDER BY TotalLoanAmount DESC;


--  Finding customers with overdue loans
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(l.LoanID) AS NumberOfOverdueLoans,
    ROUND(SUM(l.PrincipalAmount), 2) AS OverdueLoanAmount
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
ORDER BY OverdueLoanAmount DESC;

-- Finding customers with both overdue loans and negative account balances = 0
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    ROUND(SUM(a.Balance), 2) AS TotalBalance,
    ROUND(MIN(a.Balance), 2) AS LowestAccountBalance,
    COUNT(DISTINCT CASE
        WHEN ls.StatusName = 'Overdue' THEN l.LoanID
    END) AS NumberOfOverdueLoans,
    ROUND(SUM(CASE
        WHEN ls.StatusName = 'Overdue' THEN l.PrincipalAmount
        ELSE 0
    END), 2) AS OverdueLoanAmount
FROM customers_clean c
JOIN accounts_clean a
    ON c.CustomerID = a.CustomerID
LEFT JOIN loans_clean l
    ON a.AccountID = l.AccountID
LEFT JOIN loan_statuses ls
    ON l.LoanStatusID = ls.LoanStatusID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
HAVING MIN(a.Balance) < 0
   AND COUNT(DISTINCT CASE
       WHEN ls.StatusName = 'Overdue' THEN l.LoanID
   END) > 0
ORDER BY OverdueLoanAmount DESC;


-- Comparison of overdue loans by customer type
SELECT
    ct.TypeName,
    COUNT(DISTINCT c.CustomerID) AS TotalCustomers,
    COUNT(DISTINCT CASE
        WHEN ls.StatusName = 'Overdue' THEN c.CustomerID
    END) AS CustomersWithOverdueLoans,
    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN ls.StatusName = 'Overdue' THEN c.CustomerID
        END)
        / COUNT(DISTINCT c.CustomerID),
        2
    ) AS OverdueCustomerPercentage
FROM customers_clean c
JOIN customer_types ct
    ON c.CustomerTypeID = ct.CustomerTypeID
LEFT JOIN accounts_clean a
    ON c.CustomerID = a.CustomerID
LEFT JOIN loans_clean l
    ON a.AccountID = l.AccountID
LEFT JOIN loan_statuses ls
    ON l.LoanStatusID = ls.LoanStatusID
GROUP BY ct.TypeName
ORDER BY OverdueCustomerPercentage DESC;