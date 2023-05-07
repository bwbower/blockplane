INSERT INTO users (username, password_digest)
VALUES ('admin', crypt('password', gen_salt('bf'))),
       ('johnny', crypt('cash$$$', gen_salt('bf'))),
       ('dolly', crypt('jolene', gen_salt('bf'))),
       ('frank', crypt('ocean', gen_salt('bf'))),
       ('tom', crypt('waitsforit', gen_salt('bf')))
;

INSERT INTO topics (user_id, title, content)
VALUES (1, 'Welcome!', 'Welcome to the online forum, I''m your friendly admin!'),
       (2, 'What a Great Forum!', 'This is a really great forum.'),
       (4, 'Forum Purpose', 'I think this forum should have some kind of unifying vision. What do you all think?'),
       (5, 'How does this forum work?', 'I''m not very good with the internets.'),
       (3, 'New topic', 'I''d like to have some new topics on this forum.'),
       (2, 'Yet another new topic', 'Just wanted to showcase the handy ''next page'' feature, for pagination purposes')
;

INSERT INTO comments (user_id, topic_id, content)
VALUES (2, 1, 'Thanks for making this great site, admin!'),
       (1, 1, 'You''re welcome!'),
       (3, 1, 'How do you create new topics?'),
       (1, 1, 'Simply click the "Create Topic" button at the top of the homepage!'),
       (3, 1, 'Great, I''ll do that now!'),
       (1, 2, 'Glad you''re enjoying it!'),
       (2, 3, 'I guess this forum could be about anything.'),
       (1, 3, 'Yeah but shouldn''t it be about something specific?'),
       (3, 3, 'I don''t know, does it really matter?'),
       (4, 3, 'I think so.'),
       (2, 3, 'Well I disagree.'),
       (5, 3, 'Okay, agree to disagree.')
;