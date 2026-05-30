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