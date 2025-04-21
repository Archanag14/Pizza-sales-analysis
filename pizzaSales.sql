Basic:
--1)Retrieve the total number of orders placed
select count(*) as total_orders 
from orders

--2)Calculate the total revenue generated from pizza sales.
select round(sum(quantity * price)) as total_revenue 
from order_details join pizza 
on pizza.pizza_id = order_details.pizza_id

--3)Identify the highest-priced pizza.
select name, price from pizza 
join pizza_types 
on pizza.pizza_type_id = pizza_types.pizza_type_id
order by price desc
limit 1

--4)Identify the most common pizza size ordered.
select pizza.size,count(order_details_id) as total_orders 
from order_details
join pizza on order_details.pizza_id = pizza.pizza_id
group by 1
order by 2 desc
limit 1

--5)List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,sum(quantity) from order_details
join pizza on order_details.pizza_id = pizza.pizza_id
join pizza_types on pizza.pizza_type_id = pizza_types.pizza_type_id
group by 1
order by 2 desc
limit 5

--Intermediate:
--6)Join the necessary tables to find the total quantity of each pizza category ordered.
select category, sum(quantity) as quantity 
from pizza_types join pizza
on pizza_types.pizza_type_id = pizza.pizza_type_id
join order_details
on order_details.pizza_id = pizza.pizza_id
group by category
order by quantity desc

--7)Determine the distribution of orders by hours of the day
Select extract(HOUR FROM order_time) as hours,
count(orders.order_id) as order_count from orders
join order_details
on orders.order_id = order_details.order_id
group by hours
order by 1 asc

--8)join relevant tables to find the categorywise distribution of pizzas
select category, count(name) as pizza_count
from pizza_types
group by category
order by 2 desc

--9)Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(total_quantity)) from
(select order_date, count(order_details.quantity) as total_quantity
from order_details join orders 
on orders.order_id = order_details.order_id
group by order_date
order by 1 asc) as order_quantity

--10)determine the top 3 most ordered pizza types based on revenue
select name, sum(quantity * price) as revenue 
from order_details
join pizza on pizza.pizza_id = order_details.pizza_id
join pizza_types on pizza.pizza_type_id = pizza_types.pizza_type_id
group by name
order by 2 desc
limit 3

--Advanced:
--11)Calculate the percentage contribution of each pizza type to total revenue
select category, 
      round(sum(quantity * price)/(select sum(quantity * price) 
      from order_details
      join pizza 
      on pizza.pizza_id = order_details.pizza_id) * 100) as revenue_percentage
from order_details
join pizza on pizza.pizza_id = order_details.pizza_id
join pizza_types on pizza.pizza_type_id = pizza_types.pizza_type_id
group by 1
order by 2 desc

--12)Analyze the cumulative revenue generated over time.
with revenuebydate as(
   select order_date, sum(quantity * price) as revenue 
   from order_details join orders
   on orders.order_id = order_details.order_id
   join pizza on pizza.pizza_id = order_details.pizza_id
   group by 1
   order by 1 asc)
select order_date, 
   sum(revenue) over(order by order_date) as cum_rev 
from revenuebydate

--13)Determine the top 3 most ordered pizza types based on revenue for each pizza category
with category_rank as(
   with category_revenue as(
      select name, category, sum(quantity * price) as revenue 
	  from order_details
      join pizza on pizza.pizza_id = order_details.pizza_id
      join pizza_types on pizza.pizza_type_id = pizza_types.pizza_type_id
      group by name, category )
select category, name, revenue, 
      rank() over( partition by category order by revenue desc) 
from category_revenue )
select category, name, revenue from category_rank
where rank<=3
