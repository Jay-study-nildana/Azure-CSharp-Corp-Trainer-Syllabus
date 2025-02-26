-- 1. Retrieve all superheroes
SELECT * FROM Superheroes;

-- 2. Retrieve all teams
SELECT * FROM Teams;

-- 3. Retrieve all comics
SELECT * FROM Comics;

-- 4. Retrieve all superheroes along with their teams
SELECT s.Name AS SuperheroName, t.TeamName
FROM Superheroes s
JOIN SuperheroTeams st ON s.SuperheroID = st.SuperheroID
JOIN Teams t ON st.TeamID = t.TeamID;

-- 5. Retrieve all comics along with the superheroes featured in them
SELECT c.Title AS ComicTitle, c.IssueNumber, s.Name AS SuperheroName
FROM Comics c
JOIN Superheroes s ON c.SuperheroID = s.SuperheroID;

-- 6. Count the number of comics each superhero is featured in
SELECT s.Name AS SuperheroName, COUNT(c.ComicID) AS ComicCount
FROM Superheroes s
LEFT JOIN Comics c ON s.SuperheroID = c.SuperheroID
GROUP BY s.Name
ORDER BY ComicCount DESC;

-- 7. List all superheroes who are part of the 'Justice League'
SELECT s.Name AS SuperheroName
FROM Superheroes s
JOIN SuperheroTeams st ON s.SuperheroID = st.SuperheroID
JOIN Teams t ON st.TeamID = t.TeamID
WHERE t.TeamName = 'Justice League';

-- 8. List all comics released before the year 1960
SELECT * FROM Comics
WHERE ReleaseDate < '1960-01-01';

-- 9. Find the first appearance of each superhero
SELECT Name, FirstAppearance
FROM Superheroes
ORDER BY FirstAppearance;

-- 10. List all teams along with the number of superheroes in each team
SELECT t.TeamName, COUNT(st.SuperheroID) AS SuperheroCount
FROM Teams t
LEFT JOIN SuperheroTeams st ON t.TeamID = st.TeamID
GROUP BY t.TeamName
ORDER BY SuperheroCount DESC;

-- 11. Find all superheroes who do not belong to any team
SELECT s.Name AS SuperheroName
FROM Superheroes s
LEFT JOIN SuperheroTeams st ON s.SuperheroID = st.SuperheroID
WHERE st.TeamID IS NULL;

-- 12. List the total number of superheroes and teams
SELECT 
    (SELECT COUNT(*) FROM Superheroes) AS TotalSuperheroes,
    (SELECT COUNT(*) FROM Teams) AS TotalTeams;

-- 13. Retrieve superhero details along with their first comic appearance
SELECT s.Name AS SuperheroName, c.Title AS FirstComicTitle, c.IssueNumber, c.ReleaseDate
FROM Superheroes s
JOIN Comics c ON s.SuperheroID = c.SuperheroID
WHERE c.ReleaseDate = (
    SELECT MIN(ReleaseDate)
    FROM Comics
    WHERE SuperheroID = s.SuperheroID
);

-- 14. List all superheroes along with the number of teams they belong to
SELECT s.Name AS SuperheroName, COUNT(st.TeamID) AS TeamCount
FROM Superheroes s
LEFT JOIN SuperheroTeams st ON s.SuperheroID = st.SuperheroID
GROUP BY s.Name
ORDER BY TeamCount DESC;

-- 15. Find the most recent comic release for each superhero
SELECT s.Name AS SuperheroName, c.Title AS RecentComicTitle, c.ReleaseDate
FROM Superheroes s
JOIN Comics c ON s.SuperheroID = c.SuperheroID
WHERE c.ReleaseDate = (
    SELECT MAX(ReleaseDate)
    FROM Comics
    WHERE SuperheroID = s.SuperheroID
);

--Let's Look at some Villains now

-- Simple Queries

-- 1. Retrieve all villains
SELECT * FROM Villains;

-- 2. Retrieve all villain teams
SELECT * FROM VillainTeams;

-- 3. Retrieve all villains along with their aliases
SELECT Name, Alias FROM Villains;

-- 4. Find all villains who first appeared before 1970
SELECT * FROM Villains WHERE FirstAppearance < '1970-01-01';

-- 5. Find all villains who first appeared after 1980
SELECT * FROM Villains WHERE FirstAppearance > '1980-01-01';

-- 6. Retrieve all villain teams with their base of operations
SELECT TeamName, BaseOfOperations FROM VillainTeams;

-- Intermediate Queries

-- 7. Retrieve all villains along with the teams they belong to
SELECT v.Name AS VillainName, vt.TeamName
FROM Villains v
JOIN VillainTeamMemberships vtm ON v.VillainID = vtm.VillainID
JOIN VillainTeams vt ON vtm.VillainTeamID = vt.VillainTeamID;

-- 8. Retrieve all comics along with the villains featured in them
SELECT c.Title AS ComicTitle, c.IssueNumber, v.Name AS VillainName
FROM Comics c
JOIN Villains v ON c.VillainID = v.VillainID;

-- 9. Count the number of comics each villain is featured in
SELECT v.Name AS VillainName, COUNT(c.ComicID) AS ComicCount
FROM Villains v
LEFT JOIN Comics c ON v.VillainID = c.VillainID
GROUP BY v.Name
ORDER BY ComicCount DESC;

-- 10. List all villains who are part of the 'Legion of Doom'
SELECT v.Name AS VillainName
FROM Villains v
JOIN VillainTeamMemberships vtm ON v.VillainID = vtm.VillainID
JOIN VillainTeams vt ON vtm.VillainTeamID = vt.VillainTeamID
WHERE vt.TeamName = 'Legion of Doom';

-- Advanced Queries

-- 11. Find all villains who do not belong to any team
SELECT v.Name AS VillainName
FROM Villains v
LEFT JOIN VillainTeamMemberships vtm ON v.VillainID = vtm.VillainID
WHERE vtm.VillainTeamID IS NULL;

-- 12. List the total number of villains and villain teams
SELECT 
    (SELECT COUNT(*) FROM Villains) AS TotalVillains,
    (SELECT COUNT(*) FROM VillainTeams) AS TotalVillainTeams;

-- 13. Retrieve villain details along with their first comic appearance
SELECT v.Name AS VillainName, c.Title AS FirstComicTitle, c.IssueNumber, c.ReleaseDate
FROM Villains v
JOIN Comics c ON v.VillainID = c.VillainID
WHERE c.ReleaseDate = (
    SELECT MIN(ReleaseDate)
    FROM Comics
    WHERE VillainID = v.VillainID
);

-- 14. List all villains along with the number of teams they belong to
SELECT v.Name AS VillainName, COUNT(vtm.VillainTeamID) AS TeamCount
FROM Villains v
LEFT JOIN VillainTeamMemberships vtm ON v.VillainID = vtm.VillainID
GROUP BY v.Name
ORDER BY TeamCount DESC;

-- 15. Find the most recent comic release for each villain
SELECT v.Name AS VillainName, c.Title AS RecentComicTitle, c.ReleaseDate
FROM Villains v
JOIN Comics c ON v.VillainID = c.VillainID
WHERE c.ReleaseDate = (
    SELECT MAX(ReleaseDate)
    FROM Comics
    WHERE VillainID = v.VillainID
);

-- 16. Find the average number of comics per villain
SELECT AVG(ComicCount) AS AverageComicsPerVillain
FROM (
    SELECT COUNT(c.ComicID) AS ComicCount
    FROM Villains v
    LEFT JOIN Comics c ON v.VillainID = c.VillainID
    GROUP BY v.VillainID
) AS ComicCounts;

-- 17. Find the villain who has appeared in the most comics
SELECT TOP 1 v.Name AS VillainName, COUNT(c.ComicID) AS ComicCount
FROM Villains v
LEFT JOIN Comics c ON v.VillainID = c.VillainID
GROUP BY v.Name
ORDER BY ComicCount DESC;

-- 18. List all villains and their corresponding superheroes in comics
SELECT v.Name AS VillainName, s.Name AS SuperheroName, c.Title AS ComicTitle
FROM Comics c
JOIN Villains v ON c.VillainID = v.VillainID
JOIN Superheroes s ON c.SuperheroID = s.SuperheroID;

-- 19. Find villains who have appeared in the same comic as a specific superhero
-- Example: Find villains who have appeared in the same comic as 'Superman'
SELECT DISTINCT v.Name AS VillainName
FROM Villains v
JOIN Comics c ON v.VillainID = c.VillainID
WHERE c.ComicID IN (
    SELECT ComicID
    FROM Comics
    WHERE SuperheroID = (SELECT SuperheroID FROM Superheroes WHERE Name = 'Superman')
);

-- 20. List all superheroes who have faced 'Joker' in comics
SELECT DISTINCT s.Name AS SuperheroName
FROM Superheroes s
JOIN Comics c ON s.SuperheroID = c.SuperheroID
WHERE c.VillainID = (SELECT VillainID FROM Villains WHERE Name = 'Joker');