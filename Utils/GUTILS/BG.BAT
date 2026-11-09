@echo off
bcc -c %1.c
tlib /E gpa -+%1
