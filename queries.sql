-- This is a road traffic management database that is particularly usable for administrative purposes only
-- Insert into the "tickets" table:
INSERT INTO
    "tickets" (
        "id",
        "datetime",
        "location",
        "officer_id",
        "driver_id",
        "vehicle_id"
    )
VALUES
    (
        '2025-02-24 10:00:00', -- Sample data
        'Intersection of Main St and Oak Ave',
        1,
        NULL, --driver might be unknown firstly
        NULL -- the vehicle as well
    );

BEGIN TRANSACTION;

-- This inserts the details of the violations associated with the ticket.
-- A ticket can have multiple violations.
INSERT INTO
    "ticket_details" ("ticket_id", "violation_code", "quantity")
VALUES
    (1, 9, 1), -- Sample violation 1 (ticket_id must match the ticket inserted above)
    (1, 10, 1);

-- Sample violation 2 (ticket_id must match, different violation code)
INSERT INTO
    "licence_points_log" (
        "driver_id",
        "ticket_id",
        "points_before",
        "points_change",
        "points_after",
        "processed_at"
    )
VALUES
    (
        (
            SELECT
                "driver_id"
            FROM
                "tickets"
            WHERE
                "id" = 1
        ), -- the driver ID
        1, -- the ticket ID
        (
            SELECT
                "current_points"
            FROM
                "drivers"
            WHERE
                "id" = (
                    SELECT
                        "driver_id"
                    FROM
                        "tickets"
                    WHERE
                        "id" = 1
                )
        ), -- previous points value
        - (
            SELECT
                (
                    SUM(
                        "violations"."points_deduct" * "ticket_details"."quantity"
                    )
                )
            FROM
                "ticket_details"
                JOIN "violations" ON "ticket_details"."violation_code" = "violations"."violation_code"
            WHERE
                "ticket_details"."ticket_id" = 1
        ), -- change
        (
            (
                SELECT
                    "current_points"
                FROM
                    "drivers"
                WHERE
                    "id" = (
                        SELECT
                            "driver_id"
                        FROM
                            "tickets"
                        WHERE
                            "id" = 1
                    )
            ) - (
                SELECT
                    (
                        SUM(
                            "violations"."points_deduct" * "ticket_details"."quantity"
                        )
                    )
                FROM
                    "ticket_details"
                    JOIN "violations" ON "ticket_details"."violation_code" = "violations"."violation_code"
                WHERE
                    "ticket_details"."ticket_id" = 1
            )
        ), -- final points
        '2025-04-24 10:05:00' -- time
    );

UPDATE "drivers"
SET
    "current_points" = (
        SELECT
            "points_after"
        FROM
            "licence_points_log"
        WHERE
            "ticket_id" = 1
    )
WHERE
    "id" = (
        SELECT
            "driver_id"
        FROM
            "tickets"
        WHERE
            "id" = 1
    );

COMMIT TRANSACTION;

-- The below command could be though a public right
-- to enlist all the details about each road traffic violation type
SELECT
    *
FROM
    "violations";

-- Querying the first ticket
SELECT
    *
FROM
    "tickets"
WHERE
    "id" = 1;

-- Updating the driver_id for the first ticket
UPDATE "tickets"
SET
    "driver_id" = 1
WHERE
    "id" = 1;

-- Delete retired officer for example
DELETE FROM "officers"
WHERE
    "id" = 1;

-- End of queries
