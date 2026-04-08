# Problem: Retail Database Design

Below is an ER diagram description for a retail management system. Use this as a prompt to design a normalized SQL Server schema. Your solution should include appropriate primary keys, foreign keys, unique constraints, check constraints, and default values where necessary.

```
+-------------------+        +-------------------+
|   Categories      |        |    Products       |
+-------------------+        +-------------------+
| CategoryID (PK)   |<--+    | ProductID (PK)    |
| CategoryName      |   +----| ProductName       |
+-------------------+        | CategoryID (FK)   |
                             | Price (>=0)       |
                             | Stock (>=0)       |
                             | IsActive (DF)     |
                             | CreatedDate (DF)  |
                             +-------------------+

+-------------------+        +-------------------+
|   Customers       |        |     Orders        |
+-------------------+        +-------------------+
| CustomerID (PK)   |<--+    | OrderID (PK)      |
| FirstName         |   +----| CustomerID (FK)   |
| LastName          |        | OrderDate (DF)    |
| Email (UQ)        |        | Status (DF, CK)   |
| City              |        +-------------------+
| Country (DF)      |
| JoinDate (DF)     |
+-------------------+

+-------------------+
|   OrderItems      |
+-------------------+
| OrderItemID (PK)  |
| OrderID (FK)      |
| ProductID (FK)    |
| Quantity (>0)     |
| UnitPrice (>=0)   |
+-------------------+
```

Legend:
- PK = Primary Key
- FK = Foreign Key
- UQ = Unique
- DF = Default Value
- CK = Check Constraint

**Task:**
Design the SQL Server schema for this retail system. Write CREATE TABLE statements for each table, including all necessary constraints and default values.

## Solution

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