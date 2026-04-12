CREATE SCHEMA IF NOT EXISTS business_travel;

CREATE TABLE IF NOT EXISTS business_travel.company (
    company_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name    VARCHAR(200) NOT NULL,
    CONSTRAINT uq_company_name UNIQUE (company_name)
);

CREATE TABLE IF NOT EXISTS business_travel.city (
    city_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_name       VARCHAR(150) NOT NULL,
    CONSTRAINT uq_city_name UNIQUE (city_name)
);

CREATE TABLE IF NOT EXISTS business_travel.airline (
    airline_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airline_name    VARCHAR(200) NOT NULL,
    CONSTRAINT uq_airline_name UNIQUE (airline_name)
);

CREATE TABLE IF NOT EXISTS business_travel.branch (
    branch_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id       BIGINT NOT NULL,
    city_id          BIGINT NOT NULL,
    branch_name      VARCHAR(200) NOT NULL,
    CONSTRAINT fk_branch_company
        FOREIGN KEY (company_id)
        REFERENCES business_travel.company(company_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_branch_city
        FOREIGN KEY (city_id)
        REFERENCES business_travel.city(city_id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_branch_city UNIQUE (city_id),
    CONSTRAINT uq_branch_name_per_company UNIQUE (company_id, branch_name)
);

CREATE TABLE IF NOT EXISTS business_travel.employee (
    employee_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id        BIGINT NOT NULL,
    full_name        VARCHAR(200) NOT NULL,
    CONSTRAINT fk_employee_branch
        FOREIGN KEY (branch_id)
        REFERENCES business_travel.branch(branch_id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS business_travel.hotel (
    hotel_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_id          BIGINT NOT NULL,
    hotel_name       VARCHAR(200) NOT NULL,
    address_line     VARCHAR(300) NOT NULL,
    nightly_rate     NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_hotel_city
        FOREIGN KEY (city_id)
        REFERENCES business_travel.city(city_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_hotel_nightly_rate CHECK (nightly_rate >= 0),
    CONSTRAINT uq_hotel_identity UNIQUE (city_id, hotel_name, address_line)
);

CREATE TABLE IF NOT EXISTS business_travel.flight (
    flight_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airline_id             BIGINT NOT NULL,
    origin_city_id         BIGINT NOT NULL,
    destination_city_id    BIGINT NOT NULL,
    flight_number          VARCHAR(30) NOT NULL,
    departure_datetime     TIMESTAMP NOT NULL,
    ticket_price           NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_flight_airline
        FOREIGN KEY (airline_id)
        REFERENCES business_travel.airline(airline_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_flight_origin_city
        FOREIGN KEY (origin_city_id)
        REFERENCES business_travel.city(city_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_flight_destination_city
        FOREIGN KEY (destination_city_id)
        REFERENCES business_travel.city(city_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_flight_different_cities CHECK (origin_city_id <> destination_city_id),
    CONSTRAINT chk_flight_ticket_price CHECK (ticket_price >= 0),
    CONSTRAINT uq_flight_natural UNIQUE (airline_id, flight_number, departure_datetime)
);

CREATE TABLE IF NOT EXISTS business_travel.trip (
    trip_id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id              BIGINT NOT NULL,
    origin_branch_id         BIGINT NOT NULL,
    destination_branch_id    BIGINT NOT NULL,
    planned_start_date       DATE NOT NULL,
    planned_end_date         DATE NOT NULL,
    actual_start_date        DATE,
    actual_end_date          DATE,
    task_description         TEXT NOT NULL,
    status                   VARCHAR(20) NOT NULL DEFAULT 'PLANNED',
    cancellation_date        DATE,
    CONSTRAINT fk_trip_employee
        FOREIGN KEY (employee_id)
        REFERENCES business_travel.employee(employee_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_trip_origin_branch
        FOREIGN KEY (origin_branch_id)
        REFERENCES business_travel.branch(branch_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_trip_destination_branch
        FOREIGN KEY (destination_branch_id)
        REFERENCES business_travel.branch(branch_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_trip_branches_different CHECK (origin_branch_id <> destination_branch_id),
    CONSTRAINT chk_trip_planned_dates CHECK (planned_start_date <= planned_end_date),
    CONSTRAINT chk_trip_actual_dates CHECK (
        actual_start_date IS NULL
        OR actual_end_date IS NULL
        OR actual_start_date <= actual_end_date
    ),
    CONSTRAINT chk_trip_status CHECK (status IN ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT chk_trip_status_logic CHECK (
        (status = 'PLANNED' AND actual_start_date IS NULL AND actual_end_date IS NULL AND cancellation_date IS NULL)
        OR
        (status = 'IN_PROGRESS' AND actual_start_date IS NOT NULL AND actual_end_date IS NULL AND cancellation_date IS NULL)
        OR
        (status = 'COMPLETED' AND actual_start_date IS NOT NULL AND actual_end_date IS NOT NULL AND cancellation_date IS NULL)
        OR
        (status = 'CANCELLED' AND cancellation_date IS NOT NULL AND actual_start_date IS NULL AND actual_end_date IS NULL)
    )
);

CREATE TABLE IF NOT EXISTS business_travel.flight_booking (
    flight_booking_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trip_id              BIGINT NOT NULL,
    flight_id            BIGINT NOT NULL,
    leg_type             VARCHAR(10) NOT NULL,
    CONSTRAINT fk_flight_booking_trip
        FOREIGN KEY (trip_id)
        REFERENCES business_travel.trip(trip_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_flight_booking_flight
        FOREIGN KEY (flight_id)
        REFERENCES business_travel.flight(flight_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_flight_booking_leg_type CHECK (leg_type IN ('OUTBOUND', 'RETURN')),
    CONSTRAINT uq_flight_booking_trip_leg UNIQUE (trip_id, leg_type),
    CONSTRAINT uq_flight_booking_trip_flight UNIQUE (trip_id, flight_id)
);

CREATE TABLE IF NOT EXISTS business_travel.hotel_booking (
    hotel_booking_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trip_id              BIGINT NOT NULL,
    hotel_id             BIGINT NOT NULL,
    CONSTRAINT fk_hotel_booking_trip
        FOREIGN KEY (trip_id)
        REFERENCES business_travel.trip(trip_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_hotel_booking_hotel
        FOREIGN KEY (hotel_id)
        REFERENCES business_travel.hotel(hotel_id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_hotel_booking_trip UNIQUE (trip_id)
);
