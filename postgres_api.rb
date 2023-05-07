require "pg"

class ApplicationController
  def initialize(logger)
    @db = PG.connect(dbname: "forum") 
    @logger = logger
  end

  # *** HELPER METHODS ***

  # Query the database
  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  # Format topic results as hash
  def format_result(result)
    result.map do |tuple|
      { 
        id: tuple["id"].to_i, 
        username: tuple["username"],
        title: tuple["title"], 
        content: tuple["content"],
        created_on: tuple["created_on"],
        comments_count: tuple["comments_count"] 
      }
    end
  end

# *** USER METHODS ***

  # Create new user
  def create_user(username, password)
    sql = "INSERT INTO users (username, password_digest)
                VALUES ($1, crypt($2, gen_salt('bf')))"
    query(sql, username, password)
  end

  # Authenticate user credentials
  def authenticate_user(username, password)
    sql = "SELECT id
             FROM users
            WHERE username = $1
              AND password_digest = crypt($2, password_digest)"
    query(sql, username, password).ntuples == 1
  end

  # Check whether username is already in use
  def username_taken?(username)
    sql = "SELECT * FROM users WHERE username = $1"
    query(sql, username).ntuples != 0
  end

  # Read user's information, given username
  def user_info(username)
    sql = "SELECT * FROM users WHERE username = $1"
    result = query(sql, username)
    result ? result.first : result
  end

  # Read user's information, given user_id
  def user_info_from_id(user_id)
    sql = "SELECT * FROM users WHERE id = $1"
    result = query(sql, user_id)
    result ? result.first : result
  end

  # Determine if user is topic's owner
  def user_is_topic_owner?(user_id, topic_id)
    sql = "SELECT 1
             FROM topics
            WHERE id = $1 AND
                  user_id = $2"
    query(sql, topic_id, user_id).ntuples > 0
  end

  # Determine if user is comment's owner
  def user_is_comment_owner?(user_id, comment_id)
    sql = "SELECT 1
             FROM comments
            WHERE id = $1 AND
                  user_id = $2"
    query(sql, comment_id, user_id).ntuples > 0
  end

# *** TOPIC METHODS ***

  # Create topic
  def add_topic(user_id, title, content)
    sql = "INSERT INTO topics (user_id, title, content)
                VALUES ($1, $2, $3)"
    query(sql, user_id, title, content)
  end

  # Read a single topic
  def single_topic(topic_id)
    sql = "SELECT t.*, u.username, count(c.*) AS comments_count
             FROM topics t
             JOIN users u ON u.id = t.user_id
             JOIN comments c ON t.id = c.topic_id
            WHERE t.id = $1
            GROUP BY t.id, u.username"
    result = query(sql, topic_id)
    format_result(result).first
  end

  # Read five topics at a time
  def five_topics(offset)
    sql = "SELECT t.*, u.username, count(c.*) AS comments_count
              FROM topics t
              JOIN users u ON u.id = t.user_id
              JOIN comments c ON t.id = c.topic_id
             GROUP BY t.id, u.username
             ORDER BY created_on
             LIMIT 5
            OFFSET $1"
    result = query(sql, offset)
    format_result(result)
  end

  # Read all topics
  def all_topics
    sql = "SELECT * FROM topics"
    result = query(sql)
  end

  # Read id of most recently created topic
  def get_newest_topic_id
    sql = "SELECT max(id) FROM topics"
    query(sql).first["max"]
  end

  # Read all topics created by a given user
  def get_users_topics(user_id)
    sql = "SELECT * 
             FROM topics 
            WHERE user_id = $1
           ORDER BY created_on DESC"
    query(sql, user_id)
  end

  # Read topic given comment_id
  def get_topic_from_comment_id(comment_id)
    sql = "SELECT t.*
             FROM topics t
                  JOIN comments c ON t.id = c.topic_id
            WHERE c.id = $1"
    query(sql, comment_id).first
  end

  # Read most recently added comment
  def get_newest_comment_id(topic_id)
    sql = "SELECT max(id) FROM comments WHERE topic_id = $1"
    query(sql, topic_id).first["max"]
  end

  # Edit topic
  def update_topic(topic_id, title, content)
    sql = "UPDATE topics
              SET title = $1,
                  content = $2
            WHERE id = $3"
    query(sql, title, content, topic_id)
  end

  # Delete topic
  def delete_topic(topic_id)
    sql = "DELETE FROM topics WHERE id = $1"
    query(sql, topic_id)
  end

  # *** COMMENT METHODS ***

  # Create comment
  def add_comment(user_id, topic_id, comment)
    sql = "INSERT INTO comments (user_id, topic_id, content)
            VALUES ($1, $2, $3)"
    query(sql, user_id, topic_id, comment)
  end

  # Read a single comment
  def single_comment(comment_id)
    sql = "SELECT * FROM comments WHERE id = $1"
    result = query(sql, comment_id).first
  end

  # Read five comments at a time
  def five_comments(topic_id, offset)
    sql = "SELECT *
              FROM comments
            WHERE topic_id = $1
            ORDER BY created_on
            LIMIT 5
            OFFSET $2"
    query(sql, topic_id, offset)
  end

  # Read all comments
  def all_comments(topic_id)
    sql = "SELECT * FROM comments WHERE topic_id = $1"
    result = query(sql, topic_id)
  end

  # Read all comments created by a given user
  def get_users_comments(user_id)
    sql = "SELECT * 
            FROM comments 
           WHERE user_id = $1
           ORDER BY created_on DESC"
    result = query(sql, user_id)
  end

  # Edit comment
  def edit_comment(comment_id, content)
    sql = "UPDATE comments
              SET content = $1
            WHERE id = $2"
    query(sql, content, comment_id)
  end

  # Delete comment
  def delete_comment(comment_id)
    sql = "DELETE FROM comments
                  WHERE id = $1"
    query(sql, comment_id)
  end
end