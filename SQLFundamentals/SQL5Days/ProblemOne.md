# Problem: School Database Design

Below is an ASCII-style ER diagram representing the tables and relationships for a school database. Use this diagram to design a normalized SQL Server database schema. Your solution should include appropriate primary keys, foreign keys, unique constraints, and check constraints where necessary.

```
+-------------------+        +-------------------+        +-------------------+
| Academic.Students |        | Academic.Enrollments|      | Academic.Courses  |
+-------------------+        +-------------------+        +-------------------+
| StudentID (PK)    |<--+    | EnrollmentID (PK) |    +-->| CourseID (PK)     |
| FirstName         |   |    | StudentID (FK)    |    |   | CourseName        |
| LastName          |   +----| CourseID (FK)     |----+   | Credits           |
| DateOfBirth       |        | EnrollDate        |        | DepartmentID (FK) |
| Email (UQ)        |        | Grade             |        | InstructorID (FK) |
| EnrollmentDate    |        +-------------------+        +-------------------+
+-------------------+                                      ^
                                                           |
                                                           |
+-------------------+        +-------------------+         |
| Academic.Departments|      | Academic.Instructors|       |
+-------------------+        +-------------------+         |
| DepartmentID (PK) |<--+    | InstructorID (PK) |---------+
| DepartmentName    |   +----| FirstName         |
| Building          |        | LastName          |
+-------------------+        | Email (UQ)        |
                             | DepartmentID (FK) |
                             +-------------------+
```

Legend:
- PK = Primary Key
- FK = Foreign Key
- UQ = Unique

**Task:**
Design the SQL Server schema for this school system. Write CREATE TABLE statements for each table, including all necessary constraints.

## Solution

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
