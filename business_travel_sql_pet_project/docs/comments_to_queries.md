# Comments to queries

This file contains report-style explanations for the analytical SQL queries included in the repository. It follows the logic of the original coursework report, but it is adapted to a GitHub-friendly Markdown format.

A practical note: several queries use `CURRENT_DATE`, so their output depends on the day when the script is executed. The result snapshots below reflect the original report context built around the provided 2026 seed data.

## Query 01 — Hotels in Paris booked by employees from Berlin

**File:** `sql/queries/01_hotels_in_paris_for_berlin_employees.sql`

**Task.** Find all hotels in Paris that were booked by employees from Berlin in the current calendar year.

### Comment to the query

1. The query begins with `SET search_path TO business_travel;` so that all subsequent statements use the project schema by default.

2. The main data source is `hotel_booking`, because this table directly links a business trip to a specific hotel. Then the query joins `hotel` and `city` as `hotel_city` to determine where the hotel is located.

3. To identify the employee's home city, the query follows the chain `trip -> employee -> branch -> city` and uses the alias `branch_city` for the second join to the `city` table.

4. The `WHERE` clause applies three filters at once:
   - the hotel must be located in `Paris`,
   - the employee's branch must be located in `Berlin`,
   - the trip must belong to the current calendar year according to `planned_start_date`.

5. `DISTINCT` is used because the same hotel may be booked more than once across several trips. Without deduplication, the same hotel could appear multiple times in the result set.

### Result in the original report

The query returned two unique hotels in Paris:

- `Seine Business Hotel`
- `Hotel Lumiere`

## Query 02 — Hotel spending in the previous month grouped by hotel city

**File:** `sql/queries/02_hotel_spending_by_hotel_city_last_month.sql`

**Task.** Find company spending on hotel bookings in the previous month, grouped by the city where the hotel is located.

### Comment to the query

1. The query starts from `hotel_booking`, because it is the table that records the fact of accommodation booking for a trip.

2. It joins `hotel` to obtain `nightly_rate`, joins `city` to determine the hotel city, and joins `trip` to access the trip dates used for filtering and cost calculation.

3. The spending formula is:

   `SUM(h.nightly_rate * (t.planned_end_date - t.planned_start_date))`

   In this simplified model, the difference between `planned_end_date` and `planned_start_date` represents the number of nights, so multiplying it by `nightly_rate` gives the accommodation cost for one trip.

4. The previous calendar month is selected with two boundaries:
   - `date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'`
   - `date_trunc('month', CURRENT_DATE)`

   This keeps only those trips whose `planned_start_date` falls inside the previous month.

5. `GROUP BY c.city_name` aggregates all matching bookings by hotel city, and `ORDER BY total_hotel_spending DESC, c.city_name` sorts the output first by spending and then alphabetically.

### Result in the original report

The report showed one city in the result:

- `Paris — 440.00`

## Query 03 — Hotel spending in the previous month grouped by employee city

**File:** `sql/queries/03_hotel_spending_by_employee_city_last_month.sql`

**Task.** Find company spending on hotel bookings in the previous month, grouped by the home city of the employee.

### Comment to the query

1. This query uses the same cost formula as Query 02, but changes the aggregation dimension.

2. The join path begins with `hotel_booking`, then continues through `hotel` and `trip`. After that, the query joins `employee`, `branch`, and `city` as `emp_city` in order to determine the city of the employee's home branch.

3. The `WHERE` clause again restricts the dataset to trips that started in the previous calendar month.

4. The key difference from Query 02 is the grouping:

   `GROUP BY emp_city.city_name`

   This means the output no longer answers where the company spent money geographically, but rather which employee locations generated those accommodation costs.

5. The result is ordered by total spending in descending order and then by city name.

### Result in the original report

The report showed one employee city in the result:

- `Berlin — 440.00`

## Query 04 — Top branches by last-minute trip cancellations

**File:** `sql/queries/04_top_branches_by_last_minute_cancellations.sql`

**Task.** Find the top three branches with the largest number of trip cancellations, where the cancellation happened within three days before the planned trip start date.

### Comment to the query

1. The query reads from `trip`, because cancellation status and cancellation date are stored in this table.

2. It joins `branch` through `origin_branch_id`, since the metric is assigned to the branch from which the trip was supposed to start.

3. The filtering logic keeps only rows that satisfy all of the following conditions:
   - `status = 'CANCELLED'`,
   - `cancellation_date IS NOT NULL`,
   - `cancellation_date >= planned_start_date - INTERVAL '3 days'`,
   - `cancellation_date < planned_start_date`.

   Together, these conditions define a last-minute cancellation as a cancellation made during the three days immediately preceding the planned start date.

4. `GROUP BY b.branch_id, b.branch_name` counts such cancellations for each origin branch.

5. `ORDER BY cancellation_count DESC, b.branch_name` ranks branches from highest to lowest cancellation count, and `LIMIT 3` keeps only the top three rows.

### Result in the original report

The report returned one matching branch:

- `Berlin Branch — 3`

## Query 05 — Employee pairs traveling on the same route and date but on different flights

**File:** `sql/queries/05_same_day_same_route_different_flights.sql`

**Task.** Find all pairs of employees who traveled on the same day between the same pair of cities in the same direction, but on different flights.

### Comment to the query

1. The query is based on a self-join of `flight_booking`, using aliases `fb1` and `fb2`. This allows the database to compare two different flight bookings against each other.

2. Each side of the self-join is connected to its own `trip`, `employee`, and `flight` records. This makes it possible to compare two separate employees and two separate flights in one query.

3. The route is identified through the first flight record, which is then linked to the `city` table twice:
   - `c_from` for the origin city,
   - `c_to` for the destination city.

4. The conditions in the `WHERE` clause enforce the business rule:
   - both trips must not be cancelled,
   - both flights must depart on the same calendar day,
   - both flights must have the same origin city,
   - both flights must have the same destination city,
   - the two flight records must be different.

5. Two additional constraints prevent duplicate mirrored pairs:
   - `fb1.flight_booking_id < fb2.flight_booking_id` removes technical duplicates,
   - `e1.employee_id < e2.employee_id` ensures a stable employee pair ordering.

6. `DISTINCT` is kept as an extra safeguard against repeated rows, and the final `ORDER BY` makes the result easier to inspect.

### Result in the original report

The report showed one employee pair appearing twice, because the same pair matched the condition for the outbound and return directions on different dates:

- `Anna Schmidt` and `Sophie Keller` on `2026-05-20`, route `Berlin -> Paris`, flights `LH1007` and `LH1005`
- `Anna Schmidt` and `Sophie Keller` on `2026-05-22`, route `Paris -> Berlin`, flights `AF1008` and `AF1006`
