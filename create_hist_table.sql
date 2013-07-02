
------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `create_hist_table`(in_database_name CHAR(50), in_tab_name CHAR(50), in_tab_h_name CHAR(50))
begin
	DECLARE SQL_stmt TEXT;
	DECLARE t CHAR(50);
	
	-- Does the hist table already exist?
	SELECT table_name INTO t
	FROM information_schema.tables
	WHERE 1=1
		AND table_schema = 'hqlive_history'
		AND table_name = in_tab_h_name
		;

	IF t IS NULL THEN
		-- Create a new table
		SET @SQL_stmt = CONCAT('
			CREATE TABLE `', in_tab_h_name, '` AS SELECT * FROM `', in_database_name, '`.`', in_tab_name, '` WHERE 1=2
		');
		CALL log_hist_sql(in_database_name, @SQL_stmt); -- LOG SQL
		PREPARE stmt_create_hist_table FROM @SQL_stmt;
		EXECUTE stmt_create_hist_table;
		DEALLOCATE PREPARE stmt_create_hist_table;

		-- Alter the new _h table
		SET @SQL_stmt = CONCAT('
			ALTER TABLE `', in_tab_h_name, '` CHANGE `id` `id` INT(11)  NOT NULL;
		');
		CALL log_hist_sql(in_database_name, @SQL_stmt); -- LOG SQL
		PREPARE stmt_alter_hist_table1 FROM @SQL_stmt;
		EXECUTE stmt_alter_hist_table1;
		DEALLOCATE PREPARE stmt_alter_hist_table1;
		
		-- Alter the new _h table
		/*
		SET @SQL_stmt = CONCAT('
			ALTER TABLE `', in_tab_h_name, '` DROP PRIMARY KEY;
		');
		CALL log_hist_sql(in_database_name, @SQL_stmt); -- LOG SQL
		PREPARE stmt_alter_hist_table2 FROM @SQL_stmt;
		EXECUTE stmt_alter_hist_table2;
		DEALLOCATE PREPARE stmt_alter_hist_table2;
		*/
		
		-- Alter the new _h table
		SET @SQL_stmt = CONCAT('
			ALTER TABLE `', in_tab_h_name, '` ADD `valid_from` DATETIME  NOT NULL  DEFAULT "1900-01-01"  AFTER `del_flag`;
		');
		CALL log_hist_sql(in_database_name, @SQL_stmt); -- LOG SQL
		PREPARE stmt_alter_hist_table3 FROM @SQL_stmt;
		EXECUTE stmt_alter_hist_table3;
		DEALLOCATE PREPARE stmt_alter_hist_table3;
		
		-- Alter the new _h table
		SET @SQL_stmt = CONCAT('
			ALTER TABLE `', in_tab_h_name, '` ADD `valid_to` DATETIME  NOT NULL  DEFAULT "2999-12-31"  AFTER `valid_from`;
		');
		CALL log_hist_sql(in_database_name, @SQL_stmt); -- LOG SQL
		PREPARE stmt_alter_hist_table4 FROM @SQL_stmt;
		EXECUTE stmt_alter_hist_table4;
		DEALLOCATE PREPARE stmt_alter_hist_table4;
		
		-- Alter the new _h table
		SET @SQL_stmt = CONCAT('
			ALTER TABLE `', in_tab_h_name, '` ADD UNIQUE INDEX (`id`, `valid_to`);
		');
		CALL log_hist_sql(in_database_name, @SQL_stmt); -- LOG SQL
		PREPARE stmt_alter_hist_table5 FROM @SQL_stmt;
		EXECUTE stmt_alter_hist_table5;
		DEALLOCATE PREPARE stmt_alter_hist_table5;
		
		-- Prepare columns list
		SET @columns_basic = get_table_columns_string(in_database_name, in_tab_name, false);
		SET @columns_extended_target = get_extended_columns_string_target(@columns_basic);
		SET @columns_extended_source = get_extended_columns_string_source(@columns_basic, null, null);
		
		-- Insert data to the new table
		SET @SQL_stmt = CONCAT('
			INSERT INTO `', in_tab_h_name, '` (', @columns_extended_target, ')
			SELECT 
				', @columns_extended_source, '
			FROM `', in_database_name, '`.`', in_tab_name, '`
		');
		CALL log_hist_sql(in_database_name, @SQL_stmt); -- LOG SQL
		PREPARE stmt_copy_to_hist_table FROM @SQL_stmt;
		EXECUTE stmt_copy_to_hist_table;
		DEALLOCATE PREPARE stmt_copy_to_hist_table;
		
	END IF;
end;;
DELIMITER ;