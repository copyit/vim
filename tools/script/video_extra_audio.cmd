@echo off

if "%1" == "" goto HELP

set "IN=%1"
set "OUT=%~dpn1.mp3"

if "%2" == "" goto NEXT
set "OUT=%2"
:NEXT

call ffmpeg -i "%IN%" -vn -c:a mp3 -ar 48000 -ac 2 "%OUT%"

pause

goto END

:HELP
echo usage: video_gif_to_mp4 ^<input^> [^<output^>]

:END
echo.




