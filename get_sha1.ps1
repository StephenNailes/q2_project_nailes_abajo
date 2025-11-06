# Script to get SHA-1 certificate fingerprint for Android debug keystore

Write-Host "`n=== Getting SHA-1 Certificate Fingerprint ===" -ForegroundColor Cyan
Write-Host ""

# Check if debug keystore exists
$keystorePath = "$env:USERPROFILE\.android\debug.keystore"
if (-Not (Test-Path $keystorePath)) {
    Write-Host "❌ Debug keystore not found at: $keystorePath" -ForegroundColor Red
    Write-Host ""
    Write-Host "To generate a debug keystore, run:" -ForegroundColor Yellow
    Write-Host "   flutter run" -ForegroundColor Green
    Write-Host ""
    Write-Host "This will automatically create the debug keystore." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Debug keystore found at: $keystorePath" -ForegroundColor Green
Write-Host ""

# Find keytool
$keytoolPaths = @(
    "$env:JAVA_HOME\bin\keytool.exe",
    "C:\Program Files\Java\jdk-11\bin\keytool.exe",
    "C:\Program Files\Java\jdk-17\bin\keytool.exe",
    "C:\Program Files\Java\jdk-21\bin\keytool.exe",
    "C:\Program Files\OpenJDK\jdk-11\bin\keytool.exe",
    "C:\Program Files\OpenJDK\jdk-17\bin\keytool.exe",
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
)

$keytool = $null
foreach ($path in $keytoolPaths) {
    if (Test-Path $path) {
        $keytool = $path
        break
    }
}

# Try to find keytool in PATH
if (-Not $keytool) {
    try {
        $keytool = (Get-Command keytool -ErrorAction Stop).Source
    } catch {
        # Not in PATH
    }
}

if (-Not $keytool) {
    Write-Host "❌ keytool not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Java JDK or locate keytool manually." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common locations:" -ForegroundColor Cyan
    Write-Host "  - C:\Program Files\Java\jdk-XX\bin\keytool.exe"
    Write-Host "  - C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
    Write-Host ""
    Write-Host "Then run this command manually:" -ForegroundColor Yellow
    Write-Host "  & 'C:\Path\To\keytool.exe' -list -v -keystore '$keystorePath' -alias androiddebugkey -storepass android -keypass android" -ForegroundColor Green
    exit 1
}

Write-Host "✅ keytool found at: $keytool" -ForegroundColor Green
Write-Host ""
Write-Host "Getting certificate fingerprints..." -ForegroundColor Cyan
Write-Host ""

# Run keytool
try {
    $output = & $keytool -list -v -keystore $keystorePath -alias androiddebugkey -storepass android -keypass android 2>&1
    
    # Extract SHA-1 and SHA-256
    $sha1 = $output | Select-String "SHA1:" | ForEach-Object { $_.ToString().Trim() }
    $sha256 = $output | Select-String "SHA256:" | ForEach-Object { $_.ToString().Trim() }
    
    if ($sha1) {
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host "📋 YOUR SHA-1 CERTIFICATE FINGERPRINT:" -ForegroundColor Green
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host ""
        Write-Host $sha1 -ForegroundColor Yellow
        Write-Host ""
        
        # Extract just the fingerprint value
        $sha1Value = ($sha1 -split ": ")[1]
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host ""
        Write-Host "Copy this value: " -NoNewline
        Write-Host "$sha1Value" -ForegroundColor Cyan
        Write-Host ""
        
        if ($sha256) {
            Write-Host "SHA-256 (optional, for Play Store):" -ForegroundColor Gray
            Write-Host $sha256 -ForegroundColor Gray
            Write-Host ""
        }
        
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "📝 NEXT STEPS:" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Go to Firebase Console: https://console.firebase.google.com" -ForegroundColor White
        Write-Host "2. Select your project" -ForegroundColor White
        Write-Host "3. Go to Project Settings (gear icon) → General" -ForegroundColor White
        Write-Host "4. Scroll to 'Your apps' → Your Android app" -ForegroundColor White
        Write-Host "5. Under 'SHA certificate fingerprints', click 'Add fingerprint'" -ForegroundColor White
        Write-Host "6. Paste the SHA-1 value above and click Save" -ForegroundColor White
        Write-Host "7. Download the NEW google-services.json file" -ForegroundColor White
        Write-Host "8. Replace android/app/google-services.json with the new file" -ForegroundColor White
        Write-Host "9. Run: flutter clean ; flutter run" -ForegroundColor Green
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        
    } else {
        Write-Host "❌ Could not extract SHA-1 fingerprint" -ForegroundColor Red
        Write-Host ""
        Write-Host "Full output:" -ForegroundColor Yellow
        Write-Host $output
    }
    
} catch {
    Write-Host "❌ Error running keytool: $_" -ForegroundColor Red
}

Write-Host ""
