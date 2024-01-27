-- Solution 1
SELECT 
    MAX(salary) AS SecondHighestSalary
FROM
     Employee
WHERE 
    salary <> (SELECT MAX(salary) FROM Employee);

-- Solution 2

WITH cte_salary AS
(SELECT  
    DISTINCT salary, 
    DENSE_RANK() OVER(ORDER BY salary DESC) as salary_rank
FROM Employee
ORDER BY salary_rank)
SELECT 
    MAX(salary) AS SecondHighestSalary 
FROM cte_salary
WHERE salary_rank = 2;

-- Solution 3

select max(Salary) as SecondHighestSalary
from Employee
where salary <
(select max(Salary) from Employee);