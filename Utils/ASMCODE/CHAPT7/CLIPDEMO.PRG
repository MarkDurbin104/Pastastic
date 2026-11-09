*
*  Program ClipDemo ( Chapter 7 )
*
Save screen
NormColor   = "W/B"
BrightColor = "W+/B"
BlinkColor  = "W+/R+"
TitleColor  = "GR+/B"
MsgColor    = "W+/G+"
Set color to &NormColor
Clear
DemoLine = 1
StepRow  = 1
DummyVar = "                                                                 "
WhoTurned = "You have turned "
OutLine = DemoLine + StepRow
Do OutText with "The Clipper Demo Program - controlling the keyboard",TitleColor
Do OutText with "อออออออออออออออออออออออออออออออออออออออออออออออออออ"  , TitleColor
StepRow = 2
Do OutText with "Version 1.1    06.05.92   Voronezh, Russia" , TitleColor
Set color to &NormColor
DemoLine = Row()
OutLine = DemoLine + StepRow
If IsKbdEnh()
   KbdType = "an enhanced"
Else
   KbdType = "a standard"
EndIf
OutStr = "Determining the keyboard type"
Do OutText with OutStr , BrightColor
OutStr = "  You have " + KbdType + " keyboard.  "
Do OutText with Outstr , MsgColor
@ 23 , 1 Say " "
Set color to &BlinkColor
Wait

Set color to &NormColor
@ DemoLine , 0 Clear to 24,79
OutLine = DemoLine + StepRow
Do OutText with "Getting the NumLock state" , BrightColor
If GNumLock()
   OutStr = "ON"
Else
   OutStr = "OFF"
EndIf
Do OutText with "The NumLock state is now " + OutStr , NormColor
Do OutText with "Press the NumLock key" , NormColor
Do WaitNL
Do TestNL
@ 23 , 1 Say " "
Set color to &BlinkColor
Wait

Set color to &NormColor
@ DemoLine + StepRow * 2 , 0 Clear to 24,79
OutLine = DemoLine + StepRow * 2
Do OutText with "Press the NumLock key again" , BrightColor
Do WaitNL
Do TestNL
@ 23 , 1 Say " "
Set color to &BlinkColor
Wait

Set color to &NormColor
@ DemoLine , 0 Clear to 24,79
OutLine = DemoLine + StepRow
Do OutText with "Getting the CapsLock state" , BrightColor
If GCapsLock()
   OutStr = "ON"
Else
   OutStr = "OFF"
EndIf
Do OutText with "The CapsLock state is now " + OutStr , NormColor
Do OutText with "Press the CapsLock key" , NormColor
Do WaitCL
Do TestCL
@ 23 , 1 Say " "
Set color to &BlinkColor
Wait

Set color to &NormColor
@ DemoLine + StepRow * 2 , 0 Clear to 24,79
OutLine = DemoLine + StepRow * 2
Do OutText with "Press the CapsLock key again" , BrightColor
Do WaitCL
Do TestCL
@ 23 , 1 Say " "
Set color to &BlinkColor
Wait

WhoTurned = "Program is turning "
Set color to &NormColor
@DemoLine , 0 Clear to 24,79
OutLine = DemoLine + StepRow
Do OutText with "Changing the NumLock state from within the program" , BrightColor
Do OutText with "The NumLock state is turned ON" , NormColor
SnumLock (1)
Do TestNl
@ 23 , 1 Say " "
Set color to &BlinkColor
Wait
Set color to &NormColor
OutLine = DemoLine + StepRow * 2
@OutLine , 0 Clear to 24,79
Do OutText with "The NumLock state is turned OFF" , NormColor
SnumLock (0)
@ 23 , 1 Say " "
Set color to &BlinkColor
Wait


Set color to &NormColor
@DemoLine , 0 Clear to 24,79
OutLine = DemoLine + StepRow
Do OutText with "Changing the CapsLock state from within the program" , BrightColor
Do OutText with "The CapsLock state is turned ON" , NormColor
SCapsLock (1)
Do TestCL
@ 23 , 1 Say " "
Set color to &BlinkColor
Wait
Set color to &NormColor
OutLine = DemoLine + StepRow * 2
@OutLine , 0 Clear to 24,79
Do OutText with "The CapsLock state is turned OFF" , NormColor
SCapsLock (0)
Do TestCL
@ 23 , 1 Say " "
Set color to &BlinkColor
Wait
Set color to &Normcolor
Clear
Restore screen


Procedure OutText
Parameters TextStr , TextColor
Set color to &TextColor
ColumnNum = ( 80 - Len(TextStr)) / 2
@ OutLine , ColumnNum Say TextStr
OutLine = OutLine + StepRow
Set color to &NormColor
Return

Procedure WaitNL
NLStateO = GNumLock()
NLStateN = NLStateO
Do While NlStateO = NLStateN
   NLStateN = GNumLock()
EndDo
Return

Procedure TestNL
Clear Gets
If GNumLock()
   Do OutText with WhoTurned + " the NumLock ON" , NormColor
   Do OutText with "Now you can use the numeric pad" , NormColor
   OutStr = "Press few keys on numeric pad finishing with the ENTER key"
   Do OutText with OutStr , NormColor
   @ Row() + 2 , 7 Get DummyVar
   Read
Else
   Do OutText with WhoTurned + " the NumLock OFF" , NormColor
EndIf
DummyVar = "                                                                 "
Return

Procedure WaitCL
CLStateO = GCapsLock()
CLStateN = CLStateO
Do While CLStateO = CLStateN
   CLStateN = GCapsLock()
EndDo
Return

Procedure TestCL
Clear Gets
If GCapsLock()
   OutStr = "ON"
Else
   OutStr = "OFF"
EndIf
Do OutText with WhoTurned + " the CapsLock " + OutStr , NormColor
OutStr = "Press few character keys finishing with the ENTER key"
Do OutText with OutStr , NormColor
@ Row() + 2 , 7 Get DummyVar
Read
DummyVar = "                                                                 "
Return
