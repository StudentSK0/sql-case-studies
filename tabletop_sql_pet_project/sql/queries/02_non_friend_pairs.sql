SET search_path TO tabletop_app;

WITH event_players AS (
    -- Организатор тоже считается участником игры
    SELECT
        e.event_id,
        e.starts_at,
        e.organizer_user_id AS user_id
    FROM event e
    WHERE e.status = 'COMPLETED'

    UNION

    -- Остальные участники
    SELECT
        e.event_id,
        e.starts_at,
        er.user_id
    FROM event e
    JOIN event_registration er
        ON er.event_id = e.event_id
    WHERE e.status = 'COMPLETED'
      AND er.status = 'JOINED'
),
player_pairs AS (
    SELECT
        ep1.event_id,
        ep1.starts_at,
        LEAST(ep1.user_id, ep2.user_id) AS user_id_1,
        GREATEST(ep1.user_id, ep2.user_id) AS user_id_2
    FROM event_players ep1
    JOIN event_players ep2
        ON ep1.event_id = ep2.event_id
       AND ep1.user_id < ep2.user_id
),
pair_games AS (
    SELECT
        pp.user_id_1,
        pp.user_id_2,
        gt.game_type_id,
        gt.type_name,
        date_trunc('month', pp.starts_at)::date AS month_start,
        pp.event_id
    FROM player_pairs pp
    JOIN event e
        ON e.event_id = pp.event_id
    JOIN user_game ug
        ON ug.user_game_id = e.user_game_id
    JOIN game g
        ON g.game_id = ug.game_id
    JOIN game_type gt
        ON gt.game_type_id = g.game_type_id
)
SELECT
    u1.user_id AS player_1_id,
    u1.display_name AS player_1,
    u2.user_id AS player_2_id,
    u2.display_name AS player_2,
    pg.type_name AS game_category,
    pg.month_start,
    COUNT(*) AS games_together
FROM pair_games pg
JOIN app_user u1
    ON u1.user_id = pg.user_id_1
JOIN app_user u2
    ON u2.user_id = pg.user_id_2
LEFT JOIN friendship f
    ON f.user_id_1 = pg.user_id_1
   AND f.user_id_2 = pg.user_id_2
WHERE f.friendship_id IS NULL
GROUP BY
    u1.user_id,
    u1.display_name,
    u2.user_id,
    u2.display_name,
    pg.type_name,
    pg.month_start
HAVING COUNT(*) >= 3
ORDER BY
    pg.month_start,
    pg.type_name,
    games_together DESC,
    player_1,
    player_2;
