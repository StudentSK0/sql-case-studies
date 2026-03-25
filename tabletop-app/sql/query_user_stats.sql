SET search_path TO tabletop_app;

SELECT
    u.user_id,
    u.login,
    u.display_name,
    COALESCE(ug.games_in_collection, 0) AS games_in_collection,
    COALESCE(ev.created_completed_events, 0) AS created_completed_events,
    COALESCE(reg.joined_not_held_events, 0) AS joined_not_held_events
FROM app_user u
LEFT JOIN (
    SELECT
        owner_user_id,
        COUNT(*) AS games_in_collection
    FROM user_game
    WHERE is_active = TRUE
    GROUP BY owner_user_id
) ug
    ON ug.owner_user_id = u.user_id
LEFT JOIN (
    SELECT
        organizer_user_id,
        COUNT(*) AS created_completed_events
    FROM event
    WHERE status = 'COMPLETED'
    GROUP BY organizer_user_id
) ev
    ON ev.organizer_user_id = u.user_id
LEFT JOIN (
    SELECT
        er.user_id,
        COUNT(*) AS joined_not_held_events
    FROM event_registration er
    JOIN event e
        ON e.event_id = er.event_id
    WHERE er.status = 'JOINED'
      AND e.status = 'NOT_HELD'
    GROUP BY er.user_id
) reg
    ON reg.user_id = u.user_id
ORDER BY u.user_id;
