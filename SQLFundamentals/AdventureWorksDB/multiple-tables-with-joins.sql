SELECT TOP 20 PERCENT
	p.ProductID, p.ListPrice, pd.ModifiedDate, pd.DocumentNode
FROM [Production].[Product] AS p
JOIN [Production].[ProductDocument] AS pd
    ON p.ProductID = pd.ProductID;

SELECT TOP 20 PERCENT
	p.ProductID, p.ListPrice, pd.ModifiedDate, pd.DocumentNode
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductDocument] AS pd
    ON p.ProductID = pd.ProductID;

SELECT TOP 20 PERCENT
	p.ProductID, p.ListPrice, pd.ModifiedDate, pd.DocumentNode
FROM [Production].[Product] AS p
LEFT OUTER JOIN [Production].[ProductDocument] AS pd
    ON p.ProductID = pd.ProductID;

SELECT TOP 20 PERCENT
	p.ProductID, p.ListPrice, pd.ModifiedDate, pd.DocumentNode
FROM [Production].[Product] AS p
LEFT JOIN [Production].[ProductDocument] AS pd
    ON p.ProductID = pd.ProductID;

SELECT TOP 20 PERCENT
	p.ProductID, p.ListPrice, pd.ModifiedDate, pd.DocumentNode
FROM [Production].[Product] AS p
RIGHT OUTER JOIN [Production].[ProductDocument] AS pd
    ON p.ProductID = pd.ProductID;

SELECT TOP 20 PERCENT
	p.ProductID, p.ListPrice, pd.ModifiedDate, pd.DocumentNode
FROM [Production].[Product] AS p
FULL OUTER JOIN [Production].[ProductDocument] AS pd
    ON p.ProductID = pd.ProductID;

SELECT TOP 20 PERCENT
	p.ProductID, p.ListPrice, pd.ModifiedDate, pd.DocumentNode
FROM [Production].[Product] AS p
CROSS JOIN [Production].[ProductDocument] AS pd