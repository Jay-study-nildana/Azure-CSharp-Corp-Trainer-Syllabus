using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using DBPolyglot.Models;
using Microsoft.Extensions.Configuration;
using StackExchange.Redis;

namespace DBPolyglot.Data
{
    public class RedisService : IDbService, IDisposable
    {
        private readonly IDatabase _db;
        private readonly IConnectionMultiplexer _mux;

        public RedisService(IConfiguration cfg)
        {
            var cs = cfg.GetConnectionString("Redis") ?? throw new ArgumentNullException("Redis connection string missing");
            _mux = ConnectionMultiplexer.Connect(cs);
            _db = _mux.GetDatabase();
        }

        public Task CreateAsync(Person p)
        {
            try
            {
                var json = JsonSerializer.Serialize(p);
                return _db.StringSetAsync(GetKey(p.Id), json);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Redis CreateAsync error: {ex.Message}");
                return Task.CompletedTask;
            }
        }

        public async Task<List<Person>> ReadAllAsync()
        {
            try
            {
                var server = _mux.GetServer(_mux.GetEndPoints()[0]);
                var list = new List<Person>();
                await foreach (var key in server.KeysAsync(pattern: "person:*"))
                {
                    var v = await _db.StringGetAsync(key);
                    if (v.HasValue)
                    {
                        list.Add(JsonSerializer.Deserialize<Person>(v!)!);
                    }
                }
                return list;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Redis ReadAllAsync error: {ex.Message}");
                return new List<Person>();
            }
        }

        public Task UpdateAsync(Person p)
        {
            try
            {
                var json = JsonSerializer.Serialize(p);
                return _db.StringSetAsync(GetKey(p.Id), json);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Redis UpdateAsync error: {ex.Message}");
                return Task.CompletedTask;
            }
        }

        public Task DeleteAsync(string id)
        {
            try
            {
                return _db.KeyDeleteAsync(GetKey(id));
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Redis DeleteAsync error: {ex.Message}");
                return Task.CompletedTask;
            }
        }

        private static string GetKey(string id) => $"person:{id}";

        public void Dispose()
        {
            _mux?.Dispose();
        }

        public async Task<bool> CheckAsync()
        {
            try
            {
                var server = _mux.GetServer(_mux.GetEndPoints()[0]);
                var pong = await server.PingAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Redis CheckAsync failed: {ex.Message}");
                return false;
            }
        }

        public async Task SeedAsync(int count)
        {
            try
            {
                for (int i = 0; i < count; i++)
                {
                    var p = new Person { Id = Guid.NewGuid().ToString(), Name = $"Name_{i}", Email = $"user{i}@example.com" };
                    var json = JsonSerializer.Serialize(p);
                    await _db.StringSetAsync(GetKey(p.Id), json);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Redis SeedAsync error: {ex.Message}");
            }
        }

        public async Task<List<Person>> SearchAsync(string query)
        {
            try
            {
                var server = _mux.GetServer(_mux.GetEndPoints()[0]);
                var list = new List<Person>();
                await foreach (var key in server.KeysAsync(pattern: "person:*"))
                {
                    var v = await _db.StringGetAsync(key);
                    if (v.HasValue)
                    {
                        var p = JsonSerializer.Deserialize<Person>(v!);
                        if (p != null && (p.Name.Contains(query, StringComparison.OrdinalIgnoreCase) || p.Email.Contains(query, StringComparison.OrdinalIgnoreCase)))
                        {
                            list.Add(p);
                        }
                    }
                }
                return list;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Redis SearchAsync error: {ex.Message}");
                return new List<Person>();
            }
        }

        public async Task ResetAsync()
        {
            try
            {
                var server = _mux.GetServer(_mux.GetEndPoints()[0]);
                var keys = server.Keys(pattern: "person:*").ToArray();
                if (keys.Length > 0)
                {
                    await _db.KeyDeleteAsync(keys.Select(k => (RedisKey)k).ToArray());
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Redis ResetAsync error: {ex.Message}");
            }
        }
    }
}
