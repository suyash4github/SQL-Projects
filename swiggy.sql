create database swiggy
use swiggy

select * from order_details$
select * from orders$
select * from restaurants$
select * from menu$
select * from food$
select * from users$

delete from orders$
where order_id is null

-- 1. Find customers who have never ordered?

select *  from users$
where user_id not in(select user_id from orders$)

-- 2. Average price per dish?

select c.*, b.f_name,b.type from food$ b join 
(select f_id, price*1.0/no_  avg_price from
(select f_id, sum(price) price, count(price) no_ from menu$ group by f_id) a) c on c.f_id=b.f_id

-- 3. Find top restaurant in terms of number of orders for given month?

select * from 
(select *,rank() over(partition by [month] order by no_ desc) [rank] from
(select r_id, month(date) [month] , count(r_id) no_ from orders$ group by r_id, month(date))a)b
where [rank] = 1

--4. restaurants with monthly sales > 1000?

select r.r_name,a.* from restaurants$ r join 
(select r_id, month(date) [month] , sum(amount) amt from orders$ group by r_id, month(date)) a on a.r_id=r.r_id

-- 5. show all orders with order details for particular customer in aparticular date range?
-- for user_id 4 and date range 10 june to 10 july

select o.order_id, o.user_id,o.amount,r.r_name,f.f_name , d.f_id,o.date from orders$ o 
join order_details$ d on o.order_id=d.order_id
join food$ f on f.f_id=d.f_id
join restaurants$  r on r.r_id=o.r_id
where user_id=4 and (date between '2022-06-10' and '2022-07-10')

--6. find restuarnats with max repeated customers?

select top 1 r_name, count(user_id) no_of_loyal_customers from
(select r.r_name, c.user_id  from restaurants$ r join 
(select r_id, user_id, cnt  from
(select *,dense_rank() over(partition by r_id order by cnt desc) [rank] from
(select r_id, user_id, count(*) as cnt from orders$ group by  r_id, user_id)a)b
where [rank]=1) c on r.r_id=c.r_id)e
group by r_name
order by no_of_loyal_customers desc

--7. month over month revenue growth of swiggy?

select [month], sales_per_month,(sales_per_month-pre)*100/pre as [percentage] from
(select [month],sales_per_month, lag(sales_per_month,1) over(order by sales_per_month) pre from
(select b.[month],sum(sale) sales_per_month from
(select *,ROW_NUMBER() over(partition by r_id,[month] order by sale) rw from
(select r_id, month(date) [month], sum(amount) [sale] from orders$
group by r_id,month(date)
)a)b
group by b.[month])c)d

--8. customer -> favorite food 

select c.*,f.f_name from
(select user_id,f_id from
(select *,rank() over(partition by a.user_id order by cnt desc) [rank] from
(select o.user_id,d.f_id,count(d.f_id) as cnt from orders$ o 
join order_details$ d on o.order_id=d.order_id
group by o.user_id,d.f_id)a)b
where [rank]=1)c join food$ f on c.f_id=f.f_id
