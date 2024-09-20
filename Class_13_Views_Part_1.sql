--- VIEWS are stored queries

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