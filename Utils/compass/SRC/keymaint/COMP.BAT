@echo off
del \keymaint\01\keymap01.omr
copy compkey.key compkey!.!!!
td compkey %1
del compkey!.!!!
