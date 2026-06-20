# Problem: Library Database Design

Below is an ER diagram description for a library management system. Use this as a prompt to design a normalized SQL Server schema. Your solution should include appropriate primary keys, foreign keys, unique constraints, and check constraints where necessary.

```
+-------------------+        +-------------------+
|     Authors       |        |      Books        |
+-------------------+        +-------------------+
| AuthorID (PK)     |<--+    | BookID (PK)       |
| FirstName         |   |    | Title             |
| LastName          |   +----| ISBN (UQ)         |
| Country           |        | PublishedYear     |
+-------------------+        | Price (>=0)       |
                             | AuthorID (FK)     |
                             +-------------------+

+-------------------+        +-------------------+
|     Members       |        |      Loans        |
+-------------------+        +-------------------+
| MemberID (PK)     |<--+    | LoanID (PK)       |
| FullName          |   |    | BookID (FK)       |
| Email (UQ)        |   +----| MemberID (FK)     |
| JoinDate (DF)     |        | LoanDate          |
+-------------------+        | ReturnDate        |
                             | UQ: (BookID,      |
                             |      MemberID,    |
                             |      LoanDate)    |
                             | CK: ReturnDate >= |
                             |     LoanDate      |
                             +-------------------+
```

Legend:
- PK = Primary Key
- FK = Foreign Key
- UQ = Unique
- DF = Default Value
- CK = Check Constraint

**Task:**
Design the SQL Server schema for this library system. Write CREATE TABLE statements for each table, including all necessary constraints and default values.

## Solution


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