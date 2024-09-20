-- -- STORED PROCS return a scalar value
USE sql_wkday_20240228
GO
CREATE OR  ALTER PROC sp_get_count_emp_below_avg(
			@department_name VARCHAR(100)
			)
			AS
			BEGIN
				--- STEP 1 >> Calculate the average salary
				DECLARE @avg_sal AS INT
				DECLARE @emp_cnt_lower AS INT
				

				SELECT 
					@avg_sal =  AVG(salary)
				FROM
					employees
				WHERE
					employee_dept = @department_name

				SELECT 
					@emp_cnt_lower = COUNT(*)
				FROM
					employees
				WHERE
					salary <= @avg_sal
				AND
					employee_dept = @department_name

				RETURN @emp_cnt_lower
				END

GO
DECLARE @employee_count_below_avg AS INT
DECLARE @department_name AS VARCHAR(20)
SET @department_name  = 'SD-Web'


EXEC @employee_count_below_avg  = sp_get_count_emp_below_avg @department_name = @department_name

PRINT @employee_count_below_avg;


-- COORELATED SUBQUERIES
-- GET THE AVERAGE SALARY OF EACH DEPARTMENT 
SELECT *,
		(SELECT AVG(salary) FROM employees
			WHERE
				employee_dept = empl_outer.employee_dept
		) AS avg_sal_dept
FROM
employees AS empl_outer


--- get all the employees whose salary = max salary by department
SELECT *
FROM
	employees AS outer_emp_tab
WHERE
	salary  = (	
					SELECT MAX(salary)
					FROM
					employees
					WHERE
						employee_dept = outer_emp_tab.employee_dept
				)

SELECT *
FROM
	employees AS outer_emp_tab
WHERE
	salary  = (
					SELECT MIN(salary)
					FROM
					employees
					WHERE
					employee_dept = outer_emp_tab.employee_dept
				)

--- TRANSACTIONS
SELECT *  INTO e_dummy FROM employees


SELECT * FROM e_dummy


INSERT INTO e_dummy
(
	employee_name
	,employee_email
	,employee_dept
	,salary
	
)VALUES
(
	1000
	,'Rakesh Kumar Sinha'
	,'raksin@dummyemail.com'
	,'SD-Web'
	,122222
);

--- INSERT , UPDATE and DELETE are transaction
--- each time such things happen then SQL SERVER record these events in a 
--- transactional log
--normally u do not have control on the transactional are happening
-- This video is how we can control the process of transactional

-- begin a tranaction
BEGIN TRANSACTION

-- When u begin the tranasction SQL server does not automatically commits
-- them to the database
--

INSERT INTO e_dummy
(
	employee_id
	,employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	1002
	,'Pradeep Kumar Asim'
	,'pradeepas@dummyemail.com'
	,'SD-Report'
	,100000
);


SELECT * FROM e_dummy WHERE employee_email = 'pradeepas@dummyemail.com'
-- we can explicit commit the tranaction
ROLLBACK TRAN


SELECT * FROM e_dummy WHERE employee_email = 'pradeepas@dummyemail.com'

-- begin a tranaction
BEGIN TRANSACTION

-- When u begin the tranasction SQL server does not automatically commits
-- them to the database
--

INSERT INTO e_dummy
(
	employee_id
	,employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	1002
	,'Diego Kumar Asim'
	,'diego@dummyemail.com'
	,'SD-Report'
	,100000
);


SELECT * FROM e_dummy WHERE employee_email = 'diego@dummyemail.com'
-- we can explicit commit the tranaction
COMMIT TRANSACTION

SELECT * FROM e_dummy WHERE employee_email = 'diego@dummyemail.com'


-- Given name to a Transaction
BEGIN TRAN add_records_e_dummy

INSERT INTO e_dummy
(
	employee_id
	,employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	1004
	,'Hari Kumar Singh'
	,'hari@dummyemail.com'
	,'SD-DB'
	,95000
);


DECLARE @record_count AS INT
SELECT @record_count = COUNT(*) FROM e_dummy
WHERE
employee_name LIKE 'Hari Kumar Singh'
AND
employee_email = 'hari@dummyemail.com'

IF @record_count > 1
	BEGIN
		ROLLBACK TRAN add_records_e_dummy
		PRINT 'Rolling back the INSERT statement - duplicate record'
	END
ELSE
	BEGIN
		COMMIT TRAN add_records_e_dummy
		PRINT 'Commiting the newly added records'
	END


SELECT *
FROM
e_dummy
WHERE
employee_name LIKE 'Hari Kumar Singh'
AND
employee_email = 'hari@dummyemail.com'




INSERT INTO e_dummy
(
	employee_id
	,employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	1005
	,'Ojas Kumar Asim'
	,'ojasmuk@dummyemail.com'
	,'SD-Report'
	,122222
);

UPDATE e_dummy
SET salary = 'More Salary'
WHERE
employee_name LIKE '%Ojas%';


SELECT *
FROM
e_dummy
WHERE
employee_name LIKE '%Ojas%'

DELETE FROM
e_dummy
WHERE
employee_name LIKE '%Ojas%'


-- the record is still inserted and this is a HALF completed record
-- the requirement is roll back that the entire code is rolbacked
BEGIN TRAN  add_record_adit
INSERT INTO e_dummy
(
	employee_id
	,employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	1005
	,'Ojas Kumar Asim'
	,'ojasmuk@dummyemail.com'
	,'SD-Report'
	,122222
);

UPDATE e_dummy
SET salary = 'More Salary'
WHERE
employee_name LIKE '%adit kumar Asim%';

COMMIT TRAN add_record_adit;

SELECT * FROM e_dummy WHERE employee_name LIKE '%Ojas%'



BEGIN TRY
BEGIN TRAN  add_record_adit
INSERT INTO e_dummy
(
	employee_id
	,employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	1006
	,'adit Kumar Asim'
	,'ojasmuk@dummyemail.com'
	,'SD-Report'
	,122222
);

UPDATE e_dummy
SET salary = 'More Salary'
WHERE
employee_name LIKE '%adit kumar Asim%';

	COMMIT TRAN add_record_adit;
END TRY

BEGIN CATCH --- CATCH BLOCK BEGIN AFTER THE TRY BLOCK END
	ROLLBACK TRAN add_record_adit
	PRINT 'Insert or update failed, check dattype mismatches'
END CATCH


-- Nested transctions
BEGIN TRAN tran_1

	PRINT @@TRANCOUNT -- This is the number of open tranaction

COMMIT TRAN tran_1

PRINT @@TRANCOUNT

-- Nested transctions
BEGIN TRAN tran_1
	PRINT @@TRANCOUNT
	BEGIN TRAN tran_2
	PRINT @@TRANCOUNT -- This is the number of open tranaction
	COMMIT TRAN tran_2
	PRINT @@TRANCOUNT -- this global variable is used by sql server for
	--- record keeping on how many transaction has begun
COMMIT TRAN tran_1
PRINT @@TRANCOUNT



-- NESTED TRANACTIONS -- you cannot rollback transaction with name
BEGIN TRAN tran_outer
	PRINT @@TRANCOUNT
	BEGIN TRAN tran_inner
	PRINT @@TRANCOUNT -- This is the number of open tranaction
	 COMMIT TRAN tran_inner -- this will rollback all the tranactions
	PRINT @@TRANCOUNT -- this global variable is used by sql server for
	--- record keeping on how many transaction has begun
COMMIT TRAN tran_outer -- hence the commit transaction has failed

-- Here I will encounter an error
-- NESTED TRANACTIONS -- you cannot rollback transaction with name
BEGIN TRAN tran_outer
	PRINT @@TRANCOUNT
	BEGIN TRAN tran_inner
	PRINT @@TRANCOUNT -- This is the number of open tranaction
	 ROLLBACK TRAN tran_inner -- this will rollback all the tranactions
	PRINT @@TRANCOUNT -- this global variable is used by sql server for
	--- record keeping on how many transaction has begun
COMMIT TRAN tran_outer -- hence the commit transaction has failed



BEGIN TRAN tran_outer
	PRINT @@TRANCOUNT
	BEGIN TRAN
	PRINT @@TRANCOUNT -- This is the number of open tranaction
	 ROLLBACK TRAN -- this will rollback all the tranactions
	PRINT @@TRANCOUNT -- this global variable is used by sql server for
	--- record keeping on how many transaction has begun
COMMIT TRAN tran_outer -- hence the commit transaction has failed


SELECT * FROM e_dummy


BEGIN TRAN update_salary_outer

	PRINT @@TRANCOUNT
	-- This is a legitimate transaction
	UPDATE e_dummy
	SET salary = salary * 1.1
	WHERE
	employee_id = 1002

	BEGIN TRAN
		PRINT @@TRANCOUNT

		UPDATE e_dummy
			SET salary = salary * 2
		WHERE
			employee_id = 1002

	ROLLBACK TRAN --- I will also rollback the legitimate transaction
	PRINT @@TRANCOUNT

SELECT * FROM e_dummy WHERE employee_id = 1002


--- SAVEPOINT

--- savepoint
SELECT salary , 1.1 * 122222 FROM  e_dummy
	WHERE
	employee_name LIKE 'Diego' -- 122222

BEGIN TRAN diego_update_demo_savepoint

	UPDATE e_dummy
	SET salary = salary * 1.1
	FROM e_dummy
	WHERE
	employee_name LIKE 'Diego%'

	PRINT @@TRANCOUNT --- at this timeframe I have one open transaction

	SAVE TRAN updated_ojas_sal_10 -- save all the transactions till here.

	PRINT @@TRANCOUNT --- still 1 as no new transaction have been opened

	--- This is not a legitimate transaction
	UPDATE e_dummy
	SET salary = salary * 2
	FROM e_dummy
	WHERE
	employee_name LIKE 'Diego%'

	ROLLBACK TRAN  updated_ojas_sal_10-- This will rollback all the previously opened transactions


	PRINT @@TRANCOUNT -- still 1 as no new transactions have been created

COMMIT TRAN diego_update_demo_savepoint -- since this tran is already


SELECT * FROM e_dummy
WHERE
	employee_name LIKE '%Diego%'



BEGIN TRAN  add_record_adit
PRINT @@TRANCOUNT  --- 1

INSERT INTO e_dummy
(
	employee_id
	,employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	1007
	,'Adithya Kumar Asim'
	,'adityasim@dummyemail.com'
	,'SD-Report'
	,80000
);

SAVE TRAN added_record_for_adit

UPDATE e_dummy
SET salary =  2 * salary
WHERE
employee_name LIKE '%Adithya Kumar Asim%';

ROLLBACK TRAN added_record_for_adit

UPDATE
	e_dummy
	SET blood_group  = 'AB+'
	WHERE
		employee_name LIKE '%Adithya Kumar Asim%';

SAVE TRAN added_blood_grp

DELETE
	e_dummy
WHERE
		employee_name LIKE '%Adithya Kumar Asim%';

ROLLBACK TRAN added_blood_grp
COMMIT TRAN add_record_adit

SELECT *
FROM
e_dummy
WHERE
		employee_name LIKE '%Adithya Kumar Asim%';

--- examples of correlated subqueries
-- where the subquery is a part of the insert statement

SELECT *,
		(SELECT AVG(salary) FROM e_dummy WHERE
			employee_dept  = outer_e_dummy.employee_dept
		) AS avg_salary
FROM
	e_dummy AS outer_e_dummy

--- DML (INSERT, DELETE and UPDATE)
--- RUN some actions as soon as you run a INSERT UPDATE or DELETE on a table
--- you can think of these actions like Stored proc. trigger is like a stored proc

USE [sql_wkday_20240228]
GO
CREATE TRIGGER trg_e_dummy
ON e_dummy
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
AFTER 
	INSERT,
	DELETE ,
	UPDATE
AS
	BEGIN
		PRINT 'Something happened to the e_dummy table'	
	END
GO

-- update the trigger
USE [sql_wkday_20240228]
GO


CREATE OR ALTER TRIGGER [dbo].[trg_e_dummy]
ON [dbo].[e_dummy]
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
AFTER 
	INSERT,
	DELETE ,
	UPDATE
AS
	BEGIN
		PRINT 'Something happened to the e_dummy table >>> Updated trigger'	
	END
GO


SELECT * FROM e_dummy

UPDATE
	e_dummy
SET
	salary = salary * 1.1
WHERE
	employee_dept = 'SD-DB'



UPDATE e_dummy
SET
	salary = salary * 0.95
WHERE
	employee_name LIKE '%Rakesh%';

-- How to delete a Trigger
USE sql_wknd_20240128
GO
DROP TRIGGER trg_e_dummy;

-- I do not see such messages where the trigger has been removed

--- DELETE TRIGGER
DROP TRIGGER trg_e_dummy


SELECT COUNT(*) FROM e_dummy


-- hiring is frozen as of now
-- should not allow new employees to be added to the database
USE sql_wkday_20240228;
GO
CREATE OR ALTER TRIGGER [dbo].[trg_e_dummy]
ON [dbo].[e_dummy]
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
INSTEAD OF 
	INSERT
AS
	BEGIN
		RAISERROR('Hiring Freeze - Cannot hire new employees',
					16,
					1)
	END
GO


USE sql_wkday_20240228;
GO
CREATE OR ALTER TRIGGER [dbo].[trg_e_dummy]
ON [dbo].[e_dummy]
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
AFTER 
	INSERT
AS
	BEGIN
		--RAISERROR('Hiring Freeze - Cannot hire new employees',16,1)
		ROLLBACK TRANSACTION
		RAISERROR('Hiring Freeze - Cannot hire new employees',16,1)
	END
GO


DELETE FROM e_dummy
WHERE employee_id = 1009;

INSERT INTO
	e_dummy
VALUES(
	1009,
	'Amit Kumar Mishra',
	'amitmin@dummyemail.com',
	'SD-DB',
	12000,
	'A+'
)

SELECT * FROM e_dummy
WHERE employee_id = 1009
AND
employee_name  = 'Amit Kumar Mishra'

INSERT INTO
	e_dummy
VALUES(
	1012,
	'Amit Kumar Mishra',
	'amitmin@dummyemail.com',
	'SD-DB',
	12000,
	'A+'
)

-- inserted table is a table that is mainted by SQL server
--- to hold the changes made to the main table (e_dummy)
USE [sql_wkday_20240228]
GO
CREATE OR ALTER  TRIGGER [dbo].[trg_e_dummy]
ON [dbo].[e_dummy]
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
AFTER  INSERT, DELETE, UPDATE
AS
	BEGIN
		
		SELECT *, 'INSERTED TABLE' AS tab_name FROM inserted
	
	END
GO


INSERT INTO
	e_dummy
VALUES(
	1010,
	'Keshav Kumar Mishra',
	'keshavmin@dummyemail.com',
	'SD-DB',
	12000,
	'A+'
)

UPDATE 
	e_dummy
SET salary = salary * 2
WHERE
	blood_group = 'A+'


-- All newly hired employees will have salary < the MAX salary of deparment
USE [sql_wkday_20240228]
GO
CREATE OR ALTER  TRIGGER [dbo].[trg_e_dummy]
ON [dbo].[e_dummy]
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
INSTEAD OF  INSERT

AS
		BEGIN

		IF EXISTS(
					
					SELECT *
					FROM
					(
					SELECT employee_dept, salary
					FROM
					inserted
					) AS inserted_recs 
					INNER JOIN
					(
					SELECT DISTINCT employee_dept,
							MAX(salary) OVER(PARTITION BY employee_dept) AS max_salary
					FROM
					e_dummy
					) AS e_dummy_max
					ON
					inserted_recs.employee_dept = e_dummy_max.employee_dept
					AND
					inserted_recs.salary > e_dummy_max.max_salary

					)

					BEGIN
						RAISERROR(
								'Salary cannot be more than max salary'
								,16
								,1
								)
						
					END
			ELSE
				BEGIN
					INSERT INTO e_dummy
					SELECT * FROM inserted

				END
		END

INSERT INTO
	e_dummy
VALUES(
	1012,
	'Taruni Kumari Mishra',
	'taruni@dummyemail.com',
	'SD-DB',
	1200000,
	'O+'
)


SELECT * FROM e_dummy
