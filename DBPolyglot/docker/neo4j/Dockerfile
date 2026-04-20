# Neo4j Dockerfile
# Uses the official Neo4j image and documents how to run it.
FROM neo4j:5

# Example environment: set authentication (user/password). Replace before use.
ENV NEO4J_AUTH=neo4j/test

# Expose HTTP and Bolt ports
EXPOSE 7474 7687

# How to build and run (examples):
# Build: docker build -t dbpoly_neo4j ./docker/neo4j
# Run: docker run -p 7474:7474 -p 7687:7687 --name neo4j -v neo4j_data:/data -e NEO4J_AUTH=neo4j/test -d dbpoly_neo4j
# Or use docker-compose: `docker-compose up -d neo4j`

# CMD ["/sbin/tini", "--", "/docker-entrypoint.sh", "neo4j"]

