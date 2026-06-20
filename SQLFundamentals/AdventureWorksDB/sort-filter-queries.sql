SELECT TOP (5) [ProductID] AS 'Product ID', [Name]
FROM Production.Product
ORDER BY [ProductID] ASC, [Name] DESC;

SELECT TOP (5) [ProductID] AS 'Product ID', [Name]
FROM Production.Product
ORDER BY [ProductID] ASC;

SELECT TOP 2 PERCENT [ProductID] AS 'Product ID', [Name]
FROM Production.Product
ORDER BY [ProductID] ASC;

SELECT [ProductID] AS 'Product ID', [Name]
FROM Production.Product
ORDER BY [ProductID] ASC
OFFSET 0 ROWS --Skip zero rows
FETCH NEXT 10 ROWS ONLY; --Get the next 10

SELECT [ProductID] AS 'Product ID', [Name]
FROM Production.Product
ORDER BY [ProductID] ASC
OFFSET 5 ROWS --Skip zero rows
FETCH NEXT 5 ROWS ONLY; --Get the next 5

SELECT [StateProvinceID], [City]
FROM [Person].[Address]
ORDER BY [StateProvinceID], [City];

SELECT DISTINCT  [StateProvinceID], [City]
FROM [Person].[Address]
ORDER BY [StateProvinceID], [City];

SELECT [StateProvinceID], [City]
FROM [Person].[Address]
WHERE [StateProvinceID] = 179
ORDER BY [City]

SELECT DISTINCT [StateProvinceID], [City]
FROM [Person].[Address]
WHERE [StateProvinceID] = 179
ORDER BY [City]

SELECT DISTINCT [StateProvinceID], [City]
FROM [Person].[Address]
WHERE [StateProvinceID] > 120 AND [StateProvinceID] < 140
ORDER BY [StateProvinceID]

SELECT DISTINCT [StateProvinceID], [City]
FROM [Person].[Address]
WHERE [StateProvinceID] BETWEEN 120 AND 140
ORDER BY [StateProvinceID]

SELECT DISTINCT [StateProvinceID], [City]
FROM [Person].[Address]
WHERE [StateProvinceID] = 179 OR [StateProvinceID] = 50
ORDER BY [StateProvinceID]

SELECT DISTINCT [StateProvinceID], [City]
FROM [Person].[Address]
WHERE [StateProvinceID] IN (179, 50,77)
ORDER BY [StateProvinceID]

SELECT TOP (50) [Name]
FROM Production.Product
WHERE [Name] LIKE '%B%'
ORDER BY [ProductID] ASC;