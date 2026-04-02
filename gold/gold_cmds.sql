
IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
    DROP TABLE gold.dim_date;
GO
Create TABLE gold.dim_date(
	date_id INT IDENTITY(1,1) PRIMARY KEY,
	order_date Date,
	day VARCHAR(50),
	month_name VARCHAR(50),
	month INT,
	year INT,
	week INT,
	quarter INT
);
GO
TRUNCATE TABLE gold.dim_date
INSERT INTO gold.dim_date
SELECT Distinct
	Order_Date,
	DATENAME(WEEKDAY,Order_Date) day,
	DATENAME(MONTH,Order_Date) month_name,
	month(Order_Date) month,
	year(Order_Date) year,
	DATEPART(WEEK,Order_Date) week,
	DATENAME(quarter,Order_Date) quarter
FROM silver.swiggy_data
Order BY Order_Date;

--SELECT * FROM gold.dim_date

IF OBJECT_ID('gold.dim_location', 'U') IS NOT NULL
    DROP TABLE gold.dim_location;
GO
Create TABLE gold.dim_location (
	location_id INT IDENTITY(1,1) PRIMARY KEY,
	location NVARCHAR(50),
	city NVARCHAR(50),
	state NVARCHAR(50)
);
GO
TRUNCATE TABLE gold.dim_location
INSERT INTO gold.dim_location
SELECT Distinct
	location,
	city,
	state
FROM silver.swiggy_data;

--SELECT * FROM gold.dim_location

IF OBJECT_ID('gold.dim_resturent', 'U') IS NOT NULL
    DROP TABLE gold.dim_resturent;
GO
Create Table gold.dim_resturent (
	res_id  INT IDENTITY(1,1) PRIMARY KEY,
	restaurant_name NVARCHAR(50)
);
GO
TRUNCATE TABLE gold.dim_resturent
INSERT INTO gold.dim_resturent
SELECT Distinct
	restaurant_name
FROM silver.swiggy_data
Order by restaurant_name;
--SELECT * FROM gold.dim_resturent

IF OBJECT_ID('gold.dim_category', 'U') IS NOT NULL
    DROP TABLE gold.dim_category;
GO
Create TABLE gold.dim_category (
	cat_id  INT IDENTITY(1,1) PRIMARY KEY,
	category NVARCHAR(100)
);
GO
TRUNCATE TABLE gold.dim_category
INSERT INTO gold.dim_category
SELECT Distinct category
FROM silver.swiggy_data
Order by category;
--SELECT * FROM gold.dim_category

IF OBJECT_ID('gold.dim_dish', 'U') IS NOT NULL
    DROP TABLE gold.dim_dish;
GO
Create TABLE gold.dim_dish(
	dish_id  INT IDENTITY(1,1) PRIMARY KEY,
	dish_name NVARCHAR(200)
);
GO
TRUNCATE TABLE gold.dim_dish
INSERT INTO gold.dim_dish
SELECT Distinct	dish_name
FROM silver.swiggy_data
Order By dish_name; 
--SELECT * FROM gold.dim_dish

IF OBJECT_ID('gold.fact_swiggy_order', 'U') IS NOT NULL
    DROP TABLE gold.fact_swiggy_order;
GO
Create TABLE gold.fact_swiggy_order (
	order_id  INT IDENTITY(1,1) PRIMARY KEY,
	price_inr DECIMAL(10,2),
	rating DECIMAL(10,2),
	rating_count INT,
	date_id INT,
	location_id INT,
	res_id INT,
	cat_id INT,
	dish_id int,

	Constraint fk_date Foreign key (date_id) REFERENCES gold.dim_date(date_id),
	Constraint fk_location Foreign key (location_id) REFERENCES gold.dim_location(location_id),
	Constraint fk_resturent Foreign key (res_id) REFERENCES gold.dim_resturent(res_id),
	Constraint fk_cat Foreign key (cat_id) REFERENCES gold.dim_category(cat_id),
	Constraint fk_dish Foreign key (dish_id) REFERENCES gold.dim_dish(dish_id)
);
GO
TRUNCATE TABLE gold.fact_swiggy_order
INSERT INTO gold.fact_swiggy_order
SELECT 
	s.price_inr,
	s.rating,
	s.rating_count,
	dt.date_id,
	dl.location_id,
	dr.res_id,
	dc.cat_id,
	ds.dish_id
FROM silver.swiggy_data s

LEFT JOIN gold.dim_date dt
on dt.order_date = s.Order_Date

LEFT JOIN gold.dim_location dl
ON dl.location = s.location and dl.city = s.city and dl.state = s.state

LEFT JOIN gold.dim_resturent dr
on dr.restaurant_name = s.Restaurant_Name

LEFT JOIN gold.dim_category dc
on dc.category = s.Category

LEFT JOIN gold.dim_dish ds
on ds.dish_name = s.dish_name;

--checking swiggy data 

SELECT * FROM gold.fact_swiggy_order s
 JOIN gold.dim_date dt
on dt.date_id = s.date_id

 JOIN gold.dim_location dl
ON dl.location_id = s.location_id 
 JOIN gold.dim_resturent dr
on dr.res_id = s.res_id
 JOIN gold.dim_category dc
on dc.cat_id = s.cat_id

 JOIN gold.dim_dish ds
on ds.dish_id = s.dish_id 



