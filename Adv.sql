-- Rank ,dense_rank and percent_rank demo

use market_star_schema;

select ord_id,discount,customer_name,
rank() over(order by discount desc) as disc_rank,
dense_rank() over( order by discount desc) as disc_dense_rank
from market_fact_full as m
inner join cust_dimen as c
on m.cust_id=c.cust_id
where customer_name='Rick wilson';

-- Numbers of orders each customer has placed adn need rank based on that

select customer_name,count(distinct ord_id) as order_count,
rank() over(order by count(distinct ord_id) desc) as order_rank,
dense_rank()over (order by count(distinct ord_id) desc) as order_dense_rank,
row_number()over (order by count(distinct ord_id) desc) as order_row_number
from market_fact_full as m
inner join cust_dimen as c
on m.cust_id=c.cust_id
group by customer_name;     # we get same number for order_count but with diff cust_name and unique order_row_number




-- Partitioning example

with shipping_summary as
(select ship_mode,month(ship_date) as shipping_month,
count(*) as shipments
from shipping_dimen group by ship_mode,month(ship_date)
)
select *,
rank() over(partition by ship_mode order by shipments desc) as shipping_rank,
dense_rank() over(partition by ship_mode order by shipments desc) as dense_shipping_rank,
row_number() over(partition by ship_mode order by shipments desc) as row_shipping_rank
from shipping_summary;




-- Window fns

select customer_name,ord_id,discount,
rank() over w as order_rank,
dense_rank()over w as order_dense_rank,
row_number()over w as order_row_number
from market_fact_full as m
inner join cust_dimen as c
on m.cust_id=c.cust_id
where customer_name ='Rick wilson'
window w as (order by discount desc);



select customer_name,ord_id,discount,
rank() over w as order_rank,
dense_rank()over w as order_dense_rank,
row_number()over w as order_row_number
from market_fact_full as m
inner join cust_dimen as c
on m.cust_id=c.cust_id
window w as (partition by customer_name order by discount desc);





-- Frames

with daily_shipping_summary as
(select ship_date,sum(shipping_cost) as daily_total
from market_fact_full as m inner join shipping_dimen as s
on m.ship_id=s.ship_id group by ship_date)
select*,
sum(daily_total) over w1 as running_total,
avg(daily_total) over w2 as moving_avg      # w1 & w2 becz each window clause within the same query must have unique name
from daily_shipping_summary
window w1 as (order by ship_date rows unbounded preceding),   # unbounded preceding means 1 row from the begining
w2 as (order by ship_date rows 6 preceding);



-- lead and lag. (compute between current and next order)

with cust_order as
(select c.customer_name,m.ord_id,o.order_date
from market_fact_full as m
left join orders_dimen as o
on m.ord_id=o.ord_id
left join
cust_dimen as c
on m.cust_id=c.cust_id
where Customer_Name='rick wilson'
group by c.customer_name,m.ord_id,o.order_date
),
next_date_summary as
(select *,
lead(order_date, 1) over (order by order_date,ord_id) as next_order_date
from cust_order
order by customer_name,order_date,ord_id)
select *,datediff(next_order_date,order_date) as days_diff
from next_date_summary;



-- (compute between current and previous orders) use lag just replace prev_date with order _date




-- case when example

/* profit < -500 - huge loss
   profit -500 - 0 - bearable loss
   profit 0-500 > decent profit
   profit > 500 > great profit
   
*/

select market_fact_id,profit,
  case
     when  profit < -500 then 'huge loss'
     when profit between -500 and 0 then 'bearable loss'
     when profit between 0 and 500 then 'decent profit'
	 else 'Great profit'
	end as profit_type
from market_fact_full;



-- classify customers on the following criteria
-- 1. top 10% customers as gold
-- 2.next 40% customers as silver
-- 3. next 50% customers as bronze
  
  with cust_summary as 
  (select m.cust_id,c.customer_name,round(sum(m.sales)) as total_sales,
  percent_rank() over (order by round(sum(m.sales)) desc) as perc_rank
  from market_fact_full as m left join cust_dimen as c
  on m.cust_id=c.cust_id
  group by cust_id)
  select *,
     case
       when perc_rank <0.1 then 'gold'
       when perc_rank <0.5 then 'silver'
       else bronze
     end as customer_category
  from cust_summary;
  
  
  -- Creating a fns UDF
  --fns has input parameter does not have output parameter
  -- cannot call stored procedure
  
DELIMITER $$
  
  create function profitType(profit int)
  returns varchar(30) deterministic
  
  begin
  
  declare message varchar(30);
  if profit <-500 then
    set message ='huge loss';
  elseif profit between -500 and 0 then
    set message ='bearable loss';
  elseif profit between 0 and 500 then
     set message ='decent loss';
  else 
     set message ='great profit';
  end if;
  
  return message;
  
  end;
  
 $$
 DELIMITER ;
  
select profitType(10) as function_output;
  
  
  
  
  
  
-- Stored Procedure 

USE market_star_schema;

DELIMITER $$

 create procedure get_sales_customers(sales_input INT)
 begin
  select distinct cust_id, round(sales) as sales_amount
  from market_fact_full where round(sales)>sales_input
  order by sales;
end $$

DELIMITER ;

call get_sales_customers(300);




-- Index demo

create table market_fact_temp as      # copying market_fact_full data into market_fact_temp
select *from market_fact_full;
  
create index filter_index on market_fact_temp(cust_id,ship_id,prod_id);   # index is created 

alter table market_fact_temp drop index filter_index;    # index dropped






