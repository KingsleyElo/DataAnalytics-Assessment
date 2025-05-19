-- Goal: Estimate Customer Lifetime Value (CLV) based on account tenure and total transaction volume.

SELECT
  u.id AS customer_id,
  CONCAT(u.first_name, ' ', u.last_name) AS name,
  
  -- Calculate account tenure in months
  PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), DATE_FORMAT(u.date_joined, '%Y%m')) AS tenure_months,
  
  -- Total number of inflow transactions (confirmed deposits)
  COUNT(s.id) AS total_transactions,
  
  -- Estimate CLV based on simplified model
  ROUND(
    (COUNT(s.id) / NULLIF(PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), DATE_FORMAT(u.date_joined, '%Y%m')), 0)) 
    * 12 
    * 0.001 * SUM(s.confirmed_amount) / COUNT(s.id) / 100, 2  -- convert from kobo to Naira and apply 0.1% profit
  ) AS estimated_clv

FROM adashi_staging.users_customuser u
JOIN adashi_staging.savings_savingsaccount s ON u.id = s.owner_id
WHERE s.confirmed_amount > 0  -- Consider only inflow transactions
GROUP BY u.id, u.first_name, u.last_name, u.date_joined
HAVING tenure_months > 0  -- Prevent division by zero for new accounts
ORDER BY estimated_clv DESC;
