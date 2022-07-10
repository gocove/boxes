@echo off
setlocal EnableDelayedExpansion
if {%1}=={} goto usage
if {%2}=={} goto usage
if {%3}=={} goto usage
if {%4}=={} goto usage
set lot=%1
set PN=%2
set /A parts=%3
set /A qtyperbox=%4
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
call :makeSVGhead

:newpage
set /A y_line1=page_offset+32
set /A y_line2=page_offset+60
call :makepageheader %y_line1% %y_line2%

for %%Y in (96, 216, 332, 452, 572, 692, 812, 932) do (
  for %%X in (96, 240, 384, 528, 672) do (
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

:makeSVGfilename
rem Use the date and time stamp to create a unique file name.
rem Do not use the part number to avoid its sanitization.

for /F "usebackq tokens=1,2" %%I in (`date /t`) do (set _d=%%J)
for /F "usebackq tokens=1,2" %%I in (`time /t`) do (set _t=%%I%%J)
set SVGFile="%lot%_%parts%_%qtyperbox%x%totalboxes%_%_d:/=%_%_t::=%.svg"
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
echo   ^<text x="400" y="%1" class="medium"^>Part Number:  %PN% ^</text^> >>%SVGFile%
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
