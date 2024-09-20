--- WINDOWS FUNCTION 
-- Common questions would be
-- How to remove duplicate records?
-- Find the employee who gets the 10th highest salary in their respective?


USE [sql_wkday_20240228];
SELECT TOP 10 * FROM employees;
-- IN the above resultset, add an additional column that will give the average
-- salary of all the employees in the organization?

-- Solution 1 > subquery in the SELECT statement
SELECT  *,
(SELECT AVG(salary) FROM employees) AS avg_salary 
FROM employees;


SELECT  *,
(SELECT MIN(salary) FROM employees) AS min_salary 
FROM employees;

SELECT  *,
(SELECT MIN(salary) FROM employees ) AS min_salary 
FROM employees
WHERE
	employee_dept = 'SD-DB';

-- Solution 2 > CROSS join to get the same resultset?
SELECT *
FROM
employees AS emp
CROSS JOIN
(
	SELECT AVG(salary) AS avg_sal FROM employees
) AS a_sal

-- solution 3> the same resultset can be achieved using a CTE?

WITH a_sal
AS
(
	SELECT AVG(salary) AS avg_sal FROM employees
)

SELECT * FROM employees CROSS JOIN a_sal;

----- Solve the same problem using a windows function
SELECT *,
	AVG(salary) OVER() AS avg_sal
FROM
	employees;

SELECT *,
	MAX(salary) OVER() AS max_sal
FROM
	employees;

SELECT *,
	MIN(salary) OVER() AS mix_sal
FROM
	employees;

SELECT *,
	MIN(salary) OVER() AS mix_sal
FROM
	employees
WHERE
	employee_dept = 'SD-DB'



SELECT *,
	SUM(salary) OVER() AS total_salary_paid
FROM
	employees;

-- Find the employee salary as a fraction to the total salary paid to all the emps?
WITH
	emp_total_sal
AS
	(
		SELECT *,
		SUM(salary) OVER() AS total_salary_paid
		FROM
		employees
	)

SELECT * ,
	(salary * 1.000 / total_salary_paid) * 100
FROM emp_total_sal
ORDER BY
	salary DESC;

SELECT *,
	COUNT(*) OVER() AS total_number_of_emps
FROM
	employees;

SELECT 113205 * 1.00000 / (24378002 * 1.0000) 


-- In the above examples the entire table was treated as a single window
SELECT * FROM employees


SELECT *
FROM 
employees
INNER JOIN
(
	SELECT employee_dept,AVG(salary) AS avg_salary
	FROM 
	employees
	GROUP BY employee_dept
) AS t_1
ON t_1.employee_dept = employees.employee_dept

--- Common Table Expression
WITH dept_avg_sal
AS
(
	SELECT employee_dept,AVG(salary) AS avg_salary
	FROM 
	employees
	GROUP BY employee_dept
)

SELECT * 
FROM 
	employees
INNER JOIN
	dept_avg_sal
ON
	employees.employee_dept = dept_avg_sal.employee_dept;

--- Solve the above problem using a windows function
SELECT *
,	AVG(salary) OVER (PARTITION BY employee_dept) AS dept_avg_sal
FROM
employees;

-- classify all employees whose salary > AVG salary of their respective departments
	-- classify them as HIGH SAL?


-- classify all employees whose salary <= AVG salary of their respective departments
	-- classify them as LOW SAL?

SELECT *,
    CASE
        WHEN salary > dept_avg_sal THEN 'HIGH SAL'
        ELSE 'LOW SAL'
    END AS salary_class
FROM (
    SELECT *,
        AVG(salary) OVER (PARTITION BY employee_dept) AS dept_avg_sal
    FROM employees
) AS avg_salary;


WITH emp_dept_avg
AS
(
SELECT *,
        AVG(salary) OVER (PARTITION BY employee_dept) AS dept_avg_sal
    FROM employees
)

SELECT * ,
	CASE
		WHEN salary > dept_avg_sal THEN 'High Sal'
		ELSE 'Low Sal'
	END  AS salary_class
FROM emp_dept_avg;



SELECT *,
        AVG(salary) OVER (PARTITION BY employee_dept) AS dept_avg_sal
    FROM employees

--- how to find unique employee departments
SELECT DISTINCT employees.employee_dept FROM employees

SELECT *,
        MAX(salary) OVER (PARTITION BY employee_dept) AS dept_max_sal
    FROM employees
-- Use the above query to find the employee in each department who earns the MAX salary?


SELECT *,
        MIN(salary) OVER (PARTITION BY employee_dept) AS dept_min_sal
    FROM employees
-- Use the above query to find the employee in each department who earns the MIN salary?

SELECT *,
        COUNT(salary) OVER (PARTITION BY employee_dept) AS dept_emp_count
    FROM employees


SELECT *,
        SUM(salary) OVER (PARTITION BY employee_dept) AS dept_salary_sum
    FROM employees


-- ROW NUMBER



SELECT *
		, ROW_NUMBER() OVER(ORDER BY salary DESC) AS row_num_val
FROM
	employees


-- WIndows functions will not be used in a WHERE clause
SELECT *
FROM
(
SELECT *
		, ROW_NUMBER() OVER(ORDER BY salary DESC) AS row_num_val
FROM
	employees
) AS emp_sal_rank
WHERE
	row_num_val = 1

SELECT *
FROM
(
SELECT *
		, ROW_NUMBER() OVER(ORDER BY salary ASC) AS row_num_val
FROM
	employees
) AS emp_sal_rank
WHERE
	row_num_val = 1


INSERT INTO employees
VALUES
(
	(SELECT MAX(employee_id) FROM employees) + 1
	,'Samar Kumar Karamakar'
	,'samarkr@dummyemail.com'
	,'SD-Web',
	32062
	);



INSERT INTO employees
VALUES
(
	(SELECT MAX(employee_id) FROM employees) + 1
	,'Kamal Kumar Karamakar'
	,'kamalkr@dummyemail.com'
	,'SD-Report',
	32062
	);

SELECT *
		, ROW_NUMBER() OVER(ORDER BY salary ASC) AS row_num_val
FROM
	employees

-- find the emp who has the 10th highest salary in the organization?
WITH emp_sal_rank
AS
(
SELECT *
		,ROW_NUMBER() OVER(ORDER BY salary ASC) AS row_num_val
FROM
	employees
)

SELECT * FROM emp_sal_rank WHERE row_num_val = 10;


SELECT *
		,ROW_NUMBER() OVER(
					PARTITION BY employee_dept
					ORDER BY salary ASC) AS row_num_val
FROM
	employees


SELECT *
FROM
(
SELECT *
		,ROW_NUMBER() OVER(
					PARTITION BY employee_dept
					ORDER BY salary DESC) AS row_num_val
FROM
	employees
) AS emp_dept_sal_ra
WHERE row_num_val = 1;

-- ROW NUMBER WOULD shine when I want to remove duplicate records from a table

INSERT INTO employees
VALUES
(
	(SELECT MAX(employee_id) FROM employees) + 1
	,'Kamal Kumar Karamakar'
	,'kamalkr@dummyemail.com'
	,'SD-Report',
	32062
	);


SELECT * FROM employees

-- Use ROW_NUMBER() to remove duplicate records
SELECT
	*,
		ROW_NUMBER() OVER(
						PARTITION BY
							employee_name
							,employee_email
							,employee_dept
							,salary
						ORDER BY
							salary
						)
FROM
	employees
ORDER BY employee_id

-- use the above query to successfully identify the duplicates
WITH dup_emp
AS
(

SELECT
	*,
		ROW_NUMBER() OVER(
						PARTITION BY
							employee_name
							,employee_email
							,employee_dept
							,salary
						ORDER BY
							salary
						) AS dup_rank
FROM
	employees

)

SELECT * FROM dup_emp
WHERE dup_rank > 1;


-- use the above query to successfully identify the duplicates
WITH dup_emp
AS
(

SELECT
	*,
		ROW_NUMBER() OVER(
						PARTITION BY
							employee_name
							,employee_email
							,employee_dept
							,salary
						ORDER BY
							salary
						) AS dup_rank
FROM
	employees
)

DELETE FROM dup_emp
WHERE dup_rank > 1;

CREATE TABLE dummy_records
(
	friend_name VARCHAR(10)
	,friend_age INT
)

INSERT INTO dummy_records
VALUES
	('Abhijit', 32),
	('Joy', 32),
	('Kiran', 31),
	(NULL , NULL);

WITH
f_dup
AS
(
SELECT *
,	ROW_NUMBER() OVER(PARTITION BY friend_name, friend_age
					ORDER BY friend_age
					)AS friend_dup_count
					FROM dummy_records
) 

DELETE FROM f_dup
WHERE
friend_dup_count > 1;


SELECT * FROM dummy_records

--- RANK()
SELECT
	*,
		ROW_NUMBER() OVER(
						
						
						ORDER BY
							salary ASC
						) AS dup_rank
FROM
	employees



SELECT
	*,
		RANK() OVER(
						ORDER BY
							salary ASC
						) AS dup_rank
FROM
	employees


--- RANK() when the table is PARTITIONED in multiple windows based on the department
SELECT
	*,
		RANK() OVER(
						PARTITION BY employee_dept
						ORDER BY salary ASC
						) AS dup_rank
FROM
	employees


SELECT *
FROM
	(
SELECT
	*,
		RANK() OVER(
						ORDER BY
							salary ASC
						) AS sal_rank
FROM
	employees
	) AS emp_rank_sal
WHERE
	sal_rank   = 11

--- DENSE_RANK()
SELECT
	*,
		DENSE_RANK() OVER(
						ORDER BY
							salary ASC
						) AS dup_rank
FROM
	employees;


SELECT
	*,
		DENSE_RANK() OVER(
						PARTITION BY employee_dept
						ORDER BY
							salary ASC
						) AS dup_rank
FROM
	employees;



SELECT *
FROM
	(
SELECT
	*,
		DENSE_RANK() OVER(
						ORDER BY
							salary ASC
						) AS sal_rank
FROM
	employees
	) AS emp_rank_sal
WHERE
	sal_rank   = 11;


--- VARIABLES
--- STORED PROC
--- CURSOR
--- FUNCTIONS
--- TEMP TABLES
--- TABLE VARIABLES

----- 2nd Form , 2rd Normal Form, 1 TO many Relationships


SELECT TOP 10 * FROM orders

SELECT TOP 10 * FROM customers

SELECT TOP 10 * FROM salesman

SELECT TOP 10 * FROM discounts

-- can we answer
-- Total sales after discount by state?
-- We have to seperate the city and the state

-- 1234567891011
-- Bokaro, Jharkhand
--        8

-- STEP 1 > Get the position of the space
-- step 2 > get all the characters to the right of the space = State

SELECT  customer_address,
	LEN(customer_address),
		TRIM(RIGHT(customer_address, 
					LEN(customer_address) - 
					CHARINDEX(' ', customer_address)))
FROM
	customers;

SELECT CHARINDEX(' ', 'SQL is fun')

SELECT RIGHT('SQL is Fun', 3)

SELECT LEN('Bokaro, Jharkhand   ')

SELECT 'Bokaro, Jharkhand   ',
		CHARINDEX(' ', 'Bokaro, Jharkhand   ')
		, LEN('Bokaro, Jharkhand   ')
		,LEN('Bokaro, Jharkhand   ') - CHARINDEX(' ', 'Bokaro, Jharkhand   ')
		,RIGHT('Bokaro, Jharkhand   ', 
					LEN('Bokaro, Jharkhand   ') - 
					CHARINDEX(' ', 'Bokaro, Jharkhand   '))

SELECT TRIM('   SQL IN FUN   ')

SELECT RTRIM('   SQL IN FUN   ')

SELECT LTRIM('   SQL IN FUN   ')


WITH
	customer_det
AS
(
SELECT  *,
		TRIM(RIGHT(customer_address, 
					LEN(customer_address) - 
					CHARINDEX(' ', customer_address))) AS state_name
	,TRIM(REPLACE(
		LEFT(customer_address,CHARINDEX(',', customer_address)),
		',', '')) AS city_name
FROM
	customers
),

state_total_sales
AS
(
SELECT cus.state_name,
		SUM(ord.item_price * ord.quantity) AS total_sales
FROM
customer_det AS cus
INNER JOIN
orders AS ord
ON
cus.customer_id = ord.customer_id
GROUP BY
	cus.state_name
)

SELECT *
FROM
(
SELECT *,
	DENSE_RANK() OVER(ORDER BY total_sales DESC) AS sales_rank
FROM
	state_total_sales
) AS sub_q_1
WHERE
sub_q_1.sales_rank <= 3;
-- top 3 states where the highest purchase before discount was done?
-- Bokaro, Jharkhand

-- LEAD and LAG
--- VIEWS


SELECT *,
		RANK() OVER(ORDER BY salary ) AS salary_rank
		,DENSE_RANK()OVER(ORDER BY salary) AS salary_dense_rank
FROM
	employees;



SELECT *,
		RANK() OVER(ORDER BY salary ) AS salary_rank
		,DENSE_RANK()OVER(ORDER BY salary) AS salary_dense_rank
FROM
	employees;


--- Rank and Dense Rank is doing--->
SELECT *,
		RANK() OVER(PARTITION BY employee_dept ORDER BY salary ASC) AS salary_rank
		,DENSE_RANK() OVER( PARTITION BY employee_dept ORDER BY salary ASC) AS salary_dense_rank
FROM
	employees;


-- Use the rank and the dense rank to solve the below questions?

-- Top 3 salesman based on the highest total sales after discount?

-- Top 3 customers  based on the highest total sales after discount?

-- Top 3 salesman based on the highest count of sales?

-- Get the top 3 states from which the top 3 salesman served the highest count of customers

--  Get the top 3 month year with the highest sales after discount?

-- Get the bottom 3 month year with the lowest footfall?

--- Which state has the highest salesman?
WITH
	salesman_state
AS
(
SELECT *,
	TRIM(
		RIGHT(sales_location, LEN(sales_location) - 
			CHARINDEX(' ', sales_location))
		) AS state_name
	FROM salesman
)

SELECT *
FROM
(
SELECT *,
		DENSE_RANK() OVER(ORDER BY number_of_salesman DESC) AS dr_state_count
FROM
(
SELECT state_name, COUNT(*) number_of_salesman
FROM salesman_state
GROUP BY state_name
)AS sub__q_1
) AS sub_q_2
WHERE
sub_q_2.dr_state_count = 1;
--- top 3 states (where stores are located) that has the highest sales after discount?

-- use the salesman table to solve the last two questions?

--  get the top 3 month year with the highest sales after discount?--  get the top 3 month year with the highest sales after discount?WITH sales_discAS(SELECT *, quantity * item_price AS tot, (quantity * item_price)*(100-disc_perc)/100 as tot_a_disc from ordersinner joindiscountsonYEAR(purchase_date) = disc_yearANDMONTH(purchase_date) = discounts.disc_month),--select * from sales_discconcatinated_tabas(select tot_a_disc, concat(disc_month,'-', disc_year ) as month_year from sales_disc )SELECT *FROM(SELECT *, RANK() OVER(ORDER BY total_sales DESC) AS ranking_salesFROM(select month_year, SUM(tot_a_disc) AS total_salesfrom concatinated_tabGROUP BY month_year) AS sub_q_1) AS sub_q_2WHEREsub_q_2.ranking_sales <=3;
--- Co-related subqueries

-- Get the person in each department with the highest salary?
SELECT * FROM employees;
-- Solve the above problem using a SUBQUERY?
SELECT employees.*FROM(	SELECT employee_dept,       MAX(salary) AS max_sal	FROM		employees	GROUP BY	employee_dept) AS table_1INNER JOIN  employeesON  table_1.employee_dept = employees.employee_dept AND  table_1.max_sal = employees.salary


-- correlated subqury

SELECT *

,(
	SELECT MAX(salary) FROM employees WHERE 
		employee_dept = outer_query.employee_dept
) AS max_salary
FROM
employees AS outer_query
ORDER BY
outer_query.employee_dept

SELECT *
FROM
employees AS outer_query
WHERE
salary = (
			SELECT MAX(salary) FROM employees
			WHERE
			employee_dept = outer_query.employee_dept
			)

--- use the correlated subquery to find all the employees who earn more than the
--- average salary in their respective departments
SELECT *FROMemployees AS outer_queryWHEREsalary > (			SELECT AVG(salary) FROM employees AS avg_sal			WHERE			employee_dept = outer_query.employee_dept			)
-- classify each employee as Low Sal and High Sal
-- if the salary of the employee is greater then the AVG salary then High Sal
-- else LOW SAL
-- use correlated subquery to solve the above problem?


SELECT *,( SELECT AVG(salary) FROM 							employees							WHERE							employee_dept = outer_query.employee_dept) AS dept_avg_sal,CASEWHEN outer_query.salary > ( SELECT AVG(salary) FROM 							employees							WHERE							employee_dept = outer_query.employee_dept) 							THEN 'High SAL'ELSE 'Low sal'END AS sal_clasificationFROMemployees AS outer_query

WITH
employee_details
AS
(
SELECT *
,	(
	SELECT AVG(salary) FROM employees
		WHERE
		employee_dept = outer_query.employee_dept
	) AS avg_sal_dept
FROM
employees AS outer_query
)

SELECT *,
		CASE
			WHEN salary > avg_sal_dept THEN 'High Salary'
			ELSE 'Low Salary'
		END AS salary_class
FROM employee_details;


SELECT employees.*		,table_1.avg_salFROM(	SELECT employee_dept,       AVG(salary) AS avg_sal	FROM		employees	GROUP BY	employee_dept) AS table_1INNER JOIN  employeesON  table_1.employee_dept = employees.employee_dept 
-- Find the employee getting the  max, min salary based on the correlated subquery
--- Find the employees getting salary > avg salary using corelated subquery
--- Classify empl based on avg salary of their respective departments using corelated subquery


--- PROGRAMMING IN SQL
