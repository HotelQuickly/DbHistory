------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `update_old_rows`(in_database_name CHAR(50), in_tab_name CHAR(50), in_tab_h_name CHAR(50), in_valid_to DATETIME)
begin
	SET @temporary_table_name = get_tmp_diff_table_name(in_tab_name);
	
	SET @SQL_stmt = CONCAT('
		UPDATE `', in_tab_h_name, '`
		SET `valid_to` = "', in_valid_to, '"
		WHERE 1=1
			AND `', in_tab_h_name, '`.id IN (SELECT `id` FROM ', @temporary_table_name, ')
			AND (NOW() BETWEEN `', in_tab_h_name, '`.`valid_from` AND `', in_tab_h_name, '`.`valid_to`)
	');
	CALL log_hist_sql(in_database_name, @SQL_stmt); -- LOG SQL
	PREPARE stmt_update FROM @SQL_stmt;
	EXECUTE stmt_update;
	DEALLOCATE PREPARE stmt_update;
	
end;;
DELIMITER ;
