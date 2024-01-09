use PizzaDB;
select * from pizza_sales;

-- Revenue 
select sum(total_price) as totalprice from pizza_sales;

-- Average order value
select (sum(total_price)/count(distinct order_id)) as avg_ord_val from pizza_sales;

-- total pizza sold
select sum(quantity) as total_pizza_sold from pizza_sales;

-- total orders placed
select count(distinct order_id) as ord_placed from pizza_sales;

-- Average pizza per order
select cast(cast(sum(quantity) as decimal(10,2))/cast(count(distinct order_id) as decimal(10,2)) as decimal(10,2)) as pizzas_per_ord from pizza_sales;

-- orders per day
select datename(dw,order_date) as order_day , count(distinct order_id)  as total_order from pizza_sales
group by datename(dw,order_date);

-- Monthly trend orders
select datename(MONTH, order_date) as Month_ , count(distinct order_id) as total_ordrs from pizza_sales
group by datename(month,order_date)
order by total_ordrs desc;

-- percentage sales by pizza category
select pizza_category , cast(sum(total_price) * 100/(select sum(total_price) from pizza_sales where month(order_date) = 1) as decimal(10,2)) as per_sales from pizza_sales
where month(order_date) = 1
group by pizza_category
order by per_sales desc;

-- pecenatge sales by pizza size

select pizza_size , cast(sum(total_price) *100/(select sum(total_price) from pizza_sales where datepart(quarter,order_date)=1) as decimal(10,2))as per_sales_by_size from pizza_sales
where datepart(quarter,order_date)=1
group by pizza_size
order by per_sales_by_size desc


-- top 5 best sellers by revenue ,quantity, total orders
select top 5 pizza_name , sum(total_price) as revenue from pizza_sales
group by pizza_name
order by revenue desc

select top 5 pizza_name , sum(quantity) as total_quantity from pizza_sales
group by pizza_name
order by total_quantity desc

select top 5 pizza_name , count(distinct order_id) as t_orders from pizza_sales
group by pizza_name
order by t_orders desc
