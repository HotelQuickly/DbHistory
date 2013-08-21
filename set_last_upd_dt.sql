-- ----------------------------------
-- --- PACKAGE FOR HISTORIZATION
-- ----------------------------------

DROP PROCEDURE IF EXISTS `set_last_upd_dt`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `set_last_upd_dt`(in_database_name CHAR(50), in_tab_name CHAR(50))
begin
	DECLARE sql_text TEXT;

	-- Prepare SQL statement
	SET @sql_text = CONCAT('
		INSERT INTO `', in_database_name, '`.`hist_log` (`table_name`, `last_hist_dt`, `ins_dt`, `ins_process_id`)
		VALUES
		("', in_tab_name, '", NOW(), NOW(), "history-logger")
	');

	-- Call SQL statement
	PREPARE stmt_insert FROM @sql_text;
	EXECUTE stmt_insert;
	DEALLOCATE PREPARE stmt_insert;
end;;
DELIMITER ;
