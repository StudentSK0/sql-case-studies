# Comments to queries

This file contains plain-language explanations for the main SQL queries included in the project.

## 01_available_events.sql

This query finds all open game events for a given date and keeps only those where free seats are still available.

The query starts from the `event` table because it stores the scheduled game sessions themselves. Then it joins `user_game`, `game`, and `game_type` to attach the game title and category. A `LEFT JOIN` is used for `event_registration` so that events with no registered participants are still included in the result.

In the `WHERE` clause, the query filters only events with status `OPEN` and only events scheduled for a specific date. After that, the rows are grouped by event so that the number of occupied places can be calculated.

The number of occupied places is computed as `1 + COUNT(...) FILTER (WHERE er.status = 'JOINED')`. The additional `1` represents the organizer, who is also treated as a participant. The number of free places is then calculated as the difference between the maximum event capacity and the occupied places.

The `HAVING` clause keeps only those events where the number of occupied places is still smaller than the capacity. As a result, the final table contains only events that users can still join.

## 02_non_friend_pairs.sql

This query returns pairs of players who played at least three games of the same category within one month while not being friends.

The first common table expression, `event_players`, builds the set of participants for completed events. It includes both the organizer and the users whose registration status is `JOINED`. This is important because the organizer must also be counted as someone who took part in the game.

The second step, `player_pairs`, generates all unique player pairs inside each completed event. The functions `LEAST(...)` and `GREATEST(...)` are used to store the pair in a canonical order, which prevents duplicates such as `(Alice, Bob)` and `(Bob, Alice)`.

The third step, `pair_games`, connects each player pair with the game category and with the month in which the event took place. This makes it possible to aggregate not just by pair of users, but also by game category and calendar month.

In the final query, the result is joined with `app_user` to show player names and with `friendship` to check whether the pair is already friends. Pairs found in the `friendship` table are excluded. Then the query groups rows by the pair of users, game category, and month, and keeps only those groups where the number of joint games is at least three.

## 03_user_metrics.sql

This query returns three aggregated metrics for each user.

The first metric, `games_in_collection`, shows how many active games the user currently has in their collection. The second metric, `created_completed_events`, shows how many events with status `COMPLETED` were created by that user. The third metric, `joined_not_held_events`, shows how many events the user joined with status `JOINED` but that later received the status `NOT_HELD`.

Each metric is calculated in a separate subquery and then joined back to `app_user`. This design is intentional. If all related tables were combined in one large `JOIN`, the rows would multiply, and the aggregate values would become incorrect.

The `COALESCE(...)` calls replace missing values with zero, so every user appears in the result even if they have no games, no completed events, or no registrations in not-held events.
