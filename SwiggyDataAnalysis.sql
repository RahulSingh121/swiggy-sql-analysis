select * from swiggy_data;

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

-- Creating Schema
-- Dimension Table
-- Date Table

-- dim_date
CREATE TABLE dim_date (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Month INT,
    Month_Name varchar(20),
    Quarter INT,
    Week INT
);
ALTER TABLE dim_date ADD Day INT;

-- dim_location
CREATE TABLE dim_location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    State VARCHAR(100),
    City VARCHAR(100),
    Location VARCHAR(200)
);

-- dim_restaurant
CREATE TABLE dim_restaurant (
    restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
    Restaurant_Name VARCHAR(200)
);

-- dim_category
CREATE TABLE dim_category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    Category VARCHAR(200)
);

-- dim_dish
CREATE TABLE dim_dish (
    dish_id INT IDENTITY(1,1) PRIMARY KEY,
    Dish_Name VARCHAR(200)
);


-- Fact Table

CREATE TABLE fact_swiggy_orders (

    order_id INT IDENTITY(1,1) PRIMARY KEY,

    date_id INT,
    Price_INR decimal(10,2),
    Rating decimal(4,2),
    Rating_Count INT,

    location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,

    FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id),

    FOREIGN KEY (location_id)
        REFERENCES dim_location(location_id),

    FOREIGN KEY (restaurant_id)
        REFERENCES dim_restaurant(restaurant_id),

    FOREIGN KEY (category_id)
        REFERENCES dim_category(category_id),

    FOREIGN KEY (dish_id)
        REFERENCES dim_dish(dish_id)
);

-- Insert data in tables

-- dim_date
INSERT INTO dim_date (
    Full_Date, Year, Month,Month_Name, Quarter, Day, Week
)

SELECT DISTINCT
    Order_Date,
    Year(Order_Date),
    Month(Order_Date),
    datename(Month, Order_Date),
    DATEPART(Quarter, Order_Date),
    DATEPART(Week, Order_Date),
    DAY(Order_Date)

FROM swiggy_data
WHERE Order_Date IS NOT NULL;

select * from dim_date;

-- dim_location
INSERT INTO dim_location (
    State,
    City,
    Location
)

SELECT DISTINCT
    State,
    City,
    Location

FROM swiggy_data;

-- dim_restaurant
INSERT INTO dim_restaurant (
    Restaurant_Name
)

SELECT DISTINCT
    Restaurant_Name

FROM swiggy_data;

-- dim_category
INSERT INTO dim_category (
    Category
)

SELECT DISTINCT
    Category

FROM swiggy_data;

-- dim_dish
INSERT INTO dim_dish (
    Dish_Name
)

SELECT DISTINCT
    Dish_Name

FROM swiggy_data;

-- fact_table
insert into fact_swiggy_orders(
    date_id,
    Price_INR,
    Rating,
    Rating_Count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)

select 
    dd.date_id,
    s.Price_INR,
    s.Rating,
    s.Rating_Count,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
from swiggy_data s
join dim_date dd 
    on dd.Full_Date = s.Order_Date

join dim_location dl
    on dl.State = s.State
    and dl.City = s.City
    and dl.Location = s.Location

join dim_restaurant dr
    on dr.Restaurant_Name = s.Restaurant_Name

join dim_category dc
    on dc.Category = s.Category

join dim_dish dsh
    on dsh.Dish_Name = s.Dish_Name;


select * from fact_swiggy_orders;
select * from swiggy_data;

select * from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
join dim_location l on f.location_id = l.location_id
join dim_restaurant r on f.restaurant_id = r.restaurant_id
join dim_category c on f.category_id = c.category_id
join dim_dish di on f.dish_id = di.dish_id;


-- KPI's
-- Total Order's

select count(order_id) from fact_swiggy_orders;

-- Total Revenue (INR Million)
select format(SUM(convert(float, Price_INR)) / 1000000, 'N2') + 'INR Million'
    as total_revenue
from fact_swiggy_orders;

-- Avgerage Dish Price
select format(AVG(convert(float, Price_INR)), 'N2') + 'INR'
    as Average_revenue
from fact_swiggy_orders;

-- Average Rating
select format(AVG(Rating), 'N1') as avg_rating
from fact_swiggy_orders;

-- Deep-Dive Business Analysis

-- Monthly order trends
select d.Year, d.Month, d.Month_Name, count(*) as total_orders
from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
group by d.Year, d.Month, d.Month_Name
order by total_orders desc;

select d.Year, d.Month, d.Month_Name, SUM(Price_INR) as total_revenues
from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
group by d.Year, d.Month, d.Month_Name
order by total_revenues desc;

--Quaterly order trends
select d.Year, d.Quarter, count(*) as total_orders
from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
group by d.Year, d.Quarter;

select d.Year, d.Quarter, SUM(Price_INR) as total_revenues
from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
group by d.Year, d.Quarter
order by total_revenues desc;

-- Year-wise growth
select d.Year, count(*) as total_orders, SUM(Price_INR) as total_revenues
from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
group by d.Year
order by total_revenues desc;

--Day-of-week patterns
select DATENAME(WEEKDAY, d.Full_Date) as day_name, 
    count(*) as total_orders, SUM(Price_INR) as total_revenues
from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
group by DATENAME(WEEKDAY, d.Full_Date)
order by total_revenues desc;

-- Location-Based Analysis
select * from dim_location;
-- Top 10 cities by order volume
select top 10 l.City, count(*) as total_order
from fact_swiggy_orders f
join dim_location l on f.location_id = l.location_id
group by l.City
order by total_order desc;

-- Revenue contribution by states
select l.State, SUM(Price_INR) as total_revenue
from fact_swiggy_orders f
join dim_location l on f.location_id = l.location_id
group by l.State
order by total_revenue desc;

-- Food Performance

-- Top 10 restaurants by orders
select top 10 r.Restaurant_Name, count(*) as total_orders
from fact_swiggy_orders f
join dim_restaurant r on f.restaurant_id = r.restaurant_id
group by r.Restaurant_Name
order by total_orders desc; -- or for select top 10 , use 'offset 0 rows fetch next 10 rows only' syntax.

-- Top categories
select c.Category, count(*) as total_categories
from fact_swiggy_orders f
join dim_category c on f.category_id = c.category_id
group by c.Category
order by total_categories desc;

-- Most ordered dishes
select di.Dish_Name, count(*) as total_orders
from fact_swiggy_orders f
join dim_dish di on f.dish_id = di.dish_id
group by di.Dish_Name
order by total_orders desc;

-- Cuisine performance → Orders + Avg Rating
select c.Category, count(*) as total_orders, cast(AVG(f.Rating) as decimal(10,1)) as avg_rating
from fact_swiggy_orders f
join dim_category c on f.category_id = c.category_id
group by c.Category
order by total_orders desc;

/* 
Buckets of customer spend:
Under 100
100–199
200–299
300–499
500+
With total order distribution across these ranges.
*/
select 
    case 
        when convert(float, Price_INR) < 100 then 'Under 100'
        when convert(float, Price_INR) between 100 and 199 then '100–199'
        when convert(float, Price_INR) between 200 and 299 then '200–299'
        when convert(float, Price_INR) between 300 and 399 then '300–399'
        
        else '500+'
    end as price_range,
    count(*) as total_order
    
from fact_swiggy_orders f
group by 
    case 
        when convert(float, Price_INR) < 100 then 'Under 100'
        when convert(float, Price_INR) between 100 and 199 then '100–199'
        when convert(float, Price_INR) between 200 and 299 then '200–299'
        when convert(float, Price_INR) between 300 and 399 then '300–399'
        
        else '500+'
    end
order by total_order desc;

-- Ratings Analysis

-- Distribution of dish ratings from 1–5.
select Rating, count(*) as total_dishes
from fact_swiggy_orders
group by Rating
order by Rating
