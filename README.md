Online Forum

Description:
- Login: Users will be directed to a login page where new users can create an account or existing users can provide their credentials to log in to the system. Passwords are encrypted and stored in the database alongside other relevant user information. 
- Homepage: Once proper credentials have been provided, users will be able to view the forum's homepage, which includes topics posted by various users. On the homepage, topics are sorted with the oldest topics appearing first, with five topics per page.
- CRUD: Users can create, edit and delete their own topics. They can also comment on topics created by others, as well as edit or delete comments they have made.
- Topic Page: Each topic has it's own unique page where users can read comments by other users. Comments on this page are sorted with the oldest comments first and appear in pages of five comments at a time.
- User Profile: User's can view their own information, including topics they've created and comments they've made. This page displays your most recently created topics and comments first, which is the opposite of how they appear on the home and single topic pages. This was an intentional design decision, which just seemed the most natural way to display the information for this particular page. Links will take you to the page where your comment appears.

Configuration:
- Ruby Version 3.0.2
- PostgreSQL Version 14.5
- Google Chrome Version 105.0.5195.125

Directory:
- The main project folder includes the `main.rb` and `postgres_api.rb` files, as well as the rackup file `config.ru`, the `README.md` file, and the `Gemfile` and `Gemfile.lock` files.
  - `main.rb` is the main project file
  - `postgres_api.rb` is the file used by `main.rb` to query or update the database
- View files, including layout and all other router template pages, are located in the `views` sub-directory.
- Database files are located in the `db` sub-directory.
    - `schema.sql` is the file used to create the necessary tables used in the database
    - `populate.sql` can be used to populate the database with data
