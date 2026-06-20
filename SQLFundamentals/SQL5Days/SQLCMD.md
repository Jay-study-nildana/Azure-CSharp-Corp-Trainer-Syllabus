# SQL CMD 

Ideally, I would recommend you practice SQL with VS Code and/or SQL Server Management Studio. But, command line is another option. 

## Connecting to your SQL Server

```
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -Q "SELECT name FROM sys.databases;"

sqlcmd -S ".\SQLEXPRESS" -E -Q "SELECT name FROM sys.databases;"

sqlcmd -S (localdb)\MSSQLLocalDB -E

sqlcmd -S ".\SQLEXPRESS" -E
```

Note: When you use VS Code or SSMS, you are probably connected to SQLExpress. 

## Running Queries

Here, the key thing is the keyword, 'GO'. So, after typing your query, like you normally do on VSCode or SSMS, you simply type GO, and press Enter. It will look something like this.

```
C:\Users\vijay>sqlcmd -S ".\SQLEXPRESS" -E
1> USE DCComicsDB
2> GO
Changed database context to 'DCComicsDB'.
1> SELECT *
2> FROM dbo.Teams
3> GO
TeamID      TeamName                                                                                             BaseOfOperations
----------- ---------------------------------------------------------------------------------------------------- ----------------------------------------------------------------------------------------------------
          1 Justice League                                                                                       Hall of Justice
          2 Teen Titans                                                                                          Titans Tower
          3 Suicide Squad                                                                                        Belle Reve Penitentiary

(3 rows affected)
1>
```

## Common commands

```
sqlcmd -? //gives you version number
sqllocaldb info //shows you servers that are running
Get-Service -Name "MSSQL*" | Select-Object Name, Status //shows your servers that are running. powershell only.
```

## References

1. https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility

## That's it (for now)

Happy SQL Coding.