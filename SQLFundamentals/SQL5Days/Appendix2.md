# Appendix 2

Some more notes and corrections for the curricullum.

## note 1

This is working for me                                         
                                                                 
  SELECT                                                         
      ProductName,                                               
      Price                                                      
  FROM                                                           
      dbo.Products                                               
  WHERE                                                          
      Price > (                                                  
          SELECT                                                 
              AVG(Price) AS AvgPrice                             
          FROM                                                   
              dbo.Products                                       
      )                                                          
  ORDER BY Price DESC;                                           
                                                                 
  But, what if, I want to display the AvgPrice in the 3rd Column?

● You can display the average price in the third column by using a subquery or CROSS JOIN to bring the average into each row. Here’s a simple way:

   SELECT
       p.ProductName,
       p.Price,
       avgdata.AvgPrice
   FROM 
       dbo.Products p
   CROSS JOIN
       (SELECT AVG(Price) AS AvgPrice FROM dbo.Products) avgdata
   WHERE
       p.Price > avgdata.AvgPrice
   ORDER BY p.Price DESC;

  This will show ProductName, Price, and the overall AvgPrice in every row of your result.

## note 2

Here, I cannot insert CEO. So, need to alter the TABLE first.

ALTER TABLE 
    dbo.Employees
ALTER COLUMN ManagerID INT NULL;

Then, I can insert 

INSERT INTO 
    dbo.Employees(FirstName,LastName,Title,ManagerID,HireDate,Salary)
VALUES
    (N'Sarah',N'Connor',N'CEO',0,'2018-01-15',150000.00),
    (N'James',   N'Kirk',    N'VP of Sales',         1,    '2019-03-01', 120000.00),
    (N'Nyota',   N'Uhura',   N'VP of Engineering',   1,    '2019-06-15', 125000.00),
    (N'Leonard', N'McCoy',   N'Sales Manager',       2,    '2020-02-01',  95000.00),
    (N'Hikaru',  N'Sulu',    N'Sales Representative',4,    '2021-05-10',  65000.00),
    (N'Pavel',   N'Chekov',  N'Sales Representative',4,    '2021-08-20',  62000.00),
    (N'Scotty',  N'Montgomery', N'Senior Engineer',  3,    '2020-04-01', 105000.00),
    (N'Spock',   N'Grayson', N'Engineer',            7,    '2021-09-15',  90000.00),
    (N'Christine', N'Chapel', N'Engineer',           7,    '2022-01-10',  85000.00),
    (N'Janice',  N'Rand',    N'Junior Engineer',     7,    '2023-06-01',  70000.00);

INSERT INTO                                                                                                                                                                                 
      dbo.Employees(FirstName,LastName,Title,ManagerID,HireDate,Salary)                                                                                                                       
  VALUES                                                                                                                                                                                      
      (N'Sarah',N'Connor',N'CEO',NULL,'2018-01-15',150000.00),                                                                                                                                
      (N'James',   N'Kirk',    N'VP of Sales',         1,    '2019-03-01', 120000.00),                                                                                                        
      (N'Nyota',   N'Uhura',   N'VP of Engineering',   1,    '2019-06-15', 125000.00),                                                                                                        
      (N'Leonard', N'McCoy',   N'Sales Manager',       2,    '2020-02-01',  95000.00),                                                                                                        
      (N'Hikaru',  N'Sulu',    N'Sales Representative',4,    '2021-05-10',  65000.00),                                                                                                        
      (N'Pavel',   N'Chekov',  N'Sales Representative',4,    '2021-08-20',  62000.00),                                                                                                        
      (N'Scotty',  N'Montgomery', N'Senior Engineer',  3,    '2020-04-01', 105000.00),                                                                                                        
      (N'Spock',   N'Grayson', N'Engineer',            7,    '2021-09-15',  90000.00),                                                                                                        
      (N'Christine', N'Chapel', N'Engineer',           7,    '2022-01-10',  85000.00),                                                                                                        
      (N'Janice',  N'Rand',    N'Junior Engineer',     7,    '2023-06-01',  70000.00);                                                                                                        
                                                                                                                                                                                              
  and it says                                                                                                                                                                                 
                                                                                                                                                                                              
  Started executing query at  Line 394                                                                                                                                                        
  Msg 547, Level 16, State 0, Line 1                                                                                                                                                          
  The INSERT statement conflicted with the FOREIGN KEY SAME TABLE constraint "FK_Employees_Manager". The conflict occurred in database "RetailDB", table "dbo.Employees", column 'EmployeeID'.
  The statement has been terminated.                                                                                                                                                          
  Total execution time: 00:00:00.026                                                                                                                                                          

● This error occurs because you are trying to insert employees who reference managers (by ManagerID) that do not yet exist in the table at the time of insertion. In a single multi-row INSERT, all rows are
  inserted at once, so the referenced EmployeeID values (e.g., 1, 2, 3, etc.) do not exist yet.

  How to fix:

   1. Insert the CEO first (with ManagerID = NULL).
   2. Insert the next level (e.g., VPs, referencing CEO’s EmployeeID).
   3. Continue inserting each level, referencing only EmployeeIDs that already exist.

  Example:

   -- 1. Insert CEO
   INSERT INTO dbo.Employees(FirstName,LastName,Title,ManagerID,HireDate,Salary)
   VALUES (N'Sarah',N'Connor',N'CEO',NULL,'2018-01-15',150000.00);
   
   -- 2. Insert VPs (ManagerID = 1, which is CEO's EmployeeID)
   INSERT INTO dbo.Employees(FirstName,LastName,Title,ManagerID,HireDate,Salary)
   VALUES
       (N'James', N'Kirk', N'VP of Sales', 1, '2019-03-01', 120000.00),
       (N'Nyota', N'Uhura', N'VP of Engineering', 1, '2019-06-15', 125000.00);
   
   -- 3. Insert next level, referencing correct ManagerIDs, and so on.

  Summary:
  You cannot insert all employees in one statement if they reference each other by EmployeeID. Insert them in hierarchical order, so each referenced manager already exists.

for some reason, the CEO has the ID 52, even though, she was inserted first. what gives?

● The EmployeeID is generated by the IDENTITY(1,1) property, which auto-increments for each new row. If you previously inserted and deleted rows from the Employees table, the identity value does not reset or
  reuse old numbers by default. It keeps incrementing from the last highest value.

  That’s why your CEO got EmployeeID 52: 

   - There were 51 previous inserts (even if deleted), so the next insert gets
    52.

  How to check the current identity value:

   SELECT IDENT_CURRENT('dbo.Employees');

  How to reset the identity seed (if you want to start from 1 again):

   DBCC CHECKIDENT ('dbo.Employees', RESEED, 0);

  (The next insert will be 1 if the table is empty, or the next highest if not.)

  
--

Look at this                                                                             
                                                                                           
  ;WITH                                                                                    
      SupplierCosts AS                                                                     
      (                                                                                    
          SELECT                                                                           
              ProductID,                                                                   
              MIN(Cost) AS BestCost,                                                       
              MIN(LeadDays) AS FastestDelivery                                             
          FROM                                                                             
              dbo.ProductSuppliers                                                         
          GROUP BY                                                                         
              ProductID                                                                    
      ),                                                                                   
      OrderStats AS                                                                        
      (                                                                                    
          SELECT                                                                           
              oi.ProductID,                                                                
              SUM(oi.Quantity) AS TotalQuantitySold,                                       
              SUM(oi.Quantity) AS TotalRevenue                                             
          FROM                                                                             
              dbo.OrderItems oi                                                            
          JOIN                                                                             
              dbo.Orders o ON oi.OrderID = o.OrderID                                       
          WHERE                                                                            
              o.Status <> N'Cancelled'                                                     
          GROUP BY                                                                         
              oi.ProductID                                                                 
      )                                                                                    
      SELECT                                                                               
          p.ProductName,                                                                   
          cat.CategoryName,                                                                
          p.Price AS SellingPrice,                                                         
          sc.BestCost,                                                                     
          ROUND(p.Price-ISNULL(sc.BestCost,0),2) AS Margin,                                
          CASE                                                                             
              WHEN                                                                         
                  sc.BestCost IS NULL THEN 'N/A'                                           
              ELSE                                                                         
                  CAST(ROUND((p.Price - sc.BestCost)/p.Price * 100,1) AS VARCHAR(10)) + '%'
          END AS MarginPct,                                                                
          ISNULL(os.TotalQuantitySold,0) AS QtySold,                                       
          ISNULL(os.TotalRevenue,0) AS Revenue,                                            
          sc.FastestDelivery AS LeadDays,                                                  
          CASE                                                                             
              WHEN os.TotalQuantitySold IS NULL THEN 'Never Ordered'                       
              WHEN os.TotalQuantitySold > 5 THEN 'High Demand'                             
              WHEN os.TotalQuantitySold > 2 THEN 'Moderate'                                
              ELSE 'Low Demand'                                                            
          END AS DemandLevel                                                               
      FROM                                                                                 
          dbo.Products p                                                                   
      JOIN                                                                                 
          dbo.Categories cat ON p.CategoryID = cat.CategoryID                              
      LEFT JOIN                                                                            
          SupplierCosts sc ON p.ProductID = sc.ProductID                                   
      LEFT JOIN                                                                            
          OrderStats os ON p.ProductID = os.ProductID                                      
      WHERE                                                                                
          p.IsActive = 1                                                                   
      ORDER BY                                                                             
          Revenue DESC;                                                                    
                                                                                           
  I keep seeing a overflow error                                                           
                                                                                           
  Started executing query at  Line 1233                                                    
  Msg 8115, Level 16, State 5, Line 1                                                      
  Arithmetic overflow error converting numeric to data type varchar.                       
  Total execution time: 00:00:00.021                                                       

● The error is caused by this line in your SELECT:

   CAST(ROUND((p.Price - sc.BestCost)/p.Price * 100,1) AS VARCHAR(10)) + '%'

  If p.Price is 0, you get a division by zero, which can cause an overflow or error when converting to VARCHAR. Also, if the result is a very large or very small number, it may not fit in VARCHAR(10).

  How to fix:

   1. Prevent division by zero: WHEN sc.BestCost IS NULL OR p.Price = 0 THEN 'N/A'
    ELSE CAST(ROUND((p.Price - sc.BestCost)/p.Price
    * 100,1) AS VARCHAR(20)) + '%'
   2. Increase VARCHAR size:
  Use VARCHAR(20) or larger to avoid overflow on large numbers.

  Corrected CASE:

   CASE
       WHEN sc.BestCost IS NULL OR p.Price = 0 THEN 'N/A'
       ELSE CAST(ROUND((p.Price - sc.BestCost)/p.Price * 100,1) AS VARCHAR(20)) + '%'
   END AS MarginPct

  This will prevent the overflow error and handle division by zero safely.

## note 3

Another error. 

CREATE TABLE Admin.Staff (
    StaffID INT NOT NULL IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    RoleStaff NVARCHAR(30) NOT NULL,
    HireDate DATE NOT NULL CONSTRAINT DF_Staff_HireDate DEFAULT (GETDATE()),
    Salary DECIMAL(10,2) NOT NULL,
    DepartmentID INT NOT NULL,

    CONSTRAINT PK_Staff PRIMARY KEY (StaffID),
    CONSTRAINT UQ_Staff_Email UNIQUE(Email),
    CONSTRAINT CK_Staff_Role CHECK (RoleStaff IN ('Admin','Support','Manager','Director')),
    CONSTRAINT CK_Staff_Salary CHECK (Salary > 0),
    CONSTRAINT FK_Staff_Department FOREIGN KEY (DepartmentID)
        REFERENCES Academic.Departments(DepartmentID)
);

--

 looks like is not quiet correct                            
                                                             
  CREATE TABLE Academic.CourseReviews(                       
      ReviewID INT NOT NULL IDENTITY (1,1) PRIMARY KEY,      
      CourseID INT NOT NULL,                                 
      StudentID INT NOT NULL,                                
      Rating TINYINT NOT NULL CHECK (Rating BETWEEN 1 and 5),
      Comment NVARCHAR(500),                                 
                                                             
      CONSTRAINT FK_Reviews_Course FOREIGN KEY(CourseID)     
          REFERENCES Academic.Courses(CourseID)              
          ON DELETE CASCADE                                  
          ON UPDATE CASCADE,                                 
                                                             
      CONSTRAINT FK_Reviews_Student FOREIGN KEY (StudentID)  
          REFERENCES Academic.Students(StudentID)            
          ON DELETE SET NULL                                 
          ON UPDATE NO ACTION                                
                                                             
  );                                                         

● The issue is with this part of your table definition:

   CONSTRAINT FK_Reviews_Student FOREIGN KEY (StudentID)
       REFERENCES Academic.Students(StudentID)
       ON DELETE SET NULL
       ON UPDATE NO ACTION

  Problem: 

   - StudentID is defined as NOT NULL, but ON DELETE SET NULL tries to set it to NULL when the referenced student is 
  deleted. This is not allowed because the column cannot be NULL.

  Solution: 

   - Either remove ON DELETE SET NULL (use ON DELETE NO ACTION or ON DELETE CASCADE),  
   - Or change StudentID to allow NULLs (remove NOT NULL).

  Example fix (option 1):

   StudentID INT NOT NULL,
   ...
   CONSTRAINT FK_Reviews_Student FOREIGN KEY (StudentID)
       REFERENCES Academic.Students(StudentID)
       ON DELETE NO ACTION
       ON UPDATE NO ACTION

  Example fix (option 2):

   StudentID INT NULL,
   ...
   CONSTRAINT FK_Reviews_Student FOREIGN KEY (StudentID)
       REFERENCES Academic.Students(StudentID)
       ON DELETE SET NULL
       ON UPDATE NO ACTION

  Choose the option that fits your data model.

❯ Yeah, it works now with this                               
                                                             
  CREATE TABLE Academic.CourseReviews(                       
      ReviewID INT NOT NULL IDENTITY (1,1) PRIMARY KEY,      
      CourseID INT NOT NULL,                                 
      StudentID INT NOT NULL,                                
      Rating TINYINT NOT NULL CHECK (Rating BETWEEN 1 and 5),
      Comment NVARCHAR(500),                                 
                                                             
      CONSTRAINT FK_Reviews_Course FOREIGN KEY(CourseID)     
          REFERENCES Academic.Courses(CourseID)              
          ON DELETE CASCADE                                  
          ON UPDATE CASCADE,                                 
                                                             
      CONSTRAINT FK_Reviews_Student FOREIGN KEY (StudentID)  
          REFERENCES Academic.Students(StudentID)            
          ON DELETE SET NULL                                 
          ON UPDATE NO ACTION                                
                                                             
  );                                                         

● Glad it works! Just a quick note: for ON DELETE SET NULL to function, StudentID must be defined as NULL (not NOT
  NULL). If you left NOT NULL, SQL Server will still throw an error when a referenced student is deleted. Double-check
  that StudentID is nullable:

   StudentID INT NULL,

  Otherwise, your table definition is correct!

❯ Sorry, this one is the correct one                         
                                                             
  CREATE TABLE Academic.CourseReviews(                       
      ReviewID INT NOT NULL IDENTITY (1,1) PRIMARY KEY,      
      CourseID INT NOT NULL,                                 
      StudentID INT,                                         
      Rating TINYINT NOT NULL CHECK (Rating BETWEEN 1 and 5),
      Comment NVARCHAR(500),                                 
                                                             
      CONSTRAINT FK_Reviews_Course FOREIGN KEY(CourseID)     
          REFERENCES Academic.Courses(CourseID)              
          ON DELETE CASCADE                                  
          ON UPDATE CASCADE,                                 
                                                             
      CONSTRAINT FK_Reviews_Student FOREIGN KEY (StudentID)  
          REFERENCES Academic.Students(StudentID)            
          ON DELETE SET NULL                                 
          ON UPDATE NO ACTION                                
                                                             
  );                                                         

● Perfect! This version is fully correct:

   - StudentID INT (nullable) allows ON DELETE SET NULL to work as intended.
   - All constraints and references are valid.

## note 5

when practising SQL, I usually delete the old practice DBs using SSMS. The problem is, everytime I try to drop all
the old DBS, for example...

Started executing query at Line 1  
 Msg 3702, Level 16, State 4, Line 1  
 Cannot drop database "April8A" because it is currently in use.  
 Total execution time: 00:00:20.011

How do I "force" drop databases because I am not actually using them anymore.

● To force drop a database in SQL Server, you need to set it to SINGLE_USER mode and roll back any open connections
before dropping it. Here’s how:

ALTER DATABASE [April8A] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [April8A];

This will disconnect all users and allow you to drop the database immediately. Replace [April8A] with your database
name as needed.

ALTER DATABASE [RetailDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [RetailDB];

I do this

DELETE  
 FROM Villains  
 WHERE Name = 'Joker';

It says

Started executing query at Line 1  
 Msg 547, Level 16, State 0, Line 1  
 The DELETE statement conflicted with the REFERENCE constraint "FK**COMICS**VillainI\_\_5441852A". The conflict
occurred in database "DCComicsDB", table "dbo.COMICS", column 'VillainID'.  
 The statement has been terminated.  
 Total execution time: 00:00:00.032

So, what are my options here to delete 'Joker'

● This error means there are rows in the Comics table that reference the Joker in Villains, so you can’t delete Joker
due to the foreign key constraint.

Your options:

1.  Delete dependent rows first: DELETE FROM Comics WHERE VillainID = (SELECT VillainID FROM Villains WHERE Name =
    'Joker');
    DELETE FROM Villains WHERE Name = 'Joker';
2.  Set up ON DELETE CASCADE on the foreign key, so deleting Joker also deletes related Comics (requires altering
    the table).
3.  Set VillainID to NULL in Comics (if allowed by your schema), then delete Joker.

Now, I did that. Error has changed

10:43:12 PM  
 Started executing query at Line 1  
 Msg 547, Level 16, State 0, Line 1  
 The DELETE statement conflicted with the REFERENCE constraint "FK**VillainTe**Villa\_\_5AEE82B9". The conflict
occurred in database "DCComicsDB", table "dbo.VillainTeamMemberships", column 'VillainID'.  
 The statement has been terminated.  
 Total execution time: 00:00:00.010

● This new error means there are still references to Joker in the VillainTeamMemberships table. You need to delete
those rows first:

DELETE FROM VillainTeamMemberships
WHERE VillainID = (SELECT VillainID FROM Villains WHERE Name = 'Joker');

After removing all dependent rows in related tables (Comics, VillainTeamMemberships, etc.), you’ll be able to delete
Joker from Villains. Always check for all foreign key dependencies before deleting a referenced row.

I added this procedure.

CREATE PROCEDURE GetSuperheroComics @SuperheroID INT AS
BEGIN  
 SELECT \*  
 FROM Comics WHERE SuperheroID = @SuperheroID  
 END;

How do I use this?

● You can call your stored procedure like this:

EXEC GetSuperheroComics @SuperheroID = 1;

or simply:

EXEC GetSuperheroComics 1;

Replace 1 with the desired SuperheroID. This will return all comics for that
superhero.

## end of notes.

end of notes