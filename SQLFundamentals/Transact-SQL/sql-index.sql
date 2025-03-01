-- https://github.com/Jay-study-nildana/Azure-CSharp-Corp-Trainer-Syllabus/tree/main/SQLFundamentals/DCComics
-- Description: Create a view to display the list of DC Comics characters
-- =============================================

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