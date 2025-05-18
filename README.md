# DataAnalytics-Assessment

## Assesment_Q1 
### Per-Question Explanation
The query aims to identify high-value customers who have both savings and investment plans, and to provide a summary of their activity. Here's a breakdown of the approach:
#### 1.	Identify Relevant Tables:
The query uses three tables: users_customuser, savings_savingsaccount, and plans_plan. These tables contain the necessary information about users, their savings accounts, and the details of their plans (whether they are savings or investment plans).

#### 2.	Join Tables:
The query joins these tables to link related data:
* It joins users_customuser with savings_savingsaccount using u.id = sa.owner_id to connect users to their savings accounts.
* It joins savings_savingsaccount with plans_plan using sa.plan_id = pp.id to get the details of the plans associated with each savings account.

#### 3.	Filter for Customers with Both Plan Types:
The most crucial part of the query is the WHERE clause, which ensures that only customers with both a savings plan and an investment plan are included in the results. It uses two subqueries with the IN operator to achieve this:
* The first subquery WHERE pp.is_regular_savings = 1 selects the owner_id of all users who have a savings plan.
* The second subquery WHERE pp.is_a_fund = 1 selects the owner_id of all users who have an investment plan.
* The AND operator combines these two conditions, so only users whose id is present in both subquery results are included.

#### 4.	Calculate Total Deposits:
The SUM(sa.confirmed_amount) function calculates the total amount deposited by each user across their savings accounts. The result is aliased as total_deposits.

#### 5.	Count Plan Types:
The query uses conditional COUNT expressions to count the number of savings and investment plans for each user:
* COUNT(CASE WHEN pp.is_regular_savings = 1 THEN 1 ELSE NULL END) counts the savings plans.
* COUNT(CASE WHEN pp.is_a_fund = 1 THEN 1 ELSE NULL END) counts the investment plans.
* The CASE expression assigns a value of 1 to rows that meet the condition (either being a savings or investment plan), and NULL to those that don't. COUNT then counts the non-null values.
  
#### 6.	Group and Order Results:
* The GROUP BY u.id, name clause groups the results by user ID and name, so that the SUM and COUNT functions produce aggregate results for each user.
* The ORDER BY total_deposits DESC clause sorts the results in descending order of total deposits, so that the highest-value customers are shown first.

### Challenges:
*	Ensuring Both Plan Types are Present: The primary challenge was to accurately identify customers who have at least one of each plan type. Initially, I used a simpler approach, but it didn't fully capture the "at least one of each" requirement. The final solution with the two IN subqueries correctly addresses this.

## Assesment_Q2 
### Per-Question Explanation
This query analyzes the frequency of customer transactions to categorize them into "High," "Medium," and "Low" frequency users. Here's how it works:
#### 1.	Calculate Monthly Transactions:
The MonthlyTransactions CTE calculates the number of transactions for each user per month.
* It joins the users_customuser and savings_savingsaccount tables using the owner_id to link users to their transaction data.
* It filters for transactions related to regular savings plans using a subquery on plans_plan.
* It groups the transactions by user and month, counting the number of transactions per user per month.
#### 2.	Calculate Average Monthly Transactions:
* The AverageTransactions CTE calculates the average number of monthly transactions for each user.
* It uses the results from the MonthlyTransactions CTE.
* It groups the data by user and calculates the average number of transactions across all months for each user.
#### 3.	Categorize Users by Frequency:
The FrequencyCategory CTE categorizes users based on their average monthly transaction count.
* It uses a CASE statement to assign a frequency category:
  *	"High Frequency": 10 or more transactions per month.
  *	"Medium Frequency": 3 to 9 transactions per month.
  *	"Low Frequency": Less than 3 transactions per month.
#### 4.	Final Result:
The final SELECT statement generates the output.
* It groups users by their frequency category and calculates:
	* The number of customers in each category (customer_count).
	* The average number of transactions per month for each category.
*	The results are ordered for readability, showing "High Frequency" first.
### Challenges:
*	Handling Time Periods: The main challenge was to accurately calculate the average monthly transactions. The query extracts the year and month from the transaction_date to group transactions correctly.
*	Categorization Logic: Defining the frequency categories required careful consideration to ensure the users were grouped appropriately. The CASE statement effectively handles this categorization.
*	Clarity of Output: The query was refined to provide a clear and concise output, showing the frequency categories, customer counts, and average transactions per month, as requested.

## Assesment_Q3 
### Per-Question Explanation
This query identifies accounts that have been inactive for more than one year, specifically focusing on the absence of inflow transactions. Here's a breakdown of the approach:
#### 1. Identify Inflow Transactions:
* The query focuses on the savings_savingsaccount table, using the confirmed_amount column to represent inflow. It considers a transaction as an inflow if confirmed_amount is greater than 0.
#### 2.	Determine Last Transaction Date:
The LastTransactionDates CTE (Common Table Expression) is used to find the most recent inflow transaction for each account.
* It selects the plan_id and owner_id from the savings_savingsaccount table.
* It uses the MAX(transaction_date) function to get the latest transaction_date for each account.
* It filters for inflow transactions using WHERE confirmed_amount > 0.
* It groups the results by plan_id and owner_id to get the last inflow date for each unique account.
#### 3.	Determine Plan Types
The PlanTypes CTE is used to determine whether a plan is a savings or an investment plan.
* It selects the id as plan_id and owner_id from the plans_plan table.
* It uses a CASE statement to assign the plan_type:
	* If is_regular_savings = 1, the plan is labeled as 'Savings'.
	* If is_a_fund = 1, the plan is labeled as 'Investment'.
	* Otherwise, the plan is labeled as 'Unknown'.
#### 4.	Identify Inactive Accounts:
* The main SELECT statement joins the PlanTypes CTE with the LastTransactionDates CTE on plan_id and owner_id using a LEFT JOIN. A LEFT JOIN is crucial here to include all plans, even those with no matching entries in LastTransactionDates (meaning no inflows).
* It filters for accounts that meet the inactivity criteria:
  * pt.plan_id IN (SELECT id from plans_plan where is_regular_savings = 1 OR is_a_fund = 1): This ensures that the query only considers savings and investment plans.
    
  * (ltd.last_transaction_date IS NULL OR ltd.last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)): This is the core logic for identifying inactive accounts. It checks for two conditions:
  * ltd.last_transaction_date IS NULL: This identifies accounts that have never had an inflow transaction.
  * ltd.last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR): This identifies accounts where the last inflow transaction was more than one year ago. CURDATE() gets the current date, and DATE_SUB() subtracts one year.
* It uses COALESCE to handle NULL values. If an account has never had an inflow (ltd.last_transaction_date is NULL), COALESCE replaces the NULL with '1900-01-01' so that the DATEDIFF function can calculate the number of inactive days.
* It calculates inactivity_days using DATEDIFF(CURDATE(), COALESCE(ltd.last_transaction_date, '1900-01-01')).
#### 5.	Present Results:
* The query returns the following columns:
  * plan_id: The ID of the plan.
  * owner_id: The ID of the account owner.
  * plan_type: The type of plan ('Savings' or 'Investment').
  * last_transaction_date: The date of the last inflow transaction (or '1900-01-01' if never).
  * inactivity_days: The number of days since the last inflow transaction.
*	The results are ordered by inactivity_days in descending order, so the most inactive accounts are listed first.

### Challenges:
* Handling Accounts with No Transactions: A key challenge was correctly identifying accounts that have never had an inflow transaction. The LEFT JOIN and the use of COALESCE to handle NULL values in the last_transaction_date were essential to solve this.
* Calculating Inactivity Days: Calculating the number of days since the last transaction required using the DATEDIFF function and handling potential NULL values.
* Ensuring Correct Plan Types: The PlanTypes CTE was used to accurately determine and label the type of each plan (Savings or Investment), making the final output more informative.

## Assesment_Q4 
### Per-Question Explanation

This query estimates Customer Lifetime Value (CLV) based on customer account tenure and transaction volume. Here's how the query works:
#### 1.	Calculate Customer Tenure:
* The CustomerTenure CTE calculates the account tenure for each customer in months.
* It selects the customer's ID and name from the users_customuser table.
* It uses the TIMESTAMPDIFF function to determine the difference in months between the customer's account creation date (created_on) and the current date (CURDATE()).
#### 2.	Calculate Total Transactions and Value:
* The TransactionCounts CTE calculates the total number of transactions and the total transaction value for each customer.
* It selects the customer's ID from the savings_savingsaccount table.
* It uses COUNT(*) to count all transactions associated with the customer.
* It sums the confirmed_amount column from the savings_savingsaccount table to get the total inflow value for each customer.
* It filters the transactions to include only those from savings and investment plans.
#### 3.	Calculate Estimated CLV:
* The final SELECT statement calculates the estimated CLV using the following formula:
* CLV = (total_transactions / tenure_in_months) * 12 * average_profit_per_transaction
  * Where: total_transactions is the total number of transactions, tenure_in_months is the customer's account tenure in months, 12 is used to annualize the transactions and average_profit_per_transaction is assumed to be 0.1% of the transaction value.
* The query joins the CustomerTenure and TransactionCounts CTEs on customer_id to combine the tenure and transaction data for each customer.
* The calculated CLV is aliased as estimated_clv.
#### 4.	Present Results:
* The query selects the following columns:
  * customer_id: The unique identifier for the customer.
  * name: The customer's full name.
  * tenure_months: The customer's account tenure in months.
  *	total_transactions: The total number of transactions made by the customer.
  * estimated_clv: The calculated estimated customer lifetime value.
* The results are ordered in descending order of estimated_clv, showing the customers with the highest estimated CLV first.
### Challenges:
* Accurate Tenure Calculation: Ensuring the account tenure was calculated accurately in months using TIMESTAMPDIFF was important.
* CLV Formula Implementation: Correctly implementing the CLV formula, including annualizing the transactions and applying the profit margin, required careful attention to the order of operations.
* Joining Data from Multiple CTEs: The query efficiently joins the data from the CustomerTenure and TransactionCounts CTEs to calculate the CLV.
* Clarifying Assumptions: The query explicitly states the assumption of a 0.1% profit per transaction to make the calculation clear.
