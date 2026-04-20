using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DBPolyglot.Models;
using Microsoft.Extensions.Configuration;
using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Driver;

namespace DBPolyglot.Data
{
    public class MongoService : IDbService
    {
        private readonly IMongoCollection<Person> _col;
        private readonly IMongoClient _client;
        private readonly IMongoDatabase _db;

        public MongoService(IConfiguration cfg)
        {
            var cs = cfg.GetConnectionString("Mongo") ?? throw new ArgumentNullException("Mongo connection string missing");
            _client = new MongoClient(cs);
            _db = _client.GetDatabase("dbpolyglot");
            _col = _db.GetCollection<Person>("people");
        }

        public async Task CreateAsync(Person p)
        {
            try
            {
                await _col.InsertOneAsync(p);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Mongo CreateAsync error: {ex.Message}");
            }
        }

        public async Task<List<Person>> ReadAllAsync()
        {
            try
            {
                var all = await _col.FindAsync(FilterDefinition<Person>.Empty);
                return await all.ToListAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Mongo ReadAllAsync error: {ex.Message}");
                return new List<Person>();
            }
        }

        public async Task UpdateAsync(Person p)
        {
            try
            {
                await _col.ReplaceOneAsync(x => x.Id == p.Id, p, new ReplaceOptions { IsUpsert = false });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Mongo UpdateAsync error: {ex.Message}");
            }
        }

        public async Task DeleteAsync(string id)
        {
            try
            {
                await _col.DeleteOneAsync(x => x.Id == id);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Mongo DeleteAsync error: {ex.Message}");
            }
        }

        public async Task<bool> CheckAsync()
        {
            try
            {
                // Try a simple lightweight read
                var one = await _col.Find(FilterDefinition<Person>.Empty).Limit(1).FirstOrDefaultAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Mongo CheckAsync failed: {ex.Message}");
                return false;
            }
        }

        public async Task SeedAsync(int count)
        {
            try
            {
                var batch = new List<Person>(count);
                for (int i = 0; i < count; i++)
                {
                    batch.Add(new Person { Id = Guid.NewGuid().ToString(), Name = $"Name_{i}", Email = $"user{i}@example.com" });
                }
                if (batch.Count > 0) await _col.InsertManyAsync(batch);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Mongo SeedAsync error: {ex.Message}");
            }
        }

        public async Task<List<Person>> SearchAsync(string query)
        {
            try
            {
                var filter = Builders<Person>.Filter.Or(
                    Builders<Person>.Filter.Regex(p => p.Name, new MongoDB.Bson.BsonRegularExpression(query, "i")),
                    Builders<Person>.Filter.Regex(p => p.Email, new MongoDB.Bson.BsonRegularExpression(query, "i")));
                var results = await _col.Find(filter).ToListAsync();
                return results;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Mongo SearchAsync error: {ex.Message}");
                return new List<Person>();
            }
        }

        public async Task ResetAsync()
        {
            try
            {
                await _db.DropCollectionAsync("people");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Mongo ResetAsync error: {ex.Message}");
            }
        }
    }
}
