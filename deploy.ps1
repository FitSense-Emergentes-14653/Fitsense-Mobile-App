# Script de Deploy Automático para FitSense
# Ejecutar: .\deploy.ps1

Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

Write-Host "`nGetting dependencies..." -ForegroundColor Cyan
flutter pub get

Write-Host "`nBuilding for Web (Release)..." -ForegroundColor Cyan
# Use a generic build command compatible with multiple Flutter versions
flutter build web --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild succeeded!" -ForegroundColor Green

    # Check for firebase CLI
    $fv = Get-Command firebase -ErrorAction SilentlyContinue
    if (-not $fv) {
        Write-Host "`nError: firebase CLI not found. Install it with: npm i -g firebase-tools" -ForegroundColor Red
        Write-Host "Then run: firebase login" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "`nDeploying to Firebase Hosting..." -ForegroundColor Magenta
    firebase deploy --only hosting

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nDeploy completed successfully!" -ForegroundColor Green
        Write-Host "Your app should be available on Firebase Hosting." -ForegroundColor Cyan
    } else {
        Write-Host "`nError deploying to Firebase." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`nError during build." -ForegroundColor Red
    exit 1
}
