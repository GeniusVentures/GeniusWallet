@echo off
REM Generate Dart models from tokens.json using quicktype only if source files changed
set SOURCE1=tokeninfo\tokens.json
set SOURCE2=tokeninfo\tokeninfo_schema.json
set OUTPUT_FILE=lib\tokeninfo\token_model.g.dart

:BUILD_TOKENS
    echo Generating token models...
    REM Create output directory if it doesn't exist
    if not exist "lib\tokeninfo" mkdir lib\tokeninfo
    REM Run quicktype to generate Dart models
    quicktype ^
      --lang dart ^
      --src tokeninfo\tokeninfo_schema.json ^
      --src-lang schema ^
      --out "%OUTPUT_FILE%" ^
      --no-date-times ^
      --all-properties-optional ^
      --null-safety ^
      --required-props ^
      --coders-in-class ^
      --no-enums ^
      --top-level SuperGeniusTokenInfo
    if %ERRORLEVEL% equ 0 (
        echo Token models generated successfully!
    ) else (
        echo Failed to generate token models!
        exit /b 1
    )
    exit /b 0

:CHECK_REBUILD
    REM Check if output exists
    if not exist "%OUTPUT_FILE%" (
        exit /b 1
    )
    REM Check if tokens.json is newer than output
    for %%i in ("%SOURCE1%") do set SOURCE1_TIME=%%~ti
    for %%i in ("%OUTPUT_FILE%") do set OUTPUT_TIME=%%~ti
    if "%SOURCE1_TIME%" gtr "%OUTPUT_TIME%" (
        exit /b 1
    )
    REM Check if schema is newer than output
    for %%i in ("%SOURCE2%") do set SOURCE2_TIME=%%~ti
    if "%SOURCE2_TIME%" gtr "%OUTPUT_TIME%" (
        exit /b 1
    )
    echo Token models are up to date
    exit /b 0

REM Check if rebuild is needed
call :CHECK_REBUILD
if %ERRORLEVEL% equ 1 (
    call :BUILD_TOKENS
    if %ERRORLEVEL% neq 0 (
        exit /b 1
    )
)
exit /b 0


