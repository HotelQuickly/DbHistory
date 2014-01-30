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
	DECLARE max_last_start_dt DATETIME DEFAULT NULL;

	-- Select maximum datetime	
	SELECT 
		`hist_log`.`start_dt` INTO max_last_start_dt
	FROM `hqlive`.`hist_log`
	WHERE 1=1
		AND `table_name` = in_table_name
		AND `hist_log`.`finish_dt` IS NOT NULL
	ORDER BY 
		`id` DESC
	LIMIT 1;
	
	RETURN IFNULL(max_last_start_dt, '1900-01-01');
end;;
DELIMITER ;
