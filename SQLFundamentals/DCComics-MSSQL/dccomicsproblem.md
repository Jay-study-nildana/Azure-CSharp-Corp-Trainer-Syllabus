# Problem: DC Comics Database Design

Below is an ER diagram description for a DC Comics-themed database. Use this as a prompt to design a normalized SQL Server schema. Your solution should include appropriate primary keys, foreign keys, and default values where necessary.

```
+-------------------+        +-------------------+
|   Superheroes     |        |     Villains      |
+-------------------+        +-------------------+
| SuperheroID (PK)  |        | VillainID (PK)    |
| Name              |        | Name              |
| Alias             |        | Alias             |
| FirstAppearance   |        | FirstAppearance   |
| Publisher         |        | Publisher         |
+-------------------+        +-------------------+
        |                          |
        |                          |
        v                          v
+-------------------+        +-------------------+
|    Comics         |        |   Teams           |
+-------------------+        +-------------------+
| ComicID (PK)      |        | TeamID (PK)       |
| Title             |        | TeamName          |
| IssueNumber       |        | BaseOfOperations  |
| ReleaseDate       |        +-------------------+
| SuperheroID (FK)  |
| VillainID (FK)    |
+-------------------+

+-------------------+        +------------------------+
| SuperheroTeams    |        | VillainTeams           |
+-------------------+        +------------------------+
| SuperheroID (FK)  |        | VillainTeamID (PK)     |
| TeamID (FK)       |        | TeamName               |
| PK: (SuperheroID, |        | BaseOfOperations       |
|     TeamID)       |        +------------------------+
+-------------------+

+---------------------------+
| VillainTeamMemberships    |
+---------------------------+
| VillainID (FK)            |
| VillainTeamID (FK)        |
| PK: (VillainID,           |
|      VillainTeamID)       |
+---------------------------+
```

Legend:
- PK = Primary Key
- FK = Foreign Key

**Task:**
Design the SQL Server schema for this DC Comics system. Write CREATE TABLE statements for each table, including all necessary constraints and default values.

## Solution

The folder already contains the solution as well as queries for you to practice. 
