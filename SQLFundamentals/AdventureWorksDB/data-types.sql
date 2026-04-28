SELECT CAST(ProductID AS varchar(4)) + ': ' + Name AS ProductName
FROM Production.Product;

--SELECT CAST(Size AS integer) As NumericSize
--FROM Production.Product;

--Conversion failed when converting the nvarchar value 'M' to data type int.

SELECT TRY_CAST(Size AS integer) As NumericSize
FROM Production.Product;

SELECT CONVERT(varchar(4), ProductID) + ': ' + Name AS ProductName
FROM Production.Product;

SELECT [StartDate],
       CONVERT(varchar(20), [StartDate]) AS StartDate,
       CONVERT(varchar(10), [StartDate], 101) AS FormattedStartDate 
FROM [Sales].[SpecialOffer];

SELECT PARSE('01/01/2021' AS date) AS DateValue,
   PARSE('$199.99' AS money) AS MoneyValue;

SELECT ProductID,  '$' + STR(ListPrice) AS Price
FROM Production.Product;