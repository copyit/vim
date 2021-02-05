@echo off

if "%1" == "" goto EMPTY

set "IN=%1"
set "OUT=%~dpn1.mp4"


call ffmpeg -f lavfi -i anullsrc -i "%IN%" -c:v libx264 -c:a aac -shortest ^
       -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" "%OUT%"

goto END

:EMPTY
echo require file name.

:END

echo.
pause


