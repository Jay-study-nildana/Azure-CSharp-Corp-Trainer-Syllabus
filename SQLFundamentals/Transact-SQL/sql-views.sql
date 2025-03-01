-- https://github.com/Jay-study-nildana/Azure-CSharp-Corp-Trainer-Syllabus/tree/main/SQLFundamentals/DCComics
-- Description: Create a view to display the list of DC Comics characters
-- =============================================


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