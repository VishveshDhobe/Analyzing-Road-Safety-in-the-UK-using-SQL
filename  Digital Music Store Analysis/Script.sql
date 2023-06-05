-- DATASET SCRIPT
/*

https://github.com/lerocha/chinook-database/tree/master/ChinookDatabase/DataSources

*/


-- Questions

/*

1. Which city corresponds to the best customers?

*/

select c."City" 
from "Invoice" i 
inner join "Customer" c on c."CustomerId" = i."CustomerId" 
group by c."CustomerId" 
order by sum("Total") desc
limit 15;

/*
OUTPUT: 

City          |
--------------+
Prague        |
Fort Worth    |
Santiago      |
Budapest      |
Dublin        |
Frankfurt     |
Chicago       |
Salt Lake City|
Vienne        |
Madison       |
Helsinki      |
Dijon         |
Prague        |
Amsterdam     |
Bordeaux      |

*/

/*

2. The highest number of invoices belongs to which country?

*/

select i."BillingCountry" , count("InvoiceId") as no_of_invoice
from "Invoice" i 
group by "BillingCountry" 
order by no_of_invoice desc 
limit 1;

/*
OUTPUT: 

BillingCountry|no_of_invoice|
--------------+-------------+
USA           |           91|

*/

/*

3. Name the best customer (customer who spent the most money).

*/


select c."CustomerId" , concat(c."FirstName",' ',c."LastName")  as Name 
from "Invoice" i 
inner join "Customer" c on c."CustomerId" = i."CustomerId" 
group by c."CustomerId" 
order by sum("Total") desc
limit 1;

/*
OUTPUT: 

CustomerId|name       |
----------+-----------+
         6|Helena Hol�|

*/

/*

4. Suppose you want to host a rock concert in a city and want to know which location should host it. Query the dataset to find the city with the most rock-music listeners to answer this question.

*/


select c."City" ,count(c."CustomerId") as total_listners
from "Customer" c 
inner join "Invoice" i on i."CustomerId" = c."CustomerId" 
inner join "InvoiceLine" il on il."InvoiceId" = i."InvoiceId" 
inner join "Track" t on il."TrackId" = t."TrackId" 
inner join "Genre" g on t."GenreId" = g."GenreId" 
where g."Name" in('Rock','Rock And Roll')
group by c."City"
order by total_listners desc
limit 1;

/*
OUTPUT: 

City     |total_listners|
---------+--------------+
S�o Paulo|            40|

*/

/*

5. If you want to know which artists the store should invite,
 find out who is the highest-paid and most-listened-to.

*/


select a."Name" , count(il."InvoiceLineId") as no_of_time_listened
from "Artist" a 
inner join "Album" a2 on a2."ArtistId" = a."ArtistId" 
inner join "Track" t on t."AlbumId" = a2."AlbumId" 
inner join "InvoiceLine" il on il."TrackId" = t."TrackId" 
group by a."Name" 
order by no_of_time_listened desc 
limit 1;

/*
OUTPUT:

 Name       |no_of_time_listened|
-----------+-------------------+
Iron Maiden|                140| 

*/





