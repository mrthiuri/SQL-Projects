USE walmart_sales_;
SHOW TABLES;
SELECT * FROM sales;

-- Understanding the data
	-- Creating a data dictionary for a general description of the columns in our table

CREATE TABLE walmart_data_dictionary (
column_name VARCHAR(255) NOT NULL,
description TEXT);

-- Inserting data into the data dictionary
INSERT INTO walmart_data_dictionary 
VALUES 
    ('Store', 'The store number'),
    ('Date', 'The week of sales'),
    ('Holiday', 'Whether the week is a special holiday week or not'),
    ('Temperature', 'The average temperature in the region during the week'),
    ('Fuel_Price', 'The cost of fuel in the region during the week'),
    ('MarkDown1-5', 'Anonymized data related to promotional markdown events'),
    ('CPI', 'The consumer price index in the region'),
    ('Unemployment', 'The unemployment rate in the region'),
    ('IsHoliday', 'Whether the week is a holiday week or not'),
    ('Weekly_Sales', 'The sales for the given store and date');

-- Establishing the analysis period
SELECT 
	DATEDIFF(MAX(STR_TO_DATE(Date, '%d-%m-%Y')), MIN(STR_TO_DATE(Date, '%d-%m-%Y'))) AS Sales_period
FROM sales
WHERE Date IS NOT NULL;
-- Taking the standard 365 days in a year
SELECT 994/365 AS Sales_period_in_years;

-- Earliest sales date in the data
SELECT
	MIN((STR_TO_DATE(Date, '%d-%m-%Y'))) AS earliest_recorded_sales_date
FROM
	sales;
-- Latest sales date
SELECT
	MAX((STR_TO_DATE(Date, '%d-%m-%Y'))) AS last_recorded_sales_date
FROM
	sales;

-- Revenue analysis
SELECT * FROM walmart_sales_.walmart_data_dictionary;
SELECT * FROM sales;

-- Establishing the total revenue in sales generated over the 2 year period

SELECT
	SUM(Weekly_sales) AS Total_revenue_generated
FROM
	sales;
    
-- Establishing the weekly average revenue
SELECT
	AVG(Weekly_sales) AS Average_weekly_revenue
FROM
	sales;

-- Establishing the daily store revenue for a select walmart store
	-- Walmart is open 7 days a week 
SELECT 
	AVG(Weekly_sales/7) AS average_daily_sales
FROM
	sales;


-- Store analysis

-- Establishing the highest sales in a week 
SELECT 
	Store,
    MAX(Weekly_Sales) AS highest_weekly_sales
FROM
	sales
GROUP BY
	Store
ORDER BY
	highest_weekly_sales DESC
    LIMIT 1;
-- From these we establish that store 14 had the highest sales generated in a week at '3818686.45' sales
    
-- Establishing the lowest sales in a week
SELECT
	Store,
    MIN(Weekly_sales) AS lowest_weekly_sales
FROM
	sales
GROUP BY
	Store
ORDER BY
	lowest_weekly_sales ASC
LIMIT 1;
-- From these we establish that store 33 had the lowest sales generated in a week at  '209986.25' sales

-- A more definitive measure would be the lowest or highest sales amount after averaging for the entire period
	
    -- Establishing the store with the lowest average weekly sales amount 
SELECT
    Store,
    AVG(Weekly_sales) AS average_weekly_revenue
FROM
    sales
GROUP BY
    Store
ORDER BY
	average_weekly_revenue ASC
LIMIT 1;
-- From this we can tell that store 33 has the lowest average_weekly_revenue over the entire period at '259861.69202797214' sales

	-- Establishing the store with the highest weekly sales revenue over the period
SELECT
    Store,
    AVG(Weekly_sales) AS average_weekly_revenue
FROM
    sales
GROUP BY
    Store
ORDER BY
	average_weekly_revenue DESC
LIMIT 1;
-- Store 20 had the highest average revenue sales amount over the 2 year period.

-- Comparing the 2 approaches we can conclude that store 33 is the worst performing store since it posted the lowest sales in any week for the entire period as well as the lowest average weekly sales for the entire period

	-- Establishing the stores revenue contribution to the total revenue
    SELECT
		Store,
        SUM(Weekly_sales) AS Total_revenue,
        (SUM(Weekly_sales)/6737218987.11001)*100 AS Pct_total_revenue_contribution
	FROM
		sales
	GROUP BY
		Store;
        -- Store with largest revenue contribution
			SELECT
				Store,
				CONCAT((SUM(Weekly_sales)/6737218987.11001)*100,'%') AS Pct_total_revenue_contribution
			FROM
				sales
			GROUP BY
				Store
			ORDER BY
				Pct_total_revenue_contribution DESC
			LIMIT 1;
-- From this we can tell that store 20 had the largest contribution to total sales at '4.473623212139157%'
			        -- Store with smallest revenue contribution
			SELECT
				Store,
				CONCAT((SUM(Weekly_sales)/6737218987.11001)*100,'%') AS Pct_total_revenue_contribution
			FROM
				sales
			GROUP BY
				Store
			ORDER BY
				Pct_total_revenue_contribution ASC
			LIMIT 1;
-- From this we can tell that store 33 had the smallest contribution to total sales at '0.5515661882313287%' further re-inforcing our conclusion that this is the worst performing store

/* To accurately concludue which are the best and worst performing stores, we need to also take into account, the unemployment rate in that geographical region,
fuel prices and the CPI index. We can thus develop a composite index that combines these factors to provide a rating system to evaluate the percentage contribution more accurately.
The weights assigned are Unemployment: 0.4, Fuel_Price : 0.3 and CPI : 0.3 . Criteria described in documentation*/
-- Creating a column in our table for the performance index
	CREATE TABLE sales_copy
		AS
	(SELECT * FROM sales);
    
		-- Adding the new column
        ALTER TABLE sales_copy
        ADD COLUMN performance_index VARCHAR(20);
        
        
		-- Creating the performance index
        SET SQL_SAFE_UPDATES = 0;
			UPDATE sales_copy
            SET performance_index = ((Fuel_Price*0.3)+(CPI*0.3)+(Unemployment*0.4))/10 ;
		SELECT * FROM sales_copy;
        
        -- Performance index analysis
        SELECT
			MAX(performance_index) AS max_performance_index,
            MIN(performance_index) AS min_performance_index
		FROM
			sales_copy;
-- Our performance index ranges between 0 and 10

-- Continuing store analysis
 
	-- Establishing store performance

            SELECT
				Store,
				CONCAT((SUM(Weekly_sales)/6737218987.11001)*100,'%') AS Pct_total_revenue_contribution,
                performance_index
			FROM
				sales_copy
			GROUP BY
				Store,performance_index
			ORDER BY
				 Pct_total_revenue_contribution
			;
-- As per this analysis, store 14 would be our best performing store while store 33 is still our worst performing store

/* Holiday analysis. 1 represents a holiday while 0 represents no holiday*/
SELECT
	Store,
    Holiday_flag,
    AVG(Weekly_sales)AS average_weekly_sales
FROM
	sales_copy
GROUP BY
	Store,Holiday_flag;

-- Analysing sales on holidays
SELECT
	Store,
    Holiday_flag,
    AVG(Weekly_sales)AS average_weekly_sales
FROM
	sales_copy
WHERE
	Holiday_flag = 1 
GROUP BY
	Store,Holiday_flag
ORDER BY
	average_weekly_sales ASC
LIMIT 1;

-- From this we can tell that store 20 had the highest average weekly sales during holidays while store 33 had the lowest average weekly sales

	-- Comparing sales during holidays and normal days

    SELECT
		holiday_flag,
        AVG(Weekly_sales) AS average_weekly_sales
	FROM
		sales_copy
	GROUP BY
		holiday_flag
	ORDER BY
		average_weekly_sales;
-- As expected, there are far more normal days than holidays hence average_weekly_sales are more for normal days
	
/* Temperature analysis.
In this section we asses how temperature affects the sales*/
SELECT
	DISTINCT(Temperature)
FROM
	sales
ORDER BY
	Temperature ASC
LIMIT 1;
-- The lowest temperature on record is '-2.06'

SELECT
	DISTINCT(Temperature)
FROM
	sales
ORDER BY
	Temperature DESC
LIMIT 1;
-- The highest recorded temperature is '100.14'

	/* To analyse the data we can assign bins to the temperature and categorise these bins and examine their effect on sales.
    In our approach, we apply sturges rule and divide the temperature into bins with the average bin width as 12.75.*/
   SELECT
    Temperature,
    CASE
		WHEN Temperature >=-3 AND Temperature <=12.75 THEN 1
        WHEN Temperature > 12.75  AND Temperature <= 25.51 THEN 2
        WHEN Temperature > 25.51 AND Temperature <= 51.02 THEN  3
        WHEN Temperature > 51.02 AND  Temperature <= 76.53 THEN  4
        WHEN Temperature > 76.53 AND Temperature <= 89.28 THEN 5
        WHEN Temperature > 89.29 AND Temperature <= 102.04 THEN  6
		ELSE  'not_classified'
	END AS temperature_level
FROM 
	sales_copy;
    
/* We classify these six distinct levels as 'Very Cold','Cold','Cool','Moderate','Warm' and 'Hot'. 
Assessing the average sales over the 2 year period based on these six temperature levels */

		-- Adding a new column temperature_level column
        ALTER TABLE sales_copy
        ADD COLUMN temperature_level  VARCHAR(20);
        
        
		-- Inserting values into the new colum
        SET SQL_SAFE_UPDATES = 0;
			UPDATE sales_copy
            SET temperature_level = CASE
				WHEN Temperature >=-3 AND Temperature <=12.75 THEN 1
				WHEN Temperature > 12.75  AND Temperature <= 25.51 THEN 2
				WHEN Temperature > 25.51 AND Temperature <= 51.02 THEN  3
				WHEN Temperature > 51.02 AND  Temperature <= 76.53 THEN  4
				WHEN Temperature > 76.53 AND Temperature <= 89.28 THEN 5
				WHEN Temperature > 89.29 AND Temperature <= 102.04 THEN  6
		ELSE  'not_classified'
        END;

	-- Analysing sales accross the different temperature levels
	SELECT
		AVG(Weekly_Sales) AS Average_weekly_sales,
        temperature_level
	FROM
		sales_copy
	WHERE
		Weekly_sales IS NOT NULL
	GROUP BY
		temperature_level
	;
    
-- Obtaining the temperature_level with the highest and lowest average sales
SELECT
		AVG(Weekly_Sales) AS Average_weekly_sales,
        temperature_level
	FROM
		sales_copy
	WHERE
		Weekly_sales IS NOT NULL
	GROUP BY
		temperature_level
	ORDER BY
		Average_weekly_sales DESC;
    ;
/* From this we can tell the highest average sales are at level 3 what we have classified as cool while the lowest average sales occur at level 1, classified as very cold.
temperature_level 4 has the second highest average_weekly_sales and temperature level 6,hot has the second lowest average_weekly_sales.
This indicates that sales are more or higher during moderate temperatures and lower or less at extermes.*/

											-- THE END🎉--
