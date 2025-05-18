USE adashi_staging;

SELECT 
    u.id AS customer_id,
    u.last_name AS name,  -- using last_name since name column is NULL
    GREATEST(
        1,  -- avoiding division by zero
        TIMESTAMPDIFF(
            MONTH, 
            u.date_joined, 
            '2025-05-18 14:01:00'
        )
    ) AS tenure_months, 
    COUNT(s.owner_id) AS total_transactions,  -- total transactions per customer
    ROUND(
        (SUM(s.amount * 0.001) / GREATEST(
            1, 
            TIMESTAMPDIFF(
                MONTH, 
                u.date_joined, 
                '2025-05-18 14:01:00'
            )
        )) * 12, 2
    ) AS estimated_clv  -- CLV = (total_profit / tenure_months) * 12
FROM 
    users_customuser u
LEFT JOIN 
    savings_savingsaccount s ON s.owner_id = u.id  -- include all customers, even with no transactions
GROUP BY 
    u.id, u.last_name, u.date_joined
ORDER BY 
    estimated_clv DESC; 