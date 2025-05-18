WITH CustomerTenure AS (
    -- Calculate account tenure in months for each customer
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) AS tenure_months
    FROM
        users_customuser u
),
TransactionCounts AS (
    -- Calculate the total number of transactions and total inflow for each customer
    SELECT
        sa.owner_id AS customer_id,
        COUNT(*) AS total_transactions,
        SUM(sa.confirmed_amount) AS total_inflow_kobo  -- Sum of inflows
    FROM
        savings_savingsaccount sa
    WHERE sa.plan_id IN (SELECT id from plans_plan where is_regular_savings = 1 OR is_a_fund = 1)
    GROUP BY
        sa.owner_id
)
-- Calculate and order the estimated CLV
SELECT
    ct.customer_id,
    ct.name,
    ct.tenure_months,
    tc.total_transactions,
    (tc.total_transactions / ct.tenure_months) * 12 * (0.001 / 100) * tc.total_inflow_kobo AS estimated_clv -- CLV formula
FROM
    CustomerTenure ct
JOIN
    TransactionCounts tc ON ct.customer_id = tc.customer_id
ORDER BY
    estimated_clv DESC;
