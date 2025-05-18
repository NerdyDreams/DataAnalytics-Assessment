# Question 1: High-Value Customers with Multiple Products

## Approach:

The goal was to identify customers with at least one funded savings plan and one funded investment plan, sorted by total deposits. The expected output required owner_id, name, savings_count, investment_count, and total_deposits.

    Tables Used: I used plans_plan to get plan details and users_customer to get user information.
    Join: I joined plans_plan and users_customer on owner_id = id to link plans to their owners.

    Aggregation:
    I Used SUM(CASE WHEN p.is_regular_savings = 1 THEN 1 ELSE 0 END) to count savings plans.
    I Used SUM(CASE WHEN p.is_a_fund = 1 THEN 1 ELSE 0 END) to count investment plans.
    I Used SUM(p.amount) to calculate total deposits.


    Filtering: I applied 'HAVING' to ensure users have at least one savings and one investment plan.
    Sorting: I ordered results by total_deposits in descending order.

## Challenges:

    Initially, the name column in the output was NULL. I inspected the users_customer table and found that the name column was NULL for all rows, despite the table having first_name and last_name columns with values.

    Resolution: I decided to use the last_name column from users_customer instead of name. I updated the query to select u.last_name AS name to match the expected output format. Alternatively, I considered using CONCAT(u.first_name, ' ', u.last_name) to combine both names, but since the expected output seemed to expect a single name field, I stuck with last_name.

    I used a LEFT JOIN initially to debug why name was NULL, ensuring all plans_plan records were included even if there was no match in users_customer. The join on u.id = p.owner_id worked since both columns are char(32) and should match.

# Question 2: Transaction Frequency Analysis

## Approach:

The task was to calculate the average number of transactions per customer per month and categorize customers into "High Frequency" (>= 10 transactions/month), "Medium Frequency" (3 -> 9 transactions/month), and "Low Frequency" (<2 transactions/month). The output needed frequency_category, customer_count, and avg_transactions_per_month.

#### Tables Used:

I used savings_savingsaccount for transaction data and users_customuser to ensure valid customers.

#### Subquery:

    I grouped by owner_id in savings_savingsaccount to count total transactions, assuming each row represents one transaction (since there's no transaction_count column).

    I calculated the time period in months using TIMESTAMPDIFF between the earliest and latest transaction_date values, adding 1 to handle single-transaction cases.

    I computed the average transactions per month by dividing total transactions by the time period.

    I used a CASE statement to categorize customers based on their average transactions per month.

#### Main Query:

    I grouped by frequency_category to count customers and calculate the average transactions per month for each category.

    I rounded the average to 1 decimal place

    I joined with users_customuser on owner_id = id to ensure only valid customers are included.

    I ordered by avg_transactions_per_month in descending order to match the example output.

## Challenges:

    Transaction Status Ambiguity: The savings_savingsaccount table has a transaction_status column, but the qwestion didn't specify whether to count only successful transactions (e.g., transaction_status = 'success'). I assumed all transactions count

    Time Period Calculation: I had challenge calculating the time period in months for customers with only one transaction because they would have a time period of 0 months. I added 1 to the TIMESTAMPDIFF result to assume a minimum of 1 month for such customers, aligning with the need to calculate an average. This might not be the intended approach, but it matches the expected output format.

# Question 3: Account Inactivity Alert

## Approach :

The task was to find active savings or investment accounts with no transactions in the last 365 days, outputting plan_id, owner_id, type, last_transaction_date, and inactivity_days.

#### Tables Used:

I used plans_plan for account details and savings_savingsaccount for transaction data.

#### Filtering Active Plans:

I selected plans from plans_plan where is_deleted = 0 (active plans) and (is_regular_savings = 1 OR is_a_fund = 1) to include only savings or investment plans.

#### Last Transaction Date:

Used a LEFT JOIN with savings_savingsaccount to get the most recent transaction_date for each plan. I used COALESCE(MAX(s.transaction_date), p.created_on) to handle plans with no transactions, falling back to the plan's created_on date.

#### Inactivity Calculation:

I calculated inactivity_days using TIMESTAMPDIFF to find the days between the last transaction (or creation date) and the current date (May 18, 2025).

#### Type:

i used a 'CASE' statement to determine the type as "Savings" or "Investment" based on is_regular_savings and is_a_fund.

#### Filtering Inactivity:

I used 'HAVING' to filter for plans with inactivity greater than 365 days.

## Challenges

    Plans with No Transactions: Some plans might have no transactions in savings_savingsaccount. I used a LEFT JOIN and COALESCE to fall back to the plan's created_on date, assuming inactivity starts from the plan's creation if there are no transactions.

    Transaction Status Ambiguity: The savings_savingsaccount table has a transaction_status column, but the assignment didn't specify whether to count only successful transactions. I included all transactions.

# Question 4: Customer Lifetime Value (CLV) Estimation

## Approach

The task was to estimate CLV for each customer based on account tenure and transaction volume, with a profit per transaction of 0.1% of the transaction value. The output needed customer_id, name, tenure_months,total_transactions, and estimated_clv.

#### Tables Used:

I used users_customuser for customer details and savings_savingsaccount for transaction data.

#### Tenure Calculation:

I used TIMESTAMPDIFF to calculate months between date_joined and the current date (May 18, 2025, 02:01 PM WAT), with a minimum of 1 month to avoid division by zero.

#### Transaction Count:

I counted rows in savings_savingsaccount per customer as total transactions.

#### CLV Calculation:

I computed total profit as SUM(amount _ 0.001) (0.1% of transaction value).
Estimated CLV as (total_profit / tenure_months) _ 12, rounded to 2 decimal places.

## Challenges

    Name Column : the name column in users_customuser was NULL, so I used last_name as a substitute.

    Ambiguity in Transaction Value: The savings_savingsaccount table has multiple amount-related columns (amount, confirmed_amount, etc.). I chose amount as the transaction value but confirmed_amount could be considered

    Zero Tenure or Transactions: Customers with zero tenure or no transactions could cause division by zero. I used 'GREATEST' to set a minimum tenure of 1 month, assuming a minimal active period.

    Transaction Status: The transaction_status column wasn't filtered (e.g., only counting "success" transactions), as the question didn't specify. This could affect accuracy if some transactions are invalid.
