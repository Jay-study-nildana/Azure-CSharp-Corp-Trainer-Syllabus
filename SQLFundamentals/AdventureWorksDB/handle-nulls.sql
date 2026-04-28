SELECT FirstName,
      ISNULL(MiddleName, 'None') AS MiddleIfAny,
      LastName
FROM [Person].[Person];

SELECT [ProductID],
      COALESCE([UnitPrice] * [OrderQty],
                [UnitPriceDiscount],
                0.0 * 0.0) AS ProductSale
FROM [Sales].[SalesOrderDetail];

SELECT SalesOrderID,
      ProductID,
      UnitPrice,
      NULLIF(UnitPriceDiscount, 0) AS Discount
FROM Sales.SalesOrderDetail;

