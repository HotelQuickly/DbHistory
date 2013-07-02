-------------------------------------
----- FUNCTION TO GET COLUMN STRINGS
-------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` FUNCTION `get_extended_columns_string_target`(in_columns TEXT) RETURNS text CHARSET latin1
begin	
	DECLARE out_columns TEXT DEFAULT '';

	-- Concatenate strings	
	SET @out_columns = CONCAT(in_columns, ', `valid_from`, `valid_to`');
	
	RETURN @out_columns;
end;;
DELIMITER ;