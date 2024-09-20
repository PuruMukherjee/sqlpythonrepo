USE [sql_wkday_20240228]

SELECT *,
		TRIM(RIGHT(sales_location,
				LEN(sales_location) - CHARINDEX(' ', sales_location)))
		FROM salesman

SELECT *,
		TRIM(RIGHT(customer_address,
				LEN(customer_address) - CHARINDEX(' ', customer_address)))
	FROM customers

-- UDF
USE sql_wkday_20240228
GO
CREATE OR ALTER FUNCTION fn_get_state_name
	(
		@address AS VARCHAR(100)
	)
	RETURNS VARCHAR(100)
	AS
		BEGIN
			DECLARE @state_name AS VARCHAR(100)

			SELECT @state_name = 
					TRIM(RIGHT(@address,
						LEN(@address) - CHARINDEX(' ', @address)))

			RETURN @state_name
		END

-- the above function returns a scalar value or a single value
-- hence these types of functions are called as SCALAR valued functions

SELECT *
	, [dbo].[fn_get_state_name](sales_location)
FROM
salesman;


SELECT *,
	dbo.fn_get_state_name(customers.customer_address)
FROM
	customers

-- write a function that will fetch the city name?
USE sql_wkday_20240228;
GO
CREATE OR ALTER FUNCTION fn_get_city_name	(		@address AS VARCHAR(100)	)	RETURNS VARCHAR(100)	AS		BEGIN			DECLARE @city_name AS VARCHAR(100)			SELECT @city_name = 					TRIM(LEFT(@address,CHARINDEX(',', @address)))			RETURN @city_name		END'Panaji, Goa'SELECT * ,dbo.fn_get_city_name (sales_location)FROM salesman;USE [sql_wkday_20240228]
GO


CREATE OR ALTER  FUNCTION [dbo].[fn_get_city_name]
	(
		@address AS VARCHAR(100)
	)
	RETURNS VARCHAR(100)
	AS
		BEGIN
			DECLARE @city_name AS VARCHAR(100)

			SELECT @city_name = 
					REPLACE(TRIM(LEFT(@address, CHARINDEX(',', @address)-1 )),
						',', '')

			RETURN @city_name
		END
GO

SELECT *
	, [dbo].fn_get_city_name(customers.customer_address) AS city_name
	, dbo.fn_get_state_name(customer_address) AS state_name
	, DATENAME(DW, customer_dob) + ' ' +
	  DATENAME(D, customer_dob) +
	  CASE
		WHEN DATENAME(D, customer_dob) IN (1, 21, 31) THEN 'st'
		WHEN DATENAME(D, customer_dob) IN (2, 22) THEN 'nd'
		WHEN DATENAME(D, customer_dob) IN (3, 23) THEN 'rd'
		ELSE 'th'
		END + ' '+
		DATENAME(M , customer_dob) + ' ' +
		DATENAME(YYYY, customer_dob) AS detailed_dob
FROM
	customers;


SELECT * FROM orders;
SELECT * FROM salesman

USE sql_wkday_20240228
GO
CREATE OR ALTER FUNCTION fn_get_detailed_date
	(
		@datevalue AS DATETIME
	)
	RETURNS NVARCHAR(100)
	AS
		BEGIN
		DECLARE @detailed_date_format AS VARCHAR(100)

		SELECT
			@detailed_date_format = 
			DATENAME(DW, @datevalue) + ' ' +
			DATENAME(D, @datevalue) + 
			CASE
					WHEN DATENAME(D, @datevalue) IN (1, 21, 31) THEN 'st'
					WHEN DATENAME(D, @datevalue) IN (2, 22) THEN 'nd'
					WHEN DATENAME(D, @datevalue) IN (3, 23) THEN 'rd'
					ELSE 'th'
			END + ' ' +
			DATENAME(M , @datevalue) + ' ' +
			DATENAME(YYYY, @datevalue)

			RETURN @detailed_date_format
		END



SELECT *,
	[dbo].[fn_get_detailed_date](customer_dob) AS detailed_dob
FROM
customers


USE sql_wkday_20240228
GO
CREATE OR ALTER FUNCTION fn_get_detailed_date
	(
		@datevalue AS DATETIME
	)
	RETURNS NVARCHAR(100)
	AS
		BEGIN
		DECLARE @detailed_date_format AS VARCHAR(100)
		-- NESTED IF STATEMENTS
		-- ELIF
		DECLARE @suffix_val AS CHAR(2)

		SET @suffix_val = ''

		IF DATENAME(D, @datevalue) = '1' OR
			DATENAME(D, @datevalue) = '21' OR
			DATENAME(D, @datevalue) = '31'
			BEGIN
				SET @suffix_val = 'st'
			END
		ELSE
			BEGIN
				IF DATENAME(D, @datevalue) = '2' OR
					DATENAME(D, @datevalue) = '22'
					BEGIN
					SET @suffix_val = 'nd'
					END
				ELSE
					BEGIN
						IF DATENAME(D, @datevalue) = '3' OR
							DATENAME(D, @datevalue) = '23'
							BEGIN
								SET @suffix_val = 'rd'
							END
						ELSE
							BEGIN
								SET @suffix_val = 'th'
							END
					END
			END

		SELECT
			@detailed_date_format = 
			DATENAME(DW, @datevalue) + ' ' +
			DATENAME(D, @datevalue) + @suffix_val +
			 ' ' +
			DATENAME(M , @datevalue) + ' ' +
			DATENAME(YYYY, @datevalue)

			RETURN @detailed_date_format
		END



USE sql_wkday_20240228
GO
CREATE OR ALTER FUNCTION fn_get_detailed_date
	(
		@datevalue AS DATETIME
	)
	RETURNS NVARCHAR(100)
	AS
		BEGIN
		DECLARE @detailed_date_format AS VARCHAR(100)
		-- NESTED IF STATEMENTS
		-- ELIF
		DECLARE @suffix_val AS CHAR(2)

		SET @suffix_val = ''

		IF DATENAME(D, @datevalue) = '1' OR
			DATENAME(D, @datevalue) = '21' OR
			DATENAME(D, @datevalue) = '31'
			BEGIN
				SET @suffix_val = 'st'
			END
		ELSE IF DATENAME(D, @datevalue) = '2' OR
				DATENAME(D, @datevalue) = '22'
				BEGIN
					SET @suffix_val = 'nd'
				END
		ELSE IF DATENAME(D, @datevalue) = '3' OR
				DATENAME(D, @datevalue) = '23' 
				BEGIN
					SET @suffix_val = 'rd'
				END
		ELSE
				BEGIN
					SET @suffix_val = 'th'
				END

		SELECT
			@detailed_date_format = 
			DATENAME(DW, @datevalue) + ' ' +
			DATENAME(D, @datevalue) + @suffix_val +
			 ' ' +
			DATENAME(M , @datevalue) + ' ' +
			DATENAME(YYYY, @datevalue)

			RETURN @detailed_date_format
		END

		SELECT *,
	[dbo].[fn_get_detailed_date](customer_dob) AS detailed_dob
FROM
customers

--- end of Scalar UDF ---------------

--- STEP 1 >>> DECLARE a table variable
DECLARE @avg_sal_dept TABLE
	(
		department_name VARCHAR(20) PRIMARY KEY
		,average_salary DECIMAL(10, 2)
	)

--- STEP 2 >>> Populate a table variable
INSERT INTO @avg_sal_dept
SELECT employees.employee_dept,
	   AVG(employees.salary * 1.0000) AS avg_sal
FROM
	employees
GROUP BY
	employees.employee_dept;

--- STEP 3 >>> SELECT from a table variable. 
SELECT * FROM @avg_sal_dept
WITH
	emp_avg_sal
AS
(
SELECT *
FROM
@avg_sal_dept AS tab_v
INNER JOIN
employees
ON
	employees.employee_dept = tab_v.department_name
)

SELECT *
	, CASE
		WHEN	salary > average_salary THEN 'High Sal'
		ELSE 'Low Sal'
	  END AS salary_classification
FROM
	emp_avg_sal
ORDER BY
	employee_dept, salary


SELECT * FROM @avg_sal_dept

DROP TABLE IF EXISTS #temp_table
SELECT employees.employee_dept,
	   AVG(employees.salary * 1.0000) AS avg_sal
	   INTO #temp_table
FROM
	employees
GROUP BY
	employees.employee_dept

-- There is already an object named '#temp_table' in the database.
DROP TABLE IF EXISTS #temp_table
SELECT * INTO
	#temp_table
FROM
	employees
WHERE
	employee_dept = 'SD-Web'




-- Table Variables
DECLARE @max_salary_dept TABLE
	(
		department_name VARCHAR(40) PRIMARY KEY,
		max_salary DECIMAL(10, 2)
	);

-- Inserting data into a table variable
INSERT INTO @max_salary_dept
SELECT employees.employee_dept, MAX(employees.salary)
FROM
employees
GROUP BY 
employees.employee_dept

SELECT * FROM @max_salary_dept

--- use table variables to get the employees who earn the max salary in their department
------ use table variables to get the employees who earn the min salary in their department
--- --- use table variables to get the employees who earn more than the 1.5 times the average salary in their department

--- use table variables to get the employees who earn the max salary in their department USE sql_wkday_20240228DECLARE @max_salary_dept TABLE(    department_name VARCHAR(40) PRIMARY KEY,    max_salary DECIMAL(10, 2));-- Inserting data into a table variableINSERT INTO @max_salary_deptSELECT employees.employee_dept, MAX(employees.salary) AS max_salaryFROM employeesGROUP BY employees.employee_dept;-- who earn the max salary in their departmentSELECT employees.*FROM employeesINNER JOIN 	@max_salary_dept msdON 	employees.employee_dept = msd.department_nameAND	employees.salary = msd.max_salary;

--- any employees who gets lower than 80%  of the average salary--- in their respective department is classified as Low SAL--- any employees who get between 80 and 150% of the average salary is classified as Average SAL--- any employee who gets above 150% of the average salary is High SAL--- UNION of all employees who get a salary lower --- than the average salary of their respective departments?--- with all the employees who get a salary HIGHER than the average salaryDECLARE @max_salary_dept TABLE(    employee_id INT PRIMARY KEY,    employee_name VARCHAR(100),	employee_dept VARCHAR(100),	salary INT,	avg_salary DECIMAL(10, 2),	salary_classification CHAR(20))DECLARE @avg_salary DECIMAL(10, 2)SELECT @avg_salary = AVG(salary * 1.000) FROM employeesINSERT INTO @max_salary_deptSELECT		employee_id	,employee_name	,employee_dept	,salary	,@avg_salary AS avg_salary	,'High Salary' AS salary_classificationFROM	employeesWHERE	salary > @avg_salaryINSERT INTO @max_salary_deptSELECT		employee_id	,employee_name	,employee_dept	,salary	,@avg_salary AS avg_salary	,'Low Salary' AS salary_classFROM	employeesWHERE	salary <= @avg_salarySELECT * FROM @max_salary_deptORDER BY salary_classification--- question -- find a UNION of top 10 people whose salary is closest to the average  of the entire company-- top 10 people whose salary is the farthest from the average of the entire company?--- get the top 5 employee from each departments whose salaies are closest--  or fartheset from the average salary
--- Question <2> Find the top 3 customer based on their total purchase after discount


--- table functions