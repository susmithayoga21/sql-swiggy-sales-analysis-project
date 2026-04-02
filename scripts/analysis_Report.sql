/*==================================
Basic KPIs
	•	Total Orders
	•	Total Revenue (INR Million)
	•	Average Dish Price
	•	Average Rating
====================================*/

Select Count(*) Total_Orders,
Cast(CAST(SUM(price_inr/1000000) as Decimal(10,2))as varchar) + ' Million INR' Total_Revenue,
AVG(price_inr) Avg_Dish_Price,
AVG(rating) Avg_Rating
FROM gold.fact_swiggy_order;


/*=============================
Date-Based Analysis
	•	Monthly order trends
	•	Quarterly order trends
	•	Year-wise growth
	•	Day-of-week patterns
===============================*/
--Monthly order trends
SELECT d.month_name,
Count(*) Monthly_Orders,
Cast(CAST(SUM(price_inr/1000000) as Decimal(10,2))as varchar) + ' Million INR' Monthly_Revenue
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_date d
on d.date_id = f.date_id
Group by d.month_name,d.month
ORDER BY Monthly_Revenue Desc


--Quarterly order trends
SELECT d.quarter,
Count(*) Quarterly_Orders,
Cast(CAST(SUM(price_inr/1000000) as Decimal(10,2))as varchar) + ' Million INR' Quarterly_Revenue
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_date d
on d.date_id = f.date_id
Group by d.quarter
ORDER BY Quarterly_Revenue DESC

--Year-wise growth
SELECT d.year,
Count(*) Yearly_Orders,
Cast(CAST(SUM(price_inr/1000000) as Decimal(10,2))as varchar) + ' Million INR' Yearly_Revenue
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_date d
on d.date_id = f.date_id
Group by d.year
ORDER BY Yearly_Revenue

--Day-of-week patterns
SELECT d.day,
Count(*) Days_Orders,
Cast(CAST(SUM(price_inr/1000000) as Decimal(10,2))as varchar) + ' Million INR' Days_Revenue
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_date d
on d.date_id = f.date_id
Group by d.day
ORDER BY Days_Revenue Desc


/*=================================
Location-Based Analysis
•	Top 10 cities by order volume
•	Revenue contribution by states
===================================*/

--Top 10 cities by orders
SELECT TOP 10 l.city,
Count(*) Total_Orders
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_location l
on l.location_id = f.location_id
GROUP by l.city
Order by Total_Orders DESC

--Revenue contribution by states
SELECT l.state,
Count(*) Total_Orders,
Cast(CAST(SUM(f.price_inr/1000000) as Decimal(10,2))as varchar) + ' Million INR' State_Revenue
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_location l
on l.location_id = f.location_id
GROUP by l.state
Order by State_Revenue DESC


/*===========================================
Food Performance
•	Top 10 restaurants by orders
•	Top categories (Indian, Chinese, etc.)
•	Most ordered dishes
•	Cuisine performance → Orders + Avg Rating
==============================================*/

--Top 10 restaurants by orders
SELECT TOP 10 r.restaurant_name,
Count(*) Total_Orders
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_resturent r
on r.res_id = f.res_id
GROUP by r.restaurant_name
order by Total_Orders Desc

--Top categories (Indian, Chinese, etc.)
SELECT TOP 50 c.category,
Count(*) Total_Orders
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_category c
on c.cat_id = f.cat_id
GROUP BY c.category
ORDER BY Total_Orders Desc

--Most ordered dishes
SELECT ds.dish_name,
Count(*) Total_Orders
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_dish ds
on ds.dish_id = f.dish_id
GROUP BY ds.dish_name
ORDER BY Total_Orders Desc

--Cuisine performance → Orders + Avg Rating
SELECT c.category,
Count(*) Total_Orders,
AVG(rating) Avg_Rating
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_category c
on c.cat_id = f.cat_id
GROUP BY c.category
ORDER BY Total_Orders DESC,Avg_Rating Desc

/*================================================
Customer Spending Insights
Buckets of customer spend:
•	Under 100
•	100–199
•	200–299
•	300–499
•	500+
With total order distribution across these ranges.
===================================================*/

WITH CTE AS(
SELECT price_inr price,
CASE WHEN price_inr <100 THEN 'Under 100'
		WHEN price_inr BETWEEN 100 AND  199  THEN '100–199'
		WHEN price_inr BETWEEN 200 AND  299  THEN '200–299'
		WHEN price_inr BETWEEN 300 AND  499  THEN '300–499'
		ELSE '500+'
	END Buckets
FROM gold.fact_swiggy_order )
SELECT Buckets,
Count(*) Total_Orders
FROM CTE
GROUP BY Buckets
ORDER BY Total_Orders DESC

/*====================================
Ratings Analysis
Distribution of dish ratings from 1–5.
=====================================*/

SELECT ds.dish_name,f.rating,
Count(*) Total_Rating_Dishes
FROM gold.fact_swiggy_order f
LEFT JOIN gold.dim_dish ds
on ds.dish_id = f.dish_id
group by ds.dish_name,f.rating
ORDER BY Total_Rating_Dishes DESC

