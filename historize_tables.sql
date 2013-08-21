-- ----------------------------------
-- --- HISTORIZE TABLES (all tables)
-- ----------------------------------

DROP PROCEDURE IF EXISTS `historize_tables`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `historize_tables`(in_database_name CHAR(50), in_interval INTEGER)
begin
	DECLARE tab_name CHAR(50);
	
	DECLARE SQL_stmt TEXT;
	DECLARE columns_basic TEXT;
	DECLARE columns_extended TEXT;
	
	DECLARE no_more_rows BOOLEAN;
	DECLARE loop_cntr INT DEFAULT 0;
	DECLARE num_rows INT DEFAULT 0;

	-- Create cursor
	DECLARE cursor_tables CURSOR FOR
		SELECT `tables`.`table_name`
		FROM `information_schema`.`tables`
		INNER JOIN `hqlive`.`hist_interval` ON `hqlive`.`hist_interval`.`table_name` = `tables`.`table_name`
			AND `hqlive`.`hist_interval`.`interval` = in_interval
		LEFT JOIN `hqlive`.`hist_table_exclusion` ON `hist_table_exclusion`.`table_name` = `tables`.`table_name`
			AND `hist_table_exclusion`.`excluded_flag` = 1
		WHERE 1=1
			AND `table_schema` = in_database_name
			AND `hist_table_exclusion`.id IS NULL
		;

	-- Exception handler
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL log_hist_error(in_database_name, @SQL_stmt);
	END;

	DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET no_more_rows = TRUE;

	CALL set_default_interval(in_database_name);
	
	CALL set_db_settings();
	
	OPEN cursor_tables;
	SELECT FOUND_ROWS() INTO num_rows;
	
	the_loop: LOOP
		FETCH cursor_tables INTO tab_name;
		
		-- break the loop
		IF no_more_rows THEN
			CLOSE cursor_tables;
			LEAVE the_loop;
		END IF;
		
		-- historize individual table
		CALL historize_table(in_database_name, tab_name);
		
		-- Slow down the database a bit (CPU)
		SELECT SLEEP(1);

		-- increment loop counter
		SET loop_cntr = loop_cntr + 1;
		
	END LOOP the_loop;

end;;
DELIMITER ;
