SET search_path TO tabletop_app;

INSERT INTO game_type (type_name)
VALUES
    ('Board Game'),
    ('Card Game'),
    ('TTRPG');

INSERT INTO app_user (
    login,
    email,
    password_hash,
    display_name,
    email_verified_at
)
VALUES
    ('alice', 'alice@example.com', 'hash_alice', 'Alice', NOW()),
    ('bob', 'bob@example.com', 'hash_bob', 'Bob', NOW()),
    ('carol', 'carol@example.com', 'hash_carol', 'Carol', NOW()),
    ('dmitry', 'dmitry@example.com', 'hash_dmitry', 'Dmitry', NOW()),
    ('eva', 'eva@example.com', 'hash_eva', 'Eva', NOW());

INSERT INTO game (
    game_type_id,
    title,
    players_min,
    players_max,
    duration_minutes,
    description,
    image_url,
    created_by_user_id
)
VALUES
(
    (SELECT game_type_id FROM game_type WHERE type_name = 'Board Game'),
    'Catan',
    3,
    4,
    90,
    'Economic board game about resource trading and settlement building.',
    'https://example.com/catan.jpg',
    (SELECT user_id FROM app_user WHERE login = 'alice')
),
(
    (SELECT game_type_id FROM game_type WHERE type_name = 'Board Game'),
    'Ticket to Ride',
    2,
    5,
    60,
    'Railway route-building board game.',
    'https://example.com/ticket-to-ride.jpg',
    (SELECT user_id FROM app_user WHERE login = 'eva')
),
(
    (SELECT game_type_id FROM game_type WHERE type_name = 'Card Game'),
    'Uno',
    2,
    10,
    30,
    'Fast-paced card game.',
    'https://example.com/uno.jpg',
    (SELECT user_id FROM app_user WHERE login = 'carol')
),
(
    (SELECT game_type_id FROM game_type WHERE type_name = 'TTRPG'),
    'Dungeons & Dragons 5e',
    4,
    6,
    240,
    'Fantasy tabletop role-playing game.',
    'https://example.com/dnd5e.jpg',
    (SELECT user_id FROM app_user WHERE login = 'dmitry')
),
(
    (SELECT game_type_id FROM game_type WHERE type_name = 'Board Game'),
    'Chess',
    2,
    2,
    45,
    'Classic strategy board game.',
    'https://example.com/chess.jpg',
    (SELECT user_id FROM app_user WHERE login = 'bob')
);

INSERT INTO user_game (owner_user_id, game_id, notes)
VALUES
(
    (SELECT user_id FROM app_user WHERE login = 'alice'),
    (SELECT game_id FROM game WHERE title = 'Catan'),
    'My favorite copy'
),
(
    (SELECT user_id FROM app_user WHERE login = 'eva'),
    (SELECT game_id FROM game WHERE title = 'Ticket to Ride'),
    'European edition'
),
(
    (SELECT user_id FROM app_user WHERE login = 'carol'),
    (SELECT game_id FROM game WHERE title = 'Uno'),
    'Travel version'
),
(
    (SELECT user_id FROM app_user WHERE login = 'dmitry'),
    (SELECT game_id FROM game WHERE title = 'Dungeons & Dragons 5e'),
    'Starter campaign'
),
(
    (SELECT user_id FROM app_user WHERE login = 'bob'),
    (SELECT game_id FROM game WHERE title = 'Chess'),
    'Tournament board'
);

INSERT INTO event (
    organizer_user_id,
    user_game_id,
    starts_at,
    address_text,
    latitude,
    longitude,
    player_level,
    min_players_required,
    max_players_capacity,
    status
)
VALUES
(
    (SELECT user_id FROM app_user WHERE login = 'alice'),
    (SELECT ug.user_game_id
     FROM user_game ug
     JOIN app_user u ON u.user_id = ug.owner_user_id
     JOIN game g ON g.game_id = ug.game_id
     WHERE u.login = 'alice' AND g.title = 'Catan'),
    TIMESTAMPTZ '2026-04-15 18:00:00+03',
    '12 Main St, Berlin',
    52.520000,
    13.405000,
    'BEGINNER',
    3,
    4,
    'OPEN'
),
(
    (SELECT user_id FROM app_user WHERE login = 'dmitry'),
    (SELECT ug.user_game_id
     FROM user_game ug
     JOIN app_user u ON u.user_id = ug.owner_user_id
     JOIN game g ON g.game_id = ug.game_id
     WHERE u.login = 'dmitry' AND g.title = 'Dungeons & Dragons 5e'),
    TIMESTAMPTZ '2026-04-15 19:00:00+03',
    '45 River Rd, Berlin',
    52.517000,
    13.388000,
    'INTERMEDIATE',
    4,
    6,
    'OPEN'
),
(
    (SELECT user_id FROM app_user WHERE login = 'bob'),
    (SELECT ug.user_game_id
     FROM user_game ug
     JOIN app_user u ON u.user_id = ug.owner_user_id
     JOIN game g ON g.game_id = ug.game_id
     WHERE u.login = 'bob' AND g.title = 'Chess'),
    TIMESTAMPTZ '2026-04-15 17:00:00+03',
    '8 Park Ave, Berlin',
    52.510000,
    13.390000,
    'ADVANCED',
    2,
    2,
    'OPEN'
),
(
    (SELECT user_id FROM app_user WHERE login = 'carol'),
    (SELECT ug.user_game_id
     FROM user_game ug
     JOIN app_user u ON u.user_id = ug.owner_user_id
     JOIN game g ON g.game_id = ug.game_id
     WHERE u.login = 'carol' AND g.title = 'Uno'),
    TIMESTAMPTZ '2026-04-16 18:30:00+03',
    '22 Sunset Blvd, Berlin',
    52.500000,
    13.410000,
    'ANY',
    2,
    6,
    'OPEN'
),
(
    (SELECT user_id FROM app_user WHERE login = 'eva'),
    (SELECT ug.user_game_id
     FROM user_game ug
     JOIN app_user u ON u.user_id = ug.owner_user_id
     JOIN game g ON g.game_id = ug.game_id
     WHERE u.login = 'eva' AND g.title = 'Ticket to Ride'),
    TIMESTAMPTZ '2026-04-15 20:00:00+03',
    '100 Central Sq, Berlin',
    52.530000,
    13.420000,
    'ANY',
    2,
    5,
    'CANCELLED'
);

INSERT INTO event_registration (event_id, user_id, status)
VALUES
(
    (SELECT e.event_id
     FROM event e
     JOIN app_user u ON u.user_id = e.organizer_user_id
     WHERE u.login = 'alice' AND e.starts_at = TIMESTAMPTZ '2026-04-15 18:00:00+03'),
    (SELECT user_id FROM app_user WHERE login = 'bob'),
    'JOINED'
),
(
    (SELECT e.event_id
     FROM event e
     JOIN app_user u ON u.user_id = e.organizer_user_id
     WHERE u.login = 'alice' AND e.starts_at = TIMESTAMPTZ '2026-04-15 18:00:00+03'),
    (SELECT user_id FROM app_user WHERE login = 'carol'),
    'JOINED'
),
(
    (SELECT e.event_id
     FROM event e
     JOIN app_user u ON u.user_id = e.organizer_user_id
     WHERE u.login = 'dmitry' AND e.starts_at = TIMESTAMPTZ '2026-04-15 19:00:00+03'),
    (SELECT user_id FROM app_user WHERE login = 'alice'),
    'JOINED'
),
(
    (SELECT e.event_id
     FROM event e
     JOIN app_user u ON u.user_id = e.organizer_user_id
     WHERE u.login = 'dmitry' AND e.starts_at = TIMESTAMPTZ '2026-04-15 19:00:00+03'),
    (SELECT user_id FROM app_user WHERE login = 'bob'),
    'JOINED'
),
(
    (SELECT e.event_id
     FROM event e
     JOIN app_user u ON u.user_id = e.organizer_user_id
     WHERE u.login = 'dmitry' AND e.starts_at = TIMESTAMPTZ '2026-04-15 19:00:00+03'),
    (SELECT user_id FROM app_user WHERE login = 'eva'),
    'JOINED'
),
(
    (SELECT e.event_id
     FROM event e
     JOIN app_user u ON u.user_id = e.organizer_user_id
     WHERE u.login = 'dmitry' AND e.starts_at = TIMESTAMPTZ '2026-04-15 19:00:00+03'),
    (SELECT user_id FROM app_user WHERE login = 'carol'),
    'WAITLIST'
),
(
    (SELECT e.event_id
     FROM event e
     JOIN app_user u ON u.user_id = e.organizer_user_id
     WHERE u.login = 'bob' AND e.starts_at = TIMESTAMPTZ '2026-04-15 17:00:00+03'),
    (SELECT user_id FROM app_user WHERE login = 'alice'),
    'JOINED'
),
(
    (SELECT e.event_id
     FROM event e
     JOIN app_user u ON u.user_id = e.organizer_user_id
     WHERE u.login = 'carol' AND e.starts_at = TIMESTAMPTZ '2026-04-16 18:30:00+03'),
    (SELECT user_id FROM app_user WHERE login = 'eva'),
    'JOINED'
);
