/****** Customer Address Table Profiling  ******/
SELECT * FROM  [CustomerAddress]

SELECT count(*) FROM CustomerAddress --- 3999

SELECT distinct property_valuation FROM  [CustomerAddress]

SELECT distinct [state] FROM  [CustomerAddress]

SELECT customer_id,count(*) from CustomerAddress
GROUP BY customer_id
HAVING count(*) > 1


/****** Customer Demographic Table Profiling  ******/
SELECT * FROM  [CustomerDemographic] 

SELECT count(*) FROM CustomerDemographic --- 4000 

SELECT * FROM  [CustomerDemographic]
ORDER BY customer_id asc


SELECT * FROM  [CustomerDemographic]
WHERE DOB IS NOT NULL
ORDER BY DOB asc


SELECT count(*) FROM  [CustomerDemographic]
WHERE first_name IS NULL -- 0

SELECT count(*) FROM  [CustomerDemographic]
WHERE last_name IS NULL   --- 125

SELECT count(*) FROM  [CustomerDemographic]
WHERE job_title IS NULL   --- 506

SELECT count(*) FROM  [CustomerDemographic]
WHERE DOB IS NULL   --- 87

SELECT count(*) FROM  [CustomerDemographic]
WHERE tenure IS NULL   --- 87

SELECT * FROM  [CustomerDemographic]
WHERE tenure IS NULL  --- all DOB fields are also NULL

SELECT * FROM [CustomerDemographic]
WHERE gender = 'U'  ------ all DOB fields are also NULL and one of the row seems to be a typo


SELECT count(*) FROM  [CustomerDemographic]
WHERE past_3_years_bike_related_purchases IS NULL   --- 0

SELECT count(*) FROM  [CustomerDemographic]
WHERE job_industry_category IS NULL  --- 0

SELECT count(*) FROM  [CustomerDemographic]
WHERE job_industry_category = 'n/a'  --- 656

SELECT count(*) FROM  [CustomerDemographic]
WHERE wealth_segment IS NULL  --- 0

SELECT count(*) FROM  [CustomerDemographic]
WHERE owns_car IS NULL  --- 0

SELECT distinct wealth_segment FROM  [CustomerDemographic]

SELECT distinct deceased_indicator FROM  [CustomerDemographic]

SELECT * FROM CustomerDemographic
WHERE deceased_indicator = 'Y'

SELECT distinct [default] FROM  [CustomerDemographic]

SELECT distinct gender FROM  [CustomerDemographic]

SELECT distinct past_3_years_bike_related_purchases FROM  [CustomerDemographic]
 
SELECT * FROM  [CustomerDemographic]
WHERE past_3_years_bike_related_purchases  = 0

SELECT * FROM [CustomerDemographic]
WHERE DOB IS NOT NULL
ORDER BY DOB 				---1st April 1995  TO  30th Sep 1998

SELECT customer_id,count(*) from CustomerDemographic
GROUP BY customer_id
HAVING count(*) > 1



/****** Transactions Table Profiling  ******/

SELECT * FROM  [Transactions] 

SELECT count(*) FROM Transactions --- 20000

SELECT * FROM  [Transactions]
ORDER BY transaction_id 

SELECT * FROM  [Transactions]
ORDER BY customer_id 

SELECT distinct customer_id FROM  [Transactions]
ORDER BY customer_id  ---3494

SELECT * FROM  [Transactions]
ORDER BY product_id 

SELECT count(*) FROM  [Transactions]
WHERE product_id = 0 -- 1378

SELECT count(*) FROM  Transactions
WHERE transaction_date IS NULL   --- 0

SELECT count(*) FROM  Transactions
WHERE online_order IS NULL   --- 360

SELECT * FROM Transactions
WHERE online_order IS NULL

SELECT (list_price - standard_cost) as profit, * FROM  Transactions
WHERE online_order IS NULL
ORDER BY 1 desc  --- 2 records with null values for the price columns


SELECT count(*) FROM  Transactions
WHERE order_status IS NULL   --- 0

SELECT * FROM  Transactions
WHERE brand IS NULL 
OR product_line IS NULL 
OR product_class IS NULL
OR product_size IS NULL
OR standard_cost IS NULL 
OR product_first_sold_date IS NULL -- all the filtered columns are NULL, there might be a dependency

SELECT count(*) FROM  Transactions
WHERE brand IS NULL 
OR product_line IS NULL 
OR product_class IS NULL
OR product_size IS NULL
OR standard_cost IS NULL 
OR product_first_sold_date IS NULL   --- 197

SELECT distinct order_status FROM  Transactions

SELECT distinct brand FROM  Transactions

SELECT distinct product_line FROM  Transactions

SELECT distinct product_class FROM  Transactions

SELECT distinct product_size FROM  Transactions


SELECT * FROM Transactions
ORDER BY transaction_date DESC   ---7th April 2017 --- 27th Sep 2017

SELECT transaction_id,count(*) from Transactions
GROUP BY transaction_id
HAVING count(*) > 1


/****** Lets JOIN these tables ******/

SELECT count(*)
FROM Transactions t  --- 20000 total rows
JOIN CustomerDemographic d  ----- 4000 total rows
ON t.customer_id = d.customer_id  --- 19997  total rows    For 3 transactions customer's demographic is missing

SELECT distinct customer_id FROM Transactions
WHERE customer_id NOT IN (
SELECT customer_id FROM CustomerDemographic) -- 5034 

SELECT * FROM Transactions WHERE customer_id = 5034  -- looks like a bad data


SELECT count(*)
FROM  CustomerDemographic d ---4000 total rows
JOIN  CustomerAddress a --- 3999 total rows
ON d.customer_id = a.customer_id ---3996   4 values does not match


SELECT customer_id FROM CustomerDemographic
WHERE customer_id NOT IN (
SELECT customer_id FROM CustomerAddress)  -- 3, 10, 22, 23

SELECT * FROM CustomerDemographic WHERE customer_id IN('3', '10', '22', '23')   -- data looks good, must be an old entry


SELECT count(*)
FROM Transactions t  --- 20000 total rows
JOIN CustomerAddress a  ----- 3999 total rows
ON t.customer_id = a.customer_id  --- 19968  total rows    For 32 transactions customer's address are not matching 


SELECT distinct customer_id FROM Transactions
WHERE customer_id NOT IN (
SELECT customer_id FROM CustomerAddress) -- 5034,3, 10, 22, 23 as expected


/*** Lets join all the three tables and create a view out of it ***/

GO
CREATE VIEW Sprocket_Analysis AS 
SELECT t.[transaction_id]
      ,t.[product_id]
      ,t.[customer_id] 
      ,t.[transaction_date]
      ,t.[online_order]
      ,t.[order_status]
      ,t.[brand]
      ,t.[product_line]
      ,t.[product_class]
      ,t.[product_size]
      ,t.[list_price]
      ,t.[standard_cost]
      ,t.[product_first_sold_date]
      ,d.[first_name]
      ,d.[last_name]
      ,d.[gender]
      ,d.[past_3_years_bike_related_purchases]
      ,d.[DOB]
      ,d.[job_title]
      ,d.[job_industry_category]
      ,d.[wealth_segment]
      ,d.[deceased_indicator]
      ,d.[default]
      ,d.[owns_car]
      ,d.[tenure]
      ,a.[address]
      ,a.[postcode]
      ,a.[state]
      ,a.[country]
      ,a.[property_valuation]
FROM Transactions t  --- 20000 total rows
JOIN CustomerDemographic d  ----- 4000 total rows
ON t.customer_id = d.customer_id
LEFT JOIN CustomerAddress a  --- 3999 total rows    LEFT JOIN since we want to preserve all the valid customers for now
ON d.customer_id = a.customer_id  ------------ 19997, hence so customers for 3 transaction are missing
GO



SELECT TOP 1000 * FROM Sprocket_Analysis

SELECT count(*) FROM Sprocket_Analysis
WHERE address IS NULL

SELECT distinct country FROM Sprocket_Analysis -- NULL

SELECT count(*) FROM Sprocket_Analysis
WHERE country IS NULL


SELECT transaction_id, product_id, customer_id FROM Sprocket_Analysis
GROUP BY transaction_id, product_id, customer_id
HAVING Count(*) > 1

SELECT product_id, count(*) as ProductCounts from Sprocket_Analysis
GROUP BY product_id
HAVING count(*) > 1
ORDER BY 2 DESC

SELECT product_id, count(*) as ProductCounts from Sprocket_Analysis
GROUP BY product_id
HAVING count(*) > 1
ORDER BY 2 

SELECT product_id, MAX(list_price - standard_cost) AS MaxProfit 
FROM Sprocket_Analysis
GROUP BY product_id
ORDER BY MaxProfit DESC   -- 3, 38, 44, 77

SELECT product_id, ROUND(SUM(list_price - standard_cost),2) AS TotalProfit 
FROM Sprocket_Analysis
GROUP BY product_id
ORDER BY TotalProfit DESC


SELECT * FROM Sprocket_Analysis WHERE product_id = 3 

SELECT product_id, MAX(list_price - standard_cost) AS MaxProfit 
FROM Sprocket_Analysis
GROUP BY product_id
ORDER BY MaxProfit


SELECT brand, MAX(list_price - standard_cost) AS MaxProfit 
FROM Sprocket_Analysis
GROUP BY brand
ORDER BY MaxProfit DESC

SELECT brand, ROUND(SUM(list_price - standard_cost),2) AS TotalProfit 
FROM Sprocket_Analysis
GROUP BY brand
ORDER BY TotalProfit DESC

SELECT product_id,brand, MAX(list_price - standard_cost) AS Profit 
FROM Sprocket_Analysis
GROUP BY product_id, brand
ORDER BY Profit DESC  ----similar to profit by products

SELECT customer_id, MAX(list_price - standard_cost) AS MaxProfit 
FROM Sprocket_Analysis
GROUP BY customer_id
ORDER BY MaxProfit DESC

SELECT customer_id, ROUND(SUM(list_price - standard_cost),2) AS TotalProfit 
FROM Sprocket_Analysis
GROUP BY customer_id
ORDER BY TotalProfit DESC

SELECT ROUND((list_price - standard_cost),2) AS Profit, * 
FROM Sprocket_Analysis 
WHERE customer_id = 941
ORDER BY 1 DESC

SELECT product_size, ROUND(SUM(list_price - standard_cost),2) AS TotalProfit 
FROM Sprocket_Analysis
GROUP BY product_size
ORDER BY TotalProfit DESC ---------------- medium size is more profitabe

SELECT product_size, count(*) AS TotalCount 
FROM Sprocket_Analysis
GROUP BY product_size
ORDER BY TotalCount DESC   ------- Medium size are the highet

SELECT MONTH(transaction_date) AS "Month", ROUND(SUM(list_price - standard_cost),2) AS TotalProfit 
FROM Sprocket_Analysis
GROUP BY MONTH(transaction_date)
ORDER BY TotalProfit DESC


/** We can go on and get the insights by writing more queries, however I would prefer a Prep tool or Visulaization tool for further Analysis
I am using Tableau Prep again for more data quality check and python for cleaning which you can find in the Cleaning folder****/
