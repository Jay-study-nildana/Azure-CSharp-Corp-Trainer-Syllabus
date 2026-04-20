using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DBPolyglot.Data;
using DBPolyglot.Models;

namespace DBPolyglot.Tests
{
    // Simple in-memory mock implementation of IDbService for unit testing
    public class MockDbService : IDbService
    {
        private readonly Dictionary<string, Person> _store = new();

        public Task CreateAsync(Person p)
        {
            _store[p.Id] = p;
            return Task.CompletedTask;
        }

        public Task<List<Person>> ReadAllAsync()
        {
            var list = _store.Values.Select(p => new Person { Id = p.Id, Name = p.Name, Email = p.Email }).ToList();
            return Task.FromResult(list);
        }

        public Task UpdateAsync(Person p)
        {
            if (_store.ContainsKey(p.Id)) _store[p.Id] = p;
            return Task.CompletedTask;
        }

        public Task DeleteAsync(string id)
        {
            _store.Remove(id);
            return Task.CompletedTask;
        }

        public Task<bool> CheckAsync()
        {
            return Task.FromResult(true);
        }

        public Task SeedAsync(int count)
        {
            for (int i = 0; i < count; i++)
            {
                var p = new Person { Id = Guid.NewGuid().ToString(), Name = $"Name_{i}", Email = $"user{i}@example.com" };
                _store[p.Id] = p;
            }
            return Task.CompletedTask;
        }

        public Task<List<Person>> SearchAsync(string query)
        {
            var list = _store.Values.Where(p => p.Name.Contains(query, StringComparison.OrdinalIgnoreCase) || p.Email.Contains(query, StringComparison.OrdinalIgnoreCase)).Select(p => new Person { Id = p.Id, Name = p.Name, Email = p.Email }).ToList();
            return Task.FromResult(list);
        }

        public Task ResetAsync()
        {
            _store.Clear();
            return Task.CompletedTask;
        }
    }
}
