-- Monthly transaction trends view 
CREATE OR REPLACE VIEW vw_monthly_transaction_trends AS
SELECT
    DATE_FORMAT(CleanTransactionDate, '%Y-%m') AS TransactionMonth,
    COUNT(TransactionID) AS NumberOfTransactions,
    ROUND(SUM(Amount), 2) AS TotalTransactionValue,
    ROUND(AVG(Amount), 2) AS AverageTransactionAmount
FROM transactions_clean
WHERE CleanTransactionDate IS NOT NULL
GROUP BY DATE_FORMAT(CleanTransactionDate, '%Y-%m');

-- loan status summary view
CREATE OR REPLACE VIEW vw_loan_status_summary AS

SELECT
    ls.StatusName AS LoanStatus,
    COUNT(l.LoanID) AS NumberOfLoans,
    ROUND(SUM(l.PrincipalAmount), 2) AS TotalLoanExposure,
    ROUND(AVG(l.PrincipalAmount), 2) AS AverageLoanAmount,
    ROUND(
        100.0 * COUNT(l.LoanID) /
        SUM(COUNT(l.LoanID)) OVER (),
        2
    ) AS PercentageOfLoans
FROM loans_clean l
JOIN loan_statuses ls
    ON l.LoanStatusID = ls.LoanStatusID
GROUP BY ls.StatusName;

-- Customer risk profile view
CREATE OR REPLACE VIEW vw_customer_risk_profile AS
WITH account_summary AS (
    SELECT
        CustomerID,
        COUNT(AccountID) AS NumberOfAccounts,
        SUM(Balance) AS TotalBalance,
        MIN(Balance) AS LowestAccountBalance,
        MAX(CASE WHEN Balance < 0 THEN 1 ELSE 0 END) AS NegativeBalanceFlag
    FROM accounts_clean
    GROUP BY CustomerID
),

loan_summary AS (
    SELECT
        a.CustomerID,
        COUNT(l.LoanID) AS NumberOfLoans,
        SUM(l.PrincipalAmount) AS TotalLoanExposure,

        COUNT(CASE
            WHEN ls.StatusName = 'Overdue' THEN l.LoanID
        END) AS NumberOfOverdueLoans,

        SUM(CASE
            WHEN ls.StatusName = 'Overdue'
            THEN l.PrincipalAmount
            ELSE 0
        END) AS OverdueLoanExposure

    FROM accounts_clean a
    JOIN loans_clean l
        ON a.AccountID = l.AccountID
    JOIN loan_statuses ls
        ON l.LoanStatusID = ls.LoanStatusID
    GROUP BY a.CustomerID
),

sent_summary AS (
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

received_summary AS (
    SELECT
        a.CustomerID,
        COUNT(t.TransactionID) AS TransactionsReceived,
        SUM(t.Amount) AS TotalAmountReceived
    FROM accounts_clean a
    JOIN transactions_clean t
        ON a.AccountID = t.AccountdestinationID
    GROUP BY a.CustomerID
),

risk_indicators AS (
    SELECT
        c.CustomerID,
        CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
        ct.TypeName AS CustomerType,

        COALESCE(a.NumberOfAccounts, 0) AS NumberOfAccounts,
        ROUND(COALESCE(a.TotalBalance, 0), 2) AS TotalBalance,
        ROUND(COALESCE(a.LowestAccountBalance, 0), 2) AS LowestAccountBalance,

        COALESCE(l.NumberOfLoans, 0) AS NumberOfLoans,
        ROUND(COALESCE(l.TotalLoanExposure, 0), 2) AS TotalLoanExposure,
        COALESCE(l.NumberOfOverdueLoans, 0) AS NumberOfOverdueLoans,
        ROUND(COALESCE(l.OverdueLoanExposure, 0), 2) AS OverdueLoanExposure,

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
        ) AS NetTransactionFlow,

        COALESCE(a.NegativeBalanceFlag, 0) AS NegativeBalanceFlag,

        CASE
            WHEN COALESCE(l.NumberOfOverdueLoans, 0) > 0 THEN 1
            ELSE 0
        END AS OverdueLoanFlag,

        CASE
            WHEN COALESCE(a.TotalBalance, 0) > 0
                 AND COALESCE(l.TotalLoanExposure, 0) > COALESCE(a.TotalBalance, 0)
            THEN 1
            ELSE 0
        END AS HighLoanExposureFlag,

        CASE
            WHEN COALESCE(s.AverageAmountSent, 0) > 0
                 AND COALESCE(s.LargestAmountSent, 0)
                     >= COALESCE(s.AverageAmountSent, 0) * 2
            THEN 1
            ELSE 0
        END AS LargeTransactionFlag

    FROM customers_clean c
    JOIN customer_types ct
        ON c.CustomerTypeID = ct.CustomerTypeID
    LEFT JOIN account_summary a
        ON c.CustomerID = a.CustomerID
    LEFT JOIN loan_summary l
        ON c.CustomerID = l.CustomerID
    LEFT JOIN sent_summary s
        ON c.CustomerID = s.CustomerID
    LEFT JOIN received_summary rvw_customer_risk_profile
        ON c.CustomerID = r.CustomerID
),

risk_scores AS (
    SELECT
        *,
        NegativeBalanceFlag
        + OverdueLoanFlag
        + HighLoanExposureFlag
        + LargeTransactionFlag AS RiskScore
    FROM risk_indicators
)

SELECT
    *,
    CASE
        WHEN RiskScore >= 3 THEN 'Higher Priority'
        WHEN RiskScore = 2 THEN 'Moderate Priority'
        ELSE 'Lower Priority'
    END AS RiskCategory
FROM risk_scores;


-- Branch-level risk activity summary 
CREATE OR REPLACE VIEW vw_branch_risk_summary AS

SELECT
    b.BranchID,
    b.BranchName,

    COUNT(t.TransactionID) AS NumberOfTransactions,
    ROUND(SUM(t.Amount), 2) AS TotalTransactionValue,
    ROUND(AVG(t.Amount), 2) AS AverageTransactionAmount,

    COUNT(DISTINCT CASE
        WHEN r.RiskCategory = 'Higher Priority'
        THEN r.CustomerID
    END) AS HigherPriorityCustomers,

    ROUND(SUM(CASE
        WHEN r.RiskCategory = 'Higher Priority'
        THEN t.Amount
        ELSE 0
    END), 2) AS HigherPriorityTransactionValue,

    COUNT(DISTINCT CASE
        WHEN r.OverdueLoanFlag = 1
        THEN r.CustomerID
    END) AS CustomersWithOverdueLoans,

    COUNT(DISTINCT CASE
        WHEN r.NegativeBalanceFlag = 1
        THEN r.CustomerID
    END) AS CustomersWithNegativeBalances

FROM transactions_clean t

JOIN branches b
    ON t.BranchID = b.BranchID

JOIN accounts_clean a
    ON t.AccountOriginID = a.AccountID

JOIN vw_customer_risk_profile r
    ON a.CustomerID = r.CustomerID

GROUP BY
    b.BranchID,
    b.BranchName;
-- side check
-- Checking the distribution of account statuses
SELECT
    ast.StatusName,
    COUNT(*) AS NumberOfAccounts
FROM accounts a
JOIN account_statuses ast
    ON a.AccountStatusID = ast.AccountStatusID
GROUP BY ast.StatusName
ORDER BY NumberOfAccounts DESC;

-- Comparing account balances by account status
SELECT
    ast.StatusName,
    COUNT(*) AS NumberOfAccounts,
    ROUND(SUM(a.Balance), 2) AS TotalBalance,
    ROUND(AVG(a.Balance), 2) AS AverageBalance,
    SUM(CASE WHEN a.Balance < 0 THEN 1 ELSE 0 END) AS NegativeBalanceAccounts
FROM accounts a
JOIN account_statuses ast
    ON a.AccountStatusID = ast.AccountStatusID
GROUP BY ast.StatusName;