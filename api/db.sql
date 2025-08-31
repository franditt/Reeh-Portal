-- Producers Table
CREATE TABLE `producers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `google_uid` varchar(255) NOT NULL,
  `organization_name` varchar(255) DEFAULT NULL,
  `user_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `google_uid` (`google_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Streams Table
CREATE TABLE `streams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `producer_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `event_date` date DEFAULT NULL,
  `event_time` time DEFAULT NULL,
  `price` decimal(10,2) DEFAULT '0.00',
  `thumbnail_url` varchar(255) DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `producer_id` (`producer_id`),
  CONSTRAINT `streams_ibfk_1` FOREIGN KEY (`producer_id`) REFERENCES `producers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
