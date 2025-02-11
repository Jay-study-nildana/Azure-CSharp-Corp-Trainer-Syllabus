using System;
using System.Configuration;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Linq;
using ADOLINQHWb;

// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");

//SQL Query to be run in the database. 
//Use SQL Server Management Studio to create the database and run the query.
//Also use Azure Data Studio to run the query and check connection string
//Just use both to check the connection string and run the query

//CREATE TABLE Customers (
//    CustomerID INT PRIMARY KEY IDENTITY,
//    CompanyName NVARCHAR(100),
//    ContactName NVARCHAR(100),
//    Country NVARCHAR(50)
//);
//GO

//INSERT INTO Customers (CompanyName, ContactName, Country) VALUES
//('Company A', 'Contact A', 'USA'),
//('Company B', 'Contact B', 'Canada'),
//('Company C', 'Contact C', 'UK'),
//('Company D', 'Contact D', 'USA'),
//('Company E', 'Contact E', 'Canada');
//GO

//CREATE TABLE Customers (
//    CustomerID INT PRIMARY KEY IDENTITY,
//    CompanyName NVARCHAR(100),
//    ContactName NVARCHAR(100),
//    Country NVARCHAR(50)
//);
//GO

//INSERT INTO Customers (CompanyName, ContactName, Country) VALUES
//('Company A', 'Contact A', 'USA'),
//('Company B', 'Contact B', 'Canada'),
//('Company C', 'Contact C', 'UK'),
//('Company D', 'Contact D', 'USA'),
//('Company E', 'Contact E', 'Canada');
//GO

string connectionString = ConfigurationManager.ConnectionStrings["DemoDB"].ConnectionString;

using (SqlConnection connection = new SqlConnection(connectionString))
{
    connection.Open();

    // Retrieve data using ADO.Net
    SqlDataAdapter adapter = new SqlDataAdapter("SELECT * FROM Customers", connection);
    DataSet dataSet = new DataSet();
    adapter.Fill(dataSet, "Customers");

    // Use LINQ to query the DataSet
    var customers = dataSet.Tables["Customers"].AsEnumerable()
        .Where(row => row.Field<string>("Country") == "USA")
        .Select(row => new
        {
            CustomerID = row.Field<int>("CustomerID"),
            CompanyName = row.Field<string>("CompanyName"),
            ContactName = row.Field<string>("ContactName"),
            Country = row.Field<string>("Country")
        });

    Console.WriteLine("Customers from USA:");
    foreach (var customer in customers)
    {
        Console.WriteLine($"ID: {customer.CustomerID}, Name: {customer.CompanyName}, Contact: {customer.ContactName}, Country: {customer.Country}");
    }
}

CustomerRepository customerRepository = new CustomerRepository();

// Retrieve all customers
var customers2 = customerRepository.GetAllCustomers();
Console.WriteLine("All Customers:");
foreach (var customer in customers2)
{
    Console.WriteLine($"ID: {customer.CustomerID}, Name: {customer.CompanyName}, Contact: {customer.ContactName}, Country: {customer.Country}");
}

// Add a new customer
Customer newCustomer = new Customer
{
    CompanyName = "New Company",
    ContactName = "New Contact",
    Country = "USA"
};
customerRepository.AddCustomer(newCustomer);
Console.WriteLine("New customer added.");

// Update an existing customer
var customerToUpdate = customers2.First();
customerToUpdate.CompanyName = "Updated Company";
customerRepository.UpdateCustomer(customerToUpdate);
Console.WriteLine("Customer updated.");

// Delete a customer
var customerToDelete = customers2.Last();
customerRepository.DeleteCustomer(customerToDelete.CustomerID);
Console.WriteLine("Customer deleted.");

// Retrieve and display customers from the USA using LINQ
var usCustomers = customerRepository.GetAllCustomers().Where(c => c.Country == "USA");
Console.WriteLine("Customers from USA:");
foreach (var customer in usCustomers)
{
    Console.WriteLine($"ID: {customer.CustomerID}, Name: {customer.CompanyName}, Contact: {customer.ContactName}, Country: {customer.Country}");
}
