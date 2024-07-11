ALTER TABLE olist_orders_dataset
MODIFY COLUMN order_purchase_timestamp TIMESTAMP;

alter table olist_orders_dataset
modify column order_approved_at timestamp;

 select order_approved_at
 from olist_orders_dataset limit 5;
 
select order_purchase_timestamp
 from olist_orders_dataset limit 5;
 
 

ALTER TABLE olist_orders_dataset ADD COLUMN order_approved_at_backup VARCHAR(255);
UPDATE olist_orders_dataset SET order_approved_at_backup = order_approved_at;

-- Check for invalid dates
SELECT order_approved_at_backup
FROM olist_orders_dataset
WHERE order_approved_at_backup = '' OR STR_TO_DATE(order_approved_at_backup, '%Y-%m-%d %H:%i:%s') IS NULL
LIMIT 10;

ALTER TABLE olist_orders_dataset ADD COLUMN temp_order_approved_at TIMESTAMP;

UPDATE olist_orders_dataset
SET temp_order_approved_at = STR_TO_DATE(order_approved_at_backup, '%Y-%m-%d %H:%i:%s')
WHERE order_approved_at_backup <> '' AND STR_TO_DATE(order_approved_at_backup, '%Y-%m-%d %H:%i:%s') IS NOT NULL;

UPDATE olist_orders_dataset
SET order_approved_at = temp_order_approved_at
WHERE temp_order_approved_at IS NOT NULL;

ALTER TABLE olist_orders_dataset DROP COLUMN temp_order_approved_at;

alter table olist_order_items_dataset
modify column shipping_limit_date timestamp;

alter table olist_customers_dataset
modify column customer_zip_code_prefix varchar(50);

alter table  olist_customers_dataset rename to olist_customers;

alter table  olist_order_payments_dataset rename to olist_payment;

alter table  olist_products_dataset rename to olist_products;

alter table olist_sellers_dataset rename to olist_sells;
alter table olist_sells 
modify column seller_zip_code_prefix varchar(50);

alter table olist_geolocation_dataset rename to olist_geolocation;

alter table olist_geolocation
modify column geolocation_zip_code_prefix varchar(50);

alter table olist_order_reviews_dataset rename to olist_reviews;
 
 alter table olist_order_items_dataset rename to olist_items;

select order_approved_at_backup
from olist_orders_dataset;

-- Example: Update to correct format if necessary
-- OLIST ORDERS TABLE
-- ORRDER_PURCHASE_DATE_TIME to time stamp 
UPDATE olist_orders_dataset
SET order_approved_at_backup = DATE_FORMAT(STR_TO_DATE(order_approved_at_backup, '%d/%m/%Y %H:%i:%s'), '%Y-%m-%d %H:%i:%s')
WHERE STR_TO_DATE(order_approved_at_backup, '%d/%m/%Y %H:%i:%s') IS NOT NULL;

SELECT order_approved_at_backup
FROM olist_orders_dataset
LIMIT 10;

SELECT order_approved_at_backup
FROM olist_orders_dataset
WHERE STR_TO_DATE(order_approved_at_backup, '%Y-%m-%d %H:%i:%s') IS NULL
LIMIT 10;

UPDATE olist_orders_dataset
SET order_approved_at_backup = NULL
WHERE order_approved_at_backup = '';

SELECT order_approved_at_backup
FROM olist_orders_dataset
WHERE order_approved_at_backup IS NOT NULL AND order_approved_at_backup <> ''
AND STR_TO_DATE(order_approved_at_backup, '%Y-%m-%d %H:%i:%s') IS NULL
LIMIT 10;


UPDATE olist_orders_dataset
SET order_approved_at_backup = STR_TO_DATE(order_approved_at_backup, '%d/%m/%Y %H:%i:%s')
WHERE STR_TO_DATE(order_approved_at_backup, '%d/%m/%Y %H:%i:%s') IS NOT NULL;

alter table olist_orders_dataset drop column temp_order_approved_at;
ALTER TABLE olist_orders_dataset ADD COLUMN temp_order_approved_at TIMESTAMP;

UPDATE olist_orders_dataset
SET temp_order_approved_at = STR_TO_DATE(order_approved_at_backup, '%Y-%m-%d %H:%i:%s')
WHERE order_approved_at_backup IS NOT NULL AND order_approved_at_backup <> ''
AND STR_TO_DATE(order_approved_at_backup, '%Y-%m-%d %H:%i:%s') IS NOT NULL;

select temp_order_approved_at
from olist_orders_dataset
limit 10;


ALTER TABLE olist_orders_dataset DROP COLUMN order_approved_at;

alter table olist_orders_dataset
rename column temp_order_approved_at to order_approved_at;

--  order_delivered_carrier_date to time stamp
alter table olist_orders_dataset
modify column order_delivered_carrier_date timestamp;

UPDATE olist_orders_dataset
SET order_delivered_carrier_date = NULL
WHERE order_delivered_carrier_date = '';

ALTER TABLE olist_orders_dataset
MODIFY COLUMN order_delivered_carrier_date TIMESTAMP;

-- order_delivered_customer_date to timestamp
alter table olist_orders_dataset
modify column order_delivered_customer_date timestamp;

UPDATE olist_orders_dataset
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date = '';

alter table olist_orders_dataset
modify column order_delivered_customer_date timestamp;

-- order_estimated_delivery_date to timestamp
alter table olist_orders_dataset
modify column order_estimated_delivery_date timestamp;

alter table olist_orders_dataset rename to olist_order;

alter table product_category_name_translation rename to product_category_name;

-- updated the olist_products
alter table olist_products 
add column product_category_name_english varchar(255);  

update olist_products op
join product_category_name pcnt
 on op.product_category_name=pcnt.ï»¿product_category_name
set op.product_category_name_english=pcnt.product_category_name_english;

select *
from olist_products op
where product_category_name='';

update olist_products
set product_category_name_english='n/a'
where product_category_name_english is null;

select product_category_name,product_category_name_english
from olist_products op
where product_category_name_english='n/a';

select product_category_name,product_category_name_english
from olist_products op
where product_category_name='portateis_cozinha_e_preparadores_de_alimentos';

update olist_products
set product_category_name_english='portable kitchen and food preparers'
where product_category_name='portateis_cozinha_e_preparadores_de_alimentos';

update olist_products
set product_category_name_english='pc_gamer'
where product_category_name='pc_gamer';

--  *****total revenue generated by Olist, and how has it changed over time?****

 -- first time frame needed 
 select max(order_purchase_timestamp) as ended_date,
 min(order_purchase_timestamp) as started_date
 from olist_order oo;
 
 select order_status,
 count(*) as invalid_orders
 from olist_order oo
 where order_delivered_customer_date is null
 group by order_status order by invalid_orders desc;
 
 -- total revenue 
-- omitting the rows which are ordered status as cancelled
-- and alsoe delivery date is null
select round(sum(opa.payment_value),0) as total_revenue
from olist_order oo
join olist_payment opa on oo.order_id=opa.order_id
where oo.order_status <> 'canceled'
and oo.order_delivered_customer_date is not null;

-- for sales overtime first with year, then quarters,then month
#yearly sales
select
year(oo.order_purchase_timestamp) as the_year,
round(sum(payment_value),0) as revenue
from olist_order oo
join olist_payment opa on oo.order_id=opa.order_id
where oo.order_status <> 'canceled'
and oo.order_delivered_customer_date is not null
group by the_year
order by the_year;

#quareterly sales
select
year(oo.order_purchase_timestamp) as the_year,
quarter(oo.order_purchase_timestamp) as the_quarter,
round(sum(payment_value),0) as revenue
from olist_order oo
join olist_payment opa on oo.order_id=opa.order_id
where oo.order_status <> 'canceled'
and oo.order_delivered_customer_date is not null
group by the_year,the_quarter
order by the_year,the_quarter;

#monthly sales
select
year(oo.order_purchase_timestamp) as the_year,
quarter(oo.order_purchase_timestamp) as the_quarter,
month(oo.order_purchase_timestamp) as the_month,
round(sum(payment_value),0) as revenue
from olist_order oo
join olist_payment opa on oo.order_id=opa.order_id
where oo.order_status <> 'canceled'
and oo.order_delivered_customer_date is not null
group by the_year,the_quarter,the_month
order by revenue desc;

-- ******How many orders were placed on Olist, and how does this vary by month or season****
select count(*) as num_order
from olist_order oo
where oo.order_status <> 'canceled'
and oo.order_delivered_customer_date is not null;

select 
year(order_purchase_timestamp) as the_year,
quarter(order_purchase_timestamp) as the_quarter,
count(*) as num_order
from olist_order oo
where oo.order_status <> 'canceled'
and oo.order_delivered_customer_date is not null
group by the_year,the_quarter
order by the_year,the_quarter;

select 
year(order_purchase_timestamp) as the_year,
month(order_purchase_timestamp) as the_month,
count(*) as num_order
from olist_order oo
where oo.order_status <> 'canceled'
and oo.order_delivered_customer_date is not null
group by the_year,the_month
order by the_year,the_month;

-- **What are the most popular product categories on Olist, and how do their sales volumes compare to each other
-- **What are the top-selling products on Olist, and how have their sales trends changed over time?

select 
count(oi.product_id) as total_product_id
from olist_items oi
join olist_order oo on oi.order_id=oo.order_id
where oo.order_status <> 'canceled'
and oo.order_delivered_customer_date is not null;

SELECT
op.product_category_name_english AS product_name,
COUNT(oo.order_id) AS num_orders,
ROUND (100.0 * (COUNT(oo.order_id) / total_orders.total_num_orders), 2) AS percentage
FROM
olist_order oo
JOIN
olist_items oi ON oo.order_id = oi.order_id
JOIN
(SELECT
product_id,
product_category_name_english
FROM
olist_products op) AS op ON oi.product_id = op.product_id
CROSS JOIN
(
SELECT COUNT(oo.order_id) AS total_num_orders
FROM olist_order oo
JOIN
olist_items oi ON oo.order_id = oi.order_id
JOIN
olist_products op ON oi.product_id = op.product_id
WHERE
oo.order_status <> 'canceled'
AND oo.order_delivered_customer_date IS NOT NULL
) AS total_orders
WHERE
oo.order_status <> 'canceled'
AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
product_name, total_num_orders
ORDER BY
percentage DESC
limit 1000;


WITH ranked_orders AS (
  SELECT 
    YEAR(oo.order_purchase_timestamp) AS the_year,
    op.product_category_name AS product_name,
    COUNT(oo.order_id) AS num_orders
  FROM 
    olist_order oo
  INNER JOIN 
    olist_items oi ON oi.order_id = oo.order_id
  INNER JOIN 
    olist_products op ON op.product_id = oi.product_id
  WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
  GROUP BY 
    product_name, the_year
)
SELECT 
  *, 
  RANK() OVER(ORDER BY num_orders DESC) AS rnk
FROM 
  ranked_orders
ORDER BY 
  rnk;
  
-- average order value (AOV) on Olist, and how does this vary by product category or payment method 
-- aov=total revenue/order
-- cpo=total cost of product /total orders
select round(sum(opa.payment_value)/count(oo.order_id),0) as aov,
round(sum(oi.cost)/count(oo.order_id),0) as cpo,
round((sum(opa.payment_value)/count(oo.order_id))-(sum(oi.cost)/count(oo.order_id)),0) as profit_per_order
from olist_order oo
join(select oo.order_id as order_id,
		sum(payment_value) as payment_value
        from olist_payment opa 
        join olist_order oo on oo.order_id=opa.order_id
         WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
    group by order_id) as opa  on oo.order_id=opa.order_id
join(select oo.order_id,
sum(freight_value+price) as cost 
from olist_items oi
join olist_order oo on oo.order_id=oi.order_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
    group by order_id) as oi on oo.order_id=oi.order_id;
    
select 
oo.order_id as order_id,
round(sum(opa.payment_value)/count(oo.order_id),0) as aov,
round(sum(oi.cost)/count(oo.order_id),0) as cpo,
round((sum(opa.payment_value)/count(oo.order_id))-(sum(oi.cost)/count(oo.order_id)),0) as profit_per_order
from olist_order oo
join(select oo.order_id as order_id,
		sum(payment_value) as payment_value
        from olist_payment opa 
        join olist_order oo on oo.order_id=opa.order_id
         WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
    group by order_id) as opa  on oo.order_id=opa.order_id
join(select oo.order_id,
sum(freight_value+price) as cost 
from olist_items oi
join olist_order oo on oo.order_id=oi.order_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
    group by order_id) as oi on oo.order_id=oi.order_id
group by order_id
having profit_per_order>0
order by profit_per_order desc;

select op.product_category_name_english as product_name,
count(profit.order_id) as profit_count
from olist_items oi 
join olist_products op on op.product_id=oi.product_id
join(
select 
oo.order_id as order_id,
round(sum(opa.payment_value)/count(oo.order_id),0) as aov,
round(sum(oi.cost)/count(oo.order_id),0) as cpo,
round((sum(opa.payment_value)/count(oo.order_id))-(sum(oi.cost)/count(oo.order_id)),0) as profit_per_order
from olist_order oo
join(select oo.order_id as order_id,
		sum(payment_value) as payment_value
        from olist_payment opa 
        join olist_order oo on oo.order_id=opa.order_id
         WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
    group by order_id) as opa  on oo.order_id=opa.order_id
join(select oo.order_id,
sum(freight_value+price) as cost 
from olist_items oi
join olist_order oo on oo.order_id=oi.order_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
    group by order_id) as oi on oo.order_id=oi.order_id
group by order_id
having profit_per_order>0
order by profit_per_order desc
) as profit on profit.order_id=oi.order_id
group by product_name
order by profit_count desc;

-- For AOV by payment method
select payment_type ,
round(sum(opa.payment_value)/count(distinct oo.order_id),0) as aov
from olist_order oo
join olist_payment opa on oo.order_id=opa.order_id
 WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
group by payment_type
order by aov desc;

-- how many sellers are active in olist 


-- considering active seller is a seller who added new listing in 30 days
select count(distinct seller_id) 
from olist_sells os;

-- some of the order id contains multiple seller id
select si.seller_id as seller_id,
oi.order_id ,
subquery.order_item_count
from olist_items oi
join (
    select order_id, count(oi.order_item_id) as order_item_count
    from olist_items oi
    join olist_sells os on oi.seller_id = os.seller_id
    group by order_id
    having count(distinct os.seller_id) > 1
) As subquery on oi.order_id = subquery.order_id
join olist_sells si on si.seller_id = oi.seller_id
group by oi.order_id, si.seller_id, subquery.order_item_count
order by si.seller_id, oi.order_id;

select 
oi.seller_id,
oo.order_id,
oo.order_purchase_timestamp,
LAG(oo.order_purchase_timestamp,1) 
over (partition by oi.seller_id order by oo.order_purchase_timestamp) as previous_order_date
from olist_order oo
join(
	select si.seller_id as seller_id,
	oi.order_id ,
	subquery.order_item_count
	from olist_items oi
	join (
		select order_id, count(oi.order_item_id) as order_item_count
		from olist_items oi
		join olist_sells os on oi.seller_id = os.seller_id
		group by order_id
		having count(distinct os.seller_id) > 1
	) As subquery on oi.order_id = subquery.order_id
	join olist_sells si on si.seller_id = oi.seller_id
	group by oi.order_id, si.seller_id, subquery.order_item_count
	order by si.seller_id, oi.order_id
) as oi on oi.order_id=oo.order_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
order by oi.seller_id,oo.order_purchase_timestamp desc;


select count(seller_id) as 	num_active_sellers
from(
	select seller_id,
datediff(max(order_purchase_timestamp),max(previous_order_date)) as days_between_orders
from(
	select 
oi.seller_id,
oo.order_id,
oo.order_purchase_timestamp,
LAG(oo.order_purchase_timestamp,1) 
over (partition by oi.seller_id order by oo.order_purchase_timestamp) as previous_order_date
from olist_order oo
join(
	select si.seller_id as seller_id,
	oi.order_id ,
	subquery.order_item_count
	from olist_items oi
	join (
		select order_id, count(oi.order_item_id) as order_item_count
		from olist_items oi
		join olist_sells os on oi.seller_id = os.seller_id
		group by order_id
		having count(distinct os.seller_id) > 1
	) As subquery on oi.order_id = subquery.order_id
	join olist_sells si on si.seller_id = oi.seller_id
	group by oi.order_id, si.seller_id, subquery.order_item_count
	order by si.seller_id, oi.order_id
) as oi on oi.order_id=oo.order_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
order by oi.seller_id,oo.order_purchase_timestamp desc
)as second_last_order_date
group by seller_id
having datediff(max(order_purchase_timestamp),max(previous_order_date)) <=30
and datediff(max(order_purchase_timestamp),max(previous_order_date)) is not null
order by datediff(max(order_purchase_timestamp),max(previous_order_date)) 
) as active_seller;


-- distribution of seller ratings on olist and how does it impact sales performance
select review_score,
count(*) as num_review,
round((100*count(*)/tot_re.total_re),2) as percentage
from olist_reviews ore
cross join(select count(*) as total_re
from olist_items oi ) as tot_re
group by review_score,total_re
order by review_score desc;

create or replace view review as 
select oo.order_id as order_id,
round(avg(review_score ),0) as review_score
from olist_order oo 
join olist_reviews ore on
oo.order_id=ore.order_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
group by oo.order_id;

create  or replace view payment as
select 
oo.order_id as order_id,
sum(op.payment_value) as payment_value
from olist_order oo
join olist_payment op on
oo.order_id=op.order_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
group by oo.order_id;

select r.review_score,
coalesce(round(sum(p.payment_value),0),0) as total_payment_value,
round(100*(coalesce(round(sum(p.payment_value),0),0)/all_sum.all_pay),2) as percentage
from review r
join payment p on r.order_id=p.order_id
cross join(
select coalesce(round(sum(p.payment_value),0),0) as all_pay
from payment p)as all_sum
group by r.review_score ,all_pay
order by r.review_score desc;

-- How many customers have made repeat purchases on Olist
-- what percentage of total sales do they account for?
select count(distinct customer_unique_id) as customers
from olist_customers oc;

select count(*) as num_return_customers
from(
select 
oc.customer_unique_id as re_customer,
count(distinct  oo.order_id) as num_re_customers
from olist_order oo
join olist_customers oc on oo.customer_id=oc.customer_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
group by re_customer
having count(oo.order_id)>1
order by num_re_customers desc) as return_customers;

create or replace view revenue_customer as
SELECT 
    ROUND(SUM(total_rev), 0) AS return_rev
FROM (
    SELECT 
        oc.customer_unique_id AS re_customer,
        COUNT(DISTINCT oo.order_id) AS num_re_customer,
        SUM(opa.payment_value) AS total_rev
    FROM olist_order oo
    JOIN olist_customers oc ON oo.customer_id = oc.customer_id
    JOIN olist_payment opa ON oo.order_id = opa.order_id
    WHERE oc.customer_unique_id IN (
        SELECT 
            oc.customer_unique_id
        FROM olist_order oo
        JOIN olist_customers oc ON oo.customer_id = oc.customer_id
        WHERE oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL
        GROUP BY oc.customer_unique_id
        HAVING COUNT(oo.order_id) > 1
    )
    AND oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
    GROUP BY oc.customer_unique_id
) AS sub;

select
round(100*return_rev/total_revenue,2) as percentag_of_return_customer
from revenue_customer,(
select round(sum(opa.payment_value),0) as total_revenue
from olist_order oo
join olist_payment opa on oo.order_id=opa.order_id
 WHERE oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL) as toatl_revenue;
        
## ---------- NPS(Net Promoter score) ------------- ##
/* customer experience metric
 */ 
 SELECT
   SUM(CASE WHEN review_score IN (5,4) THEN 1 ELSE 0 END) AS positive_count,
   SUM(CASE WHEN review_score =1 THEN 1 ELSE 0 END) AS negative_count,
   COUNT(*) AS total_count,
   100.0*(SUM(CASE WHEN review_score IN (5,4) THEN 1 ELSE 0 END) -
	 SUM(CASE WHEN review_score =1 THEN 1 ELSE 0 END))/COUNT(*)  AS NPS
FROM 
olist_reviews or2;

### 9. What is the average order cancellation rate on Olist, and how does this impact seller performance?-------------------------------------

# canceled rate: 0.63%
	
SELECT
   order_status,
   COUNT(order_id) AS num_order,
   ROUND(100 * COUNT(order_id) / SUM(COUNT(order_id)) OVER (), 2) AS percentage
FROM
   olist_order oo
GROUP BY
   order_status;
   
### 10. What are the top-selling products on Olist, and how have their sales trends changed over time?----------------------------------------

## top 3 selling products (same query as Q3)
SELECT 
    op.product_category_name_english AS product_name,
    COUNT(oo.order_id) AS num_order
FROM
    olist_order oo
JOIN 
    olist_items oi ON oo.order_id = oi.order_id 
JOIN
    (SELECT
        product_id,
        product_category_name_english
     FROM 
        olist_products op) AS op ON oi.product_id = op.product_id
WHERE
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
    product_name
ORDER BY 
    num_order DESC; -- 110,189 rows
   
## how have their sales trends changed over time? 

SELECT 
    YEAR(oo.order_purchase_timestamp) AS the_year,
    op.product_category_name_english AS product_name,
    COUNT(oo.order_id) AS num_order,
    RANK() OVER(ORDER BY COUNT(oo.order_id) DESC) AS rnk
FROM
    olist_order oo
JOIN 
    olist_items oi ON oo.order_id = oi.order_id 
JOIN
    (SELECT
        product_id,
        product_category_name_english
     FROM 
        olist_products op) AS op ON oi.product_id = op.product_id
WHERE
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
    product_name, the_year
ORDER BY 
    the_year; -- 110,189 rows












































