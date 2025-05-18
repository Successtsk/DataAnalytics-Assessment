WITH LastTransactionDates AS (
    -- Find the last transaction date for each plan
    SELECT
        plan_id,
        owner_id,
        MAX(transaction_date) AS last_transaction_date
    FROM
        savings_savingsaccount
    WHERE confirmed_amount > 0  -- Consider only inflow transactions
    GROUP BY
        plan_id, owner_id
),
PlanTypes AS (
    -- Determine the type of each plan (Savings or Investment)
    SELECT
        id AS plan_id,
        owner_id,
        CASE
            WHEN is_regular_savings = 1 THEN 'Savings'
            WHEN is_a_fund = 1 THEN 'Investment'
            ELSE 'Unknown'
        END AS plan_type
    FROM
        plans_plan
)
-- Final result: Find inactive accounts
SELECT
    pt.plan_id,
    pt.owner_id,
    pt.plan_type,
    COALESCE(ltd.last_transaction_date, '1900-01-01') AS last_transaction_date,
    DATEDIFF(CURDATE(), COALESCE(ltd.last_transaction_date, '1900-01-01')) AS inactivity_days
FROM
    PlanTypes pt
LEFT JOIN
    LastTransactionDates ltd ON pt.plan_id = ltd.plan_id AND pt.owner_id = ltd.owner_id
WHERE pt.plan_id IN (SELECT id from plans_plan where is_regular_savings = 1 OR is_a_fund = 1)
    AND (ltd.last_transaction_date IS NULL OR ltd.last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR) )
ORDER BY
    inactivity_days DESC;
