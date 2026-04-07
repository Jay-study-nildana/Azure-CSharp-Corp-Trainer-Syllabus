# Day 2: Core SQL & Data Manipulation

---

## Table of Contents

1. [Recap & Setup](#1-recap--setup)
2. [Deep Dive into T-SQL](#2-deep-dive-into-t-sql)
3. [System Functions](#3-system-functions)
4. [Advanced SELECT Queries](#4-advanced-select-queries)
5. [Advanced DML Statements](#5-advanced-dml-statements)
6. [Other T-SQL Statements](#6-other-t-sql-statements)
7. [Set Operators](#7-set-operators)
8. [Day 2 Summary](#8-day-2-summary)
9. [Hands-On Exercises](#9-hands-on-exercises)

---

## 1. Recap & Setup

### 1.1 Quick Recap of Day 1

| Concept         | Key Point                                                |
| --------------- | -------------------------------------------------------- |
| RDBMS           | Data in tables, relationships via keys                   |
| T-SQL           | Microsoft's SQL dialect for SQL Server                   |
| DDL             | CREATE, ALTER, DROP, TRUNCATE                            |
| DML             | SELECT, INSERT, UPDATE, DELETE                           |
| DCL             | GRANT, REVOKE, DENY                                     |
| Constraints     | PK, FK, UNIQUE, CHECK, DEFAULT, NOT NULL                 |

### 1.2 Sample Database for Day 2

We will use a small **retail store** database throughout today's lessons.
Run the following script to set it up:

```sql
-- ============================================
-- Create the RetailDB database
-- ============================================
CREATE DATABASE RetailDB;
GO

USE RetailDB;
GO

-- ============================================
-- Tables
-- ============================================

CREATE TABLE dbo.Categories (
    CategoryID   INT           NOT NULL IDENTITY(1,1),
    CategoryName NVARCHAR(50)  NOT NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID)
);

CREATE TABLE dbo.Products (
    ProductID    INT            NOT NULL IDENTITY(1,1),
    ProductName  NVARCHAR(100)  NOT NULL,
    CategoryID   INT            NOT NULL,
    Price        DECIMAL(10,2)  NOT NULL,
    Stock        INT            NOT NULL DEFAULT 0,
    IsActive     BIT            NOT NULL DEFAULT 1,
    CreatedDate  DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Products PRIMARY KEY (ProductID),
    CONSTRAINT FK_Products_Category FOREIGN KEY (CategoryID)
        REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    CONSTRAINT CK_Products_Stock CHECK (Stock >= 0)
);

CREATE TABLE dbo.Customers (
    CustomerID   INT            NOT NULL IDENTITY(1,1),
    FirstName    NVARCHAR(50)   NOT NULL,
    LastName     NVARCHAR(50)   NOT NULL,
    Email        NVARCHAR(100)  NOT NULL,
    City         NVARCHAR(50),
    Country      NVARCHAR(50)   NOT NULL DEFAULT N'United States',
    JoinDate     DATE           NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
    CONSTRAINT UQ_Customers_Email UNIQUE (Email)
);

CREATE TABLE dbo.Orders (
    OrderID      INT            NOT NULL IDENTITY(1,1),
    CustomerID   INT            NOT NULL,
    OrderDate    DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    Status       NVARCHAR(20)   NOT NULL DEFAULT N'Pending',
    CONSTRAINT PK_Orders PRIMARY KEY (OrderID),
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID),
    CONSTRAINT CK_Orders_Status CHECK (Status IN (
        N'Pending', N'Processing', N'Shipped', N'Delivered', N'Cancelled'
    ))
);

CREATE TABLE dbo.OrderItems (
    OrderItemID  INT           NOT NULL IDENTITY(1,1),
    OrderID      INT           NOT NULL,
    ProductID    INT           NOT NULL,
    Quantity     INT           NOT NULL,
    UnitPrice    DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_OrderItems PRIMARY KEY (OrderItemID),
    CONSTRAINT FK_OrderItems_Order FOREIGN KEY (OrderID)
        REFERENCES dbo.Orders(OrderID),
    CONSTRAINT FK_OrderItems_Product FOREIGN KEY (ProductID)
        REFERENCES dbo.Products(ProductID),
    CONSTRAINT CK_OrderItems_Qty CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_Price CHECK (UnitPrice >= 0)
);
GO

-- ============================================
-- Seed data
-- ============================================

-- Categories
INSERT INTO dbo.Categories (CategoryName)
VALUES
    (N'Electronics'),
    (N'Clothing'),
    (N'Books'),
    (N'Home & Kitchen'),
    (N'Sports');

-- Products
INSERT INTO dbo.Products (ProductName, CategoryID, Price, Stock)
VALUES
    (N'Laptop Pro 15',        1, 1299.99, 50),
    (N'Wireless Mouse',       1,   29.99, 200),
    (N'USB-C Hub',            1,   49.99, 150),
    (N'Mechanical Keyboard',  1,   89.99, 120),
    (N'Noise-Cancel Headphones', 1, 249.99, 75),
    (N'Cotton T-Shirt',       2,   19.99, 500),
    (N'Denim Jeans',          2,   59.99, 300),
    (N'Winter Jacket',        2,  129.99, 100),
    (N'Running Shoes',        2,   99.99, 200),
    (N'SQL in 24 Hours',      3,   34.99, 80),
    (N'Clean Code',           3,   39.99, 60),
    (N'Design Patterns',      3,   44.99, 45),
    (N'Coffee Maker',         4,   79.99, 90),
    (N'Blender Pro',          4,   64.99, 110),
    (N'Air Fryer',            4,  119.99, 70),
    (N'Yoga Mat',             5,   24.99, 250),
    (N'Dumbbell Set',         5,   59.99, 80),
    (N'Basketball',           5,   29.99, 150);

-- Customers
INSERT INTO dbo.Customers (FirstName, LastName, Email, City, Country, JoinDate)
VALUES
    (N'Alice',   N'Johnson', N'alice@email.com',   N'New York',    N'United States', '2024-01-15'),
    (N'Bob',     N'Smith',   N'bob@email.com',     N'Los Angeles', N'United States', '2024-03-20'),
    (N'Charlie', N'Lee',     N'charlie@email.com', N'London',      N'United Kingdom','2024-02-10'),
    (N'Diana',   N'Chen',    N'diana@email.com',   N'Toronto',     N'Canada',        '2024-05-05'),
    (N'Eve',     N'Adams',   N'eve@email.com',     N'Sydney',      N'Australia',     '2024-06-18'),
    (N'Frank',   N'Wilson',  N'frank@email.com',   N'New York',    N'United States', '2024-07-22'),
    (N'Grace',   N'Kim',     N'grace@email.com',   N'Seoul',       N'South Korea',   '2024-08-30'),
    (N'Hank',    N'Brown',   N'hank@email.com',    N'Chicago',     N'United States', '2024-09-14'),
    (N'Ivy',     N'Patel',   N'ivy@email.com',     N'Mumbai',      N'India',         '2024-10-01'),
    (N'Jack',    N'Taylor',  N'jack@email.com',     N'Berlin',      N'Germany',       '2024-11-11');

-- Orders
INSERT INTO dbo.Orders (CustomerID, OrderDate, Status)
VALUES
    (1, '2025-01-10 09:30:00', N'Delivered'),
    (1, '2025-02-15 14:00:00', N'Delivered'),
    (2, '2025-01-20 11:15:00', N'Delivered'),
    (3, '2025-02-01 16:45:00', N'Shipped'),
    (4, '2025-02-10 10:00:00', N'Shipped'),
    (5, '2025-03-01 08:30:00', N'Processing'),
    (6, '2025-03-05 12:00:00', N'Pending'),
    (7, '2025-03-10 09:00:00', N'Pending'),
    (2, '2025-03-12 15:30:00', N'Pending'),
    (8, '2025-03-15 11:00:00', N'Cancelled'),
    (1, '2025-03-18 13:45:00', N'Processing'),
    (9, '2025-03-20 10:30:00', N'Pending'),
    (3, '2025-03-22 14:15:00', N'Pending'),
    (10,'2025-03-25 09:00:00', N'Pending');

-- OrderItems
INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
    -- Order 1 (Alice)
    (1, 1, 1, 1299.99),
    (1, 2, 2,   29.99),
    -- Order 2 (Alice)
    (2, 10, 1,  34.99),
    (2, 11, 1,  39.99),
    -- Order 3 (Bob)
    (3, 6, 3,   19.99),
    (3, 7, 1,   59.99),
    -- Order 4 (Charlie)
    (4, 5, 1,  249.99),
    (4, 3, 2,   49.99),
    -- Order 5 (Diana)
    (5, 13, 1,  79.99),
    (5, 15, 1, 119.99),
    -- Order 6 (Eve)
    (6, 16, 2,  24.99),
    (6, 17, 1,  59.99),
    -- Order 7 (Frank)
    (7, 1, 1, 1299.99),
    (7, 4, 1,   89.99),
    -- Order 8 (Grace)
    (8, 8, 1,  129.99),
    (8, 9, 1,   99.99),
    -- Order 9 (Bob - 2nd order)
    (9, 12, 2,  44.99),
    (9, 14, 1,  64.99),
    -- Order 10 (Hank - cancelled)
    (10, 1, 1, 1299.99),
    -- Order 11 (Alice - 3rd order)
    (11, 15, 1, 119.99),
    (11, 18, 3,  29.99),
    -- Order 12 (Ivy)
    (12, 6, 5,  19.99),
    (12, 16, 1, 24.99),
    -- Order 13 (Charlie - 2nd order)
    (13, 10, 1, 34.99),
    (13, 11, 1, 39.99),
    (13, 12, 1, 44.99),
    -- Order 14 (Jack)
    (14, 2, 1,  29.99),
    (14, 3, 1,  49.99),
    (14, 4, 1,  89.99);
GO
```

---

## 2. Deep Dive into T-SQL

### 2.1 Variables

Variables let you store temporary values during a batch or script.

```sql
-- Declare and set a variable
DECLARE @ProductCount INT;
SET @ProductCount = (SELECT COUNT(*) FROM dbo.Products);
PRINT 'Total products: ' + CAST(@ProductCount AS VARCHAR(10));

-- Declare and assign in one step (SQL Server 2008+)
DECLARE @MaxPrice DECIMAL(10,2) = (SELECT MAX(Price) FROM dbo.Products);
SELECT @MaxPrice AS MaxPrice;
```

### 2.2 Multiple Variable Assignment

```sql
DECLARE @FirstName NVARCHAR(50),
        @LastName  NVARCHAR(50),
        @Email     NVARCHAR(100);

SELECT @FirstName = FirstName,
       @LastName  = LastName,
       @Email     = Email
FROM dbo.Customers
WHERE CustomerID = 1;

PRINT @FirstName + N' ' + @LastName + N' — ' + @Email;
-- Output: Alice Johnson — alice@email.com
```

### 2.3 Control Flow: IF…ELSE

```sql
DECLARE @Stock INT;
SELECT @Stock = Stock FROM dbo.Products WHERE ProductID = 1;

IF @Stock > 100
    PRINT 'Well stocked.';
ELSE IF @Stock > 20
    PRINT 'Stock is adequate.';
ELSE
    PRINT 'Low stock — reorder needed!';
```

### 2.4 Control Flow: WHILE Loop

```sql
-- Print numbers 1 to 5
DECLARE @Counter INT = 1;

WHILE @Counter <= 5
BEGIN
    PRINT 'Counter: ' + CAST(@Counter AS VARCHAR(2));
    SET @Counter = @Counter + 1;
END;
```

**Output:**
```
Counter: 1
Counter: 2
Counter: 3
Counter: 4
Counter: 5
```

### 2.5 WHILE Loop — Practical Example

```sql
-- Apply a 10% discount to all products priced above $100,
-- but keep reducing until no product exceeds $500.
WHILE EXISTS (SELECT 1 FROM dbo.Products WHERE Price > 500)
BEGIN
    UPDATE dbo.Products
    SET Price = Price * 0.90
    WHERE Price > 500;
END;
```

> **Caution:** Always ensure WHILE loops have a clear termination condition.
> An infinite loop will lock your database!

### 2.6 BEGIN…END Blocks

`BEGIN…END` groups multiple statements into a single logical block:

```sql
IF (SELECT COUNT(*) FROM dbo.Orders WHERE Status = N'Pending') > 5
BEGIN
    PRINT 'High number of pending orders!';
    PRINT 'Consider adding staff to process them.';
    -- You could trigger an alert here
END
ELSE
BEGIN
    PRINT 'Pending orders are under control.';
END;
```

### 2.7 CASE Expressions

`CASE` lets you add conditional logic inside a query.

#### Simple CASE

```sql
SELECT
    ProductName,
    Price,
    CASE CategoryID
        WHEN 1 THEN 'Electronics'
        WHEN 2 THEN 'Clothing'
        WHEN 3 THEN 'Books'
        WHEN 4 THEN 'Home & Kitchen'
        WHEN 5 THEN 'Sports'
        ELSE 'Other'
    END AS CategoryLabel
FROM dbo.Products;
```

#### Searched CASE

```sql
SELECT
    ProductName,
    Price,
    CASE
        WHEN Price >= 500           THEN 'Premium'
        WHEN Price >= 100           THEN 'Mid-Range'
        WHEN Price >= 50            THEN 'Budget'
        ELSE                             'Bargain'
    END AS PriceTier
FROM dbo.Products
ORDER BY Price DESC;
```

**Output (sample):**

| ProductName              | Price   | PriceTier |
| ------------------------ | ------- | --------- |
| Laptop Pro 15            | 1299.99 | Premium   |
| Noise-Cancel Headphones  | 249.99  | Mid-Range |
| Winter Jacket            | 129.99  | Mid-Range |
| Air Fryer                | 119.99  | Mid-Range |
| Running Shoes            | 99.99   | Budget    |
| Mechanical Keyboard      | 89.99   | Budget    |
| Denim Jeans              | 59.99   | Budget    |
| Dumbbell Set             | 59.99   | Budget    |
| USB-C Hub                | 49.99   | Bargain   |
| ...                      | ...     | ...       |

### 2.8 CASE in UPDATE Statements

```sql
-- Adjust stock alerts based on category
UPDATE dbo.Products
SET Stock = CASE
    WHEN CategoryID = 1 AND Stock < 50  THEN Stock + 20   -- restock electronics
    WHEN CategoryID = 2 AND Stock < 100 THEN Stock + 50   -- restock clothing
    ELSE Stock
END;
```

### 2.9 IIF — Inline IF (Shorthand CASE)

```sql
SELECT
    ProductName,
    Stock,
    IIF(Stock > 100, 'In Stock', 'Low Stock') AS StockStatus
FROM dbo.Products;
```

### 2.10 CHOOSE — Index-Based Selection

```sql
SELECT
    OrderID,
    CHOOSE(
        MONTH(OrderDate),
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
    ) AS OrderMonth
FROM dbo.Orders;
```

---

## 3. System Functions

SQL Server provides hundreds of built-in functions. Let's cover the most
important categories.

### 3.1 String Functions

| Function                | Description                          | Example                                      |
| ----------------------- | ------------------------------------ | -------------------------------------------- |
| `LEN(str)`              | Length (excluding trailing spaces)   | `LEN('Hello')` → 5                           |
| `DATALENGTH(str)`       | Storage size in bytes                | `DATALENGTH(N'Hello')` → 10                  |
| `LEFT(str, n)`          | First n characters                   | `LEFT('Hello', 3)` → `'Hel'`                 |
| `RIGHT(str, n)`         | Last n characters                    | `RIGHT('Hello', 3)` → `'llo'`                |
| `SUBSTRING(str, s, n)`  | n characters starting at position s  | `SUBSTRING('Hello', 2, 3)` → `'ell'`         |
| `UPPER(str)`            | Convert to uppercase                 | `UPPER('hello')` → `'HELLO'`                 |
| `LOWER(str)`            | Convert to lowercase                 | `LOWER('HELLO')` → `'hello'`                 |
| `LTRIM(str)`            | Remove leading spaces                | `LTRIM('  Hi')` → `'Hi'`                     |
| `RTRIM(str)`            | Remove trailing spaces               | `RTRIM('Hi  ')` → `'Hi'`                     |
| `TRIM(str)`             | Remove leading & trailing spaces     | `TRIM('  Hi  ')` → `'Hi'`                    |
| `REPLACE(str, old, new)`| Replace occurrences                  | `REPLACE('Hello', 'l', 'r')` → `'Herro'`    |
| `CHARINDEX(find, str)`  | Position of first occurrence         | `CHARINDEX('l', 'Hello')` → 3                |
| `REVERSE(str)`          | Reverse the string                   | `REVERSE('Hello')` → `'olleH'`               |
| `REPLICATE(str, n)`     | Repeat string n times                | `REPLICATE('Ab', 3)` → `'AbAbAb'`            |
| `STUFF(str, s, n, new)` | Delete n chars at s, insert new      | `STUFF('Hello', 2, 3, 'XY')` → `'HXYo'`     |
| `CONCAT(a, b, …)`       | Concatenate (NULL-safe)              | `CONCAT('A', NULL, 'B')` → `'AB'`            |
| `CONCAT_WS(sep, a, b)`  | Concatenate with separator           | `CONCAT_WS('-','2025','03','15')` → `'2025-03-15'` |
| `STRING_AGG(col, sep)`  | Aggregate into delimited string      | See example below                             |
| `FORMAT(value, fmt)`    | Format as string                     | `FORMAT(1234.5, 'N2')` → `'1,234.50'`        |

#### String Functions in Action

```sql
SELECT
    CustomerID,
    UPPER(FirstName) + N' ' + UPPER(LastName) AS FullNameUpper,
    LEN(Email) AS EmailLength,
    LEFT(Email, CHARINDEX('@', Email) - 1) AS EmailUsername,
    REVERSE(FirstName) AS ReversedFirst
FROM dbo.Customers;
```

**Output (sample):**

| CustomerID | FullNameUpper  | EmailLength | EmailUsername | ReversedFirst |
| ---------- | -------------- | ----------- | ------------- | ------------- |
| 1          | ALICE JOHNSON  | 15          | alice         | ecilA         |
| 2          | BOB SMITH      | 13          | bob           | boB           |
| 3          | CHARLIE LEE    | 17          | charlie       | eilrahC       |

#### CONCAT vs + Operator

```sql
-- The + operator returns NULL if any operand is NULL
SELECT 'Name: ' + NULL + 'Test';           -- Result: NULL

-- CONCAT treats NULL as empty string
SELECT CONCAT('Name: ', NULL, 'Test');      -- Result: 'Name: Test'

-- CONCAT_WS skips NULL values
SELECT CONCAT_WS(', ', 'Alice', NULL, 'New York', NULL, 'USA');
-- Result: 'Alice, New York, USA'
```

#### STRING_AGG — Aggregate Strings

```sql
-- List all product names per category, comma-separated
SELECT
    c.CategoryName,
    STRING_AGG(p.ProductName, ', ') AS ProductList
FROM dbo.Products p
JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName;
```

| CategoryName    | ProductList                                                          |
| --------------- | -------------------------------------------------------------------- |
| Electronics     | Laptop Pro 15, Wireless Mouse, USB-C Hub, Mechanical Keyboard, ...   |
| Clothing        | Cotton T-Shirt, Denim Jeans, Winter Jacket, Running Shoes            |
| Books           | SQL in 24 Hours, Clean Code, Design Patterns                         |
| Home & Kitchen  | Coffee Maker, Blender Pro, Air Fryer                                 |
| Sports          | Yoga Mat, Dumbbell Set, Basketball                                   |

---

### 3.2 Date & Time Functions

| Function                       | Description                             | Example Output              |
| ------------------------------ | --------------------------------------- | --------------------------- |
| `GETDATE()`                    | Current date/time (datetime)            | `2025-03-28 14:30:15.123`  |
| `SYSDATETIME()`                | Current date/time (datetime2, precise)  | `2025-03-28 14:30:15.1234567` |
| `GETUTCDATE()`                 | Current UTC date/time                   | `2025-03-28 19:30:15.123`  |
| `YEAR(date)`                   | Extract year                            | `YEAR('2025-03-28')` → 2025|
| `MONTH(date)`                  | Extract month                           | `MONTH('2025-03-28')` → 3  |
| `DAY(date)`                    | Extract day                             | `DAY('2025-03-28')` → 28   |
| `DATEPART(part, date)`         | Extract a specific part                 | `DATEPART(WEEKDAY, GETDATE())` |
| `DATENAME(part, date)`         | Part name as string                     | `DATENAME(MONTH, '2025-03-28')` → `'March'` |
| `DATEADD(part, n, date)`       | Add n units to a date                   | `DATEADD(DAY, 7, '2025-03-28')` → `'2025-04-04'` |
| `DATEDIFF(part, start, end)`   | Difference between two dates            | `DATEDIFF(DAY, '2025-03-01', '2025-03-28')` → 27 |
| `EOMONTH(date)`                | Last day of the month                   | `EOMONTH('2025-03-15')` → `'2025-03-31'` |
| `ISDATE(expr)`                 | Returns 1 if valid date, else 0         | `ISDATE('2025-13-01')` → 0 |
| `FORMAT(date, fmt)`            | Format date as string                   | `FORMAT(GETDATE(), 'yyyy-MM-dd')` |

#### Date Functions in Action

```sql
-- How long has each customer been a member?
SELECT
    FirstName,
    LastName,
    JoinDate,
    DATEDIFF(DAY, JoinDate, GETDATE())   AS DaysSinceJoin,
    DATEDIFF(MONTH, JoinDate, GETDATE()) AS MonthsSinceJoin,
    DATEADD(YEAR, 1, JoinDate)           AS OneYearAnniversary,
    DATENAME(WEEKDAY, JoinDate)          AS JoinDayOfWeek
FROM dbo.Customers
ORDER BY JoinDate;
```

#### Finding Orders by Date Range

```sql
-- Orders placed in March 2025
SELECT *
FROM dbo.Orders
WHERE OrderDate >= '2025-03-01'
  AND OrderDate <  '2025-04-01';

-- Alternative using YEAR and MONTH functions
SELECT *
FROM dbo.Orders
WHERE YEAR(OrderDate) = 2025
  AND MONTH(OrderDate) = 3;
```

> **Performance tip:** The first approach (range comparison) is **sargable** —
> it can use indexes. The second approach wraps the column in a function,
> which may prevent index usage.

#### Grouping by Month

```sql
SELECT
    FORMAT(OrderDate, 'yyyy-MM')    AS OrderMonth,
    COUNT(*)                        AS TotalOrders
FROM dbo.Orders
GROUP BY FORMAT(OrderDate, 'yyyy-MM')
ORDER BY OrderMonth;
```

| OrderMonth | TotalOrders |
| ---------- | ----------- |
| 2025-01    | 2           |
| 2025-02    | 2           |
| 2025-03    | 8           |

---

### 3.3 Mathematical Functions

| Function              | Description                  | Example                        |
| --------------------- | ---------------------------- | ------------------------------ |
| `ABS(n)`              | Absolute value               | `ABS(-42)` → 42               |
| `CEILING(n)`          | Round up to nearest integer  | `CEILING(4.2)` → 5            |
| `FLOOR(n)`            | Round down to nearest integer| `FLOOR(4.8)` → 4              |
| `ROUND(n, d)`         | Round to d decimal places    | `ROUND(3.14159, 2)` → 3.14    |
| `POWER(base, exp)`    | Exponentiation               | `POWER(2, 10)` → 1024         |
| `SQRT(n)`             | Square root                  | `SQRT(144)` → 12              |
| `SIGN(n)`             | Returns -1, 0, or 1          | `SIGN(-42)` → -1              |
| `RAND()`              | Random float 0–1             | `RAND()` → 0.7134...          |
| `PI()`                | Value of π                   | `PI()` → 3.14159265358979     |
| `LOG(n)` / `LOG10(n)` | Natural / base-10 logarithm | `LOG10(1000)` → 3             |

```sql
-- Pricing calculations
SELECT
    ProductName,
    Price,
    ROUND(Price * 1.08, 2)                AS PriceWithTax,
    CEILING(Price)                         AS RoundedUp,
    FLOOR(Price)                           AS RoundedDown,
    ROUND(Price * 0.85, 2)                AS DiscountedPrice
FROM dbo.Products
WHERE CategoryID = 1;
```

| ProductName             | Price   | PriceWithTax | RoundedUp | RoundedDown | DiscountedPrice |
| ----------------------- | ------- | ------------ | --------- | ----------- | --------------- |
| Laptop Pro 15           | 1299.99 | 1403.99      | 1300      | 1299        | 1104.99         |
| Wireless Mouse          | 29.99   | 32.39        | 30        | 29          | 25.49           |
| USB-C Hub               | 49.99   | 53.99        | 50        | 49          | 42.49           |
| Mechanical Keyboard     | 89.99   | 97.19        | 90        | 89          | 76.49           |
| Noise-Cancel Headphones | 249.99  | 269.99       | 250       | 249         | 212.49          |

---

### 3.4 Conversion Functions

| Function                       | Purpose                                          |
| ------------------------------ | ------------------------------------------------ |
| `CAST(expr AS type)`           | Standard SQL type conversion                     |
| `CONVERT(type, expr [, style])`| SQL Server-specific, supports format styles      |
| `TRY_CAST(expr AS type)`      | Returns NULL instead of error on failure          |
| `TRY_CONVERT(type, expr)`     | Returns NULL instead of error on failure          |
| `PARSE(str AS type [USING culture])` | Parse string using .NET culture settings    |
| `TRY_PARSE(str AS type)`      | Returns NULL instead of error on failure          |
| `STR(float, length, decimal)` | Convert float to string                          |

```sql
-- CAST examples
SELECT CAST(42 AS VARCHAR(10))           AS IntToString;    -- '42'
SELECT CAST('2025-03-28' AS DATE)        AS StringToDate;   -- 2025-03-28
SELECT CAST(3.14159 AS DECIMAL(4,2))     AS RoundedDecimal; -- 3.14

-- CONVERT with style codes for dates
SELECT CONVERT(VARCHAR(10), GETDATE(), 101) AS US_Format;     -- 03/28/2025
SELECT CONVERT(VARCHAR(10), GETDATE(), 103) AS UK_Format;     -- 28/03/2025
SELECT CONVERT(VARCHAR(10), GETDATE(), 120) AS ISO_Format;    -- 2025-03-28
SELECT CONVERT(VARCHAR(10), GETDATE(), 104) AS German_Format; -- 28.03.2025

-- TRY_CAST — safe conversion
SELECT TRY_CAST('Hello' AS INT)          AS Result;  -- NULL (no error)
SELECT TRY_CAST('42' AS INT)             AS Result;  -- 42
```

#### Common CONVERT Style Codes for Dates

| Code | Format              | Example           |
| ---- | ------------------- | ----------------- |
| 101  | MM/DD/YYYY          | 03/28/2025        |
| 103  | DD/MM/YYYY          | 28/03/2025        |
| 104  | DD.MM.YYYY          | 28.03.2025        |
| 110  | MM-DD-YYYY          | 03-28-2025        |
| 120  | YYYY-MM-DD HH:MI:SS| 2025-03-28 14:30:15 |
| 126  | ISO 8601            | 2025-03-28T14:30:15.123 |

---

### 3.5 NULL-Handling Functions

| Function                        | Purpose                                       |
| ------------------------------- | --------------------------------------------- |
| `ISNULL(expr, replacement)`     | Replace NULL with a value (SQL Server only)   |
| `COALESCE(expr1, expr2, …)`    | Return first non-NULL expression              |
| `NULLIF(expr1, expr2)`         | Return NULL if both expressions are equal     |

```sql
-- ISNULL: replace NULL city with 'Unknown'
SELECT
    FirstName,
    ISNULL(City, N'Unknown') AS City
FROM dbo.Customers;

-- COALESCE: check multiple columns for a usable value
SELECT
    COALESCE(City, Country, N'No Location') AS Location
FROM dbo.Customers;

-- NULLIF: return NULL when two values match (useful to avoid division by zero)
SELECT
    ProductName,
    Price,
    Stock,
    Price / NULLIF(Stock, 0) AS PricePerUnit
FROM dbo.Products;
```

#### Avoiding Division by Zero

```sql
-- Without NULLIF — error if Stock = 0:
SELECT 100.00 / 0;  -- Error: Divide by zero

-- With NULLIF — returns NULL instead of error:
SELECT 100.00 / NULLIF(0, 0);  -- Result: NULL

-- In a real query:
SELECT
    ProductName,
    Price,
    Stock,
    ISNULL(Price / NULLIF(Stock, 0), 0) AS PricePerUnit
FROM dbo.Products;
```

---

### 3.6 Aggregate Functions

| Function       | Description              |
| -------------- | ------------------------ |
| `COUNT(*)`     | Count all rows           |
| `COUNT(col)`   | Count non-NULL values    |
| `SUM(col)`     | Sum of values            |
| `AVG(col)`     | Average of values        |
| `MIN(col)`     | Minimum value            |
| `MAX(col)`     | Maximum value            |
| `STDEV(col)`   | Standard deviation       |
| `VAR(col)`     | Variance                 |

```sql
-- Overall product statistics
SELECT
    COUNT(*)           AS TotalProducts,
    COUNT(CategoryID)  AS ProductsWithCategory,
    SUM(Stock)         AS TotalInventory,
    AVG(Price)         AS AvgPrice,
    MIN(Price)         AS CheapestProduct,
    MAX(Price)         AS MostExpensive,
    ROUND(STDEV(Price), 2) AS PriceStdDev
FROM dbo.Products;
```

| TotalProducts | ProductsWithCategory | TotalInventory | AvgPrice | CheapestProduct | MostExpensive | PriceStdDev |
| ------------- | -------------------- | -------------- | -------- | --------------- | ------------- | ----------- |
| 18            | 18                   | 2330           | 163.87   | 19.99           | 1299.99       | 295.54      |

> **Note:** `COUNT(*)` counts all rows including NULLs.
> `COUNT(column)` counts only non-NULL values.

---

### 3.7 Ranking / Window Functions (Preview)

A quick look — we'll use these more in Day 3:

```sql
-- Rank products by price within each category
SELECT
    ProductName,
    CategoryID,
    Price,
    ROW_NUMBER() OVER (PARTITION BY CategoryID ORDER BY Price DESC) AS RowNum,
    RANK()       OVER (PARTITION BY CategoryID ORDER BY Price DESC) AS PriceRank,
    DENSE_RANK() OVER (PARTITION BY CategoryID ORDER BY Price DESC) AS DenseRank
FROM dbo.Products;
```

---

## 4. Advanced SELECT Queries

### 4.1 SELECT with Expressions

```sql
-- Calculated columns
SELECT
    ProductName,
    Price,
    Stock,
    Price * Stock                          AS InventoryValue,
    ROUND(Price * 1.08, 2)                AS PriceWithTax,
    CONCAT(ProductName, ' ($', Price, ')') AS DisplayName
FROM dbo.Products
ORDER BY InventoryValue DESC;
```

### 4.2 DISTINCT

```sql
-- Unique countries
SELECT DISTINCT Country
FROM dbo.Customers
ORDER BY Country;

-- Unique combinations
SELECT DISTINCT City, Country
FROM dbo.Customers
ORDER BY Country, City;
```

### 4.3 TOP and TOP WITH TIES

```sql
-- Top 5 most expensive products
SELECT TOP 5
    ProductName, Price
FROM dbo.Products
ORDER BY Price DESC;

-- TOP with PERCENT
SELECT TOP 10 PERCENT
    ProductName, Price
FROM dbo.Products
ORDER BY Price DESC;

-- TOP WITH TIES: include all rows that tie with the last row
SELECT TOP 5 WITH TIES
    ProductName, Price
FROM dbo.Products
ORDER BY Price DESC;
```

### 4.4 OFFSET-FETCH (Pagination)

```sql
-- Page 1: rows 1-5
SELECT ProductName, Price
FROM dbo.Products
ORDER BY Price DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- Page 2: rows 6-10
SELECT ProductName, Price
FROM dbo.Products
ORDER BY Price DESC
OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;

-- Page 3: rows 11-15
SELECT ProductName, Price
FROM dbo.Products
ORDER BY Price DESC
OFFSET 10 ROWS FETCH NEXT 5 ROWS ONLY;
```

### 4.5 GROUP BY

`GROUP BY` collapses rows into groups and lets you apply aggregate functions.

```sql
-- Total products and average price per category
SELECT
    c.CategoryName,
    COUNT(p.ProductID)       AS ProductCount,
    ROUND(AVG(p.Price), 2)   AS AvgPrice,
    SUM(p.Stock)             AS TotalStock
FROM dbo.Products p
JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY ProductCount DESC;
```

| CategoryName    | ProductCount | AvgPrice | TotalStock |
| --------------- | ------------ | -------- | ---------- |
| Electronics     | 5            | 343.99   | 595        |
| Clothing        | 4            | 77.49    | 1100       |
| Books           | 3            | 39.99    | 185        |
| Home & Kitchen  | 3            | 88.32    | 270        |
| Sports          | 3            | 38.32    | 480        |

#### GROUP BY with Multiple Columns

```sql
-- Orders per customer per status
SELECT
    cu.FirstName,
    cu.LastName,
    o.Status,
    COUNT(o.OrderID) AS OrderCount
FROM dbo.Orders o
JOIN dbo.Customers cu ON o.CustomerID = cu.CustomerID
GROUP BY cu.FirstName, cu.LastName, o.Status
ORDER BY cu.LastName, o.Status;
```

### 4.6 HAVING

`HAVING` filters **groups** (after aggregation). `WHERE` filters **rows**
(before aggregation).

```sql
-- Categories with an average price above $50
SELECT
    c.CategoryName,
    COUNT(p.ProductID)     AS ProductCount,
    ROUND(AVG(p.Price), 2) AS AvgPrice
FROM dbo.Products p
JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
HAVING AVG(p.Price) > 50
ORDER BY AvgPrice DESC;
```

| CategoryName    | ProductCount | AvgPrice |
| --------------- | ------------ | -------- |
| Electronics     | 5            | 343.99   |
| Home & Kitchen  | 3            | 88.32    |
| Clothing        | 4            | 77.49    |

#### WHERE vs HAVING — Side by Side

```sql
-- WHERE: filter BEFORE grouping (only active products)
-- HAVING: filter AFTER grouping (only categories with 3+ products)
SELECT
    c.CategoryName,
    COUNT(p.ProductID) AS ActiveProducts
FROM dbo.Products p
JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
WHERE p.IsActive = 1              -- row-level filter (before grouping)
GROUP BY c.CategoryName
HAVING COUNT(p.ProductID) >= 3    -- group-level filter (after grouping)
ORDER BY ActiveProducts DESC;
```

### 4.7 ORDER BY

```sql
-- Single column, descending
SELECT ProductName, Price
FROM dbo.Products
ORDER BY Price DESC;

-- Multiple columns
SELECT FirstName, LastName, City, Country
FROM dbo.Customers
ORDER BY Country ASC, City ASC, LastName ASC;

-- Order by column position (not recommended for readability)
SELECT ProductName, Price, Stock
FROM dbo.Products
ORDER BY 2 DESC;   -- 2 = Price (second column)

-- Order by expression
SELECT
    ProductName,
    Price * Stock AS InventoryValue
FROM dbo.Products
ORDER BY Price * Stock DESC;

-- Order by alias
SELECT
    ProductName,
    Price * Stock AS InventoryValue
FROM dbo.Products
ORDER BY InventoryValue DESC;
```

### 4.8 Combining Everything: A Complex SELECT

```sql
-- Top 5 customers by total spending (only delivered orders, minimum $100 spend)
SELECT TOP 5
    c.FirstName + N' ' + c.LastName         AS CustomerName,
    c.City,
    c.Country,
    COUNT(DISTINCT o.OrderID)               AS OrderCount,
    SUM(oi.Quantity * oi.UnitPrice)         AS TotalSpent,
    ROUND(AVG(oi.Quantity * oi.UnitPrice), 2) AS AvgItemValue,
    MIN(o.OrderDate)                        AS FirstOrder,
    MAX(o.OrderDate)                        AS LastOrder
FROM dbo.Customers c
JOIN dbo.Orders o      ON c.CustomerID = o.CustomerID
JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
WHERE o.Status = N'Delivered'                      -- row filter
GROUP BY c.FirstName, c.LastName, c.City, c.Country
HAVING SUM(oi.Quantity * oi.UnitPrice) >= 100      -- group filter
ORDER BY TotalSpent DESC;                          -- sort
```

### 4.9 Logical Processing Order of a SELECT

Understanding the order SQL Server **processes** clauses is critical:

```
1. FROM        ← identify the tables
2. WHERE       ← filter rows
3. GROUP BY    ← create groups
4. HAVING      ← filter groups
5. SELECT      ← choose columns / compute expressions
6. DISTINCT    ← remove duplicates
7. ORDER BY    ← sort results
8. TOP / OFFSET-FETCH ← limit rows
```

> **Key insight:** This is why you **can't** reference a column alias defined
> in `SELECT` from the `WHERE` or `GROUP BY` clause — `SELECT` runs after them!

```sql
-- ❌ This fails:
SELECT Price * Stock AS InventoryValue
FROM dbo.Products
WHERE InventoryValue > 1000;   -- Error: alias not yet defined

-- ✅ Correct approach:
SELECT Price * Stock AS InventoryValue
FROM dbo.Products
WHERE Price * Stock > 1000;    -- repeat the expression
```

---

## 5. Advanced DML Statements

### 5.1 INSERT — Advanced Patterns

#### INSERT with DEFAULT VALUES

```sql
-- Insert a row using only default values
CREATE TABLE dbo.AuditLog (
    LogID       INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    LogMessage  NVARCHAR(200) NOT NULL DEFAULT N'System event',
    LogDate     DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);

INSERT INTO dbo.AuditLog DEFAULT VALUES;

SELECT * FROM dbo.AuditLog;
-- LogID: 1, LogMessage: 'System event', LogDate: (current timestamp)
```

#### INSERT INTO … SELECT

```sql
-- Archive delivered orders into a history table
CREATE TABLE dbo.OrderHistory (
    OrderID      INT,
    CustomerID   INT,
    OrderDate    DATETIME2,
    Status       NVARCHAR(20),
    ArchivedDate DATETIME2 DEFAULT SYSDATETIME()
);

INSERT INTO dbo.OrderHistory (OrderID, CustomerID, OrderDate, Status)
SELECT OrderID, CustomerID, OrderDate, Status
FROM dbo.Orders
WHERE Status = N'Delivered';
```

#### INSERT with OUTPUT

The `OUTPUT` clause lets you capture the inserted/deleted rows:

```sql
-- Insert a new product and capture the generated ID
DECLARE @InsertedProducts TABLE (NewProductID INT, ProductName NVARCHAR(100));

INSERT INTO dbo.Products (ProductName, CategoryID, Price, Stock)
OUTPUT inserted.ProductID, inserted.ProductName INTO @InsertedProducts
VALUES (N'Smart Watch', 1, 199.99, 30);

SELECT * FROM @InsertedProducts;
-- NewProductID: 19, ProductName: Smart Watch
```

### 5.2 UPDATE — Advanced Patterns

#### UPDATE with JOIN

```sql
-- Increase the price of all products that have been ordered more than 5 times
UPDATE p
SET p.Price = ROUND(p.Price * 1.10, 2)  -- 10% increase
FROM dbo.Products p
JOIN (
    SELECT ProductID, SUM(Quantity) AS TotalOrdered
    FROM dbo.OrderItems
    GROUP BY ProductID
    HAVING SUM(Quantity) > 5
) AS popular ON p.ProductID = popular.ProductID;
```

#### UPDATE with OUTPUT

```sql
-- Track what changed during an update
DECLARE @PriceChanges TABLE (
    ProductID   INT,
    OldPrice    DECIMAL(10,2),
    NewPrice    DECIMAL(10,2)
);

UPDATE dbo.Products
SET Price = ROUND(Price * 0.90, 2)       -- 10% discount
OUTPUT
    deleted.ProductID,
    deleted.Price,
    inserted.Price
INTO @PriceChanges
WHERE CategoryID = 3;                     -- Books only

SELECT * FROM @PriceChanges;
```

| ProductID | OldPrice | NewPrice |
| --------- | -------- | -------- |
| 10        | 34.99    | 31.49    |
| 11        | 39.99    | 35.99    |
| 12        | 44.99    | 40.49    |

#### UPDATE with CASE

```sql
-- Different discount rates based on stock levels
UPDATE dbo.Products
SET Price = CASE
    WHEN Stock > 200 THEN ROUND(Price * 0.80, 2)  -- 20% off (overstocked)
    WHEN Stock > 100 THEN ROUND(Price * 0.90, 2)  -- 10% off
    ELSE Price                                      -- no change
END;
```

### 5.3 DELETE — Advanced Patterns

#### DELETE with JOIN

```sql
-- Delete order items for cancelled orders
DELETE oi
FROM dbo.OrderItems oi
JOIN dbo.Orders o ON oi.OrderID = o.OrderID
WHERE o.Status = N'Cancelled';
```

#### DELETE with OUTPUT

```sql
-- Capture deleted records for auditing
DECLARE @DeletedItems TABLE (
    OrderItemID INT,
    OrderID     INT,
    ProductID   INT,
    Quantity    INT
);

DELETE FROM dbo.OrderItems
OUTPUT
    deleted.OrderItemID,
    deleted.OrderID,
    deleted.ProductID,
    deleted.Quantity
INTO @DeletedItems
WHERE OrderID IN (SELECT OrderID FROM dbo.Orders WHERE Status = N'Cancelled');

SELECT * FROM @DeletedItems;
```

#### DELETE with TOP

```sql
-- Delete the 10 oldest delivered orders (for archival cleanup)
DELETE TOP (10) FROM dbo.Orders
WHERE Status = N'Delivered'
  AND OrderDate < '2024-01-01';
```

---

## 6. Other T-SQL Statements

### 6.1 TRUNCATE TABLE

```sql
-- Remove ALL rows — fast, minimal logging, resets identity
TRUNCATE TABLE dbo.AuditLog;
```

| Feature         | TRUNCATE                    | DELETE (no WHERE)            |
| --------------- | --------------------------- | ---------------------------- |
| Speed           | Very fast                   | Slower                       |
| Logging         | Minimal (page deallocation) | Full (row-by-row)            |
| WHERE clause    | ❌ Not supported            | ✅ Supported                 |
| Identity reset  | ✅ Yes                      | ❌ No                        |
| Triggers        | ❌ Not fired                | ✅ Fires DELETE triggers     |
| FK referenced   | ❌ Can't truncate           | ✅ Can delete if no FK violation |

### 6.2 MERGE Statement

`MERGE` combines INSERT, UPDATE, and DELETE in a single statement — often
called an **"upsert"**.

#### Scenario: Sync Product Prices from a Staging Table

```sql
-- Create a staging table with updated prices
CREATE TABLE dbo.StagingProducts (
    ProductID   INT,
    ProductName NVARCHAR(100),
    Price       DECIMAL(10,2)
);

INSERT INTO dbo.StagingProducts VALUES
    (1,  N'Laptop Pro 15',    1349.99),  -- price change
    (2,  N'Wireless Mouse',     29.99),  -- no change
    (99, N'VR Headset',        399.99);  -- new product (doesn't exist)
GO

-- MERGE: sync staging → products
MERGE dbo.Products AS target
USING dbo.StagingProducts AS source
ON target.ProductID = source.ProductID

-- Match found: update if price changed
WHEN MATCHED AND target.Price <> source.Price THEN
    UPDATE SET target.Price = source.Price

-- No match in target: insert new product
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductName, CategoryID, Price, Stock)
    VALUES (source.ProductName, 1, source.Price, 0)

-- Optional: delete from target if not in source
-- WHEN NOT MATCHED BY SOURCE THEN
--     DELETE

-- OUTPUT what happened
OUTPUT
    $action AS MergeAction,
    COALESCE(inserted.ProductID, deleted.ProductID) AS ProductID,
    inserted.ProductName,
    deleted.Price AS OldPrice,
    inserted.Price AS NewPrice;
```

**Output:**

| MergeAction | ProductID | ProductName     | OldPrice | NewPrice |
| ----------- | --------- | --------------- | -------- | -------- |
| UPDATE      | 1         | Laptop Pro 15   | 1299.99  | 1349.99  |
| INSERT      | 19        | VR Headset      | NULL     | 399.99   |

> **Important:** Always end a MERGE statement with a **semicolon (`;`)**.

### 6.3 SELECT INTO

Creates a **new table** from the results of a query:

```sql
-- Create a backup of the Products table
SELECT *
INTO dbo.Products_Backup
FROM dbo.Products;

-- Create a filtered copy
SELECT ProductID, ProductName, Price
INTO dbo.ExpensiveProducts
FROM dbo.Products
WHERE Price > 100;

-- Verify
SELECT * FROM dbo.ExpensiveProducts;
```

> **Note:** `SELECT INTO` copies data and column definitions but does **not**
> copy constraints, indexes, or triggers.

### 6.4 INSERT INTO … EXEC

Execute a stored procedure and insert results into a table:

```sql
-- Insert results of a stored procedure into a table
CREATE TABLE dbo.TempResults (
    DatabaseName NVARCHAR(128)
);

INSERT INTO dbo.TempResults
EXEC sp_databases;

SELECT * FROM dbo.TempResults;
```

---

## 7. Set Operators

Set operators combine results from two or more SELECT statements.

### 7.1 Rules for Set Operators

1. All queries must have the **same number of columns**.
2. Corresponding columns must have **compatible data types**.
3. Column names come from the **first** query.

### 7.2 UNION vs UNION ALL

```
UNION     = Combine + Remove duplicates  (slower — requires sort)
UNION ALL = Combine + Keep duplicates    (faster — no sort needed)
```

#### Example: Combine customer cities and order statuses (for demonstration)

```sql
-- All unique cities from customers and a static list
SELECT City AS Location FROM dbo.Customers WHERE City IS NOT NULL
UNION
SELECT N'Houston'
UNION
SELECT N'New York';   -- Already exists — will be deduplicated
```

```sql
-- Same but keeping duplicates
SELECT City AS Location FROM dbo.Customers WHERE City IS NOT NULL
UNION ALL
SELECT N'Houston'
UNION ALL
SELECT N'New York';   -- Will appear twice
```

#### Practical Example: Combine Active and Archived Orders

```sql
-- Current orders
SELECT OrderID, CustomerID, OrderDate, Status, 'Current' AS Source
FROM dbo.Orders

UNION ALL

-- Archived orders
SELECT OrderID, CustomerID, OrderDate, Status, 'Archive' AS Source
FROM dbo.OrderHistory;
```

### 7.3 INTERSECT

Returns rows that appear in **both** result sets:

```sql
-- Customers who have placed both 'Delivered' and 'Pending' orders
SELECT CustomerID
FROM dbo.Orders
WHERE Status = N'Delivered'

INTERSECT

SELECT CustomerID
FROM dbo.Orders
WHERE Status = N'Pending';
```

### 7.4 EXCEPT

Returns rows from the **first** result set that are **not** in the second:

```sql
-- Customers who have placed orders but NEVER had a delivery
SELECT CustomerID
FROM dbo.Orders

EXCEPT

SELECT CustomerID
FROM dbo.Orders
WHERE Status = N'Delivered';
```

### 7.5 Set Operators Visualized

```
Table A          Table B
┌───┐            ┌───┐
│ 1 │            │ 2 │
│ 2 │            │ 3 │
│ 3 │            │ 4 │
└───┘            └───┘

A UNION B        → {1, 2, 3, 4}       (all unique)
A UNION ALL B    → {1, 2, 3, 2, 3, 4} (all rows, with dupes)
A INTERSECT B    → {2, 3}             (in both)
A EXCEPT B       → {1}               (in A but not B)
B EXCEPT A       → {4}               (in B but not A)
```

### 7.6 Combining Set Operators

You can chain multiple set operators. Use parentheses to control order:

```sql
-- Products ordered in January BUT NOT in February, PLUS all products in the Sports category
(
    SELECT DISTINCT oi.ProductID
    FROM dbo.OrderItems oi
    JOIN dbo.Orders o ON oi.OrderID = o.OrderID
    WHERE MONTH(o.OrderDate) = 1

    EXCEPT

    SELECT DISTINCT oi.ProductID
    FROM dbo.OrderItems oi
    JOIN dbo.Orders o ON oi.OrderID = o.OrderID
    WHERE MONTH(o.OrderDate) = 2
)
UNION
(
    SELECT ProductID
    FROM dbo.Products
    WHERE CategoryID = 5
);
```

### 7.7 Set Operators vs JOINs

| Feature              | Set Operators           | JOINs                           |
| -------------------- | ----------------------- | ------------------------------- |
| Combine how?         | Vertically (stack rows) | Horizontally (add columns)      |
| Column requirement   | Same count & types      | Related via keys/conditions     |
| Duplicates           | UNION removes them      | JOINs can produce them          |
| Use case             | Merge similar datasets  | Combine related data            |

```
Set Operators (vertical):          JOINs (horizontal):

 ┌────────┐                        ┌────────┬────────┐
 │ Query1 │                        │ TableA │ TableB │
 ├────────┤                        │  col1  │  col1  │
 │ Query2 │                        │  col2  │  col2  │
 └────────┘                        └────────┴────────┘
```

---

## 8. Day 2 Summary

### What We Covered

| Topic                    | Key Takeaway                                                 |
| ------------------------ | ------------------------------------------------------------ |
| Variables                | `DECLARE @var TYPE; SET @var = value;`                       |
| Control Flow             | `IF…ELSE`, `WHILE`, `BEGIN…END`                              |
| CASE                     | Conditional logic in queries (Simple & Searched)             |
| String Functions         | `LEN`, `SUBSTRING`, `REPLACE`, `CONCAT`, `STRING_AGG`, etc. |
| Date Functions           | `DATEADD`, `DATEDIFF`, `FORMAT`, `EOMONTH`, etc.            |
| Math Functions           | `ROUND`, `CEILING`, `FLOOR`, `ABS`, `POWER`, etc.           |
| Conversion               | `CAST`, `CONVERT`, `TRY_CAST` — always prefer safe versions |
| NULL Handling            | `ISNULL`, `COALESCE`, `NULLIF` — avoid NULL surprises       |
| Aggregates               | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`                         |
| GROUP BY & HAVING        | Group rows, filter groups                                    |
| ORDER BY & Pagination    | Sort results, `OFFSET-FETCH` for paging                     |
| Advanced INSERT          | `INSERT…SELECT`, `OUTPUT`, `DEFAULT VALUES`                  |
| Advanced UPDATE          | `UPDATE…JOIN`, `OUTPUT`, `CASE`                              |
| Advanced DELETE          | `DELETE…JOIN`, `OUTPUT`, `TOP`                               |
| TRUNCATE                 | Fast table wipe, resets identity                             |
| MERGE                    | Upsert: INSERT + UPDATE + DELETE in one statement            |
| SELECT INTO              | Create new table from query results                          |
| Set Operators            | `UNION`, `UNION ALL`, `INTERSECT`, `EXCEPT`                  |

### Key Decision Tree

```
Need to combine data?
│
├── From DIFFERENT tables, RELATED by keys?
│   └── Use JOINs (Day 3)
│
├── From SIMILAR structures, stack vertically?
│   ├── Remove duplicates? ──────> UNION
│   ├── Keep duplicates? ────────> UNION ALL
│   ├── Only common rows? ──────> INTERSECT
│   └── Rows in A but not B? ──> EXCEPT
│
└── From the SAME table, conditional logic?
    └── Use CASE / IIF / CHOOSE
```

### Logical Processing Order (Reminder)

```
1. FROM        ← source tables
2. WHERE       ← filter rows
3. GROUP BY    ← create groups
4. HAVING      ← filter groups
5. SELECT      ← columns, expressions, aliases
6. DISTINCT    ← deduplicate
7. ORDER BY    ← sort
8. TOP / OFFSET-FETCH ← limit
```

---

## 9. Hands-On Exercises

### Exercise 1: String Manipulation

Using the `RetailDB` database, write queries to:

1. Display each customer's full name in the format `"LAST, First"` (e.g., `"JOHNSON, Alice"`).
2. Extract the domain from each customer's email (everything after `@`).
3. Create a "username" for each customer: first letter of first name + full last name, all lowercase (e.g., `ajohnson`).
4. List all products whose name contains more than 2 words.
5. Produce a single comma-separated string of all customer cities (no duplicates).

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. LAST, First format
SELECT
    UPPER(LastName) + N', ' + FirstName AS FormattedName
FROM dbo.Customers;

-- 2. Email domain
SELECT
    Email,
    SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS Domain
FROM dbo.Customers;

-- 3. Username: first letter + last name, lowercase
SELECT
    LOWER(LEFT(FirstName, 1) + LastName) AS Username
FROM dbo.Customers;

-- 4. Products with more than 2 words
-- (count spaces: if there are 2+ spaces, there are 3+ words)
SELECT ProductName
FROM dbo.Products
WHERE LEN(ProductName) - LEN(REPLACE(ProductName, ' ', '')) >= 2;

-- 5. All unique cities, comma-separated
SELECT STRING_AGG(City, ', ')
FROM (SELECT DISTINCT City FROM dbo.Customers WHERE City IS NOT NULL) AS UniqueCities;
```

</details>

---

### Exercise 2: Date Calculations

1. For each customer, calculate how many days they have been a member.
2. Find the customer who has been a member the longest.
3. List all orders placed on a weekend (Saturday or Sunday).
4. For each order, show the order date and what date it would be if shipping takes 5 business days (just add 7 calendar days as a simplification).
5. Show orders grouped by the day of the week, with a count per day.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Days as member
SELECT
    FirstName,
    LastName,
    JoinDate,
    DATEDIFF(DAY, JoinDate, GETDATE()) AS DaysAsMember
FROM dbo.Customers
ORDER BY DaysAsMember DESC;

-- 2. Longest member
SELECT TOP 1
    FirstName, LastName, JoinDate,
    DATEDIFF(DAY, JoinDate, GETDATE()) AS DaysAsMember
FROM dbo.Customers
ORDER BY JoinDate ASC;

-- 3. Weekend orders
SELECT OrderID, OrderDate, DATENAME(WEEKDAY, OrderDate) AS DayName
FROM dbo.Orders
WHERE DATEPART(WEEKDAY, OrderDate) IN (1, 7);  -- 1=Sunday, 7=Saturday (default setting)

-- 4. Estimated delivery date (+7 days)
SELECT
    OrderID,
    OrderDate,
    DATEADD(DAY, 7, OrderDate) AS EstimatedDelivery
FROM dbo.Orders;

-- 5. Orders by day of week
SELECT
    DATENAME(WEEKDAY, OrderDate) AS DayOfWeek,
    COUNT(*) AS OrderCount
FROM dbo.Orders
GROUP BY DATENAME(WEEKDAY, OrderDate), DATEPART(WEEKDAY, OrderDate)
ORDER BY DATEPART(WEEKDAY, OrderDate);
```

</details>

---

### Exercise 3: Aggregation Challenges

1. Find the total revenue (Quantity × UnitPrice) per order.
2. Find the average order value (total revenue per order, then average across all orders).
3. Which category has the highest total inventory value (Price × Stock)?
4. Find customers who have placed more than 1 order.
5. Find the month with the highest number of orders.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Revenue per order
SELECT
    OrderID,
    SUM(Quantity * UnitPrice) AS OrderRevenue
FROM dbo.OrderItems
GROUP BY OrderID
ORDER BY OrderRevenue DESC;

-- 2. Average order value
SELECT
    ROUND(AVG(OrderTotal), 2) AS AvgOrderValue
FROM (
    SELECT OrderID, SUM(Quantity * UnitPrice) AS OrderTotal
    FROM dbo.OrderItems
    GROUP BY OrderID
) AS OrderTotals;

-- 3. Category with highest inventory value
SELECT TOP 1
    c.CategoryName,
    SUM(p.Price * p.Stock) AS TotalInventoryValue
FROM dbo.Products p
JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY TotalInventoryValue DESC;

-- 4. Customers with more than 1 order
SELECT
    cu.FirstName,
    cu.LastName,
    COUNT(o.OrderID) AS OrderCount
FROM dbo.Customers cu
JOIN dbo.Orders o ON cu.CustomerID = o.CustomerID
GROUP BY cu.FirstName, cu.LastName
HAVING COUNT(o.OrderID) > 1
ORDER BY OrderCount DESC;

-- 5. Month with most orders
SELECT TOP 1
    FORMAT(OrderDate, 'yyyy-MM') AS OrderMonth,
    COUNT(*) AS OrderCount
FROM dbo.Orders
GROUP BY FORMAT(OrderDate, 'yyyy-MM')
ORDER BY OrderCount DESC;
```

</details>

---

### Exercise 4: Advanced DML

1. Create a table `dbo.ProductPriceHistory` with columns: HistoryID (identity), ProductID, OldPrice, NewPrice, ChangeDate (default now).
2. Write an UPDATE that increases all Electronics prices by 5%, capturing the changes into `ProductPriceHistory` using the OUTPUT clause.
3. Write a MERGE that:
   - Updates the price of ProductID 2 to $32.99
   - Inserts a new product: "Tablet Pro" with CategoryID 1, Price $599.99, Stock 40
   - Use a table variable as the source.
4. Use SELECT INTO to create a `dbo.OrderSummary` table containing: OrderID, CustomerName, OrderDate, TotalAmount.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Create price history table
CREATE TABLE dbo.ProductPriceHistory (
    HistoryID   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ProductID   INT           NOT NULL,
    OldPrice    DECIMAL(10,2) NOT NULL,
    NewPrice    DECIMAL(10,2) NOT NULL,
    ChangeDate  DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- 2. Update with OUTPUT
UPDATE dbo.Products
SET Price = ROUND(Price * 1.05, 2)
OUTPUT
    deleted.ProductID,
    deleted.Price,
    inserted.Price,
    SYSDATETIME()
INTO dbo.ProductPriceHistory (ProductID, OldPrice, NewPrice, ChangeDate)
WHERE CategoryID = 1;

SELECT * FROM dbo.ProductPriceHistory;
GO

-- 3. MERGE
DECLARE @Source TABLE (
    ProductID   INT,
    ProductName NVARCHAR(100),
    CategoryID  INT,
    Price       DECIMAL(10,2),
    Stock       INT
);

INSERT INTO @Source VALUES
    (2, N'Wireless Mouse', 1, 32.99, 200),
    (NULL, N'Tablet Pro',  1, 599.99, 40);

MERGE dbo.Products AS target
USING @Source AS source
ON target.ProductID = source.ProductID

WHEN MATCHED THEN
    UPDATE SET target.Price = source.Price

WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductName, CategoryID, Price, Stock)
    VALUES (source.ProductName, source.CategoryID, source.Price, source.Stock)

OUTPUT $action, inserted.ProductID, inserted.ProductName, inserted.Price;
GO

-- 4. SELECT INTO
SELECT
    o.OrderID,
    c.FirstName + N' ' + c.LastName AS CustomerName,
    o.OrderDate,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalAmount
INTO dbo.OrderSummary
FROM dbo.Orders o
JOIN dbo.Customers c   ON o.CustomerID = c.CustomerID
JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, c.FirstName, c.LastName, o.OrderDate;

SELECT * FROM dbo.OrderSummary ORDER BY TotalAmount DESC;
GO
```

</details>

---

### Exercise 5: Set Operators

1. Find product IDs that have been ordered in **both** January and February 2025.
2. Find product IDs that were ordered in January but **not** in February.
3. Create a combined list of all customer names and all product names, labeled with their source (`'Customer'` or `'Product'`). Remove duplicates.
4. Find customers who exist in the Customers table but have **never** placed an order (using EXCEPT, not a JOIN).

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. Products ordered in BOTH January and February 2025
SELECT oi.ProductID
FROM dbo.OrderItems oi
JOIN dbo.Orders o ON oi.OrderID = o.OrderID
WHERE o.OrderDate >= '2025-01-01' AND o.OrderDate < '2025-02-01'

INTERSECT

SELECT oi.ProductID
FROM dbo.OrderItems oi
JOIN dbo.Orders o ON oi.OrderID = o.OrderID
WHERE o.OrderDate >= '2025-02-01' AND o.OrderDate < '2025-03-01';

-- 2. Products ordered in January but NOT February
SELECT oi.ProductID
FROM dbo.OrderItems oi
JOIN dbo.Orders o ON oi.OrderID = o.OrderID
WHERE o.OrderDate >= '2025-01-01' AND o.OrderDate < '2025-02-01'

EXCEPT

SELECT oi.ProductID
FROM dbo.OrderItems oi
JOIN dbo.Orders o ON oi.OrderID = o.OrderID
WHERE o.OrderDate >= '2025-02-01' AND o.OrderDate < '2025-03-01';

-- 3. Combined name list
SELECT FirstName + N' ' + LastName AS Name, 'Customer' AS Source
FROM dbo.Customers

UNION

SELECT ProductName AS Name, 'Product' AS Source
FROM dbo.Products;

-- 4. Customers with no orders (using EXCEPT)
SELECT CustomerID
FROM dbo.Customers

EXCEPT

SELECT CustomerID
FROM dbo.Orders;
```

</details>

---

### Exercise 6: Putting It All Together

Write a **single query** that produces a "Daily Sales Dashboard" showing:

- Month name (e.g., "January")
- Total orders
- Total items sold
- Total revenue
- Average order value
- Status breakdown: count of Delivered, Shipped, Pending, and Cancelled orders

Only include months with at least 2 orders. Sort by most recent month first.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
SELECT
    DATENAME(MONTH, o.OrderDate) AS MonthName,
    MONTH(o.OrderDate)           AS MonthNum,
    COUNT(DISTINCT o.OrderID)    AS TotalOrders,
    SUM(oi.Quantity)             AS TotalItemsSold,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue,
    ROUND(
        SUM(oi.Quantity * oi.UnitPrice) * 1.0
        / NULLIF(COUNT(DISTINCT o.OrderID), 0),
        2
    ) AS AvgOrderValue,
    SUM(CASE WHEN o.Status = N'Delivered'  THEN 1 ELSE 0 END) AS Delivered,
    SUM(CASE WHEN o.Status = N'Shipped'    THEN 1 ELSE 0 END) AS Shipped,
    SUM(CASE WHEN o.Status = N'Pending'    THEN 1 ELSE 0 END) AS Pending,
    SUM(CASE WHEN o.Status = N'Cancelled'  THEN 1 ELSE 0 END) AS Cancelled
FROM dbo.Orders o
JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY DATENAME(MONTH, o.OrderDate), MONTH(o.OrderDate)
HAVING COUNT(DISTINCT o.OrderID) >= 2
ORDER BY MonthNum DESC;
```

</details>

---

## 🎯 End of Day 2

**Tomorrow (Day 3)** we will master:

- JOIN types (INNER, LEFT, RIGHT, FULL, CROSS)
- Subqueries (correlated and non-correlated)
- Complex multi-table queries
- Query optimization basics

**Homework:**

1. Run all the exercises above without looking at the solutions.
2. Try adding a `dbo.Returns` table to `RetailDB` and practice MERGE and set operators with it.
3. Experiment with every system function mentioned — change the inputs and observe the outputs.

---

> **Tip:** The best way to learn SQL is to **write it**. Don't just read the
> examples — type them out, modify them, break them, and fix them.