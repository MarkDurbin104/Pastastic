unit TPControlFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GPCSBase_TLB,GPCSBaseAU,GPCSGUID, StdCtrls,ComObj,Printers,Compress,
  ExtCtrls,PackStrListU,FileCtrl,JPEG;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Image1: TImage;
    Memo1: TMemo;
    Button5: TButton;
    Button6: TButton;
    RunOn: TEdit;
    Label1: TLabel;
    Button7: TButton;
    Memo2: TMemo;
    Button8: TButton;
    Button9: TButton;
    Panel1: TPanel;
    Button10: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
  private
    RemoteControl:IRemoteControl;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
   GUID:TGUID;
begin
   if GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post' then
      GUID:=Class_TanApplication
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Bermuda Post' then
      GUID:=Class_BerApplication
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Pakistan Post' then
      GUID:=Class_PakApplication
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Botswana Post' then
      GUID:=Class_BotApplication
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Uganda Post' then
      GUID:=Class_UgaApplication
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Guernsey Post' then
      GUID:=Class_GerApplication
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Swaziland Post' then
      GUID:=Class_SwaApplication
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Oman Post' then
      GUID:=Class_OmaApplication
   else
      GUID:=Class_SauApplication;

   if RemoteControl = nil then
   begin
      if RunOn.Text = '' then
         RemoteControl:=CreateComObject(GUID) as IRemoteControl
      else
         RemoteControl:=CreateRemoteComObject(RunOn.Text,GUID) as IRemoteControl;
   end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   if RemoteControl <> nil then
      RemoteControl:=nil;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   if RemoteControl <> nil then
      RemoteControl.Execute(Edit1.Text);
end;
procedure PrintScreen(BitMap:TBitMap;Text:String);
var
   SRect:TRect;
   DRect:TRect;
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   SL.CommaText:=Text;
   with BitMap do SRect:=Bounds(0,0,Width,Height);
   with BitMap do DRect:=Bounds((Printer.PageWidth-Width) div 2,50,Width,Height);
   Printer.Title:='GPCS Screen Shot';
   Printer.BeginDoc;
   Printer.Canvas.CopyRect(DRect,BitMap.Canvas,SRect);
   with Printer.Canvas do
   begin
      for I:=0 to SL.Count-1 do
      begin
         TextOut(10,BitMap.Height+100+I*TextHeight('Wg'),SL[I]);
      end;
   end;
   Printer.EndDoc;
   BitMap.Free;
   SL.Free;
end;
procedure TForm1.Button4Click(Sender: TObject);
var
//   BitMap:TBitMap;
//   Compressor:TCompressor;
   JPEG:TJPEGImage;
begin
   if RemoteControl <> nil then
   begin
//      Compressor:=TCompressor.Create;
//      BitMap:=Compressor.CreateBitmapFromArray(RemoteControl.ScreenShot);
//      Compressor.Free;
      JPEG:=TJPEGImage.Create;
      JPEG.LoadFromFile(RemoteControl.ScreenShot);
      Image1.Picture.Bitmap.Assign(JPEG);
      JPEG.Free;
//      BitMap.Free;
      Memo2.Lines.CommaText:=CurrentMemoryStatus;
//      PrintScreen(Image1.Picture.Bitmap,RemoteControl.HelpText);
   end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
   I,J:Integer;
//   BitMap:TBitMap;
   WB:Variant;
   Shape:Variant;
   SL:TPackStringList;
   Title:String;
   Compressor:TCompressor;
begin
   if RemoteControl <> nil then
   begin
      Visible:=False;
      SL:=TPackStringList.Create;
      Compressor:=TCompressor.Create;
      WB:=CreateOleObject('Word.Application');
      WB.Documents.Add;
      WB.Visible:=True;
      try
         for I:=0 to Memo1.Lines.Count-1 do
         begin
            RemoteControl.Execute(Memo1.Lines[I]);
            SL.PackText:=RemoteControl.HelpText;
//            Sleep(100);
            if Copy(Memo1.Lines[I],1,6) = 'Group.' then
            begin
               WB.Selection.Style:='Heading 1';
               Title:='Menu - '+RemoteControl.Title
            end
            else
            begin
               WB.Selection.Style:='Heading 2';
               Title:='Form - '+RemoteControl.Title;
            end;
            try
//               WB.Selection.Style:='Heading 1';
               WB.Selection.TypeText(Title);
               WB.Selection.TypeParagraph;
               WB.Selection.TypeParagraph;
//               BitMap:=Compressor.CreateBitmapFromArray(RemoteControl.ScreenShot);
//               BitMap.SaveToFile('E:\Images\RemoteControl\'+Memo1.Lines[I]+'.BMP');
//               BitMap.Free;
               Memo2.Lines.CommaText:=CurrentMemoryStatus;
               Shape:=WB.Selection.InlineShapes.AddPicture(RemoteControl.ScreenShot,False,True);
               Shape.Width:=320;
               Shape.Height:=240;
               WB.Selection.TypeParagraph;
               WB.Selection.TypeParagraph;
               for J:=0 to SL.Count-1 do
               begin
                  WB.Selection.TypeText(SL[J]);
                  WB.Selection.TypeParagraph;
               end;
               if I <> Memo1.Lines.Count-1 then
                  WB.Selection.InsertBreak(Type:=1);
            except
               WB.Selection.TypeText('------------- Exception ! -------------');
               WB.Selection.TypeParagraph;
            end;
            RemoteControl.Execute('Cancel');
         end;
      except
      end;
      Compressor.Free;
      Visible:=True;
      WB:=Unassigned;
      RemoteControl:=nil;
   end;
end;
procedure TForm1.Button6Click(Sender: TObject);
begin
   ShowMessage(RemoteControl.HelpText);
end;

procedure TForm1.Button7Click(Sender: TObject);
var
   BitMap:TBitMap;
   I:Integer;
   Compressor:TCompressor;
begin
   if RemoteControl <> nil then
   begin
//      Visible:=False;
      try
         Compressor:=TCompressor.Create;
         for I:=0 to Memo1.Lines.Count-1 do
         begin
            RemoteControl.Execute(Memo1.Lines[I]);
            BitMap:=Compressor.CreateBitmapFromArray(RemoteControl.ScreenShot);
            BitMap.SaveToFile('E:\Images\RemoteControl\'+Memo1.Lines[I]+'.BMP');
            BitMap.Free;
            RemoteControl.Execute('Cancel');
            Memo2.Lines.CommaText:=CurrentMemoryStatus;
         end;
         Compressor.Free;
      except
      end;
//      Visible:=True;
      RemoteControl:=nil;
   end;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
   Memo2.Lines.CommaText:=CurrentMemoryStatus;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
   RemoteControl:=nil;
end;

function FuncKey(Keys:String;var Index:Integer):String;
var
   FKey:String;
   I:Integer;
begin
   Result:=' ';
   Inc(Index);
   I:=Index;
   FKey:='';
   while (I <= Length(Keys)) and (Keys[I] <> ']') do
   begin
      FKey:=FKey+Keys[I];
      Inc(I);
   end;
   if I <= Length(Keys) then
   begin
      Index:=I;
      if FKey = 'CR' then
         Result:=#13;
   end;
end;
procedure KeySequence(RemoteControl:IRemoteControl;Keys:String);
var
   I:Integer;
begin
   I:=1;
   while I <= Length(Keys) do
   begin
      if Keys[I] = '[' then
         RemoteControl.KeyStroke(FuncKey(Keys,I))
      else
         RemoteControl.KeyStroke(Keys[I]);
      Inc(I);
   end;
end;
procedure TForm1.Button10Click(Sender: TObject);
var
   I,J:Integer;
   WB:Variant;
   Shape:Variant;
   ActiveDocument:Variant;
   SL:TPackStringList;
   Title:String;
   Posi:Integer;
   Weight:String;
   Keys:String;
   Section:String;
   Compressor:TCompressor;
   GUID:TGUID;
   PC:Integer;
   Template:String;
begin
   if GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post' then
   begin
      GUID:=Class_TanApplication;
      Template:='Tanzania Post Office UG';
      if FileExists('TanzaniaComponents.txt') then
         Memo1.Lines.LoadFromFile('TanzaniaComponents.txt');
   end
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Bermuda Post' then
   begin
      Template:='Bermuda Post Office UG';
      GUID:=Class_BerApplication;
      if FileExists('BermudaComponents.txt') then
         Memo1.Lines.LoadFromFile('BermudaComponents.txt');
   end
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Pakistan Post' then
   begin
      Template:='Pakistan Post Office UG';
      GUID:=Class_PakApplication;
      if FileExists('PakistanComponents.txt') then
         Memo1.Lines.LoadFromFile('PakistanComponents.txt');
   end
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Saudi Post' then
   begin
      Template:='Saudi Post Office UG';
      GUID:=Class_SauApplication;
      if FileExists('SaudiComponents.txt') then
         Memo1.Lines.LoadFromFile('SaudiComponents.txt');
   end
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Botswana Post' then
   begin
      Template:='Botswana Post Office UG';
      GUID:=Class_BotApplication;
      if FileExists('BotswanaComponents.txt') then
         Memo1.Lines.LoadFromFile('BotswanaComponents.txt');
   end
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Uganda Post' then
   begin
      Template:='Uganda Post Office UG';
      GUID:=Class_UgaApplication;
      if FileExists('UgandaComponents.txt') then
         Memo1.Lines.LoadFromFile('UgandaComponents.txt');
   end
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Guernsey Post' then
   begin
      Template:='';
//      Template:='Guernsey Post Office UG';
      GUID:=Class_GerApplication;
      if FileExists('GuernseyComponents.txt') then
         Memo1.Lines.LoadFromFile('GuernseyComponents.txt');
   end
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Swaziland Post' then
   begin
      Template:='Swaziland Post Office UG';
      GUID:=Class_SwaApplication;
      if FileExists('SwazilandComponents.txt') then
         Memo1.Lines.LoadFromFile('SwazilandComponents.txt');
   end
   else
      Template:='';

   RemoteControl:=CreateComObject(GUID) as IRemoteControl;
   Sleep(30000);
   PC:=0;
   if RemoteControl <> nil then
   begin
      try
         Visible:=False;
         SL:=TPackStringList.Create;
         Compressor:=TCompressor.Create;
         WB:=CreateOleObject('Word.Application');
         ActiveDocument:=WB.Documents.Add(Template);
         if FileExists('C:\UGuide.doc') then
            DeleteFile('C:\UGuide.doc');
         ActiveDocument.SaveAs(FileName:='C:\UGuide.doc');
         WB.Selection.GoTo(What:=1,Which:=1,Count:=4);
         WB.Visible:=True;
         try
            for I:=0 to Memo1.Lines.Count-1 do
            begin
               Posi:=Pos('^',Memo1.Lines[I]);
               Section:='';
               if Posi > 0 then
               begin
                  Section:=Copy(Memo1.Lines[I],Posi+1,9999)+' ';
                  Memo1.Lines[I]:=Copy(Memo1.Lines[I],1,Posi-1);
               end;
               Posi:=Pos('^',Section);
               Weight:='0';
               if Posi > 0 then
               begin
                  Weight:=Trim(Copy(Section,Posi+1,9999));
                  Section:=Copy(Section,1,Posi-1)+' ';
               end;
               Posi:=Pos('^',Weight);
               Keys:='';
               if Posi > 0 then
               begin
                  Keys:=Trim(Copy(Weight,Posi+1,9999));
                  Weight:=Copy(Weight,1,Posi-1)+' ';
               end;
               RemoteControl.ScaleReading:=StrToIntDef(Weight,0);
               RemoteControl.Execute(Memo1.Lines[I]);
               Sleep(250);
               KeySequence(RemoteControl,Keys);
               if Copy(Memo1.Lines[I],1,6) = 'Group.' then
               begin
                  WB.Selection.Style:='Heading 1';
                  Title:=Section+'Menu - '+RemoteControl.Title
               end
               else
               begin
                  WB.Selection.Style:='Heading 2';
                  Title:=Section+'Form - '+RemoteControl.Title;
               end;
               try
                  WB.Selection.TypeText(Title);
                  WB.Selection.MoveLeft(Unit:=2,Count:=1,Extend:=1); // Select Text
                  WB.ActiveDocument.Indexes.MarkEntry(Range:=WB.Selection.Range,Entry:=Title,EntryAutoText:=Title);
                  WB.Selection.MoveRight(Unit:=1,Count:=1); // De-Select Text
                  WB.Selection.TypeParagraph;
                  WB.Selection.Style:='Normal';
                  WB.Selection.TypeParagraph;
                  WB.Selection.TypeText('Ref:'+Memo1.Lines[I]);
                  WB.Selection.TypeParagraph;
                  Memo2.Lines.CommaText:=CurrentMemoryStatus;
                  Shape:=WB.Selection.InlineShapes.AddPicture(RemoteControl.ScreenShot,False,True);
//                  Shape.Width:=320;
//                  Shape.Height:=240;
                  WB.Selection.TypeParagraph;
                  WB.Selection.TypeParagraph;
                  SL.PackText:=RemoteControl.HelpText;
                  for J:=0 to SL.Count-1 do
                  begin
                     WB.Selection.TypeText(SL[J]);
                     WB.Selection.TypeParagraph;
                  end;
                  if I <> Memo1.Lines.Count-1 then
                     WB.Selection.InsertBreak(Type:=1);
               except
                  WB.Selection.TypeText('------------- Exception ! -------------');
                  WB.Selection.TypeParagraph;
               end;
               RemoteControl.Execute('Cancel');
               Inc(PC);
               if (PC mod 10) = 0 then
                  ActiveDocument.Save;
            end;                          
         except
         end;
         Compressor.Free;
         Visible:=True;
         WB:=Unassigned;
      except
      end;
   end;
   RemoteControl:=nil;
end;

end.
