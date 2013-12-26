-- --------------------------------------------
-- --- CREATE TEMPORARY TABLE WITH UPDATES
-- --------------------------------------------

DROP PROCEDURE IF EXISTS `create_tmp_table_with_updates`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `create_tmp_table_with_updates`(
	in_database_name CHAR(50), 
	in_tab_name CHAR(50), 
	in_last_upd_dt DATETIME
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
	
	-- Drop temporary table if exists
	CALL drop_tmp_table_with_updates(in_database_name);

	SET @SQL_stmt = CONCAT('
		CREATE TEMPORARY TABLE IF NOT EXISTS ', @temporary_table_name, ' AS
		SELECT id 
		FROM `', in_database_name,'`.`', in_tab_name, '`
		WHERE `', in_tab_name, '`.`upd_dt` >= "', in_last_upd_dt, '"
	');

	-- LOG SQL
	CALL log_hist_sql(in_database_name, @SQL_stmt); 

	-- Call SQL Statement
	PREPARE stmt_create_tmp_table FROM @SQL_stmt;
	EXECUTE stmt_create_tmp_table;
	DEALLOCATE PREPARE stmt_create_tmp_table;
	
end;;
DELIMITER ;
