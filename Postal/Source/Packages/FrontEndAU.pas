unit FrontEndAU;

interface
uses
   Forms,Windows,Graphics,Classes,ComObj,GPCSBaseAU,Printers,CompressU,Bin2String;
  
type
   TRemControl = class(TGPCSRemoteControl)
    private
    protected
      function Execute(const ExecName: WideString): WideString;  override;
      function KeyStroke(const KeyName: WideString): WideString; override;
      function ScreenShot: WideString;                           override;
      function HelpText: WideString;                             override;
      function Get_Title: WideString;                            override;
    public
      procedure Initialize; override;
      destructor Destroy;   override;
   end;
   
implementation

uses
   TestButtonFU;
   
procedure TRemControl.Initialize; 
begin
   inherited Initialize;
end;
destructor TRemControl.Destroy;
begin
   inherited Destroy;
end;
function TRemControl.Execute(const ExecName: WideString): WideString; 
var
   I:Integer;
begin                         
   MainForm.CompExec.Execute(ExecName,False);
   for I:=0 to 20000 do Application.ProcessMessages;
end;
function TRemControl.KeyStroke(const KeyName: WideString): WideString;
begin
   Result:='';
end;
function TRemControl.ScreenShot: WideString;                          
var
   SStream:TStringStream;
   BitMap:TBitmap;
   Compressor:TCompress;
   S:String;
   SRect:TRect;
   DRect:TRect;
begin
   MainForm.RePaint;
   BitMap:=TBitMap.Create;
   BitMap.Width:=Screen.Width;
   BitMap.Height:=Screen.Height;
   with Screen do SRect:=Bounds(0,0,Width,Height);
   with BitMap do DRect:=Bounds(0,0,Width,Height);
   BitMap.Canvas.CopyRect(DRect,Application.MainForm.Canvas,SRect);
   SStream:=TStringStream.Create('');
   Bitmap.SaveToStream(SStream);
   BitMap.Free;
   SStream.Position:=0;
   Compressor:=TCompress.Create;
   S:=SStream.DataString;
   SStream.Free;
   S:=Compressor.CompressString(S);
   Compressor.Free;
   Result:=BinaryToString(S);
end;
function TRemControl.HelpText: WideString;                            
begin
   Result:=MainForm.SelectHelp('C:\Tan\Help.txt',MainForm.CompExec.CurrentExec);
end;
function TRemControl.Get_Title: WideString;
begin
   Result:=MainForm.Title.Caption;
end;

end.
