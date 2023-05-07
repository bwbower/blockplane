require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "securerandom"

require_relative "postgres_api.rb"

# ***** CONFIGURATION *****

configure do
  enable :sessions

  # If session_secret is not set in ENV, generate one with SecureRandom
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

  # Escape html on input to prevent XSS attacks
  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "postgres_api.rb"
end

helpers do
  # Check if user is logged in
  def logged_in?
    if session[:username] == nil
      session[:error] = "You must be logged in to do that!" unless request.path == "/"
      session[:requested_page] = request.path
      redirect "/login"
    end
  end

  # Log user in to system by setting sessions info
  def login_user(username)
    @user = @storage.user_info(username)
    session[:user_id] = @user["id"]
    session[:username] = @user["username"]
    session[:success] = "Welcome, #{@user["username"]}!"
  end

  # Determine topic page for a given comment
  def get_page_of_comment(comment_id, topic_id)
    # Get all comments for specified topic, ensure they're sorted by date
    result = @storage.all_comments(topic_id).values.sort_by { |comment| comment[-1] }

    # Determine position of comment within that list
    idx = result.index { |comment| comment[0] == comment_id }

    # Determine page
    page = 0

    while idx > 0
      page += 1 if idx % 5 == 0 
      idx -= 1
    end

    return page
  end

  # Redirect to most recently posted comment on topic thread
  def redirect_to_latest_comment(topic_id)
    comment_id = @storage.get_newest_comment_id(topic_id)
    page = comment_id.nil? ? 0 : get_page_of_comment(comment_id, topic_id)
    redirect "/topics/#{topic_id}/page/#{page}"
  end

  # Determine if topic exists
  def topic_exists?(topic_id)
    if (topic_id =~ /^\d+$/).nil? ||
       @storage.single_topic(topic_id).nil?
      redirect not_found
    end
  end

  # Determine if comment exists
  def comment_exists?(comment_id)
    if (comment_id =~ /^\d+$/).nil? ||
       @storage.single_comment(comment_id).nil?
      redirect not_found 
    end
  end

  # Determine if page exists for home
  def homepage_exists?(page)
    if !(page.to_s =~ /^\d+$/).nil? &&
       page >= 0 && 
       page <= (@storage.all_topics.count / 5)
      return true
    else
      return false
    end
  end

  # Determine if page exists for topic thread
  def comments_page_exists?(topic, page)
    if page =~ /^\d+$/ &&
       page.to_i >= 0 &&
       page.to_i <= (@storage.all_comments(topic).count / 5)
      return true
    else
      redirect not_found
    end
  end

  # Determine validity of topic title
  def valid_title?(title)
    if title =~ /.*\w+.*/
      session.delete(:title)
      return true
    else
      session[:title] = params[:title]
      session[:content] = params[:content]
      session[:error] = "Title must include letters or numbers!"
      return false
    end
  end

  # Determine validity of textarea for topic content
  def valid_content?(content)
    if content =~ /.*\w+.*/
      session.delete(:content)
      return true
    else
      session[:title] = params[:title]
      session[:content] = params[:content]
      session[:error] = "Content must include letters or numbers!"
      return false
    end
  end

  # Determine validity of comment
  def valid_comment?(comment)
    if comment =~ /.*\w+.*/
      return true
    else
      session[:error] = "Comment must include letters or numbers!"
      return false
    end
  end
end

# Before any route, create a connection to the database and ouput SQL log to termial
before do
  @storage = ApplicationController.new(logger)
end

# Redirect if not found
not_found do
  logged_in?
  session[:error] = "Page does not exist!"
  redirect "/home/0"
end

# ***** HOMEPAGE ROUTES *****

# Redirect root to homepage
get "/" do
  logged_in?
  redirect "/home/0"
end

# Homepage
get "/home/:page" do
  logged_in?
  if homepage_exists?(params[:page].to_i)
    @user = @storage.user_info(session[:username])
    @offset = params[:page].to_i * 5
    @five_topics = @storage.five_topics(@offset)

    erb :home, layout: :layout
  else
    redirect not_found
  end
end

# ***** USER/LOGIN/SIGNUP ROUTES *****

# Login Page
get "/login" do
  erb :login, layout: :layout
end

# Login Procedure
post "/login" do
  if @storage.authenticate_user(params[:username], params[:password])
    login_user(params[:username])
    redirect "#{session[:requested_page]}"
  else
    session[:error] = "Invalid username or password."
  end

  erb :login
end

# New User Procedure
post "/signup" do
  if @storage.username_taken?(params[:username])
    session[:error] = "Username already taken!"
    erb :login
  else
    @storage.create_user(params[:username], params[:password])
    login_user(params[:username])
    redirect "#{session[:requested_page]}"
  end
end

# Logout Procedure
get "/user/logout" do
  session.destroy
  session[:success] = "You have been logged out."
  erb :login
end

# User Profile Page
get "/profile" do
  logged_in?

  @user = @storage.user_info(session[:username])
  @topics = @storage.get_users_topics(session[:user_id])
  @comments = @storage.get_users_comments(session[:user_id])

  erb :user
end

# ***** TOPIC CRUD ROUTES *****

# Single Topic Page
get "/topics/:id/page/:page" do
  logged_in?
  topic_exists?(params[:id])
  comments_page_exists?(params[:id], params[:page])

  # Get topic and necessary metadata
  @topic = @storage.single_topic(params[:id])
  @username = @topic[:username]

  # Get five comments at a time
  @offset = params[:page].to_i * 5
  @five_comments = @storage.five_comments(params[:id], @offset)

  erb :single_topic, layout: :layout
end

# Add Topic Page
get "/topics/add" do
  logged_in?
  erb :add_topic, layout: :layout
end

# Add Topic Procedure
post "/topics/add" do
  logged_in?
  if !valid_title?(params[:title]) || !valid_content?(params[:content])
    erb :add_topic, layout: :layout
  else
    @storage.add_topic(session[:user_id], params[:title].strip, params[:content].strip)
    session[:success] = "Topic has been added!"
    
    # Determine route to newly added topic
    topic_id = @storage.get_newest_topic_id
    redirect "/topics/#{topic_id}/page/0"
  end
end

# Edit Topic Page
get "/topics/:id/edit" do
  logged_in?
  topic_exists?(params[:id])
  @topic = @storage.single_topic(params[:id])
  erb :edit_topic, layout: :layout
end

# Edit Topic Procedure
post "/topics/:id/edit" do
  logged_in?
  topic_exists?(params[:id])
  @topic = @storage.single_topic(params[:id])

  # If title or content is invalid, reload page
  if !valid_title?(params[:title]) || !valid_content?(params[:content])
    erb :edit_topic, layout: :layout
  # If current user did not create the topic, return to the home page
  elsif !@storage.user_is_topic_owner?(session[:user_id], params[:id])
    session[:error] = "Sorry, you don't have permission to edit that topic!"
    erb :home, layout: :layout
  else
    @storage.update_topic(params[:id], params[:title], params[:content])
    session[:success] = "Topic has been updated!"
    redirect "/topics/#{params[:id]}/page/0"
  end
end

# Delete Topic
post "/topics/:id/delete" do
  topic_exists?(params[:id])

  if @storage.user_is_topic_owner?(session[:user_id], params[:id])
    @storage.delete_topic(params[:id])
    session[:success] = "Topic has been deleted."
  else
    session[:error] = "Sorry, you don't have permission to delete that topic!"
  end

  redirect "/home/0"
end

# ***** COMMENT CRUD ROUTES *****

# Add Comment Procedure
post "/topics/:id/add" do
  logged_in?
  topic_exists?(params[:id])
  if !valid_comment?(params[:content])
    redirect "/topics/#{params[:id]}/page/0"
  else
    @storage.add_comment(session[:user_id], params[:id], params[:content])
    redirect_to_latest_comment(params[:id])
  end
end

# Edit Comment Page
get "/topics/:id/comments/:comment_id" do
  logged_in?
  topic_exists?(params[:id])
  comment_exists?(params[:comment_id])

  if @storage.user_is_comment_owner?(session[:user_id], params[:comment_id])
    @topic = @storage.single_topic(params[:id])
    @comment = @storage.single_comment(params[:comment_id])
  else
    session[:error] = "Sorry, you don't have permission to edit that comment!"
    redirect "/home/0"
  end

  erb :edit_comment, layout: :layout
end

# Edit Comment Procedure
post "/topics/:id/comments/:comment_id" do
  logged_in?
  topic_exists?(params[:id]) && comment_exists?(params[:comment_id])
  if !valid_comment?(params[:content])
    erb :edit_comment, layout: :layout
  elsif !@storage.user_is_comment_owner?(session[:user_id], params[:comment_id])
    session[:error] = "Sorry, you don't have permission to edit that comment!"
    erb :home, layout: :layout
  else
    @storage.edit_comment(params[:comment_id], params[:content])
    session[:success] = "Comment has been edited."
    page = get_page_of_comment(params[:comment_id], params[:id])
    redirect "/topics/#{params[:id]}/page/#{page}"
  end
end

# Delete Comment Procedure
post "/topics/:id/comments/:comment_id/delete" do
  logged_in?
  topic_exists?(params[:id])
  comment_exists?(params[:comment_id])

  if @storage.user_is_comment_owner?(session[:user_id], params[:comment_id])
    @storage.delete_comment(params[:comment_id])
    session[:success] = "Comment has been deleted."
  else
    session[:error] = "Sorry, you don't have permission to delete that comment!"
  end

  redirect "/topics/#{params[:id]}/page/0"
end