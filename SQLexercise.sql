--Someone says that the gift basket Savory Basket is very gourmand. Show all food
--products included in the basket and the corresponding prices.

SELECT basketCombines.basket_name, food.name, food.price
FROM BasketCombines, Food
WHERE BasketCombines.food_name = Food.name
AND BasketCombines.food_unit = Food.unit
AND BasketCombines.food_weight = Food.weight
AND BasketCombines.basket_name = 'Savory basket';

--Pistachio is your favorite ingredient! Show food name, unit, weight, label and price of
--Pistachio Cream.

SELECT name, unit, weight, label, price
FROM Food
WHERE name = 'Pistachio Cream';

--Main menus are regular menus grouping many menu items. Verify this fact!

SELECT a.name, a.main
FROM Menu a, Menu b
WHERE a.name = b.main;

--Return the food product in the shop, which is the most expensive.
SELECT name, unit, weight, price
FROM Food
WHERE price = (SELECT MAX(price)
                     FROM Food);
					 

--List food products added to the shop in the year 2020.
--Firstly create a query in order to select foods added in the year 2020.

SELECT year(new.startDate), new.name, new.unit, new.weight
FROM (SELECT *
      FROM Food
      WHERE year(startDate) = 2020) new;
	  
--List food products that are at least in one gift basket.
SELECT name, unit, weight, price
FROM Food
WHERE EXISTS (SELECT *
             FROM BasketCombines
             WHERE BasketCombines.food_name = Food.name
             AND BasketCombines.food_unit = Food.unit
             AND BasketCombines.food_weight = Food.weight);
			 

--Show menus listing food products added to the shop last year.
SELECT main, menu
FROM Menu
WHERE name IN (SELECT menu_name
               FROM Food
               WHERE year(startDate) = year(now()) - 1)
ORDER BY main;

--Which food products are more expensive than all food prices added to the
--shop in the year 2018?

SELECT *
FROM Food
WHERE year(startDate) > 2018
  AND price >ALL (SELECT price
                  FROM Food
                   WHERE year(startDate) = 2018);
				   

--Which food has been added - for example of different weight - to the shop
--along the next years?
SELECT *
FROM Food a
WHERE year(a.startDate) >ANY (SELECT year(b.startDate)
                              FROM Food b
                              WHERE b.name = a.name);
							  

--For each menu determine the cheapest food product. Show menu which offers
--at least one product cheaper than 5 $.

SELECT menu_name, MIN(price) AS cheaper
FROM Food
GROUP BY menu_name
HAVING MIN(price) <= 5;

--We have the need to verify whether in the main-menu Preserved Foods there is at
--least one food having a price larger than 8.50 e. Show the sub-menu they belong to.
SELECT name, main
FROM Menu
WHERE main = 'Preserved Foods'
  AND EXISTS (SELECT *
              FROM Food
              WHERE price > 8.50
              AND Food.menu_name = Menu.name);
			  

--Create a short price list including foods of the two sub-menu Sauces and Pesto
--and Olives and Capers. For the rst sub-menu a special discount of 20% is applied.
--Report the food name, weight and unit, the price, compute the discounted price and
--beside a special column with the label 'discounted' if the price is discounted the label
--'full' if not.
--[Tip: Select data for each sub-menu separately. For the full prices do not compute
--anything and just return the NULL value.]

(SELECT name, weight, unit, price, price*0.80 AS n_price, 'discounted' AS type
FROM Food
WHERE menu_name = 'Sauces and Pesto')
UNION
(SELECT name, weight, unit, price, NULL AS n_price, 'full' AS type
FROM Food
WHERE menu_name = 'Olives and Capers')
ORDER BY weight;


--We create for each product a sort of \tag" following this text format:
--Traditional Bolognese Ragu - [La Dispensa di Amerigo: 180.00 g]
--which includes name, label, weight, unit. Other than the label the query must return
--NULL if the food does not belong to any gift basket, the gift basket name (capitalized)
--otherwise. [Tip: the explicit join could be helpful]

SELECT CONCAT(name, ' - [',label, ': ', weight, ' ', unit, ']') AS label,
UCASE(basket_name) AS basket
FROM Food LEFT JOIN BasketCombines
  ON (Food.name = BasketCombines.food_name
  AND Food.unit = BasketCombines.food_unit
  AND Food.weight = BasketCombines.food_weight)
ORDER by name DESC;


--We aim to detect main menus that suffer of a poor offer of food products. Return
--main menu which offer less than seven food products, additional data is the available
--number of food products in this menu and their commercial value, that is the total price
--of the food products.
SELECT main, COUNT(*) AS nr, SUM(price) AS value
FROM Food, Menu
WHERE Food.menu_name = Menu.name
   AND endDate IS NOT NULL
GROUP BY main
HAVING nr < 7;


--Realize a comparative selection of your food products. The selection is based on
--cost/benefit parameter and on the level of nutritive we can benefit, specifically
--cost/benefit parameter equals the ratio price/weight, while nutritive benefitt is the 30%
--of the weight. Show those foods which have the cost/benefit parameter larger than its
--average (over all foods) or the nutritive benefit larger than its average (over all foods).
SELECT name, price/weight AS comparative, weight*0.30 AS nutritive
FROM Food
WHERE price/weight > (SELECT AVG(price/weight)
                      FROM Food)
   OR weight*0.30 > (SELECT AVG(weight*0.30)
                     FROM Food);
					 
--The goal is to verify if the food products proposal can be appreciated by different
--people targets, so we compute two differenterent key numbers. The first one is for each main
--menu the number of foods having a price smaller than or equal to 5 e (adding the label
--`cheaper') while the second one, again for each main menu, the number of foods having
--a price larger than or equal to 14 e (adding the label `expensive').
--Both results must be returned together in the same list.


(SELECT 'cheaper' AS type, Menu.main, COUNT(*) AS nr
FROM Food, Menu
WHERE Food.menu_name = Menu.name
AND price <= 5.0
GROUP BY Menu.main)
UNION
(SELECT 'expensive' AS type, Menu.main, COUNT(*) AS nr
FROM Food, Menu
WHERE Food.menu_name = Menu.name
AND price >= 14.0
GROUP BY Menu.main);


--You aim to offer a \Smart Basket", made by a selection of cheapest products. You
-- among your food products those that in the corresponding menu they are the
--cheapest ones.
--Show returned foods from the most expensive to the cheapest one.
--[Tip: the operator IN works with a couple of attribute: WHERE (attr1, attr2) IN.]

SELECT menu_name, CONCAT(name,'-',weight,'-', unit), price
FROM Food
WHERE (menu_name,price) IN (SELECT menu_name, MIN(price)
                            FROM Food
                            GROUP BY menu_name)
ORDER BY price DESC;


--We aim to evaluate how many products are added in one quarter. Report the product
--added to the online market in the third quarter of the year 2019, but only if they
--have been used to combine a basket.
SELECT *
FROM Food
WHERE (startDate >= '2019-07-01' AND startDate <= '2019-09-30')
AND EXISTS (SELECT *
            FROM BasketCombines
            WHERE food_name = Food.name
            AND food_unit = Food.unit
         ,  AND food_weight = Food.weight)
ORDER BY startDate;


--We have a selection of Preserved Foods in the online market which could be appre-
--ciated in the United Kingdom market, hence for each food product in the main menu
--Preserved Foods we create a label (specifically uk label) concatenating the name,
--the weight and the price, paying attention to UK units (ounces=oz for grams, pound=$
--for euro). [Tip: In order to convert values in ounces and pounds multiply respectively
--the values by 0.035 and 0.8.] One acceptable label could be:
--Black Olive Paste: 2.80 oz # 2.160 $
SELECT concat(Food.name, ': ', round(weight*0.035,2),' oz # ', price*0.8, ' $') AS uk_label
FROM Menu, Food
WHERE Menu.name = Food.menu_name
AND main = 'Preserved Foods';


--There exists one food (or more) which are available in the online market from a long
--time, probably because it is mostly appreciated and bought.
--Return the food product(s) which is in the market from a long time (it has the oldest
--startDate). Report the food name, weight and unit and moreover the number of years
--of availability [tip: use an expression based on the year() function].
SELECT name, weight, unit, year(now()) - year(startDate)
FROM Food
WHERE startDate = (SELECT MIN(startDate)
FROM Food);

--Marketing manger would like to rename gift baskets emphasizing products \value",
--therefore he would like a report, as below. [Tip: apply the strategy to find maximum
--and minimum separately]
--Use the explicit JOIN whenever it is necessary to join tables.

(SELECT B.basket_name, MAX(F.price) AS price, 'MAX' AS value
FROM Food F JOIN BasketCombines B
   ON (F.name = B.food_name
       AND F.unit = B.food_unit
       AND F.weight = B.food_weight)
GROUP BY B.basket_name)
UNION
(SELECT B.basket_name, MIN(F.price) AS price, 'MIN' AS value
FROM Food F JOIN BasketCombines B
  ON (F.name = B.food_name
     AND F.unit = B.food_unit
     AND F.weight = B.food_weight)
 GROUP BY B.basket_name)
ORDER BY basket_name, price;

--Consider to check which food products are offered at least in two different format (i.e.
--different weights). List all these products, adding to the data identifying the products
--the two different weights detected.
SELECT f1.name, f1.unit, f1.weight AS w1, f2.weight AS w2
FROM food f1, food f2
WHERE f1.name = f2.name
  AND f1.unit = f2.unit
  AND f1.weight > f2.weight;
  

--Which food products have been mostly consulted?

SELECT food_name, food_unit, food_weight, COUNT(*) AS nr
FROM consulted
GROUP BY food_name, food_unit, food_weight
HAVING COUNT(*) >=ALL(SELECT COUNT(*)
                      FROM consulted
                    GROUP BY food_name, food_unit, food_weight);
					


--Report for each oered product in the online shop how many times they have been
--consulted and selected. Consider a tabular output format.

SELECT C.name, C.unit, C.weight, C.consulted, S.selected
FROM (SELECT name, unit, weight, COUNT(food_name) AS consulted
      FROM food LEFT OUTER JOIN consulted ON (food.name = food_name
      AND food.unit = food_unit
      AND food.weight = food_weight)
      GROUP BY name, unit, weight) C,
    (SELECT name, unit, weight, COUNT(food_name) AS selected
     FROM food LEFT OUTER JOIN selected ON (food.name = food_name
      AND food.unit = food_unit
      AND food.weight = food_weight)
     GROUP BY name, unit, weight) S
WHERE C.name = S.name
AND C.unit = S.unit
AND C.weight = S.weight
ORDER BY C.name, C.weight;


--Consider each access (ID), when it happened (date), and at which time and what
--product the user has consulted. We assume that a consultation follows access time.
SELECT U.ID, U.date, U.time, C.time, C.food_name, C.food_unit, C.food_weight
FROM consulted C, user U
WHERE C.ID = U.ID
  AND C.time >= U.time
ORDER BY U.date, U.time, C.time;


--The marketing would like to reconsider number and value of food products to oer as
--speciality of a region. The request is to extract the region name - excluding the whole
--Italy - for which the online market oers the largest number of products, moreover for
--that region the cheapest and the expensive product oered.
SELECT region_name, MIN(food.price), MAX(food.price)
FROM sheet JOIN food ON food.sheet_ID = sheet.ID
WHERE NOT(region_name = 'Italy')
GROUP BY region_name
HAVING COUNT(ID) >= ALL(SELECT COUNT(ID)
                        FROM sheet
                       WHERE NOT(region_name = 'Italy')
                       GROUP BY region_name);
					   
					   
--Marketing has formulated the need of a report of users accesses long summer time,
--that is how many items (products) the user selected (or nothing), when browsing the
--shop.
--Report for each user, identifed by the network info, the number of items selected
--(or nothing) in summer. Show number of selections from the largest to the smallest.
--[Sol.]

SELECT network_info, count(food_name) AS nr
FROM user LEFT JOIN selected ON (user.ID = selected.ID)
WHERE date >= '2022-06-22'
  AND date <='2022-09-21'
GROUP BY network_info
ORDER BY nr DESC;

--We would like to create a new gift basket having in mind something of healthy and of
--tradition and for some of them to apply a special discount. List foods in the menu 'Olive
--Oil', but do not retrive those having the highest price. Considering the high quality of
--products we do not apply any discount. Then list foods that can be related to `Bologna'
--tradition, and moreover all types of legumes. For those returns in a new column that
--you apply a 30% discount. [Tip: Write different selections and then combine returned
--tuples]
--[Sol.]

(SELECT CONCAT(name, '-', weight, '-', unit) AS prod, price, NULL AS disc
FROM food
WHERE menu_name = 'Olive Oil'
 AND price NOT IN (SELECT MAX(price)
                   FROM food
                   WHERE menu_name = 'Olive Oil'))
UNION
(SELECT CONCAT(name, '-', weight, '-', unit) AS prod, price, '30%' AS disc
 FROM food
 WHERE name LIKE '%bologn%'
OR menu_name = 'Legumes');


--Aiming to update food sheets, marketing requests to list all sheets code, and producer
--name but only for producers who have at least two sheets (food products) published
--on the online-market.
--[Sol.]
SELECT DISTINCT p1.producer_name AS producer, p1.ID AS code
FROM sheet p1, sheet p2
WHERE p1.producer_name = p2.producer_name
AND p1.ID <> p2.ID
ORDER BY code;


--We would like to create a particular gift basket having in mind something from Sicily
--and a selection of foods from each menu. List name, weight, unit of foods from 'Sicilia'
--then detect from each menu the product in glass jar (unit in grams) having the largest
--quantity. [Tip: The second selection should use in the condition the pair (menu name,
--weight)].
(SELECT name, weight, unit, 'Sicily'
FROM food JOIN sheet ON sheet_ID = ID
WHERE region_name = 'Sicilia')
UNION
(SELECT name, weight, unit, 'Big Glass'
FROM food
WHERE (menu_name, weight) IN (SELECT menu_name, MAX(weight)
                              FROM food
                              WHERE unit = 'g'
                              GROUP BY menu_name))
ORDER BY name, weight;



--Marketing has formulated the request to determine in which day the online shop has
--been consulted the most (Clicks on some products). Report the date and the number
--of consultations (clicks). [Tip: Data to consider are available in User and Consulted
--tables].
SELECT date, count(*) AS nr, 'clicks'
FROM user JOIN consulted ON user.ID = consulted.ID
GROUP BY date
HAVING COUNT(*) >= ALL(SELECT count(*)
                       FROM user JOIN consulted ON user.ID = consulted.ID
                       GROUP BY date);
					   

--Marketing would like to know if - and in case the relevance - of organic foods.
--A) Determine for each menu the number of organic products, and moreover for each
--menu the number of traditional products (non organic).

SELECT O.menu_name, O.organic, T.traditional
FROM (SELECT menu_name, COUNT(*) AS organic
      FROM food
      WHERE name LIKE '%organic%'
GROUP BY menu_name) O,
(SELECT menu_name, COUNT(*) AS traditional
FROM food
WHERE name NOT LIKE '%organic%'
GROUP BY menu_name) T
WHERE O.menu_name = T.menu_name;


--We would like to create a particular gift basket having in mind something of salad
--and something of sweet excellence. List name, weight, unit of foods of something
--different from `Sweet Products' and `Preserved Foods' (main menus). Add foods
--which report in their description (published on the sheet) the name of the two
--excellences: `gianduia' or `pistacchio'. Add the information `SALAD' or `SWEET' at
--the end of each row.
(SELECT food.name, food.weight, food.unit, 'SALAD'
FROM food, menu
WHERE food.menu_name = menu.name
  AND main NOT IN('Sweet Products', 'Preserved Foods'))
UNION
(SELECT food.name, food.weight, food.unit, 'SWEET'
FROM food, sheet
WHERE food.sheet_ID = sheet.ID
  AND (description LIKE '%gianduia%' OR description LIKE '%pistacchio%'));
  

--The report of the last year showed that on January and on July users accessed to the
--online market the most. Marketing asks us to analyze user accesses on January and
--on July showing users (identify a user by user network info) who accessed at
--least twice.
SELECT DISTINCT month(u1.date), u1.network_info
FROM user u1, user u2
WHERE u1.network_info = u2.network_info
 AND u1.date < u2.date
 AND month(u1.date) IN (1,7)
ORDER BY u1.date;


--The statistics of food appreciation is necessary to make suitable sale strategies, there-
--fore:
--A) Compute for each menu and for each producer description (in attribute `label'),
--the number of selected food items (in the basket to buy), including those producers
--whose food items have never been selected.
--B) [extra points] Reports only data with the best statistic, that is the largest
--number of selected items.

SELECT menu_name, label, count(selected.food_name) AS nr
FROM food LEFT JOIN selected ON
  (food.name = selected.food_name
AND food.unit = selected.food_unit
AND food.weight = selected.food_weight)
GROUP BY menu_name, label
HAVING nr >= ALL (SELECT count(selected.food_name) AS nr
                  FROM food LEFT JOIN selected ON
                 (food.name = selected.food_name
                 AND food.unit = selected.food_unit
                 AND food.weight = selected.food_weight)
                 GROUP BY menu_name, label);
				 
				 
--The marketing would like to analyze the part of the day users prefer to visit the online
--market, especially during working hours. Report for each hour of the day how many
--users have been connected at that hour [tip: use the function hour() to extract the
--hour from the complete time]. Consider only working hours, that is from 9 (included)
--to 13 and from 14 (included) to 18.
--[Sol.]
SELECT hour(time) AS slot, COUNT(*)
  FROM user
WHERE (hour(time) >= 9 AND hour(time) < 13)
  OR (hour(time) >= 14 AND hour(time) < 18)
GROUP BY hour(time);


--We have the suspicious that a competitor accesses very frequently to the web store,
--just to consult - and maybe copy - food offers. List all food consultations for which
--there exists at least one access (table user) in the month of June coming from a network
--starting with 112 or 113.
--[Sol.]
SELECT *
FROM consulted
WHERE EXISTS (SELECT *
              FROM user
               WHERE month(date) = 6
               AND (network_info LIKE '112%' OR network_info LIKE '113')
                AND ID = consulted.ID);
				

--Marketing would like to know the entity value of each basket [we consider as basket
--which food products a user has selected. The value is simply the quantity of each item
--selected multiplied by the corresponding price]. Therefore compute and report for each
--user ID the computed value. Consider only basket values greater than or equal to 50
--$.
--[Sol.]

SELECT ID, SUM(quantity*price) AS total
  FROM food, selected
WHERE food.name = selected.food_name
  AND food.weight = selected.food_weight
  AND food.unit = selected.food_unit
GROUP BY ID
HAVING total >= 50;