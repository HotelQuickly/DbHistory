-- -----------------------------
-- --- GET TEMPORARY TABLE NAME
-- -----------------------------

DROP FUNCTION IF EXISTS `get_tmp_updates_table_name`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` FUNCTION `get_tmp_updates_table_name`() RETURNS text CHARSET utf8
begin	

	-- Just return the name
	RETURN 'xTMP_updated_rows';

end;;
DELIMITER ;
