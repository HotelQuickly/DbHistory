-- -----------------------------------
-- --- HISTORIZE TABLE (only 1 table)
-- -----------------------------------

DROP PROCEDURE IF EXISTS `historize_table`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `historize_table`(
	in_database_name CHAR(50), 
	in_table_name CHAR(50)
)
begin
	DECLARE SQL_stmt TEXT;
	DECLARE columns_basic TEXT;
	DECLARE columns_extended TEXT;
	DECLARE updated_id INT;
	
	DECLARE no_more_rows BOOLEAN;
	DECLARE loop_cntr INT DEFAULT 0;
	DECLARE num_rows INT DEFAULT 0;

	DECLARE tab_name CHAR(50);
	DECLARE tab_h_name CHAR(50);

	DECLARE last_upd_dt DATETIME;
	DECLARE new_valid_from DATETIME;
	DECLARE new_valid_to DATETIME;

	DECLARE p_can_run_historize_table BOOLEAN DEFAULT TRUE;
	DECLARE p_last_log_id INT DEFAULT -1;
	DECLARE p_last_start_dt DATETIME DEFAULT NULL;
	DECLARE p_last_finish_dt DATETIME DEFAULT NULL;

	DECLARE error_found BOOLEAN DEFAULT false;
	
	-- Create cursor	
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

	-- Create cursor
	-- MySQL cannot create dynamic cursors, so we select from a temporary table that we create later
	DECLARE cur_updated_rows CURSOR FOR
		SELECT id
		FROM `xTMP_updated_rows`
		;

	-- Exception handler
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL log_hist_error(in_database_name, @SQL_stmt);

		SET error_found = TRUE;
	END;

	DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET no_more_rows = TRUE;

	OPEN cur1;
	SELECT FOUND_ROWS() INTO num_rows;

	-- Fetch last start time
	SET p_last_log_id = (
		SELECT 
			`hqlive`.`hist_log`.`id`
		FROM `hqlive`.`hist_log`
		WHERE 1=1
		    AND `hqlive`.`hist_log`.`table_name` = tab_name
		ORDER BY 
			`hqlive`.`hist_log`.`id` DESC
		LIMIT 1
	);
	SET p_last_start_dt = (
		SELECT 
			`hqlive`.`hist_log`.`start_dt`
		FROM `hqlive`.`hist_log`
		WHERE 1=1
		    AND `hqlive`.`hist_log`.`id` = p_last_log_id
	);
	-- Fetch last finish time
	SET p_last_finish_dt = (
		SELECT 
			`hqlive`.`hist_log`.`finish_dt`
		FROM `hqlive`.`hist_log`
		WHERE 1=1
		    AND `hqlive`.`hist_log`.`id` = p_last_log_id
	);

	-- Prepare GLOBAL variables
	SET @job_id = CONCAT(FLOOR(RAND()*10000000), '-', in_table_name);

	-- Prepare LOCAL variables
	SET tab_h_name = CONCAT(in_table_name, '_h');
	SET last_upd_dt = IFNULL(get_last_upd_dt(in_database_name, in_table_name), '1900-01-01');
	SET new_valid_to = DATE_ADD(NOW(), INTERVAL -1 second);
	SET new_valid_from = NOW();

	-- Set last update datetime
	CALL log(in_database_name, in_table_name, null);

	-- LOG SQL
	CALL log_hist_sql(in_database_name, CONCAT('-- Starting table: ', tab_h_name)); -- LOG SQL
	
	-- Create Hist table just in case it doesn't exist yet
	CALL create_hist_table(in_database_name, in_table_name, tab_h_name);

	the_loop: LOOP
		FETCH cur1 INTO tab_name;
		
		-- break the loop
		IF no_more_rows THEN
			SELECT 'no more rows (1)';

			CLOSE cur1;
			LEAVE the_loop;
		END IF;

		SET p_can_run_historize_table = can_run_historize_table(in_database_name, tab_name, p_last_start_dt, p_last_finish_dt);

		IF p_can_run_historize_table = 0 THEN
			SELECT CONCAT('cannot run historize table ', in_table_name);

			CLOSE cur1;
			LEAVE the_loop;
		ELSE 
			SELECT CONCAT('running historize table ', in_table_name);

		END IF;
		
		-- Temporary table
		CALL create_tmp_table_with_updates(in_database_name, tab_name, last_upd_dt);

		OPEN cur_updated_rows;

		updated_rows: LOOP

			FETCH cur_updated_rows INTO updated_id;

			-- break the loop
			IF no_more_rows THEN
				SELECT 'no more rows (2)';

				CLOSE cur_updated_rows;
				LEAVE updated_rows;
			END IF;

			CALL log_hist_sql(in_database_name, CONCAT('Updating ID: ', updated_id)); -- LOG SQL
			
			-- Create temporary table with difference
			CALL create_tmp_table_with_diff(in_database_name, tab_name, tab_h_name, last_upd_dt, updated_id);

			-- Set VALID_TO for old rows		
			CALL update_old_rows(in_database_name, tab_name, tab_h_name, new_valid_to);
			
			-- Insert new rows with VALID_FROM = now
			CALL insert_new_rows(in_database_name, tab_name, tab_h_name, new_valid_from);
			
			-- Drop temporary table - Cleaning
			CALL drop_tmp_table_with_diff(tab_name);

		END LOOP updated_rows;

		-- LOG SQL
		IF error_found = FALSE THEN
			CALL log_hist_sql(in_database_name, CONCAT('-- Ending table: ', tab_h_name)); -- LOG SQL
		ELSE
			CALL log_hist_sql(in_database_name, CONCAT('-- Ending table with error: ', tab_h_name)); -- LOG SQL
		END IF;

		SET loop_cntr = loop_cntr + 1;
		
	END LOOP the_loop;

	-- Set last update datetime
	CALL log(in_database_name, in_table_name, NOW());
end;;
DELIMITER ;
