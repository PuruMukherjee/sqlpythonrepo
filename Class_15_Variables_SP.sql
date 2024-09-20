--- ADVANCE SQL Programming Concepts
--- SQL SERVER 
--- This is an advance section
--- If you applying as a DATA SCIENTIST
--- SQL SERVER , 

--- ADVANCE SQL Programming Concepts
--- SQL SERVER 
--- This is an advance section
--- If you applying as a DATA SCIENTIST
--- SQL SERVER , Tina

--- VARIABLE
DECLARE @location VARCHAR(40);
SET @location = 'Jamshedpur';

SELECT @location;
PRINT @location;

-- Practicle use of a variable
-- Where I want to see all the employees whose salary > avg salary of the Organization

DECLARE @avg_salary INT;
SET @avg_salary = 80558;

SELECT   *,
		 @avg_salary as average_salary
		,'High Salary' AS salary_class
FROM
employees
WHERE
salary > @avg_salary

UNION

SELECT *,
		@avg_salary AS average_salary
		,'Low Salary' AS low_salary
FROM
employees
WHERE
salary <= @avg_salary

ORDER BY 
	employee_dept, salary DESC

SELECT AVG(salary) FROM employees

-- where we use a SCALAR SUBQUERY to set the valUE of the variable
DECLARE @avg_salary INT;
SET @avg_salary = (SELECT AVG(salary) FROM employees);

SELECT   *,
		 @avg_salary as average_salary
		,'High Salary' AS salary_class
FROM
employees
WHERE
salary > @avg_salary

UNION

SELECT *,
		@avg_salary AS average_salary
		,'Low Salary' AS low_salary
FROM
employees
WHERE
salary <= @avg_salary

ORDER BY 
	employee_dept, salary DESC

--- create two variables containing the value of department name and avg salary
--- of that department
-- and use the two variables to classify all the employees as either high sal or Low sal
GO
DECLARE @department_name VARCHAR(10);
SET @department_name = 'SD-Report';
DECLARE @avg_salary INT;
SET @avg_salary = (SELECT AVG(salary) FROM employees 
					WHERE employee_dept = @department_name
					);

SELECT *,
		@avg_salary AS average_salary
		,CASE
			WHEN salary > @avg_salary THEN 'High Salary'
			ELSE	'Low Salary'
		END AS salary_classification
FROM
	employees
WHERE
	employee_dept = @department_name
ORDER BY salary ASC;
-- Conversion failed when converting the varchar value 
-- 'Average salary of departmentSD-WEB=' to data type int.
PRINT 'Average salary of department ' + @department_name +' = '+ 
		CAST(@avg_salary AS VARCHAR(10));


SELECT CAST(10 AS CHAR(2)) + ' concatinate with string'


SELECT	10 + ' concatinate with string'


--- set the value of a variable using a SELECT statement
GO
DECLARE @max_salary INT;
DECLARE @min_salary INT;
DECLARE @avg_salary INT;
SELECT
		@max_salary = MAX(salary)
		,@min_salary = MIN(salary)
		,@avg_salary = AVG(salary)
FROM
		employees

PRINT @max_salary 
PRINT @min_salary
PRINT @avg_salary;

DECLARE @department_name VARCHAR(20);
DECLARE @top_sal_emp_names VARCHAR(MAX);

SET @department_name = 'SD-Web';
SET @top_sal_emp_names = '';

SELECT TOP 10
		@top_sal_emp_names = @top_sal_emp_names + employees.employee_name +'|'
FROM
	employees
ORDER BY salary DESC;

PRINT @top_sal_emp_names;

-- STORED PROCEDURE
GO
CREATE OR ALTER PROC sp_get_emps_gt_avg_sal
	AS
		BEGIN
			SELECT *
			FROM
			employees
			WHERE
			salary > (SELECT AVG(salary) FROM employees)
		END

EXEC sp_get_emps_gt_avg_sal;

--- I am altering the code of an existing STORED PROC
USE [sql_wkday_20240228]
GO

CREATE OR ALTER PROC [dbo].[sp_get_emps_gt_avg_sal]
	AS
		BEGIN
			SELECT *
			FROM
			employees
			WHERE
			salary > (SELECT AVG(salary) FROM employees)
			ORDER BY
				employee_dept, salary
		END
GO


USE [sql_wkday_20240228]
GO


CREATE OR ALTER  PROC [dbo].[sp_get_emps_gt_avg_sal]
	AS
		BEGIN

		   DECLARE @avg_salary AS INT;
		   SELECT @avg_salary = AVG(salary)
		   FROM
		   employees

		   PRINT @avg_salary

			SELECT *
					,@avg_salary AS avg_sal
			FROM
			employees
			WHERE
			salary > @avg_salary
			ORDER BY
				employee_dept, salary
		END
GO


EXEC sp_get_emps_gt_avg_sal;

--- How to create a stored proc that takes user inputs?

EXEC sp_help employees;

--- STORED proc with input
--- Stored proc with outputs
--- USER Defined functions

-- we are going to pass input paramters to a stored procedure
--- where we need a stored proc which takes two user inputs
--- the name of the department and the number of employees
USE sql_wkday_20240228;
GO
CREATE OR ALTER PROC sp_fetch_top_records_from_dept
			(
			@department_name AS VARCHAR(50),
			@number_of_emps AS INT
			)
		AS
			BEGIN

				WITH emp_sal_rank
				AS
				(
				SELECT *,
						DENSE_RANK() OVER(ORDER BY salary DESC) AS salary_rank
				FROM
					employees
				WHERE
					employee_dept = @department_name
				)

				SELECT *
				FROM
				emp_sal_rank
				WHERE
				salary_rank <= @number_of_emps
			END

EXEC sp_fetch_top_records_from_dept @department_name = 'SD-Web', 
									@number_of_emps=5;


EXEC sp_fetch_top_records_from_dept @department_name = 'SD-DB',
									@number_of_emps=5;

--- DEFAULT PARAMETER VALUES
USE sql_wkday_20240228;
GO
CREATE OR ALTER PROC sp_fetch_top_records_from_dept
			(
			@department_name AS VARCHAR(50),
			@number_of_emps AS INT = 5
			)
		AS
			BEGIN

				WITH emp_sal_rank
				AS
				(
				SELECT *,
						DENSE_RANK() OVER(ORDER BY salary DESC) AS salary_rank
				FROM
					employees
				WHERE
					employee_dept = @department_name
				)

				SELECT *
				FROM
				emp_sal_rank
				WHERE
				salary_rank <= @number_of_emps
			END

-- sql is considering the default values for the number of emps
EXEC sp_fetch_top_records_from_dept @department_name = 'SD-DB';

EXEC sp_fetch_top_records_from_dept @department_name = 'SD-DB',
									@number_of_emps=3;

--- create a stored proc that will classify salary of emps by default based on average salary
--- but you may also provide a salary value that can be used to classify the emps
--- make sure that the sp takes two user input
--- one is the department for which we are going to classify emps
--- second is the salary based on which we will classify emps
USE sql_wkday_20240228;GOCREATE OR ALTER PROC sp_fetch_salary_class           (			@department_name AS VARCHAR(50),			@threshold_salary AS INT 			)			AS			BEGIN						SELECT *,					@threshold_salary AS [threshold salary]			,CASE			WHEN salary > @threshold_salary  THEN 'High Sal'			ELSE 'Low Sal'			END AS salary_classification			FROM employees			WHERE			    employee_dept = @department_name			ORDER BY				salary					ENDGODECLARE @department_name AS VARCHAR(30);SET @department_name = 'SD-Infra';DECLARE @avg_salary AS DECIMAL(10,2 );SELECT 		@avg_salary = AVG(salary)FROM		employeesWHERE		employee_dept = @department_nameSET @avg_salary = @avg_salary * 1.20;EXEC sp_fetch_salary_class @department_name = @department_name,							@threshold_salary = @avg_salary;


--- STORED PROC THAT Take input parameter and return one or more output parameter
GO
CREATE OR ALTER PROC sp_dept_stats
				(
					@department_name VARCHAR(40)
					,@max_salary AS INT OUTPUT
					,@min_salary AS INT OUTPUT
					,@avg_salary AS INT OUTPUT
					,@emp_count AS INT OUTPUT
				)
	AS
		BEGIN
			-- Going to declare local variables
			DECLARE @max_sal_local AS INT;
			DECLARE @min_sal_local AS INT;
			DECLARE @avg_sal_local AS INT;
			DECLARE @emp_count_local AS INT;

			SELECT
					@max_sal_local = MAX(salary)
					,@min_sal_local = MIN(salary)
					,@avg_sal_local = AVG(salary)
					,@emp_count_local = COUNT(employee_id)
			FROM	
				employees
			WHERE
				employee_dept = @department_name

			-- the output variables will take the values of MAX MIN AVG COUNT
			-- outside the body of the stored proc
			SET @max_salary = @max_sal_local
			SET @min_salary = @min_sal_local
			SET @avg_salary = @avg_sal_local
			SET @emp_count = @emp_count_local
		END

-- call the stored proc


DECLARE @max_s AS INT;
DECLARE @min_s AS INT;
DECLARE @avg_s AS INT;
DECLARE @emp_cnt AS INT;

EXEC 
		sp_dept_stats
				@department_name = 'SD-WEB'
				,@max_salary = @max_s OUTPUT
				,@min_salary = @min_s OUTPUT
				,@avg_salary = @avg_s OUTPUT
				,@emp_count =  @emp_cnt OUTPUT
			
SELECT @max_s, @min_s, @avg_s, @emp_cnt

SELECT *
FROM
	employees
WHERE
	employee_dept = 'SD-WEB'
AND
	salary = @max_s;

SELECT *
FROM
	employees
WHERE
	employee_dept = 'SD-WEB'
AND
	salary = @min_s;



SELECT
	*
	, CASE
		WHEN	
			salary > @avg_s THEN 'High Sal'
		ELSE 'Low Sal'
	  END AS salary_classification
FROM
	employees
WHERE
	employee_dept = 'SD-WEB';



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

---- Get the average salary of all employees of a specified dept classified as LOW SALARY
---- Get the average salary of all the employees of a specified dept as HIGH SALARY
USE sql_wkday_20240228;
go
CREATE OR ALTER PROC sp_avg_sal_emp_class
				(
					@department_name AS VARCHAR(40)
					,@avg_low_sal AS DECIMAL(10, 2) OUTPUT
					,@avg_high_sal AS DECIMAL(10, 2) OUTPUT
				)
	AS

		BEGIN
			-- First calculate the AVG salary of the department
			-- because we wil use the AVG SAL to classify every emp as High or Low sal
			DECLARE @avg_sal AS DECIMAL(10, 2)
			SELECT @avg_sal = AVG(salary)
			FROM
				employees
			WHERE
				employee_dept = @department_name
			PRINT @avg_sal --- code works till here

			DECLARE @avg_low_sal_local AS DECIMAL(10, 2)
			DECLARE @avg_high_sal_local AS DECIMAL(10, 2);

			WITH emp_sal_class
			AS
			(
			SELECT *
					, CASE
						WHEN salary > @avg_sal THEN 'High Salary'
						ELSE 'Low Salary'
					  END AS salary_class
			FROM
				employees
			WHERE
				employee_dept = @department_name
			)

			-- USE the CTE created above to find the average salary of each sal class
			
			SELECT @avg_low_sal_local = AVG(salary)
			FROM
			emp_sal_class
			WHERE
				salary_class = 'Low Salary';


		 WITH emp_sal_class_new
			AS
			(
			SELECT *
					, CASE
						WHEN salary > @avg_sal THEN 'High Salary'
						ELSE 'Low Salary'
					  END AS salary_class
			FROM
				employees
			WHERE
				employee_dept = @department_name
			)

			SELECT @avg_high_sal_local = AVG(salary)
			FROM
			emp_sal_class_new
			WHERE
				salary_class = 'High Salary'

			SET @avg_low_sal = @avg_low_sal_local
			SET @avg_high_sal = @avg_high_sal_local
		END

DECLARE @avg_h_sal AS DECIMAL(10, 2)
DECLARE @avg_l_sal AS DECIMAL(10, 2)


EXEC sp_avg_sal_emp_class @department_name = 'SD-WEB'
							,@avg_low_sal = @avg_l_sal OUTPUT
							,@avg_high_sal = @avg_h_sal  OUTPUT

SELECT @avg_l_sal , @avg_h_sal


--- temp tables
SELECT *
					, CASE
						WHEN salary > 80000 THEN 'High Salary'
						ELSE 'Low Salary'
					  END AS salary_class

					INTO #temp_table
			FROM
				employees
			WHERE
				employee_dept = 'SD-DB'


SELECT * FROM #temp_table




CREATE OR ALTER PROC sp_avg_sal_emp_class
				(
					@department_name AS VARCHAR(40)
					,@avg_low_sal AS DECIMAL(10, 2) OUTPUT
					,@avg_high_sal AS DECIMAL(10, 2) OUTPUT
				)
	AS

		BEGIN
			-- First calculate the AVG salary of the department
			-- because we wil use the AVG SAL to classify every emp as High or Low sal
			DECLARE @avg_sal AS DECIMAL(10, 2)
			SELECT @avg_sal = AVG(salary)
			FROM
				employees
			WHERE
				employee_dept = @department_name
			PRINT @avg_sal --- code works till here

			DECLARE @avg_low_sal_local AS DECIMAL(10, 2)
			DECLARE @avg_high_sal_local AS DECIMAL(10, 2);

			
			SELECT *
					, CASE
						WHEN salary > @avg_sal THEN 'High Salary'
						ELSE 'Low Salary'
					  END AS salary_class
					  INTO #temp_table
			FROM
				employees
			WHERE
				employee_dept = @department_name
			

			-- USE the CTE created above to find the average salary of each sal class
			
			SELECT @avg_low_sal_local = AVG(salary)
			FROM
				#temp_table
			WHERE
				salary_class = 'Low Salary';


			SELECT @avg_high_sal_local = AVG(salary)
			FROM
				#temp_table
			WHERE
				salary_class = 'High Salary'

			SET @avg_low_sal = @avg_low_sal_local
			SET @avg_high_sal = @avg_high_sal_local
		END


DECLARE @avg_h_sal AS DECIMAL(10, 2)
DECLARE @avg_l_sal AS DECIMAL(10, 2)


EXEC sp_avg_sal_emp_class @department_name = 'SD-WEB'
							,@avg_low_sal = @avg_l_sal OUTPUT
							,@avg_high_sal = @avg_h_sal  OUTPUT

SELECT @avg_l_sal , @avg_h_sal
