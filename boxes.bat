@echo off
setlocal EnableDelayedExpansion
if not {%1}=={} if not {%2}=={} if not {%3}=={} if not {%4}=={} goto start
goto usage

:start
set lot=%1
call :validatenumber %3 total_parts
if not defined _n goto usage
set /A parts=_n
call :validatenumber %4 parts_per_box
if not defined _n goto usage
set /A qtyperbox=_n
set /A totalboxes=parts/qtyperbox
set /A qtyinpartialbox=parts%%qtyperbox
if %qtyinpartialbox% gtr 0 set /A totalboxes+=1
set /A box=1
set /A page_offset=0
set /A numberofpages=totalboxes/40
set /A lastpage=totalboxes%%40
if %lastpage% gtr 0 set /A numberofpages+=1
set /A svgheight=numberofpages*1056
call :makeSVGfilename
call :escapeSVGspecialcharacters %2
call :makeSVGhead

:newpage
set /A y_line1=page_offset+32
set /A y_line2=page_offset+60
call :makepageheader %y_line1% %y_line2%

for %%Y in (96, 216, 332, 452, 572, 692, 812, 932) do (
  for %%X in (72, 216, 360, 504, 648) do (
    if !box! equ !totalboxes! (
      if !qtyinpartialbox! equ 0 (call :makebox %%X %%Y
      ) else ( call :makepartialbox %%X %%Y )
      goto finish
    )
    call :makebox %%X %%Y
  )
)
set /A page_offset+=1056
goto newpage

:makebox
set /A y_offset=page_offset+%2
set /A x_text=%1+22
set /A y_text=y_offset+22
set /A x_count=%1+118
set /A y_count=y_offset+83
if {%3}=={} (set /A partcount=box*qtyperbox
) else ( set /A partcount=%3 )
call :makeSVGbox %1 %y_offset% %x_text% %y_text% %box% %x_count% %y_count% %partcount%
set /A box+=1
goto :eof

:makepartialbox
call :makebox %1 %2 %parts%
rem Mark the box as partial
set /A x=%1+120
set /A y_offset=page_offset+%2
set /A y=y_offset+80
call :makeSVGline %x% %y_offset% %1 %y%
set /A x-=10
set /A y-=10
call :makeSVGpartialcount %x% %y% %qtyinpartialbox%
goto :eof

:validatenumber
set _n=%1
set _n=%_n:,=%
set _n=%_n:"=%
set _nan=
for /F "delims=0123456789" %%I in ("%_n%") do set _nan=%%J
if not defined _nan if %_n% GTR 0 goto :eof
echo %2 [%1] must be a natural number
set _n=
goto :eof

:makeSVGfilename
rem Use the date and time stamp to create a unique file name.
rem Do not use the part number to avoid its sanitization.

for /F "usebackq tokens=1,2" %%I in (`date /t`) do (set _d=%%J)
for /F "usebackq tokens=1,2" %%I in (`time /t`) do (set _t=%%I%%J)
set SVGFile="%lot%_%parts%_%qtyperbox%x%totalboxes%_%_d:/=%_%_t::=%.svg"
goto :eof

:escapeSVGspecialcharacters
rem Escape the ampersand, left angle bracket and right angle bracket
rem in the part number.
set _pn=%1
set _pn=%_pn:&=^&amp;%
set _pn=%_pn:<=^&lt;%
set _pn=%_pn:>=^&gt;%
set PN=%_pn%
goto :eof

:finish
call :makeSVGfooter
exit /b

rem SVG 
rem

:makeSVGhead
echo ^<svg xmlns="http://www.w3.org/2000/svg" >%SVGFile%
echo    width="816" height="%svgheight%"^> >>%SVGFile%
echo   ^<style^> >>%SVGFile%
echo     .small  { font: italic 14px sans-serif; } >>%SVGFile%
echo     .heavy  { font: bold 18px sans-serif; } >>%SVGFile%
echo     .medium { font: 16px sans-serif; } >>%SVGFile%
echo   ^</style^> >>%SVGFile%
echo      ^<symbol id="box"^> >>%SVGFile%
echo        ^<rect width="120" height="80" fill="none" stroke="black" stroke-width="3"/^> >>%SVGFile%
echo        ^<circle cx="22" cy="22" r="18" fill="none" stroke="black" stroke-width="2"/^> >>%SVGFile%
echo      ^</symbol^> >>%SVGFile%
goto :eof

:makeSVGfooter
echo ^</svg^> >>%SVGFile%
goto :eof

:makepageheader
echo   ^<text x="96" y="%1" class="medium"^>Lot:  %lot% ^</text^> >>%SVGFile%
echo   ^<text x="400" y="%1" class="medium"^>Part Number:  %PN:"=% ^</text^> >>%SVGFile%
echo   ^<text x="96" y="%2" class="medium"^>Total Parts:  %parts% ^</text^> >>%SVGFile%
echo   ^<text x="400" y="%2" class="medium"^>Qty Per Box:  %qtyperbox% ^</text^> >>%SVGFile%
echo   ^<text x="640" y="%2" class="medium"^>Boxes:  %totalboxes% ^</text^> >>%SVGFile%
goto :eof

:makeSVGbox
echo   ^<use x="%1" y="%2" href="#box"/^> >>%SVGFile%
echo   ^<text x="%3" y="%4" text-anchor="middle" dominant-baseline="middle" class="heavy"^>%5^</text^> >>%SVGFile%
echo   ^<text x="%6" y="%7" text-anchor="end" dominant-baseline="hanging" class="small"^>%8^</text^> >>%SVGFile%
goto :eof


:makeSVGline 
echo   ^<line x1="%1" y1="%2" x2="%3" y2="%4" stroke="black" stroke-width="2"/^> >>%SVGFile%
goto :eof

:makeSVGpartialcount
echo   ^<text x="%1" y="%2" text-anchor="end" class="heavy"^>%3^</text^> >>%SVGFile%
goto :eof

:usage
echo Usage:
echo     boxes.bat lot_number part_number total_parts parts_per_box
echo Creates an SVG file with a list of boxes.
goto :eof
