------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `log_hist_sql`(in_database_name CHAR(50), in_sql TEXT)
begin
	DECLARE sql_text TEXT;
	
	SET @sql_text = CONCAT('
		INSERT INTO `', in_database_name, '`.`hist_sql` (`sql`, `ins_dt`, `ins_process_id`)
		VALUES
		("', REPLACE(in_sql, '"', "'"), '", NOW(), "history-logger")
	');
	PREPARE stmt_update FROM @sql_text;
	EXECUTE stmt_update;
	DEALLOCATE PREPARE stmt_update;
	
end;;
DELIMITER ;
