-- -----------------------------------
-- --- TABLE: HISTORY ERROR
-- -----------------------------------

CREATE TABLE IF NOT EXISTS `hist_error` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sql` mediumtext DEFAULT NULL,
  `error_code` varchar(255) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `ins_dt` datetime NOT NULL,
  `ins_user_id` int(11) NOT NULL DEFAULT '-1',
  `ins_process_id` varchar(255) DEFAULT NULL,
  `upd_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `upd_user_id` int(11) NOT NULL DEFAULT '-1',
  `upd_process_id` varchar(255) DEFAULT NULL,
  `del_flag` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ins_user_id` (`ins_user_id`),
  KEY `upd_user_id` (`upd_user_id`),
  KEY `upd_dt` (`upd_dt`),
  CONSTRAINT `hist_error_ibfk_1` FOREIGN KEY (`ins_user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `hist_error_ibfk_2` FOREIGN KEY (`upd_user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
