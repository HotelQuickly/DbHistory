-- ----------------------------------
-- --- CREATE HISTORY TABLE
-- ----------------------------------

DROP PROCEDURE IF EXISTS `create_hist_table`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `create_hist_table`(in_database_name CHAR(50), in_tab_name CHAR(50), in_tab_h_name CHAR(50))
begin
	DECLARE SQL_stmt TEXT;
	DECLARE t CHAR(50);
	
	-- Exception handler
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL log_hist_error(in_database_name, @SQL_stmt);
	END;
	
	-- Does the hist table already exist?
	SELECT table_name INTO t
	FROM information_schema.tables
	WHERE 1=1
		AND table_schema = 'hqlive_history'
		AND table_name = in_tab_h_name
		;

	IF t IS NULL THEN

		-- ===== ===== ===== ===== ===== ===== ===== 
		-- ===== ===== ===== ===== ===== ===== ===== 
		-- Create a new table
		SET @SQL_stmt = CONCAT('
			CREATE TABLE `', in_tab_h_name, '` AS SELECT * FROM `', in_database_name, '`.`', in_tab_name, '` WHERE 1=2
		');

		-- LOG SQL
		CALL log_hist_sql(in_database_name, @SQL_stmt); 

		-- Call SQL statement
		PREPARE stmt_create_hist_table FROM @SQL_stmt;
		EXECUTE stmt_create_hist_table;
		DEALLOCATE PREPARE stmt_create_hist_table;

		-- ===== ===== ===== ===== ===== ===== ===== 
		-- ===== ===== ===== ===== ===== ===== ===== 
		-- Alter the new _h table - drop AUTOINCREMENT
		SET @SQL_stmt = CONCAT('
			ALTER TABLE `', in_tab_h_name, '` CHANGE `id` `id` INT(11)  NOT NULL;
		');

		-- LOG SQL
		CALL log_hist_sql(in_database_name, @SQL_stmt); 

		-- Call SQL statement
		PREPARE stmt_alter_hist_table1 FROM @SQL_stmt;
		EXECUTE stmt_alter_hist_table1;
		DEALLOCATE PREPARE stmt_alter_hist_table1;
		
		-- ===== ===== ===== ===== ===== ===== ===== 
		-- ===== ===== ===== ===== ===== ===== ===== 
		-- Alter the new _h table - add columns VALID_FROM and VALID_TO
		SET @SQL_stmt = CONCAT('
			ALTER TABLE `', in_tab_h_name, '` ADD `valid_from` DATETIME  NOT NULL  DEFAULT "1900-01-01"  AFTER `del_flag`;
		');

		-- LOG SQL
		CALL log_hist_sql(in_database_name, @SQL_stmt);

		-- Call SQL statement
		PREPARE stmt_alter_hist_table3 FROM @SQL_stmt;
		EXECUTE stmt_alter_hist_table3;
		DEALLOCATE PREPARE stmt_alter_hist_table3;
		
		-- ===== ===== ===== ===== ===== ===== ===== 
		-- ===== ===== ===== ===== ===== ===== ===== 
		-- Alter the new _h table - add columns VALID_FROM and VALID_TO
		SET @SQL_stmt = CONCAT('
			ALTER TABLE `', in_tab_h_name, '` ADD `valid_to` DATETIME  NOT NULL  DEFAULT "2999-12-31"  AFTER `valid_from`;
		');

		-- LOG SQL
		CALL log_hist_sql(in_database_name, @SQL_stmt);

		-- Call SQL statement
		PREPARE stmt_alter_hist_table4 FROM @SQL_stmt;
		EXECUTE stmt_alter_hist_table4;
		DEALLOCATE PREPARE stmt_alter_hist_table4;
		
		-- ===== ===== ===== ===== ===== ===== ===== 
		-- ===== ===== ===== ===== ===== ===== ===== 
		-- Alter the new _h table - add new INDEX
		SET @SQL_stmt = CONCAT('
			ALTER TABLE `', in_tab_h_name, '` ADD UNIQUE INDEX (`id`, `valid_to`);
		');

		-- LOG SQL
		CALL log_hist_sql(in_database_name, @SQL_stmt); 

		-- Call SQL statement
		PREPARE stmt_alter_hist_table5 FROM @SQL_stmt;
		EXECUTE stmt_alter_hist_table5;
		DEALLOCATE PREPARE stmt_alter_hist_table5;
		
		-- Prepare columns list
		SET @columns_basic = get_table_columns_string(in_database_name, in_tab_name, false);
		SET @columns_extended_target = get_extended_columns_string_target(@columns_basic);
		SET @columns_extended_source = get_extended_columns_string_source(@columns_basic, null, null);
		
		-- ===== ===== ===== ===== ===== ===== ===== 
		-- ===== ===== ===== ===== ===== ===== ===== 
		-- Insert data to the new table
		SET @SQL_stmt = CONCAT('
			INSERT INTO `', in_tab_h_name, '` (', @columns_extended_target, ')
			SELECT 
				', @columns_extended_source, '
			FROM `', in_database_name, '`.`', in_tab_name, '`
		');

		-- LOG SQL
		CALL log_hist_sql(in_database_name, @SQL_stmt); 

		-- Call SQL statement
		PREPARE stmt_copy_to_hist_table FROM @SQL_stmt;
		EXECUTE stmt_copy_to_hist_table;
		DEALLOCATE PREPARE stmt_copy_to_hist_table;

	ELSE
		-- Prepare SQL for alter table
		SELECT
			CONCAT(
				'ALTER TABLE `', in_database_name,'_history`.`', `columns_live`.`table_name`, '_h` 
				ADD `', `columns_live`.`column_name`, '` ', `columns_live`.`column_type`,
				' ',
				CASE 
					WHEN `columns_live`.`data_type` like '%char%' THEN 'CHARACTER SET utf8'
					WHEN `columns_live`.`data_type` like '%text%' THEN 'CHARACTER SET utf8'
					ELSE ''
				END,
				' ',
				CASE WHEN `columns_live`.`is_nullable` = 'NO' THEN 'NOT NULL' ELSE '' END,
				' ',
				CASE WHEN `columns_live`.`column_default` IS NOT NULL THEN CONCAT('DEFAULT "', `columns_live`.`column_default`, '"') ELSE 'DEFAULT NULL' END,
				' ',
				'AFTER `del_flag`') into @SQL_stmt
				/* `columns_live`.*   */
		FROM `information_schema`.`columns` `columns_live`
		LEFT JOIN `information_schema`.`columns` `columns_hist` ON 1=1
			AND `columns_hist`.`table_schema` = CONCAT(in_database_name, '_history')
			AND `columns_hist`.`table_name` = CONCAT(`columns_live`.`table_name`, '_h')
			AND `columns_hist`.`column_name` = `columns_live`.`column_name`
		WHERE 1=1
			AND `columns_live`.`table_schema` = in_database_name
			AND `columns_live`.`table_name` = in_tab_name
			AND `columns_hist`.`column_name` IS NULL
		;

	
		IF @SQL_stmt IS NOT NULL THEN 
			-- Call SQL statement
			PREPARE stmt_copy_to_hist_table FROM @SQL_stmt;
			EXECUTE stmt_copy_to_hist_table;
			DEALLOCATE PREPARE stmt_copy_to_hist_table;
		END IF;

	END IF;
end;;
DELIMITER ;