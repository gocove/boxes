@echo off
rem Run forms for a list of work orders from a text file.
rem Each line contains TAB-separated arguments for one order: 
rem   lot number
rem   part number
rem   total part count
rem   parts per box
rem Commented lines start with #.
rem
set DRYRUN=" "
set DRYRUN=%DRYRUN:"=%
set BOXES=%~dp0\boxes.bat
set PARTS=%~dp0\parts.bat

if not {%1}=={} if /I "%1"=="-d" (set DRYRUN=echo) & (shift)

if not {%1}=={} (set inputfile=%1) else (set inputfile=workorders.txt) 

if not exist %inputfile% (
  echo The input file %inputfile% does not exist.
  goto :eof
)

for /f "eol=# tokens=1-4 delims=	"  %%I in (%inputfile%) do @(
  %DRYRUN% %BOXES% "%%I" "%%J" "%%K" "%%L"
  %DRYRUN% %PARTS% "%%I" "%%J" "%%K" "%%L"
)

