USE [sql_202401]

SELECT * FROM employees;

-- What is a STORED PROCEDURE
-- Creating a BASIC stored procedure
-- Executing a STORED Procedure
-- Making changes to a STORED Procedure
-- Deleting a Stored Procedure

-- A stored procedure is a GROUP OF SQL STATMENTS grouped together
-- under a name
-- it has similar benefits the main one is speed and analysis
-- If I need to run the query many times I need to run it many times
USE sql_202401;
GO
CREATE OR ALTER PROC sp_employee_max_sal_by_dept
AS
 BEGIN
	SELECT
		employees.*
	FROM
		employees
	INNER JOIN
		(
			SELECT 
				employee_dept
				,MAX(salary) AS max_salary
			FROM
				employees
			GROUP BY
				employee_dept
		) AS max_sal_dept
	ON
		employees.employee_dept = max_sal_dept.employee_dept
	AND
		employees.salary = max_sal_dept.max_salary
	ORDER BY
		employees.salary DESC
	END

-- This is how we create a stored procedure
-- There are several choices we have on how to execute the STORED PROCEDURE

EXEC sp_employee_max_sal_by_dept;

-- To remove a STORED Procedure
DROP PROC IF EXISTS sp_employee_max_sal_by_dept;

-- How can we add parameters in stored procedure in Microsoft SQL Server

-- What are parameters?
-- Creating Parameters?
-- Executing Procedure with Parameters?
-- Optional Parameters and Default Values?

-- In the previous example we the stored procedure is like a simple SELECT statement
-- in the first step
-- In this exAMPLE, We will add parameters to a stored procedure
USE sql_202401;
GO
CREATE OR ALTER PROC sp_get_top_n_emps_dept
				(
					@department_name VARCHAR(60),
					@emp_count INT = 10 --- Example of a DEFAULT PARAMETER
				)
	AS
	BEGIN
		SELECT *
		FROM
		(
		SELECT *,
				DENSE_RANK() OVER(ORDER BY salary DESC) AS salary_rank
		FROM
			employees
		) AS sub_q_1
		WHERE
			sub_q_1.salary_rank <= @emp_count

	END;

EXEC sp_get_top_n_emps_dept @department_name = 'SD-DB',
							@emp_count = 5;

-- What are variables
-- How to declare a Variable?
-- How to assign a value to a Variable?
-- How to refer to a variable in a Query

-- Usage of Variables?
-- How to store variables in a QUERY?
-- Display the results of a Variable?
-- Reading Records into a Variable?
-- Global Variables?

-- a value stored in a memory location
-- to set a variable of the variable we can use the SET KEYWORD to 
-- set the name of the variable
USE sql_202401;
DECLARE @avg_salary DECIMAL(10,2);
SELECT @avg_salary = AVG(CAST(salary AS DECIMAL(10, 2)))
FROM
employees;
PRINT 'The average salary of the entire organization is ' + 
		CAST(@avg_salary AS VARCHAR(10)); -- This output will be seen in the messages tab
WITH
	emp_classification_tab
AS
(
SELECT employees.*
	,'High Salary' AS salary_classification
FROM
	employees
WHERE
	salary >@avg_salary

UNION ALL

SELECT 
	employees.*
	,'Low Salary' AS salary_classification
FROM
	employees
	WHERE
	salary <= @avg_salary
)

--
SELECT * FROM emp_classification_tab;

DECLARE @max_salary AS INT;
DECLARE @min_salary AS INT;
DECLARE @avg_salary AS DECIMAL(10, 2);

SELECT @max_salary = MAX(salary)
		,@min_salary = MIN(salary)
		,@avg_salary = AVG(salary)
FROM
	employees


PRINT @max_salary;
PRINT @min_salary;
PRINT @avg_salary;


DECLARE @name_list AS VARCHAR(MAX);
SET @name_list  = '';

SELECT @name_list = @name_list + employee_name + '|'
FROM
	employees
WHERE
	salary>= @max_salary * 0.85;
PRINT @name_list;

	-- OUTPUT Parameters and Return Value in SQL SERVER
	-- GETTING RETURN values out of a Stored procedure
	-- Using Return Values in a Stored Procedure
	USE sql_202401;
	GO
	CREATE OR ALTER PROC sp_get_avg_sal_dept
					(
						@department_name AS VARCHAR(30)
						,@max_salary AS INT OUTPUT
						,@min_salary AS INT OUTPUT
						,@avg_salary AS DECIMAL(10, 2) OUTPUT
						,@emp_count AS INT OUTPUT
					)
			AS
				BEGIN

					DECLARE @min_salary_local AS INT;
					DECLARE @max_salary_local AS INT;
					DECLARE @avg_salary_local AS DECIMAL(10, 2);
					DECLARE @emp_count_local AS INT;

					SELECT @min_salary_local = MIN(salary)
						  ,@max_salary_local = MAX(salary)
						  ,@avg_salary_local = AVG(salary)
						  ,@emp_count_local = COUNT(employee_id)
					FROM
						employees
					WHERE
						employee_dept = @department_name

					SET @max_salary = @max_salary_local
					SET @min_salary = @min_salary_local
					SET @avg_salary = @avg_salary_local
					SET @emp_count = @emp_count_local
				END

	DECLARE @max_sal AS INT;
	DECLARE @min_sal AS INT;
	DECLARE @avg_sal AS DECIMAL(10, 2);
	DECLARE @emp_cnt AS INT;

	EXEC sp_get_avg_sal_dept
				@department_name = 'SD-Web'
				,@max_salary = @max_sal OUTPUT
				,@min_salary = @min_sal OUTPUT
				,@avg_salary = @avg_sal OUTPUT
				,@emp_count  = @emp_cnt OUTPUT

	SELECT @max_sal;
	SELECT @min_sal;
	SELECT @avg_sal;
	SELECT @emp_cnt;
