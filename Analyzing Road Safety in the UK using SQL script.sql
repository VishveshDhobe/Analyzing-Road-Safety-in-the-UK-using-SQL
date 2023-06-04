
-- create schema

create schema UK_Vehicle_Accident;

set schema 'UK_Vehicle_Accident';

show search_path;

-- create tables

create table accident(
	Accident_Index	varchar,
	Location_Easting_OSGR int,
	Location_Northing_OSGR int,
	Longitude float,
	Latitude float,
	Police_Force int,
	Accident_Severity int,
	Number_of_Vehicles int,
	Number_of_Casualties int,
	Date text,
	Day_of_Week int,
	Time time,
	Local_Authority_District int,
	Local_Authority_Highway	varchar,
	First_Road_Class	int,
	first_Road_Number int,
	Road_Type int,
	Speed_limit	int,
	Junction_Detail	int,
	Junction_Control int,
	second_Road_Class int,
	second_Road_Number int,
	Pedestrian_Crossing_Human_Controlint int,
	Pedestrian_Crossing_Physical_Facilities	int,
	Light_Conditions int,
	Weather_Conditions	int,
	Road_Surface_Conditions int,
	Special_Conditions_at_Site int,
	Carriageway_Hazards int,
	Urban_or_Rural_Area int,
	Did_Police_Officer_Attend_Scene_of_Accident	int,
	LSOA_of_Accident_Location varchar
);


COPY accident
		FROM '[file location]'
		DELIMITER ','
		CSV HEADER;

create table vehicals(
	Accident_Index varchar,
	Vehicle_Reference int,
	Vehicle_Type int,
	Towing_and_Articulation int,
	Vehicle_Manoeuvre int,
	Vehicle_Location_Restricted_Lane int,
	Junction_Location int,
	Skidding_and_Overturning int,
	Hit_Object_in_Carriageway int,
	Vehicle_Leaving_Carriageway int,
	Hit_Object_off_Carriageway int,
	First_Point_of_Impact int,
	Was_Vehicle_Left_Hand_Drive int,
	Journey_Purpose_of_Driver int,
	Sex_of_Driver int,
	Age_of_Driver int,
	Age_Band_of_Driver int,
	Engine_Capacity_cc int,
	Propulsion_Code int,
	Age_of_Vehicle int,
	Driver_IMD_Decile int,
	Driver_Home_Area_Type int,
	Vehicle_IMD_Decile int
);


copy vehicals 
from '[file location]'
delimiter ','
csv header;
	

alter table vehicals 
rename to vehicle;

create table vehicle_type(
	code int,
	label text
);

copy vehicle_type
from '[file location]'
delimiter ','
csv header;
	

/*

1. Evaluate the median severity value of accidents caused by various Motorcycles.

**/

select accident_vehicle.vehicle_type, accident_vehicle.label, percentile_cont(0.5) within group
							(order by accident_vehicle.accident_severity) as median
from (
		select a.accident_severity, v.vehicle_type, vt.label
		from vehicle v 
		left join accident a on a.accident_index = v.accident_index 
		inner join vehicle_type vt on vt.code = v.vehicle_type 
		where vehicle_type in (2,3,4,5)
		order by vehicle_type ,accident_severity
) as accident_vehicle 
group by accident_vehicle.vehicle_type, accident_vehicle.label;


/*
 OUTPUT :
 
label                                |vehicle_type|median|
-------------------------------------+------------+------+
Motorcycle 50cc and under            |           2|   3.0|
Motorcycle 125cc and under           |           3|   3.0|
Motorcycle over 125cc and up to 500cc|           4|   3.0|
Motorcycle over 500cc                |           5|   3.0|

*/

/*

2. Evaluate Accident Severity and Total Accidents per Vehicle Type

*/

select v.vehicle_type, vt.label ,count(a.accident_index) as total_accident, 
		mode() within group(order by a.accident_severity) as  Accident_Severity
from vehicle v 
left join accident a on a.accident_index = v.accident_index 
inner join vehicle_type vt on vt.code = v.vehicle_type 
where vehicle_type > 0
group by vehicle_type ,vt.label 
order by vehicle_type 

/*
OUTPUT:


vehicle_type|label                                |total_accident|accident_severity|
------------+-------------------------------------+--------------+-----------------+
           1|Pedal cycle                          |         19440|                3|
           2|Motorcycle 50cc and under            |          2237|                3|
           3|Motorcycle 125cc and under           |          9234|                3|
           4|Motorcycle over 125cc and up to 500cc|          2187|                3|
           5|Motorcycle over 500cc                |          7054|                3|
           8|Taxi/Private hire car                |          5420|                3|
           9|Car                                  |        182954|                3|
          10|Minibus (8 - 16 passenger seats)     |           498|                3|
          11|Bus or coach (17 or more pass seats) |          5381|                3|
          16|Ridden horse                         |           107|                3|
          17|Agricultural vehicle                 |           504|                3|
          18|Tram                                 |            18|                3|
          19|Van / Goods 3.5 tonnes mgw or under  |         13876|                3|
          20|Goods over 3.5t. and under 7.5t      |          1708|                3|
          21|Goods 7.5 tonnes mgw and over        |          4762|                3|
          22|Mobility scooter                     |           222|                3|
          23|Electric motorcycle                  |             9|                2|
          90|Other vehicle                        |          1286|                3|
          97|Motorcycle - unknown cc              |           275|                3|
          98|Goods vehicle - unknown weight       |           615|                3|

*/


/*

3. Calculate the Average Severity by vehicle type.

*/


select v.vehicle_type, vt.label ,round(AVG(a.accident_severity),3) as  Average_Severity 
from vehicle v 
left join accident a on a.accident_index = v.accident_index 
inner join vehicle_type vt on vt.code = v.vehicle_type 
where vehicle_type > 0
group by vehicle_type ,vt.label 
order by vehicle_type; 


/*
 OUTPUT :

vehicle_type|label                                |average_severity|
------------+-------------------------------------+----------------+
           1|Pedal cycle                          |           2.811|
           2|Motorcycle 50cc and under            |           2.827|
           3|Motorcycle 125cc and under           |           2.781|
           4|Motorcycle over 125cc and up to 500cc|           2.690|
           5|Motorcycle over 500cc                |           2.585|
           8|Taxi/Private hire car                |           2.881|
           9|Car                                  |           2.867|
          10|Minibus (8 - 16 passenger seats)     |           2.817|
          11|Bus or coach (17 or more pass seats) |           2.858|
          16|Ridden horse                         |           2.832|
          17|Agricultural vehicle                 |           2.679|
          18|Tram                                 |           2.889|
          19|Van / Goods 3.5 tonnes mgw or under  |           2.851|
          20|Goods over 3.5t. and under 7.5t      |           2.811|
          21|Goods 7.5 tonnes mgw and over        |           2.734|
          22|Mobility scooter                     |           2.716|
          23|Electric motorcycle                  |           2.444|
          90|Other vehicle                        |           2.778|
          97|Motorcycle - unknown cc              |           2.695|
          98|Goods vehicle - unknown weight       |           2.839|

*/


/*

4. Calculate the Average Severity and Total Accidents byMotorcyclee.

*/



select v.vehicle_type, vt.label ,round(AVG(a.accident_severity),3) as  Average_Severity,
		count(a.accident_index) as total_accident
from vehicle v 
left join accident a on a.accident_index = v.accident_index 
inner join vehicle_type vt on vt.code = v.vehicle_type 
where vehicle_type in (2,3,4,5)
group by vehicle_type ,vt.label 
order by vehicle_type ;

/*
OUTPUT:

vehicle_type|label                                |average_severity|total_accident|
------------+-------------------------------------+----------------+--------------+
           2|Motorcycle 50cc and under            |           2.827|          2237|
           3|Motorcycle 125cc and under           |           2.781|          9234|
           4|Motorcycle over 125cc and up to 500cc|           2.690|          2187|
           5|Motorcycle over 500cc                |           2.585|          7054|

*/


/*

4. Calculate Average Severity(Mean), Mode severity, Median severity and Total Accidents.

*/


select accident_vehicle.vehicle_type, accident_vehicle.label, mode() within group( order by accident_severity) as mode,
	   avg(accident_severity) as mean, percentile_cont(0.5) within group (order by 
	   accident_vehicle.accident_severity) as median, count(accident_severity) as total_accident
from (
		select a.accident_severity, v.vehicle_type, vt.label
		from vehicle v 
		left join accident a on a.accident_index = v.accident_index 
		inner join vehicle_type vt on vt.code = v.vehicle_type 
		where vehicle_type > -1
		order by vehicle_type ,accident_severity
) as accident_vehicle 
group by accident_vehicle.vehicle_type, accident_vehicle.label;


/*
OUTPUT :

vehicle_type|label                                |mode|mean              |median|total_accident|
------------+-------------------------------------+----+------------------+------+--------------+
           1|Pedal cycle                          |   3|2.8108024691358025|   3.0|         19440|
           2|Motorcycle 50cc and under            |   3|2.8265534197586053|   3.0|          2237|
           3|Motorcycle 125cc and under           |   3|2.7807017543859649|   3.0|          9234|
           4|Motorcycle over 125cc and up to 500cc|   3|2.6904435299497028|   3.0|          2187|
           5|Motorcycle over 500cc                |   3|2.5849163595123334|   3.0|          7054|
           8|Taxi/Private hire car                |   3|2.8813653136531365|   3.0|          5420|
           9|Car                                  |   3|2.8665292915159002|   3.0|        182954|
          10|Minibus (8 - 16 passenger seats)     |   3|2.8172690763052209|   3.0|           498|
          11|Bus or coach (17 or more pass seats) |   3|2.8576472774577216|   3.0|          5381|
          16|Ridden horse                         |   3|2.8317757009345794|   3.0|           107|
          17|Agricultural vehicle                 |   3|2.6785714285714286|   3.0|           504|
          18|Tram                                 |   3|2.8888888888888889|   3.0|            18|
          19|Van / Goods 3.5 tonnes mgw or under  |   3|2.8508215624099164|   3.0|         13876|
          20|Goods over 3.5t. and under 7.5t      |   3|2.8108899297423888|   3.0|          1708|
          21|Goods 7.5 tonnes mgw and over        |   3|2.7341453170936581|   3.0|          4762|
          22|Mobility scooter                     |   3|2.7162162162162162|   3.0|           222|
          23|Electric motorcycle                  |   2|2.4444444444444444|   2.0|             9|
          90|Other vehicle                        |   3|2.7783825816485226|   3.0|          1286|
          97|Motorcycle - unknown cc              |   3|2.6945454545454545|   3.0|           275|
          98|Goods vehicle - unknown weight       |   3|2.8390243902439024|   3.0|           615|

*/


