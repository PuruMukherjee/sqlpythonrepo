USE sql_wknd_20240128

-- cursor is designed to point at a single record at a time
-- and a cursor is designed to move through each record one at a time
-- cursor gives u a much finer level of control
-- example you can execute a stored procedure over an individual record
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
			FETCH RELATIVE 10 FROM employee_cursor
		END
CLOSE employee_cursor
--- good house 
DEALLOCATE employee_cursor

--- read the output of the cursor in a variables
DECLARE @emp_name VARCHAR(100)
DECLARE @emp_dept VARCHAR(60)
DECLARE @emp_salary INT
DECLARE @avg_salary DECIMAL(10, 2)
DECLARE employee_cursor CURSOR SCROLL
	FOR
		SELECT employee_name, employee_dept, salary FROM employees

--after you declare a cursor you need to open the cursor
-- the statement to open the cursor is 
OPEN employee_cursor

-- do something useful
-- FETCH THE values of the cursor into variable names

	FETCH NEXT FROM employee_cursor
		INTO @emp_name,
			 @emp_dept,
			 @emp_salary
-- to make my cursor useful, I should be able to
	WHILE @@FETCH_STATUS = 0
		
		BEGIN
			PRINT @emp_name+ ' '+ @emp_dept+ ' '+
				CAST( @emp_salary AS CHAR(10))
			
			SELECT @avg_salary = AVG(salary) 
			FROM
				employees
			WHERE
				employee_dept = @emp_dept

			--- once the average salary is calculate print the message
			IF @emp_salary > @avg_salary
				BEGIN
					PRINT @emp_name + ' from department ' +
							@emp_dept +' get''s a salary of '
							+ CAST(@emp_salary AS CHAR(10)) +
							'which is greater than the average salary of the department which is ' +
							+ CAST(@avg_salary AS CHAR(12))
					PRINT '------------------------------------------------------'
				END
			ELSE
				BEGIN
					PRINT @emp_name + ' from department ' +
							@emp_dept +' get''s a salary of '
							+ CAST(@emp_salary AS CHAR(10)) +
							' which is less than equal to the average salary of the department which is ' +
							+ CAST(@avg_salary AS CHAR(12))
					PRINT '------------------------------------------------------'
				

				END
			FETCH NEXT FROM employee_cursor
				INTO @emp_name,
					 @emp_dept,
					 @emp_salary
		END
CLOSE employee_cursor
DEALLOCATE employee_cursor


-- cursor used in a stored procedure
USE sql_wknd_20240128
GO
CREATE OR ALTER PROC	sp_get_employee_salary_desc
	(
		@employee_name VARCHAR(100)
		,@employee_dept VARCHAR(60)
		,@employee_salary INT
		,@detailed_description VARCHAR(200) OUTPUT
	)
	AS
	BEGIN
		DECLARE @avg_salary AS DECIMAL(10, 2)
		DECLARE @detailed_text AS VARCHAR(200)

		SELECT @avg_salary = AVG(salary)
		FROM
		employees
		WHERE
		employee_dept = @employee_dept

		IF @employee_salary > @avg_salary
			BEGIN
				SET @detailed_text = 'SP OUTPUT >>>' +
							@employee_name + ' from department ' +
							@employee_dept +' get''s a salary of '
							+ CAST(@employee_salary AS CHAR(10)) +
							'which is greater than the average salary of the department which is ' +
							+ CAST(@avg_salary AS CHAR(12))
			END
		ELSE
			BEGIN
				SET @detailed_text =  'SP OUTPUT >>>' + 
							@employee_name + ' from department ' +
							@employee_dept +' get''s a salary of '
							+ CAST(@employee_salary AS CHAR(10)) +
							'which is less than or equal to than the average salary of the department which is ' +
							+ CAST(@avg_salary AS CHAR(12))
			END

		SET @detailed_description = @detailed_text
	END

--- Once the stored procedure is declare we have to use the stored procedure inside
--- a cursor
DECLARE @emp_name VARCHAR(100)
DECLARE @emp_dept VARCHAR(60)
DECLARE @emp_salary INT
DECLARE @detailed_message_txt AS VARCHAR(200)
DECLARE employee_cursor CURSOR SCROLL
	FOR
		SELECT employee_name, employee_dept, salary FROM employees

--after you declare a cursor you need to open the cursor
-- the statement to open the cursor is 
OPEN employee_cursor

-- do something useful
-- FETCH THE values of the cursor into variable names

	FETCH NEXT FROM employee_cursor
		INTO @emp_name,
			 @emp_dept,
			 @emp_salary
-- to make my cursor useful, I should be able to
	WHILE @@FETCH_STATUS = 0
		
		BEGIN
			PRINT @emp_name+ ' '+ @emp_dept+ ' '+
				CAST( @emp_salary AS CHAR(10))
			
			EXEC sp_get_employee_salary_desc
				@employee_name = @emp_name
				,@employee_dept = @emp_dept
				,@employee_salary = @emp_salary
				,@detailed_description = @detailed_message_txt OUTPUT

			PRINT @detailed_message_txt
			FETCH NEXT FROM employee_cursor
						INTO @emp_name,
							 @emp_dept,
							 @emp_salary 
		END
CLOSE employee_cursor
DEALLOCATE employee_cursor


-- DECLARE the CURSOR as local or global
-- GLOBAL is  to assure that the cursor is visible to the entire session

-- what are fetch options available for FETCH
--SCROLL CURSOR -- FETCH FIRST, FETCH LAST, FETCH ABSOLUTE FETCH PRIOR
--FORWARD ONLY --- FETCH NEXT

--- Table variables
-- DECLARE a table variables
-- table variable only persist as long as the code is running
-- created and dropped automatically when the code is running
-- table variable is created and dropped automatically
USE sql_wknd_20240128;
DECLARE @employ_info TABLE
	(
		employee_id INT PRIMARY KEY
		,employee_name VARCHAR(100)
		,employee_dept VARCHAR(60)
		,salary  INT
	);

INSERT INTO @employ_info
SELECT 
		employee_id
		,employee_name
		,employee_dept
		,salary
FROM
	employees
WHERE
employee_dept = 'SD-Web'
ORDER BY
	salary DESC

SELECT * FROM @employ_info

-- Table Valued functions
-- Simple table valued functions
-- Defining an inline table valued functions
-- what are table valued functions
SELECT *
FROM
employees
WHERE
	salary > (
				SELECT AVG(salary * 1.0000) FROM employees
				WHERE
				employee_dept = 'SD-Web'
			 )
	AND
		employee_dept = 'SD-Web';

-- These functions are inline table valued functions
USE sql_wknd_20240128
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
				WHERE employee_dept = 'SD-Web'
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

-- This is how we will access the table valued function
	SELECT *
	FROM
	[dbo].[fn_abv_avg_sal_emp]('SD-Web')
	ORDER BY
		salary DESC;

-- The above is an example of SCALAR table valued functions
-- Modifying the table valued functions


-- multi valued table valued function
-- we can use multiple select statements
-- populate a table using multiple select statements
-- return the value of the multiple select statements

-- defining a Multi Statement
USE sql_wknd_20240128
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
	,salary_classification VARCHAR(30)
)
AS
	BEGIN
		WITH employee_avg_sal
		AS
		(
			SELECT 
				employee_id
				,employees.employee_name
				,employees.employee_dept
				,employees.salary
				,avg_sal_t.avg_salary
			FROM employees
			CROSS JOIN
			(SELECT AVG(salary) AS avg_salary  FROM employees) AS avg_sal_t
			WHERE
				employees.employee_dept = @department_name
		)

		INSERT INTO @t
		SELECT *,
				'Low Salary' AS salary_classification
		FROM
			employee_avg_sal
		WHERE
			salary <= avg_salary;

		WITH employee_avg_sal
		AS
		(
			SELECT 
				employee_id
				,employees.employee_name
				,employees.employee_dept
				,employees.salary
				,avg_sal_t.avg_salary
			FROM employees
			CROSS JOIN
			(
				SELECT 
					AVG(salary) AS avg_salary  FROM employees) AS avg_sal_t
				WHERE
					employees.employee_dept = @department_name
			)

		INSERT INTO @t
		SELECT *,
				'High Salary' AS salary_classification
		FROM
			employee_avg_sal
		WHERE
			salary >= avg_salary;

		RETURN
		
	END
	
SELECT * FROM
dbo.[fn_classify_emps_dept]('SD-Web');

USE sql_wknd_20240128
GO
CREATE OR ALTER PROC sp_classify_emps
		(
			@department_name VARCHAR(60)
		)
		AS
			BEGIN
				DECLARE @t TABLE
						(
							employee_id INT PRIMARY KEY
							,employee_name VARCHAR(100)
							,employee_dept_name VARCHAR(60)
							,salary INT
							,avg_sal_dept DECIMAL(10, 2)
							,salary_classification VARCHAR(30)
						)
				INSERT INTO @t
				SELECT 
					employees.employee_id
					,employees.employee_name
					,employees.employee_dept
					,employees.salary
					,a_sal.avg_salary
					,'High Salary' AS salary_classification
				FROM
					employees
				CROSS JOIN
					(SELECT AVG(salary) AS avg_salary FROM employees
					WHERE employee_dept = 'SD-DB')  a_sal
				WHERE
					a_sal.avg_salary <= employees.salary
				AND
					employees.employee_dept = 'SD-DB' -- @department_name

				SELECT * FROM @t
				RETURN 
			END


DECLARE @t TABLE
						(
							employee_id INT PRIMARY KEY
							,employee_name VARCHAR(100)
							,employee_dept_name VARCHAR(60)
							,salary INT
							,avg_sal_dept DECIMAL(10, 2)
							,salary_classification VARCHAR(30)
						)
INSERT INTO @t
EXEC sp_classify_emps @department_name = 'SD-DB';

SELECT * FROM @t;


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


SET @tablename = N'employee_information_tab'
SET @SQLstring = N'SELECT * FROM ' + @tablename
EXEC sp_executesql @SQLstring

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

--- cursors
-- most of the operations are designed to work on a set of data
-- for example a select statement will run on a set of records
-- in one or more tables

-- cursor is used to point at one record at a time
-- cursor gives a finer level of control
-- executing a stored procedure , that you cannot do in other set based
-- operations

-- declare a CURSOR
-- WHAT set of records the cursor will be used with
go
DECLARE employee_cursor CURSOR
	FOR
		SELECT employee_name, employee_dept, salary FROM employees

-- The above is a basic declaration of a cursor
-- after you declare the cursor you need to open the cursor
OPEN employee_cursor

	-- do something useful
	-- Move the cursor to a record
	FETCH NEXT FROM employee_cursor
	-- because my cursor has just been opened, the above statement will
	-- give me the first record

	-- the key to using the cursor is to ask it to continue fetching
	-- records after it has fectched the first record
	-- use the GLOBAL variable
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH NEXT FROM employee_cursor
			-- at this point we have the basic structure of the cursor
			-- which will fetch the record from the record set
			-- check the value of the GLOBAL variable and 
			-- if the @@FETCH_STATUS == 0
			-- only when @@FETCH_STATUS == 0 then 
		END
CLOSE employee_cursor
DEALLOCATE employee_cursor
	
-- You do not 
go
DECLARE employee_cursor CURSOR SCROLL
	FOR
		SELECT employee_name, employee_dept, salary FROM employees

-- The above is a basic declaration of a cursor
-- after you declare the cursor you need to open the cursor
OPEN employee_cursor

	-- do something useful
	-- Move the cursor to a record
	FETCH FIRST FROM employee_cursor
	-- because my cursor has just been opened, the above statement will
	-- give me the first record

	-- the key to using the cursor is to ask it to continue fetching
	-- records after it has fectched the first record
	-- use the GLOBAL variable
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH NEXT FROM employee_cursor
			-- at this point we have the basic structure of the cursor
			-- which will fetch the record from the record set
			-- check the value of the GLOBAL variable and 
			-- if the @@FETCH_STATUS == 0
			-- only when @@FETCH_STATUS == 0 then 
		END
CLOSE employee_cursor
DEALLOCATE employee_cursor


go
DECLARE employee_cursor CURSOR SCROLL
	FOR
		SELECT employee_name, employee_dept, salary FROM employees

-- The above is a basic declaration of a cursor
-- after you declare the cursor you need to open the cursor
OPEN employee_cursor

	-- do something useful
	-- Move the cursor to a record
	FETCH LAST FROM employee_cursor
	-- because my cursor has just been opened, the above statement will
	-- give me the first record

	-- the key to using the cursor is to ask it to continue fetching
	-- records after it has fectched the first record
	-- use the GLOBAL variable
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH PRIOR FROM employee_cursor
			-- at this point we have the basic structure of the cursor
			-- which will fetch the record from the record set
			-- check the value of the GLOBAL variable and 
			-- if the @@FETCH_STATUS == 0
			-- only when @@FETCH_STATUS == 0 then 
		END
CLOSE employee_cursor
DEALLOCATE employee_cursor

GO
DECLARE employee_cursor CURSOR SCROLL
	FOR
		SELECT employee_name, employee_dept, salary FROM employees

-- The above is a basic declaration of a cursor
-- after you declare the cursor you need to open the cursor
OPEN employee_cursor

	-- do something useful
	-- Move the cursor to a record
	FETCH ABSOLUTE 20 FROM employee_cursor
	-- because my cursor has just been opened, the above statement will
	-- give me the first record

	-- the key to using the cursor is to ask it to continue fetching
	-- records after it has fectched the first record
	-- use the GLOBAL variable
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH RELATIVE 10 FROM employee_cursor
			-- at this point we have the basic structure of the cursor
			-- which will fetch the record from the record set
			-- check the value of the GLOBAL variable and 
			-- if the @@FETCH_STATUS == 0
			-- only when @@FETCH_STATUS == 0 then 
		END
CLOSE employee_cursor
DEALLOCATE employee_cursor


GO
DECLARE employee_cursor CURSOR SCROLL
	FOR
		SELECT employee_name, employee_dept, salary FROM employees

-- The above is a basic declaration of a cursor
-- after you declare the cursor you need to open the cursor
OPEN employee_cursor

	-- do something useful
	-- Move the cursor to a record
	-- Move the cursor to the 20th record from the end
	FETCH ABSOLUTE -20 FROM employee_cursor
	-- because my cursor has just been opened, the above statement will
	-- give me the first record

	-- the key to using the cursor is to ask it to continue fetching
	-- records after it has fectched the first record
	-- use the GLOBAL variable
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH RELATIVE -10 FROM employee_cursor
			-- at this point we have the basic structure of the cursor
			-- which will fetch the record from the record set
			-- check the value of the GLOBAL variable and 
			-- if the @@FETCH_STATUS == 0
			-- only when @@FETCH_STATUS == 0 then 
		END
CLOSE employee_cursor
DEALLOCATE employee_cursor

-- read the values of the output into variables
GO
DECLARE @employee_id INT
DECLARE @employee_name NVARCHAR(100)
DECLARE @employee_dept NVARCHAR(100)
DECLARE @employee_salary INT

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

OPEN employee_cursor

	FETCH NEXT FROM employee_cursor
	INTO @employee_id
		,@employee_name
		,@employee_dept
		,@employee_salary

	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT CAST(@employee_id AS CHAR(4))+' employee name ' +@employee_name +
									' department name ' + @employee_dept +
									' salary is ' + 
									CAST (@employee_salary AS NVARCHAR(20))

			FETCH NEXT FROM employee_cursor
				INTO
					@employee_id
					,@employee_name
					,@employee_dept
					,@employee_salary

		END

CLOSE employee_cursor
DEALLOCATE employee_cursor


--- Use the above CURSOR to detemine which employees have salary above and
--- which employees have salary below the average salary

-- read the values of the output into variables
GO
DECLARE @employee_id INT
DECLARE @employee_name NVARCHAR(100)
DECLARE @employee_dept NVARCHAR(100)
DECLARE @employee_salary INT
DECLARE @average_salary DECIMAL(10, 2)
DECLARE @salary_classification VARCHAR(100)

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

OPEN employee_cursor

	FETCH NEXT FROM employee_cursor
	INTO @employee_id
		,@employee_name
		,@employee_dept
		,@employee_salary

	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT CAST(@employee_id AS CHAR(4))+' employee name ' +@employee_name +
									' department name ' + @employee_dept +
									' salary is ' + 
									CAST (@employee_salary AS NVARCHAR(20))
			SELECT @average_salary = AVG(salary)
			FROM
				employees
			WHERE
				employee_dept = 'SD-Web'

			-- check if the salary of the employee is greater or less
			-- than the average salary
			IF @employee_salary > @average_salary
				BEGIN
					SET @salary_classification = 'High Salary'
					PRINT CAST(@employee_id AS CHAR(4))+' employee name ' +@employee_name +
									' department name ' + @employee_dept +
									' salary is ' + 
									CAST (@employee_salary AS NVARCHAR(20)) +
									' The employee salary is greater than the average salary'+
									' of ' + CAST(@average_salary  AS NVARCHAR(20)) +
									@employee_name + ' is classified as ' + @salary_classification + '.'
				END
			ELSE
				BEGIN
					SET @salary_classification = 'Low Salary'
					PRINT CAST(@employee_id AS CHAR(4))+' employee name ' +@employee_name +
									' department name ' + @employee_dept +
									' salary is ' + 
									CAST (@employee_salary AS NVARCHAR(20)) +
									' The employee salary is less than the average salary'+
									' of ' + CAST(@average_salary  AS NVARCHAR(20)) +
									' '+@employee_name + ' is classified as ' + @salary_classification + '.'



				END
				PRINT '-----------------------------------------------------'
			FETCH NEXT FROM employee_cursor
				INTO
					@employee_id
					,@employee_name
					,@employee_dept
					,@employee_salary

		END

CLOSE employee_cursor
DEALLOCATE employee_cursor

-- Use the stored proc to generate the print message
USE sql_wknd_20240128
GO
CREATE OR ALTER PROC sp_generate_emp_salary_status_message
	(
		@employee_id AS INT,
		@employee_name AS NVARCHAR(100),
		@employee_dept AS NVARCHAR(100),
		@employee_salary AS INT,
		@detailed_emp_message AS VARCHAR(400) OUTPUT
	)
	AS
		BEGIN
			DECLARE @detailed_message NVARCHAR(400)
			DECLARE @average_salary AS DECIMAL(10, 2)
			DECLARE @salary_classification AS VARCHAR(30)
			SELECT @average_salary = AVG(salary)
			FROM
				employees
			WHERE
				employee_dept = @employee_dept

			IF @employee_salary > @average_salary 
				BEGIN
					SET @salary_classification = 'High Salary'
					SET @detailed_message = 
								CAST(@employee_id AS CHAR(4))+' employee name ' +@employee_name +
									' department name ' + @employee_dept +
									' salary is ' + 
									CAST (@employee_salary AS NVARCHAR(20)) +
									' The employee salary is greater than the average salary'+
									' of ' + CAST(@average_salary  AS NVARCHAR(20)) +
									' '+@employee_name + 
									' is classified as ' + 
									@salary_classification + '.'

				END
			ELSE
				BEGIN
					SET @salary_classification = 'Low Salary'

					SET @detailed_message = 
								CAST(@employee_id AS CHAR(4))+' employee name ' +@employee_name +
									' department name ' + @employee_dept +
									' salary is ' + 
									CAST (@employee_salary AS NVARCHAR(20)) +
									' The employee salary is less than the average salary'+
									' of ' + CAST(@average_salary  AS NVARCHAR(20)) +
									' '+@employee_name + 
									' is classified as ' + 
									@salary_classification + '.'

				END

			PRINT 'STORED PROC The status is ' + @salary_classification
			

			PRINT @detailed_message
			SET @detailed_emp_message  =  @detailed_message
		END

GO

DECLARE @employee_id AS INT
DECLARE @employee_name AS VARCHAR(100)
DECLARE @employee_department_name AS VARCHAR(30)
DECLARE @employee_salary AS INT
DECLARE @employee_message AS NVARCHAR(400)
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

OPEN employee_cursor
	
	FETCH NEXT FROM employee_cursor
		INTO 
			@employee_id
			,@employee_name
			,@employee_department_name
			,@employee_salary

	WHILE @@FETCH_STATUS = 0
	BEGIN
			 
					EXEC sp_generate_emp_salary_status_message
						@employee_id = @employee_id
						,@employee_name = @employee_name
						,@employee_dept = @employee_department_name
						,@employee_salary = @employee_salary
						,@detailed_emp_message = @employee_message OUTPUT

					---PRINT @employee_message


						FETCH NEXT FROM employee_cursor
						INTO 
							@employee_id
							,@employee_name
							,@employee_department_name
							,@employee_salary


	END

CLOSE  employee_cursor
DEALLOCATE employee_cursor