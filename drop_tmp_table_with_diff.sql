--------------------------------------------
----- DROP TEMPORARY TABLE WITH DIFFERENCES
--------------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `drop_tmp_table_with_diff`(in_tab_name CHAR(50))
begin
	DECLARE SQL_stmt TEXT;

	-- Get name of the temporary table
	SET @temporary_table_name = get_tmp_diff_table_name(in_tab_name);

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