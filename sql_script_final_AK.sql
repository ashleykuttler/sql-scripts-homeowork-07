-- 1a. Display the first and last names of all actors from the table actor.
USE sakila;
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) as 'Actor Name'  FROM actor
order by 1;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name like '%joe%';

-- 2b. Find all actors whose last name contain the letters GEN
SELECT first_name, last_name FROM actor
WHERE last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name FROM actor
WHERE last_name like '%LI%'
ORDER BY 2, 1;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country from country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
USE sakila;
ALTER TABLE actor add Description BLOB;

-- 3b. Very quickly you realize that entering decriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor DROP Description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) as '# of Actors' FROM actor
GROUP BY last_name
ORDER BY 1;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) as '# of Actors' FROM actor
GROUP BY last_name
HAVING COUNT(*) >= 2
ORDER BY 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SET @id = (SELECT actor_id FROM actor WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS');
UPDATE actor 
SET first_name = 'HARPO' 
WHERE actor.actor_id = @id;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name =  'GROUCHO'
WHERE actor_id = @id;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address, a.address2 FROM staff s
INNER JOIN address a ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name,
	s.last_name, 
    DATE_FORMAT(p.payment_date, "%M %Y") as payment_date, 
    CONCAT('$', FORMAT(SUM(p.amount), 2)) as total_amt  
FROM staff s
INNER JOIN payment p ON s.staff_id = p.staff_id
WHERE payment_date BETWEEN '2005-08-01' and '2005-09-01'
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) as "# of actors" FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title
ORDER BY 1;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, 
COUNT(inventory.inventory_id) as total_copies_in_inventory FROM film
INNER JOIN inventory on film.film_id = inventory.film_id
WHERE title = 'Hunchback Impossible'
GROUP BY title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
--  List the customers alphabetically by last name:
SELECT customer.first_name, 
customer.last_name, 
SUM(payment.amount) as total_amount_paid 
FROM customer 
INNER JOIN payment  ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY 2 ;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film 
WHERE ( title LIKE 'K%' OR title LIKE 'Q%')
AND language_id = (SELECT language_id from language where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN 
	(SELECT actor_id FROM film_actor WHERE film_id IN 
		(Select film_id FROM film where title = 'Alone Trip'));
        
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information
SELECT 
CONCAT(c.first_name, ' ', c.Last_name) as CustomerName, 
c.email,
country.country 
FROM customer c
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ON city.city_id = a.city_id
INNER JOIN country ON country.country_id = city.country_id
WHERE country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title, c.`name` FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON c.category_id = fc.category_id
WHERE c.`name` = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) as total_rentals from film f
INNER JOIN inventory i ON i.film_id = f.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY 2 DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in
SELECT s.store_id, CONCAT('$', FORMAT(SUM(amount),2)) as total_revenue FROM payment p
LEFT JOIN staff on staff.staff_id = p.staff_id
LEFT JOIN store s ON s.store_id = staff.store_id
GROUP BY s.store_id
ORDER BY 2 DESC; 

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, cn.country FROM store s
INNER JOIN address a ON s.address_id = a.address_id 
INNER JOIN city c on a.city_id = c.city_id
INNER JOIN country cn ON c.country_id = cn.country_id




