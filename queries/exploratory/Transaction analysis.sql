-- Transaction Analysis

-- Summmar of outgoing transaction behaviour for each customer
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(t.TransactionID) AS NumberOfTransactions,
    ROUND(SUM(t.Amount), 2) AS TotalAmountSent,
    ROUND(AVG(t.Amount), 2) AS AverageTransactionAmount,
    ROUND(MAX(t.Amount), 2) AS LargestTransaction
FROM customers_clean c
JOIN accounts_clean a
    ON c.CustomerID = a.CustomerID
JOIN transactions_clean t
    ON a.AccountID = t.AccountOriginID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY TotalAmountSent DESC;


--  Ranking customers by transaction value and transaction frequency
WITH customer_transactions AS (
    SELECT
        c.CustomerID,
        CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
        COUNT(t.TransactionID) AS NumberOfTransactions,
        ROUND(SUM(t.Amount), 2) AS TotalAmountSent,
        ROUND(AVG(t.Amount), 2) AS AverageTransactionAmount,
        ROUND(MAX(t.Amount), 2) AS LargestTransaction
    FROM customers_clean c
    JOIN accounts_clean a
        ON c.CustomerID = a.CustomerID
    JOIN transactions_clean t
        ON a.AccountID = t.AccountOriginID
    GROUP BY
        c.CustomerID,
        c.FirstName,
        c.LastName
)

SELECT
    *,
    RANK() OVER (
        ORDER BY TotalAmountSent DESC
    ) AS AmountSentRank,
    RANK() OVER (
        ORDER BY NumberOfTransactions DESC
    ) AS TransactionFrequencyRank
FROM customer_transactions
ORDER BY AmountSentRank;

--  Summary of incoming transaction behaviour for each customer
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(t.TransactionID) AS NumberOfTransactionsReceived,
    ROUND(SUM(t.Amount), 2) AS TotalAmountReceived,
    ROUND(AVG(t.Amount), 2) AS AverageAmountReceived,
    ROUND(MAX(t.Amount), 2) AS LargestAmountReceived
FROM customers_clean c
JOIN accounts_clean a
    ON c.CustomerID = a.CustomerID
JOIN transactions_clean t
    ON a.AccountID = t.AccountdestinationID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY TotalAmountReceived DESC;

--  Comparing money sent and received by each customer
WITH money_sent AS (
    SELECT
        a.CustomerID,
        COUNT(t.TransactionID) AS TransactionsSent,
        SUM(t.Amount) AS TotalAmountSent
    FROM accounts_clean a
    JOIN transactions_clean t
        ON a.AccountID = t.AccountOriginID
    GROUP BY a.CustomerID
),

money_received AS (
    SELECT
        a.CustomerID,
        COUNT(t.TransactionID) AS TransactionsReceived,
        SUM(t.Amount) AS TotalAmountReceived
    FROM accounts_clean a
    JOIN transactions_clean t
        ON a.AccountID = t.AccountdestinationID
    GROUP BY a.CustomerID
)

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COALESCE(ms.TransactionsSent, 0) AS TransactionsSent,
    COALESCE(mr.TransactionsReceived, 0) AS TransactionsReceived,
    ROUND(COALESCE(ms.TotalAmountSent, 0), 2) AS TotalAmountSent,
    ROUND(COALESCE(mr.TotalAmountReceived, 0), 2) AS TotalAmountReceived,
    ROUND(
        COALESCE(mr.TotalAmountReceived, 0)
        - COALESCE(ms.TotalAmountSent, 0),
        2
    ) AS NetTransactionFlow
FROM customers_clean c
LEFT JOIN money_sent ms
    ON c.CustomerID = ms.CustomerID
LEFT JOIN money_received mr
    ON c.CustomerID = mr.CustomerID
ORDER BY NetTransactionFlow ASC;

--  Finding transactions that are much larger than each customer's average
WITH customer_transactions AS (
    SELECT
        c.CustomerID,
        CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
        t.TransactionID,
        t.CleanTransactionDate,
        t.Amount,
        AVG(t.Amount) OVER (
            PARTITION BY c.CustomerID
        ) AS CustomerAverageAmount
    FROM customers_clean c
    JOIN accounts_clean a
        ON c.CustomerID = a.CustomerID
    JOIN transactions_clean t
        ON a.AccountID = t.AccountOriginID
)

SELECT
    CustomerID,
    CustomerName,
    TransactionID,
    CleanTransactionDate,
    ROUND(Amount, 2) AS TransactionAmount,
    ROUND(CustomerAverageAmount, 2) AS CustomerAverageAmount,
    ROUND(Amount / CustomerAverageAmount, 2) AS TimesAboveAverage
FROM customer_transactions
WHERE Amount >= CustomerAverageAmount * 2
ORDER BY TimesAboveAverage DESC;

--  Monthly transaction activity summary
SELECT
    DATE_FORMAT(CleanTransactionDate, '%Y-%m') AS TransactionMonth,
    COUNT(TransactionID) AS NumberOfTransactions,
    ROUND(SUM(Amount), 2) AS TotalTransactionValue,
    ROUND(AVG(Amount), 2) AS AverageTransactionAmount
FROM transactions_clean
WHERE CleanTransactionDate IS NOT NULL
GROUP BY DATE_FORMAT(CleanTransactionDate, '%Y-%m')
ORDER BY TransactionMonth;

--  Comparing monthly transaction value with the previous month
WITH monthly_transactions AS (
    SELECT
        DATE_FORMAT(CleanTransactionDate, '%Y-%m') AS TransactionMonth,
        COUNT(TransactionID) AS NumberOfTransactions,
        SUM(Amount) AS TotalTransactionValue
    FROM transactions_clean
    WHERE CleanTransactionDate IS NOT NULL
    GROUP BY DATE_FORMAT(CleanTransactionDate, '%Y-%m')
)

SELECT
    TransactionMonth,
    NumberOfTransactions,
    ROUND(TotalTransactionValue, 2) AS TotalTransactionValue,

    ROUND(
        LAG(TotalTransactionValue) OVER (
            ORDER BY TransactionMonth
        ), 2
    ) AS PreviousMonthValue

FROM monthly_transactions
ORDER BY TransactionMonth;


WITH monthly_transactions AS (
    SELECT
        DATE_FORMAT(CleanTransactionDate, '%Y-%m') AS TransactionMonth,
        COUNT(TransactionID) AS NumberOfTransactions,
        SUM(Amount) AS TotalTransactionValue
    FROM transactions_clean
    WHERE CleanTransactionDate IS NOT NULL
    GROUP BY DATE_FORMAT(CleanTransactionDate, '%Y-%m')
),

monthly_comparison AS (
    SELECT
        TransactionMonth,
        NumberOfTransactions,
        TotalTransactionValue,
        LAG(TotalTransactionValue) OVER (
            ORDER BY TransactionMonth
        ) AS PreviousMonthValue
    FROM monthly_transactions
)

SELECT
    TransactionMonth,
    NumberOfTransactions,
    ROUND(TotalTransactionValue, 2) AS TotalTransactionValue,
    ROUND(PreviousMonthValue, 2) AS PreviousMonthValue,
    ROUND(
        ((TotalTransactionValue - PreviousMonthValue)
        / PreviousMonthValue) * 100,
        2
    ) AS MonthlyPercentageChange
FROM monthly_comparison
ORDER BY TransactionMonth;


-- Customer transaction behaviour summary
WITH sent AS (
    SELECT
        a.CustomerID,
        COUNT(t.TransactionID) AS TransactionsSent,
        SUM(t.Amount) AS TotalAmountSent,
        AVG(t.Amount) AS AverageAmountSent,
        MAX(t.Amount) AS LargestAmountSent
    FROM accounts_clean a
    JOIN transactions_clean t
        ON a.AccountID = t.AccountOriginID
    GROUP BY a.CustomerID
),

received AS (
    SELECT
        a.CustomerID,
        COUNT(t.TransactionID) AS TransactionsReceived,
        SUM(t.Amount) AS TotalAmountReceived
    FROM accounts_clean a
    JOIN transactions_clean t
        ON a.AccountID = t.AccountdestinationID
    GROUP BY a.CustomerID
)

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COALESCE(s.TransactionsSent, 0) AS TransactionsSent,
    COALESCE(r.TransactionsReceived, 0) AS TransactionsReceived,
    ROUND(COALESCE(s.TotalAmountSent, 0), 2) AS TotalAmountSent,
    ROUND(COALESCE(r.TotalAmountReceived, 0), 2) AS TotalAmountReceived,
    ROUND(COALESCE(s.AverageAmountSent, 0), 2) AS AverageAmountSent,
    ROUND(COALESCE(s.LargestAmountSent, 0), 2) AS LargestAmountSent,
    ROUND(
        COALESCE(r.TotalAmountReceived, 0)
        - COALESCE(s.TotalAmountSent, 0),
        2
    ) AS NetTransactionFlow
FROM customers_clean c
LEFT JOIN sent s
    ON c.CustomerID = s.CustomerID
LEFT JOIN received r
    ON c.CustomerID = r.CustomerID
ORDER BY TotalAmountSent DESC;