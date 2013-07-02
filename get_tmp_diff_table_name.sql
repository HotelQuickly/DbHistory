------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` FUNCTION `get_tmp_diff_table_name`(in_tab_name CHAR(50)) RETURNS text CHARSET latin1
begin	
	RETURN CONCAT('xTMP_DIFF_', in_tab_name);
end;;
DELIMITER ;