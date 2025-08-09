@echo off
setlocal enabledelayedexpansion

set FLUTTER_PARENT=..\\flutter
set THIRDPARTY_DIR=%FLUTTER_PARENT%
set FLUTTER_DIR=%THIRDPARTY_DIR%\\flutter

echo Checking Flutter installation target: %FLUTTER_DIR%

if not exist %THIRDPARTY_DIR% (
    echo Cloning thirdparty into %THIRDPARTY_DIR%...
    git clone git@github.com:GeniusVentures/thirdparty.git %THIRDPARTY_DIR%
) else (
    if not exist %THIRDPARTY_DIR%\\.git (
        echo Error: %THIRDPARTY_DIR% exists but is not a Git repository.
        echo Please remove or rename it before continuing.
        exit /b 1
    ) else (
        echo thirdparty already exists and is a Git repo.
    )
)

cd %THIRDPARTY_DIR%

echo Initializing flutter submodule...
git submodule update --init --recursive -- flutter

cd flutter

set FLUTTER_BIN_DIR=%CD%\\bin
echo Flutter is installed at: %FLUTTER_BIN_DIR%

echo.
echo To use Flutter now, run:
echo     set PATH=%FLUTTER_BIN_DIR%;%%PATH%%
echo.
echo To make this permanent, add the above line to your environment variables or user profile.
