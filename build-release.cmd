@echo off
setlocal

call "%~dp0build-android.cmd" assembleRelease %*
exit /b %ERRORLEVEL%