175. Combine Two Tables

Table: Person
+-------------+---------+
| Column Name | Type |
+-------------+---------+
| PersonId | int |
| FirstName | varchar |
| LastName | varchar |
+-------------+---------+
PersonId is the primary key column for this table.
Table: Address
+-------------+---------+
| Column Name | Type |
+-------------+---------+
| AddressId | int |
| PersonId | int |
| City | varchar |
| State | varchar |
+-------------+---------+
AddressId is the primary key column for this table.

Write a SQL query for a report that provides the following information for each person in the Person table, regardless if there is an address for each of those people:
FirstName, LastName, City, State


**PySpark Solution:**

cols_person = ['PersonId', 'FirstName', 'LastName']
cols_address = ['AddressId', 'PersonId', 'City', 'Country']

data_person = [(25, "Alice", "Sheron"),
               (30, "Bob", "San"),
               (35, "Charlie", "Angeles"),
               (45, "Samson", "Ignis")]

data_address = [('123AB', '25', 'Washington', 'USA'),
                ('345CC', '30', 'New York', 'USA'),
                ('888RD', '35', 'California', 'USA'),
                ('233HJ', '40', 'Beijing', 'China')]

df_person = spark.createDataFrame(data = data_person, schema = cols_person)
df_address = spark.createDataFrame(data = data_address, schema = cols_address)

df_report = df_person.join(df_address, 'PersonId', 'left').select("FirstName", "LastName", "City", "Country")

df_report.display()
