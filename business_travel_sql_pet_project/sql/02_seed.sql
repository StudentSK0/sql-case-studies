SET search_path TO business_travel;

INSERT INTO business_travel.company (company_name)
SELECT 'EuroBusiness Travel Ltd'
WHERE NOT EXISTS (
    SELECT 1 FROM business_travel.company WHERE company_name = 'EuroBusiness Travel Ltd'
);

INSERT INTO business_travel.city (city_name)
SELECT v.city_name
FROM (VALUES
    ('Berlin'),
    ('Paris'),
    ('Munich'),
    ('Rome'),
    ('Madrid'),
    ('Vienna'),
    ('Prague')
) AS v(city_name)
WHERE NOT EXISTS (
    SELECT 1 FROM business_travel.city c WHERE c.city_name = v.city_name
);

INSERT INTO business_travel.airline (airline_name)
SELECT v.airline_name
FROM (VALUES
    ('Lufthansa'),
    ('Air France'),
    ('ITA Airways'),
    ('Iberia'),
    ('Austrian Airlines'),
    ('Czech Airlines')
) AS v(airline_name)
WHERE NOT EXISTS (
    SELECT 1 FROM business_travel.airline a WHERE a.airline_name = v.airline_name
);

INSERT INTO business_travel.branch (company_id, city_id, branch_name)
SELECT
    c.company_id,
    ct.city_id,
    v.branch_name
FROM (VALUES
    ('Berlin', 'Berlin Branch'),
    ('Paris', 'Paris Branch'),
    ('Munich', 'Munich Branch'),
    ('Rome', 'Rome Branch'),
    ('Madrid', 'Madrid Branch'),
    ('Vienna', 'Vienna Branch'),
    ('Prague', 'Prague Branch')
) AS v(city_name, branch_name)
JOIN business_travel.company c
    ON c.company_name = 'EuroBusiness Travel Ltd'
JOIN business_travel.city ct
    ON ct.city_name = v.city_name
WHERE NOT EXISTS (
    SELECT 1 FROM business_travel.branch b WHERE b.branch_name = v.branch_name
);

INSERT INTO business_travel.employee (branch_id, full_name)
SELECT
    b.branch_id,
    v.full_name
FROM (VALUES
    ('Berlin Branch', 'Anna Schmidt'),
    ('Berlin Branch', 'Lukas Weber'),
    ('Berlin Branch', 'Sophie Keller'),
    ('Paris Branch', 'Claire Martin'),
    ('Paris Branch', 'Julien Dubois'),
    ('Munich Branch', 'Max Fischer'),
    ('Munich Branch', 'Emma Braun'),
    ('Rome Branch', 'Marco Rossi'),
    ('Rome Branch', 'Giulia Bianchi'),
    ('Madrid Branch', 'Carlos Garcia')
) AS v(branch_name, full_name)
JOIN business_travel.branch b
    ON b.branch_name = v.branch_name
WHERE NOT EXISTS (
    SELECT 1 FROM business_travel.employee e WHERE e.full_name = v.full_name
);

INSERT INTO business_travel.hotel (city_id, hotel_name, address_line, nightly_rate)
SELECT
    c.city_id,
    v.hotel_name,
    v.address_line,
    v.nightly_rate
FROM (VALUES
    ('Paris', 'Hotel Lumiere', '12 Rue de Rivoli, Paris', 180.00),
    ('Paris', 'Seine Business Hotel', '8 Boulevard Saint-Germain, Paris', 220.00),
    ('Rome', 'Colosseo Stay', '25 Via Cavour, Rome', 150.00),
    ('Madrid', 'Gran Via Suites', '44 Gran Via, Madrid', 165.00),
    ('Vienna', 'Danube Central Hotel', '10 Praterstrasse, Vienna', 175.00),
    ('Prague', 'Old Town Residence', '6 Celetna, Prague', 140.00),
    ('Munich', 'Bavaria Plaza', '17 Marienplatz, Munich', 190.00)
) AS v(city_name, hotel_name, address_line, nightly_rate)
JOIN business_travel.city c
    ON c.city_name = v.city_name
WHERE NOT EXISTS (
    SELECT 1 FROM business_travel.hotel h
    WHERE h.hotel_name = v.hotel_name AND h.address_line = v.address_line
);

INSERT INTO business_travel.flight (
    airline_id,
    origin_city_id,
    destination_city_id,
    flight_number,
    departure_datetime,
    ticket_price
)
SELECT
    a.airline_id,
    c1.city_id,
    c2.city_id,
    v.flight_number,
    v.departure_datetime::timestamp,
    v.ticket_price
FROM (VALUES
    ('Lufthansa', 'Berlin', 'Paris',   'LH1001', '2026-01-15 08:00:00', 120.00),
    ('Air France', 'Paris', 'Berlin',  'AF1002', '2026-01-18 18:00:00', 125.00),
    ('Lufthansa', 'Berlin', 'Paris',   'LH1003', '2026-02-10 09:00:00', 130.00),
    ('Air France', 'Paris', 'Berlin',  'AF1004', '2026-02-12 17:00:00', 128.00),
    ('Lufthansa', 'Berlin', 'Paris',   'LH1005', '2026-05-20 08:30:00', 140.00),
    ('Air France', 'Paris', 'Berlin',  'AF1006', '2026-05-22 19:10:00', 138.00),
    ('Lufthansa', 'Berlin', 'Paris',   'LH1007', '2026-05-20 10:15:00', 142.00),
    ('Air France', 'Paris', 'Berlin',  'AF1008', '2026-05-22 21:00:00', 136.00),
    ('Lufthansa', 'Berlin', 'Rome',    'LH2001', '2026-03-12 07:40:00', 160.00),
    ('ITA Airways', 'Rome', 'Berlin',  'AZ2002', '2026-03-15 20:30:00', 158.00),
    ('Lufthansa', 'Munich', 'Paris',   'LH3001', '2026-04-03 09:20:00', 115.00),
    ('Air France', 'Paris', 'Munich',  'AF3002', '2026-04-06 18:45:00', 118.00),
    ('Iberia', 'Madrid', 'Paris',      'IB4001', '2026-06-11 08:10:00', 150.00),
    ('Air France', 'Paris', 'Madrid',  'AF4002', '2026-06-14 19:30:00', 149.00),
    ('Lufthansa', 'Berlin', 'Vienna',  'LH5001', '2026-07-09 06:50:00', 145.00),
    ('Austrian Airlines', 'Vienna', 'Berlin', 'OS5002', '2026-07-11 20:15:00', 147.00),
    ('Lufthansa', 'Berlin', 'Prague',  'LH6001', '2026-08-05 08:25:00', 110.00),
    ('Czech Airlines', 'Prague', 'Berlin', 'OK6002', '2026-08-07 17:40:00', 112.00)
) AS v(airline_name, origin_city, destination_city, flight_number, departure_datetime, ticket_price)
JOIN business_travel.airline a
    ON a.airline_name = v.airline_name
JOIN business_travel.city c1
    ON c1.city_name = v.origin_city
JOIN business_travel.city c2
    ON c2.city_name = v.destination_city
WHERE NOT EXISTS (
    SELECT 1 FROM business_travel.flight f
    WHERE f.flight_number = v.flight_number
      AND f.departure_datetime = v.departure_datetime::timestamp
);

INSERT INTO business_travel.trip (
    employee_id,
    origin_branch_id,
    destination_branch_id,
    planned_start_date,
    planned_end_date,
    actual_start_date,
    actual_end_date,
    task_description,
    status,
    cancellation_date
)
SELECT
    e.employee_id,
    b1.branch_id,
    b2.branch_id,
    v.planned_start_date::date,
    v.planned_end_date::date,
    v.actual_start_date::date,
    v.actual_end_date::date,
    v.task_description,
    v.status,
    v.cancellation_date::date
FROM (VALUES
    ('Anna Schmidt',  'Berlin Branch', 'Paris Branch',  '2026-01-15', '2026-01-18', '2026-01-15', '2026-01-18', 'Contract negotiation in Paris', 'COMPLETED',  NULL),
    ('Lukas Weber',   'Berlin Branch', 'Paris Branch',  '2026-02-10', '2026-02-12', '2026-02-10', '2026-02-12', 'Finance workshop in Paris',     'COMPLETED',  NULL),
    ('Sophie Keller', 'Berlin Branch', 'Paris Branch',  '2026-05-20', '2026-05-22', '2026-05-20', '2026-05-22', 'Sales visit in Paris',          'COMPLETED',  NULL),
    ('Anna Schmidt',  'Berlin Branch', 'Paris Branch',  '2026-05-20', '2026-05-22', '2026-05-20', '2026-05-22', 'Project review in Paris',       'COMPLETED',  NULL),
    ('Lukas Weber',   'Berlin Branch', 'Rome Branch',   '2026-03-12', '2026-03-15', '2026-03-12', '2026-03-15', 'Supplier meeting in Rome',      'COMPLETED',  NULL),
    ('Max Fischer',   'Munich Branch', 'Paris Branch',  '2026-04-03', '2026-04-06', '2026-04-03', '2026-04-06', 'Operations review in Paris',    'COMPLETED',  NULL),
    ('Carlos Garcia', 'Madrid Branch', 'Paris Branch',  '2026-06-11', '2026-06-14', NULL,         NULL,         'Marketing campaign in Paris',   'PLANNED',    NULL),
    ('Anna Schmidt',  'Berlin Branch', 'Vienna Branch', '2026-07-09', '2026-07-11', NULL,         NULL,         'Regional coordination in Vienna','CANCELLED', '2026-07-07'),
    ('Lukas Weber',   'Berlin Branch', 'Prague Branch', '2026-08-05', '2026-08-07', NULL,         NULL,         'Partner visit in Prague',       'CANCELLED',  '2026-08-03'),
    ('Sophie Keller', 'Berlin Branch', 'Paris Branch',  '2026-09-14', '2026-09-16', NULL,         NULL,         'Customer workshop in Paris',    'CANCELLED',  '2026-09-12')
) AS v(full_name, origin_branch, destination_branch, planned_start_date, planned_end_date, actual_start_date, actual_end_date, task_description, status, cancellation_date)
JOIN business_travel.employee e
    ON e.full_name = v.full_name
JOIN business_travel.branch b1
    ON b1.branch_name = v.origin_branch
JOIN business_travel.branch b2
    ON b2.branch_name = v.destination_branch
WHERE NOT EXISTS (
    SELECT 1
    FROM business_travel.trip t
    WHERE t.employee_id = e.employee_id
      AND t.planned_start_date = v.planned_start_date::date
      AND t.task_description = v.task_description
);

INSERT INTO business_travel.hotel_booking (trip_id, hotel_id)
SELECT
    t.trip_id,
    h.hotel_id
FROM (VALUES
    ('Anna Schmidt',  '2026-01-15', 'Hotel Lumiere'),
    ('Lukas Weber',   '2026-02-10', 'Seine Business Hotel'),
    ('Sophie Keller', '2026-05-20', 'Hotel Lumiere'),
    ('Anna Schmidt',  '2026-05-20', 'Seine Business Hotel'),
    ('Lukas Weber',   '2026-03-12', 'Colosseo Stay'),
    ('Max Fischer',   '2026-04-03', 'Hotel Lumiere'),
    ('Carlos Garcia', '2026-06-11', 'Seine Business Hotel'),
    ('Anna Schmidt',  '2026-07-09', 'Danube Central Hotel'),
    ('Lukas Weber',   '2026-08-05', 'Old Town Residence'),
    ('Sophie Keller', '2026-09-14', 'Hotel Lumiere')
) AS v(full_name, planned_start_date, hotel_name)
JOIN business_travel.employee e
    ON e.full_name = v.full_name
JOIN business_travel.trip t
    ON t.employee_id = e.employee_id
   AND t.planned_start_date = v.planned_start_date::date
JOIN business_travel.hotel h
    ON h.hotel_name = v.hotel_name
WHERE NOT EXISTS (
    SELECT 1 FROM business_travel.hotel_booking hb WHERE hb.trip_id = t.trip_id
);

INSERT INTO business_travel.flight_booking (trip_id, flight_id, leg_type)
SELECT
    t.trip_id,
    f.flight_id,
    v.leg_type
FROM (VALUES
    ('Anna Schmidt',  '2026-01-15', 'LH1001', 'OUTBOUND'),
    ('Anna Schmidt',  '2026-01-15', 'AF1002', 'RETURN'),
    ('Lukas Weber',   '2026-02-10', 'LH1003', 'OUTBOUND'),
    ('Lukas Weber',   '2026-02-10', 'AF1004', 'RETURN'),
    ('Sophie Keller', '2026-05-20', 'LH1005', 'OUTBOUND'),
    ('Sophie Keller', '2026-05-20', 'AF1006', 'RETURN'),
    ('Anna Schmidt',  '2026-05-20', 'LH1007', 'OUTBOUND'),
    ('Anna Schmidt',  '2026-05-20', 'AF1008', 'RETURN'),
    ('Lukas Weber',   '2026-03-12', 'LH2001', 'OUTBOUND'),
    ('Lukas Weber',   '2026-03-12', 'AZ2002', 'RETURN'),
    ('Max Fischer',   '2026-04-03', 'LH3001', 'OUTBOUND'),
    ('Max Fischer',   '2026-04-03', 'AF3002', 'RETURN'),
    ('Carlos Garcia', '2026-06-11', 'IB4001', 'OUTBOUND'),
    ('Carlos Garcia', '2026-06-11', 'AF4002', 'RETURN'),
    ('Anna Schmidt',  '2026-07-09', 'LH5001', 'OUTBOUND'),
    ('Anna Schmidt',  '2026-07-09', 'OS5002', 'RETURN'),
    ('Lukas Weber',   '2026-08-05', 'LH6001', 'OUTBOUND'),
    ('Lukas Weber',   '2026-08-05', 'OK6002', 'RETURN')
) AS v(full_name, planned_start_date, flight_number, leg_type)
JOIN business_travel.employee e
    ON e.full_name = v.full_name
JOIN business_travel.trip t
    ON t.employee_id = e.employee_id
   AND t.planned_start_date = v.planned_start_date::date
JOIN business_travel.flight f
    ON f.flight_number = v.flight_number
WHERE NOT EXISTS (
    SELECT 1
    FROM business_travel.flight_booking fb
    WHERE fb.trip_id = t.trip_id
      AND fb.leg_type = v.leg_type
);
