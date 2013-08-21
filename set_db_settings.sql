-- --------------------------
-- --- SET DATABASE SETTINGS
-- --------------------------

DROP PROCEDURE IF EXISTS `set_db_settings`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `set_db_settings`()
begin

	SET SESSION tmp_table_size = 500000000;
	SET SESSION join_buffer_size = 1500000;
	
end;;
DELIMITER ;
