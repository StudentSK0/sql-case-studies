CREATE SCHEMA IF NOT EXISTS tabletop_app;
SET search_path TO tabletop_app;

-- Пользователи

CREATE TABLE app_user (
    user_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login                VARCHAR(50)  NOT NULL,
    email                VARCHAR(255) NOT NULL,
    password_hash        TEXT         NOT NULL,
    display_name         VARCHAR(100) NOT NULL,
    is_active            BOOLEAN      NOT NULL DEFAULT TRUE,
    email_verified_at    TIMESTAMPTZ,
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_app_user_login UNIQUE (login),
    CONSTRAINT uq_app_user_email UNIQUE (email)
);

CREATE INDEX ix_app_user_login ON app_user(login);
CREATE INDEX ix_app_user_display_name ON app_user(display_name);

-- Подтверждение email

CREATE TABLE email_verification_token (
    token_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id              BIGINT       NOT NULL,
    token_hash           VARCHAR(255) NOT NULL,
    expires_at           TIMESTAMPTZ  NOT NULL,
    used_at              TIMESTAMPTZ,
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_email_verification_user
        FOREIGN KEY (user_id)
        REFERENCES app_user(user_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_email_verification_token UNIQUE (token_hash)
);

-- Восстановление пароля

CREATE TABLE password_reset_token (
    token_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id              BIGINT       NOT NULL,
    token_hash           VARCHAR(255) NOT NULL,
    expires_at           TIMESTAMPTZ  NOT NULL,
    used_at              TIMESTAMPTZ,
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_password_reset_user
        FOREIGN KEY (user_id)
        REFERENCES app_user(user_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_password_reset_token UNIQUE (token_hash)
);

-- Дружба и запросы в друзья

CREATE TABLE friend_request (
    friend_request_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    requester_user_id    BIGINT       NOT NULL,
    addressee_user_id    BIGINT       NOT NULL,
    status               VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    responded_at         TIMESTAMPTZ,

    CONSTRAINT fk_friend_request_requester
        FOREIGN KEY (requester_user_id)
        REFERENCES app_user(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_friend_request_addressee
        FOREIGN KEY (addressee_user_id)
        REFERENCES app_user(user_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_friend_request_users_diff
        CHECK (requester_user_id <> addressee_user_id),

    CONSTRAINT chk_friend_request_status
        CHECK (status IN ('PENDING', 'ACCEPTED', 'DECLINED', 'CANCELLED'))
);

CREATE INDEX ix_friend_request_addressee_status
    ON friend_request(addressee_user_id, status, created_at DESC);

CREATE UNIQUE INDEX uq_friend_request_pending_pair
    ON friend_request (
        LEAST(requester_user_id, addressee_user_id),
        GREATEST(requester_user_id, addressee_user_id)
    )
    WHERE status = 'PENDING';

CREATE TABLE friendship (
    friendship_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id_1            BIGINT      NOT NULL,
    user_id_2            BIGINT      NOT NULL,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_friendship_user_1
        FOREIGN KEY (user_id_1)
        REFERENCES app_user(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_friendship_user_2
        FOREIGN KEY (user_id_2)
        REFERENCES app_user(user_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_friendship_order
        CHECK (user_id_1 < user_id_2),

    CONSTRAINT uq_friendship_pair UNIQUE (user_id_1, user_id_2)
);

-- Справочник типов игр

CREATE TABLE game_type (
    game_type_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type_name            VARCHAR(50) NOT NULL,

    CONSTRAINT uq_game_type_name UNIQUE (type_name)
);

-- Каталог игр

CREATE TABLE game (
    game_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    game_type_id         BIGINT       NOT NULL,
    title                VARCHAR(200) NOT NULL,
    players_min          SMALLINT     NOT NULL,
    players_max          SMALLINT     NOT NULL,
    duration_minutes     INTEGER      NOT NULL,
    description          TEXT,
    image_url            TEXT,
    created_by_user_id   BIGINT,
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_game_type
        FOREIGN KEY (game_type_id)
        REFERENCES game_type(game_type_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_game_created_by
        FOREIGN KEY (created_by_user_id)
        REFERENCES app_user(user_id)
        ON DELETE SET NULL,

    CONSTRAINT chk_game_players
        CHECK (players_min >= 1 AND players_max >= players_min),

    CONSTRAINT chk_game_duration
        CHECK (duration_minutes > 0)
);

CREATE INDEX ix_game_title ON game(title);
CREATE INDEX ix_game_type ON game(game_type_id);

-- Коллекция игр пользователя

CREATE TABLE user_game (
    user_game_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_user_id        BIGINT      NOT NULL,
    game_id              BIGINT      NOT NULL,
    added_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active            BOOLEAN     NOT NULL DEFAULT TRUE,
    notes                TEXT,

    CONSTRAINT fk_user_game_owner
        FOREIGN KEY (owner_user_id)
        REFERENCES app_user(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_game_game
        FOREIGN KEY (game_id)
        REFERENCES game(game_id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_user_game_owner_game UNIQUE (owner_user_id, game_id),
    CONSTRAINT uq_user_game_id_owner UNIQUE (user_game_id, owner_user_id)
);

CREATE INDEX ix_user_game_owner ON user_game(owner_user_id);

-- Мероприятия

CREATE TABLE event (
    event_id                 BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organizer_user_id        BIGINT        NOT NULL,
    user_game_id             BIGINT        NOT NULL,
    starts_at                TIMESTAMPTZ   NOT NULL,
    address_text             TEXT          NOT NULL,
    latitude                 NUMERIC(9,6)  NOT NULL,
    longitude                NUMERIC(9,6)  NOT NULL,
    player_level             VARCHAR(20)   NOT NULL DEFAULT 'ANY',
    min_players_required     SMALLINT      NOT NULL,
    max_players_capacity     SMALLINT      NOT NULL,
    status                   VARCHAR(20)   NOT NULL DEFAULT 'OPEN',
    created_at               TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_event_user_game
        FOREIGN KEY (user_game_id, organizer_user_id)
        REFERENCES user_game(user_game_id, owner_user_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_event_player_level
        CHECK (player_level IN ('ANY', 'BEGINNER', 'INTERMEDIATE', 'ADVANCED')),

    CONSTRAINT chk_event_status
        CHECK (status IN ('OPEN', 'FULL', 'CANCELLED', 'NOT_HELD', 'COMPLETED')),

    CONSTRAINT chk_event_players
        CHECK (
            min_players_required >= 1
            AND max_players_capacity >= min_players_required
        ),

    CONSTRAINT chk_event_latitude
        CHECK (latitude BETWEEN -90 AND 90),

    CONSTRAINT chk_event_longitude
        CHECK (longitude BETWEEN -180 AND 180)
);

CREATE INDEX ix_event_starts_at ON event(starts_at);
CREATE INDEX ix_event_status ON event(status);
CREATE INDEX ix_event_lat_lon ON event(latitude, longitude);
CREATE INDEX ix_event_level ON event(player_level);

-- Запись пользователей на мероприятия

CREATE TABLE event_registration (
    event_id              BIGINT       NOT NULL,
    user_id               BIGINT       NOT NULL,
    status                VARCHAR(20)  NOT NULL DEFAULT 'JOINED',
    registered_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_event_registration PRIMARY KEY (event_id, user_id),

    CONSTRAINT fk_registration_event
        FOREIGN KEY (event_id)
        REFERENCES event(event_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_registration_user
        FOREIGN KEY (user_id)
        REFERENCES app_user(user_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_registration_status
        CHECK (status IN ('JOINED', 'CANCELLED', 'REJECTED', 'WAITLIST'))
);

CREATE INDEX ix_event_registration_event_status
    ON event_registration(event_id, status);

CREATE INDEX ix_event_registration_user
    ON event_registration(user_id);
