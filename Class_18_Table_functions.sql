--- scalar Table functions
USE [sql_wkday_20240228]
GO
CREATE OR ALTER FUNCTION fn_abv_avg_sal_emp
	(
		@department_name AS VARCHAR(30)
	)
	RETURNS TABLE
	AS
		RETURN
		SELECT *,
			(SELECT AVG(salary * 1.00000) FROM employees
				WHERE employee_dept = @department_name
			) AS avg_salary
		FROM
		employees
		WHERE
		salary > (
				SELECT AVG(salary * 1.0000) FROM employees
				WHERE
				employee_dept = @department_name
			 )
		AND
			employee_dept = @department_name;


SELECT * FROM fn_abv_avg_sal_emp('SD-Web')

-- Declare the table variable
DECLARE @emp_abv_avg_sal TABLE
(
	employee_id INT
	,employee_name VARCHAR(100)
	,employee_email VARCHAR(100)
	,department_name VARCHAR(30)
	,employee_salary INT
	,department_avg_salary DECIMAL(10, 2)
)
--- populate the table variable
INSERT INTO @emp_abv_avg_sal
SELECT * FROM dbo.fn_abv_avg_sal_emp('SD-Infra')

SELECT * FROM @emp_abv_avg_sal
ORDER BY employee_salary DESC;

USE [sql_wkday_20240228]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_abv_avg_sal_emp]    Script Date: 28-03-2024 20:34:52 ******/


ALTER   FUNCTION [dbo].[fn_abv_avg_sal_emp]
	(
		@department_name AS VARCHAR(30)
	)
	RETURNS TABLE
	AS

	RETURN
		SELECT *,
			(SELECT AVG(salary * 1.00000) FROM employees
				WHERE employee_dept = @department_name
			) AS avg_salary
			,'High Salary' AS salary_classification
		FROM
		employees
		WHERE
		salary > (
				SELECT AVG(salary * 1.0000) FROM employees
				WHERE
				employee_dept = @department_name
			 )
		AND
			employee_dept = @department_name;
	GO



SELECT * FROM [dbo].[fn_abv_avg_sal_emp]('SD-Report')


DECLARE @emp_abv_avg_sal TABLE
(
	employee_id INT
	,employee_name VARCHAR(100)
	,employee_email VARCHAR(100)
	,department_name VARCHAR(30)
	,employee_salary INT
	,blood_group CHAR(4)
	,department_avg_salary DECIMAL(10, 2)
	,classification_based_salary CHAR(20)
)
--- populate the table variable
INSERT INTO @emp_abv_avg_sal
SELECT * FROM dbo.fn_abv_avg_sal_emp('SD-Infra')

SELECT * FROM @emp_abv_avg_sal
ORDER BY employee_salary DESC;


--- where we had to find the top 10 people whose salary was closest to the average salary
USE sql_wkday_20240228
GO
CREATE OR ALTER FUNCTION fn_get_empl_near_avg_sal
	(
		@department_name VARCHAR(100)
	)
	RETURNS TABLE
	AS
		RETURN
		SELECT employee_id
				, employee_name
				,employee_dept
				,salary
				,avg_sal
				,sal_diff_avg_sal
				,sal_diff_rank
		FROM
		(
		SELECT *,
				DENSE_RANK() OVER(ORDER BY sal_diff_avg_sal ASC) AS sal_diff_rank
		FROM
		(
		SELECT *,
				ABS(salary - avg_sal) AS sal_diff_avg_sal
		FROM
		(
			SELECT *,
				(SELECT AVG(salary * 1.00) FROM employees) AS avg_sal
			FROM
				employees
			WHERE
				employee_dept = 'SD-DB' ---@department_name
		) AS sub_q_1
		) AS sub_q_2
		) AS sub_q_3
		WHERE
		sub_q_3.sal_diff_rank < = 10
		
SELECT * FROM dbo.fn_get_empl_near_avg_sal('SD-DB', 20)

--- DEFAULT ARGUMENT
USE sql_wkday_20240228
GO
CREATE OR ALTER FUNCTION fn_get_empl_near_avg_sal
	(
		@department_name VARCHAR(100)
		,@emp_count INT  = 10
	)
	RETURNS TABLE
	AS
		RETURN
		SELECT employee_id
				, employee_name
				,employee_dept
				,salary
				,avg_sal
				,sal_diff_avg_sal
				,sal_diff_rank
		FROM
		(
		SELECT *,
				DENSE_RANK() OVER(ORDER BY sal_diff_avg_sal ASC) AS sal_diff_rank
		FROM
		(
		SELECT *,
				ABS(salary - avg_sal) AS sal_diff_avg_sal
		FROM
		(
			SELECT *,
				(SELECT AVG(salary * 1.00) FROM employees) AS avg_sal
			FROM
				employees
			WHERE
				employee_dept = 'SD-DB' ---@department_name
		) AS sub_q_1
		) AS sub_q_2
		) AS sub_q_3
		WHERE
		sub_q_3.sal_diff_rank < = @emp_count
		

SELECT * FROM dbo.fn_get_empl_near_avg_sal('SD-DB', 5)
---
-- multi STATEMENT table valued function
-- we can use multiple select statements
-- populate a table using multiple select statements
-- return the value of the multiple select statements

-- defining a Multi Statement


USE [sql_wkday_20240228]
GO
CREATE OR ALTER FUNCTION fn_classify_emps_dept
(
	@department_name VARCHAR(50)
)
RETURNS @t TABLE
(
	employee_id INT PRIMARY KEY
	,employee_name VARCHAR(100)
	,employee_dept_name VARCHAR(60)
	,salary INT
	,avg_sal_dept DECIMAL(10, 2)
)
AS
	BEGIN
		INSERT INTO @t
		SELECT employee_id
				,employee_name
				,employee_dept
				,salary
				,(SELECT AVG(salary) FROM employees
					WHERE employee_dept = @department_name
				  ) AS average_salary
		FROM
			employees
		WHERE
			employee_dept = @department_name



		RETURN 
	END

SELECT * FROM dbo.fn_classify_emps_dept('SD-WEB');


USE [sql_wkday_20240228]
GO
CREATE OR ALTER FUNCTION fn_classify_emps_dept
(
	@department_name VARCHAR(50)
)
RETURNS @t TABLE
(
	employee_id INT PRIMARY KEY
	,employee_name VARCHAR(100)
	,employee_dept_name VARCHAR(60)
	,salary INT
	,avg_sal_dept DECIMAL(10, 2)
	,salary_classification VARCHAR(20)
)
AS
	BEGIN
		INSERT INTO @t
		SELECT employee_id
				,employee_name
				,employee_dept
				,salary
				,avg_sal_dept.avg_salary AS average_salary_dept
				,'High Sal' AS salary_classification
		FROM
			employees
		CROSS JOIN
			(
				SELECT AVG(salary) AS avg_salary
				FROM
					employees
				WHERE
					employee_dept = @department_name
			 ) AS avg_sal_dept
		WHERE
			employee_dept = @department_name
		AND
			employees.salary > avg_sal_dept.avg_salary---- @department_name

		INSERT INTO @t
		SELECT employee_id
				,employee_name
				,employee_dept
				,salary
				,avg_sal_dept.avg_salary AS average_salary_dept
				,'Low Sal' AS salary_classification
		FROM
			employees
		CROSS JOIN
			(
				SELECT AVG(salary) AS avg_salary
				FROM
					employees
				WHERE
					employee_dept = @department_name
			 ) AS avg_sal_dept
		WHERE
			employee_dept = @department_name
		AND
			employees.salary <= avg_sal_dept.avg_salary---- @department_name

		RETURN 
	END

SELECT * FROM dbo.fn_classify_emps_dept('SD-WEB');
--- Get the top 10 people whose salary is closest to the avg_sal of a dept
--- get the top 10 people whose salary is farthest  to the avg_sal of a dept


--- STORED PROCS
--- UDF
--- VARIABLES
--- CURSORS

--- CURSORS

SELECT * FROM employees;
USE sql_wknd_20240128

-- cursor is designed to point at a single record at a time
-- and a cursor is designed to move through each record one at a time
-- cursor gives u a much finer level of control
-- example you can execute a stored procedure over an individual record


-- the other downside is that cursor work slowly and they are inevitably slower than
-- other set based operations

-- declare a cursor
DECLARE employee_cursor CURSOR
	FOR
		SELECT * FROM employees

--after you declare a cursor you need to open the cursor
-- the statement to open the cursor is 
OPEN employee_cursor

-- do something useful
-- move the cursor to a record
	FETCH NEXT FROM employee_cursor
	
-- to make my cursor useful, I should be able to
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH NEXT FROM employee_cursor
		END
CLOSE employee_cursor
--- good house 
DEALLOCATE employee_cursor

-- declare a cursor
DECLARE employee_cursor CURSOR SCROLL 
	FOR
		SELECT * FROM employees

--after you declare a cursor you need to open the cursor
-- the statement to open the cursor is 
OPEN employee_cursor

-- do something useful
-- move the cursor to a record
	FETCH ABSOLUTE -10 FROM employee_cursor
	
-- to make my cursor useful, I should be able to
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH RELATIVE -10 FROM employee_cursor
		END
CLOSE employee_cursor
--- good house 
DEALLOCATE employee_cursor



-- declare a cursor
DECLARE employee_cursor CURSOR
	FOR
		SELECT * FROM employees

--after you declare a cursor you need to open the cursor
-- the statement to open the cursor is 
OPEN employee_cursor

-- do something useful
-- move the cursor to a record
	FETCH NEXT FROM employee_cursor
-- to make my cursor useful, I should be able to
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH NEXT FROM employee_cursor
		END
CLOSE employee_cursor
--- good house 
DEALLOCATE employee_cursor

-- You do not always move one step forward in a cursor

DECLARE employee_cursor CURSOR SCROLL
	FOR
		SELECT * FROM employees

--after you declare a cursor you need to open the cursor
-- the statement to open the cursor is 
OPEN employee_cursor

-- do something useful
-- move the cursor to a record
	FETCH LAST FROM employee_cursor -- FETCH LAST
-- to make my cursor useful, I should be able to
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH PRIOR FROM employee_cursor
		END
CLOSE employee_cursor
--- good house 
DEALLOCATE employee_cursor

-- MOVE The cursor non sequantially
-- we can ask the cursor to move to any numbered record

DECLARE employee_cursor CURSOR SCROLL
	FOR
		SELECT * FROM employees

--after you declare a cursor you need to open the cursor
-- the statement to open the cursor is 
OPEN employee_cursor

-- do something useful
-- move the cursor to a record
-- FETCH NEGETIVE 10 RECORDS from the end of the cursor
	FETCH ABSOLUTE -10 FROM employee_cursor -- FETCH LAST
-- to make my cursor useful, I should be able to
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH RELATIVE -10 FROM employee_cursor
		END
CLOSE employee_cursor
--- good house 
DEALLOCATE employee_cursor

-- HOW TO use CURSORS with a STORED PROC?
-- FIRST NORMAL FORM - THIRD NORMAL FORM
-- WINDOWS FUNCTIONS (LAG, LEAD , NTILE)
-- SUBQUERIES
-- COORELATED SUBQUERIES
-- STORED PROCS return a scalar value
