USE sql_wknd_20240128;
--  what are transactions?
-- in sql server , tranasction is like an event that happens
-- when something changes in the database


SELECT * FROM e_dummy
INSERT INTO e_dummy
(
	employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	'Rakesh Kumar Sinha'
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
	employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	'Rakesh Kumar Asim'
	,'rakasim@dummyemail.com'
	,'SD-DB'
	,122222
);


SELECT * FROM e_dummy WHERE employee_email = 'rakasim@dummyemail.com'
-- we can explicit commit the tranaction
ROLLBACK TRAN



BEGIN TRANSACTION

-- When u begin the tranasction SQL server does not automatically commits
-- them to the database
--

INSERT INTO e_dummy
(
	employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	'Unmesh Kumar Asim'
	,'unmeshasim@dummyemail.com'
	,'SD-Report'
	,122222
);

SELECT * FROM e_dummy WHERE employee_name LIKE '%Unmesh%'

ROLLBACK TRAN

SELECT * FROM e_dummy WHERE employee_name LIKE '%Unmesh%'

-- we can explicit commit the tranaction
COMMIT TRAN add_records_e_dummy


-- We can give name to transaction
BEGIN TRAN add_records_e_dummy
INSERT INTO e_dummy
(
	employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	'Pradeep Kumar Asim'
	,'unmeshasim@dummyemail.com'
	,'SD-Report'
	,122222
);


DECLARE @record_count AS INT
SELECT @record_count = COUNT(*) FROM e_dummy
WHERE
employee_name LIKE 'Pradeep Kumar Asim'

IF @record_count > 1
	BEGIN
		ROLLBACK TRAN add_records_e_dummy
		PRINT 'Rolling back the INSERT statement'
	END
ELSE
	BEGIN
		COMMIT TRAN add_records_e_dummy
		PRINT 'Commiting the newly added records'
	END

--- insert record and handling error
INSERT INTO e_dummy
(
	employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	'Ojas Kumar Asim'
	,'ojasmuk@dummyemail.com'
	,'SD-Report'
	,122222
);

UPDATE e_dummy
SET salary = 'More Salary'
WHERE
employee_name LIKE '%Ojas%';
-- the record is still inserted and this is a HALF completed record
-- the requirement is roll back that the entire code is rolbacked
BEGIN TRAN  add_record_adit
INSERT INTO e_dummy
(
	employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	'adit Kumar Asim'
	,'ojasmuk@dummyemail.com'
	,'SD-Report'
	,122222
);

UPDATE e_dummy
SET salary = 'More Salary'
WHERE
employee_name LIKE '%adit kumar Asim%';

COMMIT TRAN add_record_adit;


SELECT * FROM e_dummy
WHERE
employee_name LIKE '%adit kumar Asim%';

-- provide error handling to the above 

BEGIN TRY
BEGIN TRAN  add_record_adit
INSERT INTO e_dummy
(
	employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	'adit Kumar Asim'
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


SELECT * 
	FROM 
		e_dummy 
		WHERE
employee_name 
	LIKE '%adit kumar Asim%';

-- Nested transctions
BEGIN TRAN tran_1

	PRINT @@TRANCOUNT -- This is the number of open tranaction

COMMIT TRAN tran_1


-- Nested transctions
BEGIN TRAN tran_1
	PRINT @@TRANCOUNT
	BEGIN TRAN tran_2
	PRINT @@TRANCOUNT -- This is the number of open tranaction
	COMMIT TRAN tran_2
	PRINT @@TRANCOUNT -- this global variable is used by sql server for
	--- record keeping on how many transaction has begun
COMMIT TRAN tran_1

-- rollback nested transaction
-- rollback nested transactions
--
-- NESTED TRANACTIONS -- you cannot rollback transaction with name
BEGIN TRAN tran_outer
	PRINT @@TRANCOUNT
	BEGIN TRAN 
	PRINT @@TRANCOUNT -- This is the number of open tranaction
	ROLLBACK TRAN -- this will rollback all the tranactions
	PRINT @@TRANCOUNT -- this global variable is used by sql server for
	--- record keeping on how many transaction has begun
COMMIT TRAN tran_outer -- hence the commit transaction has failed


BEGIN TRAN tran_outer
	PRINT @@TRANCOUNT
	BEGIN TRAN 
	PRINT @@TRANCOUNT -- This is the number of open tranaction
	COMMIT TRAN -- this will rollback all the tranactions
	PRINT @@TRANCOUNT -- this global variable is used by sql server for
	--- record keeping on how many transaction has begun
ROLLBACK TRAN tran_outer -- hence the commit transaction has failed


-- ROLLBACK IN A  NESTED TRANSACTION WILL ROLL BACK ALL TRANSACTIONS
-- ROLLBACK OF The outer transaction will cause all the previous changes
-- to roll back
SELECT * FROM e_dummy

BEGIN TRAN tran_ojas_update_outer
	UPDATE e_dummy
	SET salary = salary * 1.1
	FROM e_dummy
	WHERE
	employee_name LIKE 'Ojas%Asim'

	PRINT @@TRANCOUNT

	BEGIN TRAN

	PRINT @@TRANCOUNT

	UPDATE e_dummy
	SET salary = salary * 2
	FROM e_dummy
	WHERE
	employee_name LIKE 'Ojas%Asim'

	COMMIT TRAN


	PRINT @@TRANCOUNT

ROLLBACK TRAN tran_ojas_update_outer


-- ORIGINAL salary = 127721

SELECT * FROM  e_dummy
	WHERE
	employee_name LIKE 'Ojas%Asim'


BEGIN TRAN tran_ojas_update_outer
	UPDATE e_dummy
	SET salary = salary * 1.1
	FROM e_dummy
	WHERE
	employee_name LIKE 'Ojas%Asim'

	PRINT @@TRANCOUNT

	BEGIN TRAN

	PRINT @@TRANCOUNT

	UPDATE e_dummy
	SET salary = salary * 2
	FROM e_dummy
	WHERE
	employee_name LIKE 'Ojas%Asim'

	COMMIT TRAN


	PRINT @@TRANCOUNT

ROLLBACK TRAN tran_ojas_update_outer

BEGIN TRAN tran_ojas_update_outer_demo
	UPDATE e_dummy
	SET salary = salary * 1.1
	FROM e_dummy
	WHERE
	employee_name LIKE 'Ojas%Asim'

	PRINT @@TRANCOUNT

	BEGIN TRAN

	PRINT @@TRANCOUNT

	UPDATE e_dummy
	SET salary = salary * 2
	FROM e_dummy
	WHERE
	employee_name LIKE 'Ojas%Asim'

	ROLLBACK TRAN -- This will rollback all the previously opened transactions


	PRINT @@TRANCOUNT

COMMIT TRAN tran_ojas_update_outer_demo -- since this tran is already
-- rollbacked hence we cannot commit this transaction
-- this transaction has been rolled back because of the 


--- savepoint
SELECT salary , 1.1 * 122222 FROM  e_dummy
	WHERE
	employee_name LIKE 'Ojas%Asim' -- 122222

BEGIN TRAN ojas_update_demo_savepoint

	UPDATE e_dummy
	SET salary = salary * 1.1
	FROM e_dummy
	WHERE
	employee_name LIKE 'Ojas%Asim'

	PRINT @@TRANCOUNT

	SAVE TRAN updated_ojas_sal_10 -- save all the transactions till here.

	PRINT @@TRANCOUNT

	UPDATE e_dummy
	SET salary = salary * 2
	FROM e_dummy
	WHERE
	employee_name LIKE 'Ojas%Asim'

	ROLLBACK TRAN  updated_ojas_sal_10-- This will rollback all the previously opened transactions


	PRINT @@TRANCOUNT

COMMIT TRAN ojas_update_demo_savepoint -- since this tran is already

SELECT *,
		(SELECT AVG(salary) FROM e_dummy WHERE
			employee_dept  = outer_e_dummy.employee_dept
		) AS avg_salary
FROM
	e_dummy AS outer_e_dummy


USE sql_wknd_20240128
SELECT *
	FROM
	e_dummy AS e_dummy_outer
	WHERE
		salary = (SELECT MAX(salary) FROM e_dummy
					WHERE employee_dept = e_dummy_outer.employee_dept
				 )

-- DML Triggers in Microsoft SQL SERVER
-- Trigger is a special kind of stored procedure
-- DML Trigger ( INSERT UPDATE and DELETE events)
-- DML trigger can be attached to table or view, 
-- it can be an AFTER or INSTEAD OF trigger

-- Create A simple DML trigger
USE sql_wknd_20240128
GO
CREATE TRIGGER trg_e_dummy
ON e_dummy
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
AFTER INSERT, DELETE , UPDATE
AS
	BEGIN
		PRINT 'Something happened to the e_dummy table'	
	END
GO

SELECT * FROM e_dummy
UPDATE e_dummy
SET
	salary = salary * 1.15
WHERE
	employee_name LIKE '%Rakesh%';

-- Modify your trigger
USE [sql_wknd_20240128]
GO

/****** Object:  Trigger [dbo].[trg_e_dummy]    Script Date: 02-04-2024 19:09:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER  TRIGGER [dbo].[trg_e_dummy]
ON [dbo].[e_dummy]
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
AFTER INSERT, DELETE , UPDATE
AS
	BEGIN
		PRINT 'Something happened to the e_dummy table right now!!!!'	
	END
GO

ALTER TABLE [dbo].[e_dummy] ENABLE TRIGGER [trg_e_dummy]
GO

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
USE [sql_wknd_20240128]
GO

/****** Object:  Trigger [dbo].[trg_e_dummy]    Script Date: 02-04-2024 19:09:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER  TRIGGER [dbo].[trg_e_dummy]
ON [dbo].[e_dummy]
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
INSTEAD OF INSERT
AS
	BEGIN
		RAISERROR ('No more employees can be inserted', 16, 1)
	END
GO
-- The below statement will throw an error
-- The below statement will throw an error
INSERT INTO e_dummy
(
	employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	'Ying Maa Lee'
	,'maalong@dummyemail.com'
	,'SD-Web'
	,122222
);


-- access to the data modifued
-- make the below trigger with the AFTER 
USE sql_wknd_20240128
GO
CREATE OR ALTER  TRIGGER [dbo].[trg_e_dummy]
ON [dbo].[e_dummy]
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
AFTER  INSERT, DELETE, UPDATE
AS
	BEGIN
		SELECT * FROM inserted
	END
GO


INSERT INTO e_dummy
(
	employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	'Ying Maa Lee'
	,'maalong@dummyemail.com'
	,'SD-Web'
	,122222
);



UPDATE e_dummy
SET employee_name = 'Maa Long'
WHERE
employee_name = 'Ying Maa Lee'

-- we can use the inserted table with the validation of the database
-- for that we will create a new trigger
USE sql_wknd_20240128
GO
CREATE OR ALTER  TRIGGER [dbo].[trg_e_dummy]
ON [dbo].[e_dummy]
-- DECIDE that trigger will be an after trigger or INSTEAD of trigger
INSTEAD OF  INSERT
AS
	BEGIN
						
				IF EXISTS	
					(
						SELECT *
						FROM
						(
							SELECT employee_dept AS employee_department_name
								,salary AS employee_salary
							FROM
							inserted
						) AS employee_sal_dept
						INNER JOIN
						(
							SELECT DISTINCT e_dummy.employee_dept,
								MAX(salary) OVER(PARTITION BY employee_dept) AS max_sal
							FROM
								e_dummy
						) AS e_max_sal
						ON
						employee_sal_dept.employee_department_name = 
							e_max_sal.employee_dept
						AND
						employee_sal_dept.employee_salary > 
							e_max_sal.max_sal
					)
					BEGIN

					RAISERROR('Salary cannot be more than max salary',
									16,
									1)
					ROLLBACK TRANSACTION
					RETURN 
					END
				ELSE
					BEGIN
						INSERT INTO e_dummy(
											employee_name
											,employee_email
											,employee_dept
											,salary
											)
						SELECT				employee_name
											,employee_email
											,employee_dept
											,salary
						FROM inserted
					END
	END
GO


INSERT INTO e_dummy
(
	employee_name
	,employee_email
	,employee_dept
	,salary
)VALUES
(
	'Ying Maa Lee'
	,'maalong@dummyemail.com'
	,'SD-Web'
	,78676
);

SELECT * FROM e_dummy


--- Stored proc returning a single value

--- STORED PROC to return a single value
--- return can only return a single value
--- return value should always be int
GO
ALTER PROC sp_get_count_emp_below_avg(
			@department_name VARCHAR(100)
			)
			AS
			BEGIN
				
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
