using Dapper;
using DapperHW.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DapperHW.Data
{
    public class StudentRepository
    {
        private readonly DatabaseContext _context;

        public StudentRepository(DatabaseContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Student>> GetAllStudents()
        {
            using (var connection = _context.CreateConnection())
            {
                var sql = "SELECT * FROM Students";
                return await connection.QueryAsync<Student>(sql);
            }
        }

        public async Task<Student> GetStudentById(int id)
        {
            using (var connection = _context.CreateConnection())
            {
                var sql = "SELECT * FROM Students WHERE Id = @Id";
                return await connection.QuerySingleOrDefaultAsync<Student>(sql, new { Id = id });
            }
        }

        public async Task<int> CreateStudent(Student student)
        {
            using (var connection = _context.CreateConnection())
            {
                var sql = "INSERT INTO Students (Name, Age) VALUES (@Name, @Age); SELECT CAST(SCOPE_IDENTITY() as int)";
                return await connection.ExecuteScalarAsync<int>(sql, student);
            }
        }

        public async Task<int> UpdateStudent(Student student)
        {
            using (var connection = _context.CreateConnection())
            {
                var sql = "UPDATE Students SET Name = @Name, Age = @Age WHERE Id = @Id";
                return await connection.ExecuteAsync(sql, student);
            }
        }

        public async Task<int> DeleteStudent(int id)
        {
            using (var connection = _context.CreateConnection())
            {
                var sql = "DELETE FROM Students WHERE Id = @Id";
                return await connection.ExecuteAsync(sql, new { Id = id });
            }
        }
    }
}
