-- ------------------------------------------
-- --- DROP TEMPORARY TABLE WITH DIFFERENCES
-- ------------------------------------------

DROP PROCEDURE IF EXISTS `drop_tmp_table_with_updates`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `drop_tmp_table_with_updates`(
	in_database_name CHAR(50)
)
begin
	DECLARE SQL_stmt TEXT;

	-- Exception handler
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL log_hist_error(in_database_name, @SQL_stmt);
	END;
	
	-- Get name of the temporary table
	SET @temporary_table_name = get_tmp_updates_table_name();

	-- Prepare SQL statement to drop the table
	SET @SQL_stmt = CONCAT('
		DROP TEMPORARY TABLE IF EXISTS ', @temporary_table_name, '
	');

	-- LOG SQL
	CALL log_hist_sql('hqlive', @SQL_stmt); 

	-- Call SQL statement
	PREPARE stmt_drop_tmp_table FROM @SQL_stmt;
	EXECUTE stmt_drop_tmp_table;
	DEALLOCATE PREPARE stmt_drop_tmp_table;
	
end;;
DELIMITER ;