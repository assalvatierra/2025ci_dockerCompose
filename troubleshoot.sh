#!/bin/bash

echo "🔍 Docker Container Troubleshooting Script"
echo "==========================================="

echo ""
echo "📋 Checking running containers..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🏥 Checking container health..."
docker inspect --format='{{.Name}}: {{.State.Health.Status}}' $(docker ps -q) 2>/dev/null || echo "No health checks configured"

echo ""
echo "📡 Testing API server connectivity..."
echo "Testing from host machine:"
curl -f http://localhost:8080/weatherforecast -w "\nHTTP Status: %{http_code}\n" 2>/dev/null || echo "❌ Cannot reach API server from host"

echo ""
echo "🔗 Testing container-to-container connectivity..."
docker exec myClientApp curl -f http://apiserver:8080/weatherforecast -w "\nHTTP Status: %{http_code}\n" 2>/dev/null || echo "❌ Cannot reach API server from client container"

echo ""
echo "📝 API Server logs (last 20 lines):"
docker logs myApiServer --tail 20

echo ""
echo "📝 Client App logs (last 10 lines):"
docker logs myClientApp --tail 10

echo ""
echo "🌐 Network information:"
docker network ls
docker network inspect 2025ci_dockercompose_default 2>/dev/null || echo "Default network not found"