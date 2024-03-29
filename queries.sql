--считает общее количество покупателей из таблицы customers
select COUNT(*) as customers_count from customers;

--выводит десятку лучших продавцов по выручке с проданных товаров
select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    COUNT(s.sales_person_id) as operations,
    FLOOR(SUM(p.price * s.quantity)) as income
from employees as e
left join sales as s
    on e.employee_id = s.sales_person_id
left join products as p
    on s.product_id = p.product_id
group by CONCAT(e.first_name, ' ', e.last_name)
order by SUM(p.price * s.quantity) desc
limit 10;

--выводит продавцов, чья средняя выручка за сделку меньше средней выручки
--за сделку по всем продавцам
with sellers as (
    select
        FLOOR(AVG(p.price * s.quantity)) as average_income,
        CONCAT(e.first_name, ' ', e.last_name) as seller
    from products as p
    left join sales as s
        on p.product_id = s.product_id
    left join employees as e
        on e.employee_id = s.sales_person_id
    group by CONCAT(e.first_name, ' ', e.last_name)
)

select
    seller,
    average_income
from sellers
where average_income < (select AVG(average_income) from sellers)
order by average_income;

--выводит информацию о выручке по дням недели
select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    TO_CHAR(s.sale_date, 'day') as day_of_week,
    FLOOR(SUM(p.price * s.quantity)) as income
from employees as e
left join sales as s
    on e.employee_id = s.sales_person_id
left join products as p
    on s.product_id = p.product_id
group by EXTRACT(isodow from s.sale_date), day_of_week, seller
order by EXTRACT(isodow from s.sale_date), seller;

--выводит количество покупателей в возрастных группах
select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    COUNT(age) as age_count
from customers
group by age_category
order by age_category;

--выводит данные по количеству уникальных покупателей и выручке,
--которую они принесли
select
    TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
    COUNT(distinct s.customer_id) as total_customers,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join products as p
    on s.product_id = p.product_id
group by selling_month
order by selling_month;

--выводит данные о покупателях, первая покупка которых была
--в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)
select
    CONCAT(c.first_name, ' ', c.last_name) as customer,
    s2.sale_date,
    CONCAT(e.first_name, ' ', e.last_name) as seller
from (
    select
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        p.price,
        ROW_NUMBER() over (partition by s.customer_id order by s.sale_date)
        as rn
    from sales as s
    left join products as p
        on s.product_id = p.product_id
) as s2
left join customers as c
    on s2.customer_id = c.customer_id
left join employees as e
    on s2.sales_person_id = e.employee_id
where
    s2.rn = 1
    and s2.price = 0
order by s2.customer_id;
