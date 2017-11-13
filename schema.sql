BEGIN;

--
-- A relation to hold records for every user of our app.
--
CREATE TABLE users (
    id    BIGSERIAL PRIMARY KEY,
    email TEXT      NOT NULL UNIQUE
        CHECK (char_length(email) <= 255)
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
