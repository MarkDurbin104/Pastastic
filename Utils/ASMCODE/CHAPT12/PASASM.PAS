Unit PasAsm ;
interface
Function GetScan (TextPrompt:Char; Var SpecInd:Boolean): Byte ;
Implementation
{$L GetScan}
Function GetScan; external;
End.