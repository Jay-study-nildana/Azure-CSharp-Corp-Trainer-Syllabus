# Day 1: Introduction to RDBMS & SQL Basics

---

## Table of Contents

1. [Introduction to Databases](#1-introduction-to-databases)
2. [What is an RDBMS?](#2-what-is-an-rdbms)
3. [Data Models in Databases](#3-data-models-in-databases)
4. [Properties of RDBMS](#4-properties-of-rdbms)
5. [CODD's Relational Database Rules](#5-codds-relational-database-rules)
6. [Data Integrity Concepts](#6-data-integrity-concepts)
7. [Introduction to T-SQL Language](#7-introduction-to-t-sql-language)
8. [Working with Data Types](#8-working-with-data-types)
9. [Working with Schemas and Tables](#9-working-with-schemas-and-tables)
10. [DDL, DML, and DCL Statements](#10-ddl-dml-and-dcl-statements)
11. [Implementing Data Integrity](#11-implementing-data-integrity)
12. [Day 1 Summary](#12-day-1-summary)
13. [Practice Exercises](#13-practice-exercises)

---

## 1. Introduction to Databases

### 1.1 What is Data?

Data is raw, unprocessed facts. Think of it as individual pieces of information
that, on their own, may not mean much.

**Examples of data:**

| Raw Data        | Meaning on its own? |
| --------------- | ------------------- |
| `42`            | A number            |
| `"Alice"`       | A name              |
| `"2025-01-15"`  | A date              |
| `99.99`         | A price?            |

When data is organized and given context it becomes **information**.

### 1.2 What is a Database?

A **database** is an organized collection of data that is stored and accessed
electronically. Databases allow us to:

- **Store** large amounts of data efficiently.
- **Retrieve** specific data quickly.
- **Update** and **delete** data safely.
- **Share** data among multiple users simultaneously.

### 1.3 Brief History of Databases

| Era         | Technology                      | Notes                                                 |
| ----------- | ------------------------------- | ----------------------------------------------------- |
| 1960s       | Flat files, hierarchical DBs    | Data stored in tree-like structures                    |
| 1970s       | Relational model (E. F. Codd)   | Introduced tables, rows, columns                      |
| 1980s–1990s | Commercial RDBMS (Oracle, SQL Server, DB2) | SQL becomes the standard language          |
| 2000s       | Open-source RDBMS (MySQL, PostgreSQL) | Wider adoption, web-era databases               |
| 2010s–now   | NoSQL, NewSQL, Cloud databases  | Horizontal scaling, flexible schemas, managed services |

### 1.4 Why Do We Need Databases?

Imagine storing all student records for a university in a single Excel file:

- What happens when 10 staff members try to edit at the same time?
- How do you ensure nobody accidentally deletes a semester of grades?
- How do you quickly find all students who scored above 90 in Math?

Databases solve these problems through **concurrency control**, **data integrity**,
and **efficient querying**.

---

## 2. What is an RDBMS?

### 2.1 Definition

An **RDBMS** (Relational Database Management System) is software that:

1. Stores data in **tables** (also called **relations**).
2. Enforces **relationships** between tables.
3. Uses **SQL** (Structured Query Language) to manage data.

### 2.2 Key Terminology

| Term           | Definition                                                         |
| -------------- | ------------------------------------------------------------------ |
| **Table**      | A collection of related data organized in rows and columns.        |
| **Row**        | A single record in a table (also called a **tuple**).              |
| **Column**     | A single attribute/field in a table (also called an **attribute**).|
| **Primary Key**| A column (or set of columns) that uniquely identifies each row.    |
| **Foreign Key**| A column that creates a link between two tables.                   |
| **Schema**     | The logical structure/blueprint of the database.                   |
| **Constraint** | A rule enforced on data columns to ensure accuracy and reliability.|

### 2.3 Visual Representation

```
+------------------+          +------------------+
|    Students      |          |    Enrollments   |
+------------------+          +------------------+
| StudentID  (PK)  |<-------->| EnrollmentID (PK)|
| FirstName        |          | StudentID   (FK) |
| LastName         |          | CourseID    (FK)  |
| DateOfBirth      |          | EnrollDate       |
| Email            |          | Grade            |
+------------------+          +------------------+
```

### 2.4 Popular RDBMS Products

| Product             | Vendor      | Notes                              |
| ------------------- | ----------- | ---------------------------------- |
| SQL Server          | Microsoft   | Enterprise-grade, T-SQL dialect    |
| Oracle Database     | Oracle Corp | Widely used in large enterprises   |
| MySQL               | Oracle/OSS  | Popular open-source RDBMS          |
| PostgreSQL          | Community   | Advanced open-source RDBMS         |
| SQLite              | Public Domain | Lightweight, file-based          |
| Azure SQL Database  | Microsoft   | Cloud-managed SQL Server           |

> **In this course** we will focus on **Microsoft SQL Server** and its dialect
> of SQL called **T-SQL** (Transact-SQL).

---

## 3. Data Models in Databases

A **data model** defines how data is structured, stored, and manipulated.

### 3.1 Hierarchical Model

- Data organized in a **tree-like** structure.
- Each record has a single parent.
- Example: file system directories.

```
         University
         /       \
    Science      Arts
    /    \         \
 Physics  Chem    English
```

**Pros:** Simple, fast for known access paths.
**Cons:** Rigid, duplicates data, hard to reorganize.

### 3.2 Network Model

- Extension of hierarchical; records can have **multiple parents**.
- Uses pointers to link records.

**Pros:** More flexible than hierarchical.
**Cons:** Complex to design and navigate.

### 3.3 Relational Model

- Data stored in **tables** (relations).
- Relationships defined through **keys** (primary & foreign).
- Based on **set theory** and **first-order predicate logic**.
- Proposed by **E. F. Codd** in 1970.

```
Students                     Courses
+----+---------+             +----+------------+
| ID | Name    |             | ID | CourseName |
+----+---------+             +----+------------+
| 1  | Alice   |             | 10 | Math       |
| 2  | Bob     |             | 20 | Science    |
+----+---------+             +----+------------+
```

**Pros:** Flexible, powerful querying with SQL, strong integrity.
**Cons:** Can be slower for very large, unstructured data.

### 3.4 Object-Oriented Model

- Data stored as **objects** (similar to OOP in programming).
- Supports inheritance, encapsulation.
- Less common in mainstream databases today.

### 3.5 Document / NoSQL Models (Preview)

> We will cover NoSQL models in detail on **Day 5**.

- Data stored as documents (JSON/BSON), key-value pairs, graphs, or wide columns.
- Designed for horizontal scaling and flexible schemas.

---

## 4. Properties of RDBMS

### 4.1 ACID Properties

Every reliable RDBMS guarantees **ACID** properties for transactions:

| Property        | Meaning                                                                 |
| --------------- | ----------------------------------------------------------------------- |
| **Atomicity**   | A transaction is all-or-nothing. If any part fails, the entire transaction is rolled back. |
| **Consistency** | A transaction brings the database from one valid state to another.      |
| **Isolation**   | Concurrent transactions do not interfere with each other.               |
| **Durability**  | Once a transaction is committed, it persists even after a system crash. |

#### Example: Bank Transfer

```
BEGIN TRANSACTION;
    UPDATE Accounts SET Balance = Balance - 500 WHERE AccountID = 1;  -- debit
    UPDATE Accounts SET Balance = Balance + 500 WHERE AccountID = 2;  -- credit
COMMIT;
```

- **Atomicity:** If the credit fails, the debit is rolled back.
- **Consistency:** Total money in the system stays the same.
- **Isolation:** Another query reading balances mid-transfer won't see partial results.
- **Durability:** After `COMMIT`, the transfer survives a power outage.

### 4.2 Other Important RDBMS Properties

| Property                   | Description                                                |
| -------------------------- | ---------------------------------------------------------- |
| **Data Independence**      | Changes to storage don't affect applications.              |
| **Multi-user Access**      | Multiple users can read/write simultaneously.              |
| **Security**               | Access control via permissions and roles.                  |
| **Backup & Recovery**      | Built-in tools to protect against data loss.               |
| **Referential Integrity**  | Foreign keys ensure valid relationships.                   |
| **Normalization Support**  | Tools and rules to reduce redundancy.                      |

---

## 5. CODD's Relational Database Rules

In 1985, **Edgar F. Codd** published **12 rules** (numbered 0–12, so technically
13) that a database must satisfy to be considered truly relational.

### The 13 Rules at a Glance

| #  | Rule Name                          | Summary                                                                 |
| -- | ---------------------------------- | ----------------------------------------------------------------------- |
| 0  | Foundation Rule                    | The system must manage data entirely through its relational capabilities.|
| 1  | Information Rule                   | All data is represented in tables (rows & columns).                     |
| 2  | Guaranteed Access Rule             | Every value is accessible via table name + primary key + column name.   |
| 3  | Systematic Treatment of NULLs      | NULLs are supported to represent missing/unknown data.                  |
| 4  | Dynamic Online Catalog (Data Dictionary) | The database schema is stored in tables and queryable with SQL.   |
| 5  | Comprehensive Data Sub-Language    | At least one language (SQL) must support all DB operations.             |
| 6  | View Updating Rule                 | Views that are theoretically updatable must be updatable by the system. |
| 7  | High-Level Insert, Update, Delete  | The system must support set-level (bulk) operations.                    |
| 8  | Physical Data Independence         | Changes to physical storage don't affect apps or queries.               |
| 9  | Logical Data Independence          | Changes to logical schema (within limits) don't affect apps.           |
| 10 | Integrity Independence             | Integrity constraints are stored in the catalog, not in applications.   |
| 11 | Distribution Independence          | The system works the same whether data is centralized or distributed.   |
| 12 | Non-subversion Rule                | Low-level access cannot bypass integrity rules.                         |

### Deep Dive: Selected Rules

#### Rule 1 — Information Rule

> All information in a relational database is represented explicitly at the
> logical level in exactly one way — by values in tables.

This means:

- No hidden data structures.
- Everything is a table — even metadata.

```sql
-- Even system information is in tables:
SELECT * FROM INFORMATION_SCHEMA.TABLES;
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Students';
```

#### Rule 3 — Systematic Treatment of NULLs

> NULL represents missing or inapplicable information, distinct from any regular
> value (including zero or empty string).

```sql
-- NULL is NOT the same as 0 or ''
SELECT * FROM Students WHERE MiddleName IS NULL;

-- This will NOT work as expected:
SELECT * FROM Students WHERE MiddleName = NULL;   -- WRONG!
```

#### Rule 7 — High-Level Insert, Update, Delete

> The system must support set-at-a-time operations.

```sql
-- Set-level update: give all students in CourseID 10 a 5-point bonus
UPDATE Enrollments
SET Grade = Grade + 5
WHERE CourseID = 10;
```

---

## 6. Data Integrity Concepts

**Data integrity** ensures that the data in your database is accurate, consistent,
and reliable.

### 6.1 Types of Data Integrity

| Type                       | What it protects                                         |
| -------------------------- | -------------------------------------------------------- |
| **Entity Integrity**       | Each row is uniquely identifiable (Primary Key).         |
| **Referential Integrity**  | Relationships between tables remain valid (Foreign Key). |
| **Domain Integrity**       | Column values fall within a valid range/type.            |
| **User-Defined Integrity** | Business rules specific to your application.             |

### 6.2 Entity Integrity

Every table **must** have a primary key, and primary key values must be:

- **Unique** — no two rows share the same key.
- **NOT NULL** — every row must have a key value.

```sql
CREATE TABLE Students (
    StudentID   INT          NOT NULL PRIMARY KEY,
    FirstName   NVARCHAR(50) NOT NULL,
    LastName    NVARCHAR(50) NOT NULL,
    Email       NVARCHAR(100)
);
```

### 6.3 Referential Integrity

A **foreign key** in one table must match a **primary key** value in another
table (or be NULL, if allowed).

```sql
CREATE TABLE Enrollments (
    EnrollmentID INT NOT NULL PRIMARY KEY,
    StudentID    INT NOT NULL,
    CourseID     INT NOT NULL,
    EnrollDate   DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID)  REFERENCES Courses(CourseID)
);
```

If you try to insert an enrollment for `StudentID = 999` but no such student
exists, SQL Server will **reject** the insert.

### 6.4 Domain Integrity

Ensures column values conform to defined data types and constraints.

```sql
CREATE TABLE Products (
    ProductID   INT           NOT NULL PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Quantity    INT           NOT NULL DEFAULT 0
);
```

- `Price >= 0` prevents negative prices.
- `DEFAULT 0` sets Quantity to 0 if not supplied.

### 6.5 User-Defined Integrity

Custom business rules. Examples:

- "A student cannot enroll in more than 6 courses per semester."
- "An order's ship date must be after the order date."

```sql
CREATE TABLE Orders (
    OrderID    INT  NOT NULL PRIMARY KEY,
    OrderDate  DATE NOT NULL,
    ShipDate   DATE,
    CHECK (ShipDate IS NULL OR ShipDate >= OrderDate)
);
```

---

## 7. Introduction to T-SQL Language

### 7.1 What is SQL?

**SQL** (Structured Query Language) is the standard language for communicating
with relational databases. It was originally developed at IBM in the 1970s.

### 7.2 What is T-SQL?

**T-SQL** (Transact-SQL) is Microsoft's extension of SQL, used in:

- SQL Server
- Azure SQL Database
- Azure Synapse Analytics

T-SQL adds:

- Variables and control flow (`IF`, `WHILE`, `BEGIN…END`)
- Error handling (`TRY…CATCH`)
- Built-in functions
- Stored procedures and triggers

### 7.3 SQL Statement Categories

| Category | Name                          | Purpose                        | Key Statements                     |
| -------- | ----------------------------- | ------------------------------ | ---------------------------------- |
| **DDL**  | Data Definition Language      | Define/modify database objects | `CREATE`, `ALTER`, `DROP`          |
| **DML**  | Data Manipulation Language    | Query and modify data          | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| **DCL**  | Data Control Language         | Manage permissions             | `GRANT`, `REVOKE`, `DENY`         |
| **TCL**  | Transaction Control Language  | Manage transactions            | `BEGIN TRAN`, `COMMIT`, `ROLLBACK`|

### 7.4 Your First T-SQL Statements

```sql
-- 1. Create a database
CREATE DATABASE SchoolDB;
GO

-- 2. Switch to it
USE SchoolDB;
GO

-- 3. Say hello!
SELECT 'Hello, SQL World!' AS Greeting;
```

**Output:**

| Greeting          |
| ----------------- |
| Hello, SQL World! |

### 7.5 Comments in T-SQL

```sql
-- This is a single-line comment

/*
   This is a
   multi-line comment
*/

SELECT 1 + 1 AS Result;  -- inline comment
```

### 7.6 The GO Keyword

`GO` is **not** a T-SQL statement. It is a **batch separator** recognized by
SQL Server tools (SSMS, sqlcmd). It tells the tool to send the preceding
statements as a single batch to the server.

```sql
CREATE DATABASE DemoDB;
GO          -- end of batch 1

USE DemoDB;
GO          -- end of batch 2

CREATE TABLE Demo (ID INT);
GO          -- end of batch 3
```

---

## 8. Working with Data Types

### 8.1 Why Data Types Matter

- They define **what kind** of data a column can hold.
- They affect **storage size** and **performance**.
- They enforce **domain integrity**.

### 8.2 Commonly Used Data Types in SQL Server

#### Numeric Types

| Data Type        | Range / Precision                    | Storage  |
| ---------------- | ------------------------------------ | -------- |
| `BIT`            | 0, 1, or NULL                        | 1 bit    |
| `TINYINT`        | 0 to 255                             | 1 byte   |
| `SMALLINT`       | -32,768 to 32,767                    | 2 bytes  |
| `INT`            | -2.1 billion to 2.1 billion          | 4 bytes  |
| `BIGINT`         | ±9.2 quintillion                     | 8 bytes  |
| `DECIMAL(p, s)`  | User-defined precision & scale       | 5–17 bytes |
| `FLOAT`          | Approximate numeric                  | 4 or 8 bytes |
| `MONEY`          | ±922 trillion (4 decimal places)     | 8 bytes  |

#### String Types

| Data Type         | Description                          | Max Length     |
| ----------------- | ------------------------------------ | -------------- |
| `CHAR(n)`         | Fixed-length, non-Unicode            | 8,000 chars    |
| `VARCHAR(n)`      | Variable-length, non-Unicode         | 8,000 chars    |
| `VARCHAR(MAX)`    | Variable-length, non-Unicode         | ~2 GB          |
| `NCHAR(n)`        | Fixed-length, Unicode                | 4,000 chars    |
| `NVARCHAR(n)`     | Variable-length, Unicode             | 4,000 chars    |
| `NVARCHAR(MAX)`   | Variable-length, Unicode             | ~2 GB          |

> **Tip:** Use `NVARCHAR` when you need to store international characters
> (Arabic, Chinese, emoji, etc.). The `N` stands for **National**.

#### Date & Time Types

| Data Type          | Range                                | Precision        |
| ------------------ | ------------------------------------ | ---------------- |
| `DATE`             | 0001-01-01 to 9999-12-31            | 1 day            |
| `TIME`             | 00:00:00.0000000 to 23:59:59.9999999| 100 nanoseconds  |
| `DATETIME`         | 1753-01-01 to 9999-12-31            | 3.33 ms          |
| `DATETIME2`        | 0001-01-01 to 9999-12-31            | 100 nanoseconds  |
| `SMALLDATETIME`    | 1900-01-01 to 2079-06-06            | 1 minute         |

> **Best practice:** Prefer `DATE` for dates, `DATETIME2` for date-times.

#### Other Useful Types

| Data Type          | Use Case                             |
| ------------------ | ------------------------------------ |
| `UNIQUEIDENTIFIER` | GUIDs / UUIDs                       |
| `VARBINARY(n)`     | Binary data (files, images)          |
| `XML`              | XML documents                        |
| `JSON` (stored as `NVARCHAR`) | JSON data (no native type)|

### 8.3 Choosing the Right Data Type

```
Do you need to store...
│
├── Whole numbers?
│   ├── Small range (0-255) ──────────> TINYINT
│   ├── Medium range ──────────────���──> INT
│   └── Very large numbers ──────────> BIGINT
│
├── Decimal numbers?
│   ├── Exact (money, measurements) ──> DECIMAL(p,s)
│   └── Approximate (scientific) ────> FLOAT
│
├── Text?
│   ├── Always same length? ─────────> CHAR / NCHAR
│   ├── Variable length? ───────────> VARCHAR / NVARCHAR
│   └── Need Unicode? ──────────────> Use the N-prefix versions
│
├── Dates / Times?
│   ├── Date only ───────────────────> DATE
│   ├── Time only ───────────────────> TIME
│   └── Both ────────────────────────> DATETIME2
│
└── True / False? ───────────────────> BIT
```

### 8.4 Quick Demo: Data Types in Action

```sql
USE SchoolDB;
GO

CREATE TABLE DataTypeDemo (
    ID              INT             IDENTITY(1,1) PRIMARY KEY,
    FullName        NVARCHAR(100)   NOT NULL,
    Age             TINYINT         NOT NULL,
    GPA             DECIMAL(3, 2),          -- e.g., 3.85
    IsActive        BIT             NOT NULL DEFAULT 1,
    EnrollmentDate  DATE            NOT NULL,
    Notes           NVARCHAR(MAX)
);
GO

INSERT INTO DataTypeDemo (FullName, Age, GPA, IsActive, EnrollmentDate, Notes)
VALUES
    (N'Alice Johnson', 20, 3.85, 1, '2025-09-01', N'Honors student'),
    (N'Bob Smith',     22, 3.40, 1, '2025-09-01', NULL),
    (N'Charlie Lee',   19, 2.90, 0, '2024-09-01', N'On leave');
GO

SELECT * FROM DataTypeDemo;
```

**Expected Output:**

| ID | FullName       | Age | GPA  | IsActive | EnrollmentDate | Notes          |
| -- | -------------- | --- | ---- | -------- | -------------- | -------------- |
| 1  | Alice Johnson  | 20  | 3.85 | 1        | 2025-09-01     | Honors student |
| 2  | Bob Smith      | 22  | 3.40 | 1        | 2025-09-01     | NULL           |
| 3  | Charlie Lee    | 19  | 2.90 | 0        | 2024-09-01     | On leave       |

---

## 9. Working with Schemas and Tables

### 9.1 What is a Schema?

A **schema** is a logical container (namespace) for database objects such as
tables, views, and stored procedures.

Benefits:

- **Organization** — group related objects together.
- **Security** — grant/revoke permissions at the schema level.
- **Avoid naming conflicts** — `Sales.Orders` vs. `Warehouse.Orders`.

### 9.2 Default Schema

In SQL Server, the default schema is **`dbo`** (database owner).

```sql
-- These two statements are equivalent:
SELECT * FROM Students;
SELECT * FROM dbo.Students;
```

### 9.3 Creating a Custom Schema

```sql
-- Create a schema called 'HR'
CREATE SCHEMA HR;
GO

-- Create a table inside the HR schema
CREATE TABLE HR.Employees (
    EmployeeID  INT           NOT NULL PRIMARY KEY,
    FirstName   NVARCHAR(50)  NOT NULL,
    LastName    NVARCHAR(50)  NOT NULL,
    HireDate    DATE          NOT NULL,
    Salary      DECIMAL(10,2) NOT NULL
);
GO

-- Query the table using its full name
SELECT * FROM HR.Employees;
```

### 9.4 Creating Tables — Full Syntax

```sql
CREATE TABLE [schema_name.]table_name (
    column1  data_type  [NULL | NOT NULL]  [constraints],
    column2  data_type  [NULL | NOT NULL]  [constraints],
    ...
    [table_level_constraints]
);
```

### 9.5 Comprehensive Table Creation Example

Let's build a small **School** database with multiple related tables.

```sql
-- ============================================
-- Step 1: Create the database
-- ============================================
CREATE DATABASE SchoolDB;
GO

USE SchoolDB;
GO

-- ============================================
-- Step 2: Create schemas
-- ============================================
CREATE SCHEMA Academic;
GO

CREATE SCHEMA Admin;
GO

-- ============================================
-- Step 3: Create tables
-- ============================================

-- Departments table
CREATE TABLE Academic.Departments (
    DepartmentID    INT           NOT NULL IDENTITY(1,1),
    DepartmentName  NVARCHAR(100) NOT NULL,
    Building        NVARCHAR(50),
    CONSTRAINT PK_Departments PRIMARY KEY (DepartmentID)
);
GO

-- Instructors table
CREATE TABLE Academic.Instructors (
    InstructorID    INT           NOT NULL IDENTITY(1,1),
    FirstName       NVARCHAR(50)  NOT NULL,
    LastName        NVARCHAR(50)  NOT NULL,
    Email           NVARCHAR(100) NOT NULL,
    DepartmentID    INT           NOT NULL,
    CONSTRAINT PK_Instructors PRIMARY KEY (InstructorID),
    CONSTRAINT FK_Instructors_Dept FOREIGN KEY (DepartmentID)
        REFERENCES Academic.Departments(DepartmentID),
    CONSTRAINT UQ_Instructors_Email UNIQUE (Email)
);
GO

-- Students table
CREATE TABLE Academic.Students (
    StudentID       INT           NOT NULL IDENTITY(1,1),
    FirstName       NVARCHAR(50)  NOT NULL,
    LastName        NVARCHAR(50)  NOT NULL,
    DateOfBirth     DATE          NOT NULL,
    Email           NVARCHAR(100) NOT NULL,
    EnrollmentDate  DATE          NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Students PRIMARY KEY (StudentID),
    CONSTRAINT UQ_Students_Email UNIQUE (Email),
    CONSTRAINT CK_Students_DOB CHECK (DateOfBirth < GETDATE())
);
GO

-- Courses table
CREATE TABLE Academic.Courses (
    CourseID        INT           NOT NULL IDENTITY(1,1),
    CourseName      NVARCHAR(100) NOT NULL,
    Credits         TINYINT       NOT NULL,
    DepartmentID    INT           NOT NULL,
    InstructorID    INT,
    CONSTRAINT PK_Courses PRIMARY KEY (CourseID),
    CONSTRAINT FK_Courses_Dept FOREIGN KEY (DepartmentID)
        REFERENCES Academic.Departments(DepartmentID),
    CONSTRAINT FK_Courses_Instructor FOREIGN KEY (InstructorID)
        REFERENCES Academic.Instructors(InstructorID),
    CONSTRAINT CK_Courses_Credits CHECK (Credits BETWEEN 1 AND 6)
);
GO

-- Enrollments table (junction / bridge table)
CREATE TABLE Academic.Enrollments (
    EnrollmentID    INT  NOT NULL IDENTITY(1,1),
    StudentID       INT  NOT NULL,
    CourseID        INT  NOT NULL,
    EnrollDate      DATE NOT NULL DEFAULT GETDATE(),
    Grade           DECIMAL(4,2),
    CONSTRAINT PK_Enrollments PRIMARY KEY (EnrollmentID),
    CONSTRAINT FK_Enrollments_Student FOREIGN KEY (StudentID)
        REFERENCES Academic.Students(StudentID),
    CONSTRAINT FK_Enrollments_Course FOREIGN KEY (CourseID)
        REFERENCES Academic.Courses(CourseID),
    CONSTRAINT CK_Enrollments_Grade CHECK (Grade IS NULL OR Grade BETWEEN 0 AND 100),
    CONSTRAINT UQ_Enrollments UNIQUE (StudentID, CourseID)  -- prevent double enrollment
);
GO
```

### 9.6 Understanding IDENTITY

`IDENTITY(seed, increment)` auto-generates values for a column.

```sql
IDENTITY(1, 1)   -- starts at 1, increments by 1
IDENTITY(100, 5) -- starts at 100, increments by 5
```

```sql
-- Insert without specifying the identity column
INSERT INTO Academic.Departments (DepartmentName, Building)
VALUES
    (N'Computer Science', N'Building A'),
    (N'Mathematics',      N'Building B'),
    (N'Physics',          N'Building C');

SELECT * FROM Academic.Departments;
```

| DepartmentID | DepartmentName   | Building   |
| ------------ | ---------------- | ---------- |
| 1            | Computer Science | Building A |
| 2            | Mathematics      | Building B |
| 3            | Physics          | Building C |

### 9.7 Altering Tables

```sql
-- Add a new column
ALTER TABLE Academic.Students
ADD PhoneNumber NVARCHAR(20);
GO

-- Modify a column's data type
ALTER TABLE Academic.Students
ALTER COLUMN PhoneNumber VARCHAR(15);
GO

-- Drop a column
ALTER TABLE Academic.Students
DROP COLUMN PhoneNumber;
GO

-- Add a constraint after table creation
ALTER TABLE Academic.Courses
ADD CONSTRAINT DF_Courses_Credits DEFAULT 3 FOR Credits;
GO
```

### 9.8 Dropping Tables

```sql
-- Drop a table (be careful — this is irreversible!)
DROP TABLE IF EXISTS Academic.Enrollments;
GO
```

> **Warning:** If other tables have foreign keys referencing this table, you
> must drop those constraints or tables first.

---

## 10. DDL, DML, and DCL Statements

### 10.1 DDL — Data Definition Language

DDL statements define the **structure** of your database.

| Statement  | Purpose                               |
| ---------- | ------------------------------------- |
| `CREATE`   | Create a new database object          |
| `ALTER`    | Modify an existing object             |
| `DROP`     | Delete an object permanently          |
| `TRUNCATE` | Remove all rows from a table (fast)   |

#### CREATE Examples

```sql
-- Create a database
CREATE DATABASE InventoryDB;
GO

-- Create a table
CREATE TABLE dbo.Products (
    ProductID   INT           IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    Stock       INT           NOT NULL DEFAULT 0
);
GO
```

#### ALTER Examples

```sql
-- Add a column
ALTER TABLE dbo.Products
ADD Category NVARCHAR(50);
GO

-- Add a check constraint
ALTER TABLE dbo.Products
ADD CONSTRAINT CK_Products_Stock CHECK (Stock >= 0);
GO
```

#### DROP Examples

```sql
-- Drop a constraint
ALTER TABLE dbo.Products
DROP CONSTRAINT CK_Products_Stock;
GO

-- Drop a table
DROP TABLE IF EXISTS dbo.Products;
GO

-- Drop a database
DROP DATABASE IF EXISTS InventoryDB;
GO
```

#### TRUNCATE vs DELETE

| Feature        | `TRUNCATE TABLE`              | `DELETE FROM`                   |
| -------------- | ----------------------------- | ------------------------------- |
| Speed          | Very fast                     | Slower (row-by-row logging)     |
| WHERE clause   | Not supported                 | Supported                       |
| Identity reset | Resets to seed                | Does NOT reset                  |
| Triggers       | Does NOT fire                 | Fires DELETE triggers           |
| Rollback       | Can be rolled back in a tran  | Can be rolled back in a tran    |

```sql
-- Remove all rows from a table (fast, resets identity)
TRUNCATE TABLE dbo.Products;

-- Remove all rows (slower, does NOT reset identity)
DELETE FROM dbo.Products;

-- Remove specific rows
DELETE FROM dbo.Products WHERE Stock = 0;
```

---

### 10.2 DML — Data Manipulation Language

DML statements **read and modify** data.

#### INSERT

```sql
-- Single row insert
INSERT INTO Academic.Students (FirstName, LastName, DateOfBirth, Email)
VALUES (N'Alice', N'Johnson', '2003-05-15', N'alice@school.edu');

-- Multiple rows insert
INSERT INTO Academic.Students (FirstName, LastName, DateOfBirth, Email)
VALUES
    (N'Bob',     N'Smith',   '2002-08-22', N'bob@school.edu'),
    (N'Charlie', N'Lee',     '2004-01-10', N'charlie@school.edu'),
    (N'Diana',   N'Chen',    '2003-11-30', N'diana@school.edu');
```

#### INSERT INTO … SELECT

```sql
-- Copy data from one table into another
INSERT INTO Archive.Students (FirstName, LastName, DateOfBirth, Email)
SELECT FirstName, LastName, DateOfBirth, Email
FROM Academic.Students
WHERE EnrollmentDate < '2023-01-01';
```

#### SELECT (basic)

```sql
-- Select all columns
SELECT * FROM Academic.Students;

-- Select specific columns
SELECT FirstName, LastName, Email
FROM Academic.Students;

-- Select with alias
SELECT
    FirstName AS [First Name],
    LastName  AS [Last Name],
    Email     AS [Email Address]
FROM Academic.Students;

-- Select with a calculated column
SELECT
    FirstName,
    LastName,
    DATEDIFF(YEAR, DateOfBirth, GETDATE()) AS Age
FROM Academic.Students;
```

#### WHERE Clause

```sql
-- Comparison operators
SELECT * FROM Academic.Students WHERE StudentID = 1;
SELECT * FROM Academic.Students WHERE StudentID <> 1;
SELECT * FROM Academic.Students WHERE StudentID > 2;

-- Logical operators
SELECT * FROM Academic.Students
WHERE FirstName = N'Alice' AND LastName = N'Johnson';

SELECT * FROM Academic.Students
WHERE FirstName = N'Alice' OR FirstName = N'Bob';

-- BETWEEN
SELECT * FROM Academic.Students
WHERE DateOfBirth BETWEEN '2003-01-01' AND '2003-12-31';

-- IN
SELECT * FROM Academic.Students
WHERE FirstName IN (N'Alice', N'Bob', N'Charlie');

-- LIKE (pattern matching)
SELECT * FROM Academic.Students WHERE LastName LIKE 'J%';     -- starts with J
SELECT * FROM Academic.Students WHERE LastName LIKE '%son';   -- ends with 'son'
SELECT * FROM Academic.Students WHERE LastName LIKE '%ee%';   -- contains 'ee'
SELECT * FROM Academic.Students WHERE FirstName LIKE '_o%';   -- second letter is 'o'

-- IS NULL / IS NOT NULL
SELECT * FROM Academic.Students WHERE Email IS NOT NULL;
```

#### UPDATE

```sql
-- Update a single row
UPDATE Academic.Students
SET Email = N'alice.johnson@school.edu'
WHERE StudentID = 1;

-- Update multiple rows
UPDATE Academic.Students
SET EnrollmentDate = '2025-09-01'
WHERE EnrollmentDate IS NULL;

-- Update with calculation
UPDATE Academic.Enrollments
SET Grade = Grade + 5
WHERE CourseID = 1 AND Grade <= 95;
```

> **Always use a WHERE clause with UPDATE** unless you intentionally want to
> update every row!

#### DELETE

```sql
-- Delete a specific row
DELETE FROM Academic.Students
WHERE StudentID = 4;

-- Delete with a condition
DELETE FROM Academic.Enrollments
WHERE Grade < 30;
```

> **Always use a WHERE clause with DELETE** unless you intentionally want to
> delete every row!

---

### 10.3 DCL — Data Control Language

DCL statements manage **permissions** and **access control**.

#### GRANT

```sql
-- Grant SELECT permission on Students table to a user
GRANT SELECT ON Academic.Students TO [StudentReadUser];

-- Grant multiple permissions
GRANT SELECT, INSERT, UPDATE ON Academic.Enrollments TO [EnrollmentClerk];

-- Grant permissions on a schema
GRANT SELECT ON SCHEMA::Academic TO [ReportReader];
```

#### REVOKE

```sql
-- Revoke previously granted permission
REVOKE INSERT ON Academic.Enrollments FROM [EnrollmentClerk];
```

#### DENY

```sql
-- Explicitly deny permission (overrides GRANT)
DENY DELETE ON Academic.Students TO [EnrollmentClerk];
```

#### Permission Hierarchy

```
DENY  >  GRANT  >  (no permission)

If a user has both GRANT and DENY for the same action,
DENY wins.
```

---

## 11. Implementing Data Integrity

Now let's put everything together and implement data integrity using
**constraints**.

### 11.1 Types of Constraints

| Constraint       | Purpose                                        |
| ---------------- | ---------------------------------------------- |
| `PRIMARY KEY`    | Uniquely identifies each row                   |
| `FOREIGN KEY`    | Enforces referential integrity                 |
| `UNIQUE`         | Ensures all values in a column are distinct    |
| `CHECK`          | Validates data against a condition             |
| `DEFAULT`        | Provides a default value when none is supplied |
| `NOT NULL`       | Prevents NULL values in a column               |

### 11.2 Naming Constraints

Always **name your constraints** for clarity and easier maintenance:

```
PK_TableName             — Primary Key
FK_ChildTable_ParentTable — Foreign Key
UQ_TableName_ColumnName  — Unique
CK_TableName_Rule        — Check
DF_TableName_ColumnName  — Default
```

### 11.3 Complete Example with All Constraint Types

```sql
USE SchoolDB;
GO

CREATE TABLE Admin.Staff (
    -- PRIMARY KEY (entity integrity)
    StaffID         INT           NOT NULL IDENTITY(1,1),

    -- NOT NULL (domain integrity)
    FirstName       NVARCHAR(50)  NOT NULL,
    LastName        NVARCHAR(50)  NOT NULL,

    -- UNIQUE (no duplicate emails)
    Email           NVARCHAR(100) NOT NULL,

    -- CHECK (domain integrity — must be a valid role)
    Role            NVARCHAR(30)  NOT NULL,

    -- DEFAULT (domain integrity — defaults to today)
    HireDate        DATE          NOT NULL,

    -- CHECK (user-defined integrity — salary must be positive)
    Salary          DECIMAL(10,2) NOT NULL,

    -- Foreign Key (referential integrity)
    DepartmentID    INT           NOT NULL,

    -- =====================
    -- Table-level constraints
    -- =====================
    CONSTRAINT PK_Staff            PRIMARY KEY (StaffID),
    CONSTRAINT UQ_Staff_Email      UNIQUE (Email),
    CONSTRAINT CK_Staff_Role       CHECK (Role IN ('Admin', 'Support', 'Manager', 'Director')),
    CONSTRAINT DF_Staff_HireDate   DEFAULT (GETDATE()) FOR HireDate,
    CONSTRAINT CK_Staff_Salary     CHECK (Salary > 0),
    CONSTRAINT FK_Staff_Department FOREIGN KEY (DepartmentID)
        REFERENCES Academic.Departments(DepartmentID)
);
GO
```

### 11.4 Testing the Constraints

Let's verify our constraints work:

```sql
-- ✅ Valid insert
INSERT INTO Admin.Staff (FirstName, LastName, Email, Role, Salary, DepartmentID)
VALUES (N'Eve', N'Adams', N'eve@school.edu', N'Admin', 55000.00, 1);
-- Result: 1 row inserted (HireDate defaults to today)

-- ❌ Duplicate email (violates UQ_Staff_Email)
INSERT INTO Admin.Staff (FirstName, LastName, Email, Role, Salary, DepartmentID)
VALUES (N'Eve', N'Clone', N'eve@school.edu', N'Support', 40000.00, 1);
-- Error: Violation of UNIQUE KEY constraint 'UQ_Staff_Email'

-- ❌ Invalid role (violates CK_Staff_Role)
INSERT INTO Admin.Staff (FirstName, LastName, Email, Role, Salary, DepartmentID)
VALUES (N'Frank', N'Test', N'frank@school.edu', N'Intern', 30000.00, 1);
-- Error: The INSERT statement conflicted with the CHECK constraint 'CK_Staff_Role'

-- ❌ Negative salary (violates CK_Staff_Salary)
INSERT INTO Admin.Staff (FirstName, LastName, Email, Role, Salary, DepartmentID)
VALUES (N'Grace', N'Hopper', N'grace@school.edu', N'Manager', -1000.00, 1);
-- Error: The INSERT statement conflicted with the CHECK constraint 'CK_Staff_Salary'

-- ❌ Non-existent department (violates FK_Staff_Department)
INSERT INTO Admin.Staff (FirstName, LastName, Email, Role, Salary, DepartmentID)
VALUES (N'Hank', N'Green', N'hank@school.edu', N'Director', 80000.00, 999);
-- Error: The INSERT statement conflicted with the FOREIGN KEY constraint

-- ❌ NULL first name (violates NOT NULL)
INSERT INTO Admin.Staff (FirstName, LastName, Email, Role, Salary, DepartmentID)
VALUES (NULL, N'Nobody', N'nobody@school.edu', N'Support', 35000.00, 1);
-- Error: Cannot insert the value NULL into column 'FirstName'
```

### 11.5 Foreign Key Actions (CASCADE, SET NULL, SET DEFAULT)

When a referenced row is updated or deleted, what should happen to the
child rows?

```sql
CREATE TABLE Academic.CourseReviews (
    ReviewID    INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CourseID    INT           NOT NULL,
    StudentID   INT           NOT NULL,
    Rating      TINYINT       NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment     NVARCHAR(500),

    -- ON DELETE CASCADE: if a course is deleted, its reviews are also deleted
    CONSTRAINT FK_Reviews_Course FOREIGN KEY (CourseID)
        REFERENCES Academic.Courses(CourseID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- ON DELETE SET NULL: if a student is deleted, StudentID becomes NULL
    CONSTRAINT FK_Reviews_Student FOREIGN KEY (StudentID)
        REFERENCES Academic.Students(StudentID)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
);
```

| Action            | Behavior                                      |
| ----------------- | --------------------------------------------- |
| `NO ACTION`       | Prevent the delete/update (default)           |
| `CASCADE`         | Delete/update child rows automatically        |
| `SET NULL`        | Set foreign key column to NULL                |
| `SET DEFAULT`     | Set foreign key column to its default value   |

---

## 12. Day 1 Summary

### What We Covered

| Topic                        | Key Takeaway                                             |
| ---------------------------- | -------------------------------------------------------- |
| Databases                    | Organized collections of data for efficient CRUD.        |
| RDBMS                        | Stores data in tables with relationships via keys.       |
| Data Models                  | Hierarchical → Network → **Relational** → NoSQL.        |
| ACID Properties              | Atomicity, Consistency, Isolation, Durability.           |
| Codd's Rules                 | 13 rules defining a truly relational database.           |
| Data Integrity               | Entity, Referential, Domain, User-Defined.               |
| T-SQL                        | Microsoft's SQL extension for SQL Server.                |
| Data Types                   | Choose wisely — affects storage, performance, integrity. |
| Schemas & Tables             | Schemas organize objects; tables store data.             |
| DDL / DML / DCL              | Define structure / manipulate data / control access.     |
| Constraints                  | PK, FK, UNIQUE, CHECK, DEFAULT, NOT NULL.                |

### Key T-SQL Statements Learned

```sql
-- DDL
CREATE DATABASE, CREATE SCHEMA, CREATE TABLE
ALTER TABLE (ADD, ALTER COLUMN, DROP COLUMN, ADD CONSTRAINT)
DROP TABLE IF EXISTS
TRUNCATE TABLE

-- DML
INSERT INTO ... VALUES
INSERT INTO ... SELECT
SELECT ... FROM ... WHERE
UPDATE ... SET ... WHERE
DELETE FROM ... WHERE

-- DCL
GRANT, REVOKE, DENY
```

### Mental Model: How It All Fits Together

```
┌─────────────────────────────────────────────────────┐
│                    SQL Server                        │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │              SchoolDB (Database)             │    │
│  │                                             │    │
│  │  ┌──────────────┐  ┌──────────────────┐     │    │
│  │  │ Academic      │  │ Admin            │     │    │
│  │  │ (Schema)      │  │ (Schema)         │     │    │
│  │  │               │  │                  │     │    │
│  │  │ - Departments │  │ - Staff          │     │    │
│  │  │ - Instructors │  │                  │     │    │
│  │  │ - Students    │  └──────────────────┘     │    │
│  │  │ - Courses     │                           │    │
│  │  │ - Enrollments │  ┌──────────────────┐     │    │
│  │  │ - CourseReviews│ │ dbo (Schema)     │     │    │
│  │  └──────────────┘  │ - (default)       │     │    │
│  │                     └──────────────────┘     │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  Security: GRANT / REVOKE / DENY                    │
│  Integrity: PK / FK / UNIQUE / CHECK / DEFAULT      │
│  Transactions: BEGIN TRAN / COMMIT / ROLLBACK       │
└─────────────────────────────────────────────────────┘
```

---

## 13. Practice Exercises

### Exercise 1: Create a Library Database

Create a database called `LibraryDB` with the following tables:

1. **Authors** — AuthorID (PK, identity), FirstName, LastName, Country
2. **Books** — BookID (PK, identity), Title, ISBN (unique), PublishedYear, Price, AuthorID (FK)
3. **Members** — MemberID (PK, identity), FullName, Email (unique), JoinDate (default today)
4. **Loans** — LoanID (PK, identity), BookID (FK), MemberID (FK), LoanDate, ReturnDate

**Requirements:**
- Price must be >= 0
- PublishedYear must be between 1450 and the current year
- ReturnDate must be >= LoanDate (or NULL)
- A member cannot borrow the same book twice at the same time

<details>
<summary>💡 Click to reveal solution</summary>

```sql
CREATE DATABASE LibraryDB;
GO
USE LibraryDB;
GO

CREATE TABLE dbo.Authors (
    AuthorID    INT           NOT NULL IDENTITY(1,1),
    FirstName   NVARCHAR(50)  NOT NULL,
    LastName    NVARCHAR(50)  NOT NULL,
    Country     NVARCHAR(50),
    CONSTRAINT PK_Authors PRIMARY KEY (AuthorID)
);

CREATE TABLE dbo.Books (
    BookID        INT            NOT NULL IDENTITY(1,1),
    Title         NVARCHAR(200)  NOT NULL,
    ISBN          VARCHAR(20)    NOT NULL,
    PublishedYear INT            NOT NULL,
    Price         DECIMAL(8,2)   NOT NULL,
    AuthorID      INT            NOT NULL,
    CONSTRAINT PK_Books PRIMARY KEY (BookID),
    CONSTRAINT UQ_Books_ISBN UNIQUE (ISBN),
    CONSTRAINT CK_Books_Price CHECK (Price >= 0),
    CONSTRAINT CK_Books_Year CHECK (PublishedYear BETWEEN 1450 AND YEAR(GETDATE())),
    CONSTRAINT FK_Books_Author FOREIGN KEY (AuthorID)
        REFERENCES dbo.Authors(AuthorID)
);

CREATE TABLE dbo.Members (
    MemberID    INT           NOT NULL IDENTITY(1,1),
    FullName    NVARCHAR(100) NOT NULL,
    Email       NVARCHAR(100) NOT NULL,
    JoinDate    DATE          NOT NULL CONSTRAINT DF_Members_JoinDate DEFAULT (GETDATE()),
    CONSTRAINT PK_Members PRIMARY KEY (MemberID),
    CONSTRAINT UQ_Members_Email UNIQUE (Email)
);

CREATE TABLE dbo.Loans (
    LoanID      INT  NOT NULL IDENTITY(1,1),
    BookID      INT  NOT NULL,
    MemberID    INT  NOT NULL,
    LoanDate    DATE NOT NULL,
    ReturnDate  DATE,
    CONSTRAINT PK_Loans PRIMARY KEY (LoanID),
    CONSTRAINT FK_Loans_Book FOREIGN KEY (BookID)
        REFERENCES dbo.Books(BookID),
    CONSTRAINT FK_Loans_Member FOREIGN KEY (MemberID)
        REFERENCES dbo.Members(MemberID),
    CONSTRAINT CK_Loans_ReturnDate CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate),
    CONSTRAINT UQ_Loans_Active UNIQUE (BookID, MemberID, LoanDate)
);
GO
```

</details>

---

### Exercise 2: Insert Sample Data

Insert at least:
- 3 authors
- 5 books
- 4 members
- 6 loans

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- Authors
INSERT INTO dbo.Authors (FirstName, LastName, Country)
VALUES
    (N'George',  N'Orwell',    N'United Kingdom'),
    (N'Harper',  N'Lee',       N'United States'),
    (N'Gabriel', N'García Márquez', N'Colombia');

-- Books
INSERT INTO dbo.Books (Title, ISBN, PublishedYear, Price, AuthorID)
VALUES
    (N'1984',                        '978-0451524935', 1949, 9.99,  1),
    (N'Animal Farm',                 '978-0451526342', 1945, 7.99,  1),
    (N'To Kill a Mockingbird',       '978-0061120084', 1960, 12.99, 2),
    (N'One Hundred Years of Solitude','978-0060883287', 1967, 14.99, 3),
    (N'Love in the Time of Cholera', '978-0307389732', 1985, 13.99, 3);

-- Members
INSERT INTO dbo.Members (FullName, Email)
VALUES
    (N'Alice Johnson',  N'alice@library.org'),
    (N'Bob Smith',      N'bob@library.org'),
    (N'Charlie Lee',    N'charlie@library.org'),
    (N'Diana Chen',     N'diana@library.org');

-- Loans
INSERT INTO dbo.Loans (BookID, MemberID, LoanDate, ReturnDate)
VALUES
    (1, 1, '2025-03-01', '2025-03-15'),
    (2, 1, '2025-03-10', NULL),
    (3, 2, '2025-03-05', '2025-03-20'),
    (4, 3, '2025-03-12', NULL),
    (1, 2, '2025-03-18', NULL),
    (5, 4, '2025-03-20', '2025-04-01');
```

</details>

---

### Exercise 3: Basic Queries

Write queries to:

1. List all books with their prices.
2. Find all members who joined in March 2025.
3. Find books priced between $10 and $15.
4. List all currently active loans (ReturnDate IS NULL).
5. Find members whose email contains 'library'.
6. Update the return date for LoanID 2 to today.
7. Delete all loans that have been returned.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
-- 1. All books with prices
SELECT Title, Price FROM dbo.Books;

-- 2. Members who joined in March 2025
SELECT * FROM dbo.Members
WHERE JoinDate BETWEEN '2025-03-01' AND '2025-03-31';

-- 3. Books priced $10-$15
SELECT Title, Price FROM dbo.Books
WHERE Price BETWEEN 10.00 AND 15.00;

-- 4. Active loans
SELECT * FROM dbo.Loans
WHERE ReturnDate IS NULL;

-- 5. Members with 'library' in email
SELECT * FROM dbo.Members
WHERE Email LIKE '%library%';

-- 6. Update return date
UPDATE dbo.Loans
SET ReturnDate = CAST(GETDATE() AS DATE)
WHERE LoanID = 2;

-- 7. Delete returned loans
DELETE FROM dbo.Loans
WHERE ReturnDate IS NOT NULL;
```

</details>

---

### Exercise 4: Constraint Testing

Try each of the following and **predict** whether it will succeed or fail
(and which constraint will be violated):

```sql
-- A) Insert a book with a negative price
INSERT INTO dbo.Books (Title, ISBN, PublishedYear, Price, AuthorID)
VALUES (N'Bad Price Book', '000-0000000000', 2020, -5.00, 1);

-- B) Insert a member with a duplicate email
INSERT INTO dbo.Members (FullName, Email)
VALUES (N'Fake Alice', N'alice@library.org');

-- C) Insert a loan where ReturnDate < LoanDate
INSERT INTO dbo.Loans (BookID, MemberID, LoanDate, ReturnDate)
VALUES (1, 1, '2025-04-01', '2025-03-01');

-- D) Insert a book referencing a non-existent author
INSERT INTO dbo.Books (Title, ISBN, PublishedYear, Price, AuthorID)
VALUES (N'Ghost Book', '111-1111111111', 2020, 10.00, 999);

-- E) Insert a valid book
INSERT INTO dbo.Books (Title, ISBN, PublishedYear, Price, AuthorID)
VALUES (N'Valid Book', '222-2222222222', 2020, 15.00, 2);
```

<details>
<summary>💡 Click to reveal answers</summary>

| Statement | Result | Constraint Violated            |
| --------- | ------ | ------------------------------ |
| A         | ❌ Fail | `CK_Books_Price` (Price >= 0) |
| B         | ❌ Fail | `UQ_Members_Email`            |
| C         | ❌ Fail | `CK_Loans_ReturnDate`         |
| D         | ❌ Fail | `FK_Books_Author`             |
| E         | ✅ Pass | None — all constraints met     |

</details>

---

### Exercise 5: Schema and Security

1. Create a new schema called `Reports`.
2. Create a table `Reports.MonthlyStats` with columns: Month (DATE), TotalLoans (INT), TotalReturns (INT).
3. Write a `GRANT` statement giving SELECT-only access on the `Reports` schema to a hypothetical user called `ReportViewer`.
4. Write a `DENY` statement preventing `ReportViewer` from deleting anything in the `Reports` schema.

<details>
<summary>💡 Click to reveal solution</summary>

```sql
CREATE SCHEMA Reports;
GO

CREATE TABLE Reports.MonthlyStats (
    Month         DATE NOT NULL PRIMARY KEY,
    TotalLoans    INT  NOT NULL DEFAULT 0,
    TotalReturns  INT  NOT NULL DEFAULT 0
);
GO

GRANT SELECT ON SCHEMA::Reports TO [ReportViewer];
GO

DENY DELETE ON SCHEMA::Reports TO [ReportViewer];
GO
```

</details>

---

## 🎯 End of Day 1

**Tomorrow (Day 2)** we will dive deeper into T-SQL:

- System functions (string, date, math, conversion)
- Advanced SELECT queries (GROUP BY, HAVING, ORDER BY)
- Advanced DML (MERGE, OUTPUT clause)
- Set operators (UNION, INTERSECT, EXCEPT)
- Hands-on exercises with real-world scenarios

**Homework:** Make sure you can create the `LibraryDB` from scratch without
looking at the solutions. Practice until the syntax feels natural!

---

> **Tip:** If you want extra practice, try creating a database for a domain
> you're interested in (e-commerce, gaming, sports, music) and define at least
> 4–5 related tables with proper constraints.