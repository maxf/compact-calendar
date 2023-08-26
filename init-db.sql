

-- CREATE USER 'sammy'@'localhost' IDENTIFIED BY 'password';

CREATE DATABASE compact_calendar;
USE compact_calendar;

CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    start BIGINT NOT NULL, -- unix timestamp in ms
    duration INT NOT NULL, -- in days
    title VARCHAR(1024) NOT NULL,
    last_updated BIGINT NOT NULL -- unix timestamp in MS
);

INSERT INTO events (start, duration, title)
VALUES
    (1692478177000, 1, "Event 1", 0),
    (1692132574000, 2, "Past event", 0),
    (1694810974000, 1, "Future event", 0);
