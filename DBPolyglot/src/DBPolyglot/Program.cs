using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DBPolyglot.Data;
using DBPolyglot.Models;
using Microsoft.Extensions.Configuration;

var builder = new ConfigurationBuilder()
    .SetBasePath(AppContext.BaseDirectory)
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: false);

var config = builder.Build();

// Instantiate services
var ms = new MsSqlService(config);
var mongo = new MongoService(config);
var neo4j = new Neo4jService(config);
var redis = new RedisService(config);

var services = new Dictionary<int, (string name, IDbService svc, bool isUp)>
{
    {1, ("MS SQL", ms, false)},
    {2, ("MongoDB", mongo, false)},
    {3, ("Neo4j", neo4j, false)},
    {4, ("Redis", redis, false)}
};

async Task RefreshStatuses()
{
    var checks = new List<Task>();
    foreach (var key in services.Keys)
    {
        var k = key;
        checks.Add(Task.Run(async () =>
        {
            try
            {
                services[k] = (services[k].name, services[k].svc, await services[k].svc.CheckAsync());
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Health check error for {services[k].name}: {ex.Message}");
                services[k] = (services[k].name, services[k].svc, false);
            }
        }));
    }
    await Task.WhenAll(checks);
}

async Task RunLoop()
{
    while (true)
    {
        Console.WriteLine();
        Console.WriteLine("DBPolyglot — choose a database:");
        await RefreshStatuses();
        foreach (var kv in services) Console.WriteLine($"{kv.Key}) {kv.Value.name} ({(kv.Value.isUp ? "Up" : "Down")})");
        Console.WriteLine("0) Exit");
        Console.Write("> ");
        if (!int.TryParse(Console.ReadLine(), out var choice)) continue;
        if (choice == 0) break;
        if (!services.ContainsKey(choice)) continue;

        var svc = services[choice].svc;
        Console.WriteLine($"Selected: {services[choice].name}");

        // Enter database-specific submenu; remain here until user chooses to go back (0)
        while (true)
        {
                Console.WriteLine("Operations: 1) Create 2) List 3) Update 4) Delete 5) Seed 6) Search 7) Reset 0) Back");
            Console.Write("> ");
            if (!int.TryParse(Console.ReadLine(), out var op)) continue;
            if (op == 0) break; // back to database selection

            switch (op)
            {
                case 1:
                    var p = new Person { Id = Guid.NewGuid().ToString(), Name = Prompt("Name"), Email = Prompt("Email") };
                    await svc.CreateAsync(p);
                    Console.WriteLine("Created.");
                    break;
                case 2:
                    var list = await svc.ReadAllAsync();
                    foreach (var item in list) Console.WriteLine($"{item.Id}\t{item.Name}\t{item.Email}");
                    Console.WriteLine($"Total: {list.Count}");
                    break;
                case 3:
                    var idToUpdate = Prompt("Id to update");
                    var uName = Prompt("New name");
                    var uEmail = Prompt("New email");
                    await svc.UpdateAsync(new Person { Id = idToUpdate, Name = uName, Email = uEmail });
                    Console.WriteLine("Updated (if existed).");
                    break;
                case 4:
                    var idToDelete = Prompt("Id to delete");
                    await svc.DeleteAsync(idToDelete);
                    Console.WriteLine("Deleted (if existed).");
                    break;
                    case 5:
                        var countStr = Prompt("How many rows to seed (default 100)");
                        if (!int.TryParse(countStr, out var count)) count = 100;
                        await svc.SeedAsync(count);
                        Console.WriteLine($"Seeded {count} rows.");
                        break;
                    case 6:
                        var q = Prompt("Search query (matches name or email)");
                        var results = await svc.SearchAsync(q);
                        foreach (var r in results) Console.WriteLine($"{r.Id}\t{r.Name}\t{r.Email}");
                        Console.WriteLine($"Matches: {results.Count}");
                        break;
                    case 7:
                        var confirm = Prompt("Type YES to reset the database (irreversible)");
                        if (confirm == "YES")
                        {
                            await svc.ResetAsync();
                            Console.WriteLine("Reset completed.");
                        }
                        else
                        {
                            Console.WriteLine("Reset cancelled.");
                        }
                        break;
                default:
                    Console.WriteLine("Unknown operation.");
                    break;
            }
        }
    }
}

string Prompt(string label)
{
    Console.Write(label + ": ");
    return Console.ReadLine() ?? string.Empty;
}

await RunLoop();

// Dispose async resources
await neo4j.DisposeAsync();
redis.Dispose();

Console.WriteLine("Exiting.");
