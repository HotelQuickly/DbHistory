-- -----------------------------
-- --- GET LAST UPDATE DATETIME
-- -----------------------------

DROP FUNCTION IF EXISTS `get_last_upd_dt`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` FUNCTION `get_last_upd_dt`(
	in_database_name CHAR(50), 
	in_table_name CHAR(50)
) RETURNS datetime
begin
	DECLARE max_last_hist_dt DATETIME;

	-- Select maximum datetime	
	SELECT 
		last_hist_dt INTO max_last_hist_dt 
	FROM hqlive.hist_log
	WHERE `table_name` = in_table_name
	ORDER BY 
		last_hist_dt DESC
	LIMIT 1;
	
	RETURN max_last_hist_dt;
end;;
DELIMITER ;
