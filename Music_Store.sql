/* TITLE: MUSIC STORE ANALYSIS
   CREATED BY: HARSH AGARWAL 
   CONCEPTS USED: RECURSIVE, AGGREGATE FUNCTIONS, virtual tables,joins

*/


--the senior most employee based on job title--
Select concat(first_name,' ',last_name) as Seniormost FROM EMPLOYEE
order by levels desc
limit 1;
--countries having the most invoices--
Select billing_country,count(billing_country) as number_inv from invoice
group by billing_country
order by number_inv desc
limit 1;
--top 3 values of total invoice--
Select total from invoice
order by total desc 
limit 3;
--City that has the higest sum of invoice totals--
Select billing_city,sum(total) as total_amount
FROM invoice
group by billing_city
order by total_amount desc
limit 1;
--Customer who has the highest spend--
Select c.customer_id, concat(c.first_name,' ',c.last_name) as Cust_name,c.customer_id,sum(i.total) as total_bill
from customer as c
join invoice as i
on c.customer_id=i.customer_id
group by c.customer_id
order by sum(i.total) desc
limit 1;
--the email ,first name, last name& Genre of all rock music listeners ordered alphabetically by email starting with A--
Select distinct c.email,c.first_name,c.last_name,g.name
from
customer as c 
join invoice as i
on c.Customer_Id=i.Customer_Id
join invoice_line as il
on i.invoice_id=il.invoice_id
join track as t
on il.track_id=t.track_id
join genre as g
on t.genre_id=g.genre_id
Where g.name='Rock'
order by c.email;
--artist name and total track count of the top 10 rock bands--
SELECT ar.artist_id, ar.name,COUNT(ar.artist_id) AS tracks
FROM track as t
JOIN album as al ON al.album_id = t.album_id
JOIN artist as ar ON ar.artist_id = al.artist_id
JOIN genre as g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY ar.artist_id
ORDER BY tracks DESC
LIMIT 10;
/* track names that have a song length longer than the average song length. 
Ordered by the song length in desc order*/
SELECT name,milliseconds as durn
from track
where milliseconds>(
SELECT avg(milliseconds) as dur
from track)
order by durn desc;
/*amount spent by each customer on top artist along customer name and artist name  */
With top_artist as(
SELECT al.artist_id as arid,sum(il.unit_price*il.quantity) as spent
from album as al
join track as t
on al.album_id=t.album_id
join invoice_line as il
on t.track_id=il.track_id
group by 1
order by 2 desc
limit 1)
SELECT c.customer_id,concat(c.first_name,' ',c.last_name) as CustName,ar.name,sum(il.unit_price*il.quantity) as spend
From
Customer as c
join 
invoice as i
on c.customer_id=i.customer_id
join 
invoice_line as il
on i.invoice_id=il.invoice_id
join
track as t
on il.track_id=t.track_id
join album as al
on t.album_id=al.album_id
join artist as ar
on al.artist_id=ar.artist_id
join top_artist as ta
on ar.artist_id=ta.arid
group by 1,3
order by 4 desc;
-- the most popular music Genre for each country according to the net sales--
WITH country_genre as
(SELECT c.Country as desh,genre.genre_id as gid,sum(il.unit_price*il.quantity) as sale,
 	row_number() over(partition by c.country order by sum(il.unit_price*il.quantity) desc) as RowNo from invoice_line il
	JOIN invoice ON invoice.invoice_id = il.invoice_id
	JOIN customer c ON c.customer_id = invoice.customer_id
	JOIN track ON track.track_id = il.track_id
	JOIN genre ON genre.genre_id = track.genre_id
 	group by 1,2
 	order by 1 asc, 3 desc
)
SELECT cg.desh,cg.gid,cg.sale,g.name 
from country_genre cg
join
genre g
on cg.gid=g.Genre_id
where cg.RowNo<=1;

WITH Recursive
	Sale_country as(
		SELECT sum(il.unit_price*il.quantity) as sale,c.Country as desh,g.genre_id as gid
		from invoice_line as il
		join track as t
		on il.track_id=t.track_id
		join genre as g
		on t.genre_id=g.genre_id
		join invoice as i
		on il.invoice_id=i.invoice_id
		join customer as c
		on i.customer_id=c.customer_id
		group by 2,3
		order by 2
	), 
	max_genre as(SELECT max(sale) as sale,desh
				FROM Sale_country
				group by 2
				order by 2)
	SELECT sc.*,g.name
	from Sale_country sc
	join max_genre mg
	on sc.desh=mg.desh
	join genre g
	on sc.gid=g.genre_id
	where sc.sale=mg.sale;
/*the customer who has spent the most on music for each country.  */
WITH country_genre as
(SELECT c.Country as desh,c.customer_id as cid,sum(i.total) as sale,
 	row_number() over(partition by c.country order by sum(i.total) desc) as RowNo from invoice i
	JOIN customer c ON c.customer_id = i.customer_id
 	group by 1,2
 	order by 1 asc, 3 desc
)
SELECT cg.*,concat(c.First_name,' ',c.last_name) as name
from country_genre cg
join customer c
on cg.cid=c.customer_id
where cg.RowNo<=1;