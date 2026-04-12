SET search_path TO tabletop_app;

SELECT
    e.event_id,
    g.title AS game_title,
    gt.type_name AS game_type,
    e.starts_at,
    e.address_text,
    e.player_level,
    e.max_players_capacity,
    1 + COUNT(er.user_id) FILTER (WHERE er.status = 'JOINED') AS occupied_places,
    e.max_players_capacity - (
        1 + COUNT(er.user_id) FILTER (WHERE er.status = 'JOINED')
    ) AS free_places
FROM event e
JOIN user_game ug
    ON ug.user_game_id = e.user_game_id
JOIN game g
    ON g.game_id = ug.game_id
JOIN game_type gt
    ON gt.game_type_id = g.game_type_id
LEFT JOIN event_registration er
    ON er.event_id = e.event_id
WHERE e.status = 'OPEN'
  AND e.starts_at::date = DATE '2026-04-15'
GROUP BY
    e.event_id,
    g.title,
    gt.type_name,
    e.starts_at,
    e.address_text,
    e.player_level,
    e.max_players_capacity
HAVING 1 + COUNT(er.user_id) FILTER (WHERE er.status = 'JOINED') < e.max_players_capacity
ORDER BY e.starts_at, g.title;
