using System;
using System.Linq;
using System.Threading.Tasks;
using DBPolyglot.Models;
using DBPolyglot.Data;
using Xunit;

namespace DBPolyglot.Tests
{
    public class CrudTests
    {
        // We run the same set of unit scenarios for each logical service name using MockDbService.
        // This yields 5 tests per service (Create, Read, Update, Delete, Check), 4 services => 20 tests.

        [Theory]
        [InlineData("MS SQL")]
        [InlineData("MongoDB")]
        [InlineData("Neo4j")]
        [InlineData("Redis")]
        public async Task Create_ShouldStorePerson(string serviceName)
        {
            IDbService svc = new MockDbService();
            var p = new Person { Id = Guid.NewGuid().ToString(), Name = serviceName + " - Alice", Email = "alice@example.com" };
            await svc.CreateAsync(p);
            var all = await svc.ReadAllAsync();
            Assert.Contains(all, x => x.Id == p.Id && x.Name == p.Name);
        }

        [Theory]
        [InlineData("MS SQL")]
        [InlineData("MongoDB")]
        [InlineData("Neo4j")]
        [InlineData("Redis")]
        public async Task Read_ShouldReturnAllInserted(string serviceName)
        {
            IDbService svc = new MockDbService();
            var p1 = new Person { Id = Guid.NewGuid().ToString(), Name = serviceName + " - A", Email = "a@example.com" };
            var p2 = new Person { Id = Guid.NewGuid().ToString(), Name = serviceName + " - B", Email = "b@example.com" };
            await svc.CreateAsync(p1);
            await svc.CreateAsync(p2);
            var all = await svc.ReadAllAsync();
            Assert.True(all.Count >= 2);
            Assert.Contains(all, x => x.Id == p1.Id);
            Assert.Contains(all, x => x.Id == p2.Id);
        }

        [Theory]
        [InlineData("MS SQL")]
        [InlineData("MongoDB")]
        [InlineData("Neo4j")]
        [InlineData("Redis")]
        public async Task Update_ShouldModifyExisting(string serviceName)
        {
            IDbService svc = new MockDbService();
            var p = new Person { Id = Guid.NewGuid().ToString(), Name = serviceName + " - Old", Email = "old@example.com" };
            await svc.CreateAsync(p);
            p.Name = serviceName + " - New";
            await svc.UpdateAsync(p);
            var found = (await svc.ReadAllAsync()).FirstOrDefault(x => x.Id == p.Id);
            Assert.NotNull(found);
            Assert.Equal(p.Name, found!.Name);
        }

        [Theory]
        [InlineData("MS SQL")]
        [InlineData("MongoDB")]
        [InlineData("Neo4j")]
        [InlineData("Redis")]
        public async Task Delete_ShouldRemove(string serviceName)
        {
            IDbService svc = new MockDbService();
            var p = new Person { Id = Guid.NewGuid().ToString(), Name = serviceName + " - ToDelete", Email = "del@example.com" };
            await svc.CreateAsync(p);
            await svc.DeleteAsync(p.Id);
            var all = await svc.ReadAllAsync();
            Assert.DoesNotContain(all, x => x.Id == p.Id);
        }

        [Theory]
        [InlineData("MS SQL")]
        [InlineData("MongoDB")]
        [InlineData("Neo4j")]
        [InlineData("Redis")]
        public async Task CheckAsync_ShouldReturnTrue(string serviceName)
        {
            IDbService svc = new MockDbService();
            var ok = await svc.CheckAsync();
            Assert.True(ok, $"CheckAsync returned false for {serviceName}");
        }

        [Theory]
        [InlineData("MS SQL")]
        [InlineData("MongoDB")]
        [InlineData("Neo4j")]
        [InlineData("Redis")]
        public async Task Seed_ShouldAddMany(string serviceName)
        {
            IDbService svc = new MockDbService();
            await svc.ResetAsync();
            await svc.SeedAsync(100);
            var all = await svc.ReadAllAsync();
            Assert.True(all.Count >= 100, $"Seed count mismatch for {serviceName}");
        }

        [Theory]
        [InlineData("MS SQL")]
        [InlineData("MongoDB")]
        [InlineData("Neo4j")]
        [InlineData("Redis")]
        public async Task Search_ShouldFindMatching(string serviceName)
        {
            IDbService svc = new MockDbService();
            await svc.ResetAsync();
            // seed predictable values
            await svc.CreateAsync(new Person { Id = "p1", Name = "CommonName", Email = "alpha@example.com" });
            await svc.CreateAsync(new Person { Id = "p2", Name = "Other", Email = "common@example.com" });
            await svc.CreateAsync(new Person { Id = "p3", Name = "Unique", Email = "unique@example.com" });

            var res1 = await svc.SearchAsync("CommonName");
            Assert.True(res1.Any(x => x.Id == "p1"), $"Search failed to find p1 for {serviceName}");

            var res2 = await svc.SearchAsync("common@example.com");
            Assert.True(res2.Any(x => x.Id == "p2"), $"Search failed to find p2 for {serviceName}");
        }

        [Theory]
        [InlineData("MS SQL")]
        [InlineData("MongoDB")]
        [InlineData("Neo4j")]
        [InlineData("Redis")]
        public async Task Reset_ShouldClearAll(string serviceName)
        {
            IDbService svc = new MockDbService();
            await svc.SeedAsync(10);
            var before = await svc.ReadAllAsync();
            Assert.True(before.Count >= 10, $"Pre-reset count insufficient for {serviceName}");
            await svc.ResetAsync();
            var after = await svc.ReadAllAsync();
            Assert.Empty(after);
        }
    }
}
