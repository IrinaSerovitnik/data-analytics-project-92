--выводит продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
with sellers as (
select
CONCAT(e.first_name, ' ', e.last_name) as seller,
FLOOR(AVG(p.price*s.quantity)) as average_income
from sales as s
left join products as p
on s.product_id = p.product_id
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
