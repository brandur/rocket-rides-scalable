BEGIN;

--
-- A relation to hold records for every user of our app.
--
CREATE TABLE users (
    id      BIGSERIAL    PRIMARY KEY,
    email   VARCHAR(255) NOT NULL UNIQUE,

    -- stores the minimum lsn (log sequence number) required to have replicated
    -- to a replica before read requests for the user can be fulfilled on it
    min_lsn VARCHAR(100)
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
