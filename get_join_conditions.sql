------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` FUNCTION `get_join_conditions`(in_database_name CHAR(50), in_tab_name CHAR(50), in_tab_h_name CHAR(50)) RETURNS text CHARSET latin1
begin	
	DECLARE out_columns TEXT DEFAULT '';
	
	DECLARE no_more_rows BOOLEAN;
	DECLARE loop_cntr INT DEFAULT 0;
	DECLARE num_rows INT DEFAULT 0;
	
	DECLARE t CHAR(35);
	DECLARE SQL_stmt TEXT;
	
	DECLARE cur_columns CURSOR FOR
		SELECT column_name
		FROM information_schema.columns
		WHERE 1=1
			AND table_schema = in_database_name
			AND table_name = in_tab_name;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET no_more_rows = TRUE;

	OPEN cur_columns;

	SET @out_columns = '';

	the_loop: LOOP
		FETCH cur_columns INTO t;
		
		-- break the loop
		IF no_more_rows THEN
			CLOSE cur_columns;
			LEAVE the_loop;
		END IF;

		SET @column = CONCAT('
			AND IFNULL(`', in_tab_name, '`.`', t, '`, "XNA") = IFNULL(`', in_tab_h_name, '`.`', t, '`, "XNA")
		');
		SET @out_columns = CONCAT(@out_columns, @column);
		
	END LOOP the_loop;
	
	RETURN @out_columns;
end;;
DELIMITER ;
