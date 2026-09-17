-- ============================================================
-- Hotel Booking System — Database Schema (3NF)
-- ============================================================

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(100) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
);

CREATE TABLE `roomtype` (
  `roomtype_id` int(11) NOT NULL,
  `capacity` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`roomtype_id`)
);

CREATE TABLE `room` (
  `room_id` int(11) NOT NULL,
  `room_type` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `roomtype_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`room_id`)
);

CREATE TABLE `booking` (
  `booking_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `room_id` int(11) DEFAULT NULL,
  `check_in_date` date DEFAULT NULL,
  `check_out_date` date DEFAULT NULL,
  PRIMARY KEY (`booking_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
);

CREATE TABLE `payment` (
  `payment_id` int(11) NOT NULL,
  `payment_status` varchar(20) DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `payment_date` date DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `fk_payment_booking` (`booking_id`),
  CONSTRAINT `fk_payment_booking` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`)
);

CREATE TABLE `booking_service` (
  `service_id` int(11) NOT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `service_name` varchar(100) DEFAULT NULL,
  `service_status` varchar(50) DEFAULT NULL,
  `service_date` date DEFAULT NULL,
  PRIMARY KEY (`service_id`),
  KEY `booking_id` (`booking_id`),
  CONSTRAINT `booking_service_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`)
);

CREATE TABLE `review` (
  `review_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `room_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `date` date DEFAULT NULL,
  PRIMARY KEY (`review_id`),
  KEY `user_id` (`user_id`),
  KEY `room_id` (`room_id`),
  CONSTRAINT `review_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `review_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`)
);

CREATE TABLE `room_avaiablity` (
  `booking_id` int(11) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT NULL,
  `date` date DEFAULT NULL,
  KEY `booking_id` (`booking_id`),
  CONSTRAINT `room_avaiablity_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`)
);

-- ============================================================
-- Enhancements (added in the final milestone)
-- ============================================================

ALTER TABLE booking
  ADD COLUMN `adults` INT NOT NULL DEFAULT 1 AFTER `check_out_date`,
  ADD COLUMN `children` INT NOT NULL DEFAULT 0 AFTER `adults`,
  ADD COLUMN `special_requests` TEXT NULL AFTER `children`,
  ADD COLUMN `booking_status` ENUM('pending', 'confirmed', 'cancelled', 'completed') NOT NULL DEFAULT 'pending' AFTER `special_requests`,
  ADD COLUMN `total_amount` DECIMAL(10,2) NOT NULL AFTER `booking_status`;

ALTER TABLE payment
  ADD COLUMN `amount` DECIMAL(10,2) NOT NULL AFTER `payment_status`,
  ADD COLUMN `payment_method` ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer') NOT NULL AFTER `amount`,
  ADD COLUMN `transaction_id` VARCHAR(100) NULL AFTER `payment_method`,
  ADD COLUMN `receipt_url` VARCHAR(255) NULL AFTER `transaction_id`;
