SELECT
    u.id AS user_id,
    concat(u.first_name,' ',u.last_name) AS name,
    COUNT(CASE WHEN pp.is_regular_savings = 1 THEN 1 ELSE NULL END) AS savings_plan,
     COUNT(CASE WHEN pp.is_a_fund = 1 THEN 1 ELSE NULL END) AS investment_plan,
    SUM(sa.confirmed_amount) AS total_deposits
FROM
    users_customuser u
JOIN
    savings_savingsaccount sa ON u.id = sa.owner_id -- Join users with their savings accounts
JOIN
    plans_plan pp ON sa.plan_id = pp.id  -- Join savings accounts with plan details
WHERE u.id IN (
    SELECT sa.owner_id
    FROM savings_savingsaccount sa
    JOIN plans_plan pp ON sa.plan_id = pp.id
    WHERE pp.is_regular_savings = 1 -- Subquery to find users with savings plans
)
AND u.id IN (
    SELECT sa.owner_id
    FROM savings_savingsaccount sa
    JOIN plans_plan pp ON sa.plan_id = pp.id
    WHERE pp.is_a_fund = 1 -- Subquery to find users with investment plans
)
GROUP BY
    u.id, name -- Group results by user
ORDER BY
    total_deposits DESC;  -- Order by total deposits
