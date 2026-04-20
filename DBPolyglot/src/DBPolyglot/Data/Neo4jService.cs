using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DBPolyglot.Models;
using Microsoft.Extensions.Configuration;
using Neo4j.Driver;

namespace DBPolyglot.Data
{
    public class Neo4jService : IDbService, IAsyncDisposable
    {
        private readonly IDriver _driver;

        public Neo4jService(IConfiguration cfg)
        {
            var uri = cfg.GetConnectionString("Neo4j") ?? throw new ArgumentNullException("Neo4j connection string missing");
            var user = cfg.GetSection("Neo4j")["User"] ?? "neo4j";
            var pwd = cfg.GetSection("Neo4j")["Password"] ?? string.Empty;
            _driver = GraphDatabase.Driver(uri, AuthTokens.Basic(user, pwd));
        }

        public async Task CreateAsync(Person p)
        {
            try
            {
                await using var session = _driver.AsyncSession();
                await session.RunAsync("CREATE (p:Person {id:$id, name:$name, email:$email})", new { id = p.Id, name = p.Name, email = p.Email });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Neo4j CreateAsync error: {ex.Message}");
            }
        }

        public async Task<List<Person>> ReadAllAsync()
        {
            var list = new List<Person>();
            try
            {
                await using var session = _driver.AsyncSession();
                var cursor = await session.RunAsync("MATCH (p:Person) RETURN p.id AS id, p.name AS name, p.email AS email");
                while (await cursor.FetchAsync())
                {
                    var record = cursor.Current;
                    list.Add(new Person
                    {
                        Id = record["id"].As<string>(),
                        Name = record["name"].As<string>(),
                        Email = record["email"].As<string>()
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Neo4j ReadAllAsync error: {ex.Message}");
            }
            return list;
        }

        public async Task UpdateAsync(Person p)
        {
            try
            {
                await using var session = _driver.AsyncSession();
                await session.RunAsync("MATCH (p:Person {id:$id}) SET p.name=$name, p.email=$email", new { id = p.Id, name = p.Name, email = p.Email });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Neo4j UpdateAsync error: {ex.Message}");
            }
        }

        public async Task DeleteAsync(string id)
        {
            try
            {
                await using var session = _driver.AsyncSession();
                await session.RunAsync("MATCH (p:Person {id:$id}) DETACH DELETE p", new { id });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Neo4j DeleteAsync error: {ex.Message}");
            }
        }

        public async ValueTask DisposeAsync()
        {
            if (_driver != null)
            {
                await _driver.DisposeAsync();
            }
        }

        public async Task<bool> CheckAsync()
        {
            try
            {
                await using var session = _driver.AsyncSession();
                var cursor = await session.RunAsync("RETURN 1");
                await cursor.ConsumeAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Neo4j CheckAsync failed: {ex.Message}");
                return false;
            }
        }

        public async Task SeedAsync(int count)
        {
            try
            {
                await using var session = _driver.AsyncSession();
                for (int i = 0; i < count; i++)
                {
                    var id = Guid.NewGuid().ToString();
                    var name = $"Name_{i}";
                    var email = $"user{i}@example.com";
                    await session.RunAsync("CREATE (p:Person {id:$id, name:$name, email:$email})", new { id, name, email });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Neo4j SeedAsync error: {ex.Message}");
            }
        }

        public async Task<List<Person>> SearchAsync(string query)
        {
            var list = new List<Person>();
            try
            {
                await using var session = _driver.AsyncSession();
                var cursor = await session.RunAsync("MATCH (p:Person) WHERE p.name CONTAINS $q OR p.email CONTAINS $q RETURN p.id AS id, p.name AS name, p.email AS email", new { q = query });
                while (await cursor.FetchAsync())
                {
                    var record = cursor.Current;
                    list.Add(new Person
                    {
                        Id = record["id"].As<string>(),
                        Name = record["name"].As<string>(),
                        Email = record["email"].As<string>()
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Neo4j SearchAsync error: {ex.Message}");
            }
            return list;
        }

        public async Task ResetAsync()
        {
            try
            {
                await using var session = _driver.AsyncSession();
                await session.RunAsync("MATCH (p:Person) DETACH DELETE p");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Neo4j ResetAsync error: {ex.Message}");
            }
        }
    }
}
