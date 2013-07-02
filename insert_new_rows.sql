------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `insert_new_rows`(in_database_name CHAR(50), in_tab_name CHAR(50), in_tab_h_name CHAR(50), in_valid_from DATETIME)
begin

	SET @temporary_table_name = get_tmp_diff_table_name(in_tab_name);

	-- Prepare columns list
	SET @columns_basic = get_table_columns_string(in_database_name, in_tab_name, false);
	SET @columns_extended_target = get_extended_columns_string_target(@columns_basic);
	SET @columns_extended_source = get_extended_columns_string_source(@columns_basic, null, null);	
	
	SET @SQL_stmt = CONCAT('
		INSERT INTO `', in_tab_h_name, '` (', @columns_extended_target ,')
		SELECT
			', @columns_basic ,',
			"', in_valid_from, '" AS valid_from,
			"2999-12-31" AS valid_to
		FROM `', in_database_name, '`.`', in_tab_name, '`
		WHERE 1=1
			AND `', in_tab_name, '`.`id` IN (SELECT `id` FROM ', @temporary_table_name, ')
	');
	CALL log_hist_sql(in_database_name, @SQL_stmt); -- LOG SQL
	PREPARE stmt_insert FROM @SQL_stmt;
	EXECUTE stmt_insert;
	DEALLOCATE PREPARE stmt_insert;
	
end;;
DELIMITER ;