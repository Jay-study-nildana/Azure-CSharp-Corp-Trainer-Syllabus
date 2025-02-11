using Dapper;
using DapperHW.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DapperHW.Data
{
    public class CourseRepository
    {
        private readonly DatabaseContext _context;

        public CourseRepository(DatabaseContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Course>> GetAllCourses()
        {
            using (var connection = _context.CreateConnection())
            {
                var sql = "SELECT * FROM Courses";
                return await connection.QueryAsync<Course>(sql);
            }
        }

        public async Task<Course> GetCourseById(int id)
        {
            using (var connection = _context.CreateConnection())
            {
                var sql = "SELECT * FROM Courses WHERE Id = @Id";
                return await connection.QuerySingleOrDefaultAsync<Course>(sql, new { Id = id });
            }
        }

        public async Task<int> CreateCourse(Course course)
        {
            using (var connection = _context.CreateConnection())
            {
                var sql = "INSERT INTO Courses (Title, Credits) VALUES (@Title, @Credits); SELECT CAST(SCOPE_IDENTITY() as int)";
                return await connection.ExecuteScalarAsync<int>(sql, course);
            }
        }

        public async Task<int> UpdateCourse(Course course)
        {
            using (var connection = _context.CreateConnection())
            {
                var sql = "UPDATE Courses SET Title = @Title, Credits = @Credits WHERE Id = @Id";
                return await connection.ExecuteAsync(sql, course);
            }
        }

        public async Task<int> DeleteCourse(int id)
        {
            using (var connection = _context.CreateConnection())
            {
                var sql = "DELETE FROM Courses WHERE Id = @Id";
                return await connection.ExecuteAsync(sql, new { Id = id });
            }
        }

        public async Task AddStudentToCourse(int courseId, int studentId)
        {
            var query = "INSERT INTO CourseStudents (CourseId, StudentId) VALUES (@CourseId, @StudentId)";
            using (var connection = _context.CreateConnection())
            {
                await connection.ExecuteAsync(query, new { CourseId = courseId, StudentId = studentId });
            }
        }

        public async Task<IEnumerable<Student>> GetStudentsByCourseId(int courseId)
        {
            var query = @"
                SELECT s.* 
                FROM Students s
                INNER JOIN CourseStudents cs ON s.Id = cs.StudentId
                WHERE cs.CourseId = @CourseId";
            using (var connection = _context.CreateConnection())
            {
                return await connection.QueryAsync<Student>(query, new { CourseId = courseId });
            }
        }
    }
}
