SET search_path TO business_travel;

SELECT
    b.branch_id,
    b.branch_name,
    COUNT(*) AS cancellation_count
FROM business_travel.trip t
JOIN business_travel.branch b
    ON b.branch_id = t.origin_branch_id
WHERE t.status = 'CANCELLED'
  AND t.cancellation_date IS NOT NULL
  AND t.cancellation_date >= t.planned_start_date - INTERVAL '3 days'
  AND t.cancellation_date <  t.planned_start_date
GROUP BY b.branch_id, b.branch_name
ORDER BY cancellation_count DESC, b.branch_name
LIMIT 3;
