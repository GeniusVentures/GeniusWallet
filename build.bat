
@echo off

REM Default values
set BUILD_TYPE=Release
set BUILD_MODE=--release
set EXTRA_ARGS=

REM Parse arguments
:parse_args
if "%~1"=="" goto :done_parsing
if "%~1"=="--debug" (
    set BUILD_MODE=--debug
) else (
    set EXTRA_ARGS=%EXTRA_ARGS% %~1
)
shift
goto :parse_args
:done_parsing

set CMAKE_ARGUMENTS=" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DGENIUS_DEPENDENCY_BRANCH=TestNet-Phase-3.1 -DBRANCH_IS_TAG=ON -DCMAKE_MESSAGE_LOG_LEVEL=STATUS"

call tools\generate_tokens.bat
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

flutter build windows %EXTRA_ARGS% %BUILD_MODE%