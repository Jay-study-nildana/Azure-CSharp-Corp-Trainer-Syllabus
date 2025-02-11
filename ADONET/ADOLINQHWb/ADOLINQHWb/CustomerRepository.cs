using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using System.Configuration;

namespace ADOLINQHWb
{
    public class CustomerRepository
    {
        private readonly string _connectionString;

        public CustomerRepository()
        {
            _connectionString = ConfigurationManager.ConnectionStrings["DemoDB"].ConnectionString;
        }

        public List<Customer> GetAllCustomers()
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                SqlDataAdapter adapter = new SqlDataAdapter("SELECT * FROM Customers", connection);
                DataSet dataSet = new DataSet();
                adapter.Fill(dataSet, "Customers");

                return dataSet.Tables["Customers"].AsEnumerable()
                    .Select(row => new Customer
                    {
                        CustomerID = row.Field<int>("CustomerID"),
                        CompanyName = row.Field<string>("CompanyName"),
                        ContactName = row.Field<string>("ContactName"),
                        Country = row.Field<string>("Country")
                    }).ToList();
            }
        }

        public void AddCustomer(Customer customer)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                SqlCommand command = new SqlCommand(
                    "INSERT INTO Customers (CompanyName, ContactName, Country) VALUES (@CompanyName, @ContactName, @Country)",
                    connection);
                command.Parameters.AddWithValue("@CompanyName", customer.CompanyName);
                command.Parameters.AddWithValue("@ContactName", customer.ContactName);
                command.Parameters.AddWithValue("@Country", customer.Country);
                command.ExecuteNonQuery();
            }
        }

        public void UpdateCustomer(Customer customer)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                SqlCommand command = new SqlCommand(
                    "UPDATE Customers SET CompanyName = @CompanyName, ContactName = @ContactName, Country = @Country WHERE CustomerID = @CustomerID",
                    connection);
                command.Parameters.AddWithValue("@CustomerID", customer.CustomerID);
                command.Parameters.AddWithValue("@CompanyName", customer.CompanyName);
                command.Parameters.AddWithValue("@ContactName", customer.ContactName);
                command.Parameters.AddWithValue("@Country", customer.Country);
                command.ExecuteNonQuery();
            }
        }

        public void DeleteCustomer(int customerId)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                SqlCommand command = new SqlCommand(
                    "DELETE FROM Customers WHERE CustomerID = @CustomerID",
                    connection);
                command.Parameters.AddWithValue("@CustomerID", customerId);
                command.ExecuteNonQuery();
            }
        }
    }
}
