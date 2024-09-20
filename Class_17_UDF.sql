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
CREATE OR ALTER FUNCTION fn_get_city_name	(		@address AS VARCHAR(100)	)	RETURNS VARCHAR(100)	AS		BEGIN			DECLARE @city_name AS VARCHAR(100)			SELECT @city_name = 					TRIM(LEFT(@address,CHARINDEX(',', @address)))			RETURN @city_name		END'Panaji, Goa'SELECT * ,dbo.fn_get_city_name (sales_location)FROM salesman;