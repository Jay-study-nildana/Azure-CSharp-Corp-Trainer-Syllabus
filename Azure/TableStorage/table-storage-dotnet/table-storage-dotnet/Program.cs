// See https://aka.ms/new-console-template for more information
using Azure.Data.Tables;
using Azure.Identity;
using table_storage_dotnet.HelperClasses;

Console.WriteLine("Hello, World!");

string connectionString = "ENTERYOURSTORAGEACCOUNTCONNECTIONSTRINGHERE";

TableServiceClient serviceClient = new TableServiceClient(connectionString);

Console.WriteLine("Connected to Azure Table Storage");

//let's add some comic book characters 
var helper = new AddToTableOne();

Console.Write("Do you want to add a new table? (yes/no): ");
string response = Console.ReadLine();

if (response?.ToLower() == "yes")
{
    Console.Write("Enter a table name: ");
    string tableName = Console.ReadLine();
    await helper.AddMoviesToTable(serviceClient, tableName);
    await helper.DisplayTableContents(serviceClient, tableName);
}
else
{
    Console.WriteLine("No new table will be added.");
}

Console.Write("Do you want to add superheroes and supervillains? (yes/no): ");
string addSuperheroesResponse = Console.ReadLine();

if (addSuperheroesResponse?.ToLower() == "yes")
{
    await helper.AddStuffOne(serviceClient);
}
else
{
    Console.WriteLine("Superheroes and supervillains will not be added.");
}

await helper.ListTablesAndEntitiesAsync(serviceClient);



