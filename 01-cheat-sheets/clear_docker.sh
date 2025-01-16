#!/bin/bash

echo "Stopping and removing all containers..."
docker stop $(docker ps -aq) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null

echo "Removing all custom networks..."
docker network prune -f 2>/dev/null

echo "Removing all volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null

echo "Removing all unused images..."
docker image prune -a -f 2>/dev/null

echo "Removing all build cache..."
docker builder prune -a -f 2>/dev/null

echo "Docker cleanup everything complete!"


# docker stop $(docker ps -aq) && docker rm $(docker ps -aq)
