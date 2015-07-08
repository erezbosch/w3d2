DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255),
  body VARCHAR(255),
  author_id INTEGER REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER REFERENCES questions(id),
  user_id INTEGER REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  question_id INTEGER REFERENCES questions(id) NOT NULL,
  parent_id INTEGER REFERENCES replies(id),
  user_id INTEGER REFERENCES users(id) NOT NULL
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER REFERENCES questions(id),
  user_id INTEGER REFERENCES users(id)
);

INSERT INTO users(fname, lname)
VALUES ('John', 'Doe'), ('Abc', 'Def');

INSERT INTO questions(title, body, author_id)
VALUES ('Math', 'What is 2 + 2?', (SELECT id FROM users WHERE fname = 'John')),
('Science', 'Is global warming real?', (SELECT id FROM users WHERE fname = 'Abc'));

INSERT INTO question_follows(question_id, user_id)
VALUES (1, 2), (2, 1);

INSERT INTO replies(body, question_id, parent_id, user_id)
VALUES ("4", 1, NULL, 2), ("No it's 5", 1, 1, 1);

INSERT INTO question_likes(question_id, user_id)
VALUES (2, 2), (2, 1), (1, 1);
