@echo off
setlocal
cargo build --release
if errorlevel 1 exit /b %errorlevel%
cargo test --release
if errorlevel 1 exit /b %errorlevel%
if not exist dist mkdir dist
if errorlevel 1 exit /b %errorlevel%
copy /Y target\release\hello.exe dist\hello.exe
if errorlevel 1 exit /b %errorlevel%
exit /b 0
