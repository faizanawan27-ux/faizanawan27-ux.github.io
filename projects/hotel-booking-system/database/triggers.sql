-- ============================================================
-- Business Rules
-- ============================================================

-- 1. Booking validation trigger: mark the room unavailable for the
--    check-in date as soon as a booking is created.
DELIMITER ;;
CREATE TRIGGER after_booking_insert
AFTER INSERT ON booking
FOR EACH ROW
BEGIN
  INSERT INTO room_avaiablity (booking_id, is_available, date)
  VALUES (NEW.booking_id, 0, NEW.check_in_date);
END;;
DELIMITER ;

-- 2. Prevent double booking: implemented at the application level
--    (see BookingController::store) by checking for overlapping
--    bookings on the same room before insert.

-- 3. Review validation: only allow a review after the user has
--    actually completed a stay in that room.
DELIMITER ;;
CREATE TRIGGER before_review_insert
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
  DECLARE stay_completed INT;
  SELECT COUNT(*) INTO stay_completed
  FROM booking b
  WHERE b.user_id = NEW.user_id
    AND b.room_id = NEW.room_id
    AND b.check_out_date < CURDATE();
  IF stay_completed = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'User must have completed a stay to review this room';
  END IF;
END;;
DELIMITER ;
