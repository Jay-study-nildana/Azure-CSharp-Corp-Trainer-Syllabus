using DBPolyglot.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DBPolyglot.Data
{
    public interface IDbService
    {
        Task CreateAsync(Person p);
        Task<List<Person>> ReadAllAsync();
        Task UpdateAsync(Person p);
        Task DeleteAsync(string id);
        Task<bool> CheckAsync();
        Task SeedAsync(int count);
        Task<List<Person>> SearchAsync(string query);
        Task ResetAsync();
    }
}
