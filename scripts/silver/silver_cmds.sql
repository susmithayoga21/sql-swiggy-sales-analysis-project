
IF OBJECT_ID('silver.swiggy_data', 'U') IS NOT NULL
    DROP TABLE silver.swiggy_data;
GO

CREATE TABLE silver.swiggy_data (
    state NVARCHAR(50),
    city NVARCHAR(50),
    Order_Date DATE,
    Restaurant_Name NVARCHAR(50),
    location NVARCHAR(50),
    Category VARCHAR(100),
    dish_name VARCHAR(200),
	price_inr DECIMAL(10,2),
	rating DECIMAL(10,2),
	rating_count INT,
    dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
  

  -- Inserting cleansed data to silver 
INSERT INTO silver.swiggy_data (
	state,
    city,
    order_date,
    restaurant_name,
    location,
    category,
    dish_name,
	price_inr,
	rating,
	rating_count
)
SELECT 
	state,
    city,
    order_date,
    restaurant_name,
    location,
    category,
    dish_name,
	price_inr,
	rating,
	rating_count
	FROM
		(SELECT *,
			ROW_NUMBER() over (Partition by state,
						city,
						Order_Date,
						Restaurant_Name,
						location,
						Category,
						dish_name,
						price_inr,
						rating,
						rating_count
			Order by (SELECT NULL)) flag
		FROM bronze.swiggy_data)t 
		where flag = 1 -- to remove duplicates
/*
SELECT * from  bronze.swiggy_data
Where TRIM(state) != state or  
state is NULL or state =''*/  -- Null check and Blank/Empty String Check


    




