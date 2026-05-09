BEGIN;

TRUNCATE TABLE
    narrative_cluster_posts,
    narrative_clusters,
    posts,
    incidents
RESTART IDENTITY CASCADE;

INSERT INTO incidents (id, name, is_active) VALUES
    ('inc_east_gippsland', 'East Gippsland fire complex', true),
    ('inc_grampians',      'Grampians National Park fire', true),
    ('inc_otway_ranges',   'Otway Ranges grass fire', true);

INSERT INTO posts
    (id, author_name, platform, content, ts, share_count, post_url, misinformation_risk_score)
VALUES
    ('post_001', '@vic_alerts_now',     'TWITTER',
     'BREAKING: CFA has just ordered FULL EVACUATION of Bairnsdale CBD. Leave NOW via the highway. Share to save lives.',
     '2026-01-22 06:14:00+11', 4520,
     'https://twitter.com/vic_alerts_now/status/1001', 0.9),

    ('post_002', 'Gippsland Community Watch', 'FACEBOOK',
     'Confirmed from a friend in CFA - Bairnsdale CBD is being evacuated as of this morning. Get out now, do not wait for official notice.',
     '2026-01-22 07:02:00+11', 2110,
     'https://facebook.com/groups/gippslandwatch/posts/2002', 0.8),

    ('post_003', 'u/eastgippy_local',   'REDDIT',
     'Anyone else hearing Bairnsdale needs to evacuate? My cousin says the order just came through but I cant find it on VicEmergency.',
     '2026-01-22 07:48:00+11', 860,
     'https://reddit.com/r/melbourne/comments/abc003', 0.7),

    ('post_004', '@truth_seeker_au',    'TWITTER',
     'The Grampians fire was deliberately lit. Multiple ignition points within 2km - that is not lightning, wake up Australia.',
     '2026-01-21 19:30:00+11', 3210,
     'https://twitter.com/truth_seeker_au/status/1004', 0.7),

    ('post_005', 'Concerned Victorians', 'FACEBOOK',
     'Why are they not telling us the Grampians fire was arson? Three separate starts in one afternoon, no storms in the area. Do the maths.',
     '2026-01-21 20:15:00+11', 1530,
     'https://facebook.com/groups/concernedvic/posts/2005', 0.6),

    ('post_006', '@gippy_traveller',    'TWITTER',
     'Lakes Entrance Rd is CLOSED do not attempt. Police turning everyone back at the bridge. #vicfires',
     '2026-01-22 11:05:00+11', 990,
     'https://twitter.com/gippy_traveller/status/1006', 0.7),

    ('post_007', '@bushfire_updates',   'TIKTOK',
     'POV: you tried to drive through Lakes Entrance and the road was shut. Stay home people, this fire is moving FAST.',
     '2026-01-22 12:40:00+11', 12480,
     'https://tiktok.com/@bushfire_updates/video/1007', 0.5),

    ('post_008', 'u/otway_weather_nerd', 'REDDIT',
     'Models are showing 45+ in the Otways tomorrow but BoM is downplaying it. Not saying conspiracy but...',
     '2026-01-23 08:22:00+11', 320,
     'https://reddit.com/r/melbourne/comments/abc008', 0.4),

    ('post_009', '@otways_local',       'TWITTER',
     'Heard from a mate at the bureau that tomorrow is going to be way worse than they are publicly saying. Be ready.',
     '2026-01-23 09:10:00+11', 145,
     'https://twitter.com/otways_local/status/1009', 0.3),

    ('post_010', 'Bushfire Recovery Help', 'FACEBOOK',
     'Victorian govt has just opened $5000 emergency rebuild grants for fire-affected residents. Apply within 24h: vic-rebuild-grants[.]net',
     '2026-01-20 14:55:00+11', 2840,
     'https://facebook.com/pages/recoveryhelp/posts/2010', 0.7),

    ('post_011', '@aus_relief_official', 'TIKTOK',
     'New $5K bushfire grant just dropped! Tap the link in bio to apply, takes 2 minutes. East Gippsland residents priority.',
     '2026-01-20 16:20:00+11', 8430,
     'https://tiktok.com/@aus_relief_official/video/1011', 0.6),

    ('post_012', '@grants_au',          'TWITTER',
     'PSA: $5000 emergency rebuild grant available for fire victims, link here. Spread the word, deadline is tight.',
     '2026-01-20 17:45:00+11', 670,
     'https://twitter.com/grants_au/status/1012', 0.5),

    ('post_013', 'u/wxwatcher_vic',     'REDDIT',
     'Anyone else feel like the wind change for Grampians tomorrow is being underplayed? Just a hunch.',
     '2026-01-21 21:30:00+11', 220,
     'https://reddit.com/r/melbourne/comments/abc013', 0.4),

    ('post_014', '@gramps_local',       'TWITTER',
     'BoM forecast for the Grampians tomorrow looks sus. Not panicking, just keeping an eye on it.',
     '2026-01-21 22:05:00+11', 95,
     'https://twitter.com/gramps_local/status/1014', 0.3);

INSERT INTO narrative_clusters (id, summary, incident_id, spread_status, review_status) VALUES
    ('nar_001',
     'False evacuation order for Bairnsdale CBD',
     'inc_east_gippsland', 'SPREADING_FAST',  'NEEDS_REVIEW'),

    ('nar_002',
     'Arson conspiracy claims about Grampians fire ignition',
     'inc_grampians',      'GROWING',  'CONFIRMED_MISINFORMATION'),

    ('nar_003',
     'False claim that Lakes Entrance Road is closed',
     'inc_east_gippsland', 'SPREADING_FAST',  'NEEDS_REVIEW'),

    ('nar_004',
     'Unverified weather speculation in the Otway Ranges',
     'inc_otway_ranges',   'STEADY',  'NEEDS_REVIEW'),

    ('nar_005',
     'Phishing scam impersonating a $5000 emergency rebuild grant',
     'inc_east_gippsland', 'GROWING',  'CORRECTION_PUBLISHED'),

    ('nar_006',
     'Low-credibility speculation about understated Grampians wind change',
     'inc_grampians',      'STEADY',  'DISMISSED');

INSERT INTO narrative_cluster_posts (cluster_id, post_id) VALUES
    ('nar_001', 'post_001'),
    ('nar_001', 'post_002'),
    ('nar_001', 'post_003'),

    ('nar_002', 'post_004'),
    ('nar_002', 'post_005'),

    ('nar_003', 'post_006'),
    ('nar_003', 'post_007'),

    ('nar_004', 'post_008'),
    ('nar_004', 'post_009'),

    ('nar_005', 'post_010'),
    ('nar_005', 'post_011'),
    ('nar_005', 'post_012'),

    ('nar_006', 'post_013'),
    ('nar_006', 'post_014');

COMMIT;
