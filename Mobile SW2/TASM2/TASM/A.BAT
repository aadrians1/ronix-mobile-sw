@echo off
tasm %1 /l
tlink /t /x %1
