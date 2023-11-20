Write a SQL query to get the second highest salary from the Employee table.
+----+--------+
| Id | Salary |
+----+--------+
| 1 | 100 |
| 2 | 200 |
| 3 | 300 |
+----+--------+

For example, given the above Employee table, the query should return 200 as the second highest salary. If there is no second highest salary, then the query should return null.
+---------------------+
| SecondHighestSalary |
+---------------------+
| 200 |
+---------------------+

**PySpark Solution**:

from pyspark.sql.functions import dense_rank, col
from pyspark.sql.window import Window
  
df_sal = spark.createDataFrame(data = [(1, 100), (1, 200), (1, 300), (1, 400)], schema = ['Id', 'Salary'])

windowSpec = Window.partitionBy('Id').orderBy('Salary')

df_2nd_highest_sal = (df_sal
                      .withColumn('rank', dense_rank().over(windowSpec))
                      .filter(col("rank") == 2)
                      .withColumnRenamed("Salary", "SecondHighestSalary")
                      .drop("Id")
                      .drop("rank")
                      )

df_2nd_highest_sal.display()
