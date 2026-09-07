# Which customers show signs of financial risk, what behaviours distinguish them, and where should the bank prioritise monitoring?
> *One sentence. What did you analyze, build, or solve - and why does it matter?*

---

## ⚙️ Project Type Flags
> *Check what applies. This helps reviewers and collaborators understand the nature of the work at a glance. Delete this block before publishing.*

- [x] Exploratory Data Analysis (EDA)
- [x] SQL Analysis / Querying
- [x] Dashboard / Data Visualization
- [ ] Data Pipeline / ETL
- [ ] Predictive Modelling / Machine Learning
- [x] Data Cleaning / Wrangling
- [x] End-to-End (multiple of the above)
- [ ] Other: ___________

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Objectives](#2-objectives)
3. [Project Scope & Tools](#3-project-scope--tools)
4. [Repository Structure](#4-repository-structure)
5. [Data Workflow](#5-data-workflow)
6. [Data Model & Schema](#6-data-model--schema)
7. [ERD - Entity Relationship Diagram](#7-erd--entity-relationship-diagram) *(SQL projects)*
8. [Analysis & Metrics](#8-analysis--metrics)
9. [Key Insights](#9-key-insights)
10. [Recommendations](#10-recommendations)
11. [Assumptions & Limitations](#11-assumptions--limitations)
12. [Future Enhancements](#12-future-enhancements)
13. [Deliverables](#13-deliverables)
14. [Author](#14-author)

---

## 1. Project Overview

<!--
  Write 3–5 sentences in plain language.
  Cover: context → problem → approach → outcome.
  Read it out loud. If it sounds like a form - rewrite it.

  WHAT GOOD LOOKS LIKE:
  "A mid-size retail business was seeing inconsistent revenue across
  its regional stores but couldn't identify the root cause. This project
  explored 18 months of transaction data across five regions to determine
  whether underperformance was driven by sales volume, pricing, or return
  rates. The analysis revealed that one region's gap was almost entirely
  explained by an unusually high return rate on a single product category -
  a finding invisible in the company's top-level reporting."

  WHAT TO AVOID:
  "This project analyzes sales data to find trends and insights."
  (Too vague. Could describe 10,000 projects. Describes none of them.)
-->

**Context:** [The business, research, or personal situation that motivated this project.]

**Problem Statement:** [The specific question or challenge you were addressing.]

**Approach:** [In 1–2 sentences - how did you tackle it?]

**Outcome:** [What did you produce or discover?]

---

## 2. Objectives

<!--
  Write objectives that are specific enough to succeed or fail.
  Use action-oriented verbs: Identify, Determine, Quantify, Build, Evaluate.

  WHAT GOOD LOOKS LIKE:
  ✅ "Determine whether customer churn rate correlates with support ticket volume."
  ✅ "Identify the top three revenue-driving product categories across all regions."
  ✅ "Build a reproducible pipeline that ingests and cleans daily sales exports."

  WHAT TO AVOID:
  ❌ "Explore the data."
  ❌ "Gain insights."
  ❌ "Understand trends."
  (These can't fail - which means they can't succeed either.)
-->

- **Primary Objective:** [The main thing you set out to do]
- **Secondary Objective 1:** [Supporting goal]
- **Secondary Objective 2:** [Supporting goal]
- **Secondary Objective 3:** [Remove if not applicable]

> 💡 *Every analysis decision in this project traces back to one of these objectives.*

---

## 3. Project Scope & Tools


-->

| Dimension | Details |
|-----------|---------|
| **In Scope** | Customer, account, loan and transaction data. Analysis covers account balances, loan exposure, overdue loans, transaction behaviour and customer monitoring priority. |
| **Out of Scope** | Predictive risk modelling, forecasting future customer behaviour and estimating financial losses. The project uses a rule-based monitoring framework and the dataset does not provide confirmed financial loss outcomes. |
| **Time Period** | Transaction Data ranges from 2020-2025; however, monthly transaction trend analysis is limited to 2020-2023 because transaction records are incomplete after February 2024. Customer and loan analysis used all valid available records.|
| **Granularity** | Individual transactions, loans and accounts, summarised by customer and branch. |

### Tools & Technologies

<!--
  List only what you actually used on this project.
  This is not your skills section - it's the project's technical context.
-->

| Category | Tool(s) Used |
|----------|-------------|
| Data Storage |  CSV files |
| Data Processing | SQL |
| Analysis | custom SQL queries |
| Visualization |  Power BI |
| Version Control | GitHub] |
| Documentation | [e.g., Markdown, Notion] |


---

## 4. Repository Structure

```
[project-root]/
│
├── data/
│   ├── raw/                  # Original, unmodified source data - never edited
│   ├── processed/            # Cleaned and transformed data
│   └── external/             # Reference data, lookup tables, third-party files
│
├── notebooks/                # Jupyter, R Markdown, or Colab notebooks
│
├── scripts/                  # Reusable .py, .R, or .sh processing files
│
├── queries/                  # SQL files (retain this folder for SQL-heavy projects)
│   ├── exploratory/          # Ad-hoc or investigative queries
│   ├── transformations/      # Cleaning and reshaping logic
│   └── final/                # Production-ready or presentation queries
│
├── reports/                  # Final outputs: PDFs, slide decks, Word docs
│
├── visuals/                  # Exported charts, dashboard screenshots, ERD diagrams
│
├── docs/                     # Data dictionaries, schema notes, reference material
│
├── project_metadata.yml      # Machine-readable metadata (optional)
└── README.md                 # You are here
```

> ⚠️ *Delete folders you didn't use. An empty folder is worse than no folder.*
> SQL-heavy projects: keep `queries/`. Analysis-only projects: keep `notebooks/`. Both? Keep both.

---

## 5. Data Workflow

<!--
  Show how data moved through your project - from source to output.
  Every transformation decision should be traceable here.

  WHAT GOOD LOOKS LIKE:
  1. Source: "Monthly CSV exports pulled from the internal POS system.
              Five files, one per region, covering Jan 2023–Jun 2024."
  2. Ingestion: "Loaded into Python using pandas. Files concatenated into
                 a single dataframe (approx. 340,000 rows)."
  3. Cleaning: "Removed 1.2% of rows with null transaction IDs.
                Standardised date formats across regional files.
                Resolved product category naming inconsistencies (3 variants → 1)."
  4. Transformation: "Created a returns_rate field at product-category level.
                      Aggregated to weekly and regional grain for trend analysis."
  5. Analysis: "Descriptive statistics, regional comparison, return rate
                segmentation by product category."
  6. Output: "Summary report (PDF), annotated notebook, processed CSV."

  WHAT TO AVOID:
  ❌ "Data was cleaned and analysed." (No chain. No decisions. No trust.)
-->

```
[Data Source(s)]
      ↓
[Ingestion / Collection Method]
      ↓
[Cleaning & Transformation]
      ↓
[Analysis / Modelling / Querying]
      ↓
[Output / Visualisation / Reporting]
```

1. **Source:** This project used a finance dataset from Kaggle containing 10 CSV files covering customers, accounts, loans, transactions, addresses, branches and supporting lookup tables. The main analytical tables included 1,111 customer records, 1667 account records, 333 loan records and 12,319 transaction records.
2. **Ingestion:** The CSV files were imported into MySQL; the original tables were kept as raw data, while separate tables were made for the tables requiring data corrections.
3. **Cleaning:** Each table was assessed for duplicate records, missing values, inconsistent date formats, invalid values and relationship integrity. Removed exact duplicates, reducing customers from 1,111 to 1,100, accounts from 1,667 to 1,651, loans from 333 to 330 and transactions from 12,319 to 12,296. Blank values were standardised to NULL, mixed data formats were converted into consistent Date fields and unresolved or invalid dates were retained as NULL rather than inferred. Negative account balances were kept as they represented plausible financial behaviour rather than data errors.
4. **Transformation:** Cleaned customer, account, loan and transaction data were joined and aggregated to the customer level. Created metrics for total account balance, loan exposure, overdue loan exposure, transaction frequency, and value. In addition, four monitoring indicators were derived: negative account, overdue loan presence, loan exposure exceeding positive account balances and a largest outgoing transaction at least twice a customer's average outgoing transaction.
5. **Analysis:** SQL was used to compare customer types, investigate account balances and transaction behaviour, assess loan exposure and identify overdue loans. Plus, the analysis resulted in a combination of financial risk indicators, the four indicators were joined into a rule based monitoring score ranking customers with scores of 0-1 as Lower Priority, 2 as Moderate Priority, and 3-4 as Higher Priority. This formula is intended to prioritise customers for further review  rather than making a prediction.
6. **Output:** Four SQL views were created as a reporting layer for Power BI: a customer risk profile, monthly transaction trends, loan status summary and branch risk-activity summary. These views feed a two-page Power BI report consisting of a high-level Risk Overview and a Risk Investigation page for examining individual customers and branch-level activity.

---

## 6. Data Model & Schema

<!--
  Define your fields so that someone reading your analysis can follow along
  without digging through your code.

  WHAT GOOD LOOKS LIKE (one row example):
  | transaction_id | string | Unique identifier per sales transaction | TXN-00482 |
  | return_flag    | boolean | Whether the transaction included a return | TRUE |
  | region_code    | string | Two-letter identifier for store region | "NE" |

  WHAT TO AVOID:
  ❌ Skipping this section because "the field names are self-explanatory."
     They're not. Not to a reviewer. Not to you in six months.

  📌 FOR SQL PROJECTS: If you have multiple tables, create one block per table.
     Describe join keys and relationships here. Your ERD (Section 7) will
     visualise what this section describes in text.

  📌 FOR NON-SQL PROJECTS: Describe the shape of your dataset informally
     if a formal schema doesn't apply. Even one paragraph is more helpful than nothing.
-->

### Dataset / Table: `Customers_clean`

| Field Name | Data Type | Description | Example Value |
|------------|-----------|-------------|---------------|
|`CustomerID` | INT | Unique identifier for each customer | 10000 |
| `FirstName` | VARCHAR | Customer's first name | Maybell |
| `LastName` | VARCHAR | Customer's last name | Acevedo |
| `DateOfBirth` | VARCHAR | Original date of birth from the source data | 1979-12-27 00:00:00 |
| `CustomerTypeID` | INT | Identifies the customer's type | 2 |
| `AddressID` | INT | Links the customer to their address | 1021 |
| `CleanDateOfBirth` | DATE | Standardised date of birth used for analysis | 1979-12-27 |

> **Row count (approx.):** 1,100
> **Key join / relationship:**  `CustomerTypeID` → `customer_types.CustomerTypeID`; `AddressID` → `addresses_clean.AddressID`


### Dataset / Table: `accounts_clean`

| Field Name | Data Type | Description | Example Value |
|------------|-----------|-------------|---------------|
| `AccountID` | INT | Unique identifier for each account | 200000 |
| `CustomerID` | INT | Identifies the customer who owns the account | 10330 |
| `AccountTypeID` | INT | Identifies the type of account | 2 |
| `AccountStatusID` | INT | Identifies the current status of the account | 1 |
| `Balance` | DECIMAL | Account balance | 35794.37 |
| `OpeningDate` | VARCHAR | Original account opening date | 2018-04-06 00:00:00 |
| `CleanOpeningDate` | DATE | Standardised account opening date used for analysis | 2018-04-06 |

> **Row count (approx.):** 1,651
> **Account opening date range:** 2018-01-03 – 2026-07-06 
> **Key join/relationship:** `CustomerID` → `customers_clean.CustomerID`; `AccountTypeID` → `account_types.AccountTypeID`


### Dataset / Table: `loans_clean`

| Field Name | Data Type | Description | Example Value |
|------------|-----------|-------------|---------------|
| `LoanID` | INT | Unique identifier for each loan | 400000 |
| `AccountID` | INT | Identifies the account associated with the loan | 201241 |
| `LoanStatusID` | INT | Identifies the current loan status | 3 |
| `PrincipalAmount` | DECIMAL | Original principal amount of the loan | 52255.85 |
| `InterestRate` | DECIMAL | Interest rate associated with the loan | 0.1283 |
| `StartDate` | VARCHAR | Original loan start date | 2021-04-05 00:00:00 |
| `EstimatedEndDate` | VARCHAR | Original estimated loan end date | 2022-08-16 00:00:00 |
| `CleanStartDate` | DATE | Standardised loan start date | 2021-04-05 |
| `CleanEstimatedEndDate` | DATE | Standardised estimated loan end date | 2022-08-16 |


> **Row count (approx.):** 330
> **Loan start date range:** 2021-01-01 – 2026-08-29  
> **Key join/relationship:** `AccountID` → `accounts_clean.AccountID`; `LoanStatusID` → `loan_statuses.LoanStatusID`

### Dataset / Table: `transactions_clean`

| Field Name | Data Type | Description | Example Value |
|------------|-----------|-------------|---------------|
| `TransactionID` | BIGINT | Unique identifier for each transaction | 3000001 |
| `AccountOriginID` | BIGINT | Account from which the transaction originated | 201103 |
| `AccountdestinationID` | BIGINT | Account receiving the transaction | 200262 |
| `TransactionTypeID` | BIGINT | Identifies the type of transaction | 3 |
| `TransactionDate` | VARCHAR | Original transaction date and time | 2023-05-12 02:00:00 |
| `Amount` | DECIMAL | Value of the transaction | 4713.48 |
| `BranchID` | BIGINT | Identifies the branch associated with the transaction | 23 |
| `Description` | VARCHAR | Transaction description | Transaction 1 |
| `CleanTransactionDate` | DATE | Standardised transaction date used for analysis | 2023-05-12 |

> **Row count (approx.):** 12,296
> **Date range:** 2020-01-01 – 2026-08-28 
> **Key join/relationship:** `AccountOriginID` and `AccountdestinationID` → `accounts_clean.AccountID`; `TransactionTypeID` → `transaction_types.TransactionTypeID`; `BranchID` → `branches.BranchID`


### Dataset / Table: `addresses_clean`

| Field Name | Data Type | Description | Example Value |
|------------|-----------|-------------|---------------|
| `AddressID` | INT | Unique identifier for each address | 1 |
| `Street` | VARCHAR | Street associated with the address | Van Ness |
| `City` | VARCHAR | City associated with the address | Vineland |
| `Country` | VARCHAR | Country associated with the address | United States |

> **Row count (approx.):** 1210
> **Key join/relationship:**  `AddressID` is referenced by customer and branch records.

### Dataset / Table: `branches`

| Field Name | Data Type | Description | Example Value |
|------------|-----------|-------------|---------------|
| `BranchID` | INT | Unique identifier for each branch | 1 |
| `BranchName` | VARCHAR | Name of the branch | Branch 1 |
| `AddressID` | INT | Links the branch to its address | 733 |

> **Row count:** 50  
> **Key relationship:** `AddressID` → `addresses_clean.AddressID`

### Lookup Table: `customer_types`

Maps each `CustomerTypeID` to a customer category:

| CustomerTypeID | TypeName |
|---:|---|
| 1 | Individual |
| 2 | Small Business |
| 3 | Large Enterprise |

> **Row count:** 3  
> **Key relationship:** `CustomerTypeID` → `customers_clean.CustomerTypeID`

### Lookup Table: `transaction_types`

Maps each transaction to its transaction type.

| TransactionTypeID | TypeName |
|---:|---|
| 1 | Deposit |
| 2 | Withdrawal |
| 3 | Transfer |
| 4 | Payment |

> **Row count:** 4  
> **Key relationship:** `transactions_clean.TransactionTypeID` → `transaction_types.TransactionTypeID`

### Lookup Table: `loan_statuses`

Reference table defining the possible status of a loan.

| LoanStatusID | StatusName |
|---:|---|
| 1 | Active |
| 2 | Paid Off |
| 3 | Overdue |

> **Row count:** 3  
> **Key relationship:** `loans_clean.LoanStatusID` → `loan_statuses.LoanStatusID`

### Lookup Table: `account_types`

Reference table defining the different types of customer accounts.

| AccountTypeID | TypeName |
|---:|---|
| 1 | Checking |
| 2 | Savings |
| 3 | Payroll |
| 4 | Business |
| 5 | Youth |

> **Row count:** 5  
> **Key relationship:** `accounts_clean.AccountTypeID` → `account_types.AccountTypeID`

### Lookup Table: `account_statuses`


| AccountStatusID | StatusName |
|---:|---|
| 1 | Active |
| 2 | Inactive |
| 3 | Closed |

> **Row count:** 3
> **Key relationship:** `accounts_clean.AccountStatusID` → `account_statuses.AccountStatusID`
---

## 7. ERD - Entity Relationship Diagram




### Option A - Embedded Image
![ERD Diagram](visuals/erd.png)
*Eleven-table finance schema — customers, accounts, loans and transactions connected through shared IDs and supporting reference tables.*

---

**Table Relationships Summary:**

| Relationship | Join Key | Type |
|-------------|----------|------|
| `accounts_clean` → `customers_clean` | `CustomerID` | Many-to-One |
| `loans_clean` → `accounts_clean` | `AccountID` | Many-to-One |
| `transactions_clean` → `accounts_clean` | `AccountOriginID` → `AccountID` | Many-to-One |
| `transactions_clean` → `accounts_clean` | `AccountdestinationID` → `AccountID` | Many-to-One |
| `customers_clean` → `customer_types` | `CustomerTypeID` | Many-to-One |
| `accounts_clean` → `account_types` | `AccountTypeID` | Many-to-One |
| `accounts_clean` → `account_statuses` | `AccountStatusID` | Many-to-One |
| `loans_clean` → `loan_statuses` | `LoanStatusID` | Many-to-One |
| `transactions_clean` → `transaction_types` | `TransactionTypeID` | Many-to-One |
| `transactions_clean` → `branches` | `BranchID` | Many-to-One |
| `customers_clean` → `addresses_clean` | `AddressID` | Many-to-One |
| `branches` → `addresses_clean` | `AddressID` | Many-to-One |

Most relationships are many-to-one, with multiple customer, account, loan or transaction records linking to a single reference record.

---

## 8. Analysis & Metrics

<!--
  Explain what you measured and how - before you share what you found.

  WHAT GOOD LOOKS LIKE:
  Metric: "Customer Return Rate"
  Definition: "Number of transactions flagged as returns divided by total
               transactions, calculated at product-category and regional grain."
  Why It Matters: "Return rate - not sales volume - was hypothesised to
                  explain regional revenue gaps. This metric tests that hypothesis."

  WHAT TO AVOID:
  ❌ Defining a metric only in code: SUM(returns) / COUNT(transaction_id)
     That's an implementation. Write the plain-language definition here.
     Both belong in your project - the definition in the README,
     the implementation in the code.
-->

### Analytical Approach
The analysis began by exploring whether individual financial behaviours could help identify customers who may require closer monitoring. Rather than assuming that one behaviour represented financial risk, I investigated several possible indicators separately before examining how they interacted.

The analysis followed a series of questions:

1. **Do account balances reveal signs of financial vulnerability?**  
   Customer balances were analysed to identify negative balances and determine whether these occurred more frequently within particular customer types.

2. **Does loan behaviour provide a stronger indication of financial pressure?**  
   Loan exposure, loan status and overdue exposure were examined to identify customers carrying substantial borrowing or overdue debt. Loan exposure was also compared with customer account balances to identify cases where borrowing exceeded available balances.

3. **Do transaction patterns reveal unusual customer behaviour?**  
   Incoming and outgoing transaction frequency and value were analysed alongside net transaction flow. Large outgoing transactions were assessed relative to each customer's own average transaction value rather than using a single fixed threshold across all customers.

4. **Do multiple indicators occur together?**  
   Individual indicators were compared to determine whether customers displaying one warning sign also displayed others. For example, negative balances were compared with overdue loans; no customers displayed both indicators at the same time. This supported using several indicators rather than relying on a single measure.

5. **Can these behaviours be combined into a practical monitoring framework?**  
   Four indicators — negative balances, overdue loans, high loan exposure and unusually large outgoing transactions — were combined into a rule-based Risk Score. Customers triggering more indicators were assigned a higher monitoring priority, allowing the analysis to narrow 1,100 customers to a small group requiring further review.

6. **Are there other characteristics associated with monitoring priority?**  
   Additional exploratory analysis tested whether account status was associated with the final monitoring categories. Among the five Higher Priority customers, four had active accounts and one had an inactive account, while none had closed accounts. As no clear pattern emerged and the Higher Priority group was small, account status was not added to the Risk Score or dashboard.

7. **Where is Higher Priority customer activity occurring?**  
   Transaction activity from Higher Priority customers was aggregated by branch to identify where this activity was concentrated. This was used as a monitoring and investigation measure rather than an assessment of branch risk or financial loss.

### Key Metrics Defined

### Key Metrics Defined

| Metric | Plain-Language Definition | Why It Matters |
|--------|---------------------------|----------------|
| **Total Balance** | Combined balance across all accounts held by a customer. | Provides an overall view of the customer's available account balance. |
| **Total Loan Exposure** | Total principal value of loans associated with a customer's accounts. | Shows the level of lending exposure associated with each customer. |
| **Overdue Loan Exposure** | Total principal value of a customer's loans currently classified as overdue. | Identifies customers with outstanding overdue loan exposure requiring closer attention. |
| **Net Transaction Flow** | Total incoming transaction value minus total outgoing transaction value for each customer. | Helps identify whether transaction activity is producing an overall inflow or outflow of funds. |
| **Risk Score** | Number of monitoring indicators triggered by a customer, producing a score from 0 to 4. | Combines multiple financial behaviours into a simple method for prioritising customer review. |
| **Monitoring Priority** | Customers are grouped as Lower (0–1), Moderate (2), or Higher Priority (3–4) based on their Risk Score. | Allows monitoring efforts to focus on customers displaying multiple risk indicators. |

#### Risk Score Indicators

Each customer receives one point for each of the following conditions:

- **Negative Balance:** At least one account has a balance below zero.
- **Overdue Loan:** At least one associated loan is classified as overdue.
- **High Loan Exposure:** Total loan exposure exceeds the customer's total positive account balance.
- **Large Transaction:** The customer's largest outgoing transaction is at least twice their average outgoing transaction value.

**Risk Score:** 0–4

- **0–1:** Lower Priority
- **2:** Moderate Priority
- **3–4:** Higher Priority
- 
### Methods Used
- Data quality assessment and validation before analysis.
- Descriptive analysis of account balances, loans and transaction behaviour.
- Customer segmentation and comparison by customer type.
- Loan exposure and overdue loan analysis.
- Monthly transaction trend analysis.
- Customer-level aggregation across accounts, loans and transactions.
- SQL window functions for ranking and month-over-month comparisons.
- Rule-based scoring to combine multiple financial risk indicators.
- Branch-level analysis of transaction activity associated with Higher Priority customers.

---

## 9. Key Insights

<!--
  Findings + implications. Not just what happened - what it means.

  WHAT GOOD LOOKS LIKE:
  ✅ "Return rates, not sales volume, explain Region A's underperformance.
      Region A's return rate on home goods was 34% - more than double the
      company average. Revenue was not lost at the point of sale; it was
      lost post-sale through refunds. This points to a fulfilment or
      product quality issue specific to that region, not a demand problem."

  WHAT TO AVOID:
  ❌ "Region A had lower revenue than other regions in Q4."
     (That's an observation. It describes what happened.
      An insight says what it means and where to look next.)

  Aim for 3–6 insights. Quality over quantity.
-->

**Insight 1: [Short descriptive headline]**
[What you found + what it suggests. One short paragraph.]

**Insight 2: [Short descriptive headline]**
[What you found + what it suggests.]

**Insight 3: [Short descriptive headline]**
[What you found + what it suggests.]

**Insight 4 (if applicable): [Short descriptive headline]**
[What you found + what it suggests.]

---

## 10. Recommendations

<!--
  Action-oriented. Addressed to a real audience.
  Tied explicitly to the insight that supports each one.

  WHAT GOOD LOOKS LIKE:
  Priority: High
  Recommendation: "Conduct a fulfilment audit for home goods deliveries
                   in Region A - specifically investigating whether returns
                   correlate with a particular warehouse, carrier, or SKU batch."
  Based On: Insight 1 - return rate anomaly in Region A
  Owner: Operations / Supply Chain team

  WHAT TO AVOID:
  ❌ "Improve the return rate."
     (Not actionable. Doesn't say who, how, or where to start.)
  ❌ "Further analysis is needed."
     (This is a placeholder, not a recommendation.)
-->

| Priority | Recommendation | Based On | Suggested Owner |
|----------|---------------|----------|-----------------|
| High | [Specific, actionable step] | [Insight it comes from] | [Who should act] |
| Medium | [Specific, actionable step] | [Insight it comes from] | [Who should act] |
| Low | [Exploratory or longer-term suggestion] | [Insight it comes from] | [Who should act] |

---

## 11. Assumptions & Limitations

<!--
  WHAT GOOD LOOKS LIKE:
  Assumption: "Transaction records were assumed to be complete for all five regions.
               No validation was performed against source system record counts."
  Limitation: "The analysis cannot distinguish between returns initiated by
               the customer vs. returns initiated by the business (e.g., recalls).
               If business-initiated returns are concentrated in Region A, the
               return rate finding may reflect a policy decision, not a quality issue."

  WHAT TO AVOID:
  ❌ Leaving this section blank or writing "None known."
     Every project has limitations. Documenting them is a sign of
     analytical maturity - not a confession of failure.
-->

### Assumptions
- [What did you treat as true without being able to verify?]
- [What simplifications did you make for scope or feasibility?]
- [What domain rules or definitions did you accept as given?]

### Limitations
- [What gaps exist in the data?]
- [What analysis was out of scope but could affect interpretation?]
- [What would a more rigorous version of this project include?]
- [Are there known biases in the data source or collection method?]

Account status analysis: Account status was explored as an additional monitoring factor. Among the five Higher Priority customers, four had active accounts and one had an inactive account; none had closed accounts. Given the small Higher Priority group and lack of a clear pattern, account status was not added to the risk score or final dashboard.
> *The goal here is pre-emptive Q&A. What would a thoughtful skeptic push back on? Document the answer here, before they ask.*

---

## 12. Future Enhancements

<!--
  WHAT GOOD LOOKS LIKE:
  ✅ "Automate the monthly data pull from the POS export folder using
      a scheduled Python script, replacing the current manual process."
  ✅ "Expand the return rate analysis to include carrier-level data,
      which was unavailable in this dataset but exists in the logistics system."

  WHAT TO AVOID:
  ❌ "Add a machine learning model."
     (Vague, and disconnected from the actual findings of this project.)
  ❌ Listing aspirational features that don't follow logically from the work.
-->

- [ ] [Enhancement 1 - specific and traceable to a real gap in this project]
- [ ] [Enhancement 2]
- [ ] [Enhancement 3]
- [ ] [Enhancement 4]

---

## 13. Deliverables

| Deliverable | Description | Location |
|-------------|-------------|----------|
| [Name] | [What it contains] | [`/path/to/file`] |
| [Name] | [What it contains] | [`/path/to/file`] |
| [Name] | [What it contains] | [`/path/to/file`] |

---

## 14. Author

**[Your Name]**
[Your role or title - current or target]

- 🔗 [LinkedIn URL]
- 💼 [Portfolio or GitHub profile URL]
- 📧 [Email - optional]

---

*Last updated: [Month YYYY]*
*If this template helped you, consider starring the repository.*
