SET search_path TO business_travel;

SELECT DISTINCT
    e1.employee_id AS employee_1_id,
    e1.full_name   AS employee_1,
    e2.employee_id AS employee_2_id,
    e2.full_name   AS employee_2,
    DATE(f1.departure_datetime) AS travel_date,
    c_from.city_name AS origin_city,
    c_to.city_name   AS destination_city,
    f1.flight_number AS flight_1,
    f2.flight_number AS flight_2
FROM business_travel.flight_booking fb1
JOIN business_travel.trip t1
    ON t1.trip_id = fb1.trip_id
JOIN business_travel.employee e1
    ON e1.employee_id = t1.employee_id
JOIN business_travel.flight f1
    ON f1.flight_id = fb1.flight_id
JOIN business_travel.flight_booking fb2
    ON fb1.flight_booking_id < fb2.flight_booking_id
JOIN business_travel.trip t2
    ON t2.trip_id = fb2.trip_id
JOIN business_travel.employee e2
    ON e2.employee_id = t2.employee_id
JOIN business_travel.flight f2
    ON f2.flight_id = fb2.flight_id
JOIN business_travel.city c_from
    ON c_from.city_id = f1.origin_city_id
JOIN business_travel.city c_to
    ON c_to.city_id = f1.destination_city_id
WHERE e1.employee_id < e2.employee_id
  AND t1.status <> 'CANCELLED'
  AND t2.status <> 'CANCELLED'
  AND DATE(f1.departure_datetime) = DATE(f2.departure_datetime)
  AND f1.origin_city_id = f2.origin_city_id
  AND f1.destination_city_id = f2.destination_city_id
  AND f1.flight_id <> f2.flight_id
ORDER BY travel_date, origin_city, destination_city, employee_1, employee_2;
