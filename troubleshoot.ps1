# Docker Container Troubleshooting Script
Write-Host "🔍 Docker Container Troubleshooting Script" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "📋 Checking running containers..." -ForegroundColor Yellow
docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"

Write-Host ""
Write-Host "🏥 Checking container health..." -ForegroundColor Yellow
try {
    $containers = docker ps -q
    foreach ($container in $containers) {
        $health = docker inspect --format='{{.Name}}: {{.State.Health.Status}}' $container 2>$null
        if ($health) { Write-Host $health }
    }
} catch {
    Write-Host "No health checks configured or error occurred"
}

Write-Host ""
Write-Host "📡 Testing API server connectivity..." -ForegroundColor Yellow
Write-Host "Testing from host machine:"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/weatherforecast" -TimeoutSec 5
    Write-Host "✅ API server reachable from host. Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Cannot reach API server from host: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔗 Testing container-to-container connectivity..." -ForegroundColor Yellow
try {
    docker exec myClientApp curl -f http://apiserver:8080/weatherforecast -w "`nHTTP Status: %{http_code}`n" 2>$null
} catch {
    Write-Host "❌ Cannot reach API server from client container" -ForegroundColor Red
}

Write-Host ""
Write-Host "📝 API Server logs (last 20 lines):" -ForegroundColor Yellow
docker logs myApiServer --tail 20

Write-Host ""
Write-Host "📝 Client App logs (last 10 lines):" -ForegroundColor Yellow
docker logs myClientApp --tail 10

Write-Host ""
Write-Host "🌐 Network information:" -ForegroundColor Yellow
docker network ls
try {
    docker network inspect 2025ci_dockercompose_default 2>$null
} catch {
    Write-Host "Default network not found"
}