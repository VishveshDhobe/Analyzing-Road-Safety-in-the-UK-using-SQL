
--  Time Series Analysis


create schema Time_Series_Analysis;

set schema 'time_series_analysis';

show search_path;


--- create table

create table superstore(
	Row_ID	int,
	Order_ID  varchar,
	orderDate date,
	Ship_Date date,
	Ship_mode varchar,
	Customer_ID  varchar,
	Customer_Name varchar,
	Segment varchar,
	Country varchar,
	City varchar,
	State	varchar,
	Postal_Code int,
	Region varchar,
	Product_ID	varchar,
	Category varchar,
	Sub_Category varchar,
	Product_Name varchar,
	Sales float,
	Quantity int,
	Discount float,
	Profit float
);


copy superstore
from [pathname]
delimiter ','
header csv;


-- Questions

/*

1. 	Use the LEAD window function to create a new column sales_next that displays the sales 
	of the next row in the dataset. This function will help you quickly compare a given row’s 
	values and values in the next row.

*/

with cte as(
	select * from superstore
)
select Row_ID, Order_ID , sales,
		lead(sales,1) over (order by row_id) as lead_sales
from cte;

-- or

create or replace view lead_and_prev__superstore
as
select row_ID, order_id, sales,
		lead(sales,1) over (order by row_id) as lead_sales
from superstore;


select * 
from lead_and_prev__superstore; 

/*

2. 	Create a new column sales_previous to display the values of the row above a given row.

*/

with cte as(
	select * from superstore
)
select Row_ID, Order_ID , sales,
		lead(sales,-1) over (order by row_id) as sales_previous
from cte;

/*

3. 	Rank the data based on sales in descending order using the RANK function.

*/


select row_ID, order_id, sales,rank() over (order by sales) as rank
from superstore;

/*

4. Use common SQL commands and aggregate functions to show the monthly and daily sales averages.

*/

select orderdate,ROUND(avg(sales) over(partition by orderdate order by orderdate) ::numeric,2) 
		as daily_sales_avg, round(avg(sales) over(partition by to_char(orderdate,'Month') 
		order by to_char(orderdate,'Month') ) :: numeric,2) as montly_avg_sales
from superstore ;

/*

Evaluate moving averages using the window functions.

*/

select row_id,order_id, round(sales:: numeric,2) as sales ,round(avg(sales) over
	  (order by row_id rows between unbounded preceding and current row) :: numeric, 2)
	  as moving_avg
from superstore s ;





