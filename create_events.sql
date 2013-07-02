------------------------------------
----- CREATE EVENTS
------------------------------------

-- Create event 
CREATE EVENT historize_1440
	ON SCHEDULE EVERY 1440 MINUTE
	DO
		CALL historize_tables('hqlive', 1440);

-- Create event 
CREATE EVENT historize_60
	ON SCHEDULE EVERY 60 MINUTE
	DO
		CALL historize_tables('hqlive', 60);

-- Create event 
CREATE EVENT historize_30
	ON SCHEDULE EVERY 30 MINUTE
	DO
		CALL historize_tables('hqlive', 30);

-- Create event 
CREATE EVENT historize_20
	ON SCHEDULE EVERY 20 MINUTE
	DO
		CALL historize_tables('hqlive', 20);

-- Create event 
CREATE EVENT historize_15
	ON SCHEDULE EVERY 15 MINUTE
	DO
		CALL historize_tables('hqlive', 15);

-- Create event 
CREATE EVENT historize_10
	ON SCHEDULE EVERY 10 MINUTE
	DO
		CALL historize_tables('hqlive', 10);

-- Create event 
CREATE EVENT historize_5
	ON SCHEDULE EVERY 5 MINUTE
	DO
		CALL historize_tables('hqlive', 5);

-- Create event 
CREATE EVENT historize_3
	ON SCHEDULE EVERY 3 MINUTE
	DO
		CALL historize_tables('hqlive', 3);

-- Create event 
CREATE EVENT historize_2
	ON SCHEDULE EVERY 2 MINUTE
	DO
		CALL historize_tables('hqlive', 2);

-- Create event 
CREATE EVENT historize_1
	ON SCHEDULE EVERY 1 MINUTE
	DO
		CALL historize_tables('hqlive', 1);
