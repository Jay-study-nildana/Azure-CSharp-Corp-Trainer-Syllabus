-- SQL Advanced Basics Supplement – MS SQL (DC Comics Example)
-- This file adds foundational topics for beginners using the DC Comics database.

-----------------------------------------------------------
-- 1. UPDATE Statement
-----------------------------------------------------------

-- Update a superhero's alias
-- This won't work because there is no superhero alias named 'Superman' in the database, but it demonstrates the syntax.
UPDATE Superheroes
SET Alias = 'Man of Steel'
WHERE Name = 'Superman';
GO

--This will work because there is a superhero named 'Clark Kent' in the database.
UPDATE
    Superheroes
SET
    Alias = 'Man of Steel'
WHERE
    Name = 'Clark Kent';

-----------------------------------------------------------
-- 2. DELETE Statement
-----------------------------------------------------------

-- Delete a villain from the database
-- You cannot just do this DELETE operation due to Foreign Key constraints. 
-- You would need to first delete any related records in the SuperheroVillains table before deleting the villain.
DELETE FROM Villains
WHERE Name = 'Joker';
GO

--Here are the steps to delete the villain 'Joker' while respecting the Foreign Key constraints:
-- after deleting the related records in the SuperheroVillains table, you can then delete the villain from the Villains table, above.
DELETE 
    FROM VillainTeamMemberships
WHERE 
    VillainID = 
    (
        SELECT VillainID
        FROM Villains
        WHERE Name = 'Joker'
    );

DELETE 
    FROM Comics
    WHERE VillainID = 
    (
        SELECT 
            VillainID
        FROM 
            Villains WHERE Name ='Joker'
    );

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
-- This will be terminated because the DELETE statement won't work due to Foreign Key constraints, but it demonstrates the syntax.
-- useful to see what happens when a transaction fails and how to handle it with COMMIT and ROLLBACK.
-- you dont' have to do anything, the rollbacks will automatically happen.

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

--Here is the correct way to handle the transaction while respecting the Foreign Key constraints:
BEGIN TRAN
    UPDATE Superheroes
    SET Alias = 'The Bat'
    WHERE Name = 'Batman';

    DELETE 
        FROM VillainTeamMemberships
    WHERE 
        VillainID = 
        (
            SELECT VillainID
            FROM Villains
            WHERE Name = 'Cheetah'
        );

    DELETE 
        FROM Comics
        WHERE VillainID = 
        (
            SELECT 
                VillainID
            FROM 
                Villains WHERE Name ='Cheetah'
        );    

    DELETE 
        FROM Villains
    WHERE
        Name = 'Cheetah';

COMMIT;

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
-- this will not return any results because there is no superhero whose name starts with 'Bat' in the database, but it demonstrates the syntax.
SELECT * FROM Superheroes WHERE Name LIKE 'Bat%';
GO

--try this one, it will return results because there are superheroes whose names start with 'Bruce' in the database.
SELECT  
    *
FROM 
    Superheroes
WHERE
    Name LIKE 'Bruce%'

-- Find superheroes with specific names
-- this will not return any results because there are no superheroes named 'Superman', 'Batman', or 'Wonder Woman'.
SELECT * FROM Superheroes WHERE Name IN ('Superman', 'Batman', 'Wonder Woman');
GO

-- This will return results because there is a superhero named 'Bruce Wayne' in the database.

SELECT
    *
FROM 
    Superheroes
WHERE
    NAME IN ('Bruce Wayne');

-----------------------------------------------------------
-- 9. TRY...CATCH ERROR HANDLING
-----------------------------------------------------------

--As before, remember that, there is no superhero alias named 'Superman' in the database, but there won't be any error. 
-- It will simply execute but no rows will be affected because the WHERE clause doesn't match any records.
BEGIN TRY
    -- May produce error
    UPDATE Superheroes SET Alias = NULL WHERE Name = 'Superman';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH
GO

--This will work just fine. no error or anything.

BEGIN TRY
    UPDATE Superheroes
    SET Alias = NULL 
    WHERE Name = 'Clark Kent';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE()
    AS ErrorMessage;
END CATCH


--This will produce an error because SuperheroID is a Primary Key and cannot be set to NULL.
BEGIN TRY
    UPDATE Superheroes
    SET SuperheroID = NULL 
    WHERE Name = 'Clark Kent';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE()
    AS ErrorMessage;
END CATCH

-----------------------------------------------------------
-- 10. ERD (Entity Relationship Diagram)
-----------------------------------------------------------
-- Tip: Use SSMS Database Diagram, dbdiagram.io, or draw.io
-- to visualize the tables and relationships in DCComicsDB.

-- End of Supplementary SQL File
