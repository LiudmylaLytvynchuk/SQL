-- візьмемо розшифровки до фейсбука
select 
  fc.campaign_name,
  fa.adset_name,
  fabd.ad_date,
  fabd.spend   as facebook_spends
from facebook_ads_basic_daily fabd 
join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
join facebook_adset fa    on fabd.adset_id = fa.adset_id
;

-- дотягнемо дані, щоб порівнювати з середнім за всі записи в таблиці
select 
  fc.campaign_name,
  fa.adset_name,
  fabd.ad_date,
  fabd.spend   as facebook_spends,
  avg(fabd.spend) over()
from facebook_ads_basic_daily fabd 
join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
join facebook_adset fa    on fabd.adset_id = fa.adset_id
;

-- можемо додати до розгорнутої таблички дані з групування в різних розрізах
select 
  fc.campaign_name,
  fa.adset_name,
  fabd.ad_date,
  fabd.spend   as facebook_spends,
  avg(fabd.spend) over() as avg_spends,
  avg(fabd.spend) over(partition by campaign_name) as avg_spends_by_campaign,
  avg(fabd.spend) over(partition by campaign_name,ad_date ) as avg_spends_by_campaign_and_date
from facebook_ads_basic_daily fabd 
join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
join facebook_adset fa    on fabd.adset_id = fa.adset_id
;

-- можемо додати до розгорнутої таблички дані з групування в різних розрізах пріорітезацію
/*
ROW_NUMBER () Присвоює унікальний номер кожному рядку в межах вікна. Номери рядків відповідають порядку вибірки без сортування.
RANK () Призначає ранг кожному рядку, відповідно до вказаного виразу сортування. Рядки з однаковими значеннями отримують однаковий ранг, пропускаючи наступні ранги.
DENSE_RANK () Призначає "щільний" ранг кожному рядку, відповідно до вказаного виразу сортування. Рядки з однаковими значеннями отримують однаковий ранг, не пропускаючи наступні ранги.
 */
select 
  fc.campaign_name,
  fa.adset_name,
  fabd.ad_date,
  fabd.spend   as facebook_spends,
  ROW_NUMBER() over() as rnk_all,
  ROW_NUMBER() over(partition by campaign_name order by fabd.spend desc) as rnk_by_campaign_name,
  ROW_NUMBER() over(partition by campaign_name,ad_date order by fabd.spend desc) as rnk_by_campaign_and_date
from facebook_ads_basic_daily fabd 
join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
join facebook_adset fa    on fabd.adset_id = fa.adset_id
;

-- трьома способами
select 
  fc.campaign_name,
  fa.adset_name, 
  sum(fabd.spend)   as facebook_spends,
  ROW_NUMBER() over(partition by campaign_name order by sum(fabd.spend) desc) as rn_all,
  RANK() over(partition by campaign_name order by sum(fabd.spend) desc)       as rnk_all,
  DENSE_RANK() over(partition by campaign_name order by sum(fabd.spend) desc) as drnk_all
from facebook_ads_basic_daily fabd 
join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
join facebook_adset fa    on fabd.adset_id = fa.adset_id
group by 1,2
;
-------------------------------------------------------------------------------------
-- створимо таблицю на якій будуть співпадаючі значення і різниця в ранжуванні
CREATE TABLE if not exists product_groups_ml (
	group_id serial PRIMARY KEY,
	group_name VARCHAR (255) NOT NULL
);

CREATE TABLE  if not exists  products_ml (
	product_id serial PRIMARY KEY,
	product_name VARCHAR (255) NOT NULL,
	price DECIMAL (11, 2),
	group_id INT NOT NULL,
	FOREIGN KEY (group_id) REFERENCES product_groups_ml (group_id)
);

INSERT INTO product_groups_ml (group_name)
VALUES
	('Smartphone'),
	('Laptop'),
	('Tablet');

INSERT INTO products_ml (product_name, group_id, price)
VALUES
	('Microsoft Lumia', 1, 200),
	('HTC One', 1, 400),
	('Nexus', 1, 500),
	('iPhone', 1, 900),
	('HP Elite', 2, 1200),
	('Lenovo Thinkpad', 2, 700),
	('Sone VAIO', 2, 700),
	('Dell Vostro', 2, 800),
	('iPad', 3, 700),
	('Kindle Fire', 3, 150),
	('Samsung Galaxy Tab', 3, 200);

SELECT 
  AVG(price)
FROM products_ml
;

SELECT 
  group_name,
  AVG(price)
FROM products_ml
INNER JOIN product_groups_ml USING (group_id)
GROUP BY group_name
;

-- те ж саме але не застарілим джойном !!!
SELECT 
  group_name,
  AVG(price)
FROM products_ml as t1
JOIN product_groups_ml as t2 on t1.group_id = t2.group_id
GROUP BY group_name
;

-- в конспекті на цьому місці помилка і має бути order BY а не group by
SELECT 
  product_name,
  price,
  group_name,
  AVG(price) OVER (PARTITION BY group_name)
FROM products_ml
INNER JOIN product_groups_ml USING (group_id)
order BY group_name
;

-- різниця способів ранжування
SELECT 
  product_name,
  group_name,
  price,
  ROW_NUMBER() OVER (PARTITION BY group_name ORDER BY price)   as rn,
  RANK() OVER (PARTITION BY group_name ORDER BY price)         as rnk,
  DENSE_RANK() OVER (PARTITION BY group_name ORDER BY price)   as drnk
FROM products_ml
INNER JOIN product_groups_ml USING (group_id)
;
--------------------------------------------------------------------------------------
-- FIRST_VALUE  ???
SELECT 
  product_name,
  group_name,
  price,
  FIRST_VALUE(price) OVER (PARTITION BY group_name ORDER BY price) AS lowest_price_per_group,
  min(price) over(PARTITION BY group_name ORDER BY price)
FROM products_ml
INNER JOIN product_groups_ml USING (group_id)
;

-- LAST_VALUE   ???
SELECT 
  product_name,
  group_name,
  price,
  LAST_VALUE(price) OVER (PARTITION BY group_name  
			ORDER BY price 
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
						) AS highest_price_per_group,
  max(price) over(PARTITION BY group_name)
FROM products_ml
INNER JOIN product_groups_ml USING (group_id)
;
--------------------------------------------------------------------------------------
-- Приклад з ковзнім середнім 
SELECT 
  fc.campaign_name,
  fa.adset_name,
  fabd.ad_date,
  fabd.spend   as facebook_spends,
  AVG(fabd.spend) OVER () AS avg_spends,
  AVG(fabd.spend) OVER (PARTITION BY campaign_name) AS avg_spends_by_campaign,
  AVG(fabd.spend) OVER (PARTITION BY campaign_name, ad_date) AS avg_spends_by_campaign_and_date,
  -- тут використовуємо ROWS
  AVG(fabd.spend) OVER (PARTITION BY campaign_name ORDER BY ad_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS avg_spends_by_campaign_overall,
  AVG(fabd.spend) OVER (PARTITION BY campaign_name ORDER BY ad_date ROWS BETWEEN 3 PRECEDING AND 0 FOLLOWING) AS moving_avg_spends_by_campaign_3d

FROM facebook_ads_basic_daily fabd 
JOIN facebook_campaign fc ON fc.campaign_id = fabd.campaign_id 
JOIN facebook_adset fa ON fabd.adset_id = fa.adset_id
;


---------------------------------------------------------------------------------------
-- вивести дублі
WITH ranked_orders AS (
  SELECT 
    id,
    info,
    ROW_NUMBER() OVER (PARTITION BY id ORDER BY cast(info as varchar)) AS row_num
  FROM "HR".orders
)
SELECT id, info
FROM ranked_orders
WHERE row_num > 1
;
