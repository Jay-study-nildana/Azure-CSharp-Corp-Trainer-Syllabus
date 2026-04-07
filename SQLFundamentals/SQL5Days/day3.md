# Day 3: Joins, Subqueries, and Data Retrieval

---

## Table of Contents

1. [Recap & Setup](#1-recap--setup)
2. [What Are Joins?](#2-what-are-joins)
3. [INNER JOIN](#3-inner-join)
4. [LEFT JOIN (LEFT OUTER JOIN)](#4-left-join-left-outer-join)
5. [RIGHT JOIN (RIGHT OUTER JOIN)](#5-right-join-right-outer-join)
6. [FULL OUTER JOIN](#6-full-outer-join)
7. [CROSS JOIN](#7-cross-join)
8. [Self Joins](#8-self-joins)
9. [Multi-Table Joins](#9-multi-table-joins)
10. [Subqueries — Introduction](#10-subqueries--introduction)
11. [Non-Correlated Subqueries](#11-non-correlated-subqueries)
12. [Correlated Subqueries](#12-correlated-subqueries)
13. [EXISTS and NOT EXISTS](#13-exists-and-not-exists)
14. [Common Table Expressions (CTEs)](#14-common-table-expressions-ctes)
15. [Derived Tables vs CTEs vs Subqueries](#15-derived-tables-vs-ctes-vs-subqueries)
16. [Complex Query Building — Practical Scenarios](#16-complex-query-building--practical-scenarios)
17. [Query Optimization Basics](#17-query-optimization-basics)
18. [Day 3 Summary](#18-day-3-summary)
19. [Hands-On Exercises](#19-hands-on-exercises)

---

## 1. Recap & Setup

### 1.1 Quick Recap of Day 2

| Concept            | Key Point                                              |
| ------------------ | ------------------------------------------------------ |
| Variables          | `DECLARE`, `SET`, `SELECT` assignment                  |
| Control Flow       | `IF…ELSE`, `WHILE`, `BEGIN…END`, `CASE`                |
| System Functions   | String, Date, Math, Conversion, NULL-handling          |
| Aggregates         | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`                    |
| GROUP BY / HAVING  | Group rows, filter groups                              |
| Advanced DML       | `OUTPUT`, `MERGE`, `SELECT INTO`                       |
| Set Operators      | `UNION`, `UNION ALL`, `INTERSECT`, `EXCEPT`            |

### 1.2 Database for Day 3

We will continue using the **RetailDB** database from Day 2. If you need to
recreate it, refer to the Day 2 setup script.

Let's also add a few more tables and data to make our join scenarios richer:

```sql
USE RetailDB;
GO

-- ============================================
-- Additional tables for Day 3
-- ============================================

-- Suppliers table (some products won't have a supplier)
CREATE TABLE dbo.Suppliers (
    SupplierID   INT           NOT NULL IDENTITY(1,1),
    SupplierName NVARCHAR(100) NOT NULL,
    ContactEmail NVARCHAR(100),
    City         NVARCHAR(50),
    Country      NVARCHAR(50)  NOT NULL,
    CONSTRAINT PK_Suppliers PRIMARY KEY (SupplierID)
);
GO

-- ProductSuppliers (junction table — many-to-many)
CREATE TABLE dbo.ProductSuppliers (
    ProductID   INT NOT NULL,
    SupplierID  INT NOT NULL,
    Cost        DECIMAL(10,2) NOT NULL,
    LeadDays    INT NOT NULL DEFAULT 7,
    CONSTRAINT PK_ProductSuppliers PRIMARY KEY (ProductID, SupplierID),
    CONSTRAINT FK_PS_Product FOREIGN KEY (ProductID)
        REFERENCES dbo.Products(ProductID),
    CONSTRAINT FK_PS_Supplier FOREIGN KEY (SupplierID)
        REFERENCES dbo.Suppliers(SupplierID)
);
GO

-- Employees table (with self-referencing ManagerID for self-join demo)
CREATE TABLE dbo.Employees (
    EmployeeID  INT           NOT NULL IDENTITY(1,1),
    FirstName   NVARCHAR(50)  NOT NULL,
    LastName    NVARCHAR(50)  NOT NULL,
    Title       NVARCHAR(50)  NOT NULL,
    ManagerID   INT           NULL,      -- NULL = top-level (CEO)
    HireDate    DATE          NOT NULL,
    Salary      DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_Employees PRIMARY KEY (EmployeeID),
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerID)
        REFERENCES dbo.Employees(EmployeeID)
);
GO

-- ============================================
-- Seed data
-- ============================================

-- Suppliers
INSERT INTO dbo.Suppliers (SupplierName, ContactEmail, City, Country)
VALUES
    (N'TechSource Inc.',     N'sales@techsource.com',    N'San Jose',    N'United States'),
    (N'GlobalParts Ltd.',    N'info@globalparts.co.uk',   N'London',      N'United Kingdom'),
    (N'MegaSupply Co.',      N'contact@megasupply.de',    N'Berlin',      N'Germany'),
    (N'Eastern Electronics', N'orders@easternelec.cn',    N'Shenzhen',    N'China'),
    (N'Pacific Goods',       N'hello@pacificgoods.au',    N'Sydney',      N'Australia');
-- Note: Supplier 5 (Pacific Goods) won't be linked to any products — useful for outer joins.

-- ProductSuppliers (not every product has a supplier)
INSERT INTO dbo.ProductSuppliers (ProductID, SupplierID, Cost, LeadDays)
VALUES
    (1,  1,  850.00,  14),   -- Laptop from TechSource
    (1,  4,  820.00,  21),   -- Laptop from Eastern Electronics
    (2,  1,   15.00,   7),   -- Wireless Mouse from TechSource
    (3,  1,   25.00,   7),   -- USB-C Hub from TechSource
    (4,  4,   45.00,  14),   -- Mechanical Keyboard from Eastern
    (5,  2,  130.00,  10),   -- Headphones from GlobalParts
    (6,  3,    8.00,   5),   -- Cotton T-Shirt from MegaSupply
    (7,  3,   25.00,   7),   -- Denim Jeans from MegaSupply
    (10, 2,   18.00,   7),   -- SQL in 24 Hours from GlobalParts
    (11, 2,   20.00,   7),   -- Clean Code from GlobalParts
    (13, 4,   40.00,  10),   -- Coffee Maker from Eastern
    (15, 4,   60.00,  10);   -- Air Fryer from Eastern
-- Note: Products 8, 9, 12, 14, 16, 17, 18 have NO supplier — useful for outer joins.

-- Employees (hierarchical — self-referencing)
INSERT INTO dbo.Employees (FirstName, LastName, Title, ManagerID, HireDate, Salary)
VALUES
    (N'Sarah',   N'Connor',  N'CEO',                 NULL, '2018-01-15', 150000.00),
    (N'James',   N'Kirk',    N'VP of Sales',         1,    '2019-03-01', 120000.00),
    (N'Nyota',   N'Uhura',   N'VP of Engineering',   1,    '2019-06-15', 125000.00),
    (N'Leonard', N'McCoy',   N'Sales Manager',       2,    '2020-02-01',  95000.00),
    (N'Hikaru',  N'Sulu',    N'Sales Representative',4,    '2021-05-10',  65000.00),
    (N'Pavel',   N'Chekov',  N'Sales Representative',4,    '2021-08-20',  62000.00),
    (N'Scotty',  N'Montgomery', N'Senior Engineer',  3,    '2020-04-01', 105000.00),
    (N'Spock',   N'Grayson', N'Engineer',            7,    '2021-09-15',  90000.00),
    (N'Christine', N'Chapel', N'Engineer',           7,    '2022-01-10',  85000.00),
    (N'Janice',  N'Rand',    N'Junior Engineer',     7,    '2023-06-01',  70000.00);
GO
```

### 1.3 Our Table Relationships

```
                              ┌──────────────┐
                              │  Categories  │
                              └──────┬───────┘
                                     │ 1
                                     │
                                     │ *
┌──────────────┐   *        1 ┌──────────────┐ *        * ┌──────────────┐
│  Suppliers   │──────────────│   Products   │────────────│  OrderItems  │
└──────────────┘              └──────────────┘            └──────┬───────┘
      (via ProductSuppliers)                                     │ *
                                                                 │
                                                                 │ 1
                                                          ┌──────────────┐
┌──────────────┐                                          │    Orders    │
│  Employees   │──┐ (self-ref: ManagerID)                 └──────┬───────┘
└──────────────┘  │                                              │ *
       ▲          │                                              │
       └──────────┘                                              │ 1
                                                          ┌──────────────┐
                                                          │  Customers   │
                                                          └──────────────┘
```

---

## 2. What Are Joins?

### 2.1 Definition

A **JOIN** combines rows from two or more tables based on a related column
(usually a primary key / foreign key relationship).

### 2.2 Why Do We Need Joins?

In a normalized database, data is split across multiple tables to avoid
redundancy. Joins let us **recombine** that data for meaningful queries.

**Without joins:** We'd need separate queries for each table and combine
results manually — slow, error-prone, and impractical.

### 2.3 Join Types Overview

| Join Type         | Returns                                                |
| ----------------- | ------------------------------------------------------ |
| `INNER JOIN`      | Only rows with matches in **both** tables              |
| `LEFT JOIN`       | All rows from left table + matches from right          |
| `RIGHT JOIN`      | All rows from right table + matches from left          |
| `FULL OUTER JOIN` | All rows from **both** tables (matches + non-matches)  |
| `CROSS JOIN`      | Every row from left × every row from right (Cartesian) |
| `Self Join`       | A table joined to **itself**                           |

### 2.4 Visual Overview (Venn Diagrams)

```
INNER JOIN:              LEFT JOIN:               RIGHT JOIN:
  ┌───┐   ┌───┐           ┌───┐   ┌───┐           ┌───┐   ┌───┐
  │ A │▓▓▓│ B │           │▓▓▓│▓▓▓│ B │           │ A │▓▓▓│▓▓▓│
  │   │▓▓▓│   │           │▓▓▓│▓▓▓│   │           │   │▓▓▓│▓▓▓│
  └───┘   └───┘           └───┘   └───┘           └───┘   └───┘
  Only overlap             All A + overlap          All B + overlap

FULL OUTER JOIN:         CROSS JOIN:
  ┌───┐   ┌───┐           ┌───┐ × ┌───┐
  │▓▓▓│▓▓▓│▓▓▓│           │ A │   │ B │  = A × B rows
  │▓▓▓│▓▓▓│▓▓▓│           │   │   │   │
  └───┘   └───┘           └───┘   └───┘
  Everything               Every combination
```

### 2.5 General JOIN Syntax

```sql
SELECT columns
FROM TableA
[INNER | LEFT | RIGHT | FULL OUTER | CROSS] JOIN TableB
    ON TableA.column = TableB.column
[WHERE conditions]
[ORDER BY columns];
```

---

## 3. INNER JOIN

### 3.1 How It Works

Returns **only** the rows where the join condition is satisfied in **both** tables.
If a row in Table A has no matching row in Table B, it is **excluded**.

```
Table A          Table B          INNER JOIN Result
┌────┬──────┐    ┌────┬──────┐    ┌────┬──────┬──────┐
│ ID │ Name │    │ ID │ Value│    │ ID │ Name │ Value│
├────┼──────┤    ├────┼──────┤    ├────┼──────┼──────┤
│ 1  │ AAA  │    │ 1  │ X    │    │ 1  │ AAA  │ X    │
│ 2  │ BBB  │    │ 3  │ Y    │    │ 3  │ CCC  │ Y    │
│ 3  │ CCC  │    │ 5  │ Z    │    └────┴──────┴──────┘
│ 4  │ DDD  │    └────┴──────┘    (IDs 2,4 from A excluded)
└────┴──────┘                     (ID 5 from B excluded)
```

### 3.2 Basic INNER JOIN

```sql
-- Products with their category names
SELECT
    p.ProductID,
    p.ProductName,
    p.Price,
    c.CategoryName
FROM dbo.Products p
INNER JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.ProductName;
```

| ProductID | ProductName             | Price   | CategoryName   |
| --------- | ----------------------- | ------- | -------------- |
| 10        | SQL in 24 Hours         | 34.99   | Books          |
| 11        | Clean Code              | 39.99   | Books          |
| 12        | Design Patterns         | 44.99   | Books          |
| 6         | Cotton T-Shirt          | 19.99   | Clothing       |
| 7         | Denim Jeans             | 59.99   | Clothing       |
| ...       | ...                     | ...     | ...            |

### 3.3 INNER JOIN with Multiple Conditions

```sql
-- Products with their supplier info, only where cost is less than $50
SELECT
    p.ProductName,
    s.SupplierName,
    ps.Cost,
    ps.LeadDays
FROM dbo.Products p
INNER JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
INNER JOIN dbo.Suppliers s         ON ps.SupplierID = s.SupplierID
WHERE ps.Cost < 50.00
ORDER BY ps.Cost;
```

### 3.4 INNER JOIN with Aggregation

```sql
-- Total revenue per customer (only customers who have orders)
SELECT
    c.FirstName + N' ' + c.LastName AS CustomerName,
    COUNT(DISTINCT o.OrderID)       AS TotalOrders,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM dbo.Customers c
INNER JOIN dbo.Orders o      ON c.CustomerID = o.CustomerID
INNER JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY c.FirstName, c.LastName
ORDER BY TotalRevenue DESC;
```

### 3.5 Table Aliases

Always use short, meaningful aliases:

```sql
-- ✅ Good aliases
SELECT p.ProductName, c.CategoryName
FROM dbo.Products p
JOIN dbo.Categories c ON p.CategoryID = c.CategoryID;

-- ❌ Avoid ambiguous or long aliases
SELECT x.ProductName, y.CategoryName
FROM dbo.Products x
JOIN dbo.Categories y ON x.CategoryID = y.CategoryID;
```

> **Note:** `JOIN` is shorthand for `INNER JOIN` — they are identical.

---

## 4. LEFT JOIN (LEFT OUTER JOIN)

### 4.1 How It Works

Returns **all rows from the left table** plus matching rows from the right table.
If there is no match, the right-side columns contain **NULL**.

```
Table A          Table B          LEFT JOIN Result
┌────┬──────┐    ┌────┬──────┐    ┌────┬──────┬──────┐
│ ID │ Name │    │ ID │ Value│    │ ID │ Name │ Value│
├────┼──────┤    ├────┼──────┤    ├────┼──────┼──────┤
│ 1  │ AAA  │    │ 1  │ X    │    │ 1  │ AAA  │ X    │
│ 2  │ BBB  │    │ 3  │ Y    │    │ 2  │ BBB  │ NULL │  ← no match
│ 3  │ CCC  │    │ 5  │ Z    │    │ 3  │ CCC  │ Y    │
│ 4  │ DDD  │    └────┴──────┘    │ 4  │ DDD  │ NULL │  ← no match
└────┴──────┘                     └────┴──────┴──────┘
```

### 4.2 Basic LEFT JOIN

```sql
-- ALL products with their suppliers (including products without suppliers)
SELECT
    p.ProductID,
    p.ProductName,
    s.SupplierName,
    ps.Cost
FROM dbo.Products p
LEFT JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
LEFT JOIN dbo.Suppliers s         ON ps.SupplierID = s.SupplierID
ORDER BY p.ProductName;
```

| ProductID | ProductName             | SupplierName          | Cost    |
| --------- | ----------------------- | --------------------- | ------- |
| 15        | Air Fryer               | Eastern Electronics   | 60.00   |
| 18        | Basketball              | NULL                  | NULL    |
| 14        | Blender Pro             | NULL                  | NULL    |
| 11        | Clean Code              | GlobalParts Ltd.      | 20.00   |
| 13        | Coffee Maker            | Eastern Electronics   | 40.00   |
| 6         | Cotton T-Shirt          | MegaSupply Co.        | 8.00    |
| ...       | ...                     | ...                   | ...     |

> Notice: Basketball, Blender Pro, and other products **without** suppliers
> still appear with NULL in the supplier columns.

### 4.3 Finding Rows with No Match (Anti-Join Pattern)

One of the most powerful uses of LEFT JOIN: find rows in the left table
that have **no** corresponding row in the right table.

```sql
-- Products that have NO supplier
SELECT
    p.ProductID,
    p.ProductName
FROM dbo.Products p
LEFT JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
WHERE ps.ProductID IS NULL
ORDER BY p.ProductName;
```

| ProductID | ProductName        |
| --------- | ------------------ |
| 18        | Basketball         |
| 14        | Blender Pro        |
| 12        | Design Patterns    |
| 17        | Dumbbell Set       |
| 9         | Running Shoes      |
| 8         | Winter Jacket      |
| 16        | Yoga Mat           |

```sql
-- Customers who have NEVER placed an order
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email
FROM dbo.Customers c
LEFT JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;
```

### 4.4 LEFT JOIN with Aggregation

```sql
-- All customers with their order count (including those with 0 orders)
SELECT
    c.FirstName + N' ' + c.LastName AS CustomerName,
    COUNT(o.OrderID) AS OrderCount
FROM dbo.Customers c
LEFT JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.FirstName, c.LastName
ORDER BY OrderCount DESC;
```

> **Tip:** Use `COUNT(o.OrderID)` instead of `COUNT(*)`. The former counts
> only non-NULL matches (actual orders), while `COUNT(*)` would count 1 for
> every customer even if they have no orders.

### 4.5 LEFT JOIN — Common Mistake

```sql
-- ❌ WRONG: putting the right-table filter in WHERE negates the LEFT JOIN
SELECT p.ProductName, s.SupplierName
FROM dbo.Products p
LEFT JOIN dbo.Suppliers s
    ON p.ProductID = s.SupplierID  -- wrong column aside...
WHERE s.Country = N'United States';  -- This turns it into an INNER JOIN!

-- ✅ CORRECT: put the right-table filter in the ON clause
SELECT p.ProductName, s.SupplierName
FROM dbo.Products p
LEFT JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
LEFT JOIN dbo.Suppliers s ON ps.SupplierID = s.SupplierID
    AND s.Country = N'United States'   -- filter in ON preserves the LEFT JOIN
ORDER BY p.ProductName;
```

> **Rule of thumb:** When using an OUTER JOIN, filters on the **outer**
> (optional) table go in the `ON` clause, not the `WHERE` clause.

---

## 5. RIGHT JOIN (RIGHT OUTER JOIN)

### 5.1 How It Works

Returns **all rows from the right table** plus matching rows from the left table.
If there is no match, the left-side columns contain **NULL**.

```
Table A          Table B          RIGHT JOIN Result
┌────┬──────┐    ┌────┬──────┐    ┌────┬──────┬──────┐
│ ID │ Name │    │ ID │ Value│    │ ID │ Name │ Value│
├────┼──────┤    ├────┼──────┤    ├────┼──────┼──────┤
│ 1  │ AAA  │    │ 1  │ X    │    │ 1  │ AAA  │ X    │
│ 2  │ BBB  │    │ 3  │ Y    │    │ 3  │ CCC  │ Y    │
│ 3  │ CCC  │    │ 5  │ Z    │    │NULL│ NULL │ Z    │ ← no match
│ 4  │ DDD  │    └────┴──────┘    └────┴──────┴──────┘
└────┴──────┘
```

### 5.2 Basic RIGHT JOIN

```sql
-- ALL suppliers with their products (including suppliers with no products)
SELECT
    s.SupplierName,
    s.Country,
    p.ProductName,
    ps.Cost
FROM dbo.Products p
RIGHT JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
RIGHT JOIN dbo.Suppliers s         ON ps.SupplierID = s.SupplierID
ORDER BY s.SupplierName;
```

| SupplierName          | Country        | ProductName             | Cost    |
| --------------------- | -------------- | ----------------------- | ------- |
| Eastern Electronics   | China          | Mechanical Keyboard     | 45.00   |
| Eastern Electronics   | China          | Coffee Maker            | 40.00   |
| Eastern Electronics   | China          | Air Fryer               | 60.00   |
| Eastern Electronics   | China          | Laptop Pro 15           | 820.00  |
| GlobalParts Ltd.      | United Kingdom | Noise-Cancel Headphones | 130.00  |
| GlobalParts Ltd.      | United Kingdom | SQL in 24 Hours         | 18.00   |
| GlobalParts Ltd.      | United Kingdom | Clean Code              | 20.00   |
| MegaSupply Co.        | Germany        | Cotton T-Shirt          | 8.00    |
| MegaSupply Co.        | Germany        | Denim Jeans             | 25.00   |
| Pacific Goods         | Australia      | NULL                    | NULL    |
| TechSource Inc.       | United States  | Laptop Pro 15           | 850.00  |
| TechSource Inc.       | United States  | Wireless Mouse          | 15.00   |
| TechSource Inc.       | United States  | USB-C Hub               | 25.00   |

> Notice: **Pacific Goods** has no products linked but still appears.

### 5.3 RIGHT JOIN vs LEFT JOIN

A `RIGHT JOIN` can always be rewritten as a `LEFT JOIN` by swapping the table order:

```sql
-- These two queries produce IDENTICAL results:

-- RIGHT JOIN version
SELECT s.SupplierName, p.ProductName
FROM dbo.Products p
RIGHT JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
RIGHT JOIN dbo.Suppliers s         ON ps.SupplierID = s.SupplierID;

-- Equivalent LEFT JOIN version (tables swapped)
SELECT s.SupplierName, p.ProductName
FROM dbo.Suppliers s
LEFT JOIN dbo.ProductSuppliers ps ON s.SupplierID = ps.SupplierID
LEFT JOIN dbo.Products p          ON ps.ProductID = p.ProductID;
```

> **Best practice:** Most SQL developers prefer `LEFT JOIN` consistently and
> avoid `RIGHT JOIN` for readability. The table you want "all rows from" should
> be on the left.

---

## 6. FULL OUTER JOIN

### 6.1 How It Works

Returns **all rows from both tables**. Where there is a match, columns from both
tables are populated. Where there is no match, the missing side has NULLs.

```
Table A          Table B          FULL OUTER JOIN Result
┌────┬──────┐    ┌────┬──────┐    ┌────┬──────┬──────┐
│ ID │ Name │    │ ID │ Value│    │ ID │ Name │ Value│
├────┼──────┤    ├────┼──────┤    ├────┼──────┼──────┤
│ 1  │ AAA  │    │ 1  │ X    │    │ 1  │ AAA  │ X    │  ← match
│ 2  │ BBB  │    │ 3  │ Y    │    │ 2  │ BBB  │ NULL │  ← A only
│ 3  │ CCC  │    │ 5  │ Z    │    │ 3  │ CCC  │ Y    │  ← match
│ 4  │ DDD  │    └────┴──────┘    │ 4  │ DDD  │ NULL │  ← A only
└────┴──────┘                     │NULL│ NULL │ Z    │  ← B only
                                  └────┴──────┴──────┘
```

### 6.2 Basic FULL OUTER JOIN

```sql
-- All products and all suppliers — matched where possible
SELECT
    p.ProductName,
    s.SupplierName,
    ps.Cost
FROM dbo.Products p
FULL OUTER JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
FULL OUTER JOIN dbo.Suppliers s         ON ps.SupplierID = s.SupplierID
ORDER BY p.ProductName, s.SupplierName;
```

### 6.3 Finding Unmatched Rows on Both Sides

```sql
-- Products without suppliers AND suppliers without products
SELECT
    p.ProductName,
    s.SupplierName,
    CASE
        WHEN p.ProductID IS NULL THEN 'Supplier has no products'
        WHEN s.SupplierID IS NULL THEN 'Product has no supplier'
    END AS Issue
FROM dbo.Products p
FULL OUTER JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
FULL OUTER JOIN dbo.Suppliers s         ON ps.SupplierID = s.SupplierID
WHERE p.ProductID IS NULL OR s.SupplierID IS NULL
ORDER BY Issue, p.ProductName, s.SupplierName;
```

### 6.4 Practical Use Case: Data Reconciliation

```sql
-- Compare two datasets: current orders vs. an external report
-- (Simulated with two subqueries)
SELECT
    COALESCE(a.OrderID, b.OrderID) AS OrderID,
    a.TotalAmount AS OurTotal,
    b.TotalAmount AS ReportTotal,
    CASE
        WHEN a.OrderID IS NULL       THEN 'Missing from our system'
        WHEN b.OrderID IS NULL       THEN 'Missing from report'
        WHEN a.TotalAmount <> b.TotalAmount THEN 'Amount mismatch'
        ELSE 'OK'
    END AS Status
FROM (
    -- Our calculated totals
    SELECT o.OrderID, SUM(oi.Quantity * oi.UnitPrice) AS TotalAmount
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
    GROUP BY o.OrderID
) a
FULL OUTER JOIN (
    -- Simulated external report (some entries differ or are missing)
    SELECT OrderID, TotalAmount FROM dbo.OrderSummary
) b ON a.OrderID = b.OrderID
ORDER BY OrderID;
```

---

## 7. CROSS JOIN

### 7.1 How It Works

Returns the **Cartesian product** — every row from the left table combined with
every row from the right table. No `ON` clause is needed (or allowed).

```
Table A (3 rows)    Table B (2 rows)    CROSS JOIN (3 × 2 = 6 rows)
┌──────┐            ┌──────┐            ┌──────┬──────┐
│  A1  │            │  B1  │            │  A1  │  B1  │
│  A2  │            │  B2  │            │  A1  │  B2  │
│  A3  │            └──────┘            │  A2  │  B1  │
└──────┘                                │  A2  │  B2  │
                                        │  A3  │  B1  │
                                        │  A3  │  B2  │
                                        └──────┴──────┘
```

### 7.2 Basic CROSS JOIN

```sql
-- Every product paired with every category
SELECT
    p.ProductName,
    c.CategoryName
FROM dbo.Products p
CROSS JOIN dbo.Categories c
ORDER BY p.ProductName, c.CategoryName;
-- Result: 18 products × 5 categories = 90 rows
```

> **Warning:** CROSS JOINs can produce very large result sets!
> 1,000 rows × 1,000 rows = 1,000,000 rows.

### 7.3 Practical Use Cases

#### Generate a Calendar

```sql
-- Generate all dates in March 2025
DECLARE @StartDate DATE = '2025-03-01';
DECLARE @EndDate   DATE = '2025-03-31';

;WITH Numbers AS (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS N
    FROM sys.objects a CROSS JOIN sys.objects b
)
SELECT
    DATEADD(DAY, N, @StartDate) AS CalendarDate,
    DATENAME(WEEKDAY, DATEADD(DAY, N, @StartDate)) AS DayName
FROM Numbers
ORDER BY CalendarDate;
```

#### Size Matrix for Products

```sql
-- Generate a size × color matrix for a clothing product
DECLARE @Sizes TABLE (SizeName NVARCHAR(5));
DECLARE @Colors TABLE (ColorName NVARCHAR(20));

INSERT INTO @Sizes  VALUES ('XS'), ('S'), ('M'), ('L'), ('XL');
INSERT INTO @Colors VALUES ('Red'), ('Blue'), ('Black'), ('White');

SELECT
    s.SizeName,
    c.ColorName,
    CONCAT(s.SizeName, '-', c.ColorName) AS SKU
FROM @Sizes s
CROSS JOIN @Colors c
ORDER BY s.SizeName, c.ColorName;
```

| SizeName | ColorName | SKU       |
| -------- | --------- | --------- |
| L        | Black     | L-Black   |
| L        | Blue      | L-Blue    |
| L        | Red       | L-Red     |
| L        | White     | L-White   |
| M        | Black     | M-Black   |
| ...      | ...       | ...       |

Result: 5 sizes × 4 colors = 20 SKU combinations.

---

## 8. Self Joins

### 8.1 What Is a Self Join?

A table joined to **itself**. This is useful when a table contains a
self-referencing relationship (e.g., employees and their managers).

### 8.2 Employee-Manager Hierarchy

```sql
-- Show each employee with their manager's name
SELECT
    e.EmployeeID,
    e.FirstName + N' ' + e.LastName AS Employee,
    e.Title,
    m.FirstName + N' ' + m.LastName AS Manager,
    m.Title AS ManagerTitle
FROM dbo.Employees e
LEFT JOIN dbo.Employees m ON e.ManagerID = m.EmployeeID
ORDER BY e.EmployeeID;
```

| EmployeeID | Employee           | Title                | Manager           | ManagerTitle       |
| ---------- | ------------------ | -------------------- | ----------------- | ------------------ |
| 1          | Sarah Connor       | CEO                  | NULL              | NULL               |
| 2          | James Kirk         | VP of Sales          | Sarah Connor      | CEO                |
| 3          | Nyota Uhura        | VP of Engineering    | Sarah Connor      | CEO                |
| 4          | Leonard McCoy      | Sales Manager        | James Kirk        | VP of Sales        |
| 5          | Hikaru Sulu        | Sales Representative | Leonard McCoy     | Sales Manager      |
| 6          | Pavel Chekov       | Sales Representative | Leonard McCoy     | Sales Manager      |
| 7          | Scotty Montgomery  | Senior Engineer      | Nyota Uhura       | VP of Engineering  |
| 8          | Spock Grayson      | Engineer             | Scotty Montgomery | Senior Engineer    |
| 9          | Christine Chapel   | Engineer             | Scotty Montgomery | Senior Engineer    |
| 10         | Janice Rand        | Junior Engineer      | Scotty Montgomery | Senior Engineer    |

### 8.3 Finding Employees Who Earn More Than Their Manager

```sql
SELECT
    e.FirstName + N' ' + e.LastName AS Employee,
    e.Salary   AS EmployeeSalary,
    m.FirstName + N' ' + m.LastName AS Manager,
    m.Salary   AS ManagerSalary,
    e.Salary - m.Salary AS Difference
FROM dbo.Employees e
JOIN dbo.Employees m ON e.ManagerID = m.EmployeeID
WHERE e.Salary > m.Salary;
```

### 8.4 Org Chart Visualization

```sql
-- Show the hierarchy with indentation
;WITH OrgChart AS (
    -- Anchor: CEO (no manager)
    SELECT
        EmployeeID,
        FirstName + N' ' + LastName AS FullName,
        Title,
        ManagerID,
        0 AS Level,
        CAST(FirstName + N' ' + LastName AS NVARCHAR(500)) AS Hierarchy
    FROM dbo.Employees
    WHERE ManagerID IS NULL

    UNION ALL

    -- Recursive: each employee under their manager
    SELECT
        e.EmployeeID,
        e.FirstName + N' ' + e.LastName,
        e.Title,
        e.ManagerID,
        oc.Level + 1,
        CAST(REPLICATE(N'    ', oc.Level + 1) + e.FirstName + N' ' + e.LastName
             AS NVARCHAR(500))
    FROM dbo.Employees e
    JOIN OrgChart oc ON e.ManagerID = oc.EmployeeID
)
SELECT
    Hierarchy AS OrgChart,
    Title,
    Level
FROM OrgChart
ORDER BY Level, FullName;
```

**Output:**

```
OrgChart                    Title                Level
Sarah Connor                CEO                  0
    James Kirk              VP of Sales          1
    Nyota Uhura             VP of Engineering    1
        Leonard McCoy       Sales Manager        2
        Scotty Montgomery   Senior Engineer      2
            Christine Chapel Engineer            3
            Hikaru Sulu     Sales Representative 3
            Janice Rand     Junior Engineer      3
            Pavel Chekov    Sales Representative 3
            Spock Grayson   Engineer             3
```

---

## 9. Multi-Table Joins

### 9.1 Joining 3+ Tables

Most real-world queries involve more than two tables.

```sql
-- Complete order details: customer, order, items, products, categories
SELECT
    c.FirstName + N' ' + c.LastName AS Customer,
    o.OrderID,
    o.OrderDate,
    o.Status,
    p.ProductName,
    cat.CategoryName,
    oi.Quantity,
    oi.UnitPrice,
    oi.Quantity * oi.UnitPrice AS LineTotal
FROM dbo.Customers c
JOIN dbo.Orders o        ON c.CustomerID = o.CustomerID
JOIN dbo.OrderItems oi   ON o.OrderID    = oi.OrderID
JOIN dbo.Products p      ON oi.ProductID = p.ProductID
JOIN dbo.Categories cat  ON p.CategoryID = cat.CategoryID
ORDER BY o.OrderDate DESC, o.OrderID, oi.OrderItemID;
```

### 9.2 Mixing Join Types

```sql
-- All customers, their orders (if any), and product details (if any)
-- Including customers with no orders
SELECT
    c.FirstName + N' ' + c.LastName AS Customer,
    o.OrderID,
    o.Status,
    p.ProductName,
    oi.Quantity,
    oi.UnitPrice
FROM dbo.Customers c
LEFT JOIN dbo.Orders o       ON c.CustomerID = o.CustomerID
LEFT JOIN dbo.OrderItems oi  ON o.OrderID    = oi.OrderID
LEFT JOIN dbo.Products p     ON oi.ProductID = p.ProductID
ORDER BY c.LastName, o.OrderID;
```

### 9.3 Join Strategy: Build Step by Step

When building complex multi-table queries, follow this approach:

```
Step 1: Start with your "anchor" table (the one you need ALL rows from).
Step 2: JOIN the next most important table.
Step 3: Verify the results are correct at each step before adding more joins.
Step 4: Add aggregation and filtering last.
```

```sql
-- Step 1: Start with Products
SELECT p.ProductName, p.Price
FROM dbo.Products p;

-- Step 2: Add Category
SELECT p.ProductName, p.Price, c.CategoryName
FROM dbo.Products p
JOIN dbo.Categories c ON p.CategoryID = c.CategoryID;

-- Step 3: Add Supplier (LEFT JOIN — not all products have suppliers)
SELECT p.ProductName, p.Price, c.CategoryName, s.SupplierName, ps.Cost
FROM dbo.Products p
JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
LEFT JOIN dbo.Suppliers s ON ps.SupplierID = s.SupplierID;

-- Step 4: Add profit margin calculation and filter
SELECT
    p.ProductName,
    c.CategoryName,
    p.Price,
    s.SupplierName,
    ps.Cost,
    ROUND(p.Price - ISNULL(ps.Cost, 0), 2) AS Margin,
    ROUND((p.Price - ISNULL(ps.Cost, 0)) / p.Price * 100, 1) AS MarginPct
FROM dbo.Products p
JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
LEFT JOIN dbo.Suppliers s ON ps.SupplierID = s.SupplierID
WHERE p.IsActive = 1
ORDER BY MarginPct DESC;
```

---

## 10. Subqueries — Introduction

### 10.1 What Is a Subquery?

A **subquery** is a SELECT statement nested inside another SQL statement.
It can appear in:

- The `WHERE` clause
- The `FROM` clause (called a **derived table**)
- The `SELECT` clause (called a **scalar subquery**)
- The `HAVING` clause

### 10.2 Subquery Types

| Type                    | Returns              | Correlation with outer query? |
| ----------------------- | -------------------- | ----------------------------- |
| **Scalar**              | Single value         | Optional                      |
| **Multi-value (list)**  | One column, many rows| Optional                      |
| **Table (derived)**     | Full result set      | No (independent)              |
| **Correlated**          | Depends on outer row | Yes — runs once per outer row |

---

## 11. Non-Correlated Subqueries

A non-correlated subquery runs **independently** of the outer query. It
executes **once** and its result is used by the outer query.

### 11.1 Scalar Subquery in WHERE

```sql
-- Find products priced above the average
SELECT ProductName, Price
FROM dbo.Products
WHERE Price > (SELECT AVG(Price) FROM dbo.Products)
ORDER BY Price DESC;
```

**How it works:**
1. Inner query runs first: `SELECT AVG(Price) FROM dbo.Products` → e.g., `163.87`
2. Outer query uses that value: `WHERE Price > 163.87`

### 11.2 Multi-Value Subquery with IN

```sql
-- Products that have been ordered at least once
SELECT ProductName, Price
FROM dbo.Products
WHERE ProductID IN (SELECT DISTINCT ProductID FROM dbo.OrderItems)
ORDER BY ProductName;
```

### 11.3 Multi-Value Subquery with NOT IN

```sql
-- Products that have NEVER been ordered
SELECT ProductName, Price
FROM dbo.Products
WHERE ProductID NOT IN (
    SELECT DISTINCT ProductID FROM dbo.OrderItems
)
ORDER BY ProductName;
```

> **Warning:** If the subquery returns any NULL, `NOT IN` will return no rows!
> Always add `WHERE column IS NOT NULL` in the subquery, or use `NOT EXISTS`.

```sql
-- ❌ Dangerous if ProductID can be NULL in OrderItems:
WHERE ProductID NOT IN (SELECT ProductID FROM dbo.OrderItems)

-- ✅ Safe:
WHERE ProductID NOT IN (SELECT ProductID FROM dbo.OrderItems WHERE ProductID IS NOT NULL)
```

### 11.4 Subquery with ALL / ANY / SOME

```sql
-- Products more expensive than ALL products in the Books category
SELECT ProductName, Price
FROM dbo.Products
WHERE Price > ALL (
    SELECT Price FROM dbo.Products WHERE CategoryID = 3
)
ORDER BY Price;

-- Products more expensive than ANY (at least one) product in Electronics
SELECT ProductName, Price
FROM dbo.Products
WHERE Price > ANY (
    SELECT Price FROM dbo.Products WHERE CategoryID = 1
)
ORDER BY Price;
```

| Operator | Meaning                                  |
| -------- | ---------------------------------------- |
| `> ALL`  | Greater than the **maximum** of the list |
| `< ALL`  | Less than the **minimum** of the list    |
| `> ANY`  | Greater than the **minimum** of the list |
| `< ANY`  | Less than the **maximum** of the list    |
| `= ANY`  | Same as `IN`                             |

### 11.5 Derived Tables (Subquery in FROM)

A derived table is a subquery used as a temporary table in the `FROM` clause.

```sql
-- Average order value by customer, then find customers above the overall average
SELECT
    CustomerName,
    AvgOrderValue
FROM (
    -- Derived table: calculate each customer's average order value
    SELECT
        c.FirstName + N' ' + c.LastName AS CustomerName,
        AVG(oi.Quantity * oi.UnitPrice) AS AvgOrderValue
    FROM dbo.Customers c
    JOIN dbo.Orders o      ON c.CustomerID = o.CustomerID
    JOIN dbo.OrderItems oi ON o.OrderID    = oi.OrderID
    GROUP BY c.FirstName, c.LastName
) AS CustomerAvg
WHERE AvgOrderValue > (
    SELECT AVG(Quantity * UnitPrice) FROM dbo.OrderItems
)
ORDER BY AvgOrderValue DESC;
```

### 11.6 Scalar Subquery in SELECT

```sql
-- Show each product with the category average for comparison
SELECT
    p.ProductName,
    p.Price,
    (SELECT AVG(Price) FROM dbo.Products p2
     WHERE p2.CategoryID = p.CategoryID) AS CategoryAvgPrice,
    p.Price - (SELECT AVG(Price) FROM dbo.Products p2
               WHERE p2.CategoryID = p.CategoryID) AS DiffFromAvg
FROM dbo.Products p
ORDER BY DiffFromAvg DESC;
```

> **Note:** This last example is actually a **correlated** subquery (it references
> `p.CategoryID` from the outer query). We'll formalize this concept next.

---

## 12. Correlated Subqueries

### 12.1 How They Work

A correlated subquery **references a column from the outer query**. It executes
**once for each row** in the outer query.

```
For each row in outer query:
    → Execute inner query using the current outer row's values
    → Return result to outer query
    → Move to next outer row
```

### 12.2 Basic Correlated Subquery

```sql
-- Products that are priced above the average for their own category
SELECT
    p.ProductName,
    p.Price,
    p.CategoryID
FROM dbo.Products p
WHERE p.Price > (
    SELECT AVG(p2.Price)
    FROM dbo.Products p2
    WHERE p2.CategoryID = p.CategoryID  -- correlation: references outer p
)
ORDER BY p.CategoryID, p.Price DESC;
```

**How it works:**

1. Take the first product (e.g., Laptop Pro 15, CategoryID = 1).
2. Run inner query: `AVG(Price) WHERE CategoryID = 1` → 343.99.
3. Is 1299.99 > 343.99? → Yes, include this row.
4. Move to next product, repeat.

### 12.3 Correlated Subquery with Aggregation

```sql
-- For each customer, show their most recent order
SELECT
    c.FirstName + N' ' + c.LastName AS Customer,
    o.OrderID,
    o.OrderDate,
    o.Status
FROM dbo.Orders o
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderDate = (
    SELECT MAX(o2.OrderDate)
    FROM dbo.Orders o2
    WHERE o2.CustomerID = o.CustomerID  -- correlation
);
```

### 12.4 Correlated Subquery in UPDATE

```sql
-- Update each product's stock based on how many have been ordered
UPDATE dbo.Products
SET Stock = Stock - ISNULL((
    SELECT SUM(oi.Quantity)
    FROM dbo.OrderItems oi
    JOIN dbo.Orders o ON oi.OrderID = o.OrderID
    WHERE oi.ProductID = dbo.Products.ProductID  -- correlation
      AND o.Status <> N'Cancelled'
), 0);
```

### 12.5 Performance Consideration

Correlated subqueries run **once per outer row**, which can be slow on large
tables. Often, a JOIN or CTE is more efficient:

```sql
-- Correlated subquery (slower on large data):
SELECT p.ProductName, (SELECT COUNT(*) FROM dbo.OrderItems oi
                       WHERE oi.ProductID = p.ProductID) AS TimesOrdered
FROM dbo.Products p;

-- Equivalent with LEFT JOIN + GROUP BY (usually faster):
SELECT p.ProductName, COUNT(oi.OrderItemID) AS TimesOrdered
FROM dbo.Products p
LEFT JOIN dbo.OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductName;
```

---

## 13. EXISTS and NOT EXISTS

### 13.1 How EXISTS Works

`EXISTS` returns `TRUE` if the subquery returns **at least one row**. It does
not care about **what** the subquery returns — only whether it returns anything.

```sql
-- Customers who have placed at least one order
SELECT
    c.FirstName + N' ' + c.LastName AS Customer,
    c.Email
FROM dbo.Customers c
WHERE EXISTS (
    SELECT 1
    FROM dbo.Orders o
    WHERE o.CustomerID = c.CustomerID
);
```

> **Tip:** By convention, use `SELECT 1` inside EXISTS. The actual value
> doesn't matter — only the existence of a row.

### 13.2 NOT EXISTS

```sql
-- Customers who have NEVER placed an order
SELECT
    c.FirstName + N' ' + c.LastName AS Customer,
    c.Email
FROM dbo.Customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Orders o
    WHERE o.CustomerID = c.CustomerID
);
```

### 13.3 EXISTS vs IN vs JOIN — Comparison

```sql
-- Method 1: EXISTS (generally fast, NULL-safe)
SELECT p.ProductName
FROM dbo.Products p
WHERE EXISTS (
    SELECT 1 FROM dbo.OrderItems oi WHERE oi.ProductID = p.ProductID
);

-- Method 2: IN (watch out for NULLs)
SELECT p.ProductName
FROM dbo.Products p
WHERE p.ProductID IN (SELECT ProductID FROM dbo.OrderItems);

-- Method 3: JOIN with DISTINCT
SELECT DISTINCT p.ProductName
FROM dbo.Products p
JOIN dbo.OrderItems oi ON p.ProductID = oi.ProductID;
```

| Method        | NULL-safe? | Duplicates?     | Performance            |
| ------------- | ---------- | --------------- | ---------------------- |
| `EXISTS`      | ✅ Yes     | No duplicates   | Usually very good      |
| `IN`          | ❌ No*     | No duplicates   | Good for small lists   |
| `JOIN`        | ✅ Yes     | Need DISTINCT   | Depends on data volume |
| `NOT EXISTS`  | ✅ Yes     | No duplicates   | Best for anti-joins    |
| `NOT IN`      | ❌ No*     | No duplicates   | Dangerous with NULLs   |

> *`NOT IN` fails silently if the subquery contains NULL values.

### 13.4 Advanced EXISTS Example

```sql
-- Categories that have at least one product priced above $100
-- AND at least one order in 2025
SELECT cat.CategoryName
FROM dbo.Categories cat
WHERE EXISTS (
    SELECT 1
    FROM dbo.Products p
    WHERE p.CategoryID = cat.CategoryID
      AND p.Price > 100
)
AND EXISTS (
    SELECT 1
    FROM dbo.Products p
    JOIN dbo.OrderItems oi ON p.ProductID = oi.ProductID
    JOIN dbo.Orders o      ON oi.OrderID = o.OrderID
    WHERE p.CategoryID = cat.CategoryID
      AND YEAR(o.OrderDate) = 2025
);
```

---

## 14. Common Table Expressions (CTEs)

### 14.1 What Is a CTE?

A **CTE** (Common Table Expression) is a named, temporary result set defined
within a single SQL statement. Think of it as a "named subquery" that improves
readability.

### 14.2 Basic CTE Syntax

```sql
;WITH CTEName AS (
    -- CTE query definition
    SELECT column1, column2, ...
    FROM SomeTable
    WHERE conditions
)
SELECT *
FROM CTEName;
```

> **Note:** The semicolon before `WITH` is a best practice. If a previous
> statement doesn't end with `;`, the `WITH` keyword can be ambiguous.

### 14.3 Simple CTE Example

```sql
-- Average order value per customer, then filter
;WITH CustomerOrderTotals AS (
    SELECT
        c.CustomerID,
        c.FirstName + N' ' + c.LastName AS CustomerName,
        o.OrderID,
        SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
    FROM dbo.Customers c
    JOIN dbo.Orders o      ON c.CustomerID = o.CustomerID
    JOIN dbo.OrderItems oi ON o.OrderID    = oi.OrderID
    GROUP BY c.CustomerID, c.FirstName, c.LastName, o.OrderID
),
CustomerAverages AS (
    SELECT
        CustomerID,
        CustomerName,
        COUNT(OrderID) AS TotalOrders,
        ROUND(AVG(OrderTotal), 2) AS AvgOrderValue,
        ROUND(SUM(OrderTotal), 2) AS TotalSpent
    FROM CustomerOrderTotals
    GROUP BY CustomerID, CustomerName
)
SELECT *
FROM CustomerAverages
WHERE TotalOrders > 1
ORDER BY TotalSpent DESC;
```

### 14.4 Multiple CTEs

You can define multiple CTEs separated by commas:

```sql
;WITH
TopProducts AS (
    SELECT TOP 5
        p.ProductID,
        p.ProductName,
        SUM(oi.Quantity) AS TotalSold
    FROM dbo.Products p
    JOIN dbo.OrderItems oi ON p.ProductID = oi.ProductID
    GROUP BY p.ProductID, p.ProductName
    ORDER BY TotalSold DESC
),
TopCustomers AS (
    SELECT TOP 5
        c.CustomerID,
        c.FirstName + N' ' + c.LastName AS CustomerName,
        SUM(oi.Quantity * oi.UnitPrice)  AS TotalSpent
    FROM dbo.Customers c
    JOIN dbo.Orders o      ON c.CustomerID = o.CustomerID
    JOIN dbo.OrderItems oi ON o.OrderID    = oi.OrderID
    GROUP BY c.CustomerID, c.FirstName, c.LastName
    ORDER BY TotalSpent DESC
)
-- Use both CTEs
SELECT 'Product' AS Type, ProductName AS Name, TotalSold AS Metric
FROM TopProducts
UNION ALL
SELECT 'Customer', CustomerName, TotalSpent
FROM TopCustomers;
```

### 14.5 Recursive CTEs

Recursive CTEs reference themselves and are perfect for hierarchical data.

```sql
-- Build the full org chart with level numbers
;WITH OrgHierarchy AS (
    -- Anchor member: start with the CEO
    SELECT
        EmployeeID,
        FirstName + N' ' + LastName AS FullName,
        Title,
        ManagerID,
        0 AS Level,
        CAST(FirstName + N' ' + LastName AS NVARCHAR(MAX)) AS Path
    FROM dbo.Employees
    WHERE ManagerID IS NULL

    UNION ALL

    -- Recursive member: find subordinates
    SELECT
        e.EmployeeID,
        e.FirstName + N' ' + e.LastName,
        e.Title,
        e.ManagerID,
        oh.Level + 1,
        CAST(oh.Path + N' → ' + e.FirstName + N' ' + e.LastName AS NVARCHAR(MAX))
    FROM dbo.Employees e
    INNER JOIN OrgHierarchy oh ON e.ManagerID = oh.EmployeeID
)
SELECT
    REPLICATE('  │ ', Level) + FullName AS OrgChart,
    Title,
    Level,
    Path
FROM OrgHierarchy
ORDER BY Path;
```

#### How Recursive CTEs Work

```
Iteration 0 (Anchor):
    → Sarah Connor (CEO, Level 0)

Iteration 1:
    → James Kirk (Level 1, reports to Sarah)
    → Nyota Uhura (Level 1, reports to Sarah)

Iteration 2:
    → Leonard McCoy (Level 2, reports to James)
    → Scotty Montgomery (Level 2, reports to Nyota)

Iteration 3:
    → Hikaru Sulu, Pavel Chekov (Level 3, reports to Leonard)
    → Spock, Christine, Janice (Level 3, reports to Scotty)

Iteration 4:
    → No more employees → STOP
```

### 14.6 Recursive CTE — Running Total

```sql
-- Calculate cumulative order revenue over time
;WITH OrderedSales AS (
    SELECT
        o.OrderID,
        o.OrderDate,
        SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal,
        ROW_NUMBER() OVER (ORDER BY o.OrderDate, o.OrderID) AS RowNum
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
    GROUP BY o.OrderID, o.OrderDate
)
SELECT
    OrderID,
    OrderDate,
    OrderTotal,
    SUM(OrderTotal) OVER (ORDER BY RowNum) AS RunningTotal
FROM OrderedSales
ORDER BY RowNum;
```

---

## 15. Derived Tables vs CTEs vs Subqueries

### 15.1 Feature Comparison

| Feature              | Subquery (WHERE/SELECT) | Derived Table (FROM) | CTE                  |
| -------------------- | ----------------------- | -------------------- | -------------------- |
| Where it lives       | WHERE or SELECT clause  | FROM clause          | Before the main query|
| Named?               | No                      | Yes (alias required) | Yes (named)          |
| Reusable in query?   | No                      | No                   | Yes (multiple refs)  |
| Recursive?           | No                      | No                   | Yes                  |
| Readability          | OK for simple           | OK for moderate      | Best for complex     |
| Performance          | Same*                   | Same*                | Same*                |

> *In SQL Server, CTEs and derived tables are usually optimized identically.
> The main benefit of CTEs is **readability and maintainability**.

### 15.2 Same Query — Three Ways

```sql
-- Goal: Find products that have been ordered more than 5 times total

-- Method 1: Subquery in WHERE
SELECT p.ProductName, p.Price
FROM dbo.Products p
WHERE p.ProductID IN (
    SELECT oi.ProductID
    FROM dbo.OrderItems oi
    GROUP BY oi.ProductID
    HAVING SUM(oi.Quantity) > 5
);

-- Method 2: Derived Table
SELECT p.ProductName, p.Price
FROM dbo.Products p
JOIN (
    SELECT ProductID, SUM(Quantity) AS TotalQty
    FROM dbo.OrderItems
    GROUP BY ProductID
    HAVING SUM(Quantity) > 5
) AS PopularProducts ON p.ProductID = PopularProducts.ProductID;

-- Method 3: CTE
;WITH PopularProducts AS (
    SELECT ProductID, SUM(Quantity) AS TotalQty
    FROM dbo.OrderItems
    GROUP BY ProductID
    HAVING SUM(Quantity) > 5
)
SELECT p.ProductName, p.Price, pp.TotalQty
FROM dbo.Products p
JOIN PopularProducts pp ON p.ProductID = pp.ProductID;
```

### 15.3 When to Use What

```
Simple scalar comparison?         → Subquery in WHERE
    e.g., WHERE Price > (SELECT AVG(Price) ...)

Filter based on a list?           → IN with subquery or EXISTS
    e.g., WHERE ID IN (SELECT ...)

Need to reuse the result?         → CTE
    e.g., reference the same dataset twice

Hierarchical / recursive data?    → Recursive CTE
    e.g., org charts, bill of materials

One-off intermediate calculation? → Derived table or CTE (preference)
    e.g., calculate, then filter
```

---

## 16. Complex Query Building — Practical Scenarios

### 16.1 Scenario: Product Profitability Report

```sql
-- For each product, show:
-- Name, Category, Selling Price, Best Supplier Cost, Margin, Times Ordered, Revenue
;WITH SupplierCosts AS (
    SELECT
        ProductID,
        MIN(Cost) AS BestCost,
        MIN(LeadDays) AS FastestDelivery
    FROM dbo.ProductSuppliers
    GROUP BY ProductID
),
OrderStats AS (
    SELECT
        oi.ProductID,
        SUM(oi.Quantity)              AS TotalQuantitySold,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
    FROM dbo.OrderItems oi
    JOIN dbo.Orders o ON oi.OrderID = o.OrderID
    WHERE o.Status <> N'Cancelled'
    GROUP BY oi.ProductID
)
SELECT
    p.ProductName,
    cat.CategoryName,
    p.Price                                      AS SellingPrice,
    sc.BestCost,
    ROUND(p.Price - ISNULL(sc.BestCost, 0), 2)  AS Margin,
    CASE
        WHEN sc.BestCost IS NULL THEN 'N/A'
        ELSE CAST(ROUND((p.Price - sc.BestCost) / p.Price * 100, 1) AS VARCHAR(10)) + '%'
    END                                          AS MarginPct,
    ISNULL(os.TotalQuantitySold, 0)              AS QtySold,
    ISNULL(os.TotalRevenue, 0)                   AS Revenue,
    sc.FastestDelivery                           AS LeadDays,
    CASE
        WHEN os.TotalQuantitySold IS NULL         THEN 'Never Ordered'
        WHEN os.TotalQuantitySold > 5             THEN 'High Demand'
        WHEN os.TotalQuantitySold > 2             THEN 'Moderate'
        ELSE                                           'Low Demand'
    END                                          AS DemandLevel
FROM dbo.Products p
JOIN dbo.Categories cat    ON p.CategoryID = cat.CategoryID
LEFT JOIN SupplierCosts sc ON p.ProductID  = sc.ProductID
LEFT JOIN OrderStats os    ON p.ProductID  = os.ProductID
WHERE p.IsActive = 1
ORDER BY Revenue DESC;
```

### 16.2 Scenario: Customer Segmentation

```sql
-- Segment customers into tiers based on total spending
;WITH CustomerSpending AS (
    SELECT
        c.CustomerID,
        c.FirstName + N' ' + c.LastName AS CustomerName,
        c.City,
        c.Country,
        c.JoinDate,
        COUNT(DISTINCT o.OrderID)               AS OrderCount,
        ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalSpent
    FROM dbo.Customers c
    LEFT JOIN dbo.Orders o      ON c.CustomerID = o.CustomerID
                                AND o.Status <> N'Cancelled'
    LEFT JOIN dbo.OrderItems oi ON o.OrderID    = oi.OrderID
    GROUP BY c.CustomerID, c.FirstName, c.LastName, c.City, c.Country, c.JoinDate
)
SELECT
    CustomerName,
    City,
    Country,
    JoinDate,
    OrderCount,
    TotalSpent,
    CASE
        WHEN TotalSpent >= 1000  THEN 'Gold'
        WHEN TotalSpent >= 200   THEN 'Silver'
        WHEN TotalSpent > 0      THEN 'Bronze'
        ELSE                          'Inactive'
    END AS Tier,
    NTILE(4) OVER (ORDER BY TotalSpent DESC) AS SpendingQuartile
FROM CustomerSpending
ORDER BY TotalSpent DESC;
```

### 16.3 Scenario: Year-Over-Year Comparison

```sql
-- Compare monthly sales between 2024 and 2025
;WITH MonthlySales AS (
    SELECT
        YEAR(o.OrderDate)                    AS OrderYear,
        MONTH(o.OrderDate)                   AS OrderMonth,
        SUM(oi.Quantity * oi.UnitPrice)      AS Revenue
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
    WHERE o.Status <> N'Cancelled'
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
)
SELECT
    COALESCE(c.OrderMonth, p.OrderMonth)     AS MonthNum,
    DATENAME(MONTH, DATEFROMPARTS(2025, COALESCE(c.OrderMonth, p.OrderMonth), 1))
                                              AS MonthName,
    ISNULL(p.Revenue, 0)                     AS Revenue_2024,
    ISNULL(c.Revenue, 0)                     AS Revenue_2025,
    ISNULL(c.Revenue, 0) - ISNULL(p.Revenue, 0) AS Difference,
    CASE
        WHEN p.Revenue IS NULL OR p.Revenue = 0 THEN 'N/A'
        ELSE CAST(ROUND((c.Revenue - p.Revenue) / p.Revenue * 100, 1) AS VARCHAR) + '%'
    END AS GrowthPct
FROM (SELECT * FROM MonthlySales WHERE OrderYear = 2025) c
FULL OUTER JOIN (SELECT * FROM MonthlySales WHERE OrderYear = 2024) p
    ON c.OrderMonth = p.OrderMonth
ORDER BY MonthNum;
```

### 16.4 Scenario: Finding Gaps and Islands

```sql
-- Find customers who ordered in consecutive months (islands)
;WITH CustomerMonths AS (
    SELECT DISTINCT
        o.CustomerID,
        YEAR(o.OrderDate) * 100 + MONTH(o.OrderDate) AS YearMonth,
        ROW_NUMBER() OVER (
            PARTITION BY o.CustomerID
            ORDER BY YEAR(o.OrderDate), MONTH(o.OrderDate)
        ) AS RowNum
    FROM dbo.Orders o
),
Islands AS (
    SELECT
        CustomerID,
        YearMonth,
        YearMonth - RowNum AS GroupID  -- consecutive months will share the same GroupID
    FROM CustomerMonths
)
SELECT
    c.FirstName + N' ' + c.LastName AS Customer,
    MIN(i.YearMonth) AS FirstMonth,
    MAX(i.YearMonth) AS LastMonth,
    COUNT(*) AS ConsecutiveMonths
FROM Islands i
JOIN dbo.Customers c ON i.CustomerID = c.CustomerID
GROUP BY c.FirstName, c.LastName, i.CustomerID, i.GroupID
HAVING COUNT(*) > 1
ORDER BY ConsecutiveMonths DESC;
```

---

## 17. Query Optimization Basics

### 17.1 Execution Plans

SQL Server creates an **execution plan** — a roadmap of how it will retrieve
and process data. You can view it in SSMS:

- **Estimated Plan:** `Ctrl + L` (before running)
- **Actual Plan:** `Ctrl + M` then run the query

### 17.2 Reading an Execution Plan

```
Key operators to look for:

┌───────────────────────────────────────────────────────────┐
│ Operator           │ Meaning              │ Good or Bad?  │
├───────────────────────────────────────────────────────────┤
│ Index Seek         │ Targeted lookup      │ ✅ Good       │
│ Index Scan         │ Read entire index    │ ⚠️ OK/Bad     │
│ Table Scan         │ Read entire table    │ ❌ Usually bad │
│ Nested Loop        │ Loop join            │ ✅ Good (small)│
│ Hash Match         │ Hash-based join      │ ⚠️ Depends    │
│ Sort               │ Sorting rows         │ ⚠️ Expensive  │
│ Key Lookup         │ Extra lookup to table│ ⚠️ Can be bad │
└───────────────────────────────────────────────────────────┘
```

### 17.3 Common Performance Tips

#### Tip 1: Use SARGable Predicates

**SARGable** = **S**earch **ARG**ument **able** — the optimizer can use an index.

```sql
-- ❌ Non-SARGable (wraps column in a function):
SELECT * FROM dbo.Orders
WHERE YEAR(OrderDate) = 2025;

-- ✅ SARGable (direct comparison):
SELECT * FROM dbo.Orders
WHERE OrderDate >= '2025-01-01' AND OrderDate < '2026-01-01';
```

```sql
-- ❌ Non-SARGable:
SELECT * FROM dbo.Customers
WHERE LEFT(LastName, 1) = 'S';

-- ✅ SARGable:
SELECT * FROM dbo.Customers
WHERE LastName LIKE 'S%';
```

#### Tip 2: Avoid SELECT *

```sql
-- ❌ Returns all columns (may cause unnecessary I/O):
SELECT * FROM dbo.Products;

-- ✅ Request only what you need:
SELECT ProductName, Price FROM dbo.Products;
```

#### Tip 3: Use EXISTS Instead of COUNT for Existence Checks

```sql
-- ❌ Slow: counts ALL matching rows just to check existence
IF (SELECT COUNT(*) FROM dbo.OrderItems WHERE ProductID = 1) > 0
    PRINT 'Product has been ordered';

-- ✅ Fast: stops at the first match
IF EXISTS (SELECT 1 FROM dbo.OrderItems WHERE ProductID = 1)
    PRINT 'Product has been ordered';
```

#### Tip 4: Be Careful with Correlated Subqueries

```sql
-- ❌ Runs once per product (N × M complexity):
SELECT
    p.ProductName,
    (SELECT SUM(Quantity) FROM dbo.OrderItems WHERE ProductID = p.ProductID) AS Sold
FROM dbo.Products p;

-- ✅ Single pass with JOIN:
SELECT p.ProductName, ISNULL(SUM(oi.Quantity), 0) AS Sold
FROM dbo.Products p
LEFT JOIN dbo.OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductName;
```

#### Tip 5: Use Appropriate JOINs

```sql
-- If you only need matching rows, use INNER JOIN (not LEFT JOIN + WHERE):
-- ❌ Wasteful LEFT JOIN:
SELECT c.FirstName, o.OrderID
FROM dbo.Customers c
LEFT JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NOT NULL;

-- ✅ Simply use INNER JOIN:
SELECT c.FirstName, o.OrderID
FROM dbo.Customers c
INNER JOIN dbo.Orders o ON c.CustomerID = o.CustomerID;
```

### 17.4 SET STATISTICS: Measuring Performance

```sql
-- Turn on I/O and time statistics
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Run your query
SELECT p.ProductName, SUM(oi.Quantity) AS TotalSold
FROM dbo.Products p
JOIN dbo.OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductName;

-- Turn off statistics
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

**Sample output:**
```
Table 'OrderItems'. Scan count 1, logical reads 3, physical reads 0
Table 'Products'.   Scan count 1, logical reads 2, physical reads 0
SQL Server Execution Times:
  CPU time = 0 ms, elapsed time = 1 ms.
```

> **Focus on logical reads** — fewer is better.

### 17.5 Optimization Decision Tree

```
Query is slow?
│
├── Check: Are you using SELECT *?
│   └── Yes → Select only needed columns
│
├── Check: Are your WHERE conditions SARGable?
│   └── No → Rewrite to avoid wrapping columns in functions
│
├── Check: Are you missing indexes?
│   └── Yes → Create appropriate indexes (Day 4)
│
├── Check: Are you using correlated subqueries?
│   └── Yes → Try rewriting as JOINs or CTEs
│
├── Check: Is the execution plan showing Table Scans?
│   └── Yes → Consider adding an index
│
└── Check: Are you returning too many rows?
    └── Yes → Add WHERE filters or use TOP / OFFSET-FETCH
```

---

## 18. Day 3 Summary

### What We Covered

| Topic                  | Key Takeaway                                             |
| ---------------------- | -------------------------------------------------------- |
| INNER JOIN             | Only matching rows from both tables                      |
| LEFT JOIN              | All left rows + matches (NULLs where no match)           |
| RIGHT JOIN             | All right rows + matches (rarely used — prefer LEFT)     |
| FULL OUTER JOIN        | All rows from both sides (NULLs fill gaps)               |
| CROSS JOIN             | Cartesian product — every combination                    |
| Self Join              | Table joined to itself (hierarchies, comparisons)        |
| Multi-Table Joins      | Build step by step, mix join types as needed             |
| Non-Correlated Subqueries | Run once, independent of outer query                  |
| Correlated Subqueries  | Run once per outer row — powerful but can be slow        |
| EXISTS / NOT EXISTS    | Best for checking existence; NULL-safe                   |
| CTEs                   | Named temporary result sets; great for readability       |
| Recursive CTEs         | Self-referencing CTEs for hierarchical data              |
| Derived Tables         | Subqueries in FROM clause                                |
| Query Optimization     | SARGable, avoid SELECT *, use EXISTS, check plans        |

### Join Type Quick Reference

```sql
-- INNER JOIN:   Only matches
-- LEFT JOIN:    All left + matches from right
-- RIGHT JOIN:   All right + matches from left (avoid; use LEFT)
-- FULL OUTER:   All from both
-- CROSS JOIN:   Cartesian product (no ON clause)
-- Self JOIN:    Same table joined to itself
```

### Anti-Join Patterns (Find Missing Data)

```sql
-- Method 1: LEFT JOIN + IS NULL
SELECT a.* FROM TableA a
LEFT JOIN TableB b ON a.ID = b.ID
WHERE b.ID IS NULL;

-- Method 2: NOT EXISTS (preferred)
SELECT a.* FROM TableA a
WHERE NOT EXISTS (SELECT 1 FROM TableB b WHERE b.ID = a.ID);

-- Method 3: NOT IN (be careful with NULLs)
SELECT a.* FROM TableA a
WHERE a.ID NOT IN (SELECT ID FROM TableB WHERE ID IS NOT NULL);

-- Method 4: EXCEPT
SELECT ID FROM TableA
EXCEPT
SELECT ID FROM TableB;
```

---

## 19. Hands-On Exercises

### Exercise 1: Basic Joins

Using the RetailDB database, write queries to:

1. List all products with their category names (use INNER JOIN).
2. List ALL products with their supplier names — include products that have no supplier.
3. List ALL suppliers with the products they supply — include suppliers with no products.
4. Find all products that have no supplier assigned.
5. Find all suppliers that are not linked to any product.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Products with categories (INNER JOIN)
SELECT p.ProductName, p.Price, c.CategoryName
FROM dbo.Products p
INNER JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.ProductName;

-- 2. All products with suppliers (LEFT JOIN)
SELECT p.ProductName, s.SupplierName, ps.Cost
FROM dbo.Products p
LEFT JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
LEFT JOIN dbo.Suppliers s         ON ps.SupplierID = s.SupplierID
ORDER BY p.ProductName;

-- 3. All suppliers with products (LEFT JOIN from suppliers)
SELECT s.SupplierName, p.ProductName, ps.Cost
FROM dbo.Suppliers s
LEFT JOIN dbo.ProductSuppliers ps ON s.SupplierID = ps.SupplierID
LEFT JOIN dbo.Products p          ON ps.ProductID = p.ProductID
ORDER BY s.SupplierName;

-- 4. Products with no supplier
SELECT p.ProductName
FROM dbo.Products p
LEFT JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
WHERE ps.ProductID IS NULL
ORDER BY p.ProductName;

-- 5. Suppliers with no products
SELECT s.SupplierName
FROM dbo.Suppliers s
LEFT JOIN dbo.ProductSuppliers ps ON s.SupplierID = ps.SupplierID
WHERE ps.SupplierID IS NULL;
```

</details>

---

### Exercise 2: Multi-Table Joins

1. Write a query showing complete order information: Customer name, Order ID, Order Date, Product Name, Category Name, Quantity, Unit Price, and Line Total.
2. Modify the above to only show orders with status 'Delivered' or 'Shipped'.
3. Add the supplier name for each product in the order (include products without suppliers).
4. Calculate the total revenue per category (only non-cancelled orders).

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Complete order details
SELECT
    c.FirstName + N' ' + c.LastName AS Customer,
    o.OrderID,
    o.OrderDate,
    p.ProductName,
    cat.CategoryName,
    oi.Quantity,
    oi.UnitPrice,
    oi.Quantity * oi.UnitPrice AS LineTotal
FROM dbo.Customers c
JOIN dbo.Orders o        ON c.CustomerID = o.CustomerID
JOIN dbo.OrderItems oi   ON o.OrderID    = oi.OrderID
JOIN dbo.Products p      ON oi.ProductID = p.ProductID
JOIN dbo.Categories cat  ON p.CategoryID = cat.CategoryID
ORDER BY o.OrderDate, o.OrderID;

-- 2. Only Delivered or Shipped
SELECT
    c.FirstName + N' ' + c.LastName AS Customer,
    o.OrderID,
    o.OrderDate,
    o.Status,
    p.ProductName,
    oi.Quantity * oi.UnitPrice AS LineTotal
FROM dbo.Customers c
JOIN dbo.Orders o        ON c.CustomerID = o.CustomerID
JOIN dbo.OrderItems oi   ON o.OrderID    = oi.OrderID
JOIN dbo.Products p      ON oi.ProductID = p.ProductID
WHERE o.Status IN (N'Delivered', N'Shipped')
ORDER BY o.OrderDate;

-- 3. With supplier (LEFT JOIN)
SELECT
    c.FirstName + N' ' + c.LastName AS Customer,
    o.OrderID,
    p.ProductName,
    ISNULL(s.SupplierName, 'No Supplier') AS Supplier,
    oi.Quantity * oi.UnitPrice AS LineTotal
FROM dbo.Customers c
JOIN dbo.Orders o             ON c.CustomerID = o.CustomerID
JOIN dbo.OrderItems oi        ON o.OrderID    = oi.OrderID
JOIN dbo.Products p           ON oi.ProductID = p.ProductID
LEFT JOIN dbo.ProductSuppliers ps ON p.ProductID = ps.ProductID
LEFT JOIN dbo.Suppliers s     ON ps.SupplierID = s.SupplierID
ORDER BY o.OrderID;

-- 4. Revenue per category
SELECT
    cat.CategoryName,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM dbo.Categories cat
JOIN dbo.Products p      ON cat.CategoryID = p.CategoryID
JOIN dbo.OrderItems oi   ON p.ProductID    = oi.ProductID
JOIN dbo.Orders o        ON oi.OrderID     = o.OrderID
WHERE o.Status <> N'Cancelled'
GROUP BY cat.CategoryName
ORDER BY TotalRevenue DESC;
```

</details>

---

### Exercise 3: Self Join

1. List each employee with their manager's name.
2. Find employees who earn more than their manager.
3. List all pairs of employees who are at the same level in the hierarchy.
4. Count how many direct reports each manager has.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Employee with manager
SELECT
    e.FirstName + N' ' + e.LastName AS Employee,
    e.Title,
    ISNULL(m.FirstName + N' ' + m.LastName, '(No Manager)') AS Manager
FROM dbo.Employees e
LEFT JOIN dbo.Employees m ON e.ManagerID = m.EmployeeID
ORDER BY e.EmployeeID;

-- 2. Earns more than manager
SELECT
    e.FirstName + N' ' + e.LastName AS Employee,
    e.Salary AS EmployeeSalary,
    m.FirstName + N' ' + m.LastName AS Manager,
    m.Salary AS ManagerSalary
FROM dbo.Employees e
JOIN dbo.Employees m ON e.ManagerID = m.EmployeeID
WHERE e.Salary > m.Salary;

-- 3. Peers at the same level
;WITH EmpLevels AS (
    SELECT EmployeeID, FirstName + N' ' + LastName AS FullName, ManagerID,
           0 AS Lvl
    FROM dbo.Employees WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.EmployeeID, e.FirstName + N' ' + e.LastName, e.ManagerID,
           el.Lvl + 1
    FROM dbo.Employees e
    JOIN EmpLevels el ON e.ManagerID = el.EmployeeID
)
SELECT
    a.FullName AS Employee1,
    b.FullName AS Employee2,
    a.Lvl AS Level
FROM EmpLevels a
JOIN EmpLevels b ON a.Lvl = b.Lvl AND a.EmployeeID < b.EmployeeID
ORDER BY a.Lvl, a.FullName;

-- 4. Direct reports per manager
SELECT
    m.FirstName + N' ' + m.LastName AS Manager,
    m.Title,
    COUNT(e.EmployeeID) AS DirectReports
FROM dbo.Employees m
JOIN dbo.Employees e ON e.ManagerID = m.EmployeeID
GROUP BY m.FirstName, m.LastName, m.Title
ORDER BY DirectReports DESC;
```

</details>

---

### Exercise 4: Subqueries

1. Find products priced above the average price of ALL products.
2. Find products priced above the average price of **their own category** (correlated).
3. Find the customer who has spent the most money overall (use a derived table or CTE).
4. Using EXISTS, find categories that have at least one product with stock below 50.
5. Using NOT EXISTS, find products that have never been ordered.
6. Find orders where the total order value exceeds twice the overall average order value.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Above overall average
SELECT ProductName, Price
FROM dbo.Products
WHERE Price > (SELECT AVG(Price) FROM dbo.Products)
ORDER BY Price DESC;

-- 2. Above own category's average (correlated)
SELECT p.ProductName, p.Price, p.CategoryID
FROM dbo.Products p
WHERE p.Price > (
    SELECT AVG(p2.Price)
    FROM dbo.Products p2
    WHERE p2.CategoryID = p.CategoryID
)
ORDER BY p.CategoryID, p.Price DESC;

-- 3. Top spender (CTE)
;WITH CustomerSpend AS (
    SELECT
        c.CustomerID,
        c.FirstName + N' ' + c.LastName AS CustomerName,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSpent
    FROM dbo.Customers c
    JOIN dbo.Orders o      ON c.CustomerID = o.CustomerID
    JOIN dbo.OrderItems oi ON o.OrderID    = oi.OrderID
    WHERE o.Status <> N'Cancelled'
    GROUP BY c.CustomerID, c.FirstName, c.LastName
)
SELECT TOP 1 CustomerName, TotalSpent
FROM CustomerSpend
ORDER BY TotalSpent DESC;

-- 4. Categories with low-stock products (EXISTS)
SELECT cat.CategoryName
FROM dbo.Categories cat
WHERE EXISTS (
    SELECT 1 FROM dbo.Products p
    WHERE p.CategoryID = cat.CategoryID AND p.Stock < 50
);

-- 5. Never-ordered products (NOT EXISTS)
SELECT p.ProductName
FROM dbo.Products p
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.OrderItems oi WHERE oi.ProductID = p.ProductID
);

-- 6. Orders exceeding 2× the average order value
;WITH OrderValues AS (
    SELECT OrderID, SUM(Quantity * UnitPrice) AS OrderTotal
    FROM dbo.OrderItems
    GROUP BY OrderID
)
SELECT
    ov.OrderID,
    ov.OrderTotal
FROM OrderValues ov
WHERE ov.OrderTotal > 2 * (SELECT AVG(OrderTotal) FROM OrderValues)
ORDER BY ov.OrderTotal DESC;
```

</details>

---

### Exercise 5: CTEs and Complex Queries

1. Write a recursive CTE that shows the full management chain for employee "Spock Grayson" (from Spock up to the CEO).
2. Using CTEs, create a "Product Performance Card" that shows for each product: name, category, price, supplier cost, margin percentage, total quantity sold, total revenue, and a rating (★ to ★★★★★ based on revenue quintiles).
3. Write a query that finds the top 3 products per category by revenue using a CTE and ROW_NUMBER().

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Management chain for Spock
;WITH ManagementChain AS (
    -- Start with Spock
    SELECT EmployeeID, FirstName + N' ' + LastName AS FullName, Title, ManagerID, 0 AS Level
    FROM dbo.Employees
    WHERE FirstName = N'Spock' AND LastName = N'Grayson'

    UNION ALL

    -- Walk up to each manager
    SELECT m.EmployeeID, m.FirstName + N' ' + m.LastName, m.Title, m.ManagerID, mc.Level + 1
    FROM dbo.Employees m
    JOIN ManagementChain mc ON mc.ManagerID = m.EmployeeID
)
SELECT
    REPLICATE('  ↑ ', Level) + FullName AS Chain,
    Title,
    Level
FROM ManagementChain
ORDER BY Level;

-- 2. Product Performance Card
;WITH SupplierInfo AS (
    SELECT ProductID, MIN(Cost) AS BestCost
    FROM dbo.ProductSuppliers
    GROUP BY ProductID
),
SalesInfo AS (
    SELECT
        oi.ProductID,
        SUM(oi.Quantity) AS TotalSold,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
    FROM dbo.OrderItems oi
    JOIN dbo.Orders o ON oi.OrderID = o.OrderID
    WHERE o.Status <> N'Cancelled'
    GROUP BY oi.ProductID
),
ProductCard AS (
    SELECT
        p.ProductName,
        cat.CategoryName,
        p.Price,
        si.BestCost,
        CASE
            WHEN si.BestCost IS NOT NULL
            THEN ROUND((p.Price - si.BestCost) / p.Price * 100, 1)
            ELSE NULL
        END AS MarginPct,
        ISNULL(sa.TotalSold, 0) AS QtySold,
        ISNULL(sa.TotalRevenue, 0) AS Revenue,
        NTILE(5) OVER (ORDER BY ISNULL(sa.TotalRevenue, 0) ASC) AS RevenueQuintile
    FROM dbo.Products p
    JOIN dbo.Categories cat  ON p.CategoryID = cat.CategoryID
    LEFT JOIN SupplierInfo si ON p.ProductID = si.ProductID
    LEFT JOIN SalesInfo sa    ON p.ProductID = sa.ProductID
)
SELECT
    ProductName,
    CategoryName,
    Price,
    BestCost,
    MarginPct,
    QtySold,
    Revenue,
    REPLICATE(N'★', RevenueQuintile) AS Rating
FROM ProductCard
ORDER BY Revenue DESC;

-- 3. Top 3 products per category by revenue
;WITH ProductRevenue AS (
    SELECT
        p.ProductID,
        p.ProductName,
        cat.CategoryName,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue,
        ROW_NUMBER() OVER (
            PARTITION BY cat.CategoryID
            ORDER BY SUM(oi.Quantity * oi.UnitPrice) DESC
        ) AS RankInCategory
    FROM dbo.Products p
    JOIN dbo.Categories cat  ON p.CategoryID = cat.CategoryID
    JOIN dbo.OrderItems oi   ON p.ProductID  = oi.ProductID
    JOIN dbo.Orders o        ON oi.OrderID   = o.OrderID
    WHERE o.Status <> N'Cancelled'
    GROUP BY p.ProductID, p.ProductName, cat.CategoryID, cat.CategoryName
)
SELECT
    CategoryName,
    ProductName,
    TotalRevenue,
    RankInCategory
FROM ProductRevenue
WHERE RankInCategory <= 3
ORDER BY CategoryName, RankInCategory;
```

</details>

---

### Exercise 6: Optimization Challenge

Review each query below and identify the performance problem. Then rewrite it.

```sql
-- Query A: Find orders from 2025
SELECT * FROM dbo.Orders
WHERE YEAR(OrderDate) = 2025;

-- Query B: Check if a product has been ordered
IF (SELECT COUNT(*) FROM dbo.OrderItems WHERE ProductID = 1) > 0
    PRINT 'Yes';

-- Query C: Get product name for each order item
SELECT
    oi.OrderItemID,
    (SELECT ProductName FROM dbo.Products WHERE ProductID = oi.ProductID) AS ProductName,
    oi.Quantity
FROM dbo.OrderItems oi;
```

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- Query A Problem: YEAR() wrapping prevents index usage (non-SARGable)
-- Fix: use date range comparison
SELECT * FROM dbo.Orders
WHERE OrderDate >= '2025-01-01' AND OrderDate < '2026-01-01';

-- Query B Problem: COUNT(*) scans all matching rows just for existence check
-- Fix: use EXISTS
IF EXISTS (SELECT 1 FROM dbo.OrderItems WHERE ProductID = 1)
    PRINT 'Yes';

-- Query C Problem: correlated scalar subquery executes once per row
-- Fix: use JOIN
SELECT
    oi.OrderItemID,
    p.ProductName,
    oi.Quantity
FROM dbo.OrderItems oi
JOIN dbo.Products p ON oi.ProductID = p.ProductID;
```

</details>

---

## 🎯 End of Day 3

**Tomorrow (Day 4)** we will explore:

- Indexes: clustered, non-clustered, and how they work
- Views: creating, querying, and updating
- Stored procedures: building reusable T-SQL programs
- Exception handling with TRY…CATCH

**Homework:**

1. Rewrite all exercises without looking at solutions.
2. Practice building queries step by step (start with 2 tables, then add more).
3. Run `SET STATISTICS IO ON` for your queries and observe logical reads.
4. Challenge: Write a recursive CTE that generates numbers 1 to 100.

---

> **Tip:** When your query gets complex, break it into CTEs. Name each CTE
> after what it represents (e.g., `CustomerSpending`, `TopProducts`). Your
> future self (and your colleagues) will thank you.