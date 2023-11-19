import requests, random

RANDOM_NAMES = "https://raw.githubusercontent.com/dominictarr/random-name/master/first-names.txt"
names = requests.get(RANDOM_NAMES).text.split("\n")
random.shuffle(names)

USER_COUNT = len(names)
GAME_COUNT = USER_COUNT * 3
FRIEND_REQUESTS = USER_COUNT // 4
FRIEND_ACCEPTS = FRIEND_REQUESTS // 2

with open("data.sql", "w") as f:
    f.write("USE gamers;\n")
    for i in range(USER_COUNT):
        f.write(f"INSERT INTO players (name) VALUES ('{names[i]}');\n")
    for i in range(GAME_COUNT):
        user1 = (i + 123) % (USER_COUNT - 1) + 1
        user2 = (i + 345) % (USER_COUNT - 1) + 1
        score1 = random.randint(0, 100)
        score2 = random.randint(0, 100)
        f.write(f"INSERT INTO games (user1, user2, score1, score2) VALUES ({user1}, {user2}, {score1}, {score2});\n")
    for i in range(FRIEND_REQUESTS):
        user1 = i + 1
        user2 = FRIEND_REQUESTS + 101 + i
        f.write(f"INSERT INTO friend_requests (user1, user2) VALUES ({user1}, {user2});\n")
    for i in range(FRIEND_ACCEPTS):
        user1 = i + 1
        user2 = FRIEND_REQUESTS + 101 + i
        f.write(f"CALL AcceptFriendship({user1}, {user2});\n")