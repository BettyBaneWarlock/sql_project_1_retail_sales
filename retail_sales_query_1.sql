-- Retail Sales SQL Analysis Project
CREATE DATABASE RETAIL_SALES_DB;

-- Creating the Table 
DROP TABLE IF EXISTS RETAIL_SALES_TB;

-- Deleting table of same name if exists
CREATE TABLE RETAIL_SALES_TB (
	TRANSACTIONS_ID INT PRIMARY KEY,
	SALE_DATE DATE,
	SALE_TIME TIME,
	CUSTOMER_ID INT,
	GENDER VARCHAR(15),
	AGE INT,
	CATEGORY VARCHAR(100),
	QUANTITY INT,
	PRICE_PER_UNIT FLOAT,
	COGS FLOAT,
	TOTAL_SALE FLOAT
);

-- Checking if data was correctly imported
SELECT
	*
FROM
	RETAIL_SALES_TB
SELECT
	*
FROM
	RETAIL_SALES_TB
LIMIT
	10;

-- Checking amount of rows
SELECT
	COUNT(*)
FROM
	RETAIL_SALES_TB;

-- DATA CLEANING
-- Checking for null values, one column at a time
SELECT
	*
FROM
	RETAIL_SALES_TB
WHERE
	TRANSACTIONS_ID IS NULL;

SELECT
	*
FROM
	RETAIL_SALES_TB
WHERE
	SALE_DATE IS NULL;

-- Checking for null values, all at once
SELECT
	*
FROM
	RETAIL_SALES_TB
WHERE
	TRANSACTIONS_ID IS NULL
	OR SALE_DATE IS NULL
	OR SALE_TIME IS NULL
	OR CUSTOMER_ID IS NULL
	OR GENDER IS NULL
	OR AGE IS NULL
	OR CATEGORY IS NULL
	OR QUANTITY IS NULL
	OR PRICE_PER_UNIT IS NULL
	OR COGS IS NULL
	OR TOTAL_SALE IS NULL;

-- Deleting rows with null values (minus null ages)
DELETE FROM RETAIL_SALES_TB
WHERE
	TRANSACTIONS_ID IS NULL
	OR SALE_DATE IS NULL
	OR SALE_TIME IS NULL
	OR CUSTOMER_ID IS NULL
	OR GENDER IS NULL
	OR CATEGORY IS NULL
	OR QUANTITY IS NULL
	OR PRICE_PER_UNIT IS NULL
	OR COGS IS NULL
	OR TOTAL_SALE IS NULL;

-- DATA EXPLORATION
-- How many individual sales are there?
SELECT
	COUNT(*) AS TOTAL_SALES
FROM
	RETAIL_SALES_TB;

-- How many individual customers are there?
SELECT
	COUNT(DISTINCT CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM
	RETAIL_SALES_TB;

-- What are the individual categories?
SELECT DISTINCT
	CATEGORY
FROM
	RETAIL_SALES_TB;

--  DATA ANALYSIS AND BUSINESS KEY PROBLEMS AND ANSWERS
-- query 1 - retrieve all columns for sales made on '2022-11-05'
SELECT
	*
FROM
	RETAIL_SALES_TB
WHERE
	SALE_DATE = '2022-11-05';

-- query 2 - retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of November-2022
SELECT
	*
FROM
	RETAIL_SALES_TB
WHERE
	CATEGORY = 'Clothing'
	AND QUANTITY >= 4
	AND TO_CHAR(SALE_DATE, 'YYYY-MM') = '2022-11';

-- query 3 - calculate the total sales for each category
SELECT
	CATEGORY,
	SUM(TOTAL_SALE) AS NET_SALES,
	COUNT(*) AS TOTAL_ORDERS
FROM
	RETAIL_SALES_TB
GROUP BY
	1;

-- query 4 - find the average age of customers who purchased items from the 'Beauty' category
SELECT
	ROUND(AVG(AGE), 2) AS AVERAGE_AGE
FROM
	RETAIL_SALES_TB
WHERE
	CATEGORY = 'Beauty';

-- query 5 - find all transactions where the total sales is greater than 1000
SELECT
	*
	-- count(*) as num_of_big_sales
FROM
	RETAIL_SALES_TB
WHERE
	TOTAL_SALE > 1000;

-- query 6 - find the total number of transactions (transactions_id) made by each gender in each category 
SELECT
	CATEGORY,
	GENDER,
	COUNT(TRANSACTIONS_ID) AS TOTAL_TRANSACTIONS
FROM
	RETAIL_SALES_TB
GROUP BY
	1,
	2
ORDER BY
	1,
	2;

-- query 7 - calculate the average sale for each month. find out best selling month in each year
SELECT
	*
FROM
	(
		SELECT
			EXTRACT(
				YEAR
				FROM
					SALE_DATE
			) AS YEAR,
			EXTRACT(
				MONTH
				FROM
					SALE_DATE
			) AS MONTH,
			AVG(TOTAL_SALE) AS AVG_SALE,
			RANK() OVER (
				PARTITION BY
					EXTRACT(
						YEAR
						FROM
							SALE_DATE
					)
				ORDER BY
					AVG(TOTAL_SALE) DESC
			) AS RANK_OF_SALES
		FROM
			RETAIL_SALES_TB
		GROUP BY
			1,
			2
			-- ORDER BY
			-- 	1,
			-- 	3 DESC
	) AS T1
WHERE
	RANK_OF_SALES = 1;

-- query 8 - find the top 5 customers based on the highest total sales
SELECT
	CUSTOMER_ID,
	SUM(TOTAL_SALE) AS TOTAL_SALES
	-- rank() over(order by total_sale desc) 
FROM
	RETAIL_SALES_TB
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT
	5;

-- query 9 - find the number of unique customers who purchased items in each category
SELECT
	CATEGORY,
	COUNT(DISTINCT CUSTOMER_ID) AS NUM_OF_UNIQUE_CUSTOMERS
FROM
	RETAIL_SALES_TB
GROUP BY
	1;

-- query 10 - determine each shift and number of orders (example: morning <=12, afternoon 12<x<17, evening >17)
--my own answer that was still correct anyway lolz
-- select count(transactions_id), 
-- case 
-- 	when extract(hour from sale_time) < 12 then 'morning_shift'
-- 	when extract(hour from sale_time) between 12 and 17 then 'afternoon_shift'
-- 	else 'evening_shift'
-- end as shift
-- from retail_sales_tb
-- group by shift
WITH
	HOURLY_SALES AS (
		SELECT
			*,
			CASE
				WHEN EXTRACT(
					HOUR
					FROM
						SALE_TIME
				) < 12 THEN 'morning_shift'
				WHEN EXTRACT(
					HOUR
					FROM
						SALE_TIME
				) BETWEEN 12 AND 17  THEN 'afternoon_shift'
				ELSE 'evening_shift'
			END AS SHIFT
		FROM
			RETAIL_SALES_TB
	)
SELECT
	SHIFT,
	COUNT(TRANSACTIONS_ID) AS TOTAL_ORDERS
FROM
	HOURLY_SALES
GROUP BY
	SHIFT;

-- END OF PROJECT