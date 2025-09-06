-- SQL Advanced Basics Supplement – MS SQL (DC Comics Example)
-- This file adds foundational topics for beginners using the DC Comics database.

-----------------------------------------------------------
-- 1. UPDATE Statement
-----------------------------------------------------------

-- Update a superhero's alias
UPDATE Superheroes
SET Alias = 'Man of Steel'
WHERE Name = 'Superman';
GO

-----------------------------------------------------------
-- 2. DELETE Statement
-----------------------------------------------------------

-- Delete a villain from the database
DELETE FROM Villains
WHERE Name = 'Joker';
GO

-----------------------------------------------------------
-- 3. ALTER TABLE
-----------------------------------------------------------

-- Add a new column to Superheroes
ALTER TABLE Superheroes
ADD PowerLevel INT;
GO

-- Add a new constraint to check FirstAppearance date
ALTER TABLE Superheroes
ADD CONSTRAINT chk_FirstAppearance CHECK (FirstAppearance >= '1900-01-01');
GO

-----------------------------------------------------------
-- 4. INDEXING
-----------------------------------------------------------

-- Create an index on Superhero Name
CREATE INDEX idx_SuperheroName ON Superheroes(Name);
GO

-----------------------------------------------------------
-- 5. VIEWS
-----------------------------------------------------------

-- Create a view for Justice League members
CREATE VIEW vJusticeLeagueMembers AS
SELECT s.Name AS SuperheroName
FROM Superheroes s
JOIN SuperheroTeams st ON s.SuperheroID = st.SuperheroID
JOIN Teams t ON st.TeamID = t.TeamID
WHERE t.TeamName = 'Justice League';
GO

-----------------------------------------------------------
-- 6. STORED PROCEDURES
-----------------------------------------------------------

-- Create a procedure to get all comics for a superhero
CREATE PROCEDURE GetSuperheroComics
    @SuperheroID INT
AS
BEGIN
    SELECT * FROM Comics WHERE SuperheroID = @SuperheroID;
END;
GO

-----------------------------------------------------------
-- 7. TRANSACTIONS
-----------------------------------------------------------

-- Example transaction: Update and Delete
BEGIN TRAN

UPDATE Superheroes
SET Alias = 'The Bat'
WHERE Name = 'Batman';

DELETE FROM Villains
WHERE Name = 'Cheetah';

-- If everything is OK
COMMIT;
-- If something goes wrong
--ROLLBACK;
GO

-----------------------------------------------------------
-- 8. DISTINCT, IN, BETWEEN, LIKE
-----------------------------------------------------------

-- List unique publishers
SELECT DISTINCT Publisher FROM Superheroes;
GO

-- Find comics with issue numbers between 1 and 100
SELECT * FROM Comics WHERE IssueNumber BETWEEN 1 AND 100;
GO

-- Find superheroes whose name starts with 'Bat'
SELECT * FROM Superheroes WHERE Name LIKE 'Bat%';
GO

-- Find superheroes with specific names
SELECT * FROM Superheroes WHERE Name IN ('Superman', 'Batman', 'Wonder Woman');
GO

-----------------------------------------------------------
-- 9. TRY...CATCH ERROR HANDLING
-----------------------------------------------------------

BEGIN TRY
    -- May produce error
    UPDATE Superheroes SET Alias = NULL WHERE Name = 'Superman';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH
GO

-----------------------------------------------------------
-- 10. ERD (Entity Relationship Diagram)
-----------------------------------------------------------
-- Tip: Use SSMS Database Diagram, dbdiagram.io, or draw.io
-- to visualize the tables and relationships in DCComicsDB.

-- End of Supplementary SQL File
