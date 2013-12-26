-- -----------------------------------
-- --- TABLE: HISTORY SQL
-- -----------------------------------

CREATE TABLE IF NOT EXISTS `hist_sql` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sql` text NOT NULL,
  `job_code` varchar(35) DEFAULT NULL,
  `ins_dt` datetime NOT NULL,
  `ins_user_id` int(11) NOT NULL DEFAULT '-1',
  `ins_process_id` varchar(255) DEFAULT NULL,
  `upd_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `upd_user_id` int(11) NOT NULL DEFAULT '-1',
  `upd_process_id` varchar(255) DEFAULT NULL,
  `del_flag` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ins_user_id` (`ins_user_id`),
  KEY `upd_user_id` (`upd_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
