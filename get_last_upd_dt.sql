-- -----------------------------
-- --- GET LAST UPDATE DATETIME
-- -----------------------------

DROP FUNCTION IF EXISTS `get_last_upd_dt`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` FUNCTION `get_last_upd_dt`(in_database_name CHAR(50), in_table_name CHAR(50)) RETURNS datetime
begin
	DECLARE max_last_hist_dt DATETIME;

	-- Select maximum datetime	
	SELECT 
		MAX(last_hist_dt) INTO max_last_hist_dt 
	FROM hqlive.hist_log
	WHERE 1=1
		AND `table_name` = in_table_name
		;
	
	RETURN max_last_hist_dt;
end;;
DELIMITER ;
