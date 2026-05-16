SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 用户ID迁移：把旧自增ID统一迁移为12位后台用户ID。
-- 如果库里已经完成迁移，这些 UPDATE 不会再次命中。
UPDATE `sys_user` SET `id` = `id` + 200000000000 WHERE `id` > 0 AND `id` < 200000000000;
UPDATE `sys_user_post` SET `user_id` = `user_id` + 200000000000 WHERE `user_id` > 0 AND `user_id` < 200000000000;
UPDATE `sys_config` SET `create_by` = `create_by` + 200000000000 WHERE `create_by` > 0 AND `create_by` < 200000000000;
UPDATE `sys_config` SET `update_by` = `update_by` + 200000000000 WHERE `update_by` > 0 AND `update_by` < 200000000000;
UPDATE `sys_dict_data` SET `create_by` = `create_by` + 200000000000 WHERE `create_by` > 0 AND `create_by` < 200000000000;
UPDATE `sys_dict_data` SET `update_by` = `update_by` + 200000000000 WHERE `update_by` > 0 AND `update_by` < 200000000000;
UPDATE `sys_dict_type` SET `create_by` = `create_by` + 200000000000 WHERE `create_by` > 0 AND `create_by` < 200000000000;
UPDATE `sys_dict_type` SET `update_by` = `update_by` + 200000000000 WHERE `update_by` > 0 AND `update_by` < 200000000000;
UPDATE `sys_post` SET `created_by` = `created_by` + 200000000000 WHERE `created_by` > 0 AND `created_by` < 200000000000;
UPDATE `sys_post` SET `updated_by` = `updated_by` + 200000000000 WHERE `updated_by` > 0 AND `updated_by` < 200000000000;
UPDATE `casbin_rule` SET `v0` = 'u_200000000003' WHERE `ptype` = 'g' AND `v0` = 'u_3';
UPDATE `casbin_rule` SET `v0` = 'u_200000000031' WHERE `ptype` = 'g' AND `v0` = 'u_31';

ALTER TABLE `sys_user` MODIFY COLUMN `id` bigint(20) UNSIGNED NOT NULL;

SET @sql = IF(
  (SELECT COUNT(*) FROM `information_schema`.`columns` WHERE `table_schema` = DATABASE() AND `table_name` = 'sys_user' AND `column_name` = 'google_secret') = 0,
  'ALTER TABLE `sys_user` ADD COLUMN `google_secret` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '''' COMMENT ''Google验证码密钥'' AFTER `user_email`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM `information_schema`.`columns` WHERE `table_schema` = DATABASE() AND `table_name` = 'sys_user' AND `column_name` = 'google_status') = 0,
  'ALTER TABLE `sys_user` ADD COLUMN `google_status` tinyint(1) NOT NULL DEFAULT 0 COMMENT ''Google验证码状态;0未绑定 1已绑定'' AFTER `google_secret`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

ALTER TABLE `sys_config`
  MODIFY COLUMN `create_by` bigint(20) UNSIGNED NULL DEFAULT 0 COMMENT '创建者',
  MODIFY COLUMN `update_by` bigint(20) UNSIGNED NULL DEFAULT 0 COMMENT '更新者';

SET @sql = IF(
  (SELECT COUNT(*) FROM `information_schema`.`columns` WHERE `table_schema` = DATABASE() AND `table_name` = 'sys_config' AND `column_name` = 'config_value_type') = 0,
  'ALTER TABLE `sys_config` ADD COLUMN `config_value_type` tinyint(1) NOT NULL DEFAULT 1 COMMENT ''参数值类型：1文本 2开关 3上传 4下拉 5数字'' AFTER `config_type`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM `information_schema`.`columns` WHERE `table_schema` = DATABASE() AND `table_name` = 'sys_config' AND `column_name` = 'config_options') = 0,
  'ALTER TABLE `sys_config` ADD COLUMN `config_options` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT ''参数扩展配置'' AFTER `config_value_type`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

ALTER TABLE `sys_dict_data`
  MODIFY COLUMN `create_by` bigint(20) UNSIGNED NULL DEFAULT 0 COMMENT '创建者',
  MODIFY COLUMN `update_by` bigint(20) UNSIGNED NULL DEFAULT 0 COMMENT '更新者';

ALTER TABLE `sys_dict_type`
  MODIFY COLUMN `create_by` bigint(20) UNSIGNED NULL DEFAULT 0 COMMENT '创建者',
  MODIFY COLUMN `update_by` bigint(20) UNSIGNED NULL DEFAULT 0 COMMENT '更新者';

CREATE TABLE IF NOT EXISTS `notice_message` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '通知ID',
  `title` VARCHAR(128) NOT NULL DEFAULT '' COMMENT '通知标题',
  `content` TEXT NULL COMMENT '通知内容',
  `notice_type` VARCHAR(32) NOT NULL DEFAULT 'system' COMMENT '通知类型',
  `target_type` VARCHAR(32) NOT NULL DEFAULT 'user' COMMENT '目标类型',
  `target_value` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '目标值',
  `link_url` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '跳转地址',
  `payload_json` JSON NULL COMMENT '扩展数据JSON',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态',
  `created_at` DATETIME NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_notice_message_type` (`notice_type`, `created_at`),
  KEY `idx_notice_message_target` (`target_type`, `target_value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知消息表';

CREATE TABLE IF NOT EXISTS `notice_user` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '用户通知ID',
  `notice_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '通知ID',
  `user_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '用户ID',
  `read_status` TINYINT NOT NULL DEFAULT 0 COMMENT '读取状态',
  `read_at` DATETIME NULL DEFAULT NULL COMMENT '读取时间',
  `deleted_at` DATETIME NULL DEFAULT NULL COMMENT '删除时间',
  `created_at` DATETIME NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_notice_user` (`user_id`, `read_status`, `created_at`),
  KEY `idx_notice_user_notice` (`notice_id`),
  KEY `idx_notice_user_deleted` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户通知状态表';

INSERT INTO `sys_auth_rule` (`id`,`pid`,`name`,`title`,`icon`,`condition`,`remark`,`menu_type`,`weigh`,`is_hide`,`path`,`component`,`is_link`,`module_type`,`model_id`,`is_iframe`,`is_cached`,`redirect`,`is_affix`,`link_url`,`created_at`,`updated_at`)
SELECT 1040, 0, 'api/v1/system/notice', '通知中心', 'ele-Bell', 'nocheck', '', 0, 70, 0, '/system/notice', 'layout/routerView/parent', 0, '', 0, 0, 1, '/system/notice/list', 0, '', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM `sys_auth_rule` WHERE `id` = 1040 OR `name` = 'api/v1/system/notice');

INSERT INTO `sys_auth_rule` (`id`,`pid`,`name`,`title`,`icon`,`condition`,`remark`,`menu_type`,`weigh`,`is_hide`,`path`,`component`,`is_link`,`module_type`,`model_id`,`is_iframe`,`is_cached`,`redirect`,`is_affix`,`link_url`,`created_at`,`updated_at`)
SELECT 1041, 1040, 'api/v1/system/notice/list', '通知管理', 'ele-Message', 'nocheck', '', 1, 0, 0, '/system/notice/list', 'system/notice/index', 0, '', 0, 0, 1, '', 0, '', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM `sys_auth_rule` WHERE `id` = 1041 OR `name` = 'api/v1/system/notice/list');

INSERT INTO `sys_auth_rule` (`id`,`pid`,`name`,`title`,`icon`,`condition`,`remark`,`menu_type`,`weigh`,`is_hide`,`path`,`component`,`is_link`,`module_type`,`model_id`,`is_iframe`,`is_cached`,`redirect`,`is_affix`,`link_url`,`created_at`,`updated_at`)
SELECT 1042, 1041, 'api/v1/system/notice/send', '发送通知', '', 'nocheck', '', 2, 0, 0, '', '', 0, '', 0, 0, 1, '', 0, '', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM `sys_auth_rule` WHERE `id` = 1042 OR `name` = 'api/v1/system/notice/send');

INSERT INTO `sys_auth_rule` (`id`,`pid`,`name`,`title`,`icon`,`condition`,`remark`,`menu_type`,`weigh`,`is_hide`,`path`,`component`,`is_link`,`module_type`,`model_id`,`is_iframe`,`is_cached`,`redirect`,`is_affix`,`link_url`,`created_at`,`updated_at`)
SELECT 1043, 1041, 'api/v1/system/notice/delete', '删除通知', '', 'nocheck', '', 2, 0, 0, '', '', 0, '', 0, 0, 1, '', 0, '', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM `sys_auth_rule` WHERE `id` = 1043 OR `name` = 'api/v1/system/notice/delete');

INSERT INTO `sys_auth_rule` (`id`,`pid`,`name`,`title`,`icon`,`condition`,`remark`,`menu_type`,`weigh`,`is_hide`,`path`,`component`,`is_link`,`module_type`,`model_id`,`is_iframe`,`is_cached`,`redirect`,`is_affix`,`link_url`,`created_at`,`updated_at`)
SELECT 1044, 1041, 'api/v1/system/notice/user-list', '投递记录', '', 'nocheck', '', 2, 0, 0, '', '', 0, '', 0, 0, 1, '', 0, '', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM `sys_auth_rule` WHERE `id` = 1044 OR `name` = 'api/v1/system/notice/user-list');

SET FOREIGN_KEY_CHECKS = 1;
