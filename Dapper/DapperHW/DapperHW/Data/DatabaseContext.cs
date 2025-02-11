using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DapperHW.Data
{
    public class DatabaseContext
    {
        private readonly IConfiguration _configuration;
        private readonly string _connectionString;

        public DatabaseContext(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("DefaultConnection");
        }

        public IDbConnection CreateConnection()
            => new SqlConnection(_connectionString);

        public async Task EnsureStudentsTableExists()
        {
            var query = @"
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Students')
                BEGIN
                    CREATE TABLE Students (
                        Id INT PRIMARY KEY IDENTITY,
                        Name NVARCHAR(100) NOT NULL,
                        Age INT NOT NULL
                    )
                END

                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Courses')
                BEGIN
                    CREATE TABLE Courses (
                        Id INT PRIMARY KEY IDENTITY,
                        Title NVARCHAR(100) NOT NULL,
                        Credits INT NOT NULL
                    )
                END


                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CourseStudents')
                BEGIN
                    CREATE TABLE CourseStudents (
                        CourseId INT NOT NULL,
                        StudentId INT NOT NULL,
                        PRIMARY KEY (CourseId, StudentId),
                        FOREIGN KEY (CourseId) REFERENCES Courses(Id),
                        FOREIGN KEY (StudentId) REFERENCES Students(Id)
                    )
                END";

            using (var connection = CreateConnection())
            {
                await connection.ExecuteAsync(query);
            }
        }
    }
}
