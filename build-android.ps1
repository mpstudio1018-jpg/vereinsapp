param(
    [ValidateSet('assembleDebug', 'assembleRelease', 'bundleRelease')]
    [string]$GradleTask = 'assembleDebug',

    [switch]$SkipClean
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $projectRoot 'android'

function Set-JavaHome {
    if ($env:JAVA_HOME) {
        $javaExe = Join-Path $env:JAVA_HOME 'bin\java.exe'
        if (Test-Path $javaExe) {
            if (-not (($env:Path -split ';') -contains (Join-Path $env:JAVA_HOME 'bin'))) {
                $env:Path = "$(Join-Path $env:JAVA_HOME 'bin');$env:Path"
            }
            return
        }
    }

    $candidates = @(
        (Join-Path $env:ProgramFiles 'Android\Android Studio\jbr'),
        (Join-Path $env:ProgramFiles 'Android\Android Studio\jre'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Android Studio\jbr'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Android Studio\jre')
    )

    foreach ($candidate in $candidates) {
        if (-not $candidate) {
            continue
        }

        $javaExe = Join-Path $candidate 'bin\java.exe'
        if (Test-Path $javaExe) {
            $env:JAVA_HOME = $candidate
            if (-not (($env:Path -split ';') -contains (Join-Path $candidate 'bin'))) {
                $env:Path = "$(Join-Path $candidate 'bin');$env:Path"
            }
            Write-Host "Using JAVA_HOME=$candidate"
            return
        }
    }

    throw 'No Java runtime found. Install Android Studio or set JAVA_HOME to a JDK/JBR path before building.'
}

if (-not (Test-Path $androidDir)) {
    throw "Android directory not found: $androidDir"
}

Set-Location $projectRoot
Set-JavaHome

if (-not $SkipClean) {
    flutter clean
    if ($LASTEXITCODE -ne 0) {
        throw 'flutter clean failed.'
    }
}

flutter pub get
if ($LASTEXITCODE -ne 0) {
    throw 'flutter pub get failed.'
}

Push-Location $androidDir
try {
    .\gradlew.bat $GradleTask
    if ($LASTEXITCODE -ne 0) {
        throw "Gradle task failed: $GradleTask"
    }
}
finally {
    Pop-Location
}