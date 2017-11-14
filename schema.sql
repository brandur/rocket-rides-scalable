BEGIN;

--
-- A relation that contains the last observed lsn (log sequence number) for
-- every known replica.
--
CREATE TABLE replica_statuses (
    id       BIGSERIAL    PRIMARY KEY,
    last_lsn PG_LSN       NOT NULL,
    name     VARCHAR(100) NOT NULL UNIQUE
);

--
-- A relation to hold records for every user of our app.
--
CREATE TABLE users (
    id      BIGSERIAL    PRIMARY KEY,
    email   VARCHAR(255) NOT NULL UNIQUE,

    -- stores the minimum lsn (log sequence number) required to have replicated
    -- to a replica before read requests for the user can be fulfilled on it
    min_lsn PG_LSN
);

CREATE INDEX users_email
    ON users (email);

--
-- A relation representing a single ride by a user.
--
CREATE TABLE rides (
    id         BIGSERIAL        PRIMARY KEY,
    created_at TIMESTAMPTZ      NOT NULL DEFAULT now(),
    distance   DOUBLE PRECISION NOT NULL,

    user_id    BIGINT           NOT NULL
        REFERENCES users ON DELETE RESTRICT
);

COMMIT;
