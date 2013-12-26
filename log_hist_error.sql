-- -----------------------
-- --- LOG HISTORY ERRORS
-- -----------------------

DROP PROCEDURE IF EXISTS `log_hist_error`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `log_hist_error`(
	in_database_name CHAR(50), 
	in_sql_statement TEXT
)
begin
	-- Prepare SQL statement
	SET @SQL_error = CONCAT('
		INSERT INTO `', in_database_name, '`.`hist_error` (`error_code`, `error_message`, `sql`, `ins_dt`, `ins_process_id`)
		VALUES (null, null, "', REPLACE(in_sql_statement, '"', "\'"), '", NOW(), "log_hist_error()")
	');

	-- LOG SQL
	CALL log_hist_sql(in_database_name, @SQL_error);

	-- Call SQL statement
	PREPARE stmt_update FROM @SQL_error;
	EXECUTE stmt_update;
	DEALLOCATE PREPARE stmt_update;
end;;
DELIMITER ;
