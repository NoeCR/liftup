# Script para commit con formateo automático
param(
    [Parameter(Mandatory=$true)]
    [string]$Message
)

Write-Host "🔧 Formateando código Dart..." -ForegroundColor Yellow
dart format .

Write-Host "📝 Agregando archivos al staging area..." -ForegroundColor Yellow
git add .

Write-Host "💾 Haciendo commit..." -ForegroundColor Yellow
git commit -m $Message

Write-Host "🚀 Haciendo push..." -ForegroundColor Yellow
git push origin mejora-gestion-progresiones

Write-Host "✅ Commit y push completados!" -ForegroundColor Green
