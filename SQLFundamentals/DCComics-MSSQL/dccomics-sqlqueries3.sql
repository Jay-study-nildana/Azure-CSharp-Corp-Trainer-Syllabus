-- Create a Non-clustered Index on the Name column in the Superheroes table
CREATE NONCLUSTERED INDEX idx_Superheroes_Name
ON Superheroes (Name);

-- Create a Non-clustered Index on the TeamName column in the Teams table
CREATE NONCLUSTERED INDEX idx_Teams_TeamName
ON Teams (TeamName);

-- Query that benefits from the idx_Superheroes_Name index
SELECT * FROM Superheroes
WHERE Name = 'Bruce Wayne';

-- Query that benefits from the idx_Teams_TeamName index
SELECT * FROM Teams
WHERE TeamName = 'Suicide Squad';

-- Stored Procedure to insert a new Superhero
CREATE PROCEDURE InsertSuperhero
    @Name NVARCHAR(100),
    @Alias NVARCHAR(100),
    @FirstAppearance DATE,
    @Publisher NVARCHAR(50) = 'DC Comics'
AS
BEGIN
    INSERT INTO Superheroes (Name, Alias, FirstAppearance, Publisher)
    VALUES (@Name, @Alias, @FirstAppearance, @Publisher);
END;
GO

-- Stored Procedure to get all Comics by a specific Superhero
CREATE PROCEDURE GetComicsBySuperhero
    @SuperheroID INT
AS
BEGIN
    SELECT * FROM Comics
    WHERE SuperheroID = @SuperheroID;
END;
GO

-- Stored Procedure to update the Alias of a Superhero
CREATE PROCEDURE UpdateSuperheroAlias
    @SuperheroID INT,
    @Alias NVARCHAR(100)
AS
BEGIN
    UPDATE Superheroes
    SET Alias = @Alias
    WHERE SuperheroID = @SuperheroID;
END;
GO

-- Stored Procedure to delete a Villain by ID
CREATE PROCEDURE DeleteVillain
    @VillainID INT
AS
BEGIN
    DELETE FROM Villains
    WHERE VillainID = @VillainID;
END;
GO

-- Insert a new Superhero
EXEC InsertSuperhero @Name = 'Clark Kent', @Alias = 'Superman', @FirstAppearance = '1938-06-01';

-- Get all Comics by a specific Superhero
EXEC GetComicsBySuperhero @SuperheroID = 1;

-- Update the Alias of a Superhero
EXEC UpdateSuperheroAlias @SuperheroID = 1, @Alias = 'Man of Steel';

-- Delete a Villain by ID
EXEC DeleteVillain @VillainID = 1;


-- View to get basic details of superheroes
CREATE VIEW SuperheroDetails AS
SELECT SuperheroID, Name, Alias, FirstAppearance
FROM Superheroes;
GO

-- View to get basic details of villains
CREATE VIEW VillainDetails AS
SELECT VillainID, Name, Alias, FirstAppearance
FROM Villains;
GO

-- View to get the list of comics along with superhero and villain names
CREATE VIEW ComicBookDetails AS
SELECT c.ComicID, c.Title, c.IssueNumber, c.ReleaseDate, s.Name AS SuperheroName, v.Name AS VillainName
FROM Comics c
JOIN Superheroes s ON c.SuperheroID = s.SuperheroID
JOIN Villains v ON c.VillainID = v.VillainID;
GO

-- View to get the count of comics each superhero is featured in
CREATE VIEW SuperheroComicCount AS
SELECT s.SuperheroID, s.Name AS SuperheroName, COUNT(c.ComicID) AS ComicCount
FROM Superheroes s
LEFT JOIN Comics c ON s.SuperheroID = c.SuperheroID
GROUP BY s.SuperheroID, s.Name;
GO

-- View to get the count of comics each villain is featured in
CREATE VIEW VillainComicCount AS
SELECT v.VillainID, v.Name AS VillainName, COUNT(c.ComicID) AS ComicCount
FROM Villains v
LEFT JOIN Comics c ON v.VillainID = c.VillainID
GROUP BY v.VillainID, v.Name;
GO

-- View to get the list of superheroes and the teams they belong to
CREATE VIEW SuperheroTeams AS
SELECT s.Name AS SuperheroName, t.TeamName
FROM Superheroes s
JOIN SuperheroTeamMemberships stm ON s.SuperheroID = stm.SuperheroID
JOIN SuperheroTeams t ON stm.SuperheroTeamID = t.SuperheroTeamID;
GO

-- View to get the list of villains and the teams they belong to
CREATE VIEW VillainTeamsView AS
SELECT v.Name AS VillainName, t.TeamName
FROM Villains v
JOIN VillainTeamMemberships vtm ON v.VillainID = vtm.VillainID
JOIN VillainTeams t ON vtm.VillainTeamID = t.VillainTeamID;
GO

-- Retrieve all details from the SuperheroDetails view
SELECT * FROM SuperheroDetails;

-- Retrieve all details from the VillainDetails view
SELECT * FROM VillainDetails;

-- Retrieve all details from the ComicBookDetails view
SELECT * FROM ComicBookDetails;

-- Retrieve the count of comics each superhero is featured in
SELECT * FROM SuperheroComicCount;

-- Retrieve the count of comics each villain is featured in
SELECT * FROM VillainComicCount;

-- Retrieve the list of superheroes and the teams they belong to
SELECT * FROM SuperheroTeams;

-- Retrieve the list of villains and the teams they belong to
SELECT * FROM VillainTeams;

-- Additional examples of using views with WHERE clause and aggregations

-- Find superheroes who first appeared after 1980
SELECT * FROM SuperheroDetails
WHERE FirstAppearance > '1980-01-01';

-- Find villains who are part of the 'Legion of Doom'
SELECT * FROM VillainTeams
WHERE TeamName = 'Legion of Doom';

-- Find the total number of comics for each superhero who appeared more than 10 times
SELECT SuperheroName, ComicCount
FROM SuperheroComicCount
WHERE ComicCount > 10;

-- Find the total number of comics for each villain who appeared more than 5 times
SELECT VillainName, ComicCount
FROM VillainComicCount
WHERE ComicCount > 5;