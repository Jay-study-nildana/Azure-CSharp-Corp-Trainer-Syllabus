using Azure;
using Azure.Data.Tables;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using table_storage_dotnet.DataClasses;

namespace table_storage_dotnet.HelperClasses
{
    public class AddToTableOne
    {
        public async Task AddStuffOne(TableServiceClient serviceClient)
        {
            Console.WriteLine("Adding stuff to Table One");
            TableClient tableClient = serviceClient.GetTableClient("TableOne");
            await tableClient.CreateIfNotExistsAsync();

            await AddSuperHeroesAndVillainsAsync(tableClient);

            async Task AddSuperHeroesAndVillainsAsync(TableClient tableClient)
            {
                var superheroes = new List<SuperEntity>
                        {
                            new SuperEntity("1", "Superman") { RealName = "Clark Kent", Power = "Super Strength", City = "Metropolis", Team = "Justice League", ArchEnemy = "Lex Luthor" },
                            new SuperEntity("1", "Batman") { RealName = "Bruce Wayne", Power = "Intelligence", City = "Gotham", Team = "Justice League", ArchEnemy = "Joker" },
                            new SuperEntity("1", "Wonder Woman") { RealName = "Diana Prince", Power = "Super Strength", City = "Themyscira", Team = "Justice League", ArchEnemy = "Cheetah" },
                            new SuperEntity("1", "Flash") { RealName = "Barry Allen", Power = "Super Speed", City = "Central City", Team = "Justice League", ArchEnemy = "Reverse Flash" },
                            new SuperEntity("1", "Aquaman") { RealName = "Arthur Curry", Power = "Aquatic Abilities", City = "Atlantis", Team = "Justice League", ArchEnemy = "Black Manta" },
                            new SuperEntity("1", "Cyborg") { RealName = "Victor Stone", Power = "Cybernetics", City = "Detroit", Team = "Justice League", ArchEnemy = "Grid" },
                            new SuperEntity("1", "Green Lantern") { RealName = "Hal Jordan", Power = "Power Ring", City = "Coast City", Team = "Justice League", ArchEnemy = "Sinestro" },
                            new SuperEntity("1", "Martian Manhunter") { RealName = "J'onn J'onzz", Power = "Shape Shifting", City = "Mars", Team = "Justice League", ArchEnemy = "Ma'alefa'ak" },
                            new SuperEntity("1", "Green Arrow") { RealName = "Oliver Queen", Power = "Archery", City = "Star City", Team = "Justice League", ArchEnemy = "Merlyn" },
                            new SuperEntity("1", "Black Canary") { RealName = "Dinah Lance", Power = "Canary Cry", City = "Star City", Team = "Justice League", ArchEnemy = "Vertigo" }
                        };

                var supervillains = new List<SuperEntity>
                        {
                            new SuperEntity("2", "Joker") { RealName = "Unknown", Power = "Insanity", City = "Gotham", Team = "Injustice League", ArchEnemy = "Batman" },
                            new SuperEntity("2", "Lex Luthor") { RealName = "Lex Luthor", Power = "Intelligence", City = "Metropolis", Team = "Injustice League", ArchEnemy = "Superman" },
                            new SuperEntity("2", "Cheetah") { RealName = "Barbara Minerva", Power = "Super Strength", City = "Themyscira", Team = "Injustice League", ArchEnemy = "Wonder Woman" },
                            new SuperEntity("2", "Reverse Flash") { RealName = "Eobard Thawne", Power = "Super Speed", City = "Central City", Team = "Injustice League", ArchEnemy = "Flash" },
                            new SuperEntity("2", "Black Manta") { RealName = "David Hyde", Power = "Aquatic Abilities", City = "Atlantis", Team = "Injustice League", ArchEnemy = "Aquaman" },
                            new SuperEntity("2", "Grid") { RealName = "Grid", Power = "Cybernetics", City = "Detroit", Team = "Injustice League", ArchEnemy = "Cyborg" },
                            new SuperEntity("2", "Sinestro") { RealName = "Thaal Sinestro", Power = "Power Ring", City = "Korugar", Team = "Injustice League", ArchEnemy = "Green Lantern" },
                            new SuperEntity("2", "Ma'alefa'ak") { RealName = "Ma'alefa'ak", Power = "Shape Shifting", City = "Mars", Team = "Injustice League", ArchEnemy = "Martian Manhunter" },
                            new SuperEntity("2", "Merlyn") { RealName = "Arthur King", Power = "Archery", City = "Star City", Team = "Injustice League", ArchEnemy = "Green Arrow" },
                            new SuperEntity("2", "Vertigo") { RealName = "Count Vertigo", Power = "Vertigo Effect", City = "Star City", Team = "Injustice League", ArchEnemy = "Black Canary" }
                        };

                foreach (var hero in superheroes)
                {
                    try
                    {
                        var existingEntity = await tableClient.GetEntityAsync<TableEntity>(hero.PartitionKey, hero.RowKey);
                        Console.WriteLine($"Entity {hero.RowKey} already exists in partition {hero.PartitionKey}.");
                    }
                    catch (RequestFailedException ex) when (ex.Status == 404)
                    {
                        await tableClient.AddEntityAsync(hero);
                        Console.WriteLine($"Added entity {hero.RowKey} to partition {hero.PartitionKey}.");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error adding entity {hero.RowKey} to partition {hero.PartitionKey}: {ex.Message}");
                    }
                }

                foreach (var villain in supervillains)
                {
                    try
                    {
                        var existingEntity = await tableClient.GetEntityAsync<TableEntity>(villain.PartitionKey, villain.RowKey);
                        Console.WriteLine($"Entity {villain.RowKey} already exists in partition {villain.PartitionKey}.");
                    }
                    catch (RequestFailedException ex) when (ex.Status == 404)
                    {
                        await tableClient.AddEntityAsync(villain);
                        Console.WriteLine($"Added entity {villain.RowKey} to partition {villain.PartitionKey}.");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error adding entity {villain.RowKey} to partition {villain.PartitionKey}: {ex.Message}");
                    }
                }

                Console.WriteLine("Added superheroes and supervillains to TableOne.");
            }
        }

        public async Task DisplayTableContents(TableServiceClient serviceClient, string tableName)
        {
            TableClient tableClient = serviceClient.GetTableClient(tableName);
            var entities = tableClient.QueryAsync<TableEntity>();

            Console.WriteLine($"Contents of table: {tableName}");
            await foreach (var entity in entities)
            {
                Console.WriteLine("Entity:");
                foreach (var property in entity)
                {
                    Console.WriteLine($"  {property.Key}: {property.Value}");
                }
                Console.WriteLine(new string('-', 40));
            }
        }

        public async Task AddMoviesToTable(TableServiceClient serviceClient, string tableName)
        {
            Console.WriteLine($"Creating table: {tableName}");
            TableClient tableClient = serviceClient.GetTableClient(tableName);
            await tableClient.CreateIfNotExistsAsync();

            var movies = new List<MovieEntity>
            {
                new MovieEntity("1", "Inception") { Director = "Christopher Nolan", Genre = "Sci-Fi", ReleaseYear = 2010, Rating = 8.8 },
                new MovieEntity("1", "The Dark Knight") { Director = "Christopher Nolan", Genre = "Action", ReleaseYear = 2008, Rating = 9.0 },
                new MovieEntity("1", "Interstellar") { Director = "Christopher Nolan", Genre = "Sci-Fi", ReleaseYear = 2014, Rating = 8.6 },
                new MovieEntity("1", "The Prestige") { Director = "Christopher Nolan", Genre = "Drama", ReleaseYear = 2006, Rating = 8.5 },
                new MovieEntity("1", "Dunkirk") { Director = "Christopher Nolan", Genre = "War", ReleaseYear = 2017, Rating = 7.9 }
            };

            foreach (var movie in movies)
            {
                try
                {
                    var existingEntity = await tableClient.GetEntityAsync<TableEntity>(movie.PartitionKey, movie.RowKey);
                    Console.WriteLine($"Entity {movie.RowKey} already exists in partition {movie.PartitionKey}.");
                }
                catch (RequestFailedException ex) when (ex.Status == 404)
                {
                    await tableClient.AddEntityAsync(movie);
                    Console.WriteLine($"Added entity {movie.RowKey} to partition {movie.PartitionKey}.");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error adding entity {movie.RowKey} to partition {movie.PartitionKey}: {ex.Message}");
                }
            }

            Console.WriteLine($"Added movies to {tableName}.");
        }

        public async Task ListTablesAndEntitiesAsync(TableServiceClient serviceClient)
        {
            await foreach (var tableItem in serviceClient.QueryAsync())
            {
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine($"Table: {tableItem.Name}");
                Console.ResetColor();

                TableClient tableClient = serviceClient.GetTableClient(tableItem.Name);
                var entities = tableClient.QueryAsync<TableEntity>();

                bool isEmpty = true;
                await foreach (var entity in entities)
                {
                    if (isEmpty)
                    {
                        isEmpty = false;
                    }
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.WriteLine("  Entity:");
                    Console.ResetColor();
                    foreach (var property in entity)
                    {
                        Console.WriteLine($"    {property.Key}: {property.Value}");
                    }
                }

                if (isEmpty)
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("  This table is empty.");
                    Console.ResetColor();
                }

                Console.WriteLine(new string('-', 40));
            }
        }

    }
}
