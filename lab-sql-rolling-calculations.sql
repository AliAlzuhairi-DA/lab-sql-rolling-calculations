-- 1: Get number of monthly active customers.

WITH cte_transactions AS (
    SELECT 
        account_id, 
        CONVERT(DATE, date) AS Activity_date,
        DATE_FORMAT(CONVERT(DATE, date), '%Y-%m') AS Activity_Month
    FROM 
        bank.trans
)
SELECT 
    Activity_Month,
    COUNT(DISTINCT account_id) AS Monthly_Active_Customers
FROM 
    cte_transactions
GROUP BY 
    Activity_Month
ORDER BY 
    Activity_Month;


-- 2: Active users in the previous month.


with cte_transactions as (
	select account_id, convert(date, date) as Activity_date,
		date_format(convert(date,date), '%m') as Activity_Month,
		date_format(convert(date,date), '%Y') as Activity_year
	from bank.trans
), cte_active_users as (
	select Activity_year, Activity_Month, count(distinct account_id) as Active_users
	from cte_transactions
	group by Activity_year, Activity_Month
)
select Activity_year, Activity_month, Active_users, 
   lag(Active_users) over (order by Activity_year, Activity_Month) as Last_month
from cte_active_users;

-- 3:Percentage change in the number of active customers.

WITH cte_transactions AS (
    SELECT 
        account_id, 
        CONVERT(DATE, date) AS Activity_date,
        DATE_FORMAT(CONVERT(DATE, date), '%m') AS Activity_Month,
        DATE_FORMAT(CONVERT(DATE, date), '%Y') AS Activity_year
    FROM 
        bank.trans
), cte_active_users AS (
    SELECT 
        Activity_year, 
        Activity_Month, 
        COUNT(DISTINCT account_id) AS Active_users
    FROM 
        cte_transactions
    GROUP BY 
        Activity_year, 
        Activity_Month
)
SELECT 
    Activity_year, 
    Activity_Month, 
    Active_users, 
    LAG(Active_users) OVER (ORDER BY Activity_year, Activity_Month) AS Last_month_active_users,
    CASE 
        WHEN LAG(Active_users) OVER (ORDER BY Activity_year, Activity_Month) IS NULL THEN 0
        ELSE ((Active_users - LAG(Active_users) OVER (ORDER BY Activity_year, Activity_Month)) / CAST(LAG(Active_users) OVER (ORDER BY Activity_year, Activity_Month) AS DECIMAL(10,2))) * 100
    END AS Percentage_change
FROM 
    cte_active_users;

-- 4: Retained customers every month.

WITH cte_transactions AS (
    SELECT 
        account_id, 
        CONVERT(DATE, date) AS Activity_date,
        DATE_FORMAT(CONVERT(DATE, date), '%m') AS Activity_Month,
        DATE_FORMAT(CONVERT(DATE, date), '%Y') AS Activity_year
    FROM 
        bank.trans
), cte_active_users AS (
    SELECT 
        Activity_year, 
        Activity_Month, 
        COUNT(DISTINCT account_id) AS Active_users
    FROM 
        cte_transactions
    GROUP BY 
        Activity_year, 
        Activity_Month
), cte_retained_customers AS (
    SELECT 
        au.Activity_year,
        au.Activity_Month,
        au.Active_users AS Retained_customers
    FROM 
        cte_active_users au
    JOIN 
        cte_active_users prev_au 
    ON 
        au.Activity_year = prev_au.Activity_year 
        AND au.Activity_Month = prev_au.Activity_Month + 1
)
SELECT 
    *
FROM 
    cte_retained_customers;



