--BUSINESS PROBLEMS
--Q1.FIND THE DIFFERENT PAYMENT METHOD & NO. OF TRANSACTION, NO.OF QUANTITY SOLD
SELECT --DISTINCT 
	payment_method,
	COUNT(*) AS No_of_transaction,
	SUM(quantity) AS No_of_quantity_sold
FROM "Walmart"
GROUP BY payment_method

--Q2. IDENTIFY THE HIGHEST-RATED CATEGORY IN 
--EACH BRANCH, DISPLAYING THE BRANCH, CATEGORY AVG RATING
SELECT branch,category,avg_rating FROM (
	SELECT
		branch,
		category,
		AVG(rating) AS AVG_RATING,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) desc) AS rnk
	FROM "Walmart"
	GROUP BY branch,category
)
WHERE rnk = 1;


--Q3.IDENTIFY THE BUSISET DAY FOR EACH BRANCH ON THE NUMBER OF TRANSACTIONS
--change date text column to date column

SELECT branch,day_name,No_Of_Transaction
FROM(
	SELECT 
		branch,
		TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') AS Day_name,
		COUNT(*) AS No_Of_Transaction,
		RANK() OVER(partition by branch ORDER BY COUNT(*) DESC) as rnk
	FROM "Walmart"
	GROUP BY 1, 2
)
WHERE rnk = 1

--Q4. CALCULATE TOTAL QUANTITY OF ITEMS SOLD PER PAYMENT METHOD.
--LIST PAYMENT METHOD AND TOTAL QUANTITY
SELECT 
	payment_method,
	SUM(quantity) AS Total_Quantity
FROM "Walmart"
GROUP BY payment_method

--Q.5 DETERMINE THE AVG, MINIMUM & MAX RATING OF PRODUCTS FOR EACH CITY
--LIST CITY,AVE_RATING,MIN_RATING, MAX_RATING

SELECT 
	city,
	category,
	AVG(rating) AS avg_rating,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating
FROM "Walmart"
GROUP BY city,category
	

--Q6.CALCULATE TOTAL PROFIT FOR EACH CATEGORY BY CONSIDERING TOTAL PROFIT AS
--(unit_price * quantity * profit_margin).
--LIST CATEGORY, TOTAL_PROFIT, ORDERED FROM HIGHEST TO LOWEST PROFIT.

select * from "Walmart";

SELECT
	category,
	SUM(total) AS total_revenue,
	--unit_price * quantity * profit_margin AS Total_profit
	SUM(total * profit_margin) AS total_profit
FROM "Walmart"
GROUP BY category
ORDER BY 2 DESC
	
--Q7.DETERMINE MOST COMMON PAYMENT METHOD FOR EACH BRANCH.
--DISPLAY BRANCH & PREFERRED PAYMENT METHOD

WITH CTE 
AS(
	SELECT 
		branch, 
		payment_method,
		count(*) AS total_transaction,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*)DESC) as rnk
	FROM "Walmart"
	GROUP BY 1,2
--ORDER BY 1,2 DESC
)
SELECT *
FROM cte
WHERE rnk = 1

--Q8.CATEGORIZE SALES INTO 3 GROUP MORNING, AFTERNOON, EVENING
--FIND OUT WHICH OF THE SHIFT & NO OF INVOICES
SELECT
	branch,
--convert text (time) to date
CASE 
	WHEN EXTRACT (HOUR FROM (time::time)) < 12 THEN 'Morning'
	WHEN EXTRACT (HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening'
END day_time,
COUNT(*)
FROM "Walmart"
GROUP BY 1,2
ORDER BY 1,3 DESC


--Q9 IDENTIFY 5 BRANCH WITH HIGHEST DECREASE RATIO IN
-- REVENUE COMPARE TO LAST YEAR(CURRENT YEAR 23 & LAST YEAR 22)
select * from "Walmart";

-- revenue decrease ratio = last_year_rev - current_year_revenue/last_year_revenu*100
--COVERT TO DATE
SELECT *,
	EXTRACT(YEAR FROM (TO_DATE(date,'DD/MM/YY')))as formatted_date
FROM "Walmart"



--2022 SALES FOR EACH BRANCH
WITH revenue_2022
AS(
	SELECT 
		branch,
		SUM(total) AS Revenue
	FROM "Walmart"
	WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2022 --postgresql
	--WHERE YEAR(TO_DATE(date,'DD/MM/YY')) = 2022--mysql
	GROUP BY 1
),
revenue_2023
AS
(
	SELECT 
		branch,
		SUM(total) AS Revenue
	FROM "Walmart"
	WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2023
	GROUP BY 1
)
SELECT
	last_year_sale.branch,
	last_year_sale.revenue as last_year_revenue,
	current_year_sale.revenue as current_year_revenue,
	
	--ratio
	ROUND(
		(last_year_sale.revenue - current_year_sale.revenue)::numeric /
								last_year_sale.revenue::numeric *100,
		2)AS revenue_decrease_ratio
FROM revenue_2022 AS last_year_sale
JOIN revenue_2023 AS current_year_sale
ON
	last_year_sale.branch = current_year_sale.branch
WHERE
	last_year_sale.revenue > current_year_sale.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5
