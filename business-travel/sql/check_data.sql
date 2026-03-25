SET search_path TO business_travel;

SELECT 'company' AS table_name, COUNT(*) AS row_count FROM company
UNION ALL
SELECT 'city', COUNT(*) FROM city
UNION ALL
SELECT 'airline', COUNT(*) FROM airline
UNION ALL
SELECT 'branch', COUNT(*) FROM branch
UNION ALL
SELECT 'employee', COUNT(*) FROM employee
UNION ALL
SELECT 'hotel', COUNT(*) FROM hotel
UNION ALL
SELECT 'flight', COUNT(*) FROM flight
UNION ALL
SELECT 'trip', COUNT(*) FROM trip
UNION ALL
SELECT 'hotel_booking', COUNT(*) FROM hotel_booking
UNION ALL
SELECT 'flight_booking', COUNT(*) FROM flight_booking
ORDER BY row_count;
