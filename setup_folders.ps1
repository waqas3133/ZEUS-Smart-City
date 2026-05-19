$directories = @(
    # Backend Structure
    "backend/app/api/routes",
    "backend/app/agents",
    "backend/app/services",
    "backend/app/orchestrator",
    "backend/app/models",
    "backend/app/schemas",
    "backend/app/utils",
    "backend/app/config",
    "backend/app/middleware",
    "backend/app/simulations",
    "backend/app/firebase",
    "backend/app/logs",
    
    # Frontend Structure
    "frontend/lib/core/theme",
    "frontend/lib/core/constants",
    "frontend/lib/core/utils",
    "frontend/lib/services",
    "frontend/lib/models",
    "frontend/lib/providers",
    "frontend/lib/screens/auth",
    "frontend/lib/screens/dashboard",
    "frontend/lib/screens/chatbot",
    "frontend/lib/screens/emergency",
    "frontend/lib/screens/simulation",
    "frontend/lib/screens/map",
    "frontend/lib/screens/alerts",
    "frontend/lib/screens/admin",
    "frontend/lib/widgets/common",
    "frontend/lib/widgets/animations",
    "frontend/lib/widgets/glassmorphism",
    "frontend/lib/maps",
    "frontend/lib/notifications"
)

foreach ($dir in $directories) {
    $path = Join-Path -Path $PWD -ChildPath $dir
    if (-not (Test-Path -Path $path)) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
    }
}
Write-Host "All directories created successfully."
