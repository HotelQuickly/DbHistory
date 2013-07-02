------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `create_tmp_table_with_diff`(in_database_name CHAR(50), in_tab_name CHAR(50), in_tab_h_name CHAR(50), in_last_upd_dt DATETIME)
begin
	DECLARE SQL_stmt TEXT;
		
	-- Prepare columns list
	SET @columns_basic = get_table_columns_string(in_database_name, in_tab_name, true);
	SET @columns_extended_target = get_extended_columns_string_target(@columns_basic);
	SET @columns_extended_source = get_extended_columns_string_source(@columns_basic, null, null);
	
	SET @join_conditions = get_join_conditions(in_database_name, in_tab_name, in_tab_h_name);
	
	SET @temporary_table_name = get_tmp_diff_table_name(in_tab_name);

	-- Drop temporary table if exists
	CALL drop_tmp_table_with_diff(in_tab_name);
	
	SET @SQL_stmt = CONCAT('
		CREATE TEMPORARY TABLE ', @temporary_table_name, ' AS
		SELECT
			', @columns_basic, '
		FROM `', in_database_name, '`.`', in_tab_name, '`
		LEFT JOIN `', in_tab_h_name,'` ON 1=1
			', @join_conditions ,'
			AND (NOW() BETWEEN `', in_tab_h_name,'`.`valid_from` AND `', in_tab_h_name,'`.`valid_to`)
		WHERE 1=1
			AND `', in_database_name, '`.`', in_tab_name, '`.`upd_dt` >= "', in_last_upd_dt, '"
			AND `', in_tab_h_name,'`.`id` IS NULL
	');
	CALL log_hist_sql(in_database_name, @SQL_stmt); -- LOG SQL
	PREPARE stmt_create_tmp_table FROM @SQL_stmt;
	EXECUTE stmt_create_tmp_table;
	DEALLOCATE PREPARE stmt_create_tmp_table;
	
end;;
DELIMITER ;
