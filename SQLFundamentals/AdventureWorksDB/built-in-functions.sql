SELECT TOP (5)
YEAR(SellStartDate) AS SellStartYear, ProductID, Name
FROM Production.Product
ORDER BY SellStartYear;

SELECT TOP (5)

YEAR(SellStartDate) AS SellStartYear,
DATENAME(mm,SellStartDate) AS SellStartMonth,
DAY(SellStartDate) AS SellStartDay,
DATENAME(dw, SellStartDate) AS SellStartWeekday,
DATEDIFF(yy,SellStartDate, GETDATE()) AS YearsSold,
ProductID,
Name
FROM Production.Product
ORDER BY SellStartYear;


SELECT TOP (5)
 
CONCAT(FirstName + ' ', LastName) AS FullName
FROM Person.Person;

SELECT TOP (5)

UPPER(Name) AS ProductName,
    ProductNumber,
    ROUND(Weight, 0) AS ApproxWeight,
    LEFT(ProductNumber, 2) AS ProductType,
    SUBSTRING(ProductNumber,CHARINDEX('-', ProductNumber) + 1, 4) AS ModelCode,
    SUBSTRING(ProductNumber, LEN(ProductNumber) - CHARINDEX('-', REVERSE(RIGHT(ProductNumber, 3))) + 2, 2) AS SizeCode
FROM Production.Product

SELECT TOP (5)
Name, Size AS NumericSize
FROM Production.Product
WHERE ISNUMERIC(Size) = 1;

 SELECT TOP (5)
 Name, IIF(ISNUMERIC(Size) = 1, 'Numeric', 'Non-Numeric') AS SizeType
 FROM Production.Product

SELECT TOP (5)
prd.Name AS ProductName,
    cat.Name AS Category,
	cat.ProductCategoryID,
    CHOOSE (cat.ProductCategoryID, 'Bikes','Components','Clothing','Accessories') AS ProductType
FROM Production.Product AS prd
JOIN Production.ProductCategory AS cat
    ON prd.ProductSubcategoryID = cat.ProductCategoryID;

 SELECT COUNT(*) AS Products,
        COUNT(DISTINCT ProductSubcategoryID) AS Categories,
        AVG(ListPrice) AS AveragePrice
 FROM Production.Product;

  SELECT COUNT(p.ProductID) AS BikeModels, AVG(p.ListPrice) AS AveragePrice
 FROM Production.Product AS p
 JOIN Production.ProductCategory AS c
     ON p.ProductSubcategoryID = c.ProductCategoryID
 WHERE c.Name LIKE '%Bikes';

SELECT TOP (5)
StoreID, COUNT(CustomerID) AS Customers
FROM Sales.Customer
GROUP BY StoreID
ORDER BY StoreID;

SELECT TOP (5)
c.StoreID, SUM(oh.SubTotal) AS SalesRevenue
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader oh
    ON c.CustomerID = oh.CustomerID
GROUP BY c.StoreID
ORDER BY SalesRevenue DESC;

SELECT TOP (5)
c.StoreID, ISNULL(SUM(oh.SubTotal), 0.00) AS SalesRevenue
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader oh
    ON c.CustomerID = oh.CustomerID
GROUP BY c.StoreID
ORDER BY SalesRevenue DESC;

--SELECT TOP (5)
--StoreID, COUNT(CustomerID) AS Customers
--FROM Sales.Customer
--WHERE COUNT(CustomerID) > 100
--GROUP BY StoreID
--ORDER BY StoreID;

--THIS will give the aggregate error. try the following

SELECT 
StoreID, COUNT(CustomerID) AS Customers
FROM Sales.Customer
GROUP BY StoreID
HAVING COUNT(CustomerID) > 100
ORDER BY StoreID;

SELECT TOP (5)
SalesOrderID,
    ROUND(Freight, 2) AS FreightCost
FROM Sales.SalesOrderHeader;

SELECT TOP (5)
SalesOrderID,
    ROUND(Freight, 2) AS FreightCost,
    LOWER(ShipMethodID) AS ShippingMethod
FROM Sales.SalesOrderHeader;

SELECT TOP (5)
SalesOrderID,
    ROUND(Freight, 2) AS FreightCost,
    LOWER(ShipMethodID) AS ShippingMethod,
    YEAR(ShipDate) AS ShipYear,
    DATENAME(mm, ShipDate) AS ShipMonth,
    DAY(ShipDate) AS ShipDay
FROM Sales.SalesOrderHeader;

SELECT TOP (5)
p.Name,SUM(o.OrderQty) AS TotalSales
FROM Sales.SalesOrderDetail AS o
JOIN Production.Product AS p
    ON o.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalSales DESC;

SELECT TOP (5)
p.Name,SUM(o.OrderQty) AS TotalSales
FROM Sales.SalesOrderDetail AS o
JOIN Production.Product AS p
    ON o.ProductID = p.ProductID
WHERE p.ListPrice > 1000
GROUP BY p.Name
ORDER BY TotalSales DESC;

SELECT TOP (5)
p.Name,SUM(o.OrderQty) AS TotalSales
FROM Sales.SalesOrderDetail AS o
JOIN Production.Product AS p
    ON o.ProductID = p.ProductID
WHERE p.ListPrice > 1000
GROUP BY p.Name
HAVING SUM(o.OrderQty) > 20
ORDER BY TotalSales DESC;