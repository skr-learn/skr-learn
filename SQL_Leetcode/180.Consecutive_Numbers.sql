-- Solution 1

select 
    distinct(num) as ConsecutiveNums 
from
    (SELECT 
        num, 
        LEAD(num, 1) OVER(ORDER BY id) AS lead_num, 
        LAG(num, 1) OVER (ORDER BY id) AS lag_num 
    FROM 
        logs) a 
where 
    num = lead_num and num = lag_num;

-- Solution 2
WITH CTE AS
(
    SELECT
        id,
        num,
        LEAD(num) OVER() AS "num1",
        LEAD(num,2) OVER() AS "num2"
    FROM
        Logs
)
SELECT
    DISTINCT num AS "ConsecutiveNums"
FROM
    CTE
WHERE
    (num = num1) AND (num1 = num2);
