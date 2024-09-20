--- VIEWS are stored queries
USE sql_wkday_20240228;
SELECT TOP 10 * FROM orders;
SELECT TOP 10 * FROM customers;
SELECT TOP 10 * FROM salesman;
SELECT TOP 10 * FROM discounts;

-- Summary Reports
-- ONEST MDM (SUMMARY REPORTS)
--- View does not hold any data
--- View only stored the structure
--- THE GO statement will create a new batch
GO
CREATE OR ALTER VIEW vw_sales_summary_report
AS
SELECT orders.*
	   ,customers.customer_name
	   ,customers.customer_address
	   ,salesman.sales_name
	   ,salesman.sales_location
	   ,salesman.sales_doj
	   ,TRIM(RIGHT(customer_address, 
					LEN(customer_address) - 
					CHARINDEX(' ', customer_address))) AS customer_state_name
		,TRIM(RIGHT(sales_location, 
					LEN(sales_location) - 
					CHARINDEX(' ', sales_location))) AS state_sale_location
		,orders.item_price * orders.quantity AS price_b_discount
		,COALESCE(discounts.disc_perc, 0) AS disc_perc
		,orders.item_price * orders.quantity 
			* COALESCE(discounts.disc_perc, 0)/100.0000 AS discounted_amount
		,(orders.item_price * orders.quantity) - 
			(orders.item_price * orders.quantity 
			* COALESCE(discounts.disc_perc, 0)/100.0000) AS price_a_discount
FROM
	orders
INNER JOIN
	customers
ON
	orders.customer_id = customers.customer_id
INNER JOIN
	salesman
ON
	orders.salesman_id = salesman.sales_id
LEFT OUTER JOIN
	discounts
ON
	DATEPART(YYYY, orders.purchase_date) = discounts.disc_year
AND
	DATEPART(M, orders.purchase_date) = discounts.disc_month


SELECT *,
	DENSE_RANK() OVER(ORDER BY total_sales DESC) AS sales_rank
FROM
(
SELECT customer_state_name, SUM(price_a_discount) AS total_sales
FROM
[dbo].[vw_sales_summary_report]
GROUP BY
	customer_state_name
) AS sub_q_1


--- ALTER THE Structure of the View
USE [sql_wkday_20240228]
GO
CREATE OR ALTER   VIEW [dbo].[vw_sales_summary_report]
AS
SELECT orders.*
		,DATEPART(YYYY, purchase_date) AS purchase_year
		,DATEPART(M, purchase_date) AS purchase_month
	   ,customers.customer_name
	   ,customers.customer_address
	   ,salesman.sales_name
	   ,salesman.sales_location
	   ,salesman.sales_doj
	   ,TRIM(RIGHT(customer_address, 
					LEN(customer_address) - 
					CHARINDEX(' ', customer_address))) AS customer_state_name
		,TRIM(RIGHT(sales_location, 
					LEN(sales_location) - 
					CHARINDEX(' ', sales_location))) AS state_sale_location
		,CAST(orders.item_price * orders.quantity AS DECIMAL(10,2)) AS price_b_discount
		,CAST(COALESCE(discounts.disc_perc, 0) AS DECIMAL(6,2)) AS disc_perc
		,orders.item_price * orders.quantity 
			* COALESCE(discounts.disc_perc, 0)/100 
			AS discounted_amount
		,(orders.item_price * orders.quantity) - 
			(orders.item_price * orders.quantity 
			* COALESCE(discounts.disc_perc, 0)/100.0000) AS price_a_discount
FROM
	orders
INNER JOIN
	customers
ON
	orders.customer_id = customers.customer_id
INNER JOIN
	salesman
ON
	orders.salesman_id = salesman.sales_id
LEFT OUTER JOIN
	discounts
ON
	DATEPART(YYYY, orders.purchase_date) = discounts.disc_year
AND
	DATEPART(M, orders.purchase_date) = discounts.disc_month
GO


-- SQL PROGRAMMING (7 CLASSES)
-- TABLE DESIGN ( 2 CLASSES)

--- top 3 states (where stores are located) that has the highest sales after discount?
GO
CREATE OR ALTER VIEW vw_top_3_sales_state
ASWITH    price_tabAS(SELECT od.*	   ,cus.customer_name	   ,cus.customer_address	   ,ss.sales_name	   ,(od.item_price * od.quantity) - 			(od.item_price * od.quantity 			* COALESCE(dis.disc_perc, 0)/100) AS price_a_discount       ,TRIM(RIGHT(ss.sales_location, 					LEN(ss.sales_location) - 					CHARINDEX(' ', ss.sales_location))) AS state_sale_locationFROM	orders AS odINNER JOIN	customers AS cusON	od.customer_id = cus.customer_idINNER JOIN	salesman AS ssON	od.salesman_id = ss.sales_idLEFT OUTER JOIN	discounts AS disON	DATEPART(YYYY, od.purchase_date) = dis.disc_yearAND	DATEPART(M, od.purchase_date) = dis.disc_month)SELECT state_sale_location, total_salFROM(SELECT *, DENSE_RANK() OVER(ORDER BY total_sal DESC) AS sales_rankFROM    (		SELECT state_sale_location,       SUM(price_a_discount) AS total_salFROM         price_tabGROUP BY        state_sale_location) AS sub_q_1) AS sub_q_2WHEREsub_q_2.sales_rank <=3;--Querying the viewSELECT * FROM vw_top_3_sales_state;-- Top 3 customers  based on the highest total sales after discount?
GO
CREATE OR ALTER VIEW vw_top_3_customers
AS
WITH    price_tabAS(SELECT od.*	   ,cus.customer_name	   ,cus.customer_address	   ,(od.item_price * od.quantity) - 			(od.item_price * od.quantity 			* COALESCE(dis.disc_perc, 0)/100) AS price_a_discountFROM	orders AS odINNER JOIN	customers AS cusON	od.customer_id = cus.customer_idLEFT OUTER JOIN	discounts AS disON	DATEPART(YYYY, od.purchase_date) = dis.disc_yearAND	DATEPART(M, od.purchase_date) = dis.disc_month)SELECT customer_id, customer_name, customer_address, total_salFROM(SELECT *,	DENSE_RANK() OVER(ORDER BY total_sal DESC) AS sales_rankFROM    (	SELECT		customer_id		,customer_name		,customer_address		,SUM(price_a_discount) AS total_salFROM         price_tabGROUP BY        customer_id, customer_name,customer_address) AS sub_q_1) AS sub_q_2WHEREsub_q_2.sales_rank <=3;

SELECT * FROM vw_top_3_customers


-- Top 3 salesman based on the highest count of sales?
GOCREATE OR ALTER VIEW vw_top_3_salesman_countASWITH price_tabAS(SELECT od.order_id		,ss.sales_id		,ss.sales_name		,ss.sales_location		,ss.sales_dojFROM     orders AS odINNER JOIN    salesman AS ssON    od.salesman_id = ss.sales_id),salesman_sales_countAS(SELECT sales_id		,sales_name		,sales_location		,sales_doj		,COUNT(order_id) AS total_sales_countFROM price_tabGROUP BY		sales_id		,sales_name		,sales_location		,sales_doj)SELECT *FROM(SELECT *,		DENSE_RANK() OVER(ORDER BY total_sales_count DESC) AS sales_count_rankFROM	salesman_sales_count) AS sub_q_1WHEREsales_count_rank <=3;SELECT * FROM vw_top_3_salesman_count--- create a view using the table dummy_personGOCREATE OR ALTER VIEW vw_dummy_recordsASSELECT * FROM dummy_records;SELECT * FROM vw_dummy_records--- I am inserting some data into dummy_recordsINSERT INTO dummy_recordsVALUES('Shouvik', 35);DELETE FROM dummy_recordsWHEREfriend_name IS NULL;SELECT * FROM vw_dummy_records;-- Adding a column in the dummy records tableALTER TABLE dummy_recordsADD friend_location VARCHAR(100);--update statement to add a value to the column friend_locationUPDATE dummy_recordsSET	friend_location = 'Bengaluru';SELECT * FROM dummy_records;SELECT * FROM vw_dummy_records;INSERT INTO dummy_recordsVALUES('Deepak', 35, 'Pune');--CREATE OR ALTER VIEW vw_dummy_recordsASSELECT * FROM dummy_records;-- VIEW IS created from a single table-- for now , please understand, that when a view is created from a single tab;e-- we can use the view to insert, delete and UPDATE THE underlying tableSELECT * FROM vw_dummy_recordsINSERT INTO vw_dummy_records(	friend_name	,friend_age	,friend_location)VALUES(	'Priyanka'	, 30	,'Bhubaneshwar');SELECT * FROM dummy_records;EXEC sp_help vw_dummy_recordsSELECT * FROM vw_dummy_records;-- UPDATE using a viewUPDATE vw_dummy_recordsSET friend_location = 'Kolkata'WHEREfriend_name = 'Kiran';SELECT * FROM vw_dummy_records;ALTER TABLE dummy_recordsDROP COLUMN friend_location;SELECT * FROM dummy_records;-- View or function 'vw_dummy_records' has more column names-- Specified than columns defined.SELECT * FROM vw_dummy_records;-- How to put some checks in place so that we do not change the structure-- of the table where a VIEW is dependent on the tableALTER TABLE dummy_recordsADD friend_location VARCHAR(100);--update statement to add a value to the column friend_locationUPDATE dummy_recordsSET	friend_location = 'Bengaluru';SELECT * FROM vw_dummy_records;-- When creating a view with schemabinding-- we have to specify all the columns explicitly-- we cannot give a * to specify columns-- Cannot schema bind view 'vw_dummy_records_new' because name 'dummy_records' is invalid for schema binding.--  Names must be in two-part format and an object cannot reference itself.CREATE OR ALTER VIEW vw_dummy_records_new WITH SCHEMABINDINGASSELECT friend_name		,friend_age		,friend_locationFROM [dbo].[dummy_records]SELECT * FROM vw_dummy_records_newWHERE friend_age >= 35;-- ALTER THE table from which the SCHEMABINDING view is created-- and drop an underlying column-- This is the error message-- ALTER TABLE DROP COLUMN friend_location failed because one or more objects access this column.ALTER TABLE dummy_recordsDROP COLUMN friend_location;-- Adding new columns to the underlying table is allowedALTER TABLE dummy_recordsADD friend_occupation VARCHAR(100);UPDATE dummy_recordsSET friend_occupation = 'Software Developer';SELECT * FROM dummy_records;SELECT * FROM dbo.vw_dummy_records-- the schemabinding will prevent me from-- altering the structure of those columns on which the VIEW is dependentALTER TABLE dummy_recordsALTER COLUMN  friend_name VARCHAR(200);-----IF A view is created from A Single table-- we can use the view to INSERT UPDATE and deleteCREATE TABLE kids_new(	kid_id INT PRIMARY KEY	,kid_name VARCHAR(10) NOT NULL	,sport_id INT NOT NULL);INSERT INTO kids_newVALUES(1, 'Jiten', 1),(2, 'Lekha', 1),(3, 'Naman', 1);CREATE OR ALTER VIEW vw_kids WITH SCHEMABINDINGASSELECT 		kid_name,		sport_idFROM dbo.kids_new;SELECT *FROMvw_kids-- Cannot insert the value NULL into column 'kid_id', table 'sql_wkday_20240228.dbo.kids_new';0-- column does not allow nulls. INSERT fails.-- The view is not made up of the primary key hence the VIEW-- cannot be used to insert new records into the underlying tableINSERT INTO vw_kids(	kid_name	,sport_id)VALUES(	'Rounak'	,1);UPDATE vw_kidsSET	sport_id = 2WHERE	sport_id = 1;SELECT * FROM kids_new;SELECT * FROM kids_new;UPDATE vw_kidsSET kid_name = 'Sushmita'WHERE	kid_name = 'Rekha';UPDATE vw_kidsSET 	kid_name = 'Jiten Shah'WHERE	kid_name  = 'Jiten';--- in the perspective of the VIEW the column kid_id does not existsUPDATE vw_kidsSET 	kid_name = 'Jiten Shah'WHERE	kid_id  = 1;--- WITH CHECK OPTIONGOCREATE OR ALTER VIEW vw_sd_report WITH SCHEMABINDINGASSELECT    employee_id		, employee_name		, employee_email		, employee_dept		, salary	FROM dbo.employeesWHERE 	employee_dept = 'SD-Report';--- STRUCTURE IS THE column names and the datatype of those columnsEXEC sp_help vw_sd_report;INSERT INTO vw_sd_report(			employee_id		, employee_name		, employee_email		, employee_dept		, salary)VALUES(603	,'Bhaskar Kumar Rao'	,'raobhaskar@dummyemail.com'	,'SD-DB'	,100000);ALTER TABLE employeesADD blood_group VARCHAR(4);UPDATE employeesSET blood_group ='0+';SELECT * FROM vw_sd_report;SELECT * FROM vw_sd_report-- Invalid column name 'blood_group'.INSERT INTO vw_sd_report(			employee_id		, employee_name		, employee_email		, employee_dept		, salary		,blood_group)VALUES(603	,'Bhaskar Kumar Rao'	,'raobhaskar@dummyemail.com'	,'SD-DB'	,100000	,'AB+');---- insertINSERT INTO vw_sd_reportVALUES(601,'Divya Kumari Selvi','divyaselvi@dummyemail.com' ,'SD-Report', 100000);SELECT *FROMvw_sd_reportWHEREemployee_name LIKE 'Divya%';INSERT INTO vw_sd_reportVALUES(602,'Kavya Kumari Rao','raokavya@dummyemail.com' ,'SD-WEB', 100000);-- This view will only SELECT *FROMvw_sd_reportWHEREemployee_name LIKE 'Kavya%Rao';SELECT *FROMemployeesWHEREemployee_name LIKE 'Kavya%Rao'ORemployee_name LIKE 'Divya%'GOCREATE OR ALTER VIEW vw_sd_report WITH SCHEMABINDINGASSELECT    employee_id		, employee_name		, employee_email		, employee_dept		, salary	FROM dbo.employeesWHERE 	employee_dept = 'SD-Report'AND	salary < 75000	WITH CHECK OPTION;-- The attempted insert or update failed because the target view
-- either specifies WITH CHECK OPTION or spans a view that specifies
--- WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.
INSERT INTO vw_sd_report(			employee_id		, employee_name		, employee_email		, employee_dept		, salary)VALUES(604	,'Bhaskar Kumar Rao'	,'raobhaskar@dummyemail.com'	,'SD-DB'	,100000	);UPDATE vw_sd_reportSET employee_dept = 'SD-Web'WHERE	employee_name LIKE 'Divya%'CREATE OR ALTER VIEW vw_kids WITH SCHEMABINDINGASSELECT 		kid_name,		sport_idFROM 		dbo.kids_new;SELECT * FROM vw_kids;SELECT * FROM kids_new;ALTER TABLE kids_newADD  school_name VARCHAR(40);UPDATE kids_newSET	school_name = 'Gurukul Techno Academy';-- Invalid column name 'school_name'.UPDATE vw_kids	SET school_name = 'New Horizon School';ALTER TABLE kids_newADD kid_age INT;UPDATE kids_new	SET kid_age = 5;-- if I try to alter the structure of the kid_name or the sport_id column-- SQL will prevent me from altering the structure as the structure is protected-- using SCHEMABINDINGALTER TABLE kids_new	ALTER COLUMN kid_name VARCHAR(40);SELECT 'VIEW' , * FROM vw_kidsSELECT 'TABLE', * FROM kids_new-- for the VIEW vw_kids, the kid_age column does not exists-- Invalid column name 'kid_age'.INSERT INTO vw_kids(	kid_name	,sport_id	,kid_age) VALUES(	'Ashish'	,1	,8);--USE sql_wkday_20240228;CREATE OR ALTER VIEW vw_sd_report WITH SCHEMABINDINGASSELECT    employee_id		, employee_name		, employee_email		, employee_dept		, salary	FROM dbo.employeesWHERE 	employee_dept = 'SD-Report'AND	salary < 75000	WITH CHECK OPTION;--- I can use the VIEW to insert data into a table when the view is created from--- one table onlyINSERT INTO vw_sd_report(	employee_id		, employee_name		, employee_email		, employee_dept		, salary) VALUES(	608	,'Gowtam Hari Nair'	,'gowtamnair@dummyemail.com'	,'SD-Report'	,70000);SELECT * FROM vw_sd_report;-- The attempted insert or update failed because the target view either
-- specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.
INSERT INTO vw_sd_report(	employee_id		, employee_name		, employee_email		, employee_dept		, salary) VALUES(	609	,'Deepa S Nair'	,'deepanair@dummyemail.com'	,'SD-DB'	,70000);INSERT INTO vw_sd_report(	employee_id		, employee_name		, employee_email		, employee_dept		, salary) VALUES(	609	,'Deepa S Nair'	,'deepanair@dummyemail.com'	,'SD-Report' -- this is confirming with the WITH CHECK OPTION	,80000 -- This value is not confirming with the WITH CHECK OPTION);