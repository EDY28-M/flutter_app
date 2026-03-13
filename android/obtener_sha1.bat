@echo off
REM Obtener SHA-1 para Google Sign-In (evita error con Java 25)
set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
call gradlew.bat --stop 2>nul
call gradlew.bat signingReport
pause
