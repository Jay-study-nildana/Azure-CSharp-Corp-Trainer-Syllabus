-- DC Comics Super Heroes & Super Villains - PostgreSQL Example Database
-- Purpose: comprehensive schema + seed data to demonstrate SELECT, JOINs, GROUP BY, HAVING, aggregates, and subqueries
-- Note: designed for PostgreSQL. Use this file to create the schema, populate sample rows, and run the example queries at the end.

-- ========================================
-- 1. SCHEMA CREATION
-- ========================================

-- Characters: unified table for heroes, villains, and antiheroes
CREATE TABLE characters (
  id              SERIAL PRIMARY KEY,
  name            TEXT NOT NULL,
  alias           TEXT,
  kind            TEXT NOT NULL CHECK (kind IN ('hero','villain','antihero')),
  origin_city     TEXT,
  debut_year      INT,
  strength_rating NUMERIC(3,1) DEFAULT 5.0 CHECK (strength_rating >= 0),
  intelligence_rating NUMERIC(3,1) DEFAULT 5.0 CHECK (intelligence_rating >= 0),
  is_active       BOOLEAN DEFAULT TRUE
);

-- Teams / organizations
CREATE TABLE teams (
  id           SERIAL PRIMARY KEY,
  name         TEXT NOT NULL UNIQUE,
  alignment    TEXT NOT NULL CHECK (alignment IN ('hero','villain','neutral','mixed')),
  founded_year INT,
  is_active    BOOLEAN DEFAULT TRUE
);

-- Many-to-many: characters <-> teams
CREATE TABLE character_team (
  id           SERIAL PRIMARY KEY,
  character_id INT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  team_id      INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  role         TEXT,
  joined_on    DATE,
  left_on      DATE,
  UNIQUE (character_id, team_id, joined_on)
);

-- Powers / abilities
CREATE TABLE powers (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL UNIQUE,
  description TEXT,
  power_tier INT NOT NULL CHECK (power_tier BETWEEN 1 AND 10) -- 1 = minor, 10 = godlike
);

-- Many-to-many: characters <-> powers with proficiency
CREATE TABLE character_power (
  id                SERIAL PRIMARY KEY,
  character_id      INT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  power_id          INT NOT NULL REFERENCES powers(id) ON DELETE CASCADE,
  proficiency_level INT NOT NULL CHECK (proficiency_level BETWEEN 1 AND 100), -- percent-like
  UNIQUE (character_id, power_id)
);

-- Artifacts (could be owned by characters)
CREATE TABLE artifacts (
  id               SERIAL PRIMARY KEY,
  name             TEXT NOT NULL UNIQUE,
  description      TEXT,
  power_level      INT NOT NULL DEFAULT 1 CHECK (power_level >= 0),
  owner_character_id INT REFERENCES characters(id) ON DELETE SET NULL
);

-- Battles / conflicts
CREATE TABLE battles (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  location    TEXT,
  battle_date DATE,
  description TEXT
);

-- Participants in battles: a many-to-many with role/outcome/damage
CREATE TABLE battle_participants (
  id            SERIAL PRIMARY KEY,
  battle_id     INT NOT NULL REFERENCES battles(id) ON DELETE CASCADE,
  character_id  INT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  side          TEXT NOT NULL CHECK (side IN ('hero','villain','neutral')),
  outcome       TEXT CHECK (outcome IN ('won','lost','draw','ongoing')),
  damage_taken  INT DEFAULT 0 CHECK (damage_taken >= 0)
);

-- Appearances (comics/movies/series) for demonstration counts
CREATE TABLE appearances (
  id           SERIAL PRIMARY KEY,
  character_id INT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  medium       TEXT NOT NULL, -- e.g., 'comic', 'movie', 'series'
  title        TEXT NOT NULL,
  year         INT
);

-- Missions assigned to teams (to show aggregation by team)
CREATE TABLE missions (
  id              SERIAL PRIMARY KEY,
  name            TEXT NOT NULL,
  assigned_team_id INT REFERENCES teams(id) ON DELETE SET NULL,
  mission_date    DATE,
  success         BOOLEAN,
  casualties      INT DEFAULT 0 CHECK (casualties >= 0),
  notes           TEXT
);

-- Indexes to support common queries (joins and filters)
CREATE INDEX idx_characters_kind ON characters(kind);
CREATE INDEX idx_character_team_team ON character_team(team_id);
CREATE INDEX idx_character_power_power ON character_power(power_id);
CREATE INDEX idx_battle_participants_battle ON battle_participants(battle_id);
CREATE INDEX idx_appearances_character ON appearances(character_id);

-- ========================================
-- 2. SAMPLE DATA INSERTS
-- ========================================
-- Insert characters (heroes and villains)
INSERT INTO characters (id, name, alias, kind, origin_city, debut_year, strength_rating, intelligence_rating, is_active) VALUES
  (1, 'Kal-El',                'Superman',       'hero',      'Krypton/Metropolis',  1938, 10.0, 8.5, TRUE),
  (2, 'Bruce Wayne',           'Batman',         'hero',      'Gotham',              1939, 7.5,  10.0, TRUE),
  (3, 'Diana Prince',          'Wonder Woman',   'hero',      'Themyscira',         1941, 9.0,  8.0, TRUE),
  (4, 'Barry Allen',           'Flash',          'hero',      'Central City',        1956, 8.5,  7.0, TRUE),
  (5, 'Hal Jordan',            'Green Lantern',  'hero',      'Coast City',          1959, 7.0,  7.5, TRUE),
  (6, 'Arthur Curry',          'Aquaman',        'hero',      'Atlantis',            1941, 7.5,  6.5, TRUE),
  (7, 'Jonn Jonzz',        'Martian Manhunter', 'hero',   'Mars',                1955, 8.0,  8.5, TRUE),
  (8, 'Joker',                 NULL,             'villain',   'Gotham',              1940, 3.5,  9.0, TRUE),
  (9, 'Lex Luthor',            NULL,             'villain',   'Metropolis',          1940, 3.0,  10.0, TRUE),
  (10, 'Darkseid',             NULL,             'villain',   'Apokolips',           1970, 10.0, 9.5, TRUE),
  (11, 'Cheetah',              NULL,             'villain',   'Unknown',             1943, 6.5,  5.5, TRUE),
  (12, 'Eobard Thawne',        'Reverse-Flash',  'villain',   'Unknown',             1961, 8.5,  7.0, TRUE),
  (13, 'Sinestro',             NULL,             'villain',   'Korugar',             1961, 7.5,  8.0, TRUE),
  (14, 'Harley Quinn',         NULL,             'villain',   'Gotham',              1992, 3.5,  6.0, TRUE),
  (15, 'Bane',                 NULL,             'villain',   'Countries Unknown',   1993, 8.0,  6.5, TRUE),
  (16, 'Doomsday',             NULL,             'villain',   'Krypton',             1992, 10.0, 1.0, TRUE);

-- Teams
INSERT INTO teams (id, name, alignment, founded_year, is_active) VALUES
  (1, 'Justice League', 'hero', 1960, TRUE),
  (2, 'Suicide Squad',  'mixed', 1987, TRUE),
  (3, 'Legion of Doom', 'villain', 1970, TRUE),
  (4, 'Teen Titans',    'hero', 1964, TRUE),
  (5, 'Injustice League','villain', 1983, FALSE);

-- Character - Team memberships
INSERT INTO character_team (character_id, team_id, role, joined_on) VALUES
  (1, 1, 'Founding Member', '1960-01-01'),
  (2, 1, 'Tactical Lead',   '1960-01-01'),
  (3, 1, 'Ambassador',      '1960-01-01'),
  (4, 1, 'Speedster',       '1960-01-01'),
  (5, 1, 'Lantern Corps Liaison', '1960-01-01'),
  (6, 1, 'Atlantean Representative','1960-01-01'),
  (7, 1, 'Telepathic Support','1960-01-01'),
  (8, 3, 'Agent of Chaos',  '1940-01-01'),
  (9, 3, 'Mastermind',      '1940-01-01'),
  (10, 3, 'Overlord',       '1970-01-01'),
  (11, 3, 'Assassin',       '1943-01-01'),
  (12, 3, 'Speed Rival',    '1961-01-01'),
  (13, 3, 'Sinestro Corps', '1961-01-01'),
  (14, 2, 'Wildcard',       '1992-01-01'),
  (15, 3, 'Brawler',        '1993-01-01'),
  (16, 3, 'Apocalyptic Force','1992-01-01');

-- Powers
INSERT INTO powers (id, name, description, power_tier) VALUES
  (1, 'Flight', 'Ability to fly at high speeds', 9),
  (2, 'Super Strength', 'Exceptional strength beyond human limits', 10),
  (3, 'X-Ray Vision', 'See through solids', 7),
  (4, 'Super Speed', 'Move at extraordinary speeds', 9),
  (5, 'Ring Constructs', 'Create solid constructs using a power ring', 8),
  (6, 'Aquatic Telepathy', 'Communicate with and command sea life', 6),
  (7, 'Shape Shifting', 'Change physical form', 8),
  (8, 'Genius Intellect', 'Advanced scientific and strategic intellect', 10),
  (9, 'Chemistry/Explosives', 'Knowledge and use of unstable compounds and traps', 5),
  (10, 'Fear Manipulation', 'Project and amplify fear', 8),
  (11, 'Martial Arts', 'Mastery of combat techniques', 6),
  (12, 'Regeneration', 'Recover from injury rapidly', 8),
  (13, 'Omega Effect', 'Cosmic-level destructive power', 10),
  (14, 'Telepathy', 'Read and influence minds', 9);

-- Character powers (proficiency percent)
INSERT INTO character_power (character_id, power_id, proficiency_level) VALUES
  (1, 1, 100), -- Superman: Flight
  (1, 2, 100), -- Superman: Super Strength
  (1, 3, 95),  -- Superman: X-Ray
  (2, 11, 95), -- Batman: Martial Arts
  (2, 8, 95),  -- Batman: Genius Intellect
  (3, 2, 90),  -- Wonder Woman: Super Strength
  (3, 11, 85), -- Wonder Woman: Martial Arts
  (4, 4, 100), -- Flash: Super Speed
  (12, 4, 95), -- Reverse-Flash: Super Speed
  (5, 5, 90),  -- Green Lantern: Ring Constructs
  (13, 5, 85), -- Sinestro: Ring Constructs
  (6, 6, 90),  -- Aquaman: Aquatic Telepathy
  (7, 7, 80),  -- Martian Manhunter: Shape Shifting
  (7, 14, 90), -- Martian Manhunter: Telepathy
  (9, 8, 100), -- Lex Luthor: Genius Intellect
  (10,13,100), -- Darkseid: Omega Effect
  (11, 2, 65), -- Cheetah: Super Strength
  (11, 11, 65),-- Cheetah: Martial Arts
  (14,9,70),   -- Harley Quinn: Chemistry/Explosives
  (15,2,85),   -- Bane: Super Strength (Venom-enhanced)
  (16,2,100),  -- Doomsday: Super Strength
  (16,12,90);  -- Doomsday: Regeneration

-- Artifacts
INSERT INTO artifacts (name, description, power_level, owner_character_id) VALUES
  ('Mother Box', 'Alien technology with reality-bending functions', 9, NULL),
  ('Power Ring (Hal Jordan)', 'Green Lantern power ring', 9, 5),
  ('Kryptonian Codex', 'Ancient Kryptonian knowledge artifact', 8, 1);

-- Battles
INSERT INTO battles (id, name, location, battle_date, description) VALUES
  (1, 'Battle of Metropolis', 'Metropolis', '1993-06-12', 'Major clash in central Metropolis'),
  (2, 'Gotham Showdown', 'Gotham', '2011-10-31', 'Battle in the streets of Gotham'),
  (3, 'Apokolips Invasion', 'Apokolips', '2005-03-03', 'Invasion led by Darkseid'),
  (4, 'Speed War', 'Central City', '2015-04-01', 'High-speed clash involving speedsters'),
  (5, 'Amazon Skirmish', 'Themyscira', '2008-08-08', 'Conflict on the isle of Themyscira');

-- Battle participants with outcomes and damage taken
INSERT INTO battle_participants (battle_id, character_id, side, outcome, damage_taken) VALUES
  (1, 1, 'hero', 'won', 20),   -- Superman
  (1, 9, 'villain', 'lost', 80),-- Lex Luthor (defeated)
  (1, 10, 'villain', 'lost', 95),-- Darkseid (surprising defeat for demo)
  (2, 2, 'hero', 'won', 30),    -- Batman
  (2, 8, 'villain', 'lost', 60),-- Joker
  (2, 14, 'villain', 'lost', 50),-- Harley Quinn
  (3, 10, 'villain', 'won', 0), -- Darkseid (won on Apokolips)
  (3, 1, 'hero', 'lost', 100),  -- Superman (sustained heavy damage)
  (4, 4, 'hero', 'won', 10),    -- Flash
  (4, 12, 'villain', 'lost', 30), -- Reverse-Flash
  (5, 3, 'hero', 'won', 5),     -- Wonder Woman
  (5, 11, 'villain', 'lost', 40),-- Cheetah
  (1, 5, 'hero', 'won', 15),    -- Green Lantern
  (1, 7, 'hero', 'won', 10),    -- Martian Manhunter
  (3, 16, 'villain', 'won', 10),-- Doomsday on Apokolips
  (3, 15, 'villain', 'won', 5); -- Bane (affiliate role)

-- Appearances to demonstrate aggregation across mediums
INSERT INTO appearances (character_id, medium, title, year) VALUES
  (1, 'comic', 'Action Comics #1', 1938),
  (1, 'movie', 'Man of Steel', 2013),
  (2, 'comic', 'Detective Comics #27', 1939),
  (2, 'movie', 'The Dark Knight', 2008),
  (3, 'comic', 'All Star Comics #8', 1941),
  (4, 'comic', 'Showcase #4', 1956),
  (4, 'series', 'The Flash (TV)', 2014),
  (9, 'comic', 'Action Comics #23', 1940),
  (8, 'comic', 'Batman #1', 1940),
  (10, 'comic', 'Forever People #1', 1970);

-- Missions
INSERT INTO missions (name, assigned_team_id, mission_date, success, casualties, notes) VALUES
  ('Stop Lex''s Engine', 1, '1993-06-12', TRUE, 0, 'Successful sabotage of the engine'),
  ('Contain Metahuman Leak', 1, '2015-04-02', TRUE, 1, 'Minor casualties during extraction'),
  ('Apokolips Defense', 3, '2005-03-03', FALSE, 500, 'Catastrophic losses for defenders');

-- ========================================
-- 3. SAMPLE QUERIES: SELECT, JOINs, GROUP BY, HAVING, AGGREGATES, SUBQUERIES
-- ========================================
-- 3.1 Basic SELECT: find active heroes with high strength
SELECT id, name, alias, origin_city, strength_rating
FROM characters
WHERE kind = 'hero' AND is_active = TRUE AND strength_rating > 8.0
ORDER BY strength_rating DESC, name
LIMIT 10;

-- 3.2 JOIN: list characters with their current teams (if any)
SELECT c.id AS character_id, c.name AS character_name, c.alias, c.kind,
       t.id AS team_id, t.name AS team_name, ct.role, ct.joined_on
FROM characters c
LEFT JOIN character_team ct ON ct.character_id = c.id AND ct.left_on IS NULL
LEFT JOIN teams t ON t.id = ct.team_id
ORDER BY c.kind, c.name;

-- 3.3 JOIN across three tables: characters with their powers and proficiency
SELECT c.name AS character, COALESCE(c.alias,'-') AS alias, p.name AS power, cp.proficiency_level
FROM character_power cp
JOIN characters c ON c.id = cp.character_id
JOIN powers p ON p.id = cp.power_id
ORDER BY c.name, cp.proficiency_level DESC;

-- 3.4 Aggregate + GROUP BY: number of members per team
SELECT t.id AS team_id, t.name AS team_name, COUNT(ct.character_id) AS member_count
FROM teams t
LEFT JOIN character_team ct ON ct.team_id = t.id
GROUP BY t.id, t.name
ORDER BY member_count DESC, t.name;

-- 3.5 Aggregate with AVG: average strength per team (only currently assigned members)
SELECT t.name AS team_name,
       COUNT(ct.character_id) AS members,
       ROUND(AVG(c.strength_rating)::numeric,2) AS avg_strength,
       ROUND(AVG(c.intelligence_rating)::numeric,2) AS avg_intelligence
FROM teams t
JOIN character_team ct ON ct.team_id = t.id
JOIN characters c ON c.id = ct.character_id
WHERE ct.left_on IS NULL OR ct.left_on IS NULL -- explicit to emphasize current membership
GROUP BY t.name
ORDER BY avg_strength DESC;

-- 3.6 HAVING: teams with more than 2 active members and average strength > 7.0
SELECT t.name AS team_name,
       COUNT(c.id) AS active_members,
       ROUND(AVG(c.strength_rating)::numeric,2) AS avg_strength
FROM teams t
JOIN character_team ct ON ct.team_id = t.id
JOIN characters c ON c.id = ct.character_id
WHERE c.is_active = TRUE
GROUP BY t.name
HAVING COUNT(c.id) > 2 AND AVG(c.strength_rating) > 7.0
ORDER BY avg_strength DESC;

-- 3.7 Aggregates: battle statistics per character (total battles, wins, total damage taken)
SELECT c.id AS character_id, c.name, c.kind,
       COUNT(bp.battle_id) AS battles_fought,
       SUM(CASE WHEN bp.outcome = 'won' THEN 1 ELSE 0 END) AS battles_won,
       SUM(bp.damage_taken) AS total_damage_taken,
       MAX(bp.damage_taken) AS worst_single_battle_damage
FROM characters c
LEFT JOIN battle_participants bp ON bp.character_id = c.id
GROUP BY c.id, c.name, c.kind
ORDER BY battles_fought DESC, battles_won DESC;

-- 3.8 STRING_AGG: list powers per character as a comma-separated string
SELECT c.name AS character, 
       COALESCE(STRING_AGG(p.name, ', ' ORDER BY p.name), '') AS powers
FROM characters c
LEFT JOIN character_power cp ON cp.character_id = c.id
LEFT JOIN powers p ON p.id = cp.power_id
GROUP BY c.id, c.name
ORDER BY c.name;

-- 3.9 Subquery (scalar): find the most powerful hero by strength_rating
SELECT id, name, alias, strength_rating
FROM characters
WHERE kind = 'hero' AND strength_rating = (
  SELECT MAX(strength_rating) FROM characters WHERE kind = 'hero'
);

-- 3.10 Correlated subquery: for each hero, count how many battles they have WON
SELECT c.id, c.name,
       (SELECT COUNT(*) FROM battle_participants bp
        WHERE bp.character_id = c.id AND bp.outcome = 'won') AS wins
FROM characters c
WHERE c.kind = 'hero'
ORDER BY wins DESC, c.name;

-- 3.11 Subquery with IN: characters who have faced Darkseid in any battle
SELECT DISTINCT c.name AS character
FROM characters c
WHERE c.id IN (
  SELECT bp.character_id FROM battle_participants bp
  WHERE bp.battle_id IN (
    SELECT battle_id FROM battle_participants
    WHERE character_id = (SELECT id FROM characters WHERE name = 'Darkseid' LIMIT 1)
  )
)
ORDER BY character;

-- 3.12 EXISTS subquery: list villains who have at least one battle victory
SELECT v.id, v.name
FROM characters v
WHERE v.kind = 'villain'
  AND EXISTS (
    SELECT 1 FROM battle_participants bp WHERE bp.character_id = v.id AND bp.outcome = 'won'
  )
ORDER BY v.name;

-- 3.13 Derived table (subquery in FROM): top powers by number of distinct characters possessing them
SELECT power_name, holder_count
FROM (
  SELECT p.name AS power_name, COUNT(DISTINCT cp.character_id) AS holder_count
  FROM powers p
  LEFT JOIN character_power cp ON cp.power_id = p.id
  GROUP BY p.name
) AS power_stats
ORDER BY holder_count DESC, power_name
LIMIT 10;

-- 3.14 Complex query: per-team battle performance (total battles involving team members, wins by side)
-- Approach: find battles that had at least one member of the team participate, then aggregate outcomes
SELECT t.name AS team_name,
       COUNT(DISTINCT bp.battle_id) AS battles_involved,
       SUM(CASE WHEN bp.side = 'hero' AND bp.outcome = 'won' THEN 1 ELSE 0 END) AS hero_side_wins,
       SUM(CASE WHEN bp.side = 'villain' AND bp.outcome = 'won' THEN 1 ELSE 0 END) AS villain_side_wins
FROM teams t
JOIN character_team ct ON ct.team_id = t.id
JOIN battle_participants bp ON bp.character_id = ct.character_id
GROUP BY t.name
ORDER BY battles_involved DESC, team_name;

-- 3.15 Subquery with aggregation and HAVING: identify powers used by more than 2 active characters
SELECT p.name, COUNT(DISTINCT cp.character_id) AS active_holders
FROM powers p
JOIN character_power cp ON cp.power_id = p.id
JOIN characters c ON c.id = cp.character_id
WHERE c.is_active = TRUE
GROUP BY p.name
HAVING COUNT(DISTINCT cp.character_id) > 2
ORDER BY active_holders DESC, p.name;

-- 3.16 Nested aggregates: characters whose average proficiency across their powers is above a threshold
SELECT c.name, ROUND(avg_proficiency::numeric,2) AS avg_proficiency
FROM (
  SELECT cp.character_id, AVG(cp.proficiency_level) AS avg_proficiency
  FROM character_power cp
  GROUP BY cp.character_id
) AS avgp
JOIN characters c ON c.id = avgp.character_id
WHERE avgp.avg_proficiency > 80
ORDER BY avgp.avg_proficiency DESC, c.name;

-- 3.17 Subquery for ranking: characters with higher-than-average strength among heroes
SELECT id, name, strength_rating
FROM characters
WHERE kind = 'hero' AND strength_rating > (
  SELECT AVG(strength_rating) FROM characters WHERE kind = 'hero'
)
ORDER BY strength_rating DESC;

-- 3.18 Use of DISTINCT in aggregate contexts: count how many unique teams heroes belong to (per hero)
SELECT c.name, COUNT(DISTINCT ct.team_id) AS teams_count
FROM characters c
LEFT JOIN character_team ct ON ct.character_id = c.id
GROUP BY c.name
ORDER BY teams_count DESC, c.name;

-- 3.19 Example: list characters who have appeared in both comics AND movies (subquery with INTERSECT-like logic)
SELECT DISTINCT c.name
FROM appearances a
JOIN characters c ON c.id = a.character_id
WHERE a.character_id IN (SELECT character_id FROM appearances WHERE medium = 'comic')
  AND a.character_id IN (SELECT character_id FROM appearances WHERE medium = 'movie')
ORDER BY c.name;

-- 3.20 Composite example: For each character, show name, total battles, wins, losses, and win_rate (use NULL-safe division)
SELECT c.id, c.name,
       COALESCE(SUM(CASE WHEN bp.battle_id IS NOT NULL THEN 1 ELSE 0 END),0) AS total_battles,
       COALESCE(SUM(CASE WHEN bp.outcome = 'won' THEN 1 ELSE 0 END),0) AS wins,
       COALESCE(SUM(CASE WHEN bp.outcome = 'lost' THEN 1 ELSE 0 END),0) AS losses,
       CASE WHEN COALESCE(SUM(CASE WHEN bp.battle_id IS NOT NULL THEN 1 ELSE 0 END),0) = 0 THEN NULL
            ELSE ROUND(100.0 * COALESCE(SUM(CASE WHEN bp.outcome = 'won' THEN 1 ELSE 0 END),0) /
                       COALESCE(SUM(CASE WHEN bp.battle_id IS NOT NULL THEN 1 ELSE 0 END),0),2)
       END AS win_rate_percent
FROM characters c
LEFT JOIN battle_participants bp ON bp.character_id = c.id
GROUP BY c.id, c.name
ORDER BY win_rate_percent DESC NULLS LAST, total_battles DESC;

-- ========================================
-- End of file
-- ========================================

-- If you want to reset and start over. 

-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;
-- GRANT ALL ON SCHEMA public TO postgres;
-- GRANT ALL ON SCHEMA public TO public;