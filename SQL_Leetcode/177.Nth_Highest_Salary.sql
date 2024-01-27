CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
    select max(salary) from        
    (select salary, dense_rank() over(order by salary desc) as rank_desc from Employee)a where rank_desc = N
  );
END