using Azure.Data.Tables;
using Azure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace table_storage_dotnet.DataClasses
{
    public class MovieEntity : ITableEntity
    {
        public string PartitionKey { get; set; }
        public string RowKey { get; set; }
        public DateTimeOffset? Timestamp { get; set; }
        public ETag ETag { get; set; }

        public string Director { get; set; }
        public string Genre { get; set; }
        public int ReleaseYear { get; set; }
        public double Rating { get; set; }

        public MovieEntity() { }

        public MovieEntity(string partitionKey, string rowKey)
        {
            PartitionKey = partitionKey;
            RowKey = rowKey;
        }
    }
}
