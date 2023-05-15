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

-- Populate database

INSERT INTO users (username, password_digest)
VALUES
    ('admin', crypt('password', gen_salt('bf'))),
    ('johnny', crypt('cash$$$', gen_salt('bf'))),
    ('dolly', crypt('jolene', gen_salt('bf'))),
    ('frank', crypt('ocean', gen_salt('bf'))),
    ('tom', crypt('waitsforit', gen_salt('bf'))),
    ('lucy', crypt('inthesky', gen_salt('bf'))),
    ('david', crypt('bowie', gen_salt('bf'))),
    ('emily', crypt('wood', gen_salt('bf'))),
    ('robert', crypt('plant', gen_salt('bf'))),
    ('susan', crypt('woodworking101', gen_salt('bf')))
;


-- Insert the conversations as topics and comments
INSERT INTO topics (user_id, title, content)
VALUES
    (9, 'Beginner-Friendly Woodworking Projects', 'Hi everyone! I''m new to woodworking and looking for some beginner-friendly project ideas. Any suggestions?'),
    (2, 'Recommendations for a Reliable Table Saw', 'Hey, fellow woodworkers! I''m thinking of investing in a table saw. Any recommendations for a reliable model?'),
    (3, 'Preventing Wood Warping Tips', 'Does anyone have tips for preventing wood warping? I''ve had issues with my projects warping after a while.'),
    (4, 'Favorite Wood Finishes', 'I''m interested in learning about different types of wood finishes. What are your favorites?'),
    (5, 'Preferred Methods for Joining Wood Pieces', 'Hey, woodworkers! What''s your preferred method for joining wood pieces together?'),
    (6, 'Recommended Workbench Top Material', 'I''m planning to build a workbench for my shop. Any recommendations for the top material?'),
    (7, 'Getting Started with Wood Carving', 'Does anyone have experience with wood carving? I''d like to give it a try. Where should I start?'),
    (8, 'Chisel Sharpening Techniques', 'I''m having trouble sharpening my chisels. Any sharpening techniques you can recommend?');

INSERT INTO comments (user_id, topic_id, content)
VALUES
    (2, 1, 'Welcome! How about starting with a simple wooden cutting board? It''s a great way to practice basic woodworking skills.'),
    (3, 1, 'I agree. Another idea could be building a small shelf or a jewelry box. They''re relatively easy and practical projects.'),
    (10, 2, 'I''ve heard good things about the Dewalt DWE7491RS. It''s a sturdy and versatile table saw with great reviews.'),
    (4, 2, 'I have the Bosch 4100-10, and it''s been fantastic. The fence system is excellent, and it''s easy to use.'),
    (4, 3, 'One important tip is to properly seal the wood to prevent moisture absorption. Also, try to store your projects in a controlled environment.'),
    (7, 3, 'Using kiln-dried lumber and allowing it to acclimate to the workshop''s humidity can also help reduce warping.'),
    (5, 4, 'I love the natural look of Danish oil. It enhances the wood''s beauty while providing good protection.'),
    (6, 4, 'Shellac is my go-to finish. It''s easy to apply, dries quickly, and gives a warm, traditional look.'),
    (6, 5, 'I''m a fan of pocket hole joinery. It''s quick, strong, and doesn''t require advanced woodworking skills.'),
    (2, 5, 'For more decorative projects, I enjoy using dovetail joints. They add a touch of craftsmanship and create strong connections.'),
    (7, 6, 'Hardwood, such as maple or beech, is a popular choice for workbench tops due to its durability and resistance to wear.'),
    (8, 6, 'Another option is a laminated MDF (medium-density fiberboard) top. It''s affordable, flat, and provides a smooth work surface.'),
    (4, 7, 'Begin with basic hand tools like a carving knife, chisels, and gouges. Practice on softwoods like basswood to get the hang of it.'),
    (10, 7, 'Look for instructional videos or join a local carving group. They can provide guidance and valuable tips for beginners.'),
    (3, 8, 'Sharpening guides can be helpful for maintaining consistent angles. Also, consider using sharpening stones of different grits for a polished edge.'),
    (5, 8, 'Honing guides are great for beginners to ensure a consistent bevel. Don''t forget to strop the chisel after sharpening for a razor-sharp edge.')
;