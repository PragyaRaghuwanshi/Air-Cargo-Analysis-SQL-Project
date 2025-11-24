                                -- Data Acquisition and Manipulation Using SQL --
                                        -- Course-End Project 2 --
					                     -- Air Cargo Analysis --
-- Actions --
/* 1.Create a database named AirCargo and import ticket_details.csv, routes.csv, passengers_on_flights.csv, and customer.csv from the given resources into it. */

create database if not exists AirCargo;
use AirCargo;

/*2.Create an ER diagram for the given airlines' database. */
 
 -- customer --
 create table if not exists AirCargo.customer(
 customer_id int not null 
,first_name varchar(100) 
,last_name varchar (100)
,date_of_birth date
,gender varchar(10)
,primary key (customer_id));

-- routes --
create table if not exists AirCargo.routes(
 route_id int not null 
,flight_num varchar (20) 
,origin_airport varchar (10)
,destination_airport varchar (10)
,aircraft_id varchar (30)
,distance_miles int 
,primary key (route_id));

-- ticket_details --
create table if not exists AirCargo.ticket_details(
 p_date date
,customer_id int not null 
,aircraft_id varchar (30)
,class_id varchar (50)
,no_of_tickets int 
,a_code varchar (10)
,Price_per_ticket decimal (12,2) 
,brand varchar (100)
,primary key (customer_id,p_date,aircraft_id,a_code)
,constraint fk_ticket_customer foreign key (customer_id) references customer (customer_id)); 

-- passengers_on_flights --
create table if not exists AirCargo.passengers_on_flights (
 customer_id int not null
,aircraft_id varchar (30)
,route_id int
,depart varchar (10)
,arrival varchar (10)
,seat_num varchar (10)
,class_id varchar (50)
,travel_date date
,flight_num varchar (20)
,primary key (customer_id, aircraft_id ,route_id,seat_num,travel_date, flight_num)
,constraint fk_passenger_customer foreign key (customer_id) references customer (customer_id)
,constraint fk_passenger_route foreign key  (route_id) references  routes (route_id));

/* 3.Write a query to display all the passengers who have traveled on routes 01 to 25 from the passengers_on_flights table.  */

select 
 customer_id
,route_id
From AirCargo.passengers_on_flights
where route_id between 1 and 25;

/* 4.Write a query to identify the number of passengers and total revenue in business class from the ticket_details table.*/

select
 sum(no_of_tickets) as total_passengers
,sum(no_of_tickets * Price_per_ticket) as total_revenue
from AirCargo.ticket_details
where class_id = 'Business';

/* 5.Write a query to display the full name of the customer by extracting the first name and last name from the customer table.*/

select
 customer_id
,concat(first_name, ' ' , last_name) as full_name
from AirCargo.customer;

/* 6.Write a query to extract the customers who have registered and booked a ticket from the customer and ticket_details tables.*/

select
 AirCargo.customer.customer_id
,concat(AirCargo.customer.first_name , ' ' , AirCargo.customer.last_name) as full_name
from AirCargo.customer
inner join
     AirCargo.ticket_details on
     AirCargo.customer.customer_id = AirCargo.ticket_details.customer_id;
     
/* 7.Write a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table. */

select
   AirCargo.customer.customer_id
  ,AirCargo.customer.first_name
  ,AirCargo.customer.last_name
  ,AirCargo.ticket_details.brand
from AirCargo.customer
inner join 
          AirCargo.ticket_details on
          AirCargo.customer.customer_id = AirCargo.ticket_details.customer_id
where AirCargo.ticket_details.brand = 'Emirates';

/* 8.Write a query to identify the customers who have traveled by Economy Plus class using the sub-query on the passengers_on_flights table. */

select
   AirCargo.customer.customer_id
  ,AirCargo.customer.first_name
  ,AirCargo.customer.last_name
 from AirCargo.customer
 where customer_id in (select
                         AirCargo.passengers_on_flights.customer_id
					   from AirCargo.passengers_on_flights
                       where class_id = 'Economy Plus');

/* 9.Write a query to determine whether the revenue has crossed 10000 using the IF clause on the ticket_details table. */                       

 select
 if(sum(no_of_tickets * Price_per_ticket) > 10000
 , 'Revenue has crossed 10000' , 'Revenue has not crossed 10000') as revenue_status
 from AirCargo.ticket_details;
 
 /* 10.Write a query to create and grant access to a new user to perform database operations.*/

 -- create a new user
create user 'Aircargo_user'@'localhost'identified by'StrongPassword123';
-- drop user if exists 'Aircargo_user'@'localhost'; 

-- grant access to a new user
grant all privileges on aircargo.* to 'Aircargo_user'@'localhost';

/*11.Write a query to find the maximum ticket price for each class using window functions on the ticket_details table.*/

select
      class_id
     ,price_per_ticket
     ,max(Price_per_ticket) over (partition by class_id) as max_price_for_class
from AirCargo.ticket_details;

/* 12.Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table using the index.*/

create index idx_route_id on passengers_on_flights(route_id);
select*from passengers_on_flights where route_id = 4;

/*13.For route ID 4, write a query to view the execution plan of the passengers_on_flights table.*/

explain
select * from passengers_on_flights
where route_id = 4;

/*14.Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using the rollup function. */

select
      customer_id
	 ,aircraft_id
     ,sum(no_of_tickets * price_per_ticket) as total_price
from ticket_details
group by customer_id, aircraft_id with rollup;

/*15.Write a query to create a view with only business class customers and the airline brand.*/

drop view if exists business_class_customers; 
create view business_class_customers as
select
      AirCargo.customer.customer_id
	 ,AirCargo.customer.first_name
     ,AirCargo.customer.last_name
     ,AirCargo.ticket_details.brand
from AirCargo.customer
inner join 
           AirCargo.ticket_details on
            AirCargo.customer.customer_id = AirCargo.ticket_details.customer_id
where AirCargo.ticket_details.class_id = 'Business';

select * from business_class_customers; 

/* 16.Write a query to create a stored procedure that extracts all the details from the routes table where the traveled distance is more than 2000 miles. */

drop procedure if exists get_long_routes;

DELIMITER $$
create procedure get_long_routes()
begin
     select *
     from AirCargo.routes
     where distance_miles > 2000;
end $$
DELIMITER ;

call get_long_routes(); 

/*17.Using GROUP BY, determine the total number of tickets purchased by each customer and the total price paid.*/

select 
      customer_id
	 ,sum(no_of_tickets) as total_tickets_purchased
     ,sum(no_of_tickets * price_per_ticket) as total_amount_paid
from AirCargo.ticket_details
group by
		customer_id;

/*18.Calculate the average number of passengers per flight route.*/

select
      route_id
	 ,count(customer_id) as total_passengers
from AirCargo.passengers_on_flights
group by route_id;

select 
       avg(total_passengers) as 
       avg_passengers_per_route
from (
      select
            route_id
	 ,count(customer_id) as total_passengers
from AirCargo.passengers_on_flights
group by route_id) as route_passenger_countd;

                         -- project Developed by- Pragya Raghuwanshi--














































                       

























