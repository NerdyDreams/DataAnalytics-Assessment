USE adashi_staging;

SELECT 
    p.owner_id,
    u.last_name AS name,  -- using last_name sinc the name column in users_customer is NULL
    SUM(CASE WHEN p.is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,  -- count of savings plans
    SUM(CASE WHEN p.is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count,  -- count investment plans
    SUM(p.amount) AS total_deposits  -- sum of all plan amounts for total deposits
FROM 
    plans_plan p
LEFT JOIN 
    users_customuser u ON u.id = p.owner_id  -- join to get user details
GROUP BY 
    p.owner_id, u.last_name
HAVING 
    SUM(CASE WHEN p.is_regular_savings = 1 THEN 1 ELSE 0 END) > 0 
    AND SUM(CASE WHEN p.is_a_fund = 1 THEN 1 ELSE 0 END) > 0  -- ensuring at least one savings and one investment plan
ORDER BY 
    total_deposits DESC;