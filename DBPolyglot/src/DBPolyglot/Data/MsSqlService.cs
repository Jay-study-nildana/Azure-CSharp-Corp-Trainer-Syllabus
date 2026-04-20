using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using DBPolyglot.Models;

namespace DBPolyglot.Data
{
    public class MsSqlService : IDbService
    {
        private readonly string _conn;

        public MsSqlService(IConfiguration cfg)
        {
            _conn = cfg.GetConnectionString("MsSql") ?? throw new ArgumentNullException("MsSql connection string missing");
            try
            {
                EnsureTable().GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"MsSqlService initialization error: {ex.Message}");
            }
        }

        private async Task EnsureTable()
        {
            using var c = new SqlConnection(_conn);
            await c.OpenAsync();
            var sql = @"
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='People' and xtype='U')
BEGIN
    CREATE TABLE People (
        Id NVARCHAR(50) PRIMARY KEY,
        Name NVARCHAR(200),
        Email NVARCHAR(200)
    );
END
";
            await c.ExecuteAsync(sql);
        }

        public async Task CreateAsync(Person p)
        {
            try
            {
                using var c = new SqlConnection(_conn);
                await c.ExecuteAsync("INSERT INTO People (Id, Name, Email) VALUES (@Id, @Name, @Email)", p);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"MsSql CreateAsync error: {ex.Message}");
            }
        }

        public async Task<List<Person>> ReadAllAsync()
        {
            try
            {
                using var c = new SqlConnection(_conn);
                var rows = await c.QueryAsync<Person>("SELECT Id, Name, Email FROM People");
                return rows.AsList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"MsSql ReadAllAsync error: {ex.Message}");
                return new List<Person>();
            }
        }

        public async Task UpdateAsync(Person p)
        {
            try
            {
                using var c = new SqlConnection(_conn);
                await c.ExecuteAsync("UPDATE People SET Name=@Name, Email=@Email WHERE Id=@Id", p);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"MsSql UpdateAsync error: {ex.Message}");
            }
        }

        public async Task DeleteAsync(string id)
        {
            try
            {
                using var c = new SqlConnection(_conn);
                await c.ExecuteAsync("DELETE FROM People WHERE Id=@Id", new { Id = id });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"MsSql DeleteAsync error: {ex.Message}");
            }
        }

        public async Task<bool> CheckAsync()
        {
            try
            {
                using var c = new SqlConnection(_conn);
                await c.OpenAsync();
                await c.ExecuteScalarAsync("SELECT 1");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"MsSql CheckAsync failed: {ex.Message}");
                return false;
            }
        }

        public async Task SeedAsync(int count)
        {
            try
            {
                using var c = new SqlConnection(_conn);
                await c.OpenAsync();
                using var tx = await c.BeginTransactionAsync();
                for (int i = 0; i < count; i++)
                {
                    var p = new Person { Id = Guid.NewGuid().ToString(), Name = $"Name_{i}", Email = $"user{i}@example.com" };
                    await c.ExecuteAsync("INSERT INTO People (Id, Name, Email) VALUES (@Id, @Name, @Email)", p, tx);
                }
                await tx.CommitAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"MsSql SeedAsync error: {ex.Message}");
            }
        }

        public async Task<List<Person>> SearchAsync(string query)
        {
            try
            {
                using var c = new SqlConnection(_conn);
                var rows = await c.QueryAsync<Person>("SELECT Id, Name, Email FROM People WHERE Name LIKE @q OR Email LIKE @q", new { q = "%" + query + "%" });
                return rows.AsList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"MsSql SearchAsync error: {ex.Message}");
                return new List<Person>();
            }
        }

        public async Task ResetAsync()
        {
            try
            {
                using var c = new SqlConnection(_conn);
                await c.ExecuteAsync("DELETE FROM People");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"MsSql ResetAsync error: {ex.Message}");
            }
        }
    }
}
