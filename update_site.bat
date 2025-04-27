@echo off
setlocal enabledelayedexpansion
echo [1/4] Generating weekly links...
"C:\Program Files\R\R-4.4.1\bin\Rscript.exe" generate_weekly_links.R
if errorlevel 1 (
    echo ERROR: R script failed
    pause
    exit /b 1
)
echo [2/4] Rendering Quarto site...
quarto render
if errorlevel 1 (
    echo ERROR: Quarto render failed
    pause
    exit /b 1
)
echo [3/4] Checking for changes in docs...
git add docs
git diff --cached --quiet
if errorlevel 1 (
    echo Changes detected, committing...

    REM Get ISO timestamp for default message
    for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set datetime=%%I
    set ISODATE=!datetime:~0,4!-!datetime:~4,2!-!datetime:~6,2!T!datetime:~8,2!:!datetime:~10,2!:!datetime:~12,2!
    
    REM Prompt for commit message
    set /p COMMIT_MSG="Enter commit message (or press Enter for default timestamp): "
    
    REM Use entered message or default to timestamp
    if "!COMMIT_MSG!"=="" (
        set COMMIT_MSG=updated !ISODATE!
    )
    
    git commit -m "!COMMIT_MSG!"
    if errorlevel 1 (
        echo ERROR: Git commit failed
        pause
        exit /b 1
    )

    echo [4/4] Pushing changes...
    git push
    if errorlevel 1 (
        echo ERROR: Git push failed
        pause
        exit /b 1
    )
    echo Successfully pushed docs updates.
) else (
    echo No changes in docs to commit.
)
echo GitHub sync complete
pause
endlocal