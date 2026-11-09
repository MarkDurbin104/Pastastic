unit FrontEndAU;

interface
uses
   Forms,Windows,Messages,Graphics,Classes,ComObj,GPCSBaseAU,Printers,Compress,
   GPCSGUID,StretchU,JPEG;

type
   TRemControl = class(TGPCSRemoteControl)
   private
      FDateEnabled:Boolean;
      FScaleReading:Integer;
    public
      procedure Initialize; override;
      destructor Destroy;   override;
      function Execute(const ExecName: WideString): WideString;  override;
      function KeyStroke(const KeyName: WideString): WideString; override;
      function HelpText: WideString;                             override;
      function Get_Title: WideString;                            override;
      function ScreenShot: OleVariant;                           override;
      function Get_DateEnabled: WordBool;                        override;
      function Get_ScaleReading: Integer;                        override;
      procedure Set_DateEnabled(Value: WordBool);                override;
      procedure Set_ScaleReading(Value: Integer);                override;
   end;

implementation

uses
   MainFU;

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
   Bitmap:TBitmap;
begin
   try
      while not (MainForm.CompExec.CompExec.CompMan.Ready) do
         Application.ProcessMessages;
      MainForm.CompExec.CompExec.UnderRemoteControl:=True;
      if ExecName[1] = '*' then
      begin
         MainForm.CompExec.Execute(Copy(ExecName,2,999),False);
         for I:=0 to 25 do begin sleep(1); Application.ProcessMessages; end;
         Bitmap:=MainForm.GetFormImage;
         Bitmap.SaveToFile('E:\Images\RemoteControl\'+Copy(ExecName,2,999)+'.BMP');
         Bitmap.Free;
      end
      else
      begin
         MainForm.CompExec.Execute(ExecName,False);
//         sleep(1);
         Application.ProcessMessages;
      end;
   except
   end;
end;
function TRemControl.KeyStroke(const KeyName: WideString): WideString;
begin
   MainForm.CompExec.CompExec.SetExecDataValues(KeyName);
end;
function TRemControl.ScreenShot: OleVariant;
var
   SBitMap:TBitmap;
//   DBitMap:TBitmap;
   JPEG:TJPEGImage;
//   Bitmap:TBitmap;
//   Compressor:TCompressor;
begin
//   Compressor:=TCompressor.Create;
//   DBitMap:=TBitMap.Create;
//   DBitMap.Width:=512;
//   DBitMap.Height:=384;
   JPEG:=TJPEGImage.Create;
   try
      SBitMap:=MainForm.GetFormImage;
//      Stretch(SBitmap,DBitmap);
      JPEG.Assign(SBitMap);
      SBitMap.Free;
      Result:='C:\ScreenShot.jpg';
      JPEG.SaveToFile(Result);
   except
   end;
   JPEG.Free;
//   DBitMap.Free;
//   try
//      DBitMap.Width:=512;
//      DBitMap.Height:=384;
//      Stretch(SBitmap,DBitmap);
//      Result:=Compressor.CreateArrayFromBitmap(DBitMap);
//      Bitmap:=MainForm.GetFormImage;
//      Result:=Compressor.CreateArrayFromBitmap(Bitmap);
//      Bitmap.Free;
//   except
//   end;
//   DBitMap.Free;
//   Compressor.Free;
end;
function TRemControl.HelpText: WideString;
begin
   try
      Result:=MainForm.SelectHelp('Help.txt',MainForm.CompExec.CurrentExec);
   except
   end;
end;
function TRemControl.Get_Title: WideString;
begin
   try
      Result:=MainForm.Title.Caption;
   except
   end;
end;
function TRemControl.Get_DateEnabled: WordBool;
begin
   Result:=MainForm.CompExec.CompExec.CompMan.Ready;
end;
function TRemControl.Get_ScaleReading: Integer;
begin
   Result:=FScaleReading;
end;
procedure TRemControl.Set_DateEnabled(Value: WordBool);
begin
   FDateEnabled:=Value;
end;
procedure TRemControl.Set_ScaleReading(Value: Integer);
begin
   MainForm.CompExec.CompExec.ScaleReading:=Value;
   FScaleReading:=Value;
end;

end.
