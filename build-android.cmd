@echo off
setlocal
setlocal EnableDelayedExpansion

set "PROJECT_ROOT=%~dp0"
set "ANDROID_DIR=%PROJECT_ROOT%android"
set "GRADLE_TASK=assembleDebug"
set "SKIP_CLEAN=0"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--skip-clean" (
    set "SKIP_CLEAN=1"
    shift
    goto parse_args
)

set "GRADLE_TASK=%~1"
shift
goto parse_args

:args_done
call :set_java_home
if errorlevel 1 exit /b 1

pushd "%PROJECT_ROOT%"

if "%SKIP_CLEAN%"=="0" (
    call flutter clean
    if errorlevel 1 (
        popd
        exit /b 1
    )
)

call flutter pub get
if errorlevel 1 (
    popd
    exit /b 1
)

pushd "%ANDROID_DIR%"
call gradlew.bat %GRADLE_TASK%
set "BUILD_EXIT=%ERRORLEVEL%"
popd
popd
exit /b %BUILD_EXIT%

:set_java_home
if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\java.exe" (
        echo Using JAVA_HOME=%JAVA_HOME%
        goto :eof
    )
)

where java >nul 2>nul
if not errorlevel 1 goto :eof

for %%D in (
    "%ProgramFiles%\Android\Android Studio\jbr"
    "%ProgramFiles%\Android\Android Studio\jre"
    "%LOCALAPPDATA%\Programs\Android Studio\jbr"
    "%LOCALAPPDATA%\Programs\Android Studio\jre"
) do (
    if exist "%%~fD\bin\java.exe" (
        set "JAVA_HOME=%%~fD"
        set "PATH=!JAVA_HOME!\bin;%PATH%"
        echo Using JAVA_HOME=!JAVA_HOME!
        goto :eof
    )
)

echo No Java runtime found. Install Android Studio or set JAVA_HOME to a JDK/JBR path before building.
exit /b 1