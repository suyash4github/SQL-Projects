create database burgerbash;
use burgerbash;

CREATE TABLE burger_names(
   burger_id   INTEGER  NOT NULL PRIMARY KEY 
  ,burger_name VARCHAR(10) NOT NULL
);
INSERT INTO burger_names(burger_id,burger_name) VALUES (1,'Meatlovers');
INSERT INTO burger_names(burger_id,burger_name) VALUES (2,'Vegetarian');

CREATE TABLE runner_orders(
   order_id     INTEGER  NOT NULL PRIMARY KEY 
  ,runner_id    INTEGER  NOT NULL
  ,pickup_time  timestamp
  ,distance     VARCHAR(7)
  ,duration     VARCHAR(10)
  ,cancellation VARCHAR(23)
);
INSERT INTO runner_orders VALUES (1,1,'2021-01-01 18:15:34','20km','32 minutes',NULL);
INSERT INTO runner_orders VALUES (2,1,'2021-01-01 19:10:54','20km','27 minutes',NULL);
INSERT INTO runner_orders VALUES (3,1,'2021-01-03 00:12:37','13.4km','20 mins',NULL);
INSERT INTO runner_orders VALUES (4,2,'2021-01-04 13:53:03','23.4','40',NULL);
INSERT INTO runner_orders VALUES (5,3,'2021-01-08 21:10:57','10','15',NULL);
INSERT INTO runner_orders VALUES (6,3,NULL,NULL,NULL,'Restaurant Cancellation');
INSERT INTO runner_orders VALUES (7,2,'2021-01-08 21:30:45','25km','25mins',NULL);
INSERT INTO runner_orders VALUES (8,2,'2021-01-10 00:15:02','23.4 km','15 minute',NULL);
INSERT INTO runner_orders VALUES (9,2,NULL,NULL,NULL,'Customer Cancellation');
INSERT INTO runner_orders VALUES (10,1,'2021-01-11 18:50:20','10km','10minutes',NULL);

CREATE TABLE burger_runner(
   runner_id   INTEGER  NOT NULL PRIMARY KEY 
  ,registration_date date NOT NULL
);
INSERT INTO burger_runner VALUES (1,'2021-01-01');
INSERT INTO burger_runner VALUES (2,'2021-01-03');
INSERT INTO burger_runner VALUES (3,'2021-01-08');
INSERT INTO burger_runner VALUES (4,'2021-01-15');

CREATE TABLE customer_orders(
   order_id    INTEGER  NOT NULL 
  ,customer_id INTEGER  NOT NULL
  ,burger_id    INTEGER  NOT NULL
  ,exclusions  VARCHAR(4)
  ,extras      VARCHAR(4)
  ,order_time  timestamp NOT NULL
);
INSERT INTO customer_orders VALUES (1,101,1,NULL,NULL,'2021-01-01 18:05:02');
INSERT INTO customer_orders VALUES (2,101,1,NULL,NULL,'2021-01-01 19:00:52');
INSERT INTO customer_orders VALUES (3,102,1,NULL,NULL,'2021-01-02 23:51:23');
INSERT INTO customer_orders VALUES (3,102,2,NULL,NULL,'2021-01-02 23:51:23');
INSERT INTO customer_orders VALUES (4,103,1,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (4,103,1,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (4,103,2,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (5,104,1,NULL,'1','2021-01-08 21:00:29');
INSERT INTO customer_orders VALUES (6,101,2,NULL,NULL,'2021-01-08 21:03:13');
INSERT INTO customer_orders VALUES (7,105,2,NULL,'1','2021-01-08 21:20:29');
INSERT INTO customer_orders VALUES (8,102,1,NULL,NULL,'2021-01-09 23:54:33');
INSERT INTO customer_orders VALUES (9,103,1,'4','1, 5','2021-01-10 11:22:59');
INSERT INTO customer_orders VALUES (10,104,1,NULL,NULL,'2021-01-11 18:34:49');
INSERT INTO customer_orders VALUES (10,104,1,'2, 6','1, 4','2021-01-11 18:34:49');

show tables;
select * from burger_runner;
select * from customer_orders;
select * from burger_names;
select * from runner_orders;

-- How many burgers were ordered?
select count(*) no_of_burgers from customer_orders;

-- How many unique customer orders were made?
select distinct order_id as unique_orders from customer_orders
order by order_id;

-- How many successful orders were delivered by each runner?
select runner_id, count(runner_id) No_of_succesful_deliveries from runner_orders
where cancellation is null
group by runner_id
order by runner_id;

-- How many each type of burgers were delivered?
select n.burger_name,count(c.burger_id) no_of_b_delivered from customer_orders c
join burger_names n on n.burger_id=c.burger_id
join runner_orders r on r.order_id=c.order_id
where r.distance !=0
group by n.burger_name;

-- How many vegetarian and meatlovers were ordered by each customer?
select c.customer_id,n.burger_name,count(c.burger_id) burger_ordered from customer_orders c
join burger_names n on n.burger_id=c.burger_id
group by c.customer_id,n.burger_name
order by c.customer_id;

-- what was the maximum no of burgers delivered in singlr order?
select c.order_id, count(burger_id) no_of_burgers from customer_orders c
join runner_orders r on r.order_id=c.order_id
where r.distance !=0
group by c.order_id
order by count(burger_id) desc
limit 1;

-- For each customer , how many delivered burgers had 1 change and how many had no changes?
select customer_id, sum(case when c.exclusions is null and c.extras is null then 1 else 0 end ) as no_change,
sum(case when c.exclusions is not null or  c.extras is not null then 1 else 0 end) as at_least_1_change
from customer_orders c
join runner_orders r on r.order_id=c.order_id
group by customer_id
order by customer_id;

-- what was total volume of burgers ordered for each hour of day?
select  hour(order_time) as hr, count(*) from customer_orders
group by  hour(order_time)
order by  hour(order_time);

## How many runners signed up in same 1 week period?
select week(registration_date),count(runner_id) as cnt_of_signup from burger_runner
group by week(registration_date);

## what was avg distance travelled for each customer?
select c.customer_id,avg(r.distance) as avg_distance from customer_orders c
join runner_orders r on r.order_id=c.order_id
where r.duration!=0
group by c.customer_id
order by c.customer_id;

