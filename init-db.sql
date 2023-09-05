

-- CREATE USER 'sammy'@'localhost' IDENTIFIED BY 'password';

CREATE DATABASE compact_calendar;
USE compact_calendar;

DROP TABLE IF EXISTS events;
CREATE TABLE events (
    id INT,
    start BIGINT NOT NULL, -- unix timestamp in ms
    duration INT NOT NULL, -- in days
    title VARCHAR(1024) NOT NULL,
    last_updated BIGINT NOT NULL -- unix timestamp in MS
);

INSERT INTO events (id, start, duration, title, last_updated)
VALUES
    (1, 1692478177000, 1, "Event 1", 0),
    (2, 1692132574000, 2, "Past event", 0),
    (3, 1694810974000, 1, "Future event", 0);

DROP TABLE IF EXISTS meta;
CREATE TABLE meta (
    last_sync BIGINT NOT NULL
);

INSERT INTO meta (last_sync) VALUES (0);
