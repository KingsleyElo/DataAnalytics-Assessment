-- Goal: Segment users based on how frequently they transact each month into 

-- Get average transactions per user per month and categorize them
WITH user_transaction_frequency AS (
  SELECT
    u.id AS user_id,
    -- categorize each user into High, Medium, or Low frequency based on their monthly average
    CASE
      WHEN COUNT(*) * 1.0 / COUNT(DISTINCT DATE_FORMAT(s.transaction_date, '%Y-%m')) >= 10 THEN 'High Frequency'
      WHEN COUNT(*) * 1.0 / COUNT(DISTINCT DATE_FORMAT(s.transaction_date, '%Y-%m')) >= 3 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category,
    
    -- calculate user's average transactions per month
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT DATE_FORMAT(s.transaction_date, '%Y-%m')), 2) AS avg_transactions_per_month
  FROM adashi_staging.savings_savingsaccount s
  
  -- join the savings table with users table to get user info
  JOIN adashi_staging.users_customuser u ON s.owner_id = u.id
  
  -- focus only on actual confirmed transactions
  WHERE s.confirmed_amount > 0
  
  -- group by user to get individual transaction frequency
  GROUP BY u.id
)

-- Group users by their frequency category and compute final metrics
SELECT
  frequency_category,
  COUNT(user_id) AS customer_count,
  
  -- calculate the average transactions per month across users in each category
  ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM user_transaction_frequency

-- group the summary result by frequency category
GROUP BY frequency_category

-- order by average frequency to show most active users first
ORDER BY avg_transactions_per_month DESC;
