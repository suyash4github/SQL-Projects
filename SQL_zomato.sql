create database zomato;

use zomato;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from users;
select * from goldusers_signup;

--1. what is total amount each customer spent on zomato?

select a.userid,sum(b.price) as amount_spent from sales a inner join product b on a.product_id=b.product_id
group by a.userid


-- 2. How many days has each customer  visited zomato?

select userid, count(distinct created_date) as No_of_times_visited from sales
group by userid

-- 3. what was the first product purchesd by each  customer?
select * from 
(select *,RANK() over(partition by userid order by created_date ) rnk from sales ) a where rnk=1

-- 4. what is the most purchsed item on menu and how many tines was it purchased?

select userid, count(userid) as no_of_times_purchased from sales where product_id=
(select top 1 product_id from sales
group by product_id
order by count(product_id) desc)
group by userid

-- 5. which item was most popular for each customer?

select * from 
(select *,rank() over(partition by userid order by cnt desc) rnk from
(select userid, product_id, count(*) as cnt from sales
group by userid, product_id) a)b
where rnk= 1

--6. which item  was purchased first by customer after they become gold member?

select * from 
(select *,rank() over(partition by userid order by created_date ) rnk from 
(select a.userid,a.created_date,a.product_id, b.gold_signup_date from sales a inner join goldusers_signup b on 
a.userid = b.userid and created_date >= gold_signup_date) c) d 
where rnk=1

--7. which item was purchased just before the customer become the member?
select * from 
(select *,rank() over(partition by userid order by created_date desc) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join goldusers_signup b on a.userid=b.userid
and created_date < gold_signup_date) c) d
where rnk =1

--8. what is total orders and amount spent for each member before they become member?

select userid, count(created_date), sum(price) from
(select c.*, d.price from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join goldusers_signup b on a.userid=b.userid
and created_date < gold_signup_date) c inner join product d on c.product_id=d.product_id) e
group by userid

--9. I fbuying each product generates points for eg 5rs=2 zomato points and each product has different purchasing points for
-- p1  5rs=1 zomato point , for p2 10rs =5 zomato point and p3 5rs=1 zomato point.

--calculate points collected by each customer and for which product most points have been collected till now?
	
	(select userid, sum(total_points)*2.5  total_money_earned from
	(select e.*, amt/points total_points from
	(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
	(select c.userid, c.product_id, sum(price) as amt from 
	(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id) c
	group by userid, product_id) d) e) f group by userid ) 

	select * from
	(select *, rank() over(order by total_points_for_product desc) rnk from
	(select product_id, sum(total_points) total_points_for_product  from
	(select e.*, amt/points total_points from
	(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
	(select c.userid, c.product_id, sum(price) as amt from 
	(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id) c
	group by userid, product_id) d) e) f group by product_id ) h) i
	where rnk=1


--10. In the first one year after customer joins the gold programme irrespective of what the customer has purchased they earn 5 zomato points 
--for every 10 rs spent who earned 1 oe 3 and what was their points eaening in their first year?
1zp=2rs

select c.*, d.price*0.5 as total_points from
(select a.userid,a.created_date,a.product_id, b.gold_signup_date from sales a inner join goldusers_signup b on 
a.userid = b.userid and created_date >= gold_signup_date and created_date<= DATEADD(year,1,gold_signup_date))c inner join product d on
c.product_id=d.product_id 

--11. rank all the transaction of customers?

select *, rank() over(partition by userid order by created_date) rnk from sales


--12. rank all the transaction fro each member whenever they zomato gold member for every non gold member transacton mark as na

select e.*, case when rnk=0 then 'na' else rnk end as rnkk from
(select c.*, cast((case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc) end) as varchar) as rnk from
(select a.userid,a.created_date,a.product_id, b.gold_signup_date from sales a left join goldusers_signup b on 
a.userid = b.userid and created_date >= gold_signup_date ) c)e