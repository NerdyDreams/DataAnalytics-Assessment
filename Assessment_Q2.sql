USE adashi_staging;

SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM (
    SELECT 
        s.owner_id,
        -- count total transactions per customer
        COUNT(*) AS total_transactions,
        -- calculate time period in months i.e difference between max and min transaction dates
        TIMESTAMPDIFF(
            MONTH, 
            MIN(s.transaction_date), 
            MAX(s.transaction_date)
        ) + 1 AS months_active,  -- adding 1 to avoid division by zero for single-transaction customers
        -- calculate average transactions per month
        COUNT(*) / (TIMESTAMPDIFF(
            MONTH, 
            MIN(s.transaction_date), 
            MAX(s.transaction_date)
        ) + 1) AS avg_transactions_per_month,
        -- categorize based on average transactions per month
        CASE 
            WHEN COUNT(*) / (TIMESTAMPDIFF(
                MONTH, 
                MIN(s.transaction_date), 
                MAX(s.transaction_date)
            ) + 1) >= 10 THEN 'High Frequency'
            WHEN COUNT(*) / (TIMESTAMPDIFF(
                MONTH, 
                MIN(s.transaction_date), 
                MAX(s.transaction_date)
            ) + 1) >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM 
        savings_savingsaccount s
    JOIN 
        users_customuser u ON u.id = s.owner_id  -- ensurin customer exists in users_customuser
        
    GROUP BY 
        s.owner_id
) AS customer_transactions
GROUP BY 
    frequency_category
ORDER BY 
    avg_transactions_per_month DESC;  -- Sort by average transactions per month in descending order