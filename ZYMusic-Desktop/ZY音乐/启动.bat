@echo off
cd /d "%~dp0"
set "JDK=%~dp0..\..\jdk21\jdk-21.0.11+10\bin\javaw.exe"
set "DATA=%~dp0..\..\ZYmusic\target\runtime"
set "LIB=%~dp0app"
set "MP=%LIB%\javafx-base-17.0.2.jar;%LIB%\javafx-base-17.0.2-win.jar;%LIB%\javafx-controls-17.0.2.jar;%LIB%\javafx-controls-17.0.2-win.jar;%LIB%\javafx-graphics-17.0.2.jar;%LIB%\javafx-graphics-17.0.2-win.jar;%LIB%\javafx-web-17.0.2.jar;%LIB%\javafx-web-17.0.2-win.jar;%LIB%\javafx-media-17.0.2.jar;%LIB%\javafx-media-17.0.2-win.jar"
start "" "%JDK%" -Dzymusic.data.dir="%DATA%" --module-path "%MP%" --add-modules=ALL-MODULE-PATH -cp "%LIB%\*" com.zjlymusic.app.DesktopApp
