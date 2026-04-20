# DBPolyglot

This workspace contains Dockerfiles and a `docker-compose.yml` to run example database servers for the Polyglot DB teaching demos.

Included databases:

- MS SQL Server (TCP 1433)
- MongoDB (TCP 27017)
- Neo4j (HTTP 7474, Bolt 7687) (note : for some reason, neo4j just won't run on docker for me. The code is there, but I don't know if it is working for sure)
- Redis (TCP 6379)

# Docker Related Notes

- Docker (Desktop or Engine)
- docker-compose (included in Docker Desktop; or use `docker compose`)

Quick start

1. From the repository root run:

```bash
docker-compose up -d
```

2. Check status:

```bash
docker-compose ps
docker-compose logs -f mssql
```

3. Stop and remove containers:

```bash
docker-compose down
```

4. To remove volumes (data) too:

```bash
docker-compose down -v
```

# Build and run

```bash
dotnet build
dotnet run --project src/DBPolyglot
```

# Running tests

- A unit test project using xUnit is available at `src/DBPolyglot.Tests`.
- The tests use a `MockDbService` to exercise CRUD operations without needing external databases.
- Run the tests with:

```bash
dotnet test src/DBPolyglot.Tests
```

## book a session with me

1. [calendly](https://calendly.com/jaycodingtutor/30min)

## hire and get to know me

find ways to hire me, follow me and stay in touch with me.

1. [github](https://github.com/Jay-study-nildana)
1. [personal site](https://thechalakas.com)
1. [upwork](https://www.upwork.com/fl/vijayasimhabr)
1. [fiverr](https://www.fiverr.com/jay_codeguy)
1. [codementor](https://www.codementor.io/@vijayasimhabr)
1. [stackoverflow](https://stackoverflow.com/users/5338888/jay)
1. [Jay's Coding Channel on YouTube](https://www.youtube.com/channel/UCJJVulg4J7POMdX0veuacXw/)
1. [medium blog](https://medium.com/@vijayasimhabr)