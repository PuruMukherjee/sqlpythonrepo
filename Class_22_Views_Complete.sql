-- give a report where every emp is classified as low sal and high sal
-- based on the following rule
-- if the salary of the emp > avg the sala of the department
-- then the emp is classified as high sal
-- else the emp is classified as low sal


USE [sql_20240206];
-- The column 'employee_dept' was specified multiple times 
--  for 'emp_details_dept_avg'.
GO
CREATE OR ALTER VIEW vw_emp_classification_dept
AS
SELECT *,
	CASE
		WHEN salary > avg_sal THEN 'High Sal'
		ELSE 'Low Sal'
	END AS salary_classification
FROM
(
SELECT emp.*
		,dept_avg_sal.avg_sal
FROM
(
SELECT employee_dept, AVG(salary) AS avg_sal
FROM
employees
GROUP BY 
	employee_dept
) AS dept_avg_sal
INNER JOIN
	employees AS emp
ON
	emp.employee_dept = dept_avg_sal.employee_dept
) AS emp_details_dept_avg




USE [sql_20240206]
GO --- starts a new batch
CREATE OR ALTER  VIEW [dbo].[vw_emp_classification_dept]
AS
SELECT *,
	CASE
		WHEN salary > avg_sal THEN 'High Sal'
		ELSE 'Low Sal'
	END AS salary_classification
	, AVG(salary) OVER() AS avg_sal_of_entire_cmpy
FROM
(
SELECT emp.*
		,dept_avg_sal.avg_sal
FROM
(
SELECT employee_dept, AVG(salary) AS avg_sal
FROM
employees
GROUP BY 
	employee_dept
) AS dept_avg_sal
INNER JOIN
	employees AS emp
ON
	emp.employee_dept = dept_avg_sal.employee_dept
) AS emp_details_dept_avg
GO -- starts a new batch here


USE [sql_20240206]

--- THE view does not store any data, it is not a table
--- everytime the view is executed the underlying SELECT statement is executed
SELECT *
FROM
[dbo].[vw_emp_classification_dept]
WHERE
	salary_classification LIKE 'High Sal'



SELECT TOP 10 * FROM orders;
SELECT TOP 10 * FROM salesman;
SELECT TOP 10 * FROM customers;
SELECT TOP 10 * FROM discounts

GO
CREATE OR ALTER VIEW vw_sales_summary_report
AS
SELECT orders.*
		,salesman.sales_name
		,salesman.sales_location
		,salesman.sales_doj
		,customers.customer_name
		,customers.customer_phone
		,customers.customer_email
		,customers.customer_dob
		,customers.customer_address
		,COALESCE(discounts.disc_perc, 0) AS discount_perc
		,orders.item_price * orders.quantity AS price_b_discount
		,(orders.item_price * orders.quantity) - 
				((orders.item_price * orders.quantity) *
					COALESCE(discounts.disc_perc, 0) /100) AS price_a_discount
FROM
orders 
INNER JOIN
salesman
ON
orders.salesman_id = salesman.sales_id
INNER JOIN
customers
ON
orders.customer_id = customers.customer_id
LEFT OUTER JOIN
discounts
ON
DATEPART(YYYY, orders.purchase_date)  = discounts.disc_year
AND
DATEPART(M, orders.purchase_date) = discounts.disc_month




SELECT
	*
	, DENSE_RANK()OVER(ORDER BY total_sales DESC) AS sales_rank
FROM
(
	SELECT salesman_id, sales_name,
			SUM(price_a_discount) AS total_sales
	FROM dbo.[vw_sales_summary_report]
	GROUP BY
		salesman_id, sales_name
) AS sales_total_sales


-- CREATE A View using a Common Table expression
-- THE GO statement creates a BATCH
GO
CREATE OR ALTER VIEW vw_sales_summary_cte
AS
WITH
	sales_summary
	AS
	(
SELECT orders.*
		,salesman.sales_name
		,salesman.sales_location
		,salesman.sales_doj
		,customers.customer_name
		,customers.customer_phone
		,customers.customer_email
		,customers.customer_dob
		,customers.customer_address
		,COALESCE(discounts.disc_perc, 0) AS discount_perc
FROM
orders 
INNER JOIN
salesman
ON
orders.salesman_id = salesman.sales_id
INNER JOIN
customers
ON
orders.customer_id = customers.customer_id
LEFT OUTER JOIN
discounts
ON
DATEPART(YYYY, orders.purchase_date)  = discounts.disc_year
AND
DATEPART(M, orders.purchase_date) = discounts.disc_month
)
,

sales_summary_price_b_discount --- This is the second common table expression
AS
(
SELECT * 
,item_price * quantity AS price_b_discount
,(item_price * quantity * discount_perc /100) AS discounted_amount
FROM 
sales_summary
)

SELECT *,
	price_b_discount - discounted_amount AS price_a_discount
FROM 
	sales_summary_price_b_discount;


SELECT
	*
	, DENSE_RANK()OVER(ORDER BY total_sales DESC) AS sales_rank
FROM
(
	SELECT salesman_id, sales_name,
			SUM(price_a_discount) AS total_sales
	FROM dbo.[vw_sales_summary_report]
	GROUP BY
		salesman_id, sales_name
) AS sales_total_sales


-- Refresh The Cache
	-- EDIT ---> Intellisense ---> Refresh Local Cache CTRL + SHFT + R


SELECT
	*
	, DENSE_RANK()OVER(ORDER BY total_sales DESC) AS sales_rank
FROM
(
SELECT salesman_id, sales_name,
			SUM(price_a_discount) AS total_sales
	FROM dbo.[vw_sales_summary_cte]
	GROUP BY
		salesman_id, sales_name
) AS salesman_total_sales



-- create a view from the employees table such that the view will contain all the 
-- rows and all the columns ?
GO
CREATE OR ALTER VIEW vw_employees
AS
SELECT *
FROM employees;


SELECT *
FROM 
	vw_employees
WHERE
	employee_dept = 'SD-Web'

-- ALTER the view so that the view only returns records for Employees who work
-- in the SD-DB department??

GO
CREATE OR ALTER VIEW vw_employees
AS
SELECT *
FROM employees
WHERE employee_dept = 'SD-DB'

-- USE THE view to select the data
SELECT *
FROM
vw_employees;

--- YOU can use View to update, insert or delete records from the undelying table
--- when the view is created using a single table

-- The HR of the SD-DB inserted data for a new employee using the view
INSERT INTO vw_employees
VALUES
(
	406
	,'Devarashi Maharisha Prasada'
	,'devamamaha@dummyemail.com'
	,'SD-DB'
	,100001
);

SELECT * FROM employees
WHERE
employee_id = 403

-- The HR of the SD-DB update EMPLOYEE data using a view
SELECT *, CEILING(salary * 1.1) AS salary_a_hike
FROM
vw_employees
WHERE
salary <=
(
SELECT AVG(salary) FROM vw_employees
)

-- whole number divided by a whole number will not give fractional values
-- whole number divided by a whole number will always give a whole number
SELECT ((100 + 10)/(100))

SELECT CAST(110 AS DECIMAL(6, 2)) /100

SELECT CEILING(1.76)
SELECT CAST(5 AS DECIMAL(3,1)) /3

--- use the VIEW to update the salary of all employees of the SD-DB department
--- whose salary is less than the AVG salary of the SD-DB department
UPDATE vw_employees
SET salary = CEILING(salary * 1.1)
WHERE
salary <=
(
SELECT AVG(salary) FROM vw_employees
);


SELECT * FROM employees
WHERE
employee_id = 403

DELETE FROM vw_employees
WHERE
employee_id = 403;

--- HR is now using this query to INSERT UPDATE and delete records from other departments

SELECT * FROM vw_employees

UPDATE vw_employees
SET
	employee_dept = 'SD-WEB'
WHERE
employee_id = 101;

SELECT * FROM employees WHERE employee_id = 101;

-- HR is now using this view to insert data for other departments
-- This is not the expected behavior
INSERT INTO vw_employees
VALUES
(
	404
	,'Ramana Maharisha Prasada'
	,'ramanamaha@dummyemail.com'
	,'SD-Report'
	,100001
);

-- with CHECK OPTION will prevent the view from INSERT, DELETE and UPDATE
-- records where the WHERE CLAUSE is violated
-- in the below view the WHERE clause is employee_dept = 'SD-DB'
GO
CREATE OR ALTER VIEW vw_employees
AS
SELECT *
FROM employees
WHERE 
	employee_dept = 'SD-DB' -- INSERT, UPDATE and DELETE where the WHERE condition is meet
AND
	salary < 75000
WITH CHECK OPTION;

SELECT * FROM vw_employees

---The attempted insert or update failed because the target view 
--- either specifies WITH CHECK OPTION or spans a view that specifies 
--- WITH CHECK OPTION and one or more rows resulting from the operation 
--- did not qualify under the CHECK OPTION constraint.

-- In the below update the WHERE clause is violated as the salary is not < 75000
--- the salary should always be less than 75000 as the  VIEW was created with a 
--- WITH CHECK OPTION
UPDATE vw_employees
SET salary = 100000
WHERE
employee_id = 135


--- The INSERT cannot be done using the VIEW below
--- as INSERT TO the underlying table, employees would require the PRIMARY KEY
--- the primary key is employee_id and the employee_id is not part of the view

-- WITH CHECK OPTION will ensure that the records affected by the INSERT,
--- UPDATE or DELETE must be from employee_dept = 'SD-DB'
--- AND salary < 75000
GO
CREATE OR ALTER VIEW vw_employees
AS
SELECT employee_name
		,employee_email
		,employee_dept
		,salary
FROM employees
WHERE 
	employee_dept = 'SD-DB' -- INSERT, UPDATE and DELETE where the WHERE condition is meet
AND
	salary < 75000
WITH CHECK OPTION;



SELECT *, salary * 1.02 AS new_salary FROM vw_employees
WHERE salary  <35000


--- the below UPDATE statement can run without any problems as
--- the below UPDATE statement needs only the salary column in the
--- SET and the WHERE clause and the salary column is part of the view 
UPDATE  vw_employees
SET 
	salary = salary * 1.02
WHERE
	salary < 35000


--- the below UPDATE statement can run without any problems as
--- the below UPDATE statement needs the salary column in the
--- SET clause
--- and needs the employee_name column in the WHERE clause
UPDATE 
	vw_employees
SET 
	salary = salary - 1000
WHERE 
	employee_name LIKE '%Das%'

-- always do a SELECT TO see the records that will be affected by the UPDATE or DELETE statement
-- the SELECT statement will give a clear idea on which columns 
-- will be affected by the UPDATE or DELETE statement
SELECT *
FROM
vw_employees
WHERE employee_name LIKE '%Das%'

SELECT * FROM vw_employees

-- The below query will not work although all the conditions of the WITH CHECK OPTION
-- is satisfied because the primary key Employee_id is not part of the INSERT
-- statement
INSERT INTO vw_employees
VALUES
('Shrithi Devi Kurdimat'
,'shruthidevi@dummyemail.com'
,'SD-DB'
,70000
);

EXEC sp_help employees;