# Redis Dockerfile
# Uses the official Redis image and documents how to run it.
FROM redis:7

# Expose Redis default port
EXPOSE 6379

# How to build and run (examples):
# Build: docker build -t dbpoly_redis ./docker/redis
# Run: docker run -p 6379:6379 --name redis -v redis_data:/data -d dbpoly_redis
# Or use docker-compose: `docker-compose up -d redis`

CMD ["redis-server"]
