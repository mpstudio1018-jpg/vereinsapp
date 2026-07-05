@echo off
setlocal

call "%~dp0build-android.cmd" bundleRelease %*
exit /b %ERRORLEVEL%