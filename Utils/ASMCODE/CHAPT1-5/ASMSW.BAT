@Echo off
If %1. == 5. GoTo Masm5
If %1. == 6. GoTo Masm6
If %1. == 61. GoTo Masm61
If %1. == tasm. GoTo Tasm
If %1. == TASM. GoTo Tasm
:Masm5
Set AsmPath=d:\masm5\bin
Set LnkPath=d:\masm5\bin
Set DebPath=d:\masm5\bin
Set AsmPg=masm
Set AsmOpt= /Zd
Set AsmListF5=,%tmp%\Obj.Obj,%tmp%\Lst.Lst,Nul
Set AsmListF6=
Set AsmListFT=
Echo.
Echo Microsoft Macro Assembler 5.10 and CodeView 2.3 will be used
Echo.
GoTo EndMas
:Masm6
Set AsmPath=d:\masm\bin
Set LnkPath=d:\masm\binb
Set DebPath=d:\masm\bin
Set AsmPg=ml
Set AsmOpt= /Zd /c
Set AsmListF5=
Set AsmListF6= /Fo%tmp%\Obj.Obj /Fl%tmp%\Lst.Lst
Set AsmListFT=
Echo.
Echo Microsoft Macro Assembler 6.0 and CodeView 3.14 will be used
Echo.
GoTo EndMas
:Masm61
Set AsmPath=d:\masm61\bin
Set LnkPath=d:\masm61\bin
Set DebPath=d:\masm61\bin
Set AsmPg=ml
Set AsmOpt= /Zd /c
Set AsmListF5=
Set AsmListF6= /Fo%tmp%\Obj.Obj /Fl%tmp%\Lst.Lst
Set AsmListFT=
Echo.
Echo Microsoft Macro Assembler 6.10 and CodeView 4.0 will be used
Echo.
:EndMas
Set AsmOptD= /Zi
Set LnkPg=link
Set DebPg=cv
Set SetDeb= /CO
GoTo FullEx
:Tasm
Set AsmPath=d:\tasm
Set LnkPath=d:\tasm
Set DebPath=d:\tasm
Set AsmPg=tasm
Set AsmOpt= /l
Set AsmOptD= /zi
Set LnkPg=tlink
Set DebPg=td
Set SetDeb= /v
Set AsmListF5=
Set AsmListF6=
Set AsmListFT=,%tmp%\Obj.Obj,%tmp%\Lst.Lst
Echo.
Echo Borland Turbo Assembler and Turbo Debugger will be used
Echo.
:FullEx