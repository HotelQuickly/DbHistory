------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `historize_table`(in_database_name CHAR(50), in_table_name CHAR(50))
begin
	DECLARE SQL_stmt TEXT;
	DECLARE columns_basic TEXT;
	DECLARE columns_extended TEXT;
	
	DECLARE no_more_rows BOOLEAN;
	DECLARE loop_cntr INT DEFAULT 0;
	DECLARE num_rows INT DEFAULT 0;

	DECLARE tab_name CHAR(35);
	DECLARE tab_h_name CHAR(35);
	
	DECLARE cur1 CURSOR FOR
		SELECT `tables`.`table_name`
		FROM `information_schema`.`tables`
		LEFT JOIN `hqlive`.`hist_table_exclusion` ON `hist_table_exclusion`.`table_name` = `tables`.`table_name`
			AND `hist_table_exclusion`.`excluded_flag` = 1
		WHERE 1=1
			AND `table_schema` = in_database_name
			AND `tables`.`table_name` = in_table_name
			AND `hist_table_exclusion`.id IS NULL
		LIMIT 1;

	DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET no_more_rows = TRUE;

	OPEN cur1;
	SELECT FOUND_ROWS() INTO num_rows;
	
	the_loop: LOOP
		FETCH cur1 INTO tab_name;
		SET @tab_h_name = CONCAT(tab_name, '_h');
		
		-- break the loop
		IF no_more_rows THEN
			CLOSE cur1;
			LEAVE the_loop;
		END IF;
		
		SET @last_upd_dt = IFNULL(get_last_upd_dt(in_database_name, in_table_name), '1900-01-01');
		SET @new_valid_to = date_add(NOW(), INTERVAL -1 second);
		SET @new_valid_from = NOW();

		-- LOG SQL
		CALL log_hist_sql(in_database_name, CONCAT('-- Starting table: ', @tab_h_name)); -- LOG SQL

		-- Create Hist table just in case it doesn't exist yet
		CALL create_hist_table(in_database_name, tab_name, @tab_h_name);
		
		-- Create temporary table with difference
		CALL create_tmp_table_with_diff(in_database_name, tab_name, @tab_h_name, @last_upd_dt);

		-- Set VALID_TO for old rows		
		CALL update_old_rows(in_database_name, tab_name, @tab_h_name, @new_valid_to);
		
		-- Insert new rows with VALID_FROM = now
		CALL insert_new_rows(in_database_name, tab_name, @tab_h_name, @new_valid_from);
		
		-- Set last update datetime
		CALL set_last_upd_dt(in_database_name, in_table_name);
		
		-- Drop temporary table - Cleaning
		CALL drop_tmp_table_with_diff(tab_name);

		-- LOG SQL
		CALL log_hist_sql(in_database_name, CONCAT('-- Ending table: ', @tab_h_name)); -- LOG SQL
		
		SET loop_cntr = loop_cntr + 1;
		
	END LOOP the_loop;
end;;
DELIMITER ;