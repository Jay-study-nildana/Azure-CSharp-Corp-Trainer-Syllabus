-- https://github.com/Jay-study-nildana/Azure-CSharp-Corp-Trainer-Syllabus/tree/main/SQLFundamentals/DCComics
-- Description: Create a view to display the list of DC Comics characters
-- =============================================

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