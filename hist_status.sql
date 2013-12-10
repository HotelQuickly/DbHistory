-- -----------------------------------
-- --- TABLE: HISTORY STATUS
-- -----------------------------------

CREATE TABLE `hist_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `active_flag` varchar(255) NOT NULL DEFAULT '',
  `ins_dt` datetime NOT NULL,
  `ins_user_id` int(11) NOT NULL DEFAULT '-1',
  `ins_process_id` varchar(255) DEFAULT NULL,
  `upd_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `upd_user_id` int(11) NOT NULL DEFAULT '-1',
  `upd_process_id` varchar(255) DEFAULT NULL,
  `del_flag` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

