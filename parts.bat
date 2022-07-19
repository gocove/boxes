@echo off
if not {%1}=={} if not {%2}=={} if not {%3}=={} if not {%4}=={} goto start
goto usage

:start
rem Find the template file. It must be in the same directory as this batch file.
rem
set template=%~dp0parts_form_template.ps
if not exist %template% (
	echo Template file is missing: %template% does not exist.
	goto :eof
)
set psfile="parts.ps"
echo %%!  >%psfile%
rem Dequote arguments
echo /lot_number (%~1) def >>%psfile%
echo /part_number (%~2) def  >>%psfile%
echo /total_parts (%~3) def  >>%psfile%
echo /qty_per_box (%~4) def >>%psfile%
type %template% >>%psfile%
goto :eof

:usage
echo Usage:
echo     %~n0 lot_number part_number total_parts parts_per_box
goto :eof
