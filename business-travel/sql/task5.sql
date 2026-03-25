SET search_path TO business_travel;

SELECT
    emp_city.city_name AS employee_city,
    SUM(h.nightly_rate * (t.planned_end_date - t.planned_start_date)) AS total_hotel_spending
FROM business_travel.hotel_booking hb
JOIN business_travel.hotel h
    ON h.hotel_id = hb.hotel_id
JOIN business_travel.trip t
    ON t.trip_id = hb.trip_id
JOIN business_travel.employee e
    ON e.employee_id = t.employee_id
JOIN business_travel.branch b
    ON b.branch_id = e.branch_id
JOIN business_travel.city emp_city
    ON emp_city.city_id = b.city_id
WHERE t.planned_start_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
  AND t.planned_start_date <  date_trunc('month', CURRENT_DATE)
GROUP BY emp_city.city_name
ORDER BY total_hotel_spending DESC, employee_city;
