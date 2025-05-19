-- Goal: Identify high-value customers who have both a funded savings plan and a funded investment plan.

-- Funded savings plans: Count number of regular savings plans per user with at least one confirmed inflow
WITH funded_savings AS (
  SELECT 
    p.owner_id,
    COUNT(DISTINCT p.id) AS savings_count
  FROM adashi_staging.plans_plan p
  JOIN adashi_staging.savings_savingsaccount s 
    ON s.plan_id = p.id
  WHERE p.is_regular_savings = 1
    AND s.confirmed_amount > 0
  GROUP BY p.owner_id
),

-- Funded investment plans: Count number of investment plans per user with at least one confirmed inflow
funded_investments AS (
  SELECT 
    p.owner_id,
    COUNT(DISTINCT p.id) AS investment_count
  FROM adashi_staging.plans_plan p
  JOIN adashi_staging.savings_savingsaccount s 
    ON s.plan_id = p.id
  WHERE p.is_a_fund = 1
    AND s.confirmed_amount > 0
  GROUP BY p.owner_id
),

-- Total deposits: Sum of all confirmed inflows per user (converted from Kobo to Naira)
user_deposits AS (
  SELECT 
    s.owner_id,
    SUM(s.confirmed_amount) / 100 AS total_deposits
  FROM adashi_staging.savings_savingsaccount s
  GROUP BY s.owner_id
)

-- Final result: Join all above CTEs with user table and return customers with both product types
SELECT 
  u.id AS owner_id,
  CONCAT(u.first_name, ' ', u.last_name) AS name,
  fs.savings_count,
  fi.investment_count,
  ud.total_deposits
FROM adashi_staging.users_customuser u
JOIN funded_savings fs 
  ON u.id = fs.owner_id
JOIN funded_investments fi 
  ON u.id = fi.owner_id
JOIN user_deposits ud 
  ON u.id = ud.owner_id
WHERE ud.total_deposits > 0
ORDER BY ud.total_deposits DESC;
