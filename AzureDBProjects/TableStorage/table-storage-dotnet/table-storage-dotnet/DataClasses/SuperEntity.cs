using Azure.Data.Tables;
using Azure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace table_storage_dotnet.DataClasses
{
    public class SuperEntity : ITableEntity
    {
        public string PartitionKey { get; set; }
        public string RowKey { get; set; }
        public DateTimeOffset? Timestamp { get; set; }
        public ETag ETag { get; set; }

        public string RealName { get; set; }
        public string Power { get; set; }
        public string City { get; set; }
        public string Team { get; set; }
        public string ArchEnemy { get; set; }

        public SuperEntity() { }

        public SuperEntity(string partitionKey, string rowKey)
        {
            PartitionKey = partitionKey;
            RowKey = rowKey;
        }
    }
}
