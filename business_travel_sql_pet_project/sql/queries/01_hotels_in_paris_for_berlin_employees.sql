SET search_path TO business_travel;

SELECT DISTINCT
    h.hotel_id,
    h.hotel_name,
    h.address_line,
    h.nightly_rate
FROM business_travel.hotel_booking hb
JOIN business_travel.hotel h
    ON h.hotel_id = hb.hotel_id
JOIN business_travel.city hotel_city
    ON hotel_city.city_id = h.city_id
JOIN business_travel.trip t
    ON t.trip_id = hb.trip_id
JOIN business_travel.employee e
    ON e.employee_id = t.employee_id
JOIN business_travel.branch b
    ON b.branch_id = e.branch_id
JOIN business_travel.city branch_city
    ON branch_city.city_id = b.city_id
WHERE hotel_city.city_name = 'Paris'
  AND branch_city.city_name = 'Berlin'
  AND EXTRACT(YEAR FROM t.planned_start_date) = EXTRACT(YEAR FROM CURRENT_DATE);
