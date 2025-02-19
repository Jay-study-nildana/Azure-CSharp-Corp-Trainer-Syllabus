 SELECT TOP (5) * FROM [Sales].[SalesOrderDetail]

SELECT TOP (5)

	SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber
  
FROM [Sales].[SalesOrderDetail]

SELECT TOP (5)

	SalesOrderID AS 'Sales Order ID', SalesOrderDetailID, CarrierTrackingNumber
  
FROM [Sales].[SalesOrderDetail]

SELECT TOP (5)

	[FirstName] + [MiddleName] + [LastName] AS 'Full Name'
  
FROM [Person].[Person]

SELECT TOP (5)
	CAST(ProductID AS varchar(5)) + ' : Product'  AS ProductName
FROM [Sales].[SalesOrderDetail]; 

SELECT TOP (5)
	CONVERT(varchar(5), ProductID) + ' : Product'  AS ProductName
FROM [Sales].[SalesOrderDetail];

SELECT TOP (5)
	[StartDate],
    CONVERT(nvarchar(30), [StartDate]) AS ConvertedDate,
    CONVERT(nvarchar(30), [StartDate], 126) AS ISO8601FormatDate 
FROM [Sales].[SpecialOffer];

SELECT TOP (5) 
	[Description], TRY_CAST([SpecialOfferID] AS Integer) AS NumericSize
FROM [Sales].[SpecialOffer]

SELECT TOP (5) 
	[Description], ISNULL(TRY_CAST([SpecialOfferID] AS Integer),0) AS NumericSize
FROM [Sales].[SpecialOffer]

SELECT TOP (5)
	[SpecialOfferID], [MaxQty] AS OriginalMaxQty, ISNULL([MaxQty], 69) + 10  AS ModifiedMaxQty
FROM [Sales].[SpecialOffer]

SELECT TOP (5)
	[Description], [StartDate], [EndDate], COALESCE([StartDate], [EndDate]) AS StatusLastUpdated
FROM [Sales].[SpecialOffer]

SELECT TOP (5)
	[Description], [StartDate], [EndDate],[MaxQty],
    CASE
        WHEN [MaxQty] IS NULL THEN 'No Max Quantity Specified'
        ELSE 'Max Quantity Available'
    END AS SalesStatus
FROM [Sales].[SpecialOffer];