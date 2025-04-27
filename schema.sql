-- schema of the database, including the CREATE TABLE, CREATE INDEX, and CREATE VIEW statements
CREATE TABLE
    "people" (
        "id" INTEGER,
        "firstname" TEXT NOT NULL,
        "lastname" TEXT NOT NULL,
        "father" TEXT NOT NULL,
        "mother" TEXT NOT NULL,
        "dob" NUMERIC NOT NULL,
        "blood_group" TEXT NOT NULL,
        "nid" INTEGER NOT NULL UNIQUE,
        "address" TEXT NOT NULL,
        "birthplace" TEXT NOT NULL,
        PRIMARY KEY ("id")
    );

CREATE TABLE
    "drivers" (
        "id" INTEGER NOT NULL,
        "person_id" INTEGER NOT NULL,
        "license_no" TEXT NOT NULL UNIQUE,
        "issue_date" NUMERIC NOT NULL,
        "expiry_date" NUMERIC NOT NULL,
        "status" TEXT NOT NULL,
        "current_points" INTEGER NOT NULL DEFAULT 12,
        PRIMARY KEY ("id"),
        FOREIGN KEY ("person_id") REFERENCES "people"."id"
    );

CREATE TABLE
    "owners" (
        "id" INTEGER NOT NULL,
        "person_id" INTEGER NOT NULL,
        "vehicle_id" INTEGER NOT NULL,
        "percent_share" INTEGER NOT NULL DEFAULT 100,
        "from_date" NUMERIC NOT NULL,
        PRIMARY KEY ("id"),
        FOREIGN KEY ("person_id") REFERENCES "people"."id",
        FOREIGN KEY ("vehicle_id") REFERENCES "vehicles"."id"
    );

CREATE TABLE
    "vehicles" (
        "id" INTEGER NOT NULL,
        "plate_no" TEXT NOT NULL,
        "reg_year" INTEGER NOT NULL,
        "make" TEXT NOT NULL,
        "model" TEXT NOT NULL,
        "color" TEXT,
        "chassis_no" TEXT NOT NULL UNIQUE,
        "engine_no" TEXT NOT NULL UNIQUE,
        "manufacture_year" INTEGER NOT NULL,
        "vehicle_type" TEXT NOT NULL,
        PRIMARY KEY ("id")
    );

CREATE TABLE
    "officers" (
        "id" INTEGER NOT NULL,
        "person_id" INTEGER NOT NULL,
        "badge_no" INTEGER NOT NULL UNIQUE,
        "station" TEXT NOT NULL,
        "rank" TEXT NOT NULL,
        PRIMARY KEY ("id"),
        FOREIGN KEY ("person_id") REFERENCES "people"."id"
    );

CREATE TABLE
    "violations" (
        "violation_code" INTEGER NOT NULL,
        "points_deduct" INTEGER NOT NULL,
        "description" TEXT NOT NULL,
        "fine_amount" INTEGER NOT NULL,
        PRIMARY KEY ("violation_code")
    );

CREATE TABLE
    "tickets" (
        "id" INTEGER NOT NULL,
        "datetime" NUMERIC DEFAULT CURRENT_TIMESTAMP,
        "location" TEXT NOT NULL,
        "officer_id" INTEGER NOT NULL,
        "driver_id" INTEGER,
        "vehicle_id" INTEGER,
        PRIMARY KEY ("id"),
        FOREIGN KEY ("officer_id") REFERENCES "officers"."id",
        FOREIGN KEY ("driver_id") REFERENCES "drivers"."id",
        FOREIGN KEY ("vehicle_id") REFERENCES "vehicles"."id"
    );

CREATE TABLE
    "ticket_details" (
        "ticket_id" INTEGER NOT NULL,
        "violation_code" INTEGER NOT NULL,
        "quantity" INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY ("ticket_id", "violation_code"),
        FOREIGN KEY ("ticket_id") REFERENCES "tickets"."id",
        FOREIGN KEY ("violation_code") REFERENCES "violations"."violation_code"
    );

CREATE TABLE
    "licence_points_log" (
        "id" INTEGER NOT NULL,
        "driver_id" INTEGER NOT NULL,
        "ticket_id" INTEGER NOT NULL,
        "points_before" INTEGER NOT NULL,
        "points_change" INTEGER NOT NULL,
        "points_after" INTEGER NOT NULL,
        "processed_at" NUMERIC DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY ("id"),
        FOREIGN KEY ("ticket_id") REFERENCES "tickets"."id",
        FOREIGN KEY ("driver_id") REFERENCES "drivers"."id"
    );

-- Index for fast retrieval of drivers by license number
CREATE INDEX "license_index" ON "drivers" ("license_no");

-- Index for fast retrieval of tickets by officer ID
CREATE INDEX indx_tickets_officer_id ON "tickets" ("officer_id");

-- Index for fast retrieval of tickets by driver ID
CREATE INDEX indx_tickets_driver_id ON "tickets" ("driver_id");

-- Index for fast retrieval of tickets by vehicle ID
CREATE INDEX indx_tickets_vehicle_id ON "tickets" ("vehicle_id");

-- Index for fast retrieval of vehicles by plate number
CREATE INDEX idx_vehicles_plate_no ON "vehicles" ("plate_no");

-- Index for joining "owners" and "people" on "person_id"
CREATE INDEX idx_owners_person_id ON "owners" ("person_id");

-- Index for joining "owners" and "vehicles" on "vehicle_id"
CREATE INDEX idx_owners_vehicle_id ON "owners" ("vehicle_id");

-- Index for joining "drivers" and "people" on "person_id"
CREATE INDEX idx_drivers_person_id ON "drivers" ("person_id");

-- Index for joining "officers" and "people" on "person_id"
CREATE INDEX idx_officers_person_id ON "officers" ("person_id");

-- Index for "ticket_details" on "ticket_id" for faster retrieval of details for a given ticket
CREATE INDEX idx_ticket_details_ticket_id ON "ticket_details" ("ticket_id");

-- Index for "ticket_details" on "violation_code"
CREATE INDEX idx_ticket_details_violation_code ON "ticket_details" ("violation_code");

-- Index for "licence_points_log" on "driver_id"
CREATE INDEX idx_licence_points_log_driver_id ON "licence_points_log" ("driver_id");

-- Index for "licence_points_log" on "ticket_id"
CREATE INDEX idx_licence_points_log_ticket_id ON "licence_points_log" ("ticket_id");

-- Example to get ticket information with driver and officer details:
CREATE VIEW
    "ticket_details_view" AS
SELECT
    "officer_people"."firstname" AS "officer_firstname",
    "officer_people"."lastname" AS "officer_lastname",
    "driver_people"."firstname" AS "driver_firstname",
    "driver_people"."lastname" AS "driver_lastname",
FROM
    "tickets"
    JOIN "officers" ON "tickets"."officer_id" = "officers"."id"
    JOIN "people" AS "officer_people" ON "officers"."person_id" = "officer_people"."id"
    LEFT JOIN "drivers" ON "tickets"."driver_id" = "drivers"."id"
    LEFT JOIN "people" AS "driver_people" ON "drivers"."person_id" = "driver_people"."id"
    LEFT JOIN "vehicles" ON "tickets"."vehicle_id" = "vehicles"."id";

-- End of schema
