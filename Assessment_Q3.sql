USE adashi_staging;

SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
    END AS type,  -- Determine plan type
    COALESCE(MAX(s.transaction_date), p.created_on) AS last_transaction_date,  -- Use created_on if no transactions
    TIMESTAMPDIFF(
        DAY, 
        COALESCE(MAX(s.transaction_date), p.created_on), 
        '2025-05-18'
    ) AS inactivity_days  -- Calculate days since last transaction or creation
FROM 
    plans_plan p
LEFT JOIN 
    savings_savingsaccount s ON s.plan_id = p.id  -- Join to get transaction dates
WHERE 
    p.is_deleted = 0  -- Only active plans
    AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)  -- Savings or investment plans
GROUP BY 
    p.id, p.owner_id, p.is_regular_savings, p.is_a_fund, p.created_on
HAVING 
    TIMESTAMPDIFF(
        DAY, 
        COALESCE(MAX(s.transaction_date), p.created_on), 
        '2025-05-18'
    ) > 365  -- Filter for inactivity greater than 365 days
ORDER BY 
    inactivity_days DESC;