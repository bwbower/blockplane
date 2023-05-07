-- Enable pgcrypto module for storing encrypted passwords
CREATE EXTENSION pgcrypto;

-- Users Database
CREATE TABLE users (
  id serial PRIMARY KEY,
  username text UNIQUE NOT NULL,
  password_digest text NOT NULL,
  date_joined timestamp (0) DEFAULT now()
);

-- Application Database
CREATE TABLE topics (
  id serial PRIMARY KEY,
  user_id integer NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title text NOT NULL,
  content text NOT NULL,
  created_on timestamp (0) DEFAULT now()
);

CREATE TABLE comments (
  id serial PRIMARY KEY,
  user_id integer NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  topic_id integer NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
  content text NOT NULL,
  created_on timestamp (0) DEFAULT now()
);
