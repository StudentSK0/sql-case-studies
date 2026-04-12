# Tabletop Event App SQL Database

A portfolio SQL project that models a small application for board game and tabletop RPG players. The database supports user accounts, friendship workflows, personal game collections, event creation, event registration, and analytical queries over completed and scheduled games.

The project is designed as a PostgreSQL schema-first pet project that can be shown in a résumé or portfolio. It demonstrates relational design, integrity constraints, indexing, seed data, and non-trivial SQL queries.

## Business scenario

Registered users can discover other players, send and accept friend requests, maintain their own game collections, organize game sessions, and join events with available seats. The system also distinguishes between minimum required players and maximum event capacity, which makes it possible to classify an event as not held when participation is too low.

## Main capabilities

The schema supports:
- user registration and account lifecycle,
- email verification and password reset tokens,
- friend requests and confirmed friendships,
- a shared game catalog and per-user owned games,
- event creation only for games that belong to the organizer,
- participant registration with controlled statuses,
- reporting queries for availability, repeated co-play patterns, and user-level metrics.

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

A few design decisions make the model more realistic.

`friend_request` and `friendship` are intentionally separated. This keeps the request workflow independent from the final accepted relationship.

`event` references `user_game`, not only `game`. This guarantees that an organizer can create an event only for a title that exists in their own collection.

`min_players_required` and `max_players_capacity` are stored explicitly in `event`. This allows business logic such as identifying events that were scheduled but did not actually happen because too few players joined.

Status columns are validated with `CHECK` constraints, and several uniqueness rules are enforced directly in the database. This reduces invalid states and makes the schema safer to use from any application layer.

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

## Getting started

Create a PostgreSQL database and run the scripts in order.

```bash
psql -d your_database -f sql/01_schema.sql
psql -d your_database -f sql/02_seed.sql
```

Then run any query from the `sql/queries/` directory, for example:

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

## What this project demonstrates

This repository is useful as a portfolio project because it shows more than basic CRUD. It demonstrates that the author can:
- translate product requirements into a normalized relational schema,
- design constraints and indexes deliberately,
- prepare reproducible seed data,
- write analytical SQL queries with joins, CTEs, aggregation, filtering, and business rules,
- structure a small database project in a way that is easy to review on GitHub.

## Possible next improvements

A natural next step is to add an ER diagram, Docker-based startup, and a small API layer or migration tooling such as Flyway or Alembic. That would turn the repository from a database design project into a fuller backend portfolio example.
