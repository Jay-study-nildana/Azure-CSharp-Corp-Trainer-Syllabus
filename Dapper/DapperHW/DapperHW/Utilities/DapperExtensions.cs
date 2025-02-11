using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DapperHW.Utilities
{
    public static class DapperExtensions
    {
        public static async Task<IEnumerable<T>> QueryWithPagination<T>(this IDbConnection connection, string sql, object parameters, int page, int pageSize)
        {
            var paginatedSql = $"{sql} OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";
            return await connection.QueryAsync<T>(paginatedSql, new { Offset = (page - 1) * pageSize, PageSize = pageSize });
        }

        public static async Task<IEnumerable<T>> QueryWithCaching<T>(this IDbConnection connection, string sql, object parameters, int cacheDuration)
        {
            // Implementation of caching logic
            // This is just a placeholder, actual implementation will vary
            return await connection.QueryAsync<T>(sql, parameters);
        }
    }
}
