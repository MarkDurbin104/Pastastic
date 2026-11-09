time 1:00
md a:\keymaint
md a:\keymaint\007
md a:\iss
md a:\iss\posupdt
copy \keymaint\*.* a:\keymaint\*.* /Y
copy \keymaint\007\*.omr a:\keymaint\007\*.omr /Y
copy \iss\posupdt\posom007.flt a:\iss\posupdt\posom007.flt /Y
copy compkey.exe a:\ /Y
copy genrplu.exe a:\ /Y
touch a:\*.*
touch a:\keymaint\*.*
touch a:\keymaint\007\*.*
touch a:\iss\posupdt\*.*
time %1
