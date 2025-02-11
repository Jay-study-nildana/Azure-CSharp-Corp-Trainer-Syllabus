# .Net Fundamentals

Let's explore some .Net Fundamentals.

List of Topics.

1. Overview of .NET Core
2. Setting up .NET Core Projects
3. Console Applications
4. Entity Framework Core
5. Setting Up a Database Connection
6. CRUD Operations
7. Migrations and Data Seeding

Let's dive into the "Overview of .NET Core".

### Overview of .NET Core

.NET Core is an open-source, general-purpose development framework maintained by Microsoft and the .NET community on GitHub. It is cross-platform, supporting Windows, macOS, and Linux, and is used to build various applications, including web, mobile, desktop, cloud, and microservices. .NET Core is modular, lightweight, and highly performant, making it suitable for modern, scalable applications.

#### Key Features of .NET Core:

1. **Cross-platform**: Develop and run applications on Windows, macOS, and Linux.
2. **Open-source**: The .NET Core source code is available on GitHub, allowing developers to contribute and view the code.
3. **High Performance**: Optimized for performance, making it ideal for high-load and scalable applications.
4. **Modular Architecture**: Includes a modular set of libraries called "CoreFX" that you can include as needed.
5. **Unified Framework**: Supports multiple application types, including web, desktop, mobile, cloud, gaming, and IoT.
6. **CLI Tools**: Provides a set of CLI (Command-Line Interface) tools for development and continuous integration.
7. **Flexible Deployment**: Can be deployed as a stand-alone application or framework-dependent application.
8. **Compatibility**: Compatible with .NET Framework, Xamarin, and Mono, enabling code reuse and library sharing.

#### Ecosystem and Components:

1. **.NET Core Runtime**: The runtime is the execution environment for .NET Core applications. It includes the Just-In-Time (JIT) compiler, garbage collector, and other essential services.
2. **ASP.NET Core**: A framework for building modern, cloud-based, internet-connected applications, such as web apps, IoT apps, and mobile backends.
3. **Entity Framework Core (EF Core)**: An object-relational mapper (ORM) that simplifies data access by allowing developers to work with databases using .NET objects.
4. **.NET Core CLI**: Command-line tools for creating, building, running, and publishing .NET Core applications.
5. **Visual Studio and Visual Studio Code**: IDEs that provide rich development environments for .NET Core, with features like IntelliSense, debugging, and version control integration.
6. **NuGet**: A package manager for .NET that provides access to a vast ecosystem of libraries and tools.

#### Getting Started with .NET Core:

To get started with .NET Core, you need to install the .NET Core SDK, which includes the runtime, libraries, and tools needed for development. You can download the SDK from the [.NET Core website](https://dotnet.microsoft.com/download).

After installing the SDK, you can create a new project using the .NET Core CLI:
```bash
# Create a new console application
dotnet new console -o MyConsoleApp

# Navigate to the project directory
cd MyConsoleApp

# Run the application
dotnet run
```

This will create a simple console application that prints "Hello World!" to the console.

### Conclusion

.NET Core is a powerful and versatile framework for building a wide range of applications. Its cross-platform capabilities, high performance, and modular architecture make it an excellent choice for modern development. In the upcoming sections, we will explore how to set up .NET Core projects, create console applications, work with Entity Framework Core, and perform various database operations.

### Setting up .NET Core Projects

In this section, we'll cover how to set up .NET Core projects, including creating a new project, understanding the project structure, and configuring the project settings.

#### Prerequisites

Before you start, ensure you have the following installed on your system:

1. **.NET Core SDK**: You can download and install the SDK from the [.NET Core website](https://dotnet.microsoft.com/download).
2. **IDE**: An integrated development environment like Visual Studio, Visual Studio Code, or any other text editor of your choice.

#### Creating a New .NET Core Project

You can create a new .NET Core project using the .NET Core CLI or using an IDE like Visual Studio.

##### Using the .NET Core CLI

The .NET Core CLI provides a simple way to create and manage .NET Core projects.

1. **Open a command prompt or terminal**.
2. **Run the following command to create a new console application**:
   ```bash
   dotnet new console -o MyConsoleApp
   ```
   This command creates a new console application in a directory named `MyConsoleApp`.

3. **Navigate to the project directory**:
   ```bash
   cd MyConsoleApp
   ```

4. **Run the application**:
   ```bash
   dotnet run
   ```
   You should see the output "Hello World!" in the console.

##### Using Visual Studio

If you prefer using an IDE, Visual Studio provides a rich environment for creating and managing .NET Core projects.

1. **Open Visual Studio**.
2. **Create a new project**:
   - Go to `File > New > Project`.
   - Select `Console App` under `.NET Core`.
   - Click `Next`.
3. **Configure your project**:
   - Name your project `MyConsoleApp`.
   - Choose a location to save the project.
   - Click `Create`.

4. **Run the application**:
   - Press `F5` or click the `Run` button.
   - You should see the output "Hello World!" in the console.

#### Understanding the Project Structure

A typical .NET Core project has the following structure:

```plaintext
MyConsoleApp/
├── bin/
├── obj/
├── MyConsoleApp.csproj
└── Program.cs
```

- **bin/**: Contains the compiled binaries and executables.
- **obj/**: Contains temporary files used during the build process.
- **MyConsoleApp.csproj**: The project file that defines the project's settings and dependencies.
- **Program.cs**: The main source code file containing the entry point of the application.

#### Configuring the Project Settings

The project settings are defined in the `.csproj` file. Here is an example of a basic `.csproj` file:

```xml name=MyConsoleApp.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net6.0</TargetFramework>
  </PropertyGroup>
</Project>
```

- **Sdk**: Specifies the SDK to use for the project. For .NET Core projects, use `Microsoft.NET.Sdk`.
- **OutputType**: Specifies the type of output to generate. For console applications, use `Exe`.
- **TargetFramework**: Specifies the target framework for the project. For .NET 6, use `net6.0`.

#### Adding Dependencies

To add dependencies to your project, use the `dotnet add package` command. For example, to add the Newtonsoft.Json package, run the following command:

```bash
dotnet add package Newtonsoft.Json
```

This command updates the `.csproj` file to include the new dependency.

### Conclusion

Setting up a .NET Core project is straightforward with the .NET Core CLI or Visual Studio. Understanding the project structure and configuration options will help you manage and organize your projects effectively. In the next section, we will explore creating console applications in .NET Core.

### Console Applications

Console applications are simple programs that run in a command-line interface or terminal and interact with users through text input and output. In this section, we'll cover how to create and run a console application in .NET Core, manage dependencies, and structure your code.

#### Creating a Console Application

You can create a new console application using the .NET Core CLI or Visual Studio.

##### Using the .NET Core CLI

1. **Open a command prompt or terminal**.
2. **Run the following command to create a new console application**:
   ```bash
   dotnet new console -o MyConsoleApp
   ```
   This command creates a new console application in a directory named `MyConsoleApp`.

3. **Navigate to the project directory**:
   ```bash
   cd MyConsoleApp
   ```

4. **Run the application**:
   ```bash
   dotnet run
   ```
   You should see the output "Hello World!" in the console.

##### Using Visual Studio

1. **Open Visual Studio**.
2. **Create a new project**:
   - Go to `File > New > Project`.
   - Select `Console App` under `.NET Core`.
   - Click `Next`.
3. **Configure your project**:
   - Name your project `MyConsoleApp`.
   - Choose a location to save the project.
   - Click `Create`.

4. **Run the application**:
   - Press `F5` or click the `Run` button.
   - You should see the output "Hello World!" in the console.

#### Understanding the Program.cs File

The `Program.cs` file contains the entry point of the application. Here is an example of a basic `Program.cs` file:

```csharp name=Program.cs
using System;

namespace MyConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
        }
    }
}
```

- **using System;**: Imports the System namespace, which contains fundamental classes and base classes that define commonly-used values and reference data types.
- **namespace MyConsoleApp**: Defines a namespace to organize your code.
- **class Program**: Defines a class named `Program`.
- **static void Main(string[] args)**: The `Main` method is the entry point of the application. It is called when the application starts. The `args` parameter is an array of strings that can contain command-line arguments.

#### Managing Dependencies

To add dependencies to your console application, use the `dotnet add package` command. For example, to add the Newtonsoft.Json package, run the following command:

```bash
dotnet add package Newtonsoft.Json
```

This command updates the `.csproj` file to include the new dependency. Your updated `.csproj` file might look like this:

```xml name=MyConsoleApp.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net6.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Newtonsoft.Json" Version="13.0.1" />
  </ItemGroup>
</Project>
```

#### Reading Input and Writing Output

You can read input from the user and write output to the console using the `Console` class. Here is an example that asks the user for their name and greets them:

```csharp name=Program.cs
using System;

namespace MyConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.Write("Enter your name: ");
            string name = Console.ReadLine();
            Console.WriteLine($"Hello, {name}!");
        }
    }
}
```

- **Console.Write("Enter your name: ");**: Writes a prompt message to the console.
- **string name = Console.ReadLine();**: Reads a line of input from the user and stores it in the `name` variable.
- **Console.WriteLine($"Hello, {name}!");**: Writes a greeting message to the console, using string interpolation to include the user's name.

#### Structuring Your Code

As your application grows, you may want to organize your code into multiple classes and files. Here is an example of a simple console application with multiple classes:

```csharp name=Program.cs
using System;

namespace MyConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Greeter greeter = new Greeter();
            greeter.Greet();
        }
    }
}
```

```csharp name=Greeter.cs
using System;

namespace MyConsoleApp
{
    class Greeter
    {
        public void Greet()
        {
            Console.Write("Enter your name: ");
            string name = Console.ReadLine();
            Console.WriteLine($"Hello, {name}!");
        }
    }
}
```

In this example, the `Greeter` class is defined in a separate file (`Greeter.cs`), making the code more organized and maintainable.

### Conclusion

Creating and managing console applications in .NET Core is straightforward with the .NET Core CLI and Visual Studio. By understanding the basics of reading input and writing output, managing dependencies, and structuring your code, you can build robust console applications. In the next section, we will explore Entity Framework Core and how to set up a database connection.

### Entity Framework Core

Entity Framework Core (EF Core) is a modern, open-source, and cross-platform version of the popular Entity Framework data access technology. EF Core is an object-relational mapper (ORM) that enables .NET developers to work with databases using .NET objects, eliminating the need for most of the data-access code that developers usually need to write.

#### Key Features of EF Core

1. **Cross-Platform**: Works on Windows, macOS, and Linux.
2. **Modular and Lightweight**: Allows you to include only the features you need.
3. **High Performance**: Optimized for performance and scalability.
4. **LINQ Queries**: Supports LINQ (Language Integrated Query) for querying data.
5. **Change Tracking**: Keeps track of changes to your objects and persists them to the database.
6. **Migrations**: Provides a way to incrementally update the database schema to keep it in sync with the application's data model.

#### Setting Up EF Core

To get started with EF Core, you need to install the necessary packages and set up a data context. Here is a step-by-step guide to setting up EF Core in a .NET Core console application.

##### Step 1: Create a New .NET Core Console Application

You can create a new console application using the .NET Core CLI:

```bash
dotnet new console -o MyEfCoreApp
cd MyEfCoreApp
```

##### Step 2: Install EF Core Packages

Install the EF Core packages using the `dotnet add package` command:

```bash
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
```

- `Microsoft.EntityFrameworkCore`: The core EF Core package.
- `Microsoft.EntityFrameworkCore.SqlServer`: The SQL Server provider package.
- `Microsoft.EntityFrameworkCore.Tools`: Tools for EF Core, including migrations.

##### Step 3: Define Your Data Model

Create a new folder named `Models` and define your data model classes. For example, create a `Product` class:

```csharp name=Models/Product.cs
namespace MyEfCoreApp.Models
{
    public class Product
    {
        public int ProductId { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
    }
}
```

##### Step 4: Create the Data Context

Create a new class named `AppDbContext` that inherits from `DbContext`. This class represents the session with the database and allows you to query and save data.

```csharp name=AppDbContext.cs
using Microsoft.EntityFrameworkCore;
using MyEfCoreApp.Models;

namespace MyEfCoreApp
{
    public class AppDbContext : DbContext
    {
        public DbSet<Product> Products { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=MyEfCoreAppDb;Trusted_Connection=True;");
        }
    }
}
```

- `DbSet<Product>`: Represents the collection of `Product` entities in the context.
- `OnConfiguring`: Configures the database to be used (SQL Server in this case).

##### Step 5: Add the Initial Migration

To create the initial database schema, you need to add a migration. Run the following command:

```bash
dotnet ef migrations add InitialCreate
```

This command generates code to create the initial database schema based on the defined data model.

##### Step 6: Update the Database

Apply the migration to create the database schema:

```bash
dotnet ef database update
```

This command applies the migration and creates the database with the specified schema.

##### Step 7: Use the Data Context

You can now use the `AppDbContext` to interact with the database. For example, you can add, update, delete, and query `Product` entities.

```csharp name=Program.cs
using System;
using System.Linq;
using MyEfCoreApp.Models;

namespace MyEfCoreApp
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var context = new AppDbContext())
            {
                // Add a new product
                var product = new Product { Name = "Apple", Price = 0.99M };
                context.Products.Add(product);
                context.SaveChanges();

                // Query products
                var products = context.Products.ToList();
                foreach (var p in products)
                {
                    Console.WriteLine($"ID: {p.ProductId}, Name: {p.Name}, Price: {p.Price}");
                }
            }
        }
    }
}
```

This example demonstrates how to add a new product to the database and query all products.

### Conclusion

Entity Framework Core is a powerful ORM that simplifies data access in .NET Core applications. By following the steps outlined above, you can set up EF Core, define your data model, and interact with the database using a data context. In the next section, we will explore how to set up a database connection in more detail.

### Setting Up a Database Connection

Setting up a database connection in a .NET Core application involves configuring the connection string and initializing the database context. In this section, we'll walk through the steps to set up a database connection using Entity Framework Core.

#### Step 1: Create the Project

If you haven't already created a project, you can create a new .NET Core console application:

```bash
dotnet new console -o MyEfCoreApp
cd MyEfCoreApp
```

#### Step 2: Install EF Core Packages

Make sure you have the necessary EF Core packages installed. You can do this using the following commands:

```bash
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
```

#### Step 3: Define the Data Model

Create a `Models` folder and define your data model classes. For example, create a `Product` class:

```csharp name=Models/Product.cs
namespace MyEfCoreApp.Models
{
    public class Product
    {
        public int ProductId { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
    }
}
```

#### Step 4: Create the Data Context

Create a class that inherits from `DbContext`. This class will represent the session with the database and allow you to query and save data.

```csharp name=AppDbContext.cs
using Microsoft.EntityFrameworkCore;
using MyEfCoreApp.Models;

namespace MyEfCoreApp
{
    public class AppDbContext : DbContext
    {
        public DbSet<Product> Products { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=MyEfCoreAppDb;Trusted_Connection=True;");
        }
    }
}
```

- **DbSet<Product>**: Represents the collection of `Product` entities in the context.
- **OnConfiguring**: Configures the database to be used (SQL Server in this case).

#### Step 5: Configure the Connection String

In a real-world application, you would typically store the connection string in a configuration file. Create an `appsettings.json` file to store the connection string:

```json name=appsettings.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=MyEfCoreAppDb;Trusted_Connection=True;"
  }
}
```

Update the `AppDbContext` to read the connection string from the configuration file:

```csharp name=AppDbContext.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MyEfCoreApp.Models;
using System.IO;

namespace MyEfCoreApp
{
    public class AppDbContext : DbContext
    {
        public DbSet<Product> Products { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json")
                .Build();

            optionsBuilder.UseSqlServer(config.GetConnectionString("DefaultConnection"));
        }
    }
}
```

#### Step 6: Initialize the Database

To create the initial database schema, you need to add a migration and update the database:

1. **Add the Initial Migration**:
   ```bash
   dotnet ef migrations add InitialCreate
   ```

2. **Update the Database**:
   ```bash
   dotnet ef database update
   ```

#### Step 7: Use the Data Context

You can now use the `AppDbContext` to interact with the database. For example, you can add, update, delete, and query `Product` entities.

```csharp name=Program.cs
using System;
using System.Linq;
using MyEfCoreApp.Models;

namespace MyEfCoreApp
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var context = new AppDbContext())
            {
                // Add a new product
                var product = new Product { Name = "Apple", Price = 0.99M };
                context.Products.Add(product);
                context.SaveChanges();

                // Query products
                var products = context.Products.ToList();
                foreach (var p in products)
                {
                    Console.WriteLine($"ID: {p.ProductId}, Name: {p.Name}, Price: {p.Price}");
                }
            }
        }
    }
}
```

### Conclusion

Setting up a database connection in a .NET Core application involves configuring the connection string, initializing the data context, and using EF Core's migration tools to create and update the database schema. By following the steps outlined above, you can set up a database connection and interact with the database in your .NET Core application. In the next section, we will explore CRUD operations using EF Core.

### CRUD Operations (with EF Core)

CRUD stands for Create, Read, Update, and Delete. These are the basic operations you can perform on data in a database. In this section, we'll explore how to perform CRUD operations using Entity Framework Core in a .NET Core application.

#### Prerequisites

Ensure you have set up your .NET Core project with Entity Framework Core and a database connection as described in the previous sections. 

#### Step 1: Create a New .NET Core Console Application

If you haven't already created a project, you can create a new .NET Core console application:

```bash
dotnet new console -o MyEfCoreApp
cd MyEfCoreApp
```

#### Step 2: Install EF Core Packages

Make sure you have the necessary EF Core packages installed. You can do this using the following commands:

```bash
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
```

#### Step 3: Define the Data Model

Create a `Models` folder and define your data model classes. For example, create a `Product` class:

```csharp name=Models/Product.cs
namespace MyEfCoreApp.Models
{
    public class Product
    {
        public int ProductId { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
    }
}
```

#### Step 4: Create the Data Context

Create a class that inherits from `DbContext`. This class will represent the session with the database and allow you to query and save data.

```csharp name=AppDbContext.cs
using Microsoft.EntityFrameworkCore;
using MyEfCoreApp.Models;

namespace MyEfCoreApp
{
    public class AppDbContext : DbContext
    {
        public DbSet<Product> Products { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=MyEfCoreAppDb;Trusted_Connection=True;");
        }
    }
}
```

#### Step 5: Configure the Connection String

In a real-world application, you would typically store the connection string in a configuration file. Create an `appsettings.json` file to store the connection string:

```json name=appsettings.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=MyEfCoreAppDb;Trusted_Connection=True;"
  }
}
```

Update the `AppDbContext` to read the connection string from the configuration file:

```csharp name=AppDbContext.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MyEfCoreApp.Models;
using System.IO;

namespace MyEfCoreApp
{
    public class AppDbContext : DbContext
    {
        public DbSet<Product> Products { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json")
                .Build();

            optionsBuilder.UseSqlServer(config.GetConnectionString("DefaultConnection"));
        }
    }
}
```

#### Step 6: Initialize the Database

To create the initial database schema, you need to add a migration and update the database:

1. **Add the Initial Migration**:
   ```bash
   dotnet ef migrations add InitialCreate
   ```

2. **Update the Database**:
   ```bash
   dotnet ef database update
   ```

#### Step 7: Implementing CRUD Operations

Now that we have our setup ready, let's implement the CRUD operations.

##### Create Operation

To add a new record to the database, use the `Add` method and `SaveChanges` to persist the changes.

```csharp name=Program.cs
using System;
using MyEfCoreApp.Models;

namespace MyEfCoreApp
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var context = new AppDbContext())
            {
                // Create
                var product = new Product { Name = "Apple", Price = 0.99M };
                context.Products.Add(product);
                context.SaveChanges();
                Console.WriteLine("Product created.");
            }
        }
    }
}
```

##### Read Operation

To retrieve records from the database, use the `ToList` method for querying all records, and `Find` method for querying a specific record by key.

```csharp name=Program.cs
using System;
using System.Linq;
using MyEfCoreApp.Models;

namespace MyEfCoreApp
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var context = new AppDbContext())
            {
                // Read
                var products = context.Products.ToList();
                foreach (var product in products)
                {
                    Console.WriteLine($"ID: {product.ProductId}, Name: {product.Name}, Price: {product.Price}");
                }
            }
        }
    }
}
```

##### Update Operation

To update an existing record, retrieve the entity, modify its properties, and call `SaveChanges`.

```csharp name=Program.cs
using System;
using MyEfCoreApp.Models;

namespace MyEfCoreApp
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var context = new AppDbContext())
            {
                // Update
                var product = context.Products.FirstOrDefault(p => p.Name == "Apple");
                if (product != null)
                {
                    product.Price = 1.49M;
                    context.SaveChanges();
                    Console.WriteLine("Product updated.");
                }
            }
        }
    }
}
```

##### Delete Operation

To delete a record, retrieve the entity, call the `Remove` method, and then call `SaveChanges`.

```csharp name=Program.cs
using System;
using MyEfCoreApp.Models;

namespace MyEfCoreApp
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var context = new AppDbContext())
            {
                // Delete
                var product = context.Products.FirstOrDefault(p => p.Name == "Apple");
                if (product != null)
                {
                    context.Products.Remove(product);
                    context.SaveChanges();
                    Console.WriteLine("Product deleted.");
                }
            }
        }
    }
}
```

### Conclusion

This section covered the basic CRUD operations using Entity Framework Core in a .NET Core application. These operations allow you to create, read, update, and delete records in your database. By following the examples provided, you can implement these operations in your own applications.

In the next section, we will explore migrations and data seeding in more detail.

### Migrations and Data Seeding

Migrations and data seeding are essential concepts in Entity Framework Core. Migrations allow you to incrementally update your database schema, while data seeding allows you to populate the database with initial data. In this section, we'll explore how to use migrations to update the database schema and how to seed the database with initial data.

#### Prerequisites

Ensure you have set up your .NET Core project with Entity Framework Core and a database connection as described in the previous sections.

#### Step 1: Create the Project

If you haven't already created a project, you can create a new .NET Core console application:

```bash
dotnet new console -o MyEfCoreApp
cd MyEfCoreApp
```

#### Step 2: Install EF Core Packages

Make sure you have the necessary EF Core packages installed. You can do this using the following commands:

```bash
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
```

#### Step 3: Define the Data Model

Create a `Models` folder and define your data model classes. For example, create a `Product` class:

```csharp name=Models/Product.cs
namespace MyEfCoreApp.Models
{
    public class Product
    {
        public int ProductId { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
    }
}
```

#### Step 4: Create the Data Context

Create a class that inherits from `DbContext`. This class will represent the session with the database and allow you to query and save data.

```csharp name=AppDbContext.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MyEfCoreApp.Models;
using System.IO;

namespace MyEfCoreApp
{
    public class AppDbContext : DbContext
    {
        public DbSet<Product> Products { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json")
                .Build();

            optionsBuilder.UseSqlServer(config.GetConnectionString("DefaultConnection"));
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Data seeding
            modelBuilder.Entity<Product>().HasData(
                new Product { ProductId = 1, Name = "Apple", Price = 0.99M },
                new Product { ProductId = 2, Name = "Banana", Price = 0.59M }
            );
        }
    }
}
```

- **DbSet<Product>**: Represents the collection of `Product` entities in the context.
- **OnConfiguring**: Configures the database to be used (SQL Server in this case).
- **OnModelCreating**: Seeds the database with initial data.

#### Step 5: Configure the Connection String

In a real-world application, you would typically store the connection string in a configuration file. Create an `appsettings.json` file to store the connection string:

```json name=appsettings.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=MyEfCoreAppDb;Trusted_Connection=True;"
  }
}
```

#### Step 6: Add Migrations

To create the initial database schema and apply changes, you need to add migrations. Migrations are a way to keep track of changes to the database schema over time.

1. **Add the Initial Migration**:
   ```bash
   dotnet ef migrations add InitialCreate
   ```

   This command generates code to create the initial database schema based on the defined data model.

2. **Apply the Migration**:
   ```bash
   dotnet ef database update
   ```

   This command applies the migration and creates the database with the specified schema and initial data.

#### Step 7: Modify the Data Model

Let's say you want to add a new property to the `Product` class. For example, add a `Category` property:

```csharp name=Models/Product.cs
namespace MyEfCoreApp.Models
{
    public class Product
    {
        public int ProductId { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
        public string Category { get; set; } // New property
    }
}
```

#### Step 8: Add a New Migration

After modifying the data model, you need to add a new migration to update the database schema:

```bash
dotnet ef migrations add AddCategoryToProduct
```

This command generates code to add the new `Category` column to the `Product` table.

#### Step 9: Apply the Migration

Apply the migration to update the database schema:

```bash
dotnet ef database update
```

This command updates the database to include the new `Category` column.

#### Conclusion

Migrations and data seeding are essential for managing database schema changes and populating the database with initial data. By following the steps outlined above, you can use EF Core migrations to keep your database schema in sync with your data model and seed the database with initial data.

In this section, we covered how to create and apply migrations, modify the data model, and seed the database with initial data. These concepts are crucial for maintaining and evolving your database schema over time.

