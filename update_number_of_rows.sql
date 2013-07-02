------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `update_number_of_rows`()
begin

	UPDATE hqlive.hist_interval, information_schema.tables
	SET hqlive.hist_interval.approx_number_of_rows = information_schema.tables.table_rows
	WHERE information_schema.tables.table_name = hqlive.hist_interval.table_name
		AND information_schema.tables.table_schema = 'hqlive';
	
end;;
DELIMITER ;
