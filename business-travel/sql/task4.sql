SET search_path TO business_travel;

SELECT
    c.city_name,
    SUM(h.nightly_rate * (t.planned_end_date - t.planned_start_date)) AS total_hotel_spending
FROM business_travel.hotel_booking hb
JOIN business_travel.hotel h
    ON h.hotel_id = hb.hotel_id
JOIN business_travel.city c
    ON c.city_id = h.city_id
JOIN business_travel.trip t
    ON t.trip_id = hb.trip_id
WHERE t.planned_start_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
  AND t.planned_start_date <  date_trunc('month', CURRENT_DATE)
GROUP BY c.city_name
ORDER BY total_hotel_spending DESC, c.city_name;
