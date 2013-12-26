-- -----------------------------------
-- --- TABLE: HISTORY TABLE EXLUSION
-- -----------------------------------

CREATE TABLE IF NOT EXISTS `hist_table_exclusion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(255) DEFAULT NULL,
  `excluded_flag` tinyint(4) NOT NULL DEFAULT '1',
  `ins_dt` datetime NOT NULL,
  `ins_user_id` int(11) NOT NULL DEFAULT '-1',
  `ins_process_id` varchar(255) DEFAULT NULL,
  `upd_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `upd_user_id` int(11) NOT NULL DEFAULT '-1',
  `upd_process_id` varchar(255) DEFAULT NULL,
  `del_flag` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `table_name` (`table_name`),
  KEY `ins_user_id` (`ins_user_id`),
  KEY `upd_user_id` (`upd_user_id`),
  KEY `upd_dt` (`upd_dt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
