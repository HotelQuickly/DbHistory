-- -----------------------------------
-- --- TABLE: HISTORY INTERVAL
-- -----------------------------------

CREATE TABLE IF NOT EXISTS `hist_interval` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(255) DEFAULT NULL,
  `interval` int(11) NOT NULL DEFAULT '-1',
  `approx_number_of_rows` int(11) DEFAULT NULL,
  `ins_dt` datetime NOT NULL,
  `ins_user_id` int(11) NOT NULL DEFAULT '-1',
  `ins_process_id` varchar(255) DEFAULT NULL,
  `upd_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `upd_user_id` int(11) NOT NULL DEFAULT '-1',
  `upd_process_id` varchar(255) DEFAULT NULL,
  `del_flag` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `AK_HIST_INTERVAL` (`table_name`),
  KEY `ins_user_id` (`ins_user_id`),
  KEY `upd_user_id` (`upd_user_id`),
  KEY `upd_dt` (`upd_dt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
