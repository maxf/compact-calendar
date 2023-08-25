

-- CREATE USER 'sammy'@'localhost' IDENTIFIED BY 'password';

CREATE DATABASE compact_calendar;
USE compact_calendar;

CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    start BIGINT NOT NULL, -- unix timestamp in ms
    duration INT NOT NULL, -- in days
    title VARCHAR(1024) NOT NULL
);

INSERT INTO events (start, duration, title)
VALUES
    (1692478177, 1, "Event 1"),
    (1692132574, 2, "Past event"),
    (1694810974, 1, "Future event");
