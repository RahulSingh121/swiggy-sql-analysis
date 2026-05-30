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
