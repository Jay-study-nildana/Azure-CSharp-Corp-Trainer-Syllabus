SELECT MAX([ActualCost]) AS 'Max Actual Cost'
FROM [Production].[TransactionHistory]

SELECT MAX(SalesOrderID) AS SalesOrderID
FROM Sales.SalesOrderHeader

SELECT SalesOrderID, ProductID, OrderQty
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 
   (SELECT MAX(SalesOrderID)
    FROM Sales.SalesOrderHeader);

SELECT SalesOrderID, ProductID, OrderQty,
(SELECT AVG(OrderQty)
    FROM Sales.SalesOrderDetail) AS AvgQty
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 
(SELECT MAX(SalesOrderID)
    FROM Sales.SalesOrderHeader);

SELECT SalesOrderID, CustomerID, OrderDate
FROM Sales.SalesOrderHeader AS o1
WHERE SalesOrderID =
    (SELECT MAX(SalesOrderID)
     FROM Sales.SalesOrderHeader AS o2
     WHERE o2.CustomerID = o1.CustomerID)
ORDER BY CustomerID, OrderDate;

SELECT CustomerID, [AccountNumber], [StoreID] 
FROM Sales.Customer AS c 
WHERE
(SELECT COUNT(*) 
  FROM Sales.SalesOrderHeader AS o
  WHERE o.CustomerID = c.CustomerID) > 0;

SELECT CustomerID, [AccountNumber], [StoreID] 
FROM Sales.Customer AS c 
WHERE EXISTS
(SELECT * 
  FROM Sales.SalesOrderHeader AS o
  WHERE o.CustomerID = c.CustomerID);

SELECT CustomerID, [AccountNumber], [StoreID] 
FROM Sales.Customer AS c 
WHERE NOT EXISTS
  (SELECT * 
   FROM Sales.SalesOrderHeader AS o
   WHERE o.CustomerID = c.CustomerID);

 SELECT ProductID, Name, ListPrice
 FROM [Production].Product
 WHERE ListPrice >
     (SELECT AVG(UnitPrice)
      FROM Sales.SalesOrderDetail)
 ORDER BY ProductID;

SELECT ProductID, Name, ListPrice
FROM [Production].Product
WHERE ProductID IN
    (SELECT ProductID
    FROM Sales.SalesOrderDetail
    WHERE UnitPrice < 100.00)
AND ListPrice >= 100.00
ORDER BY ProductID;

SELECT p.ProductID, p.Name, p.StandardCost, p.ListPrice,
    (SELECT AVG(o.UnitPrice)
    FROM Sales.SalesOrderDetail AS o
    WHERE p.ProductID = o.ProductID) AS AvgSellingPrice
FROM [Production].Product AS p
ORDER BY p.ProductID;

SELECT p.ProductID, p.Name, p.StandardCost, p.ListPrice,
    (SELECT AVG(o.UnitPrice)
    FROM Sales.SalesOrderDetail AS o
    WHERE p.ProductID = o.ProductID) AS AvgSellingPrice
FROM [Production].Product AS p
WHERE StandardCost >
    (SELECT AVG(od.UnitPrice)
    FROM Sales.SalesOrderDetail AS od
    WHERE p.ProductID = od.ProductID)
ORDER BY p.ProductID;