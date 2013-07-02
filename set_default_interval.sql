------------------------------------
----- PACKAGE FOR HISTORIZATION
------------------------------------

DELIMITER ;;
CREATE DEFINER=`hqlive`@`%` PROCEDURE `set_default_interval`(in_database_name CHAR(50))
begin

	insert IGNORE into hqlive.hist_interval (`table_name`, `interval`, ins_dt, ins_process_id)
	select
		tables.table_name,
		10 AS `interval`,
		NOW() AS ins_dt,
		'default-insert' AS ins_process_id
	from information_schema.tables
	left join hqlive.hist_table_exclusion ON hqlive.hist_table_exclusion.table_name = tables.table_name
	  and hist_table_exclusion.`excluded_flag` = 1
	where table_schema = in_database_name
	and hqlive.hist_table_exclusion.id is null
	order by tables.table_name
	;
	
end;;
DELIMITER ;
