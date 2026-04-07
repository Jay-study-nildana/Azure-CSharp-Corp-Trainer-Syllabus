# Day 4: Database Objects, Indexes, Views, and Stored Procedures

---

## Table of Contents

1. [Recap & Setup](#1-recap--setup)
2. [Introduction to Indexes](#2-introduction-to-indexes)
3. [Clustered Indexes](#3-clustered-indexes)
4. [Non-Clustered Indexes](#4-non-clustered-indexes)
5. [Index Design Guidelines](#5-index-design-guidelines)
6. [Introduction to Views](#6-introduction-to-views)
7. [Creating and Querying Views](#7-creating-and-querying-views)
8. [Advanced View Topics](#8-advanced-view-topics)
9. [Introduction to Stored Procedures](#9-introduction-to-stored-procedures)
10. [Creating and Using Stored Procedures](#10-creating-and-using-stored-procedures)
11. [Advanced Stored Procedure Patterns](#11-advanced-stored-procedure-patterns)
12. [Exception Handling with TRY-CATCH](#12-exception-handling-with-try-catch)
13. [User-Defined Functions (Bonus)](#13-user-defined-functions-bonus)
14. [Triggers (Bonus)](#14-triggers-bonus)
15. [Day 4 Summary](#15-day-4-summary)
16. [Hands-On Exercises](#16-hands-on-exercises)

---

## 1. Recap & Setup

### 1.1 Quick Recap of Day 3

| Concept                | Key Point                                               |
| ---------------------- | ------------------------------------------------------- |
| INNER JOIN             | Only matching rows                                      |
| LEFT / RIGHT JOIN      | All rows from one side + matches from the other         |
| FULL OUTER JOIN        | All rows from both sides                                |
| CROSS JOIN             | Cartesian product                                       |
| Self Join              | Table joined to itself                                  |
| Subqueries             | Nested SELECTs (scalar, multi-value, correlated)        |
| EXISTS / NOT EXISTS    | Best for existence checks; NULL-safe                    |
| CTEs                   | Named temporary result sets; support recursion          |
| Query Optimization     | SARGable predicates, avoid SELECT *, prefer EXISTS      |

### 1.2 Continuing with RetailDB

We continue using the **RetailDB** database from Days 2 and 3. If you need
to recreate it, refer to the Day 2 and Day 3 setup scripts.

Let's also add a logging table that we will use later:

```sql
USE RetailDB;
GO

-- Audit log for tracking changes
CREATE TABLE dbo.AuditLog (
    AuditID     INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    TableName   NVARCHAR(100)  NOT NULL,
    Operation   NVARCHAR(10)   NOT NULL,  -- INSERT, UPDATE, DELETE
    RecordID    INT,
    OldValues   NVARCHAR(MAX),
    NewValues   NVARCHAR(MAX),
    ChangedBy   NVARCHAR(128)  NOT NULL DEFAULT SYSTEM_USER,
    ChangedDate DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);
GO
```

---

## 2. Introduction to Indexes

### 2.1 What Is an Index?

An **index** is a data structure that improves the speed of data retrieval.
Think of it like the index at the back of a textbook — instead of scanning
every page to find "SQL Server," you look up the index and go directly to
the right page.

### 2.2 Without an Index (Table Scan)

```
Query: SELECT * FROM Products WHERE ProductName = 'Laptop Pro 15';

Without an index, SQL Server must check EVERY row:

Row 1:  Laptop Pro 15    ✅ Match!
Row 2:  Wireless Mouse   ❌
Row 3:  USB-C Hub        ❌
Row 4:  Mechanical KB    ❌
...
Row 18: Basketball       ❌

→ 18 rows scanned to find 1 match = TABLE SCAN
```

### 2.3 With an Index (Index Seek)

```
With an index on ProductName:

Index (sorted alphabetically):
  Air Fryer → Row 15
  Basketball → Row 18
  ...
  Laptop Pro 15 → Row 1    ✅ Found immediately!
  ...
  Yoga Mat → Row 16

→ Jump directly to the right entry = INDEX SEEK
```

### 2.4 Index Types in SQL Server

| Index Type            | Description                                            |
| --------------------- | ------------------------------------------------------ |
| **Clustered**         | Sorts and stores the actual table data in order         |
| **Non-Clustered**     | Separate structure with pointers back to the table      |
| **Unique**            | Ensures no duplicate values (can be clustered or not)   |
| **Filtered**          | Index on a subset of rows (with a WHERE clause)         |
| **Covering**          | Includes all columns needed by a query                  |
| **Columnstore**       | Column-based storage for analytics (advanced)           |
| **Full-Text**         | Specialized for text search (advanced)                  |

### 2.5 The Book Analogy

```
A physical book:

┌─────────────────────────────────────────────┐
│                                             │
│  CLUSTERED INDEX = The book itself          │
│  (pages sorted by chapter/page number)      │
│                                             │
│  NON-CLUSTERED INDEX = The back-of-book     │
│  index (sorted alphabetically, with page    │
│  numbers pointing to the actual pages)      │
│                                             │
│  You can have:                              │
│    - Only ONE way to physically sort pages   │
│      (one clustered index)                  │
│    - MANY back-of-book indexes              │
│      (multiple non-clustered indexes)       │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 3. Clustered Indexes

### 3.1 What Is a Clustered Index?

A clustered index determines the **physical order** of data in a table. The
table data itself **is** the clustered index.

Key facts:
- A table can have **only ONE** clustered index.
- By default, the **PRIMARY KEY** creates a clustered index.
- Data is stored in a **B-tree** (balanced tree) structure.

### 3.2 B-Tree Structure

```
                        ┌─────────────┐
                        │  Root Node  │
                        │  [50, 100]  │
                        └──────┬──────┘
               ┌───────────────┼───────────────┐
               ▼               ▼               ▼
        ┌────────────┐  ┌────────────┐  ┌────────────┐
        │ < 50       │  │ 50–100     │  │ > 100      │
        │ [10,25,40] │  │ [60,75,90] │  │ [110,130]  │
        └──────┬─────┘  └──────┬─────┘  └──────┬─────┘
               ▼               ▼               ▼
        ┌──────────┐    ┌──────────┐    ┌──────────┐
        │ Leaf     │    │ Leaf     │    │ Leaf     │
        │ (actual  │    │ (actual  │    │ (actual  │
        │  data    │    │  data    │    │  data    │
        │  rows)   │    │  rows)   │    │  rows)   │
        └──────────┘    └──────────┘    └──────────┘

Finding ID = 75:
  Root: 50 ≤ 75 ≤ 100 → go to middle child
  Intermediate: find 75 → go to leaf
  Leaf: return the actual data row

Only 3 levels traversed instead of scanning all rows!
```

### 3.3 Default Clustered Index (Primary Key)

```sql
-- When you create a PRIMARY KEY, SQL Server automatically creates
-- a clustered index (unless you specify NONCLUSTERED)

CREATE TABLE dbo.TestClustered (
    ID   INT NOT NULL PRIMARY KEY,       -- clustered index created automatically
    Name NVARCHAR(50)
);

-- Verify:
EXEC sp_helpindex 'dbo.TestClustered';
```

| index_name                | index_description                          | index_keys |
| ------------------------- | ------------------------------------------ | ---------- |
| PK__TestClus__3214EC27... | clustered, unique, primary key             | ID         |

### 3.4 Creating a Custom Clustered Index

```sql
-- Create a table WITHOUT a clustered index on the PK
CREATE TABLE dbo.LogEntries (
    LogID       INT            NOT NULL IDENTITY(1,1),
    LogDate     DATETIME2      NOT NULL,
    Message     NVARCHAR(500)  NOT NULL,
    Severity    NVARCHAR(10)   NOT NULL,
    CONSTRAINT PK_LogEntries PRIMARY KEY NONCLUSTERED (LogID)
);

-- Create a clustered index on LogDate (most queries filter by date)
CREATE CLUSTERED INDEX IX_LogEntries_LogDate
ON dbo.LogEntries (LogDate);
GO
```

> **Why?** If most queries filter by date range, physically sorting the data
> by `LogDate` makes range scans much faster.

### 3.5 Viewing Index Information

```sql
-- Method 1: sp_helpindex
EXEC sp_helpindex 'dbo.Products';

-- Method 2: System views
SELECT
    i.name            AS IndexName,
    i.type_desc       AS IndexType,
    i.is_unique       AS IsUnique,
    i.is_primary_key  AS IsPrimaryKey,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName,
    ic.is_included_column AS IsIncluded
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id
                          AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'Products'
ORDER BY i.index_id, ic.key_ordinal;
```

---

## 4. Non-Clustered Indexes

### 4.1 What Is a Non-Clustered Index?

A non-clustered index is a **separate structure** from the table data. It
contains:
- The indexed column values (sorted)
- A **pointer** (row locator) back to the actual data row

### 4.2 How Non-Clustered Indexes Work

```
Table (Clustered Index on ProductID):
┌────────────┬─────────────────────┬──────────┬───────┐
│ ProductID  │ ProductName         │ Price    │ Stock │
├────────────┼─────────────────────┼──────────┼───────┤
│ 1          │ Laptop Pro 15       │ 1299.99  │ 50    │
│ 2          │ Wireless Mouse      │ 29.99    │ 200   │
│ 3          │ USB-C Hub           │ 49.99    │ 150   │
│ ...        │ ...                 │ ...      │ ...   │
└────────────┴─────────────────────┴──────────┴───────┘

Non-Clustered Index on ProductName:
┌��────────────────────┬────────────┐
│ ProductName (sorted) │ ProductID  │  ← pointer to clustered index
├─────────────────────┼────────────┤
│ Air Fryer           │ 15         │
│ Basketball          │ 18         │
│ Blender Pro         │ 14         │
│ Clean Code          │ 11         │
│ ...                 │ ...        │
│ Laptop Pro 15       │ 1          │  ← finding this is fast!
│ ...                 │ ...        │
└─────────────────────┴────────────┘

Query: WHERE ProductName = 'Laptop Pro 15'
Step 1: Search NC index → find ProductID = 1
Step 2: Go to Clustered Index → find full row (Key Lookup)
```

### 4.3 Creating Non-Clustered Indexes

```sql
-- Simple non-clustered index
CREATE NONCLUSTERED INDEX IX_Products_ProductName
ON dbo.Products (ProductName);
GO

-- Composite index (multiple columns)
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID_OrderDate
ON dbo.Orders (CustomerID, OrderDate DESC);
GO

-- Unique non-clustered index
CREATE UNIQUE NONCLUSTERED INDEX IX_Customers_Email
ON dbo.Customers (Email);
GO
```

### 4.4 Included Columns (Covering Index)

A **covering index** includes all the columns a query needs, so SQL Server
doesn't have to go back to the table (avoiding the **Key Lookup**).

```sql
-- Query we want to optimize:
SELECT ProductName, Price
FROM dbo.Products
WHERE CategoryID = 1;

-- Non-clustered index on CategoryID with INCLUDED columns
CREATE NONCLUSTERED INDEX IX_Products_CategoryID_Incl
ON dbo.Products (CategoryID)
INCLUDE (ProductName, Price);
GO
```

```
Without INCLUDE:
  1. Seek IX on CategoryID → find ProductIDs
  2. Key Lookup → get ProductName, Price from table (SLOW for many rows)

With INCLUDE:
  1. Seek IX on CategoryID → ProductName and Price are RIGHT THERE
  2. No Key Lookup needed! (FAST)
```

### 4.5 Filtered Indexes

A filtered index covers only a **subset** of rows, making it smaller and faster.

```sql
-- Index only on active products
CREATE NONCLUSTERED INDEX IX_Products_Active
ON dbo.Products (ProductName, Price)
WHERE IsActive = 1;
GO

-- Index only on pending orders
CREATE NONCLUSTERED INDEX IX_Orders_Pending
ON dbo.Orders (CustomerID, OrderDate)
WHERE Status = N'Pending';
GO
```

> **When to use:** When queries frequently filter on a specific value and
> that value represents a small portion of the data.

### 4.6 Dropping and Rebuilding Indexes

```sql
-- Drop an index
DROP INDEX IX_Products_ProductName ON dbo.Products;
GO

-- Rebuild an index (removes fragmentation)
ALTER INDEX IX_Products_CategoryID_Incl ON dbo.Products REBUILD;
GO

-- Reorganize an index (lighter defragmentation)
ALTER INDEX IX_Products_CategoryID_Incl ON dbo.Products REORGANIZE;
GO

-- Rebuild ALL indexes on a table
ALTER INDEX ALL ON dbo.Products REBUILD;
GO
```

### 4.7 Checking Index Fragmentation

```sql
-- Check fragmentation levels
SELECT
    OBJECT_NAME(ips.object_id)        AS TableName,
    i.name                            AS IndexName,
    i.type_desc                       AS IndexType,
    ips.avg_fragmentation_in_percent  AS FragmentationPct,
    ips.page_count                    AS Pages,
    ips.record_count                  AS Records
FROM sys.dm_db_index_physical_stats(
    DB_ID(), NULL, NULL, NULL, 'LIMITED'
) ips
JOIN sys.indexes i
    ON ips.object_id = i.object_id
    AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 5
  AND ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;
```

| Fragmentation     | Action                      |
| ----------------- | --------------------------- |
| 5% – 30%          | `REORGANIZE` (lightweight)  |
| > 30%             | `REBUILD` (full rebuild)    |
| < 5%              | No action needed            |

---

## 5. Index Design Guidelines

### 5.1 When to Create an Index

✅ **Good candidates for indexing:**
- Columns used in `WHERE` clauses
- Columns used in `JOIN` conditions
- Columns used in `ORDER BY`
- Columns used in `GROUP BY`
- Foreign key columns (almost always)
- Columns with high selectivity (many unique values)

❌ **Avoid indexing:**
- Very small tables (table scan is just as fast)
- Columns with low selectivity (e.g., `BIT`, `Gender`)
- Columns that are frequently updated
- Tables with very heavy INSERT/UPDATE/DELETE workloads

### 5.2 The Cost of Indexes

```
More indexes = FASTER reads (SELECT)
More indexes = SLOWER writes (INSERT, UPDATE, DELETE)

Every INSERT must update ALL indexes on the table.
Every UPDATE on an indexed column must update those indexes.
Every DELETE must remove entries from ALL indexes.

Balance is key!
```

### 5.3 Composite Index Column Order

The **order of columns** in a composite index matters:

```sql
-- Index on (CustomerID, OrderDate)
CREATE INDEX IX_Orders_Cust_Date ON dbo.Orders (CustomerID, OrderDate);
```

```
This index helps these queries:
  ✅ WHERE CustomerID = 5                              (leftmost column)
  ✅ WHERE CustomerID = 5 AND OrderDate > '2025-01-01' (both columns)
  ✅ WHERE CustomerID = 5 ORDER BY OrderDate            (seek + range)

This index does NOT help:
  ❌ WHERE OrderDate > '2025-01-01'                     (skips leftmost column)
```

> **Rule:** Put the most **selective** (most unique) column first, followed
> by columns used in range filters.

### 5.4 Index Design Decision Flowchart

```
Query is slow?
│
├── Check the execution plan
│   ├── Table Scan? → Create an index on the WHERE columns
│   ├── Key Lookup? → Add missing columns to INCLUDE
│   └── Index Scan? → Column order might be wrong
│
├── Is the column in WHERE/JOIN/ORDER BY?
│   ├── Yes → Candidate for index
│   └── No  → Probably don't index it
│
├── How selective is the column?
│   ├── Many unique values → Good candidate
│   └── Few unique values (BIT, Status) → Consider filtered index
│
└── Is the table write-heavy?
    ├── Yes → Be conservative with indexes
    └── No  → Index more aggressively
```

### 5.5 Index Usage Statistics

```sql
-- See which indexes are being used (and which aren't)
SELECT
    OBJECT_NAME(s.object_id)  AS TableName,
    i.name                    AS IndexName,
    i.type_desc               AS IndexType,
    s.user_seeks              AS Seeks,
    s.user_scans              AS Scans,
    s.user_lookups            AS Lookups,
    s.user_updates            AS Updates,
    s.last_user_seek          AS LastSeek,
    s.last_user_scan          AS LastScan
FROM sys.dm_db_index_usage_stats s
JOIN sys.indexes i
    ON s.object_id = i.object_id
    AND s.index_id = i.index_id
WHERE s.database_id = DB_ID()
  AND OBJECT_NAME(s.object_id) NOT LIKE 'sys%'
ORDER BY s.user_seeks + s.user_scans DESC;
```

> **Tip:** If `user_seeks = 0` and `user_scans = 0` but `user_updates > 0`,
> the index is not being used for reads but is slowing down writes. Consider
> dropping it.

### 5.6 Missing Index Suggestions

```sql
-- SQL Server tracks which indexes it wishes it had
SELECT
    OBJECT_NAME(mid.object_id)        AS TableName,
    mid.equality_columns              AS EqualityColumns,
    mid.inequality_columns            AS InequalityColumns,
    mid.included_columns              AS IncludedColumns,
    migs.avg_user_impact              AS AvgImprovementPct,
    migs.user_seeks                   AS TimesNeeded
FROM sys.dm_db_missing_index_details mid
JOIN sys.dm_db_missing_index_groups mig
    ON mid.index_handle = mig.index_handle
JOIN sys.dm_db_missing_index_group_stats migs
    ON mig.index_group_handle = migs.group_handle
WHERE mid.database_id = DB_ID()
ORDER BY migs.avg_user_impact * migs.user_seeks DESC;
```

---

## 6. Introduction to Views

### 6.1 What Is a View?

A **view** is a virtual table based on a SELECT statement. It does not store
data — it stores the **query definition** and executes it when you query the view.

### 6.2 Why Use Views?

| Benefit           | Description                                              |
| ----------------- | -------------------------------------------------------- |
| **Simplicity**    | Hide complex joins and logic behind a simple name        |
| **Security**      | Expose only certain columns/rows to specific users       |
| **Consistency**   | One source of truth for common query patterns            |
| **Abstraction**   | Change underlying tables without breaking applications   |
| **Reusability**   | Write the query once, use it everywhere                  |

### 6.3 View vs Table vs CTE

| Feature           | Table           | View              | CTE              |
| ----------------- | --------------- | ----------------- | ---------------- |
| Stores data?      | ✅ Yes          | ❌ No (query only) | ❌ No            |
| Persisted?        | ✅ Yes          | ✅ Definition saved | ❌ Single query  |
| Can be indexed?   | ✅ Yes          | ✅ (Indexed Views) | ❌ No            |
| Reusable across queries? | ✅ Yes   | ✅ Yes             | ❌ No            |
| Security (GRANT)? | ✅ Yes          | ✅ Yes             | ❌ No            |

---

## 7. Creating and Querying Views

### 7.1 Basic View Syntax

```sql
CREATE VIEW [schema_name.]view_name
AS
    SELECT columns
    FROM tables
    [WHERE conditions]
    [GROUP BY columns];
GO
```

### 7.2 Simple View

```sql
-- View: Active products with category names
CREATE VIEW dbo.vw_ActiveProducts
AS
    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        p.Price,
        p.Stock,
        p.CreatedDate
    FROM dbo.Products p
    JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
    WHERE p.IsActive = 1;
GO

-- Query the view just like a table
SELECT * FROM dbo.vw_ActiveProducts;

-- Filter the view
SELECT ProductName, Price
FROM dbo.vw_ActiveProducts
WHERE CategoryName = N'Electronics'
ORDER BY Price DESC;
```

### 7.3 View with Aggregation

```sql
-- View: Customer order summary
CREATE VIEW dbo.vw_CustomerOrderSummary
AS
    SELECT
        c.CustomerID,
        c.FirstName + N' ' + c.LastName  AS CustomerName,
        c.Email,
        c.City,
        c.Country,
        COUNT(DISTINCT o.OrderID)         AS TotalOrders,
        ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalSpent,
        MAX(o.OrderDate)                  AS LastOrderDate
    FROM dbo.Customers c
    LEFT JOIN dbo.Orders o      ON c.CustomerID = o.CustomerID
                                AND o.Status <> N'Cancelled'
    LEFT JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
    GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email, c.City, c.Country;
GO

-- Use the view
SELECT *
FROM dbo.vw_CustomerOrderSummary
WHERE TotalOrders > 1
ORDER BY TotalSpent DESC;
```

### 7.4 View with Joins and Calculations

```sql
-- View: Detailed order line items
CREATE VIEW dbo.vw_OrderDetails
AS
    SELECT
        o.OrderID,
        o.OrderDate,
        o.Status,
        c.FirstName + N' ' + c.LastName AS CustomerName,
        c.City,
        c.Country,
        p.ProductName,
        cat.CategoryName,
        oi.Quantity,
        oi.UnitPrice,
        oi.Quantity * oi.UnitPrice       AS LineTotal
    FROM dbo.Orders o
    JOIN dbo.Customers c     ON o.CustomerID = c.CustomerID
    JOIN dbo.OrderItems oi   ON o.OrderID    = oi.OrderID
    JOIN dbo.Products p      ON oi.ProductID = p.ProductID
    JOIN dbo.Categories cat  ON p.CategoryID = cat.CategoryID;
GO

-- Now complex reports become simple:
-- Revenue by category
SELECT CategoryName, SUM(LineTotal) AS Revenue
FROM dbo.vw_OrderDetails
WHERE Status <> N'Cancelled'
GROUP BY CategoryName
ORDER BY Revenue DESC;

-- Revenue by country
SELECT Country, SUM(LineTotal) AS Revenue
FROM dbo.vw_OrderDetails
WHERE Status <> N'Cancelled'
GROUP BY Country
ORDER BY Revenue DESC;
```

### 7.5 View for Security

```sql
-- View that hides sensitive data
CREATE VIEW dbo.vw_PublicCustomerList
AS
    SELECT
        CustomerID,
        FirstName,
        LEFT(LastName, 1) + '***'   AS LastName,   -- mask last name
        LEFT(Email, 3) + '***@***'  AS Email,       -- mask email
        City,
        Country
    FROM dbo.Customers;
GO

-- Grant access to the view (not the underlying table)
-- GRANT SELECT ON dbo.vw_PublicCustomerList TO [PublicUser];
-- DENY SELECT ON dbo.Customers TO [PublicUser];

SELECT * FROM dbo.vw_PublicCustomerList;
```

| CustomerID | FirstName | LastName | Email         | City        | Country        |
| ---------- | --------- | -------- | ------------- | ----------- | -------------- |
| 1          | Alice     | J***     | ali***@***    | New York    | United States  |
| 2          | Bob       | S***     | bob***@***    | Los Angeles | United States  |
| 3          | Charlie   | L***     | cha***@***    | London      | United Kingdom |

### 7.6 Altering and Dropping Views

```sql
-- Modify an existing view
ALTER VIEW dbo.vw_ActiveProducts
AS
    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        p.Price,
        p.Stock,
        p.CreatedDate,
        p.Price * p.Stock AS InventoryValue   -- added column
    FROM dbo.Products p
    JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
    WHERE p.IsActive = 1;
GO

-- Drop a view
DROP VIEW IF EXISTS dbo.vw_PublicCustomerList;
GO
```

### 7.7 Viewing View Definitions

```sql
-- Method 1: sp_helptext
EXEC sp_helptext 'dbo.vw_ActiveProducts';

-- Method 2: OBJECT_DEFINITION
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.vw_ActiveProducts'));

-- Method 3: INFORMATION_SCHEMA
SELECT VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME = 'vw_ActiveProducts';
```

---

## 8. Advanced View Topics

### 8.1 Updatable Views

You **can** INSERT, UPDATE, and DELETE through a view if:
- The view references a single base table (for the modified columns).
- The view doesn't use GROUP BY, HAVING, DISTINCT, or TOP.
- All NOT NULL columns without defaults are included.

```sql
-- This view is updatable (single table, no aggregation)
CREATE VIEW dbo.vw_ElectronicsProducts
AS
    SELECT ProductID, ProductName, Price, Stock
    FROM dbo.Products
    WHERE CategoryID = 1;
GO

-- Update through the view
UPDATE dbo.vw_ElectronicsProducts
SET Price = Price * 1.05
WHERE ProductName = N'Wireless Mouse';

-- Insert through the view (only works if all required columns have values/defaults)
-- This would fail because CategoryID is NOT NULL and not in the view:
-- INSERT INTO dbo.vw_ElectronicsProducts (ProductName, Price, Stock)
-- VALUES (N'New Gadget', 99.99, 10);
```

### 8.2 WITH CHECK OPTION

Prevents INSERT or UPDATE operations that would cause a row to disappear
from the view:

```sql
CREATE VIEW dbo.vw_CheapProducts
AS
    SELECT ProductID, ProductName, Price, CategoryID
    FROM dbo.Products
    WHERE Price < 50
    WITH CHECK OPTION;    -- enforces the WHERE clause on modifications
GO

-- ✅ This works (price stays under 50):
UPDATE dbo.vw_CheapProducts SET Price = 45.00 WHERE ProductID = 2;

-- ❌ This fails (price would exceed 50, violating the view's WHERE):
UPDATE dbo.vw_CheapProducts SET Price = 99.99 WHERE ProductID = 2;
-- Error: The attempted insert or update failed because the target view
-- specifies WITH CHECK OPTION
```

### 8.3 WITH SCHEMABINDING

Prevents the underlying tables from being altered or dropped if a view
depends on them:

```sql
CREATE VIEW dbo.vw_ProductInventory
WITH SCHEMABINDING    -- locks the schema
AS
    SELECT
        p.ProductID,
        p.ProductName,
        p.Price,
        p.Stock,
        p.Price * p.Stock AS InventoryValue
    FROM dbo.Products p;  -- must use two-part names (schema.table)
GO

-- Now this would FAIL:
-- ALTER TABLE dbo.Products DROP COLUMN Stock;
-- Error: Cannot ALTER because view 'vw_ProductInventory' depends on it
```

> **Note:** With `SCHEMABINDING`, you **must** use two-part table names
> (e.g., `dbo.Products`, not just `Products`) and cannot use `SELECT *`.

### 8.4 Indexed Views (Materialized Views)

An indexed view physically stores the result set, making queries much faster
at the cost of storage and write overhead.

```sql
-- Step 1: Create view with SCHEMABINDING (required for indexed views)
CREATE VIEW dbo.vw_CategoryRevenue
WITH SCHEMABINDING
AS
    SELECT
        p.CategoryID,
        COUNT_BIG(*) AS OrderLineCount,   -- required for indexed views
        SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue,
        SUM(oi.Quantity) AS TotalQuantity
    FROM dbo.OrderItems oi
    JOIN dbo.Products p ON oi.ProductID = p.ProductID
    GROUP BY p.CategoryID;
GO

-- Step 2: Create a unique clustered index on the view
CREATE UNIQUE CLUSTERED INDEX IX_vw_CategoryRevenue
ON dbo.vw_CategoryRevenue (CategoryID);
GO

-- Now the view's data is physically stored and auto-maintained!
SELECT * FROM dbo.vw_CategoryRevenue;
```

**Indexed View Requirements:**
- Must use `WITH SCHEMABINDING`
- Must include `COUNT_BIG(*)` if using aggregates
- Cannot use `OUTER JOIN`, subqueries, `UNION`, `DISTINCT`, `TOP`, etc.
- Unique clustered index required

### 8.5 Views Summary

```
View Type            Use Case
────────────────────────────────────────────────────
Simple View          Hide complexity, limit columns
Aggregated View      Pre-built reports and dashboards
Security View        Mask/restrict data for users
Updatable View       Allow modifications through views
Indexed View         Precomputed results for speed
WITH CHECK OPTION    Enforce view criteria on DML
WITH SCHEMABINDING   Protect underlying schema
```

---

## 9. Introduction to Stored Procedures

### 9.1 What Is a Stored Procedure?

A **stored procedure** is a precompiled collection of T-SQL statements stored
in the database. Think of it as a **reusable program** that lives in your database.

### 9.2 Why Use Stored Procedures?

| Benefit             | Description                                            |
| ------------------- | ------------------------------------------------------ |
| **Reusability**     | Write once, call many times                            |
| **Performance**     | Compiled and cached execution plan                     |
| **Security**        | Grant EXECUTE permission without table access           |
| **Maintainability** | Change logic in one place                              |
| **Encapsulation**   | Hide complex business logic                            |
| **Reduced Traffic** | Send a procedure name instead of many SQL statements   |
| **Parameterization**| Accept inputs and return outputs                       |

### 9.3 Stored Procedure vs Inline SQL

```
Inline SQL:
  Application → sends "SELECT * FROM Products WHERE Price > 100" → SQL Server
  - SQL must be parsed and compiled each time
  - SQL injection risk if parameters are concatenated
  - Logic scattered across application code

Stored Procedure:
  Application → calls "EXEC sp_GetExpensiveProducts @MinPrice = 100" → SQL Server
  - Compiled once, plan cached
  - Parameters are type-safe (no SQL injection)
  - Logic centralized in the database
```

---

## 10. Creating and Using Stored Procedures

### 10.1 Basic Syntax

```sql
CREATE PROCEDURE [schema_name.]procedure_name
    @Parameter1 DataType [= DefaultValue],
    @Parameter2 DataType [= DefaultValue],
    ...
AS
BEGIN
    SET NOCOUNT ON;    -- suppress "x rows affected" messages
    -- T-SQL statements
END;
GO
```

### 10.2 Simple Stored Procedure (No Parameters)

```sql
CREATE PROCEDURE dbo.usp_GetAllActiveProducts
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        p.Price,
        p.Stock
    FROM dbo.Products p
    JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
    WHERE p.IsActive = 1
    ORDER BY c.CategoryName, p.ProductName;
END;
GO

-- Execute:
EXEC dbo.usp_GetAllActiveProducts;
```

> **Naming convention:** Prefix user stored procedures with `usp_` to
> distinguish them from system procedures (`sp_`). **Avoid** using the
> `sp_` prefix — SQL Server checks the `master` database first for `sp_`
> procedures, causing a slight performance hit.

### 10.3 Stored Procedure with INPUT Parameters

```sql
CREATE PROCEDURE dbo.usp_GetProductsByCategory
    @CategoryName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProductID,
        p.ProductName,
        p.Price,
        p.Stock
    FROM dbo.Products p
    JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
    WHERE c.CategoryName = @CategoryName
      AND p.IsActive = 1
    ORDER BY p.Price DESC;
END;
GO

-- Execute with different parameters:
EXEC dbo.usp_GetProductsByCategory @CategoryName = N'Electronics';
EXEC dbo.usp_GetProductsByCategory @CategoryName = N'Books';
EXEC dbo.usp_GetProductsByCategory N'Sports';  -- positional parameter
```

### 10.4 Multiple Parameters with Defaults

```sql
CREATE PROCEDURE dbo.usp_SearchProducts
    @SearchTerm  NVARCHAR(100) = NULL,
    @CategoryID  INT           = NULL,
    @MinPrice    DECIMAL(10,2) = NULL,
    @MaxPrice    DECIMAL(10,2) = NULL,
    @InStockOnly BIT           = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        p.Price,
        p.Stock
    FROM dbo.Products p
    JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
    WHERE p.IsActive = 1
      AND (@SearchTerm IS NULL OR p.ProductName LIKE N'%' + @SearchTerm + N'%')
      AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
      AND (@MinPrice   IS NULL OR p.Price >= @MinPrice)
      AND (@MaxPrice   IS NULL OR p.Price <= @MaxPrice)
      AND (@InStockOnly = 0    OR p.Stock > 0)
    ORDER BY p.ProductName;
END;
GO

-- Various ways to call:
EXEC dbo.usp_SearchProducts;                                    -- all active products
EXEC dbo.usp_SearchProducts @SearchTerm = N'laptop';           -- search by name
EXEC dbo.usp_SearchProducts @CategoryID = 1, @MinPrice = 50;   -- electronics over $50
EXEC dbo.usp_SearchProducts @MaxPrice = 30, @InStockOnly = 0;  -- under $30, including out-of-stock
```

### 10.5 OUTPUT Parameters

```sql
CREATE PROCEDURE dbo.usp_GetProductStats
    @CategoryID     INT,
    @ProductCount   INT           OUTPUT,
    @AvgPrice       DECIMAL(10,2) OUTPUT,
    @TotalInventory INT           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @ProductCount   = COUNT(*),
        @AvgPrice       = ROUND(AVG(Price), 2),
        @TotalInventory = SUM(Stock)
    FROM dbo.Products
    WHERE CategoryID = @CategoryID
      AND IsActive = 1;
END;
GO

-- Calling with OUTPUT parameters
DECLARE @Count INT, @Avg DECIMAL(10,2), @Inventory INT;

EXEC dbo.usp_GetProductStats
    @CategoryID     = 1,
    @ProductCount   = @Count    OUTPUT,
    @AvgPrice       = @Avg      OUTPUT,
    @TotalInventory = @Inventory OUTPUT;

SELECT
    @Count     AS ProductCount,
    @Avg       AS AvgPrice,
    @Inventory AS TotalInventory;
```

### 10.6 RETURN Values

Stored procedures can return an integer **status code**:

```sql
CREATE PROCEDURE dbo.usp_PlaceOrder
    @CustomerID INT,
    @ProductID  INT,
    @Quantity   INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if product exists and has enough stock
    DECLARE @Stock INT, @Price DECIMAL(10,2);

    SELECT @Stock = Stock, @Price = Price
    FROM dbo.Products
    WHERE ProductID = @ProductID AND IsActive = 1;

    IF @Stock IS NULL
    BEGIN
        PRINT 'Product not found or inactive.';
        RETURN -1;  -- error code
    END;

    IF @Stock < @Quantity
    BEGIN
        PRINT 'Insufficient stock. Available: ' + CAST(@Stock AS VARCHAR(10));
        RETURN -2;  -- error code
    END;

    -- Create the order
    DECLARE @OrderID INT;

    INSERT INTO dbo.Orders (CustomerID, OrderDate, Status)
    VALUES (@CustomerID, SYSDATETIME(), N'Pending');

    SET @OrderID = SCOPE_IDENTITY();

    INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@OrderID, @ProductID, @Quantity, @Price);

    -- Decrease stock
    UPDATE dbo.Products
    SET Stock = Stock - @Quantity
    WHERE ProductID = @ProductID;

    PRINT 'Order placed successfully. OrderID: ' + CAST(@OrderID AS VARCHAR(10));
    RETURN 0;  -- success
END;
GO

-- Execute and capture the return value
DECLARE @Result INT;
EXEC @Result = dbo.usp_PlaceOrder
    @CustomerID = 1,
    @ProductID  = 2,
    @Quantity   = 3;

SELECT @Result AS ReturnCode;
-- 0 = success, -1 = not found, -2 = insufficient stock
```

### 10.7 Altering and Dropping Procedures

```sql
-- Modify an existing procedure
ALTER PROCEDURE dbo.usp_GetAllActiveProducts
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.ProductID, p.ProductName, p.Price
    FROM dbo.Products p
    WHERE p.IsActive = 1
    ORDER BY p.ProductName;
END;
GO

-- Drop a procedure
DROP PROCEDURE IF EXISTS dbo.usp_GetAllActiveProducts;
GO

-- View procedure definition
EXEC sp_helptext 'dbo.usp_SearchProducts';
```

---

## 11. Advanced Stored Procedure Patterns

### 11.1 Procedure with Transaction

```sql
CREATE PROCEDURE dbo.usp_TransferStock
    @FromProductID INT,
    @ToProductID   INT,
    @Quantity      INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate inputs
    IF @Quantity <= 0
    BEGIN
        RAISERROR('Quantity must be positive.', 16, 1);
        RETURN -1;
    END;

    DECLARE @FromStock INT;
    SELECT @FromStock = Stock FROM dbo.Products WHERE ProductID = @FromProductID;

    IF @FromStock IS NULL OR @FromStock < @Quantity
    BEGIN
        RAISERROR('Insufficient stock in source product.', 16, 1);
        RETURN -2;
    END;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Decrease source stock
        UPDATE dbo.Products
        SET Stock = Stock - @Quantity
        WHERE ProductID = @FromProductID;

        -- Increase destination stock
        UPDATE dbo.Products
        SET Stock = Stock + @Quantity
        WHERE ProductID = @ToProductID;

        -- Log the transfer
        INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, NewValues)
        VALUES (
            N'Products',
            N'TRANSFER',
            @FromProductID,
            CONCAT(N'Transferred ', @Quantity, N' units to ProductID ', @ToProductID)
        );

        COMMIT TRANSACTION;
        PRINT 'Transfer completed successfully.';
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;  -- re-throw the error
    END CATCH;
END;
GO

-- Test:
EXEC dbo.usp_TransferStock
    @FromProductID = 1,
    @ToProductID   = 2,
    @Quantity      = 5;
```

### 11.2 Procedure with Temp Tables

```sql
CREATE PROCEDURE dbo.usp_GenerateSalesReport
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Create a temp table for intermediate calculations
    CREATE TABLE #DailySales (
        SaleDate     DATE,
        TotalOrders  INT,
        TotalItems   INT,
        TotalRevenue DECIMAL(12,2)
    );

    -- Populate it
    INSERT INTO #DailySales
    SELECT
        CAST(o.OrderDate AS DATE),
        COUNT(DISTINCT o.OrderID),
        SUM(oi.Quantity),
        SUM(oi.Quantity * oi.UnitPrice)
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
    WHERE o.Status <> N'Cancelled'
      AND CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
    GROUP BY CAST(o.OrderDate AS DATE);

    -- Return the report with running totals
    SELECT
        SaleDate,
        TotalOrders,
        TotalItems,
        TotalRevenue,
        SUM(TotalRevenue) OVER (ORDER BY SaleDate) AS RunningRevenue,
        AVG(TotalRevenue) OVER (ORDER BY SaleDate
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS SevenDayAvg
    FROM #DailySales
    ORDER BY SaleDate;

    -- Temp table is automatically dropped when the procedure ends
END;
GO

EXEC dbo.usp_GenerateSalesReport
    @StartDate = '2025-01-01',
    @EndDate   = '2025-03-31';
```

### 11.3 Procedure with Dynamic SQL

```sql
CREATE PROCEDURE dbo.usp_DynamicSearch
    @TableName   NVARCHAR(128),
    @ColumnName  NVARCHAR(128),
    @SearchValue NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    -- ⚠️ IMPORTANT: Validate inputs to prevent SQL injection
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME   = @TableName
          AND COLUMN_NAME  = @ColumnName
    )
    BEGIN
        RAISERROR('Invalid table or column name.', 16, 1);
        RETURN -1;
    END;

    -- Build and execute dynamic SQL safely using QUOTENAME
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'SELECT * FROM dbo.' + QUOTENAME(@TableName)
             + N' WHERE ' + QUOTENAME(@ColumnName) + N' LIKE @SearchVal';

    EXEC sp_executesql @SQL,
        N'@SearchVal NVARCHAR(200)',
        @SearchVal = N'%' + @SearchValue + N'%';
END;
GO

EXEC dbo.usp_DynamicSearch
    @TableName   = N'Products',
    @ColumnName  = N'ProductName',
    @SearchValue = N'Laptop';
```

> **Security:** Always use `QUOTENAME()` for identifiers and `sp_executesql`
> with parameters for values. **Never** concatenate user input directly into SQL!

### 11.4 Procedure with Cursor (Use Sparingly)

```sql
CREATE PROCEDURE dbo.usp_ApplyBulkDiscount
    @DiscountPct DECIMAL(5,2),
    @CategoryID  INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT, @ProductName NVARCHAR(100), @OldPrice DECIMAL(10,2);

    DECLARE product_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT ProductID, ProductName, Price
        FROM dbo.Products
        WHERE CategoryID = @CategoryID AND IsActive = 1;

    OPEN product_cursor;
    FETCH NEXT FROM product_cursor INTO @ProductID, @ProductName, @OldPrice;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @NewPrice DECIMAL(10,2) = ROUND(@OldPrice * (1 - @DiscountPct / 100), 2);

        UPDATE dbo.Products SET Price = @NewPrice WHERE ProductID = @ProductID;

        -- Log each change
        INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, OldValues, NewValues)
        VALUES (
            N'Products', N'UPDATE', @ProductID,
            CONCAT(N'Price: ', @OldPrice),
            CONCAT(N'Price: ', @NewPrice, N' (', @DiscountPct, N'% discount)')
        );

        PRINT CONCAT(N'Updated ', @ProductName, N': $', @OldPrice, N' → $', @NewPrice);

        FETCH NEXT FROM product_cursor INTO @ProductID, @ProductName, @OldPrice;
    END;

    CLOSE product_cursor;
    DEALLOCATE product_cursor;
END;
GO

EXEC dbo.usp_ApplyBulkDiscount @DiscountPct = 10, @CategoryID = 3;
```

> **Warning:** Cursors process rows one at a time and are **slow** compared to
> set-based operations. Use them only when row-by-row processing is truly
> necessary (e.g., calling another procedure for each row).

### 11.5 Set-Based Alternative (Preferred)

```sql
-- The same discount logic WITHOUT a cursor — much faster!
CREATE PROCEDURE dbo.usp_ApplyBulkDiscountSetBased
    @DiscountPct DECIMAL(5,2),
    @CategoryID  INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Log changes BEFORE updating
    INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, OldValues, NewValues)
    SELECT
        N'Products',
        N'UPDATE',
        ProductID,
        CONCAT(N'Price: ', Price),
        CONCAT(N'Price: ', ROUND(Price * (1 - @DiscountPct / 100), 2),
               N' (', @DiscountPct, N'% discount)')
    FROM dbo.Products
    WHERE CategoryID = @CategoryID AND IsActive = 1;

    -- Single UPDATE statement
    UPDATE dbo.Products
    SET Price = ROUND(Price * (1 - @DiscountPct / 100), 2)
    WHERE CategoryID = @CategoryID AND IsActive = 1;
END;
GO
```

---

## 12. Exception Handling with TRY-CATCH

### 12.1 Basic TRY-CATCH Syntax

```sql
BEGIN TRY
    -- Code that might cause an error
END TRY
BEGIN CATCH
    -- Code to handle the error
END CATCH;
```

### 12.2 Error Information Functions

| Function              | Returns                                       |
| --------------------- | --------------------------------------------- |
| `ERROR_NUMBER()`      | Error number                                  |
| `ERROR_MESSAGE()`     | Error message text                            |
| `ERROR_SEVERITY()`    | Severity level (0–25)                         |
| `ERROR_STATE()`       | Error state number                            |
| `ERROR_LINE()`        | Line number where the error occurred          |
| `ERROR_PROCEDURE()`   | Name of the procedure where the error occurred|

### 12.3 Simple TRY-CATCH Example

```sql
BEGIN TRY
    -- This will cause a divide-by-zero error
    SELECT 1 / 0 AS Result;
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER()    AS ErrorNumber,
        ERROR_MESSAGE()   AS ErrorMessage,
        ERROR_SEVERITY()  AS Severity,
        ERROR_STATE()     AS State,
        ERROR_LINE()      AS ErrorLine,
        ERROR_PROCEDURE() AS ErrorProcedure;
END CATCH;
```

**Output:**

| ErrorNumber | ErrorMessage                 | Severity | State | ErrorLine | ErrorProcedure |
| ----------- | ---------------------------- | -------- | ----- | --------- | -------------- |
| 8134        | Divide by zero error encountered | 16   | 1     | 3         | NULL           |

### 12.4 TRY-CATCH in a Stored Procedure

```sql
CREATE PROCEDURE dbo.usp_SafeInsertProduct
    @ProductName NVARCHAR(100),
    @CategoryID  INT,
    @Price       DECIMAL(10,2),
    @Stock       INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Products (ProductName, CategoryID, Price, Stock)
        VALUES (@ProductName, @CategoryID, @Price, @Stock);

        DECLARE @NewID INT = SCOPE_IDENTITY();

        INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, NewValues)
        VALUES (
            N'Products', N'INSERT', @NewID,
            CONCAT(N'Name: ', @ProductName, N', Price: ', @Price)
        );

        COMMIT TRANSACTION;
        PRINT CONCAT(N'Product inserted successfully. ID: ', @NewID);

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Log the error
        INSERT INTO dbo.AuditLog (TableName, Operation, NewValues)
        VALUES (
            N'Products', N'ERROR',
            CONCAT(
                N'Error ', ERROR_NUMBER(), N': ', ERROR_MESSAGE(),
                N' | Product: ', @ProductName
            )
        );

        -- Re-throw the original error
        THROW;
    END CATCH;
END;
GO

-- Test: valid insert
EXEC dbo.usp_SafeInsertProduct
    @ProductName = N'Smart Speaker',
    @CategoryID  = 1,
    @Price       = 79.99,
    @Stock       = 60;

-- Test: invalid insert (non-existent category)
EXEC dbo.usp_SafeInsertProduct
    @ProductName = N'Ghost Product',
    @CategoryID  = 999,
    @Price       = 10.00,
    @Stock       = 5;
```

### 12.5 THROW vs RAISERROR

| Feature           | `THROW`                          | `RAISERROR`                     |
| ----------------- | -------------------------------- | ------------------------------- |
| Introduced in     | SQL Server 2012                  | Older versions                  |
| Severity          | Always 16                        | Configurable (0–25)             |
| Terminates batch? | Yes (when used without params)   | Depends on severity             |
| Re-throw error?   | ✅ Yes (just `THROW;`)           | ❌ Must rebuild manually        |
| Custom messages?   | ✅ Yes                           | ✅ Yes (with msg_id or ad-hoc)  |
| Recommended?      | ✅ Yes (modern approach)         | Still supported                 |

```sql
-- THROW: custom error
THROW 50001, 'Custom error: Invalid operation.', 1;

-- THROW: re-throw in CATCH block (no parameters)
BEGIN TRY
    SELECT 1 / 0;
END TRY
BEGIN CATCH
    PRINT 'Error caught! Re-throwing...';
    THROW;  -- re-throws the original error
END CATCH;

-- RAISERROR: custom error with formatting
RAISERROR('Product %s not found (ID: %d).', 16, 1, 'Widget', 42);

-- RAISERROR: informational message (severity 0–10, doesn't trigger CATCH)
RAISERROR('This is just a warning.', 10, 1) WITH NOWAIT;
```

### 12.6 Nested TRY-CATCH

```sql
CREATE PROCEDURE dbo.usp_ProcessBatchOrders
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OrderID INT;
    DECLARE @ErrorCount INT = 0;

    DECLARE order_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT OrderID FROM dbo.Orders WHERE Status = N'Pending';

    OPEN order_cursor;
    FETCH NEXT FROM order_cursor INTO @OrderID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Process each order (could fail for individual orders)
            UPDATE dbo.Orders
            SET Status = N'Processing'
            WHERE OrderID = @OrderID;

            PRINT CONCAT(N'Order ', @OrderID, N' processed successfully.');
        END TRY
        BEGIN CATCH
            -- Log the error but continue processing other orders
            SET @ErrorCount = @ErrorCount + 1;

            INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, NewValues)
            VALUES (
                N'Orders', N'ERROR', @OrderID,
                CONCAT(N'Error processing: ', ERROR_MESSAGE())
            );

            PRINT CONCAT(N'Error processing order ', @OrderID, N': ', ERROR_MESSAGE());
        END CATCH;

        FETCH NEXT FROM order_cursor INTO @OrderID;
    END;

    CLOSE order_cursor;
    DEALLOCATE order_cursor;

    PRINT CONCAT(N'Batch complete. Errors: ', @ErrorCount);
END;
GO
```

### 12.7 Custom Error Messages

```sql
-- Add a custom error message to sys.messages
EXEC sp_addmessage
    @msgnum   = 50001,
    @severity = 16,
    @msgtext  = N'Product ID %d does not exist in category %d.',
    @lang     = 'us_english',
    @replace  = 'REPLACE';
GO

-- Use the custom message
RAISERROR(50001, 16, 1, 42, 7);
-- Output: Product ID 42 does not exist in category 7.
```

### 12.8 Complete Error Handling Pattern

Here's a battle-tested pattern you can use as a template:

```sql
CREATE PROCEDURE dbo.usp_TemplateWithErrorHandling
    @Param1 INT,
    @Param2 NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;  -- auto-rollback on any error

    -- Validate inputs
    IF @Param1 IS NULL OR @Param2 IS NULL
    BEGIN
        THROW 50001, 'Parameters cannot be NULL.', 1;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==================
        -- Business logic here
        -- ==================

        -- Step 1: ...
        -- Step 2: ...
        -- Step 3: ...

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback if a transaction is still open
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Capture error details
        DECLARE @ErrorMsg   NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorNum   INT            = ERROR_NUMBER();
        DECLARE @ErrorSev   INT            = ERROR_SEVERITY();
        DECLARE @ErrorState INT            = ERROR_STATE();
        DECLARE @ErrorLine  INT            = ERROR_LINE();
        DECLARE @ErrorProc  NVARCHAR(200)  = ERROR_PROCEDURE();

        -- Log the error
        INSERT INTO dbo.AuditLog (TableName, Operation, NewValues)
        VALUES (
            N'System', N'ERROR',
            CONCAT(
                N'Error ', @ErrorNum, N' (Severity ', @ErrorSev, N')',
                N' at line ', @ErrorLine,
                N' in ', ISNULL(@ErrorProc, N'ad-hoc'),
                N': ', @ErrorMsg
            )
        );

        -- Re-throw the original error
        THROW;
    END CATCH;
END;
GO
```

---

## 13. User-Defined Functions (Bonus)

### 13.1 Types of UDFs

| Type                     | Returns             | Used In                |
| ------------------------ | ------------------- | ---------------------- |
| **Scalar Function**      | Single value        | SELECT, WHERE, etc.    |
| **Inline Table-Valued**  | Table (single SELECT) | FROM clause          |
| **Multi-Statement TVF**  | Table (complex logic) | FROM clause          |

### 13.2 Scalar Function

```sql
CREATE FUNCTION dbo.fn_CalculateDiscount
(
    @Price       DECIMAL(10,2),
    @DiscountPct DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN ROUND(@Price * (1 - @DiscountPct / 100.0), 2);
END;
GO

-- Usage:
SELECT
    ProductName,
    Price,
    dbo.fn_CalculateDiscount(Price, 15) AS DiscountedPrice
FROM dbo.Products;
```

> **Performance warning:** Scalar UDFs can be slow because they execute
> row-by-row. In SQL Server 2019+, scalar UDF inlining may help.

### 13.3 Inline Table-Valued Function (iTVF)

```sql
-- Much faster than scalar UDFs — the optimizer can inline this
CREATE FUNCTION dbo.fn_GetProductsByPriceRange
(
    @MinPrice DECIMAL(10,2),
    @MaxPrice DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        p.Price,
        p.Stock
    FROM dbo.Products p
    JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
    WHERE p.Price BETWEEN @MinPrice AND @MaxPrice
      AND p.IsActive = 1
);
GO

-- Usage (in FROM clause like a table):
SELECT * FROM dbo.fn_GetProductsByPriceRange(20.00, 60.00);

-- Can be joined with other tables:
SELECT
    f.ProductName,
    f.Price,
    s.SupplierName
FROM dbo.fn_GetProductsByPriceRange(20.00, 60.00) f
LEFT JOIN dbo.ProductSuppliers ps ON f.ProductID = ps.ProductID
LEFT JOIN dbo.Suppliers s ON ps.SupplierID = s.SupplierID;
```

### 13.4 Functions vs Stored Procedures

| Feature              | Function                     | Stored Procedure             |
| -------------------- | ---------------------------- | ---------------------------- |
| Returns              | Value or table               | Result sets, output params   |
| Used in SELECT?      | ✅ Yes                       | ❌ No                        |
| Used in WHERE?       | ✅ Yes (scalar)              | ❌ No                        |
| DML allowed?         | ❌ No (read-only)            | ✅ Yes                       |
| TRY-CATCH?           | ❌ No                        | ✅ Yes                       |
| Transactions?        | ❌ No                        | ✅ Yes                       |
| Output parameters?   | ❌ No                        | ✅ Yes                       |

---

## 14. Triggers (Bonus)

### 14.1 What Is a Trigger?

A **trigger** is a special stored procedure that automatically executes when
a specific event occurs on a table (INSERT, UPDATE, or DELETE).

### 14.2 Trigger Types

| Type          | Fires                            |
| ------------- | -------------------------------- |
| `AFTER`       | After the DML statement executes |
| `INSTEAD OF`  | Instead of the DML statement     |

### 14.3 AFTER Trigger — Audit Example

```sql
CREATE TRIGGER trg_Products_Audit
ON dbo.Products
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle INSERTs
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, NewValues)
        SELECT
            N'Products', N'INSERT', i.ProductID,
            CONCAT(N'Name: ', i.ProductName, N', Price: ', i.Price)
        FROM inserted i;
    END;

    -- Handle UPDATEs
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, OldValues, NewValues)
        SELECT
            N'Products', N'UPDATE', i.ProductID,
            CONCAT(N'Name: ', d.ProductName, N', Price: ', d.Price),
            CONCAT(N'Name: ', i.ProductName, N', Price: ', i.Price)
        FROM inserted i
        JOIN deleted d ON i.ProductID = d.ProductID;
    END;

    -- Handle DELETEs
    IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, OldValues)
        SELECT
            N'Products', N'DELETE', d.ProductID,
            CONCAT(N'Name: ', d.ProductName, N', Price: ', d.Price)
        FROM deleted d;
    END;
END;
GO
```

### 14.4 The inserted and deleted Tables

| Operation | `inserted`        | `deleted`          |
| --------- | ----------------- | ------------------ |
| INSERT    | New rows          | Empty              |
| UPDATE    | New (after) values | Old (before) values |
| DELETE    | Empty             | Deleted rows       |

### 14.5 INSTEAD OF Trigger

```sql
-- Prevent direct deletes on Products — set IsActive = 0 instead (soft delete)
CREATE TRIGGER trg_Products_SoftDelete
ON dbo.Products
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.IsActive = 0
    FROM dbo.Products p
    JOIN deleted d ON p.ProductID = d.ProductID;

    INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, OldValues)
    SELECT
        N'Products', N'SOFT_DELETE', d.ProductID,
        CONCAT(N'Name: ', d.ProductName, N' — soft deleted')
    FROM deleted d;

    PRINT 'Product(s) soft-deleted (IsActive = 0).';
END;
GO

-- Now DELETE doesn't actually delete:
DELETE FROM dbo.Products WHERE ProductID = 18;
-- Result: Basketball is still in the table but IsActive = 0
```

### 14.6 Managing Triggers

```sql
-- Disable a trigger
DISABLE TRIGGER trg_Products_Audit ON dbo.Products;

-- Enable a trigger
ENABLE TRIGGER trg_Products_Audit ON dbo.Products;

-- Drop a trigger
DROP TRIGGER IF EXISTS trg_Products_SoftDelete;

-- List all triggers on a table
SELECT name, type_desc, is_disabled
FROM sys.triggers
WHERE parent_id = OBJECT_ID('dbo.Products');
```

> **Caution:** Triggers add hidden logic that can surprise developers. Use
> them sparingly and document them well. Prefer stored procedures for explicit
> business logic.

---

## 15. Day 4 Summary

### What We Covered

| Topic                  | Key Takeaway                                              |
| ---------------------- | --------------------------------------------------------- |
| Clustered Index        | Physical sort order of data; one per table                |
| Non-Clustered Index    | Separate lookup structure; many per table                 |
| Covering Index         | INCLUDE columns to avoid Key Lookups                      |
| Filtered Index         | Index a subset of rows (WHERE clause)                     |
| Index Maintenance      | REORGANIZE (5–30% frag) or REBUILD (>30%)                |
| Views                  | Virtual tables; simplify, secure, and reuse queries       |
| Indexed Views          | Materialized views with SCHEMABINDING + clustered index   |
| WITH CHECK OPTION      | Enforce view criteria on DML operations                   |
| Stored Procedures      | Reusable T-SQL programs with parameters                   |
| INPUT / OUTPUT params  | Pass data in and out of procedures                        |
| RETURN values          | Integer status codes for success/failure                  |
| TRY-CATCH              | Structured error handling                                 |
| THROW vs RAISERROR     | THROW is modern; RAISERROR for custom severity            |
| User-Defined Functions | Scalar (single value) and Table-Valued (iTVF preferred)   |
| Triggers               | Auto-fire on DML; use sparingly                           |

### Quick Reference: Creating Database Objects

```sql
-- Index
CREATE [UNIQUE] [CLUSTERED | NONCLUSTERED] INDEX IX_Name
ON dbo.Table (Col1 [, Col2])
[INCLUDE (Col3, Col4)]
[WHERE FilterCondition];

-- View
CREATE VIEW dbo.vw_Name [WITH SCHEMABINDING]
AS SELECT ... FROM ...
[WITH CHECK OPTION];

-- Stored Procedure
CREATE PROCEDURE dbo.usp_Name
    @Param1 DataType [= Default],
    @Param2 DataType OUTPUT
AS BEGIN SET NOCOUNT ON; ... END;

-- Function (Scalar)
CREATE FUNCTION dbo.fn_Name (@Param DataType)
RETURNS DataType AS BEGIN RETURN ...; END;

-- Function (Inline Table-Valued)
CREATE FUNCTION dbo.fn_Name (@Param DataType)
RETURNS TABLE AS RETURN (SELECT ...);

-- Trigger
CREATE TRIGGER trg_Name ON dbo.Table
AFTER INSERT, UPDATE, DELETE AS BEGIN ... END;
```

### The Database Objects Ecosystem

```
┌──────────────────────────────────────────────────────┐
│                     RetailDB                          │
│                                                      │
│  TABLES                VIEWS                          │
│  ├── Products          ├── vw_ActiveProducts          │
│  ├── Categories        ├── vw_CustomerOrderSummary    │
│  ├── Customers         ├── vw_OrderDetails            │
│  ├── Orders            └── vw_CategoryRevenue (indexed)│
│  ├── OrderItems                                       │
│  ├── Suppliers         STORED PROCEDURES              │
│  ├── ProductSuppliers  ├── usp_SearchProducts         │
│  ├── Employees         ├── usp_PlaceOrder             │
│  └── AuditLog          ├── usp_TransferStock          │
│                        └── usp_SafeInsertProduct      │
│  INDEXES                                              │
│  ├── PK_* (clustered)  FUNCTIONS                      │
│  ├── IX_* (non-clustered) ├── fn_CalculateDiscount    │
│  └── IX_*_Incl (covering) └── fn_GetProductsByRange   │
│                                                       │
│  TRIGGERS              AUDIT                          │
│  ├── trg_Products_Audit  └── AuditLog table           │
│  └── trg_Products_SoftDelete                          │
└──────────────────────────────────────────────────────┘
```

---

## 16. Hands-On Exercises

### Exercise 1: Indexes

1. Check what indexes currently exist on the `Products` table.
2. Create a non-clustered index on `Products.CategoryID` that includes `ProductName` and `Price`.
3. Create a filtered index on `Orders` for only `Pending` orders, indexing `CustomerID` and `OrderDate`.
4. Write a query that would benefit from each index you created and verify using `SET STATISTICS IO ON`.
5. Check the fragmentation level of all indexes on the `Products` table.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Check existing indexes
EXEC sp_helpindex 'dbo.Products';

-- Or with more detail:
SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    STRING_AGG(COL_NAME(ic.object_id, ic.column_id), ', ')
        WITHIN GROUP (ORDER BY ic.key_ordinal) AS Columns
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'Products' AND ic.is_included_column = 0
GROUP BY i.name, i.type_desc;

-- 2. Covering index on CategoryID
CREATE NONCLUSTERED INDEX IX_Products_CategoryID_Cover
ON dbo.Products (CategoryID)
INCLUDE (ProductName, Price);
GO

-- 3. Filtered index on pending orders
CREATE NONCLUSTERED INDEX IX_Orders_Pending_CustDate
ON dbo.Orders (CustomerID, OrderDate)
WHERE Status = N'Pending';
GO

-- 4. Queries that benefit
SET STATISTICS IO ON;

-- Uses the covering index (no Key Lookup needed):
SELECT ProductName, Price
FROM dbo.Products
WHERE CategoryID = 1;

-- Uses the filtered index:
SELECT CustomerID, OrderDate
FROM dbo.Orders
WHERE Status = N'Pending'
ORDER BY OrderDate;

SET STATISTICS IO OFF;

-- 5. Check fragmentation
SELECT
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent AS FragPct,
    ips.page_count AS Pages
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.Products'), NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id;
```

</details>

---

### Exercise 2: Views

1. Create a view `vw_ProductCatalog` that shows: ProductName, CategoryName, Price, Stock, InventoryValue (Price × Stock), and a StockStatus ('In Stock', 'Low Stock', 'Out of Stock').
2. Create a view `vw_MonthlyRevenue` that shows revenue per month per category (only non-cancelled orders).
3. Create a security view `vw_CustomerDirectory` that masks email addresses and hides exact join dates (show only the year).
4. Write `WITH CHECK OPTION` on a view of products under $50 and test that it prevents price updates above $50.
5. Query your views to answer: "Which category had the highest revenue in March 2025?"

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Product catalog view
CREATE VIEW dbo.vw_ProductCatalog
AS
    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        p.Price,
        p.Stock,
        p.Price * p.Stock AS InventoryValue,
        CASE
            WHEN p.Stock = 0   THEN 'Out of Stock'
            WHEN p.Stock < 50  THEN 'Low Stock'
            ELSE                    'In Stock'
        END AS StockStatus
    FROM dbo.Products p
    JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
    WHERE p.IsActive = 1;
GO

-- 2. Monthly revenue view
CREATE VIEW dbo.vw_MonthlyRevenue
AS
    SELECT
        YEAR(o.OrderDate)  AS OrderYear,
        MONTH(o.OrderDate) AS OrderMonth,
        DATENAME(MONTH, o.OrderDate) AS MonthName,
        c.CategoryName,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue,
        COUNT(DISTINCT o.OrderID)       AS OrderCount
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON o.OrderID    = oi.OrderID
    JOIN dbo.Products p    ON oi.ProductID = p.ProductID
    JOIN dbo.Categories c  ON p.CategoryID = c.CategoryID
    WHERE o.Status <> N'Cancelled'
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate), DATENAME(MONTH, o.OrderDate), c.CategoryName;
GO

-- 3. Security view
CREATE VIEW dbo.vw_CustomerDirectory
AS
    SELECT
        CustomerID,
        FirstName,
        LEFT(LastName, 1) + REPLICATE('*', LEN(LastName) - 1) AS LastName,
        LEFT(Email, 2) + '***@' +
            SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS Email,
        City,
        Country,
        YEAR(JoinDate) AS JoinYear
    FROM dbo.Customers;
GO

-- 4. View with CHECK OPTION
CREATE VIEW dbo.vw_BudgetProducts
AS
    SELECT ProductID, ProductName, Price, CategoryID
    FROM dbo.Products
    WHERE Price < 50
    WITH CHECK OPTION;
GO

-- Test: this should succeed
UPDATE dbo.vw_BudgetProducts SET Price = 28.99 WHERE ProductID = 2;

-- Test: this should FAIL
-- UPDATE dbo.vw_BudgetProducts SET Price = 99.99 WHERE ProductID = 2;

-- 5. Highest revenue category in March 2025
SELECT TOP 1 CategoryName, Revenue
FROM dbo.vw_MonthlyRevenue
WHERE OrderYear = 2025 AND OrderMonth = 3
ORDER BY Revenue DESC;
```

</details>

---

### Exercise 3: Stored Procedures

1. Create `usp_GetCustomerOrders` that accepts a CustomerID and returns all their orders with details (order info, products, totals).
2. Create `usp_UpdateProductPrice` that accepts ProductID, NewPrice, and updates the price. It should validate the product exists, validate price > 0, log the change to AuditLog, and use TRY-CATCH.
3. Create `usp_GetDashboard` that accepts a date range and returns three result sets: (a) total orders and revenue, (b) top 5 products by revenue, (c) top 5 customers by spending.
4. Create `usp_ArchiveDeliveredOrders` that moves all delivered orders older than 90 days into an archive table, using a transaction.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Customer orders
CREATE PROCEDURE dbo.usp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate customer exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerID = @CustomerID)
    BEGIN
        THROW 50001, 'Customer not found.', 1;
        RETURN;
    END;

    -- Customer info
    SELECT CustomerID, FirstName, LastName, Email, City, Country
    FROM dbo.Customers
    WHERE CustomerID = @CustomerID;

    -- Order details
    SELECT
        o.OrderID,
        o.OrderDate,
        o.Status,
        p.ProductName,
        oi.Quantity,
        oi.UnitPrice,
        oi.Quantity * oi.UnitPrice AS LineTotal
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON o.OrderID    = oi.OrderID
    JOIN dbo.Products p    ON oi.ProductID = p.ProductID
    WHERE o.CustomerID = @CustomerID
    ORDER BY o.OrderDate DESC, o.OrderID;

    -- Summary
    SELECT
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSpent
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
    WHERE o.CustomerID = @CustomerID
      AND o.Status <> N'Cancelled';
END;
GO

-- 2. Update product price
CREATE PROCEDURE dbo.usp_UpdateProductPrice
    @ProductID INT,
    @NewPrice  DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @NewPrice <= 0
    BEGIN
        THROW 50001, 'Price must be greater than zero.', 1;
        RETURN;
    END;

    DECLARE @OldPrice DECIMAL(10,2);
    SELECT @OldPrice = Price FROM dbo.Products WHERE ProductID = @ProductID;

    IF @OldPrice IS NULL
    BEGIN
        THROW 50001, 'Product not found.', 1;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.Products
        SET Price = @NewPrice
        WHERE ProductID = @ProductID;

        INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, OldValues, NewValues)
        VALUES (
            N'Products', N'UPDATE', @ProductID,
            CONCAT(N'Price: ', @OldPrice),
            CONCAT(N'Price: ', @NewPrice)
        );

        COMMIT TRANSACTION;
        PRINT CONCAT('Price updated: $', @OldPrice, ' → $', @NewPrice);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 3. Dashboard
CREATE PROCEDURE dbo.usp_GetDashboard
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Result set 1: Overall stats
    SELECT
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        SUM(oi.Quantity)          AS TotalItemsSold,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
    WHERE o.Status <> N'Cancelled'
      AND CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate;

    -- Result set 2: Top 5 products
    SELECT TOP 5
        p.ProductName,
        SUM(oi.Quantity) AS QtySold,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM dbo.OrderItems oi
    JOIN dbo.Products p ON oi.ProductID = p.ProductID
    JOIN dbo.Orders o   ON oi.OrderID   = o.OrderID
    WHERE o.Status <> N'Cancelled'
      AND CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
    GROUP BY p.ProductName
    ORDER BY Revenue DESC;

    -- Result set 3: Top 5 customers
    SELECT TOP 5
        c.FirstName + N' ' + c.LastName AS CustomerName,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSpent
    FROM dbo.Customers c
    JOIN dbo.Orders o      ON c.CustomerID = o.CustomerID
    JOIN dbo.OrderItems oi ON o.OrderID    = oi.OrderID
    WHERE o.Status <> N'Cancelled'
      AND CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
    GROUP BY c.FirstName, c.LastName
    ORDER BY TotalSpent DESC;
END;
GO

-- 4. Archive delivered orders
CREATE PROCEDURE dbo.usp_ArchiveDeliveredOrders
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -90, SYSDATETIME());

    -- Create archive tables if they don't exist
    IF OBJECT_ID('dbo.OrderArchive') IS NULL
    BEGIN
        SELECT * INTO dbo.OrderArchive
        FROM dbo.Orders WHERE 1 = 0;  -- empty copy with structure

        SELECT * INTO dbo.OrderItemArchive
        FROM dbo.OrderItems WHERE 1 = 0;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Archive order items first (child rows)
        INSERT INTO dbo.OrderItemArchive
        SELECT oi.*
        FROM dbo.OrderItems oi
        JOIN dbo.Orders o ON oi.OrderID = o.OrderID
        WHERE o.Status = N'Delivered' AND o.OrderDate < @CutoffDate;

        -- Archive orders
        INSERT INTO dbo.OrderArchive
        SELECT * FROM dbo.Orders
        WHERE Status = N'Delivered' AND OrderDate < @CutoffDate;

        -- Delete archived items
        DELETE oi
        FROM dbo.OrderItems oi
        JOIN dbo.Orders o ON oi.OrderID = o.OrderID
        WHERE o.Status = N'Delivered' AND o.OrderDate < @CutoffDate;

        -- Delete archived orders
        DELETE FROM dbo.Orders
        WHERE Status = N'Delivered' AND OrderDate < @CutoffDate;

        -- Log
        INSERT INTO dbo.AuditLog (TableName, Operation, NewValues)
        VALUES (N'Orders', N'ARCHIVE',
            CONCAT(N'Archived orders before ', FORMAT(@CutoffDate, 'yyyy-MM-dd')));

        COMMIT TRANSACTION;
        PRINT 'Archive completed successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
```

</details>

---

### Exercise 4: TRY-CATCH

1. Write a TRY-CATCH block that attempts to insert a product with an invalid CategoryID and catches the foreign key error. Display all error details.
2. Create a procedure `usp_SafeDivide` that accepts two numbers, divides them, and handles division by zero gracefully (return NULL and log the error).
3. Modify `usp_PlaceOrder` to handle the case where the customer doesn't exist (using TRY-CATCH and custom error messages).

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Catch FK violation
BEGIN TRY
    INSERT INTO dbo.Products (ProductName, CategoryID, Price, Stock)
    VALUES (N'Ghost Product', 999, 10.00, 5);
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER()    AS ErrNum,
        ERROR_MESSAGE()   AS ErrMsg,
        ERROR_SEVERITY()  AS Severity,
        ERROR_STATE()     AS State,
        ERROR_LINE()      AS Line,
        ERROR_PROCEDURE() AS Proc;

    PRINT 'Caught: ' + ERROR_MESSAGE();
END CATCH;

-- 2. Safe divide
CREATE PROCEDURE dbo.usp_SafeDivide
    @Numerator   DECIMAL(18,4),
    @Denominator DECIMAL(18,4),
    @Result      DECIMAL(18,4) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @Result = @Numerator / @Denominator;
    END TRY
    BEGIN CATCH
        SET @Result = NULL;

        INSERT INTO dbo.AuditLog (TableName, Operation, NewValues)
        VALUES (N'System', N'ERROR',
            CONCAT(N'Division error: ', @Numerator, N' / ', @Denominator,
                   N' — ', ERROR_MESSAGE()));

        PRINT 'Division by zero handled. Result is NULL.';
    END CATCH;
END;
GO

-- Test:
DECLARE @Res DECIMAL(18,4);
EXEC dbo.usp_SafeDivide 100, 3, @Res OUTPUT;
SELECT @Res AS Result;  -- 33.3333

EXEC dbo.usp_SafeDivide 100, 0, @Res OUTPUT;
SELECT @Res AS Result;  -- NULL

-- 3. Enhanced usp_PlaceOrder with customer check
ALTER PROCEDURE dbo.usp_PlaceOrder
    @CustomerID INT,
    @ProductID  INT,
    @Quantity   INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate customer
        IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerID = @CustomerID)
            THROW 50001, 'Customer does not exist.', 1;

        -- Validate product
        DECLARE @Stock INT, @Price DECIMAL(10,2);
        SELECT @Stock = Stock, @Price = Price
        FROM dbo.Products
        WHERE ProductID = @ProductID AND IsActive = 1;

        IF @Stock IS NULL
            THROW 50002, 'Product not found or inactive.', 1;

        IF @Stock < @Quantity
            THROW 50003, 'Insufficient stock.', 1;

        BEGIN TRANSACTION;

        DECLARE @OrderID INT;

        INSERT INTO dbo.Orders (CustomerID, OrderDate, Status)
        VALUES (@CustomerID, SYSDATETIME(), N'Pending');

        SET @OrderID = SCOPE_IDENTITY();

        INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice)
        VALUES (@OrderID, @ProductID, @Quantity, @Price);

        UPDATE dbo.Products SET Stock = Stock - @Quantity WHERE ProductID = @ProductID;

        COMMIT TRANSACTION;
        PRINT CONCAT('Order ', @OrderID, ' created successfully.');
        RETURN 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO dbo.AuditLog (TableName, Operation, NewValues)
        VALUES (N'Orders', N'ERROR', CONCAT(N'PlaceOrder failed: ', ERROR_MESSAGE()));

        THROW;
    END CATCH;
END;
GO
```

</details>

---

### Exercise 5: Putting It All Together

Build a complete "Product Management System" with the following components:

1. **Index:** Create an optimal index for searching products by name and filtering by price range.
2. **View:** `vw_ProductDashboard` showing each product with: name, category, price, stock, supplier (if any), times ordered, total revenue, and a demand rating.
3. **Procedure:** `usp_ManageProduct` that accepts an action parameter (`'ADD'`, `'UPDATE'`, `'DEACTIVATE'`) and relevant product fields. It should validate inputs, use transactions, handle errors, and log to AuditLog.
4. **Function:** `fn_GetProductRevenue` (inline TVF) that accepts a date range and returns each product's revenue within that range.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Index
CREATE NONCLUSTERED INDEX IX_Products_Name_Price
ON dbo.Products (ProductName)
INCLUDE (Price, CategoryID, Stock, IsActive)
WHERE IsActive = 1;
GO

-- 2. View
CREATE VIEW dbo.vw_ProductDashboard
AS
    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        p.Price,
        p.Stock,
        ISNULL(s.SupplierName, N'No Supplier') AS PrimarySupplier,
        ISNULL(os.TimesOrdered, 0)              AS TimesOrdered,
        ISNULL(os.TotalRevenue, 0)              AS TotalRevenue,
        CASE
            WHEN ISNULL(os.TimesOrdered, 0) = 0  THEN '☆ Never Ordered'
            WHEN os.TimesOrdered >= 5             THEN '★★★ High Demand'
            WHEN os.TimesOrdered >= 2             THEN '★★ Moderate'
            ELSE                                       '★ Low Demand'
        END AS DemandRating
    FROM dbo.Products p
    JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
    LEFT JOIN (
        SELECT ps.ProductID, s.SupplierName,
               ROW_NUMBER() OVER (PARTITION BY ps.ProductID ORDER BY ps.Cost) AS RN
        FROM dbo.ProductSuppliers ps
        JOIN dbo.Suppliers s ON ps.SupplierID = s.SupplierID
    ) s ON p.ProductID = s.ProductID AND s.RN = 1
    LEFT JOIN (
        SELECT oi.ProductID,
               SUM(oi.Quantity) AS TimesOrdered,
               SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
        FROM dbo.OrderItems oi
        JOIN dbo.Orders o ON oi.OrderID = o.OrderID
        WHERE o.Status <> N'Cancelled'
        GROUP BY oi.ProductID
    ) os ON p.ProductID = os.ProductID
    WHERE p.IsActive = 1;
GO

-- 3. Procedure
CREATE PROCEDURE dbo.usp_ManageProduct
    @Action      NVARCHAR(10),
    @ProductID   INT           = NULL,
    @ProductName NVARCHAR(100) = NULL,
    @CategoryID  INT           = NULL,
    @Price       DECIMAL(10,2) = NULL,
    @Stock       INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @Action = N'ADD'
        BEGIN
            IF @ProductName IS NULL OR @CategoryID IS NULL OR @Price IS NULL
                THROW 50001, 'ADD requires ProductName, CategoryID, and Price.', 1;

            BEGIN TRANSACTION;
            INSERT INTO dbo.Products (ProductName, CategoryID, Price, Stock)
            VALUES (@ProductName, @CategoryID, @Price, ISNULL(@Stock, 0));

            DECLARE @NewID INT = SCOPE_IDENTITY();

            INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, NewValues)
            VALUES (N'Products', N'INSERT', @NewID,
                CONCAT(N'Added: ', @ProductName, N', $', @Price));

            COMMIT TRANSACTION;
            PRINT CONCAT(N'Product added. ID: ', @NewID);
        END
        ELSE IF @Action = N'UPDATE'
        BEGIN
            IF @ProductID IS NULL
                THROW 50001, 'UPDATE requires ProductID.', 1;

            IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE ProductID = @ProductID)
                THROW 50001, 'Product not found.', 1;

            BEGIN TRANSACTION;
            UPDATE dbo.Products
            SET ProductName = ISNULL(@ProductName, ProductName),
                CategoryID  = ISNULL(@CategoryID, CategoryID),
                Price       = ISNULL(@Price, Price),
                Stock       = ISNULL(@Stock, Stock)
            WHERE ProductID = @ProductID;

            INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, NewValues)
            VALUES (N'Products', N'UPDATE', @ProductID,
                CONCAT(N'Updated fields for ProductID ', @ProductID));

            COMMIT TRANSACTION;
            PRINT N'Product updated.';
        END
        ELSE IF @Action = N'DEACTIVATE'
        BEGIN
            IF @ProductID IS NULL
                THROW 50001, 'DEACTIVATE requires ProductID.', 1;

            BEGIN TRANSACTION;
            UPDATE dbo.Products SET IsActive = 0 WHERE ProductID = @ProductID;

            INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, NewValues)
            VALUES (N'Products', N'DEACTIVATE', @ProductID, N'Product deactivated');

            COMMIT TRANSACTION;
            PRINT N'Product deactivated.';
        END
        ELSE
        BEGIN
            THROW 50001, 'Invalid action. Use ADD, UPDATE, or DEACTIVATE.', 1;
        END;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO dbo.AuditLog (TableName, Operation, NewValues)
        VALUES (N'Products', N'ERROR',
            CONCAT(N'ManageProduct failed (', @Action, N'): ', ERROR_MESSAGE()));

        THROW;
    END CATCH;
END;
GO

-- 4. Inline TVF
CREATE FUNCTION dbo.fn_GetProductRevenue
(
    @StartDate DATE,
    @EndDate   DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.ProductID,
        p.ProductName,
        SUM(oi.Quantity)              AS TotalQuantity,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
    FROM dbo.Products p
    JOIN dbo.OrderItems oi ON p.ProductID = oi.ProductID
    JOIN dbo.Orders o      ON oi.OrderID  = o.OrderID
    WHERE o.Status <> N'Cancelled'
      AND CAST(o.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
    GROUP BY p.ProductID, p.ProductName
);
GO

-- Test:
SELECT * FROM dbo.fn_GetProductRevenue('2025-01-01', '2025-03-31')
ORDER BY TotalRevenue DESC;
```

</details>

---

## 🎯 End of Day 4

**Tomorrow (Day 5)** we will explore:

- NoSQL databases: history, features, types
- Differences between RDBMS and NoSQL
- NoSQL demo (basic CRUD operations)
- Introduction to Azure SQL Database
- Creating and managing an Azure SQL Database
- Review, Q&A, and wrap-up

**Homework:**

1. Create at least 2 indexes, 2 views, and 2 stored procedures from scratch (without looking at solutions).
2. Write a stored procedure that uses TRY-CATCH, transactions, and the OUTPUT clause.
3. Review all your Day 1–3 queries and identify which ones could benefit from indexes.
4. Challenge: Create a trigger that prevents any single order from exceeding $10,000 in total value.

---

> **Tip:** Think of database objects as tools in a toolbox. Indexes speed up
> reads, views
