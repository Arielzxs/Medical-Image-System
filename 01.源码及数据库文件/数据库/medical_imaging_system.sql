/*
 Navicat Premium Dump SQL

 Source Server         : My_database
 Source Server Type    : MySQL
 Source Server Version : 80406 (8.4.6)
 Source Host           : localhost:3306
 Source Schema         : medical_imaging_system

 Target Server Type    : MySQL
 Target Server Version : 80406 (8.4.6)
 File Encoding         : 65001

 Date: 10/09/2025 10:29:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for appointment
-- ----------------------------
DROP TABLE IF EXISTS `appointment`;
CREATE TABLE `appointment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `patient_id` bigint NOT NULL COMMENT '患者id',
  `patient_id_card` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '患者身份证',
  `patient_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '患者姓名',
  `appointment_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '预约类型',
  `appointment_content` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '预约内容',
  `appointment_date` date DEFAULT NULL COMMENT '预约日期',
  `start_time` time DEFAULT NULL COMMENT '预约起始时间',
  `end_time` time DEFAULT NULL COMMENT '预约结束时间',
  `submission_time` datetime DEFAULT NULL COMMENT '提交时间',
  `check_in_time` datetime DEFAULT NULL COMMENT '报道时间',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '预约记录状态',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of appointment
-- ----------------------------
BEGIN;
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (22, 3, '873847747747479294', 'Bob', 'CT', '胸部CT', '2025-09-09', '09:00:00', NULL, '2025-09-08 09:14:33', NULL, 'EXPIRED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (23, 3, '873847747747479294', 'Bob', 'X光', '腿部X光', '2025-09-08', '09:00:00', NULL, '2025-09-08 09:15:11', '2025-09-08 09:15:43', 'CANCELED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (24, 3, '873847747747479294', 'Bob', '头部CT', '头部CT', '2025-09-09', '09:00:00', NULL, '2025-09-08 09:20:02', NULL, 'CANCELED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (27, 3, '873847747747479294', 'Bob', '核磁共振', '核磁共振', '2025-09-08', '10:00:00', NULL, '2025-09-08 10:01:53', '2025-09-08 10:07:19', 'COMPLETED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (28, 3, '873847747747479294', 'Bob', 'X光', 'X光', '2025-09-08', '10:00:00', NULL, '2025-09-08 10:05:25', NULL, 'CANCELED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (29, 3, '873847747747479294', 'Bob', '核磁共振', '手部核磁共振', '2025-09-08', '10:00:00', NULL, '2025-09-08 10:06:48', '2025-09-08 10:12:26', 'COMPLETED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (30, 3, '873847747747479294', 'Bob', '腰部CT', '腰部CT', '2025-09-08', '10:00:00', NULL, '2025-09-08 10:11:04', NULL, 'EXPIRED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (31, 3, '873847747747479294', 'Bob', 'CT', '头部ct', '2025-09-08', '11:30:00', NULL, '2025-09-08 11:27:39', '2025-09-08 11:28:38', 'CANCELED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (32, 2, '370523200907124672', 'Jimy', 'CT', '手部ct', '2025-09-08', '12:00:00', NULL, '2025-09-08 12:11:24', '2025-09-08 12:11:41', 'COMPLETED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (33, 2, '370523200907124672', 'Jimy', 'X光', '头部X光', '2025-09-08', '12:00:00', NULL, '2025-09-08 12:26:34', '2025-09-08 12:27:05', 'COMPLETED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (34, 3, '873847747747479294', 'Bob', 'CT', '胸部CT预约', '2025-09-09', '09:30:00', NULL, '2025-09-08 21:17:43', NULL, 'EXPIRED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (35, 3, '873847747747479294', 'Bob', 'CT', '头部CT', '2025-09-09', '11:00:00', NULL, '2025-09-09 11:18:49', '2025-09-09 11:20:42', 'IN_PROGRESS');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (36, 3, '873847747747479294', 'Bob', 'CT', '头部CT', '2025-09-10', '09:00:00', NULL, '2025-09-09 20:07:03', NULL, 'EXPIRED');
INSERT INTO `appointment` (`id`, `patient_id`, `patient_id_card`, `patient_name`, `appointment_type`, `appointment_content`, `appointment_date`, `start_time`, `end_time`, `submission_time`, `check_in_time`, `status`) VALUES (37, 2, '370523200907124672', 'Jimy', 'CT', '头部ct', '2025-09-10', '12:30:00', NULL, '2025-09-09 20:12:50', NULL, 'CANCELED');
COMMIT;

-- ----------------------------
-- Table structure for image
-- ----------------------------
DROP TABLE IF EXISTS `image`;
CREATE TABLE `image` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '影像ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID，对应user表',
  `modality` varchar(50) NOT NULL COMMENT '影像类型（CT、MRI等）',
  `file_path` varchar(500) NOT NULL COMMENT '影像文件存储路径',
  `tags` varchar(255) DEFAULT NULL COMMENT '影像标签',
  `uploaded_by` bigint NOT NULL COMMENT '上传者ID，对应user表',
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  KEY `uploaded_by` (`uploaded_by`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='医学影像表';

-- ----------------------------
-- Records of image
-- ----------------------------
BEGIN;
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (3, 3, 'CT', '/image/20250826/1d637cc052cc463286050c27d7a7f2ed.jpg', '脑瘤中期检查', 1, '2025-08-26 11:17:08');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (4, 3, 'X-ray', '/image/20250826/2972262a1b54457cb422aedd95ebc684.jpg', '脑瘤', 2, '2025-08-26 14:54:50');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (7, 2, 'X-ray', '/image/20250827/aa96f21c102d49beb2a037f03a28bf4f.jpg', '脑瘤治疗后影像', 1, '2025-08-27 11:55:34');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (8, 3, 'MRI', '/image/20250828/32200b4284e14fb896554b7871e8e6b6.jpg', '脑瘤MRI影像', 1, '2025-08-28 16:14:39');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (9, 1, 'CT', '/image/20250829/dae1beaad049449d9699003eccc4addf.jpg', '无症状', 1, '2025-08-29 10:02:02');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (25, 3, 'CT', '/image/20250902/82fe779cb8c64acfa2bba6bc56e4e8e9.jpeg', NULL, 2, '2025-09-02 19:45:39');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (27, 6, 'X-ray', '/image/20250904/59857cdd91874df3826bc7ee735f86b5.jpg', '', 1, '2025-09-04 14:22:03');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (28, 5, 'CT', '/image/20250904/97fdbe4bc49d4068810383105807b204.jpg', '', 1, '2025-09-04 16:17:04');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (29, 6, 'CT', '/image/20250904/be557f502ccb4d94af7b6b014c22cdb6.jpeg', NULL, 3, '2025-09-04 16:38:33');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (30, 5, 'CT', '/image/20250904/e0f708c1ac4a4fc9980471849f7a4bf5.jpg', '', 1, '2025-09-04 18:35:07');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (31, 4, 'X-ray', '/image/20250905/c54158a282ec464c90f84f462fdde3a0.jpg', '', 2, '2025-09-05 17:02:20');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (33, 3, 'X-ray', '/image/20250906/dc73d050324448c4a1f7e9239fec0581.jpg', '', 1, '2025-09-06 13:42:26');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (34, 3, 'CT', '/image/20250908/f438533af8b846e98ad76468c315ea92.jpg', '头部CT', 1, '2025-09-08 21:30:12');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (35, 3, 'X-ray', '/image/20250909/a3d246ab3e6e402ea42bcafa2f3bfabf.jpg', '胸部X光片', 3, '2025-09-09 20:07:55');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (36, 3, 'CT', '/image/20250909/fb4c909182c44f0e9eaceed020770106.jpeg', '胸部ct', 2, '2025-09-09 20:13:49');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (37, 3, 'CT', '/image/20250910/95b4d5caa3d04752b63c35ebd682a269.jpeg', '胸部ct', 2, '2025-09-10 10:01:49');
INSERT INTO `image` (`id`, `patient_id`, `modality`, `file_path`, `tags`, `uploaded_by`, `uploaded_at`) VALUES (38, 3, 'X-ray', '/image/20250910/bd69ca6ab46447dcba67545e4a97222a.jpg', '头部CT', 2, '2025-09-10 10:06:59');
COMMIT;

-- ----------------------------
-- Table structure for image_share
-- ----------------------------
DROP TABLE IF EXISTS `image_share`;
CREATE TABLE `image_share` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分享记录ID',
  `image_id` bigint NOT NULL COMMENT '影像ID',
  `shared_to` bigint NOT NULL COMMENT '接收用户ID',
  `shared_by` bigint NOT NULL COMMENT '分享发起用户ID',
  `shared_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '分享时间',
  PRIMARY KEY (`id`),
  KEY `image_id` (`image_id`),
  KEY `shared_to` (`shared_to`),
  KEY `shared_by` (`shared_by`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='影像分享表';

-- ----------------------------
-- Records of image_share
-- ----------------------------
BEGIN;
INSERT INTO `image_share` (`id`, `image_id`, `shared_to`, `shared_by`, `shared_at`) VALUES (1, 1, 2, 1, '2025-08-22 20:12:25');
INSERT INTO `image_share` (`id`, `image_id`, `shared_to`, `shared_by`, `shared_at`) VALUES (2, 2, 2, 1, '2025-08-28 10:01:50');
INSERT INTO `image_share` (`id`, `image_id`, `shared_to`, `shared_by`, `shared_at`) VALUES (3, 3, 3, 1, '2025-09-04 13:55:56');
COMMIT;

-- ----------------------------
-- Table structure for message
-- ----------------------------
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sender_id` bigint NOT NULL,
  `recipient_id` bigint NOT NULL,
  `content` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `is_read` int DEFAULT NULL,
  `image_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=210 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of message
-- ----------------------------
BEGIN;
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (195, 2, 1, '你好', 'text', '2025-09-05 17:20:57', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (197, 7, 3, '你好', 'text', '2025-09-06 11:16:22', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (198, 3, 7, '你好', 'text', '2025-09-06 11:23:50', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (199, 3, 7, '你是？', 'text', '2025-09-06 11:32:09', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (200, 7, 3, '我是Tom', 'text', '2025-09-06 11:36:30', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (201, 3, 7, '哦哦', 'text', '2025-09-06 11:40:16', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (202, 7, 3, '有什么事么', 'text', '2025-09-06 11:40:41', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (203, 3, 7, '没有没有', 'text', '2025-09-06 13:39:43', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (204, 1, 2, '你好', 'text', '2025-09-06 13:43:42', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (205, 3, 7, '你好', 'text', '2025-09-07 23:38:44', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (206, 2, 1, '向您发送了一张影像', 'share', '2025-09-09 17:17:49', 0, 7);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (207, 3, 2, '你好', 'text', '2025-09-09 20:09:35', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (208, 3, 1, '你好', 'text', '2025-09-09 20:09:49', 0, NULL);
INSERT INTO `message` (`id`, `sender_id`, `recipient_id`, `content`, `type`, `created_at`, `is_read`, `image_id`) VALUES (209, 2, 1, '你好', 'text', '2025-09-10 10:08:20', 0, NULL);
COMMIT;

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `user_id` bigint NOT NULL COMMENT '接收通知的用户ID',
  `message` varchar(500) NOT NULL COMMENT '通知内容',
  `is_read` tinyint(1) DEFAULT '0' COMMENT '是否已读',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '通知时间',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统通知表';

-- ----------------------------
-- Records of notification
-- ----------------------------
BEGIN;
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (1, 1, '你好', 1, '2025-08-25 13:54:34');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (2, 3, '您有一条来自 Tom 的新消息', 1, '2025-09-06 10:41:15');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (3, 3, '您有一条来自 Tom 的新消息', 1, '2025-09-06 11:16:22');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (4, 7, '您有一条来自 Bob 的新消息', 1, '2025-09-06 11:23:50');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (5, 7, '您有一条来自 Bob 的新消息', 1, '2025-09-06 11:32:09');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (6, 3, '您有一条来自 Tom 的新消息', 1, '2025-09-06 11:36:30');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (7, 7, '您有一条来自 Bob 的新消息', 1, '2025-09-06 11:40:16');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (8, 3, '您有一条来自 Tom 的新消息', 1, '2025-09-06 11:40:41');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (9, 7, '您有一条来自 Bob 的新消息', 1, '2025-09-06 13:39:43');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (10, 2, '您有一条来自 lucy 的新消息', 1, '2025-09-06 13:43:42');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (11, 7, '您有一条来自 Bob 的新消息', 0, '2025-09-07 23:38:44');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (12, 1, '您有一条来自 Jimy 的新消息', 1, '2025-09-09 17:17:49');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (13, 2, '您有一条来自 Bob 的新消息', 1, '2025-09-09 20:09:35');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (14, 1, '您有一条来自 Bob 的新消息', 1, '2025-09-09 20:09:49');
INSERT INTO `notification` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES (15, 1, '您有一条来自 Jimy 的新消息', 0, '2025-09-10 10:08:20');
COMMIT;

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` bigint NOT NULL COMMENT '操作用户ID',
  `operation` varchar(255) NOT NULL COMMENT '操作描述',
  `ip_address` varchar(50) DEFAULT NULL COMMENT 'IP地址',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作日志表';

-- ----------------------------
-- Records of operation_log
-- ----------------------------
BEGIN;
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (22, 1, '创建一张报告', '0:0:0:0:0:0:0:1', '2025-08-28 19:26:05');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (23, 1, '删除一张报告', '0:0:0:0:0:0:0:1', '2025-08-28 19:30:29');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (24, 1, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-08-29 10:02:02');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (25, 3, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-08-30 11:43:18');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (26, 3, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-08-30 11:47:55');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (27, 3, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-08-30 14:14:01');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (28, 3, '上传了一张影像', '192.168.100.105', '2025-08-30 15:12:41');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (29, 3, '上传了一张影像', '192.168.100.105', '2025-08-30 15:13:38');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (30, 3, '上传了一张影像', '192.168.100.105', '2025-08-30 15:26:01');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (31, 3, '上传了一张影像', '192.168.100.105', '2025-08-30 15:48:52');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (32, 3, '更新了用户信息', '192.168.100.105', '2025-09-01 10:05:39');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (33, 3, '更新了用户信息', '192.168.100.105', '2025-09-01 10:23:50');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (34, 3, '更新了用户信息', '192.168.100.105', '2025-09-01 10:25:20');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (35, 3, '更新了用户信息', '192.168.100.105', '2025-09-01 10:25:30');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (36, 1, '添加了一个用户', '192.168.100.105', '2025-09-01 14:59:52');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (37, 1, '添加了一个用户', '192.168.100.105', '2025-09-01 15:03:08');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (38, 1, '添加了一个用户', '192.168.100.105', '2025-09-01 15:09:27');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (39, 1, '删除了一个用户', '192.168.100.105', '2025-09-01 16:09:59');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (40, 1, '更新了一个用户信息', '192.168.100.105', '2025-09-01 17:07:52');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (41, 1, '更新了一个用户信息', '192.168.100.105', '2025-09-01 19:03:52');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (42, 2, '创建一张报告', '192.168.100.105', '2025-09-02 10:01:59');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (43, 2, '更新一张报告', '192.168.100.105', '2025-09-02 14:21:14');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (44, 2, '删除一张报告', '192.168.100.105', '2025-09-02 14:21:56');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (46, 2, '更新了用户信息', '192.168.100.105', '2025-09-02 19:43:45');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (47, 2, '上传了一张影像', '192.168.100.105', '2025-09-02 19:45:39');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (48, 2, '更新了用户信息', '192.168.100.105', '2025-09-02 19:59:02');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (49, 2, '上传了一张影像', '192.168.100.105', '2025-09-02 20:43:21');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (50, 1, '更新了一个用户信息', '192.168.100.105', '2025-09-02 21:47:54');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (51, 1, '更新了一个用户信息', '192.168.100.105', '2025-09-02 21:57:12');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (52, 2, '更新了用户信息', '192.168.100.105', '2025-09-03 20:06:14');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (53, 1, '分享了一张影像', '0:0:0:0:0:0:0:1', '2025-09-04 13:55:56');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (55, 1, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-04 14:14:34');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (56, 1, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-04 14:15:39');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (57, 1, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-04 14:17:34');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (58, 1, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-04 14:18:15');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (59, 1, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-04 14:22:03');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (63, 1, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-04 16:17:04');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (64, 1, '创建一张报告', '0:0:0:0:0:0:0:1', '2025-09-04 16:18:29');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (66, 1, '更新了用户信息', '0:0:0:0:0:0:0:1', '2025-09-04 16:19:44');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (67, 1, '更新了一个用户信息', '192.168.100.105', '2025-09-04 16:37:42');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (68, 3, '上传了一张影像', '192.168.100.105', '2025-09-04 16:38:33');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (69, 1, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-04 18:35:07');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (70, 1, '创建一张报告', '0:0:0:0:0:0:0:1', '2025-09-04 18:35:27');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (71, 1, '删除一张报告', '0:0:0:0:0:0:0:1', '2025-09-04 18:35:38');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (73, 1, '更新了用户信息', '0:0:0:0:0:0:0:1', '2025-09-04 18:36:02');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (74, 1, '更新了用户信息', '0:0:0:0:0:0:0:1', '2025-09-05 11:19:55');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (75, 1, '更新了用户信息', '0:0:0:0:0:0:0:1', '2025-09-05 11:20:00');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (76, 2, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-05 17:02:20');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (77, 3, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-06 13:38:49');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (78, 7, '删除了一张影像', '0:0:0:0:0:0:0:1', '2025-09-06 13:40:12');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (79, 7, '删除了一张影像', '0:0:0:0:0:0:0:1', '2025-09-06 13:40:14');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (80, 3, '更新了用户信息', '0:0:0:0:0:0:0:1', '2025-09-06 13:40:40');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (81, 1, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-06 13:42:26');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (82, 1, '创建一张报告', '0:0:0:0:0:0:0:1', '2025-09-06 13:43:18');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (85, 4, '创建一张报告', '192.168.100.105', '2025-09-06 14:13:18');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (86, 2, '删除一张报告', '0:0:0:0:0:0:0:1', '2025-09-06 14:27:06');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (87, 2, '删除一张报告', '192.168.100.105', '2025-09-06 14:31:54');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (88, 1, '更新了一个用户信息', '192.168.100.105', '2025-09-07 21:41:01');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (89, 1, '更新了一个用户信息', '0:0:0:0:0:0:0:1', '2025-09-08 10:14:29');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (90, 1, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-08 21:30:12');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (91, 1, '创建一张报告', '0:0:0:0:0:0:0:1', '2025-09-08 21:57:09');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (92, 3, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-09 20:07:55');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (93, 1, '创建一张报告', '0:0:0:0:0:0:0:1', '2025-09-09 20:08:50');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (94, 1, '更新一张报告', '0:0:0:0:0:0:0:1', '2025-09-09 20:09:10');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (95, 1, '删除一张报告', '0:0:0:0:0:0:0:1', '2025-09-09 20:09:16');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (96, 3, '更新了用户信息', '0:0:0:0:0:0:0:1', '2025-09-09 20:10:49');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (97, 2, '更新了用户信息', '192.168.100.105', '2025-09-09 20:11:55');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (98, 2, '上传了一张影像', '192.168.100.105', '2025-09-09 20:13:49');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (99, 2, '创建一张报告', '192.168.100.105', '2025-09-09 20:14:20');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (100, 1, '更新了一个用户信息', '192.168.100.105', '2025-09-09 20:15:11');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (101, 2, '上传了一张影像', '172.20.10.5', '2025-09-10 10:01:49');
INSERT INTO `operation_log` (`id`, `user_id`, `operation`, `ip_address`, `created_at`) VALUES (102, 2, '上传了一张影像', '0:0:0:0:0:0:0:1', '2025-09-10 10:06:59');
COMMIT;

-- ----------------------------
-- Table structure for report
-- ----------------------------
DROP TABLE IF EXISTS `report`;
CREATE TABLE `report` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '报告ID',
  `image_id` bigint NOT NULL COMMENT '关联影像ID',
  `diagnosis` text COMMENT '诊断结论',
  `suggestion` text COMMENT '建议',
  `content` text COMMENT '详细报告内容',
  `generated_by` bigint NOT NULL COMMENT '报告生成医生ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
  PRIMARY KEY (`id`),
  KEY `image_id` (`image_id`),
  KEY `generated_by` (`generated_by`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='医学报告表';

-- ----------------------------
-- Records of report
-- ----------------------------
BEGIN;
INSERT INTO `report` (`id`, `image_id`, `diagnosis`, `suggestion`, `content`, `generated_by`, `created_at`) VALUES (1, 1, '正常', '按时休息就好, 多喝水', '一切正常', 1, '2025-08-22 19:45:40');
INSERT INTO `report` (`id`, `image_id`, `diagnosis`, `suggestion`, `content`, `generated_by`, `created_at`) VALUES (2, 2, '肿瘤已经开始扩散', '尽快手术', '无', 2, '2025-08-25 15:24:18');
INSERT INTO `report` (`id`, `image_id`, `diagnosis`, `suggestion`, `content`, `generated_by`, `created_at`) VALUES (3, 2, '早期肿瘤', '尽快手术', '无', 2, '2025-08-26 10:24:24');
INSERT INTO `report` (`id`, `image_id`, `diagnosis`, `suggestion`, `content`, `generated_by`, `created_at`) VALUES (13, 3, '脑瘤未明显扩散', '继续服用药物', '暂无', 1, '2025-09-08 21:57:09');
INSERT INTO `report` (`id`, `image_id`, `diagnosis`, `suggestion`, `content`, `generated_by`, `created_at`) VALUES (15, 36, '无', '无', '无', 1, '2025-09-09 20:14:20');
COMMIT;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `id_card` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '身份证号',
  `age` int NOT NULL COMMENT '年龄',
  `gender` int NOT NULL COMMENT '性别（0表示男，1表示女）',
  `phone` varchar(255) NOT NULL COMMENT '手机号',
  `birth_date` timestamp NULL DEFAULT NULL COMMENT '出生日期',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '住址',
  `password` varchar(255) NOT NULL COMMENT '密码（加密存储）',
  `role` enum('doctor','patient','admin','expert') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'patient' COMMENT '身份',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';

-- ----------------------------
-- Records of user
-- ----------------------------
BEGIN;
INSERT INTO `user` (`id`, `username`, `id_card`, `age`, `gender`, `phone`, `birth_date`, `address`, `password`, `role`, `created_at`, `updated_at`) VALUES (1, 'lucy', '123456789012345678', 33, 1, '18383748848', '2004-08-27 00:00:00', '秦皇岛市海港区燕山大学西校区', '12345678', 'admin', '2025-08-19 20:04:18', '2025-09-05 11:20:00');
INSERT INTO `user` (`id`, `username`, `id_card`, `age`, `gender`, `phone`, `birth_date`, `address`, `password`, `role`, `created_at`, `updated_at`) VALUES (2, 'Jimy', '370523200907124672', 21, 0, '13847394859', '2005-08-30 00:00:00', NULL, '123456789', 'doctor', '2025-08-22 20:10:46', '2025-09-09 20:11:55');
INSERT INTO `user` (`id`, `username`, `id_card`, `age`, `gender`, `phone`, `birth_date`, `address`, `password`, `role`, `created_at`, `updated_at`) VALUES (3, 'Bob', '873847747747479294', 20, 0, '17839478592', '2005-05-27 00:00:00', '天津市滨海新区', '12345678', 'patient', '2025-08-26 09:12:04', '2025-09-09 20:10:49');
INSERT INTO `user` (`id`, `username`, `id_card`, `age`, `gender`, `phone`, `birth_date`, `address`, `password`, `role`, `created_at`, `updated_at`) VALUES (4, 'Mike', '839748388498374894', 40, 1, '18374788489', '2008-09-17 00:00:00', '北京市', '12345678', 'expert', '2025-08-27 17:17:53', '2025-09-06 13:44:16');
INSERT INTO `user` (`id`, `username`, `id_card`, `age`, `gender`, `phone`, `birth_date`, `address`, `password`, `role`, `created_at`, `updated_at`) VALUES (5, 'Tim', '838483829374930281', 21, 1, '17283748371', '2005-08-29 00:00:00', '北京市', '12345678', 'patient', '2025-08-29 20:18:32', '2025-09-02 21:47:54');
INSERT INTO `user` (`id`, `username`, `id_card`, `age`, `gender`, `phone`, `birth_date`, `address`, `password`, `role`, `created_at`, `updated_at`) VALUES (6, 'Kerson', '283848399293849384', 11, 0, '12345678900', '2011-08-29 00:00:00', '北京', '12345678', 'patient', '2025-08-29 20:38:04', '2025-09-08 10:14:29');
INSERT INTO `user` (`id`, `username`, `id_card`, `age`, `gender`, `phone`, `birth_date`, `address`, `password`, `role`, `created_at`, `updated_at`) VALUES (7, 'Tom', '273849388475893874', 23, 0, '13358965894', '1999-08-31 00:00:00', '滨海新区', '12345678', 'doctor', '2025-08-31 22:11:16', '2025-09-09 20:15:11');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
