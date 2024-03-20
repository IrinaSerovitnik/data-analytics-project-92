--считает общее количество покупателей из таблицы customers
select COUNT(*) as customers_count from customers;

--выводит десятку лучших продавцов по выручке с проданных товаров
select
CONCAT(e.first_name, ' ', e.last_name) as seller,
COUNT(s.sales_person_id) as operations,
FLOOR(SUM(p.price*s.quantity)) as income
from sales as s
left join products as p
on s.product_id = p.product_id
left join employees as e
on e.employee_id = s.sales_person_id
group by CONCAT(e.first_name, ' ', e.last_name)
order by SUM(p.price*s.quantity) desc
limit 10;