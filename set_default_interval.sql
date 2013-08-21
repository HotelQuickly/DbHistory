-- -------------------------
-- --- SET DEFAULT INTERVAL
-- -------------------------

DROP PROCEDURE IF EXISTS `set_default_interval`;

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `set_default_interval`(in_database_name CHAR(50))
begin

	-- Insert to param.table default values
	INSERT IGNORE INTO hqlive.hist_interval (`table_name`, `interval`, ins_dt, ins_process_id)
	SELECT
		tables.table_name,
		10 AS `interval`,
		NOW() AS ins_dt,
		'default-insert' AS ins_process_id
	FROM information_schema.tables
	LEFT JOIN hqlive.hist_table_exclusion ON hqlive.hist_table_exclusion.table_name = tables.table_name
		AND hist_table_exclusion.`excluded_flag` = 1
	WHERE 1=1
		AND table_schema = in_database_name
		AND hqlive.hist_table_exclusion.id is null
	ORDER BY tables.table_name
	;
	
end;;
DELIMITER ;
