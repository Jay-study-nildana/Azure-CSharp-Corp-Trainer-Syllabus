-- DC Comics: CTEs, Window Functions, and Transactions - PostgreSQL Example
-- Purpose: Demonstrate Common Table Expressions (non-recursive and recursive),
-- window functions (ROW_NUMBER, RANK, DENSE_RANK, running totals), and transaction patterns
-- Includes schema creation, seed data, and many sample queries and transaction examples.
-- Intended for PostgreSQL.

-- ========================================
-- 1. SCHEMA
-- ========================================

-- Characters
CREATE TABLE characters (
  id              SERIAL PRIMARY KEY,
  name            TEXT NOT NULL,
  alias           TEXT,
  kind            TEXT NOT NULL CHECK (kind IN ('hero','villain','antihero')),
  origin_city     TEXT,
  debut_year      INT,
  strength_rating NUMERIC(3,1) DEFAULT 5.0,
  intelligence_rating NUMERIC(3,1) DEFAULT 5.0,
  is_active       BOOLEAN DEFAULT TRUE
);

-- Teams with hierarchical parent relationship to allow recursive CTEs
CREATE TABLE teams (
  id            SERIAL PRIMARY KEY,
  name          TEXT NOT NULL UNIQUE,
  alignment     TEXT NOT NULL CHECK (alignment IN ('hero','villain','mixed','neutral')),
  founded_year  INT,
  parent_team_id INT REFERENCES teams(id) ON DELETE SET NULL
);

-- Team membership (many-to-many)
CREATE TABLE character_team (
  id           SERIAL PRIMARY KEY,
  character_id INT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  team_id      INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  role         TEXT,
  joined_on    DATE,
  left_on      DATE,
  UNIQUE (character_id, team_id, joined_on)
);

-- Powers and character_power (many-to-many)
CREATE TABLE powers (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL UNIQUE,
  description TEXT,
  power_tier INT NOT NULL CHECK (power_tier BETWEEN 1 AND 10)
);

CREATE TABLE character_power (
  id                SERIAL PRIMARY KEY,
  character_id      INT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  power_id          INT NOT NULL REFERENCES powers(id) ON DELETE CASCADE,
  proficiency_level INT NOT NULL CHECK (proficiency_level BETWEEN 0 AND 100),
  UNIQUE (character_id, power_id)
);

-- Mentorships to demonstrate recursive relationships (mentor -> mentee)
CREATE TABLE mentorships (
  id          SERIAL PRIMARY KEY,
  mentor_id   INT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  mentee_id   INT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  started_on  DATE
);

-- Artifacts to show transactional transfers
CREATE TABLE artifacts (
  id                 SERIAL PRIMARY KEY,
  name               TEXT NOT NULL UNIQUE,
  description        TEXT,
  power_level        INT NOT NULL DEFAULT 1,
  owner_character_id INT REFERENCES characters(id) ON DELETE SET NULL
);

-- Battles and participants to demonstrate windowed running totals
CREATE TABLE battles (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  battle_date DATE,
  location    TEXT,
  description TEXT
);

CREATE TABLE battle_participants (
  id            SERIAL PRIMARY KEY,
  battle_id     INT NOT NULL REFERENCES battles(id) ON DELETE CASCADE,
  character_id  INT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  side          TEXT NOT NULL CHECK (side IN ('hero','villain','neutral')),
  outcome       TEXT CHECK (outcome IN ('won','lost','draw','ongoing')),
  damage_taken  INT DEFAULT 0 CHECK (damage_taken >= 0)
);

-- Useful indexes
CREATE INDEX idx_characters_kind ON characters(kind);
CREATE INDEX idx_team_parent ON teams(parent_team_id);
CREATE INDEX idx_battle_participants_character ON battle_participants(character_id);
CREATE INDEX idx_mentorships_mentor ON mentorships(mentor_id);

-- ========================================
-- 2. SEED DATA
-- ========================================

-- Characters (heroes and villains)
INSERT INTO characters (name, alias, kind, origin_city, debut_year, strength_rating, intelligence_rating, is_active) VALUES
  ('Kal-El', 'Superman', 'hero', 'Krypton/Metropolis', 1938, 10.0, 8.5, TRUE),
  ('Bruce Wayne', 'Batman', 'hero', 'Gotham', 1939, 7.5, 10.0, TRUE),
  ('Diana Prince', 'Wonder Woman', 'hero', 'Themyscira', 1941, 9.0, 8.0, TRUE),
  ('Barry Allen', 'Flash', 'hero', 'Central City', 1956, 8.5, 7.0, TRUE),
  ('Hal Jordan', 'Green Lantern', 'hero', 'Coast City', 1959, 7.0, 7.5, TRUE),
  ('Arthur Curry', 'Aquaman', 'hero', 'Atlantis', 1941, 7.5, 6.5, TRUE),
  ('Jonn Jonzz', 'Martian Manhunter', 'hero', 'Mars', 1955, 8.0, 8.5, TRUE),
  ('Joker', NULL, 'villain', 'Gotham', 1940, 3.5, 9.0, TRUE),
  ('Lex Luthor', NULL, 'villain', 'Metropolis', 1940, 3.0, 10.0, TRUE),
  ('Darkseid', NULL, 'villain', 'Apokolips', 1970, 10.0, 9.5, TRUE),
  ('Harley Quinn', NULL, 'villain', 'Gotham', 1992, 3.5, 6.0, TRUE),
  ('Bane', NULL, 'villain', 'Unknown', 1993, 8.0, 6.5, TRUE),
  ('Sinestro', NULL, 'villain', 'Korugar', 1961, 7.5, 8.0, TRUE),
  ('Eobard Thawne', 'Reverse-Flash', 'villain', 'Unknown', 1961, 8.5, 7.0, TRUE);

-- Teams with a simple hierarchy (parent_team_id)
INSERT INTO teams (name, alignment, founded_year, parent_team_id) VALUES
  ('Justice League', 'hero', 1960, NULL),
  ('Justice League International', 'hero', 1987, 1), -- child of Justice League
  ('Legion of Doom', 'villain', 1970, NULL),
  ('Sinestro Corps', 'villain', 1961, 3),
  ('Teen Titans', 'hero', 1964, 1);

-- Team memberships
INSERT INTO character_team (character_id, team_id, role, joined_on) VALUES
  ((SELECT id FROM characters WHERE alias = 'Superman'), 1, 'Founding Member', '1960-01-01'),
  ((SELECT id FROM characters WHERE alias = 'Batman'), 1, 'Tactical Lead', '1960-01-01'),
  ((SELECT id FROM characters WHERE alias = 'Wonder Woman'), 1, 'Ambassador', '1960-01-01'),
  ((SELECT id FROM characters WHERE alias = 'Flash'), 1, 'Speedster', '1960-01-01'),
  ((SELECT id FROM characters WHERE alias = 'Green Lantern'), 1, 'Lantern Corps Liaison', '1960-01-01'),
  ((SELECT id FROM characters WHERE name = 'Lex Luthor'), 3, 'Mastermind', '1940-01-01'),
  ((SELECT id FROM characters WHERE name = 'Darkseid'), 3, 'Overlord', '1970-01-01'),
  ((SELECT id FROM characters WHERE name = 'Sinestro'), 4, 'Sinestro Corps Founder', '1961-01-01'),
  ((SELECT id FROM characters WHERE name = 'Harley Quinn'), 3, 'Wildcard', '1992-01-01'),
  ((SELECT id FROM characters WHERE name = 'Bane'), 3, 'Brute', '1993-01-01');

-- Powers
INSERT INTO powers (name, description, power_tier) VALUES
  ('Flight', 'Ability to fly', 9),
  ('Super Strength', 'Superhuman strength', 10),
  ('Super Speed', 'Extreme speed', 9),
  ('Ring Constructs', 'Create constructs via power ring', 8),
  ('Genius Intellect', 'Advanced intellect and strategy', 10),
  ('Regeneration', 'Rapid recovery from injury', 8),
  ('Fear Projection', 'Induce fear in others', 8);

-- Character powers
INSERT INTO character_power (character_id, power_id, proficiency_level) VALUES
  ((SELECT id FROM characters WHERE alias = 'Superman'), (SELECT id FROM powers WHERE name = 'Flight'), 100),
  ((SELECT id FROM characters WHERE alias = 'Superman'), (SELECT id FROM powers WHERE name = 'Super Strength'), 100),
  ((SELECT id FROM characters WHERE alias = 'Flash'), (SELECT id FROM powers WHERE name = 'Super Speed'), 100),
  ((SELECT id FROM characters WHERE alias = 'Green Lantern'), (SELECT id FROM powers WHERE name = 'Ring Constructs'), 90),
  ((SELECT id FROM characters WHERE name = 'Lex Luthor'), (SELECT id FROM powers WHERE name = 'Genius Intellect'), 100),
  ((SELECT id FROM characters WHERE name = 'Darkseid'), (SELECT id FROM powers WHERE name = 'Regeneration'), 95),
  ((SELECT id FROM characters WHERE name = 'Sinestro'), (SELECT id FROM powers WHERE name = 'Fear Projection'), 85);

-- Mentorships (mentor -> mentee) to form a chain for recursive CTEs
-- Example chains: Bruce Wayne mentors a younger hero; Batman -> Nightwing (not created) => use Batman->Harley Quinn (for demo), Lex mentors Sinestro (demo)
INSERT INTO mentorships (mentor_id, mentee_id, started_on) VALUES
  ((SELECT id FROM characters WHERE alias = 'Batman'), (SELECT id FROM characters WHERE name = 'Harley Quinn'), '2010-01-01'),
  ((SELECT id FROM characters WHERE name = 'Lex Luthor'), (SELECT id FROM characters WHERE name = 'Sinestro'), '2000-05-05'),
  ((SELECT id FROM characters WHERE alias = 'Superman'), (SELECT id FROM characters WHERE name = 'Eobard Thawne'), '2001-06-06');

-- Artifacts
INSERT INTO artifacts (name, description, power_level, owner_character_id) VALUES
  ('Kryptonian Codex', 'Ancient Kryptonian knowledge artifact', 8, (SELECT id FROM characters WHERE alias = 'Superman')),
  ('Green Lantern Power Ring', 'High-energy ring for willpower constructs', 9, (SELECT id FROM characters WHERE alias = 'Green Lantern')),
  ('Mother Box', 'Alien device with reality-bending tech', 10, NULL);

-- Battles and participants
INSERT INTO battles (name, battle_date, location, description) VALUES
  ('Battle of Metropolis', '1993-06-12', 'Metropolis', 'Large scale fight'),
  ('Gotham Skirmish', '2011-10-31', 'Gotham', 'Urban conflict'),
  ('Apokolips Invasion', '2005-03-03', 'Apokolips', 'Interplanetary invasion'),
  ('Speed War', '2015-04-01', 'Central City', 'Speedsters clash');

INSERT INTO battle_participants (battle_id, character_id, side, outcome, damage_taken) VALUES
  ((SELECT id FROM battles WHERE name = 'Battle of Metropolis'), (SELECT id FROM characters WHERE alias = 'Superman'), 'hero', 'won', 20),
  ((SELECT id FROM battles WHERE name = 'Battle of Metropolis'), (SELECT id FROM characters WHERE name = 'Lex Luthor'), 'villain', 'lost', 80),
  ((SELECT id FROM battles WHERE name = 'Gotham Skirmish'), (SELECT id FROM characters WHERE alias = 'Batman'), 'hero', 'won', 30),
  ((SELECT id FROM battles WHERE name = 'Gotham Skirmish'), (SELECT id FROM characters WHERE name = 'Joker'), 'villain', 'lost', 60),
  ((SELECT id FROM battles WHERE name = 'Apokolips Invasion'), (SELECT id FROM characters WHERE name = 'Darkseid'), 'villain', 'won', 0),
  ((SELECT id FROM battles WHERE name = 'Apokolips Invasion'), (SELECT id FROM characters WHERE alias = 'Superman'), 'hero', 'lost', 100),
  ((SELECT id FROM battles WHERE name = 'Speed War'), (SELECT id FROM characters WHERE alias = 'Flash'), 'hero', 'won', 10),
  ((SELECT id FROM battles WHERE name = 'Speed War'), (SELECT id FROM characters WHERE name = 'Eobard Thawne'), 'villain', 'lost', 30);

-- ========================================
-- 3. CTEs (Common Table Expressions)
-- ========================================

-- 3.1 Simple non-recursive CTE chain
-- Step 1: active heroes
-- Step 2: heroes with strong physical strength (>8)
-- Step 3: top hero per intelligence among the strong heroes
WITH active_heroes AS (
  SELECT id, name, alias, strength_rating, intelligence_rating
  FROM characters
  WHERE kind = 'hero' AND is_active = TRUE
),
strong_heroes AS (
  SELECT * FROM active_heroes WHERE strength_rating > 8.0
),
top_intelligence AS (
  SELECT *, ROW_NUMBER() OVER (ORDER BY intelligence_rating DESC) AS rn
  FROM strong_heroes
)
SELECT id, name, alias, strength_rating, intelligence_rating
FROM top_intelligence
WHERE rn = 1;

-- 3.2 Using MATERIALIZED / NOT MATERIALIZED hint (planner control)
-- We compute recent battles and then aggregate participants. MATERIALIZED forces a materialized CTE.
WITH recent_battles AS MATERIALIZED (
  SELECT id FROM battles WHERE battle_date >= '2000-01-01'
),
participants AS (
  SELECT bp.* FROM battle_participants bp
  JOIN recent_battles rb ON rb.id = bp.battle_id
)
SELECT bp.character_id, COUNT(*) AS battles_count
FROM participants bp
GROUP BY bp.character_id
ORDER BY battles_count DESC;

-- 3.3 Chained CTE with aggregation and filtering
WITH hero_battles AS (
  SELECT c.id AS character_id, c.name,
         COUNT(bp.battle_id) AS fights,
         SUM(bp.damage_taken) AS total_damage
  FROM characters c
  LEFT JOIN battle_participants bp ON bp.character_id = c.id
  WHERE c.kind = 'hero'
  GROUP BY c.id, c.name
),
healthy_heroes AS (
  SELECT character_id, name, fights, total_damage
  FROM hero_battles
  WHERE COALESCE(total_damage,0) < 50
)
SELECT * FROM healthy_heroes ORDER BY fights DESC;

-- ========================================
-- 4. RECURSIVE CTEs
-- ========================================

-- 4.1 Recursive mentorship chain: find all mentees (descendants) of a given mentor
-- Example: start from Batman and list all levels of mentees
WITH RECURSIVE mentee_chain AS (
  -- anchor: direct mentees of Batman
  SELECT m.mentor_id, m.mentee_id, 1 AS depth, m.started_on
  FROM mentorships m
  WHERE m.mentor_id = (SELECT id FROM characters WHERE alias = 'Batman')
  UNION ALL
  -- recursive step: find mentees of the current mentee
  SELECT m2.mentor_id, m2.mentee_id, mc.depth + 1 AS depth, m2.started_on
  FROM mentorships m2
  JOIN mentee_chain mc ON m2.mentor_id = mc.mentee_id
)
SELECT mc.depth, mentee.name AS mentee_name, mentee.alias, mc.started_on
FROM mentee_chain mc
JOIN characters mentee ON mentee.id = mc.mentee_id
ORDER BY mc.depth, mentee_name;

-- 4.2 Recursive CTE to walk team hierarchy (ancestors)
WITH RECURSIVE team_ancestors AS (
  SELECT id, name, parent_team_id, 0 AS depth FROM teams WHERE id = (SELECT id FROM teams WHERE name = 'Sinestro Corps')
  UNION ALL
  SELECT t.id, t.name, t.parent_team_id, ta.depth + 1
  FROM teams t
  JOIN team_ancestors ta ON t.id = ta.parent_team_id
)
SELECT depth, name FROM team_ancestors ORDER BY depth;

-- ========================================
-- 5. WINDOW FUNCTIONS (ROW_NUMBER, RANK, DENSE_RANK, running totals)
-- ========================================

-- 5.1 ROW_NUMBER: Top member per team by strength (top-1 per team)
SELECT c.id AS character_id, c.name, t.name AS team_name, c.strength_rating
FROM (
  SELECT ct.character_id, ct.team_id,
         ROW_NUMBER() OVER (PARTITION BY ct.team_id ORDER BY ch.strength_rating DESC, ch.name) AS rn
  FROM character_team ct
  JOIN characters ch ON ch.id = ct.character_id
) AS ranked
JOIN characters c ON c.id = ranked.character_id
JOIN teams t ON t.id = ranked.team_id
WHERE ranked.rn = 1
ORDER BY team_name;

-- 5.2 RANK and DENSE_RANK: rank characters by strength with tie handling
SELECT name, strength_rating,
       RANK() OVER (ORDER BY strength_rating DESC) AS rank_with_gaps,
       DENSE_RANK() OVER (ORDER BY strength_rating DESC) AS dense_rank_no_gaps
FROM characters
ORDER BY strength_rating DESC, name;

-- 5.3 Top-N per partition: top 3 strongest per alignment (hero/villain)
SELECT name, kind, strength_rating
FROM (
  SELECT c.name, c.kind, c.strength_rating,
         ROW_NUMBER() OVER (PARTITION BY c.kind ORDER BY c.strength_rating DESC) AS rn
  FROM characters c
) s
WHERE rn <= 3
ORDER BY kind, strength_rating DESC;

-- 5.4 Running total of damage taken by each character ordered by battle date (cumulative damage)
SELECT bp.character_id,
       ch.name,
       b.battle_date,
       bp.damage_taken,
       SUM(bp.damage_taken) OVER (
         PARTITION BY bp.character_id
         ORDER BY b.battle_date
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_damage
FROM battle_participants bp
JOIN battles b ON b.id = bp.battle_id
JOIN characters ch ON ch.id = bp.character_id
ORDER BY bp.character_id, b.battle_date;

-- 5.5 Windowed average proficiency (moving average) across character powers, ordered by proficiency descending
SELECT character_id, power_id, proficiency_level,
       AVG(proficiency_level) OVER (
         PARTITION BY character_id
         ORDER BY proficiency_level DESC
         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS moving_avg_top3
FROM character_power
ORDER BY character_id, proficiency_level DESC;

-- ========================================
-- 6. TRANSACTIONS
-- ========================================

-- NOTE:
-- Execute these transaction examples interactively to observe effects.
-- They demonstrate BEGIN ... COMMIT/ROLLBACK, SAVEPOINT usage, and setting isolation level.

-- 6.1 Simple transfer of an artifact with SAVEPOINT and conditional rollback (manual simulation)
-- Steps (run in interactive session):
-- 1) BEGIN;
-- 2) Check current owner:
--    SELECT name, owner_character_id FROM artifacts WHERE name = 'Mother Box';
-- 3) Attempt transfer: update owner to Batman
--    UPDATE artifacts SET owner_character_id = (SELECT id FROM characters WHERE alias = 'Batman') WHERE name = 'Mother Box';
-- 4) SAVEPOINT sp_after_assignment;
-- 5) Simulate a validation check (for demo, intentionally raise a problem by checking owner exists)
--    -- If validation fails, ROLLBACK TO SAVEPOINT sp_after_assignment; else COMMIT;
-- Example sequence:
-- BEGIN;
-- UPDATE artifacts SET owner_character_id = (SELECT id FROM characters WHERE alias = 'Batman') WHERE name = 'Mother Box';
-- SAVEPOINT sp_after_assignment;
-- -- Suppose we check that Batman is active:
-- SELECT is_active FROM characters WHERE alias = 'Batman';
-- -- If not active: ROLLBACK TO SAVEPOINT sp_after_assignment;
-- COMMIT;

-- 6.2 Use of explicit isolation level: SERIALIZABLE transaction (may raise serialization failure that requires retry)
-- Important: serialization failures require client-side retry logic.
-- Example:
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
  -- read current owner of 'Kryptonian Codex'
  SELECT owner_character_id FROM artifacts WHERE name = 'Kryptonian Codex' FOR UPDATE;
  -- update to transfer to Lex Luthor (this may conflict with another concurrent transaction)
  UPDATE artifacts SET owner_character_id = (SELECT id FROM characters WHERE name = 'Lex Luthor') WHERE name = 'Kryptonian Codex';
COMMIT;

-- If a concurrent conflicting transaction exists, the COMMIT above might fail with a serialization error.
-- In that case, the application should retry the whole transaction from the start.

-- 6.3 Transaction demonstrating INSERT ... ON CONFLICT inside a transaction (upsert pattern)
BEGIN;
  -- Suppose we want to ensure a 'Peace Summit' battle entry exists and then associate participants.
  INSERT INTO battles (name, battle_date, location, description)
  VALUES ('Peace Summit', '2026-01-01', 'Neutral City', 'Diplomatic summit turned minor skirmish')
  ON CONFLICT (name) DO NOTHING;
  -- Insert participant if not already present
  INSERT INTO battle_participants (battle_id, character_id, side, outcome, damage_taken)
  VALUES (
    (SELECT id FROM battles WHERE name = 'Peace Summit'),
    (SELECT id FROM characters WHERE alias = 'Batman'),
    'hero', 'draw', 5
  )
  ON CONFLICT DO NOTHING;
COMMIT;

-- 6.4 Example showing transactional read-modify-write with explicit locking using SELECT ... FOR UPDATE
-- Begin a transaction that increments a fictional 'reputation' metric stored in characters table (demonstration only)
-- First add a temporary column for demo (idempotent safe via conditional check would be ideal in scripts)
-- For clarity in demo environments, create the column only if not present; here we assume a fresh DB.
ALTER TABLE characters ADD COLUMN IF NOT EXISTS reputation INT DEFAULT 0;

-- Transaction: increment reputation for 'Superman' and 'Batman' safely
BEGIN;
  -- lock rows to avoid concurrent modification races
  SELECT id, reputation FROM characters WHERE alias IN ('Superman', 'Batman') FOR UPDATE;
  UPDATE characters SET reputation = reputation + 10 WHERE alias = 'Superman';
  UPDATE characters SET reputation = reputation + 5 WHERE alias = 'Batman';
COMMIT;

-- 6.5 Example rollback demonstration
-- Start a transaction, perform inserts, then rollback to undo all changes
BEGIN;
  INSERT INTO characters (name, alias, kind, origin_city, debut_year) VALUES ('Temp Villain', 'Temp', 'villain', 'Nowhere', 2026);
  -- verify inserted record exists in current transaction
  -- SELECT * FROM characters WHERE name = 'Temp Villain';
  -- Now rollback the whole transaction to discard the insert
ROLLBACK;
-- After ROLLBACK, 'Temp Villain' will not exist.

-- ========================================
-- 7. COMBINING CTEs, WINDOWS, AND TRANSACTIONS IN COMPLEX ANALYSES
-- ========================================

-- 7.1 Use a CTE to compute per-character battle aggregates, then apply window ranking across those aggregates
WITH per_character_stats AS (
  SELECT c.id AS character_id, c.name,
         COUNT(bp.battle_id) AS battles_fought,
         SUM(COALESCE(bp.damage_taken,0)) AS total_damage,
         SUM(CASE WHEN bp.outcome = 'won' THEN 1 ELSE 0 END) AS wins
  FROM characters c
  LEFT JOIN battle_participants bp ON bp.character_id = c.id
  GROUP BY c.id, c.name
)
SELECT character_id, name, battles_fought, total_damage, wins,
       RANK() OVER (ORDER BY wins DESC, battles_fought DESC) AS win_rank,
       ROW_NUMBER() OVER (ORDER BY total_damage DESC) AS damage_rank
FROM per_character_stats
ORDER BY win_rank, damage_rank;

-- 7.2 Use a CTE to find top-2 strongest per team and then store snapshot results inside a transaction
-- Snapshot top 2 characters per team into a session-local temporary table.
-- This version drops any existing temp table so it refreshes each run.

BEGIN;
DROP TABLE IF EXISTS snapshot_top_team_members;
CREATE TEMP TABLE snapshot_top_team_members
  ON COMMIT PRESERVE ROWS AS
WITH ranked_team_members AS (
  SELECT
    ct.team_id,
    c.id AS character_id,
    c.name,
    c.strength_rating,
    ROW_NUMBER() OVER (
      PARTITION BY ct.team_id
      ORDER BY c.strength_rating DESC, c.name
    ) AS rn
  FROM character_team ct
  JOIN characters c ON c.id = ct.character_id
),
top2 AS (
  SELECT team_id, character_id, name, strength_rating
  FROM ranked_team_members
  WHERE rn <= 2
)
SELECT * FROM top2;
COMMIT;

-- Inspect the temporary snapshot (in the same session)
-- SELECT * FROM snapshot_top_team_members ORDER BY team_id, strength_rating DESC;

-- ========================================
-- 8. CLEANUP NOTES (optional for iterative testing)
-- ========================================
-- If you want to drop demo tables to start fresh (run with care):
-- DROP TABLE IF EXISTS battle_participants, battles, artifacts, mentorships, character_power, powers, character_team, teams, characters;

-- End of file

-- If you want to reset and start over. 

-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;
-- GRANT ALL ON SCHEMA public TO postgres;
-- GRANT ALL ON SCHEMA public TO public;