------------------------------------
----- CREATE EVENTS
------------------------------------

-- Create event 
DROP EVENT IF EXISTS historize_1440;
CREATE EVENT historize_1440
	ON SCHEDULE EVERY 1440 MINUTE
	STARTS '2013-08-23 21:00:00'
	DO
		CALL historize_tables('hqlive', 1440);

-- Create event 
DROP EVENT IF EXISTS historize_60;
CREATE EVENT historize_60
	ON SCHEDULE EVERY 60 MINUTE
	STARTS '2013-08-23 01:00:00'
	DO
		CALL historize_tables('hqlive', 60);

-- Create event 
DROP EVENT IF EXISTS historize_30;
CREATE EVENT historize_30
	ON SCHEDULE EVERY 30 MINUTE
	STARTS '2013-08-23 01:30:00'
	DO
		CALL historize_tables('hqlive', 30);

-- Create event 
DROP EVENT IF EXISTS historize_20;
CREATE EVENT historize_20
	ON SCHEDULE EVERY 20 MINUTE
	STARTS '2013-08-23 01:20:00'
	DO
		CALL historize_tables('hqlive', 20);

-- Create event 
DROP EVENT IF EXISTS historize_15;
CREATE EVENT historize_15
	ON SCHEDULE EVERY 15 MINUTE
	STARTS '2013-08-23 01:15:00'
	DO
		CALL historize_tables('hqlive', 15);

-- Create event 
DROP EVENT IF EXISTS historize_10;
CREATE EVENT historize_10
	ON SCHEDULE EVERY 10 MINUTE
	STARTS '2013-08-23 01:10:00'
	DO
		CALL historize_tables('hqlive', 10);

-- Create event 
DROP EVENT IF EXISTS historize_5;
CREATE EVENT historize_5
	ON SCHEDULE EVERY 5 MINUTE
	STARTS '2013-08-23 01:03:00'
	DO
		CALL historize_tables('hqlive', 5);

-- Create event 
DROP EVENT IF EXISTS historize_3;
CREATE EVENT historize_3
	ON SCHEDULE EVERY 3 MINUTE
	STARTS '2013-08-23 01:04:00'
	DO
		CALL historize_tables('hqlive', 3);

-- Create event 
DROP EVENT IF EXISTS historize_2;
CREATE EVENT historize_2
	ON SCHEDULE EVERY 2 MINUTE
	STARTS '2013-08-23 01:02:00'
	DO
		CALL historize_tables('hqlive', 2);

-- Create event 
DROP EVENT IF EXISTS historize_1;
CREATE EVENT historize_1
	ON SCHEDULE EVERY 1 MINUTE
	STARTS '2013-08-23 01:00:00'
	DO
		CALL historize_tables('hqlive', 1);
