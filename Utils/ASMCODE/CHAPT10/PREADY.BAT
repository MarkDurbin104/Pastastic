@Echo Off
ReadyPrn
If ErrorLevel 1 GoTo IsReady
Echo Your printer is OFF-LINE
GoTo ExProc
:IsReady
Echo Your printer is ONLINE
:ExProc