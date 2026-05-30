-- Data Validation & Cleaning
-- Null Check

SELECT
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN [Order_Date] IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN [Restaurant_Name] IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN [Dish_Name] IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
    SUM(CASE WHEN [Price_INR] IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN [Rating_Count] IS NULL THEN 1 ELSE 0 END) AS null_rating_count

FROM swiggy_data;

-- Blank or Empty String

select *
from swiggy_data
where State = '' or City = '' or Restaurant_Name = '' or Location = ''
    or Category = '' or Dish_Name = '';

-- Duplicate Detection

select State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name, Price_INR, Rating, Rating_Count,
    count(*) as CNT
from swiggy_data
group by 
    State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name, Price_INR, Rating, Rating_Count
having count(*) > 1;

-- Delete Duplicate

with cte as (
select *, ROW_NUMBER() over(partition by State, City, Order_Date, Restaurant_Name, Location, 
    Category, Dish_Name, Price_INR, Rating, Rating_Count order by (select null)) as rn
from swiggy_data
)
Delete from cte
where rn > 1;