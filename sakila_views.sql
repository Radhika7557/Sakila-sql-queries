CREATE VIEW employee AS
SELECT staff_id employee_id
      ,first_name + ' ' + last_name employee_name
	  ,store_id
	  ,address_id
	  ,active
FROM staff$;


CREATE VIEW movie AS
WITH t1 AS (
SELECT f.film_id
      ,first_name + ' ' + last_name actor
FROM film_actor$ f JOIN actor$ a
ON f.actor_id = a.actor_id
)
, t2 AS (
SELECT film_id
      ,STUFF((SELECT ', ' + actor
  FROM t1 p2
   WHERE p2.film_id= p.film_id
   ORDER BY film_id
   FOR XML PATH('')), 1, 2, '') actors
FROM t1 AS p
GROUP BY film_id
)
, t3 AS (
SELECT f.film_id
      ,c.[name] category
FROM film_category$ f JOIN category$ c
ON f.category_id = c.category_id
)
, t4 AS (
SELECT t2.*
      ,t3.category
FROM t2 RIGHT JOIN t3
ON t2.film_id = t3.film_id
)
, t5 AS (
SELECT f.film_id
      ,f.title
	  ,f.[description]
	  ,f.release_year
	  ,f.rental_duration
	  ,f.rental_rate
	  ,f.[length]
	  ,f.replacement_cost
	  ,f.special_features
	  ,l.[name] [language]
FROM film$ f JOIN language$ l
ON f.language_id = l.language_id
)
SELECT t5.*
      ,t4.actors
	  ,t4.category
FROM t4 RIGHT JOIN t5
ON t4.film_id = t5.film_id;

CREATE VIEW customer_detail AS
WITH t1 AS (
SELECT c.customer_id
      ,c.first_name + ' ' + c.last_name customer_name
	  ,ct.city
	  ,c.active
	  ,c.store_id
	  ,cr.country
FROM customer$ c LEFT JOIN [address$] a
ON c.address_id = a.address_id
LEFT JOIN city$ ct
ON a.city_id = ct.city_id
LEFT JOIN country$ cr
ON ct.country_id = cr.country_id
)
, t2 AS (
SELECT customer_id
      ,MIN(rental_date) acquisition_date
FROM rental$
GROUP BY customer_id
)
SELECT t1.*
      ,t2.acquisition_date
FROM t1 LEFT JOIN t2
ON t1.customer_id = t2.customer_id;

CREATE VIEW [transaction] AS
WITH t1 AS (
SELECT r.rental_id
		,r.rental_date
		,r.customer_id
		,r.return_date
		,i.film_id
		,r.staff_id
FROM rental$ r JOIN inventory$ i
ON r.inventory_id = i.inventory_id
)
SELECT t1.rental_id
	  ,t1.rental_date
	  ,COALESCE(p.customer_id, t1.customer_id) customer_id
	  ,t1.return_date
	  ,t1.film_id
      ,p.payment_id
      ,p.amount
	  ,p.payment_date
	  ,t1.staff_id
FROM t1 RIGHT JOIN payment$ p
ON t1.rental_id = p.rental_id
	AND t1.customer_id = p.customer_id;


SELECT *
FROM rental;