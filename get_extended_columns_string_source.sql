------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` FUNCTION `get_extended_columns_string_source`(in_columns TEXT, valid_from CHAR(20), valid_to CHAR(20)) RETURNS text CHARSET latin1
begin
	DECLARE out_columns TEXT DEFAULT '';
	
	SET @out_columns = CONCAT(in_columns, ', ', IFNULL(valid_from, '`ins_dt`') ,', "', IFNULL(valid_to, '2999-12-31') ,'"');
	
	RETURN @out_columns;

end;;
DELIMITER ;