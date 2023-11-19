CREATE DATABASE `gamers`;
USE `gamers`;
CREATE TABLE `players` (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE `games` (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user1 INT NOT NULL,
    user2 INT NOT NULL,
    score1 INT NOT NULL,
    score2 INT NOT NULL,
    CONSTRAINT FOREIGN KEY (user1) REFERENCES players(id),
    CONSTRAINT FOREIGN KEY (user2) REFERENCES players(id)
);

CREATE TABLE `friend_requests` (
    user1 INT NOT NULL,
    user2 INT NOT NULL,
    CONSTRAINT FOREIGN KEY (user1) REFERENCES players(id),
    CONSTRAINT FOREIGN KEY (user2) REFERENCES players(id),
    CONSTRAINT UNIQUE KEY (user1, user2)
);

CREATE TABLE `friendships` (
    user1 INT NOT NULL,
    user2 INT NOT NULL,
    CONSTRAINT FOREIGN KEY (user1) REFERENCES players(id),
    CONSTRAINT FOREIGN KEY (user2) REFERENCES players(id),
    CONSTRAINT UNIQUE KEY (user1, user2)
);

DELIMITER //
CREATE PROCEDURE AcceptFriendship(IN userA INT, IN userB INT)
BEGIN
    START TRANSACTION;
    INSERT INTO friendships (user1, user2) VALUES (userA, userB);
    INSERT INTO friendships (user1, user2) VALUES (userB, userA);
    DELETE FROM friend_requests WHERE user1 = userA AND user2 = userB;
    COMMIT;
END //
DELIMITER ;