@echo off
REM ===================================================================
REM com4j build script - sets up environment and builds with native DLL
REM Usage: build.cmd [clean]
REM ===================================================================

setlocal

REM --- Environment setup ---
set "JAVA_HOME=c:\toolbase\openjdk\1.8.0.412"
set "MAVEN_HOME=c:\toolbase-jre17\mvn\3.8.6"
set "PATH=%MAVEN_HOME%\bin;%JAVA_HOME%\bin;%PATH%"

REM --- VS Developer environment (required for native build) ---
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

REM --- Build --- -s "%~dp0.mvn\settings.xml"
"%MAVEN_HOME%\bin\mvn.cmd" clean deploy -Pnative-build %*
