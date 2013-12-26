-- -----------------------------------
-- --- FUNCTION TO GET COLUMN STRINGS
-- -----------------------------------

DROP FUNCTION IF EXISTS `get_extended_columns_string_source`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` FUNCTION `get_extended_columns_string_source`(
	in_columns TEXT, 
	valid_from CHAR(20), 
	valid_to CHAR(20)
) RETURNS text CHARSET utf8
begin
	DECLARE out_columns TEXT DEFAULT '';

	-- Concatenate strings	
	SET @out_columns = CONCAT(in_columns, ', ', IFNULL(valid_from, '`ins_dt`') ,', "', IFNULL(valid_to, '2999-12-31') ,'"');
	
	RETURN @out_columns;
end;;
DELIMITER ;