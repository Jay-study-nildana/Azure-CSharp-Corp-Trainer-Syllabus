# Microsoft SQL Server 2022 Dockerfile
# This Dockerfile reuses the official image and documents how to run it.
FROM mcr.microsoft.com/mssql/server:2022-latest

# Example environment variables. For safety override these at runtime rather than
# baking secrets into the image.
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=YourStrong!Passw0rd
ENV MSSQL_PID=Express

# Expose the SQL Server TCP port
EXPOSE 1433

# How to build and run (examples):
# Build: docker build -t dbpoly_mssql ./docker/mssql
# Run: docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=YourStrong!Passw0rd' -p 1433:1433 --name mssql -v mssql_data:/var/opt/mssql -d dbpoly_mssql
# Or use docker-compose: `docker-compose up -d mssql`

CMD ["/opt/mssql/bin/sqlservr"]
