WITH MonthlyTransactions AS (
    -- Calculate transactions per user per month for regular savings plans
    SELECT
        u.id AS user_id,  
        u.first_name,
        u.last_name,
        DATE_FORMAT(sa.transaction_date, '%Y-%m') AS transaction_month,  
        COUNT(*) AS monthly_transactions  
    FROM
        users_customuser u  
    JOIN
        savings_savingsaccount sa ON u.id = sa.owner_id  
    WHERE sa.plan_id IN (SELECT id from plans_plan where is_regular_savings = 1)  -- Filter for regular savings plans
    GROUP BY
        u.id, u.first_name, u.last_name, DATE_FORMAT(sa.transaction_date, '%Y-%m') 
),
AverageTransactions AS (
    -- Calculate the average number of monthly transactions per user
    SELECT
        user_id,
        first_name,
        last_name,
        AVG(monthly_transactions) AS avg_monthly_transactions  
    FROM
        MonthlyTransactions  -- Use the results from the previous CTE
    GROUP BY
        user_id, first_name, last_name  
),
FrequencyCategory AS (
    -- Assign a frequency category to each user based on their average monthly transactions
    SELECT
        user_id,
        first_name,
        last_name,
        avg_monthly_transactions,
        CASE
            WHEN avg_monthly_transactions >= 10 THEN 'High Frequency' 
            WHEN avg_monthly_transactions >= 3 AND avg_monthly_transactions < 10 THEN 'Medium Frequency'  
            ELSE 'Low Frequency'  -- Low frequency: Less than 3 transactions
        END AS frequency_category
    FROM
        AverageTransactions  -- Use the results from the previous CTE
)
-- Final result: Group users by frequency category and calculate customer count and average transactions
SELECT 
    frequency_category,  
    COUNT(user_id) AS customer_count,  
    AVG(avg_monthly_transactions) AS avg_transactions_per_month  
FROM 
    FrequencyCategory  -- Use the results from the previous CTE
GROUP BY frequency_category  
ORDER BY 
    CASE  -- Order the categories in a logical order
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3 
    END;
