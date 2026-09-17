-- 1. Get all available rooms for a date range
SELECT r.room_id, r.room_type, rt.description
FROM room r
JOIN roomtype rt ON r.roomtype_id = rt.roomtype_id
WHERE r.room_id NOT IN (
  SELECT b.room_id FROM booking b
  WHERE b.check_in_date <= '2025-06-30'
    AND b.check_out_date >= '2025-06-20'
)
AND r.status = 'Available';

-- 2. Get booking details with user information
SELECT b.booking_id, u.name, u.email, r.room_type,
       b.check_in_date, b.check_out_date, p.payment_status
FROM booking b
JOIN user u ON b.user_id = u.user_id
JOIN room r ON b.room_id = r.room_id
LEFT JOIN payment p ON b.booking_id = p.booking_id;

-- 3. Get average room ratings
SELECT r.room_id, r.room_type, AVG(rv.rating) as average_rating
FROM room r
LEFT JOIN review rv ON r.room_id = rv.room_id
GROUP BY r.room_id, r.room_type;
