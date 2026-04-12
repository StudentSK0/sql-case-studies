# Tabletop Event App SQL Database


The project is designed as a PostgreSQL schema-first pet project. It demonstrates relational design, integrity constraints, indexing, seed data, and non-trivial SQL queries.

## Business scenario

Registered users can discover other players, send and accept friend requests, maintain their own game collections, organize game sessions, and join events with available seats. The system also distinguishes between minimum required players and maximum event capacity, which makes it possible to classify an event as not held when participation is too low.

## Data model

Core entities:
- `app_user`
- `email_verification_token`
- `password_reset_token`
- `friend_request`
- `friendship`
- `game_type`
- `game`
- `user_game`
- `event`
- `event_registration`


## Repository structure

```text
tabletop_sql_pet_project/
├── README.md
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed.sql
│   └── queries/
│       ├── 01_available_events.sql
│       ├── 02_non_friend_pairs.sql
│       └── 03_user_metrics.sql
└── docs/
    └── query_plan_note.md
```

## Tech stack

This project targets PostgreSQL and uses PostgreSQL-specific features such as:
- `GENERATED ALWAYS AS IDENTITY`,
- `TIMESTAMPTZ`,
- partial unique indexes,
- filtered aggregates with `COUNT(...) FILTER (...)`,
- `date_trunc`,
- tuple foreign keys and integrity checks.

## Launch

Create a PostgreSQL database and run the scripts in order.

```bash
psql -d your_database -f sql/01_schema.sql
psql -d your_database -f sql/02_seed.sql
```

Run any query from the `sql/queries/` directory, for example:

```bash
psql -d your_database -f sql/queries/01_available_events.sql
```

## Query highlights

The repository contains three showcase queries.

`01_available_events.sql` returns open events for a given date where free seats are still available. It joins events, owned games, the shared game catalog, and registrations, then computes occupied and free places.

`02_non_friend_pairs.sql` finds pairs of players who played at least three games of the same category within one month while not being friends. The query uses common table expressions to build participant sets, generate player pairs, and aggregate by month and category.

`03_user_metrics.sql` produces per-user statistics: active games in collection, completed events created by the user, and events the user joined that ended up not being held.

The file `docs/query_plan_note.md` also contains a concise explanation of the expected execution plan for a join-and-aggregate query with indexes that do not fully match the join predicate.

## Example schema excerpt

```sql
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
    updated_at               TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);
```

