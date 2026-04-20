# MongoDB Dockerfile
# Uses the official MongoDB image. This file documents how to run the server.
FROM mongo:6.0

# Expose MongoDB default port
EXPOSE 27017

# How to build and run (examples):
# Build: docker build -t dbpoly_mongo ./docker/mongodb
# Run: docker run -p 27017:27017 --name mongodb -v mongo_data:/data/db -d dbpoly_mongo
# Or use docker-compose: `docker-compose up -d mongodb`

CMD ["mongod"]
