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

--- how to we use cursors to assign values to variables
GO
DECLARE @employee_id INT
DECLARE @employee_name VARCHAR(100)
DECLARE @employee_department_name VARCHAR(30)
DECLARE @employee_salary INT
DECLARE @average_salary DECIMAL(10, 2)
DECLARE @emp_salary_status_msg AS VARCHAR(100)
 
DECLARE employee_cursor CURSOR
	FOR
		SELECT employee_id
				,employee_name
				,employee_dept
				,salary
				,AVG(salary) OVER() AS average_salary
		FROM
			employees
		WHERE
			employee_dept = 'SD-Web'
		ORDER BY
			salary DESC

OPEN employee_cursor

		FETCH NEXT FROM employee_cursor
			INTO	
				@employee_id
				,@employee_name
				,@employee_department_name
				,@employee_salary
				,@average_salary

		WHILE @@FETCH_STATUS = 0
			
		BEGIN
			
		IF @employee_salary > @average_salary 
			BEGIN
				SET @emp_salary_status_msg = 
				 ' employee salary is greater than  to the Average salary'		
			END
		ELSE
			BEGIN
				
					SET @emp_salary_status_msg = 
				 ' employee salary is less than equal to the Average salary'
			END

			PRINT 
				 CAST(@employee_id AS CHAR(3)) + 
					' ' + @employee_name +
					' ' + @employee_department_name + 
					' ' + CAST(@employee_salary AS VARCHAR(10)) +
					' ' + 'Average salary of ' + 
					@employee_department_name + 
					' is ' + CAST(@average_salary AS CHAR(10)) +
					@emp_salary_status_msg

			FETCH NEXT FROM employee_cursor
				INTO	
					@employee_id
					,@employee_name
					,@employee_department_name
					,@employee_salary
					,@average_salary
			END

CLOSE employee_cursor
DEALLOCATE employee_cursor
	



-- HOW TO use CURSORS with a STORED PROC?
USE sql_wkday_20240228
GO
CREATE OR ALTER PROC sp_get_employee_salary_status_msg
	(
		@employee_id AS INT
		,@employee_name AS VARCHAR(100)
		,@employee_dept AS VARCHAR(40)
		,@employee_salary AS INT
		,@salary_status_message AS VARCHAR(400) OUTPUT
	)AS
	BEGIN
		-- Local variables to be used inside the SP body
		DECLARE @avg_sal AS DECIMAL(10, 2)
		DECLARE @final_message AS VARCHAR(400)
		DECLARE @sal_stats_message AS VARCHAR(200)

		SELECT @avg_sal = AVG(salary)
		FROM
			employees
		WHERE
			employee_dept = @employee_dept

		IF @employee_salary > @avg_sal
			BEGIN
					SET @sal_stats_message = ' Salary of ' +
												@employee_name + ' '
												+ 
												' is greater than the average salary of the department'
			END
		ELSE
			BEGIN
					SET @sal_stats_message = ' Salary of ' +
												@employee_name + ' '
												+ 
												' is less  than or equal to the average salary of the department'
			END

		SET @final_message = 'Employee id = ' 
							+ CAST(@employee_id AS CHAR(3)) + ' '+
							'Name = ' + @employee_name + ' '+
							'Department = ' + @employee_dept + ' ' +
							'Salary = '+ 
							CAST(@employee_salary AS VARCHAR(10)) 
							+ ' '+
							'Average sal of department = ' +
							CAST(@avg_sal AS VARCHAR(10))
							+ ' ' + @sal_stats_message

		SET @salary_status_message = @final_message
	END



-- Call the SP declared above from the body of the cursor

GO
DECLARE @employee_id INT
DECLARE @employee_name VARCHAR(100)
DECLARE @employee_department_name VARCHAR(30)
DECLARE @employee_salary INT
DECLARE @average_salary DECIMAL(10, 2)
DECLARE @emp_salary_status_msg AS VARCHAR(400)
 
DECLARE employee_cursor CURSOR
	FOR
		SELECT employee_id
				,employee_name
				,employee_dept
				,salary
		FROM
			employees
		WHERE
			employee_dept = 'SD-Web'
		ORDER BY
			salary DESC

OPEN employee_cursor

		FETCH NEXT FROM employee_cursor
			INTO	
				@employee_id
				,@employee_name
				,@employee_department_name
				,@employee_salary
				

		WHILE @@FETCH_STATUS = 0
			
		BEGIN

			EXEC sp_get_employee_salary_status_msg 
				@employee_id = @employee_id
				,@employee_name = @employee_name
				,@employee_dept = @employee_department_name
				,@employee_salary = @employee_salary
				,@salary_status_message  = @emp_salary_status_msg OUTPUT

			PRINT @emp_salary_status_msg
			
			FETCH NEXT FROM employee_cursor
				INTO	
					@employee_id
					,@employee_name
					,@employee_department_name
					,@employee_salary
					
			END

CLOSE employee_cursor
DEALLOCATE employee_cursor


-- DYNAMIC QUERY
DECLARE @table_name AS NVARCHAR(40)
SET @table_name = N'customers'
EXEC ('SELECT  TOP 10 * FROM ' + @table_name)



SELECT 'I am at Rajat''s place'

GO
DECLARE @tablename NVARCHAR(128);
DECLARE @SQLstring NVARCHAR(200);
DECLARE @number_of_records INT;
DECLARE @employee_department_name NVARCHAR(40)


SET @tablename = N'employees'
SET @number_of_records = 10
SET @employee_department_name = N'SD-Infra'
SET @SQLstring = N'SELECT  TOP ' + 
				CAST(@number_of_records AS NVARCHAR(4))
								+ ' * FROM ' + @tablename +
								' WHERE employee_dept = ' + 
								+ '''' +@employee_department_name 
								+ ''''

PRINT @SQLstring

EXEC sp_executesql @SQLstring



--- Dynamic SQL
--- What is Dynamic SQL?
--- Two Techniques of executing Dynamic SQL?
--- Building a Dynamic SQL string?

--- Creating Stored Procedure
--- Using parameters
--- The IN operator
--- SQL Injection

--- You can take any valid SQL statement, convert it into a string of text
--- and then execute the valid SQL statement as if it was a real SQL statement

EXECUTE ('SELECT TOP 10 * FROM employees')
--- The second way is a system stored procedure
--- The stored procedure expects a UNICODE character
--- hence the character N is written before the dynamic SQL
EXEC sp_executesql N'SELECT TOP 10 * FROM employees'

-- Which method should I use?
-- we can pass parameters to the second method to run DYNAMIC sql
-- make the table name comes from a variable
DECLARE @tablename NVARCHAR(128);
DECLARE @SQLstring NVARCHAR(200)


SET @tablename = N'employees'
SET @SQLstring = N'SELECT * FROM ' + @tablename
EXEC sp_executesql @SQLstring

EXEC sp_executesql N'SELECT * FROM employees'


EXEC sp_executesql @SQLstring

-- one thing you have to be careful when you are concatinating string
-- is the fact that when you add a  number to the string
GO
DECLARE @tablename NVARCHAR(128);
DECLARE @SQLstring NVARCHAR(200);
DECLARE @number_of_records INT;


SET @tablename = N'employee_information_tab'
SET @number_of_records = 10
SET @SQLstring = N'SELECT TOP '+ CAST(@number_of_records AS NVARCHAR(3)) +
'* FROM ' + @tablename

PRINT @SQLstring
EXEC sp_executesql @SQLstring

-- CREATE a stored procedure where you pass a parameter
-- which you can pass to the stored procedure as a parameter
--
USE sql_wknd_20240128;
GO
CREATE PROC sp_VariableTable
	(
		@tablename NVARCHAR(100)
	)
	AS
		BEGIN
			DECLARE @sqlString NVARCHAR(MAX)
			SET @sqlString = N'SELECT * FROM ' + @tablename
			EXEC sp_executesql @sqlString
		END

EXECUTE sp_VariableTable @tablename = 'employees'

-- dynamic SQL is handy to make the contents of an IN operator
SELECT *
FROM
employees
WHERE
	employee_dept IN ('SD-Web', 'SD-Report')
ORDER BY
	employee_dept

USE sql_wknd_20240128
GO
CREATE OR ALTER PROC sp_fetch_emp_by_dept
	(
		@department_names NVARCHAR(100)
	)
	AS
		BEGIN
			DECLARE @sqlString AS NVARCHAR(200)

			SET @sqlString = N'SELECT * FROM employees WHERE
								employee_dept IN 
								(' + @department_names +
								 ' )
								 ORDER BY employee_dept DESC'
			PRINT @sqlString

			EXEC sp_executesql @sqlString;
		END

EXEC sp_fetch_emp_by_dept @department_names = '''SD-Web'', ''SD-DB'' '


-- THE sp_executesql has its own set of parameters
EXEC sp_executesql N'SELECT * FROM employees WHERE 
							salary > @salary_value
							AND
								employee_dept = @department_name
							ORDER BY salary ASC',
							N'@salary_value INT,
							@department_name NVARCHAR(100)'
							,@salary_value = 50000
							,@department_name = 'SD-Web'

USE sql_wkday_20240228
GO
CREATE OR ALTER PROC sp_get_emp_depts_dynamic
		( @table_name NVARCHAR(100),
		  @column_name NVARCHAR(100),
		  @column_values NVARCHAR(100)

		)
		AS
		BEGIN
			DECLARE @sqlQuery AS NVARCHAR(200)

			SET @sqlQuery = N'SELECT * FROM ' + @table_name
								+ ' WHERE ' + @column_name +' IN (' 
								+ @column_values + ')'
								+ ' ORDER BY ' + @column_name + ' DESC'

			PRINT @sqlQuery

			EXEC sp_executesql @sqlQuery

		END


EXEC sp_get_emp_depts_dynamic @table_name = 'employees'
							 ,@column_name = 'employee_dept'
							,@column_values = '''SD-Web'', ''SD-DB'''


EXEC sp_get_emp_depts_dynamic @table_name = 'employee_information_tab'
								, @column_name = 'dept_id'
							,@column_values = '''SD-Web'', ''SD-DB'''

-- FIRST NORMAL FORM - THIRD NORMAL FORM ( core sql )
-- WINDOWS FUNCTIONS (LAG, LEAD , NTILE) ( core sql )
-- SUBQUERIES
-- COORELATED SUBQUERIES
-- STORED PROCS return a scalar value




DECLARE @t TABLE
(
	employee_id INT PRIMARY KEY
	,employee_name VARCHAR(100)
	,email_id VARCHAR(100)
	,department_name VARCHAR(50)
	,employee_salary INT
	,employee_blood_group CHAR(5)
)

-- populate data into a table variable
INSERT INTO @T
EXEC sp_get_emp_depts_dynamic @table_name = 'employees'
							 ,@column_name = 'employee_dept'
							,@column_values = '''SD-Web'', ''SD-DB'''

-- SELECT A TABLE VARIABLE
SELECT * FROM @t
ORDER BY
	department_name
	,employee_salary DESC;