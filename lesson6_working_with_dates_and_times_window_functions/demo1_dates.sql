-- Робота з датами та часовими даними в SQL
SELECT CURRENT_DATE
;

SELECT CURRENT_TIMESTAMP
;

SELECT CURRENT_TIME
;

SELECT 
  CAST('1997-05-31' AS date) AS converted_date1,
  '1997-05-31'::date AS converted_date2,
  date('1997-05-31') AS converted_date3
;
  
select 
--'1997-05-31' as b_date,
  '1997-05-31'::date as b_date,
  age(CURRENT_DATE, '1997-05-31'::date), --26 years 10 mons 1 day
  age('1997-05-31'::date) --показує різницю між поточною датою (або датою, переданою як аргумент) і вказаною датою.
;

select  age('2024-04-02'::DATE , '2024-01-01'::DATE)
; --3 mons 1 day

---- є можливість отримати різницю дат в днях
select '2024-04-02'::DATE  -  '2024-01-01'::DATE
;--92

-- але навпаки тільки інтервал
select date( '2024-01-01') + interval '92 day'
;

--Функція date_add
select
  hire_date,
  hire_date + INTERVAL '1 year' AS one_year_ago,
  hire_date + INTERVAL '2 days' AS two_days_ago
FROM  "HR".employees e
;

---------------------------------------------------

--DATE_PART
SELECT 
  DATE_PART ('year',  '2025-03-03'::date),
  DATE_PART ('month',  '2025-10-03'::date),
  DATE_PART ('day',  '2025-10-03'::date)
;	

-- те ж саме через extract
SELECT 
  extract (year from '2025-03-03'::date),
  extract (month from '2025-03-03'::date),
  extract (day from '2025-03-03'::date)
;

-- Функція EXTRACT
SELECT 
  hire_date,
  EXTRACT(year FROM hire_date) AS hire_year,
  EXTRACT(month FROM hire_date) AS hire_month
FROM  "HR".employees e
;
---------------------------------------------------
-- обрізання дат (корисно для когортного аналізу)
SELECT 
  CURRENT_TIMESTAMP,
  date_trunc('year', CURRENT_TIMESTAMP)::date   AS  start_of_year,
  date_trunc('month', CURRENT_TIMESTAMP)::date  AS start_of_month,
  date_trunc('hour', CURRENT_TIMESTAMP)         AS start_of_hour
;

select 
  '2024-03-30' as rep_date ,
  date_trunc( 'year' ,  '2024-03-30'::date ) ,
  date_trunc( 'month' , '2024-03-30'::date ),
  date_trunc( 'hour', '2024-03-30'::date ),
  date_trunc( 'week', '2024-03-30'::date )
;

SELECT 
  e.hire_date                             AS hire_date,
  date_trunc('year', e.hire_date)::date   AS hire_year,
  date_trunc('month', e.hire_date)::date  AS hire_month,
  date_trunc('day', e.hire_date)::date    AS hire_day 
FROM "HR".employees e
;

---------------------------------------------------

-- Функція date_diff
SELECT 
  hire_date,
  age('2023-01-01', hire_date) , -- стаж в компанії на початок 2023
  date_part('years', age('2023-01-01', hire_date)) as diff_years,
  floor(('2023-01-01'::date - hire_date)/ 365.0)   as diff_years
FROM  "HR".employees e
;

--SELECT date_diff('yy', '1990-01-01'::date, '2024-04-01'::date) AS days_difference;

---------------------------------------------------

--Конвертація в рядок (string)
SELECT 
  hire_date,
  TO_CHAR(hire_date, 'YYYY-MM-DD') AS hire_date_str,
  TO_CHAR(hire_date, 'YYYY-MM')    AS reported_period,
  TO_CHAR(hire_date, 'DD/MM/YY')   AS hire_date_slashed
FROM  "HR".employees e
;
