create database project;
use project;

create table orders( order_id int not null,order_date date not null,
order_time time not null, primary key(order_id));
create table order_details( order_details_id int not null,
order_id int not null,pizza_id text not null,
quantity int not null, primary key(order_details_id));

-- SQL PIZZA SALES PROJECT

-- Basic:

-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    order_details o
        JOIN
    pizzas p ON p.pizza_id = o.pizza_id; 

-- Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.

SELECT DISTINCT
    p.size, COUNT(o.order_details_id) AS times_ordered
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY size
ORDER BY COUNT(o.order_details_id) DESC
LIMIT 1;



-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(o.quantity) AS quantities
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY SUM(o.quantity) DESC LIMIT 5;

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category, COUNT(quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY COUNT(quantity) DESC;

-- Determine the distribution of orders by hour of the day.

select hour(order_time) as hour_of_the_day,count(order_id) as total_orders from orders
group by hour(order_time)
order by hour(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS categories
FROM
    pizza_types
GROUP BY category;




-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS per_day_quantity
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.order_date) AS order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, ROUND(SUM(o.quantity * p.price), 0) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC LIMIT 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category, 
    CONCAT(ROUND(SUM(o.quantity * p.price) / 
        (SELECT SUM(o.quantity * p.price) 
         FROM order_details o
         JOIN pizzas p ON p.pizza_id = o.pizza_id) * 100, 2), '%') AS revenue
FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details o ON o.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;
 


-- Analyze the cumulative revenue generated over time.

select order_date,round(sum(revenue) over(order by order_date),2) as cum_revenue from
(select orders.order_date,sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders on orders.order_id=order_details.order_id
group by orders.order_date) as sales;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue,rn,category from 

(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn
from(
select pizza_types.category,pizza_types.name,
sum(order_details.quantity *pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn<=3;