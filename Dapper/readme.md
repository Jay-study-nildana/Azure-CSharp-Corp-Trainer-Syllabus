# Dapper

Let's do some dapper. 

List of Topics

1. Overview of Dapper
1. Querying databases with DAPPER
1. Performance considerations with DAPPER

# Overview of Dapper

## What is Dapper?

Dapper is a simple object mapper for .NET. It extends the IDbConnection interface in .NET, providing a set of extension methods for executing SQL queries and mapping the results to .NET objects. Dapper was developed by the team at Stack Exchange to improve data access performance and simplify working with databases.

## Key Features

1. **Performance**: Dapper is one of the fastest data access libraries for .NET, often outperforming traditional ORMs like Entity Framework. It uses raw SQL queries and minimizes the overhead of mapping database results to objects.

2. **Simplicity**: Dapper is easy to use and requires minimal setup. You can start using it with just a few lines of code. Its API is straightforward and leverages familiar ADO.NET constructs.

3. **Compatibility**: Dapper works with any database that supports ADO.NET, including SQL Server, MySQL, PostgreSQL, SQLite, and more. This makes it a versatile choice for various database systems.

4. **Flexibility**: With Dapper, you can execute raw SQL queries, stored procedures, and even dynamic SQL. It provides methods for executing queries, commands, and mapping results to objects, lists, and other collections.

5. **Lightweight**: Dapper is a lightweight library with minimal dependencies. It focuses on performance and simplicity, avoiding the complexity and overhead of traditional ORMs.

## Benefits of Using Dapper

- **Improved Performance**: Dapper's performance is comparable to using raw ADO.NET, making it an excellent choice for performance-critical applications.
- **Ease of Use**: Dapper's API is easy to learn and use, allowing developers to quickly integrate it into their applications.
- **Reduced Boilerplate Code**: Dapper reduces the amount of boilerplate code needed for data access, making the codebase cleaner and more maintainable.
- **Flexibility and Control**: Dapper provides fine-grained control over SQL queries and database interactions, allowing developers to optimize queries and tune performance as needed.

## Getting Started with Dapper

To get started with Dapper, you need to install the Dapper package via NuGet. You can do this using the NuGet Package Manager in Visual Studio or by running the following command in the Package Manager Console:

```
Install-Package Dapper
```

Once installed, you can start using Dapper by creating a database connection and executing queries. Here is a simple example:

```csharp
using System;
using System.Data;
using System.Data.SqlClient;
using Dapper;

public class Program
{
    public static void Main()
    {
        string connectionString = "YourConnectionStringHere";

        using (IDbConnection db = new SqlConnection(connectionString))
        {
            string sql = "SELECT Id, Name, Age FROM Users WHERE Age > @Age";
            var users = db.Query<User>(sql, new { Age = 25 });

            foreach (var user in users)
            {
                Console.WriteLine($"{user.Id} - {user.Name} - {user.Age}");
            }
        }
    }
}

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int Age { get; set; }
}
```

In this example, we create a connection to the database using `SqlConnection`, define a SQL query to select users older than a certain age, and use Dapper's `Query` method to execute the query and map the results to a list of `User` objects.

# Querying Databases with Dapper

Dapper provides a set of extension methods for the `IDbConnection` interface that make it easy to execute SQL queries and map the results to .NET objects. In this guide, we'll cover the basics of querying databases with Dapper.

## Setting Up

Before you can start querying databases with Dapper, you need to install the Dapper package via NuGet. You can do this using the NuGet Package Manager in Visual Studio or by running the following command in the Package Manager Console:

```
Install-Package Dapper
```

## Basic Query

The most common method for querying databases with Dapper is the `Query` method. This method executes a SQL query and maps the results to a list of .NET objects.

Here's an example:

```csharp
using System;
using System.Data;
using System.Data.SqlClient;
using Dapper;

public class Program
{
    public static void Main()
    {
        string connectionString = "YourConnectionStringHere";

        using (IDbConnection db = new SqlConnection(connectionString))
        {
            string sql = "SELECT Id, Name, Age FROM Users WHERE Age > @Age";
            var users = db.Query<User>(sql, new { Age = 25 });

            foreach (var user in users)
            {
                Console.WriteLine($"{user.Id} - {user.Name} - {user.Age}");
            }
        }
    }
}

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int Age { get; set; }
}
```

In this example:
- We create a connection to the database using `SqlConnection`.
- We define a SQL query to select users older than a certain age.
- We use Dapper's `Query` method to execute the query and map the results to a list of `User` objects.
- We iterate over the results and print them to the console.

## Parameterized Queries

Dapper supports parameterized queries, which help prevent SQL injection attacks. You can pass parameters to your queries using anonymous objects.

Here's an example:

```csharp
using System;
using System.Data;
using System.Data.SqlClient;
using Dapper;

public class Program
{
    public static void Main()
    {
        string connectionString = "YourConnectionStringHere";

        using (IDbConnection db = new SqlConnection(connectionString))
        {
            string sql = "SELECT Id, Name, Age FROM Users WHERE Age > @Age";
            var users = db.Query<User>(sql, new { Age = 25 });

            foreach (var user in users)
            {
                Console.WriteLine($"{user.Id} - {user.Name} - {user.Age}");
            }
        }
    }
}

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int Age { get; set; }
}
```

In this example, the `@Age` parameter is replaced with the value `25` from the anonymous object.

## Executing Stored Procedures

Dapper can also execute stored procedures and map the results to .NET objects. You can do this using the `Query` method with the `CommandType.StoredProcedure` option.

Here's an example:

```csharp
using System;
using System.Data;
using System.Data.SqlClient;
using Dapper;

public class Program
{
    public static void Main()
    {
        string connectionString = "YourConnectionStringHere";

        using (IDbConnection db = new SqlConnection(connectionString))
        {
            string storedProcedure = "GetUsersByAge";
            var users = db.Query<User>(storedProcedure, new { Age = 25 }, commandType: CommandType.StoredProcedure);

            foreach (var user in users)
            {
                Console.WriteLine($"{user.Id} - {user.Name} - {user.Age}");
            }
        }
    }
}

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int Age { get; set; }
}
```

In this example, we execute the `GetUsersByAge` stored procedure and pass the `Age` parameter.

## Mapping Multiple Results

Dapper can map multiple result sets to different objects. You can do this using the `QueryMultiple` method.

Here's an example:

```csharp
using System;
using System.Data;
using System.Data.SqlClient;
using Dapper;

public class Program
{
    public static void Main()
    {
        string connectionString = "YourConnectionStringHere";

        using (IDbConnection db = new SqlConnection(connectionString))
        {
            string sql = "SELECT * FROM Users; SELECT * FROM Orders;";
            using (var multi = db.QueryMultiple(sql))
            {
                var users = multi.Read<User>().ToList();
                var orders = multi.Read<Order>().ToList();

                foreach (var user in users)
                {
                    Console.WriteLine($"{user.Id} - {user.Name} - {user.Age}");
                }

                foreach (var order in orders)
                {
                    Console.WriteLine($"{order.Id} - {order.UserId} - {order.Amount}");
                }
            }
        }
    }
}

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int Age { get; set; }
}

public class Order
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public decimal Amount { get; set; }
}
```

In this example, we execute a SQL query that returns multiple result sets and map the results to `User` and `Order` objects.

## Summary

Dapper makes it easy to query databases and map the results to .NET objects. It supports raw SQL queries, parameterized queries, stored procedures, and multiple result sets. By leveraging Dapper's extension methods, you can simplify your data access code and improve performance.

# Performance Considerations with Dapper

Dapper is known for its excellent performance, but there are still best practices and considerations to keep in mind to ensure optimal performance in your applications. This guide covers key performance considerations when using Dapper.

## 1. Use Parameterized Queries

Always use parameterized queries to prevent SQL injection attacks and to allow the database to cache execution plans. Parameterized queries are more secure and efficient.

```csharp
string sql = "SELECT Id, Name, Age FROM Users WHERE Age > @Age";
var users = db.Query<User>(sql, new { Age = 25 });
```

## 2. Minimize Data Retrieval

Retrieve only the data you need. Avoid using `SELECT *` and instead specify the columns you need. This reduces the amount of data transferred and improves performance.

```csharp
string sql = "SELECT Id, Name, Age FROM Users WHERE Age > @Age";
var users = db.Query<User>(sql, new { Age = 25 });
```

## 3. Use Efficient Data Types

Use appropriate data types for your database columns and parameters. For example, use `int` for numeric values and `varchar` for text. Efficient data types reduce storage requirements and improve query performance.

## 4. Leverage Indexes

Ensure that your database tables have appropriate indexes to improve query performance. Indexes help the database quickly locate the data you need. However, be mindful of the trade-offs, as indexes can slow down insert, update, and delete operations.

## 5. Optimize Query Execution Plans

Review and optimize your query execution plans. Use database tools to analyze and improve query performance. Ensure that your queries are making use of indexes and are not causing table scans.

## 6. Use Asynchronous Methods

Dapper provides asynchronous methods for executing queries, such as `QueryAsync` and `ExecuteAsync`. Using asynchronous methods can improve the responsiveness of your application, especially in scenarios with high concurrency.

```csharp
string sql = "SELECT Id, Name, Age FROM Users WHERE Age > @Age";
var users = await db.QueryAsync<User>(sql, new { Age = 25 });
```

## 7. Batch Operations

Batch multiple operations into a single round-trip to the database when possible. This reduces network latency and improves performance. You can use Dapper's `Execute` method to execute multiple commands in a single batch.

```csharp
string sql = "INSERT INTO Users (Name, Age) VALUES (@Name, @Age)";
var users = new[]
{
    new { Name = "Alice", Age = 30 },
    new { Name = "Bob", Age = 25 }
};
db.Execute(sql, users);
```

## 8. Connection Pooling

Enable connection pooling in your database connection settings to reuse database connections and reduce the overhead of opening and closing connections. Most ADO.NET providers support connection pooling by default.

## 9. Cache Query Results

Cache the results of frequently executed queries to reduce the load on the database. You can use in-memory caching or distributed caching solutions like Redis to store query results.

## 10. Monitor and Profile Performance

Regularly monitor and profile the performance of your database queries and application. Use profiling tools to identify and address performance bottlenecks. Tools like SQL Server Profiler, Entity Framework Profiler, and MiniProfiler can help you analyze query performance.

## Example: Performance Optimization

Here's an example that incorporates some of the performance considerations mentioned above:

```csharp
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Dapper;

public class Program
{
    public static async Task Main()
    {
        string connectionString = "YourConnectionStringHere";

        using (IDbConnection db = new SqlConnection(connectionString))
        {
            // Parameterized query with specific columns
            string sql = "SELECT Id, Name, Age FROM Users WHERE Age > @Age";
            var users = await db.QueryAsync<User>(sql, new { Age = 25 });

            foreach (var user in users)
            {
                Console.WriteLine($"{user.Id} - {user.Name} - {user.Age}");
            }

            // Batch insert
            string insertSql = "INSERT INTO Users (Name, Age) VALUES (@Name, @Age)";
            var newUsers = new[]
            {
                new { Name = "Charlie", Age = 28 },
                new { Name = "Diana", Age = 32 }
            };
            await db.ExecuteAsync(insertSql, newUsers);
        }
    }
}

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int Age { get; set; }
}
```

In this example, we use a parameterized query with specific columns, execute queries asynchronously, and perform a batch insert operation. These practices help optimize performance and improve the responsiveness of the application.

## Summary

Dapper is a high-performance data access library for .NET, but it's important to follow best practices to ensure optimal performance. Use parameterized queries, minimize data retrieval, leverage indexes, use efficient data types, and consider caching and connection pooling. Regularly monitor and profile performance to identify and address bottlenecks.