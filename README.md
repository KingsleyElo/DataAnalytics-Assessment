
# SQL Job Assessment – Case Study Solutions 

## Overview 

This repository contains my solutions to a SQL case study assessment. The goal is to demonstrate my proficiency in SQL and evaluate both my technical SQL skills and my problem-solving methodology.

## 1. High-Value Customers with Multiple Products

**Goal:**  
Identify customers who have at least one funded **savings** plan and one funded **investment** plan, and rank them by their total deposits.

**Approach:**  
- Filtered for only funded transactions (`confirmed_amount > 0`).  
- Used flags `is_regular_savings = 1` and `is_a_fund = 1` to classify plan types.  
- Aggregated deposits from both savings and investment plans per user.  
- Joined with the `users_customuser` table to fetch user names.  
- Converted values from Kobo to Naira for reporting.

---

## 2. Transaction Frequency Analysis

**Goal:**  
Segment users by how frequently they transact—High, Medium, or Low frequency—based on average transactions per month.

**Approach:**  
- Grouped transactions by user and month using `DATE_FORMAT(transaction_date, '%Y-%m')`.  
- Calculated average transactions per month per user.  
- Used a `CASE` statement to categorize frequency:
  - High: ≥10/month  
  - Medium: 3–9/month  
  - Low: ≤2/month  
- Counted users in each frequency category and computed average transaction rates.

---

## 3. Account Inactivity Alert

**Goal:**  
Identify active accounts (savings or investments) with no inflow transactions in the last 365 days.

**Approach:**  
- Used a CTE (`WITH` clause) to extract the most recent transaction per plan.  
- Filtered for confirmed inflows (`confirmed_amount > 0`).  
- Joined with `plans_plan` to check account activity (`is_deleted = 0` and `is_archived = 0`).  
- Calculated days since last transaction using `DATEDIFF(CURDATE(), last_transaction_date)`.  
- Filtered for accounts with inactivity longer than 365 days.

---

## 4. Customer Lifetime Value (CLV) Estimation

**Goal:**  
Estimate customer CLV using account tenure and transaction volume, assuming 0.1% profit per transaction.

**Approach:**  
- Calculated account tenure in months using `PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), DATE_FORMAT(date_joined, '%Y%m'))`.  
- Counted total transactions per user.  
- Calculated average profit per transaction (`0.001 * total_inflow`).  
- Used the formula:  
  CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction  
- Ensured divide-by-zero safety using `NULLIF()` in tenure calculations.

---

## Challenges Faced & Fixes

### Question 1 – High-Value Customers with Multiple Products

**Issue:**  
The initial version didn’t filter for funded transactions per plan type correctly and didn’t aggregate across both savings and investment plans properly.

**Fix:**  
Used separate subqueries per plan type, applied confirmed inflow filters (`confirmed_amount > 0`), and merged them using joins and conditional counts.

---

### Question 2 – Transaction Frequency Analysis

**Issue:**  
The frequency calculation was being done across all users instead of per user. This caused categorization errors and skewed user counts.

**Fix:**  
Moved transaction counting into a subquery grouped by user. Then, I used that intermediate result to classify frequency at the individual user level before aggregating.

---

### Question 3 – Account Inactivity Alert

**Issue:**  
The first version didn’t exclude archived or deleted plans, which made the "active accounts" logic unreliable.

**Fix:**  
Added filters `is_archived = 0` and `is_deleted = 0` in the `plans_plan` join, and confirmed that only active plans were included in the output.

---

### Question 4 – Customer Lifetime Value (CLV) Estimation

**Issue:**  
The initial logic incorrectly equated transaction count with inflow and didn’t convert tenure to months accurately.

**Fix:**  
Used `PERIOD_DIFF` to calculate monthly tenure. Corrected CLV logic to use `(total_txns / tenure) * 12 * (0.1% * inflow)` and ensured all financial values were converted from kobo to naira.

---

## Final Thoughts

- All queries were tested using MySQL.

- Business logic was strictly followed using provided schema, hints, and assumptions (e.g., all amounts in Kobo).

- The queries are designed to be clear, readable, and scalable with real-world datasets.

- Comments are included for clarity on logic and transformation steps.
