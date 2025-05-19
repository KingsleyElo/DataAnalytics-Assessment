-- Goal: Identify active savings/investment plans with no inflow transactions in the past 365 days

-- last transaction date with confirmed payment
WITH last_transaction_inflow AS (
	select 
		plan_id,
        -- check the latest transaction date 
		max(transaction_date) as last_transaction_date
	from adashi_staging.savings_savingsaccount
    -- confirmed amount column is filtered to ensure we capture only active account that received money
    -- this will help us check for inactivity
	where confirmed_amount > 0
	group by plan_id
)



SELECT 
  p.id AS plan_id,
  p.owner_id,
  -- create savings and investment category and save in a column named type
  CASE 
    WHEN p.is_regular_savings = 1 THEN 'Savings'
    WHEN p.is_a_fund = 1 THEN 'Investment'
    ELSE 'Unknown'
  END AS type,
  li.last_transaction_date,
  -- calculate the inactivity days based on the last_transaction_date and the current date
  DATEDIFF(CURDATE(), li.last_transaction_date) AS inactivity_days
FROM adashi_staging.plans_plan p
-- join the temporary table created(last_transaction_inflow) with the plans table
JOIN last_transaction_inflow li ON p.id = li.plan_id
-- since we are dealing with active accounts, we filter the is_deleted column and is_archived column to display only active accounts
WHERE p.is_deleted = 0 
  AND p.is_archived = 0
  -- Check for accounts with no inflow for over 365 days
  AND DATEDIFF(CURDATE(), li.last_transaction_date) > 365
ORDER BY inactivity_days DESC;