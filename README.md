# Question 1: High-Value Customers with Multiple Products

## Approach:

The goal was to identify customers with at least one funded savings plan and one funded investment plan, sorted by total deposits. The expected output required owner\_id, name, savings\_count, investment\_count, and total\_deposits.

* Tables Used: I used plans\_plan to get plan details and users\_customer to get user information.

* Join: I joined plans\_plan and users\_customer on owner\_id = id to link plans to their owners.

* Aggregation:

* I Used SUM(CASE WHEN p.is\_regular\_savings = 1 THEN 1 ELSE 0 END) to count savings plans.

* I Used SUM(CASE WHEN p.is\_a\_fund = 1 THEN 1 ELSE 0 END) to count investment plans.

* I Used SUM(p.amount) to calculate total deposits.

* Filtering: I applied 'HAVING' to ensure users have at least one savings and one investment plan.

* Sorting: I ordered results by total\_deposits in descending order.

## Challenges:

* Initially, the name column in the output was NULL. I inspected the users\_customer table and found that the name column was NULL for all rows, despite the table having first\_name and last\_name columns with values.

* Resolution: I decided to use the last\_name column from users\_customer instead of name. I updated the query to select u.last\_name AS name to match the expected output format. Alternatively, I considered using CONCAT(u.first\_name, ' ', u.last\_name) to combine both names, but since the expected output seemed to expect a single name field, I stuck with last\_name.

* I used a LEFT JOIN initially to debug why name was NULL, ensuring all plans\_plan records were included even if there was no match in users\_customer. The join on u.id = p.owner\_id worked since both columns are char(32) and should match.

# Question 2: Transaction Frequency Analysis

## Approach:

The task was to calculate the average number of transactions per customer per month and categorize customers into "High Frequency" (>= 10 transactions/month), "Medium Frequency" (3 -> 9 transactions/month), and "Low Frequency" (<2 transactions/month). The output needed frequency\_category, customer\_count, and avg\_transactions\_per\_month.

#### Tables Used:

I used savings\_savingsaccount for transaction data and users\_customuser to ensure valid customers.

#### Subquery:

* I grouped by owner\_id in savings\_savingsaccount to count total transactions, assuming each row represents one transaction (since there's no transaction\_count column).

* I calculated the time period in months using TIMESTAMPDIFF between the earliest and latest transaction\_date values, adding 1 to handle single-transaction cases.

* I computed the average transactions per month by dividing total transactions by the time period.

* I used a CASE statement to categorize customers based on their average transactions per month.

#### Main Query:

* I grouped by frequency\_category to count customers and calculate the average transactions per month for each category.

* I rounded the average to 1 decimal place

* I joined with users\_customuser on owner\_id = id to ensure only valid customers are included.

* I ordered by avg\_transactions\_per\_month in descending order to match the example output.

## Challenges:

* Transaction Status Ambiguity: The savings\_savingsaccount table has a transaction\_status column, but the qwestion didn't specify whether to count only successful transactions (e.g., transaction\_status = 'success'). I assumed all transactions count

* Time Period Calculation: I had challenge calculating the time period in months for customers with only one transaction because they would have a time period of 0 months. I added 1 to the TIMESTAMPDIFF result to assume a minimum of 1 month for such customers, aligning with the need to calculate an average. This might not be the intended approach, but it matches the expected output format.

# Question 3: Account Inactivity Alert

## Approach :

The task was to find active savings or investment accounts with no transactions in the last 365 days, outputting plan\_id, owner\_id, type, last\_transaction\_date, and inactivity\_days.

#### Tables Used:

I used plans\_plan for account details and savings\_savingsaccount for transaction data.

#### Filtering Active Plans:

I selected plans from plans\_plan where is\_deleted = 0 (active plans) and (is\_regular\_savings = 1 OR is\_a\_fund = 1) to include only savings or investment plans.

#### Last Transaction Date:

Used a LEFT JOIN with savings\_savingsaccount to get the most recent transaction\_date for each plan. I used COALESCE(MAX(s.transaction\_date), p.created\_on) to handle plans with no transactions, falling back to the plan's created\_on date.

#### Inactivity Calculation:

I calculated inactivity\_days using TIMESTAMPDIFF to find the days between the last transaction (or creation date) and the current date (May 18, 2025).

#### Type:

i used a 'CASE' statement to determine the type as "Savings" or "Investment" based on is\_regular\_savings and is\_a\_fund.

#### Filtering Inactivity:

I used 'HAVING' to filter for plans with inactivity greater than 365 days.

## Challenges

* Plans with No Transactions: Some plans might have no transactions in savings\_savingsaccount. I used a LEFT JOIN and COALESCE to fall back to the plan's created\_on date, assuming inactivity starts from the plan's creation if there are no transactions.

* Transaction Status Ambiguity: The savings\_savingsaccount table has a transaction\_status column, but the assignment didn't specify whether to count only successful transactions. I included all transactions.

# Question 4: Customer Lifetime Value (CLV) Estimation

## Approach

The task was to estimate CLV for each customer based on account tenure and transaction volume, with a profit per transaction of 0.1% of the transaction value. The output needed customer\_id, name, tenure\_months,total\_transactions, and estimated\_clv.

#### Tables Used:

I used users\_customuser for customer details and savings\_savingsaccount for transaction data.

#### Tenure Calculation:

I used TIMESTAMPDIFF to calculate months between date\_joined and the current date (May 18, 2025, 02:01 PM WAT), with a minimum of 1 month to avoid division by zero.

#### Transaction Count:

I counted rows in savings\_savingsaccount per customer as total transactions.

#### CLV Calculation:

I computed total profit as SUM(amount \_ 0.001) (0.1% of transaction value).
Estimated CLV as (total\_profit / tenure\_months) \_ 12, rounded to 2 decimal places.

## Challenges

* Name Column : the name column in users\_customuser was NULL, so I used last\_name as a substitute.

* Ambiguity in Transaction Value: The savings\_savingsaccount table has multiple amount-related columns (amount, confirmed\_amount, etc.). I chose amount as the transaction value but confirmed\_amount could be considered

* Zero Tenure or Transactions: Customers with zero tenure or no transactions could cause division by zero. I used 'GREATEST' to set a minimum tenure of 1 month, assuming a minimal active period.

* Transaction Status: The transaction\_status column wasn't filtered (e.g., only counting "success" transactions), as the question didn't specify. This could affect accuracy if some transactions are invalid.
