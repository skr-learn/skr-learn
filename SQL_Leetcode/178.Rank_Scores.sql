select score, dense_rank() over (order by score desc) as rank
from Scores
order by rank;

-- Solution 2

with cte_scores AS 
(select
    id, score, dense_rank() over(order by score desc) as ranking
from 
    scores)
select score, ranking as rank
from cte_scores;

-- Solution 3
SELECT score, DENSE_RANK() OVER(ORDER BY score DESC) AS 'rank'  -- Necessary to use rank with quotes as it is iin-built identifier in MySQL
FROM Scores; 