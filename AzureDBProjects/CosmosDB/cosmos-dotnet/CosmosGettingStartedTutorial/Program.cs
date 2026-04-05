using System;
using System.Threading.Tasks;
using System.Configuration;
using System.Collections.Generic;
using System.Net;
using Microsoft.Azure.Cosmos;

namespace CosmosGettingStartedTutorial
{
    class Program
    {
        // The Azure Cosmos DB endpoint for running this sample.
        private static readonly string EndpointUri = ConfigurationManager.AppSettings["EndPointUri"];

        // The primary key for the Azure Cosmos account.
        private static readonly string PrimaryKey = ConfigurationManager.AppSettings["PrimaryKey"];

        // The Cosmos client instance
        private CosmosClient cosmosClient;

        // The database we will create
        private Database database;

        // The container we will create.
        private Container container;

        // The name of the database and container we will create
        private string databaseId = "ToDoList";
        private string containerId = "Items";

        // <Main>
        public static async Task Main(string[] args)
        {
            try
            {
                Console.WriteLine("Beginning operations...\n");
                Program p = new Program();
                await p.GetStartedDemoAsync();

            }
            catch (CosmosException de)
            {
                Exception baseException = de.GetBaseException();
                Console.WriteLine("{0} error occurred: {1}", de.StatusCode, de);
            }
            catch (Exception e)
            {
                Console.WriteLine("Error: {0}", e);
            }
            finally
            {
                Console.WriteLine("End of demo, press any key to exit.");
                Console.ReadKey();
            }
        }
        // </Main>

        public async Task GetStartedDemoAsync()
        {
            // Create a new instance of the Cosmos Client
            this.cosmosClient = new CosmosClient(EndpointUri, PrimaryKey, new CosmosClientOptions() { ApplicationName = "CosmosDBDotnetQuickstart" });

            bool exit = false;
            while (!exit)
            {
                Console.WriteLine("Select an action:");
                Console.WriteLine("a. Create Database");
                Console.WriteLine("b. Create Container");
                Console.WriteLine("c. Scale Container");
                Console.WriteLine("d. Add Items to Container");
                Console.WriteLine("e. Query Items");
                Console.WriteLine("f. Replace Family Item");
                Console.WriteLine("g. Delete Family Item");
                Console.WriteLine("h. Delete Database and Cleanup");
                Console.WriteLine("i. Show All Databases");
                Console.WriteLine("j. Show All Containers");
                Console.WriteLine("k. Show All Items in Each Container");
                Console.WriteLine("l. Exit");

                var key = Console.ReadKey(true).KeyChar;
                Console.WriteLine("Loading...");

                switch (key)
                {
                    case 'a':
                        await this.CreateDatabaseAsync();
                        break;
                    case 'b':
                        await this.CreateContainerAsync();
                        break;
                    case 'c':
                        await this.ScaleContainerAsync();
                        break;
                    case 'd':
                        await this.AddItemsToContainerAsync();
                        break;
                    case 'e':
                        await this.QueryItemsAsync();
                        break;
                    case 'f':
                        await this.ReplaceFamilyItemAsync();
                        break;
                    case 'g':
                        await this.DeleteFamilyItemAsync();
                        break;
                    case 'h':
                        await this.DeleteDatabaseAndCleanupAsync();
                        break;
                    case 'i':
                        await this.ShowAllDatabasesAsync();
                        break;
                    case 'j':
                        await this.ShowAllContainersAsync();
                        break;
                    case 'k':
                        await this.ShowAllItemsInEachContainerAsync();
                        break;
                    case 'l':
                        exit = true;
                        break;
                    default:
                        Console.WriteLine("Invalid selection. Please try again.");
                        break;
                }

            }
        }

        // <CreateDatabaseAsync>
        /// <summary>
        /// Create the database if it does not exist
        /// </summary>
        private async Task CreateDatabaseAsync()
        {
            try
            {
                // Create a new database
                this.database = await this.cosmosClient.CreateDatabaseIfNotExistsAsync(databaseId);
                Console.WriteLine("Created Database: {0}\n", this.database.Id);
            }
            catch (CosmosException ex)
            {
                Console.WriteLine("CosmosException with status code {0} occurred: {1}", ex.StatusCode, ex.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred: {0}", ex.Message);
            }
        }
        // </CreateDatabaseAsync>

        // <CreateContainerAsync>
        /// <summary>
        /// Create the container if it does not exist. 
        /// Specifiy "/partitionKey" as the partition key path since we're storing family information, to ensure good distribution of requests and storage.
        /// </summary>
        /// <returns></returns>
        private async Task CreateContainerAsync()
        {
            try
            {
                if (this.database == null)
                {
                    Console.WriteLine("Database is not initialized. Please create the database first.");
                    return;
                }

                // Create a new container
                this.container = await this.database.CreateContainerIfNotExistsAsync(containerId, "/partitionKey");
                Console.WriteLine("Created Container: {0}\n", this.container.Id);
            }
            catch (CosmosException ex)
            {
                Console.WriteLine("CosmosException with status code {0} occurred: {1}", ex.StatusCode, ex.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred: {0}", ex.Message);
            }
        }
        // </CreateContainerAsync>

        // <ScaleContainerAsync>
        /// <summary>
        /// Scale the throughput provisioned on an existing Container.
        /// You can scale the throughput (RU/s) of your container up and down to meet the needs of the workload. Learn more: https://aka.ms/cosmos-request-units
        /// </summary>
        /// <returns></returns>
        private async Task ScaleContainerAsync()
        {
            // Read the current throughput
            try
            {
                int? throughput = await this.container.ReadThroughputAsync();
                if (throughput.HasValue)
                {
                    Console.WriteLine("Current provisioned throughput : {0}\n", throughput.Value);
                    int newThroughput = throughput.Value + 100;
                    // Update throughput
                    await this.container.ReplaceThroughputAsync(newThroughput);
                    Console.WriteLine("New provisioned throughput : {0}\n", newThroughput);
                }
            }
            catch (CosmosException cosmosException) when (cosmosException.StatusCode == HttpStatusCode.BadRequest)
            {
                Console.WriteLine("Cannot read container throuthput.");
                Console.WriteLine(cosmosException.ResponseBody);
            }
            
        }
        // </ScaleContainerAsync>

        // <AddItemsToContainerAsync>
        /// <summary>
        /// Add Family items to the container
        /// </summary>
        private async Task AddItemsToContainerAsync()
        {
            // Create a family object for the Andersen family
            Family andersenFamily = new Family
            {
                Id = "Andersen.1",
                PartitionKey = "Andersen",
                LastName = "Andersen",
                Parents = new Parent[]
                {
                    new Parent { FirstName = "Thomas" },
                    new Parent { FirstName = "Mary Kay" }
                },
                Children = new Child[]
                {
                    new Child
                    {
                        FirstName = "Henriette Thaulow",
                        Gender = "female",
                        Grade = 5,
                        Pets = new Pet[]
                        {
                            new Pet { GivenName = "Fluffy" }
                        }
                    }
                },
                Address = new Address { State = "WA", County = "King", City = "Seattle" },
                IsRegistered = false
            };

            try
            {
                // Read the item to see if it exists.  
                ItemResponse<Family> andersenFamilyResponse = await this.container.ReadItemAsync<Family>(andersenFamily.Id, new PartitionKey(andersenFamily.PartitionKey));
                Console.WriteLine("Item in database with id: {0} already exists\n", andersenFamilyResponse.Resource.Id);
            }
            catch(CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
            {
                // Create an item in the container representing the Andersen family. Note we provide the value of the partition key for this item, which is "Andersen"
                ItemResponse<Family> andersenFamilyResponse = await this.container.CreateItemAsync<Family>(andersenFamily, new PartitionKey(andersenFamily.PartitionKey));

                // Note that after creating the item, we can access the body of the item with the Resource property off the ItemResponse. We can also access the RequestCharge property to see the amount of RUs consumed on this request.
                Console.WriteLine("Created item in database with id: {0} Operation consumed {1} RUs.\n", andersenFamilyResponse.Resource.Id, andersenFamilyResponse.RequestCharge);
            }

            // Create a family object for the Wakefield family
            Family wakefieldFamily = new Family
            {
                Id = "Wakefield.7",
                PartitionKey = "Wakefield",
                LastName = "Wakefield",
                Parents = new Parent[]
                {
                    new Parent { FamilyName = "Wakefield", FirstName = "Robin" },
                    new Parent { FamilyName = "Miller", FirstName = "Ben" }
                },
                Children = new Child[]
                {
                    new Child
                    {
                        FamilyName = "Merriam",
                        FirstName = "Jesse",
                        Gender = "female",
                        Grade = 8,
                        Pets = new Pet[]
                        {
                            new Pet { GivenName = "Goofy" },
                            new Pet { GivenName = "Shadow" }
                        }
                    },
                    new Child
                    {
                        FamilyName = "Miller",
                        FirstName = "Lisa",
                        Gender = "female",
                        Grade = 1
                    }
                },
                Address = new Address { State = "NY", County = "Manhattan", City = "NY" },
                IsRegistered = true
            };

            try
            {
                // Read the item to see if it exists
                ItemResponse<Family> wakefieldFamilyResponse = await this.container.ReadItemAsync<Family>(wakefieldFamily.Id, new PartitionKey(wakefieldFamily.PartitionKey));
                Console.WriteLine("Item in database with id: {0} already exists\n", wakefieldFamilyResponse.Resource.Id);
            }
            catch(CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
            {
                // Create an item in the container representing the Wakefield family. Note we provide the value of the partition key for this item, which is "Wakefield"
                ItemResponse<Family> wakefieldFamilyResponse = await this.container.CreateItemAsync<Family>(wakefieldFamily, new PartitionKey(wakefieldFamily.PartitionKey));

                // Note that after creating the item, we can access the body of the item with the Resource property off the ItemResponse. We can also access the RequestCharge property to see the amount of RUs consumed on this request.
                Console.WriteLine("Created item in database with id: {0} Operation consumed {1} RUs.\n", wakefieldFamilyResponse.Resource.Id, wakefieldFamilyResponse.RequestCharge);
            }
        }
        // </AddItemsToContainerAsync>

        // <QueryItemsAsync>
        /// <summary>
        /// Run a query (using Azure Cosmos DB SQL syntax) against the container
        /// Including the partition key value of lastName in the WHERE filter results in a more efficient query
        /// </summary>
        private async Task QueryItemsAsync()
        {
            var sqlQueryText = "SELECT * FROM c WHERE c.partitionKey = 'Andersen'";

            Console.WriteLine("Running query: {0}\n", sqlQueryText);

            if (this.container == null)
            {
                Console.WriteLine("Container is not initialized.");
                return;
            }

            QueryDefinition queryDefinition = new QueryDefinition(sqlQueryText);
            FeedIterator<Family> queryResultSetIterator = this.container.GetItemQueryIterator<Family>(queryDefinition);

            List<Family> families = new List<Family>();

            try
            {
                while (queryResultSetIterator.HasMoreResults)
                {
                    FeedResponse<Family> currentResultSet = await queryResultSetIterator.ReadNextAsync();
                    if (currentResultSet.Count == 0)
                    {
                        Console.WriteLine("No items found.");
                    }
                    foreach (Family family in currentResultSet)
                    {
                        families.Add(family);
                        Console.WriteLine("\tRead {0}\n", family);
                    }
                }
            }
            catch (CosmosException ex)
            {
                Console.WriteLine("CosmosException with status code {0} occurred: {1}", ex.StatusCode, ex.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred: {0}", ex.Message);
            }
        }

        // </QueryItemsAsync>

        // <ReplaceFamilyItemAsync>
        /// <summary>
        /// Replace an item in the container
        /// </summary>
        private async Task ReplaceFamilyItemAsync()
        {
            ItemResponse<Family> wakefieldFamilyResponse = await this.container.ReadItemAsync<Family>("Wakefield.7", new PartitionKey("Wakefield"));
            var itemBody = wakefieldFamilyResponse.Resource;
            
            // update registration status from false to true
            itemBody.IsRegistered = true;
            // update grade of child
            itemBody.Children[0].Grade = 6;

            // replace the item with the updated content
            wakefieldFamilyResponse = await this.container.ReplaceItemAsync<Family>(itemBody, itemBody.Id, new PartitionKey(itemBody.PartitionKey));
            Console.WriteLine("Updated Family [{0},{1}].\n \tBody is now: {2}\n", itemBody.LastName, itemBody.Id, wakefieldFamilyResponse.Resource);
        }
        // </ReplaceFamilyItemAsync>

        // <DeleteFamilyItemAsync>
        /// <summary>
        /// Delete an item in the container
        /// </summary>
        private async Task DeleteFamilyItemAsync()
        {
            var partitionKeyValue = "Wakefield";
            var familyId = "Wakefield.7";

            // Delete an item. Note we must provide the partition key value and id of the item to delete
            ItemResponse<Family> wakefieldFamilyResponse = await this.container.DeleteItemAsync<Family>(familyId,new PartitionKey(partitionKeyValue));
            Console.WriteLine("Deleted Family [{0},{1}]\n", partitionKeyValue, familyId);
        }
        // </DeleteFamilyItemAsync>

        // <DeleteDatabaseAndCleanupAsync>
        /// <summary>
        /// Delete the database and dispose of the Cosmos Client instance
        /// </summary>
        private async Task DeleteDatabaseAndCleanupAsync()
        {
            DatabaseResponse databaseResourceResponse = await this.database.DeleteAsync();
            // Also valid: await this.cosmosClient.Databases["FamilyDatabase"].DeleteAsync();

            Console.WriteLine("Deleted Database: {0}\n", this.databaseId);

            //Dispose of CosmosClient
            this.cosmosClient.Dispose();
        }
        // </DeleteDatabaseAndCleanupAsync>

        private async Task ShowAllDatabasesAsync()
        {
            try
            {
                var iterator = this.cosmosClient.GetDatabaseQueryIterator<DatabaseProperties>();
                var databases = await iterator.ReadNextAsync();
                Console.WriteLine("Databases:");
                foreach (var db in databases)
                {
                    Console.WriteLine($"- {db.Id}");
                }
            }
            catch (CosmosException ex)
            {
                Console.WriteLine("CosmosException with status code {0} occurred: {1}", ex.StatusCode, ex.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred: {0}", ex.Message);
            }
        }

        private async Task ShowAllContainersAsync()
        {
            try
            {
                var iterator = this.cosmosClient.GetDatabaseQueryIterator<DatabaseProperties>();
                var databases = await iterator.ReadNextAsync();
                foreach (var db in databases)
                {
                    var database = this.cosmosClient.GetDatabase(db.Id);
                    var containerIterator = database.GetContainerQueryIterator<ContainerProperties>();
                    var containers = await containerIterator.ReadNextAsync();
                    Console.WriteLine($"Database: {db.Id}");
                    foreach (var container in containers)
                    {
                        Console.WriteLine($"- Container: {container.Id}");
                    }
                }
            }
            catch (CosmosException ex)
            {
                Console.WriteLine("CosmosException with status code {0} occurred: {1}", ex.StatusCode, ex.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred: {0}", ex.Message);
            }
        }

        private async Task ShowAllItemsInEachContainerAsync()
        {
            try
            {
                var iterator = this.cosmosClient.GetDatabaseQueryIterator<DatabaseProperties>();
                var databases = await iterator.ReadNextAsync();
                foreach (var db in databases)
                {
                    var database = this.cosmosClient.GetDatabase(db.Id);
                    var containerIterator = database.GetContainerQueryIterator<ContainerProperties>();
                    var containers = await containerIterator.ReadNextAsync();
                    Console.WriteLine($"Database: {db.Id}");
                    foreach (var container in containers)
                    {
                        Console.WriteLine($"- Container: {container.Id}");
                        var containerInstance = database.GetContainer(container.Id);
                        var itemIterator = containerInstance.GetItemQueryIterator<dynamic>("SELECT * FROM c");
                        var items = await itemIterator.ReadNextAsync();
                        foreach (var item in items)
                        {
                            Console.WriteLine($"  - Item: {item}");
                        }
                    }
                }
            }
            catch (CosmosException ex)
            {
                Console.WriteLine("CosmosException with status code {0} occurred: {1}", ex.StatusCode, ex.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred: {0}", ex.Message);
            }
        }

    }
}
