SELECT * FROM Production.Product;

--SELECT ProductID, Name, ListPrice, StandardCost
--‎FROM Production.Product;

SELECT ProductID, Name, ListPrice, StandardCost
FROM Production.Product

SELECT ProductID,
      Name + '(' + ProductNumber + ')',
  ListPrice - StandardCost
FROM Production.Product;

SELECT ProductID AS ID,
      Name + '(' + ProductNumber + ')' AS ProductName,
  ListPrice - StandardCost AS Markup
FROM Production.Product;