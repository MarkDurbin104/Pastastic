unit TDFU;

interface

uses
  Windows, ComObj,Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,PackStrListU,GPCSGUID,GPCSBase_TLB, ExtCtrls,WinExecU;

const
   KWExecute      = 'Execute'     ;
   KWCompExecute  = 'CompExecute' ;
   KWStockExecute = 'StockExecute';
   KWDom          = 'Dom'         ;
   KWSelect       = 'Select'      ;
   
type
  TDomainEntry = class(TObject)
     Name:String;
     Value:String;
  end;
  TExecLine = class(TObject)
     Domains:TList;
     Selects:TStringList;
  end;
  TExecLines = class(TObject)
     Lines:TList;
  end;
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    OD: TOpenDialog;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    AC: TRadioGroup;
    Button5: TButton;
    GroupBox1: TGroupBox;
    Button6: TButton;
    NoDays: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    NoTests: TEdit;
    RD: TCheckBox;
    ExecMemo: TMemo;
    Button7: TButton;
    EOD: TEdit;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
     RemoteControl:IRemoteControl;
     LoopTerminated:Boolean;
     CustomerSessions:Integer;
     procedure AddLines(List:TStrings;StartLine,EndLine:Integer);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.AddLines(List:TStrings;StartLine,EndLine:Integer);
var
  I:Integer;
  SL:TPackStringList;
  LSL:TPackStringList;
  PSL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
   PSL:=TPackStringList.Create;
   if (Pos(KWExecute,Trim(List[StartLine])) = 1) then
   begin
      Memo1.Lines.Add(Copy(Trim(List[StartLine]),Length(KWExecute)+2,Length(List[StartLine])));
      for I:=StartLine+1 to EndLine do
      begin
         if (Pos(KWSelect,Trim(List[I])) = 1) then
         begin
            PSL.Add(Copy(Trim(List[I]),Length(KWSelect)+2,Length(List[I])));
//            Memo1.Lines.Add('Press '+Copy(Trim(List[I]),Length(KWSelect)+2,Length(List[I])));
         end
         else if (Pos(KWDom,Trim(List[I])) = 1) then
         begin
            SL.CommaText:=Copy(Trim(List[I]),Length(KWDom)+2,Length(List[I]));
            LSL.Add(SL.PackText);
//            if SL.Count = 2 then
//               Memo1.Lines.Add(SL[0]+' := '+SL[1]);
         end;
      end;
      SL.Clear;
      SL.Add(PSL.PackText);
      SL.Add(LSL.PackText);
      Memo1.Lines.Add(SL.PackText);
   end          
   else if (Pos(KWCompExecute,Trim(List[StartLine])) = 1)  then
   begin
      Memo1.Lines.Add('Comp'+Copy(Trim(List[StartLine]),Length(KWCompExecute)+2,Length(List[StartLine])));
   end;
   PSL.Free;
   LSL.Free;
   SL.Free;
end;                                
procedure TForm1.Button1Click(Sender: TObject);
var
   SL:TStringList;
   I:Integer;
   StartLine:Integer;
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

   if OD.Execute then
   begin
      RemoteControl:=CreateComObject(GUID) as IRemoteControl;
      Memo1.Lines.Clear;
      StartLine:=-1;
      SL:=TStringList.Create;
      SL.LoadFromFile(OD.FileName);
      for I:=0 to SL.Count-1 do
      begin
         if (Pos(KWExecute     ,Trim(SL[I])) = 1) 
         or (Pos(KWCompExecute ,Trim(SL[I])) = 1) 
         or (Pos(KWStockExecute,Trim(SL[I])) = 1) then
         begin
           if StartLine <> -1 then
              AddLines(SL,StartLine,I-1);
           StartLine:=I;
         end
      end;
      if StartLine <> -1 then
         AddLines(SL,StartLine,SL.Count-1);
      SL.Free;
   end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   I:Integer;
begin
   if RemoteControl <> nil then
   begin
      try
         I:=0;
         while (I < Memo1.Lines.Count) and (not Application.Terminated) and (not LoopTerminated) do
         begin
            Application.ProcessMessages;
            if Copy(Memo1.Lines[I],1,4) = 'Comp' then
            begin
               RemoteControl.Execute(Copy(Memo1.Lines[I],5,Length(Memo1.Lines[I])));
            end
            else
            begin
               RemoteControl.Execute(Memo1.Lines[I]);
               if Memo1.Lines[I] = 'Product.Cash' then
               begin
                  Inc(I);
                  RemoteControl.Execute('Complete');
                  case AC.ItemIndex of
                     0 : RemoteControl.Execute('End Customer');
                     1 : RemoteControl.Execute('Receipt');
                     2 : RemoteControl.Execute('Cancel Customer');
                  end;
                  Inc(CustomerSessions);
                  Caption:='Test Data - '+IntToStr(CustomerSessions)+' Customer Sessions';
               end
               else
               begin
                  Inc(I);
                  RemoteControl.KeyStroke(Memo1.Lines[I]);
                  RemoteControl.Execute('Complete');
                  RemoteControl.Execute('Cancel');
               end;
            end;
            Inc(I);
         end; 
         Windows.Beep(5000,2000);
      except
      end;
   end;
   if Application.Terminated then RemoteControl:=nil;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   RemoteControl:=nil;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
   I:Integer;
begin
   LoopTerminated:=False;
   while (not Application.Terminated) and (not LoopTerminated) do
   begin
      try
         I:=0;
         while (I < Memo1.Lines.Count) and (not Application.Terminated) and (not LoopTerminated) do
         begin
            Application.ProcessMessages;
            if Copy(Memo1.Lines[I],1,4) = 'Comp' then
            begin
               RemoteControl.Execute(Copy(Memo1.Lines[I],5,Length(Memo1.Lines[I])));
            end
            else
            begin
               RemoteControl.Execute(Memo1.Lines[I]);
               if Memo1.Lines[I] = 'Product.Cash' then
               begin
                  Inc(I);
                  RemoteControl.Execute('Complete');
                  case AC.ItemIndex of
                     0 : RemoteControl.Execute('End Customer');
                     1 : RemoteControl.Execute('Receipt');
                     2 : RemoteControl.Execute('Cancel Customer');
                  end;
                  Inc(CustomerSessions);
                  Caption:='Test Data - '+IntToStr(CustomerSessions)+' Customer Sessions';
               end
               else
               begin
                  Inc(I);
                  RemoteControl.KeyStroke(Memo1.Lines[I]);
                  RemoteControl.Execute('Complete');
                  RemoteControl.Execute('Cancel');
               end;
            end;
            Inc(I);
         end;
      except
      end;
   end;
   if Application.Terminated then RemoteControl:=nil;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
   LoopTerminated:=True;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
   I,Day:Integer;
   ExecCount:Integer;
   StartSystemTime:TSystemTime;
   SystemTime:TSystemTime;
   NumbDays:Integer;
   CurrentDay:Integer;
   MoveMonth:Boolean;
begin
   if RemoteControl = nil then Button1Click(Button1);
   if RemoteControl = nil then Exit;
   LoopTerminated:=False;
   GetSystemTime(StartSystemTime);
   GetSystemTime(SystemTime);
   Day:=0;
   NumbDays:=StrToIntDef(NoDays.Text,1);
   while (not Application.Terminated)
     and (Day < NumbDays)
     and (not LoopTerminated) do
   begin
      ExecCount:=0;
      while (not Application.Terminated)
        and (ExecCount < StrToIntDef(NoTests.Text,1))
        and (not LoopTerminated) do
      begin
         try
            Inc(ExecCount);
            I:=0;
            while (I < Memo1.Lines.Count) and (not Application.Terminated) and (not LoopTerminated) do
            begin
               Application.ProcessMessages;
               if Copy(Memo1.Lines[I],1,4) = 'Comp' then
               begin
                  RemoteControl.Execute(Copy(Memo1.Lines[I],5,Length(Memo1.Lines[I])));
               end
               else
               begin
                  RemoteControl.Execute(Memo1.Lines[I]);
                  if Memo1.Lines[I] = 'Product.Cash' then
                  begin
                     Inc(I);
                     RemoteControl.Execute('Complete');
                     case AC.ItemIndex of
                        0 : RemoteControl.Execute('End Customer');
                        1 : RemoteControl.Execute('Receipt');
                        2 : RemoteControl.Execute('Cancel Customer');
                     end;
                     Inc(CustomerSessions);
                     Caption:='Test Data - '+IntToStr(CustomerSessions)+' Customer Sessions';
                  end
                  else
                  begin
                     Inc(I);
                     RemoteControl.KeyStroke(Memo1.Lines[I]);
                     RemoteControl.Execute('Complete');
                     RemoteControl.Execute('Cancel');
                  end;
               end;
               Inc(I);
            end;
         except
         end;
      end;
      if NumbDays > 1 then
      begin
         CurrentDay:=SystemTime.wDay;
         Inc(CurrentDay);
         if CurrentDay > 28 then
         begin
            MoveMonth:=False;
            case SystemTime.wMonth of
               2 : if SystemTime.wYear mod 4 = 0 then
                   begin
                     if Day > 29 then MoveMonth:=True;
                   end
                   else
                   begin
                     if Day > 28 then begin MoveMonth:=True; end;
                   end;
               4,6,9,11 : if Day > 30 then begin MoveMonth:=True; end;
               else if Day > 31 then begin MoveMonth:=True; end;
            end;
            if MoveMonth then
            begin
               SystemTime.wMonth:=SystemTime.wMonth+1;
               CurrentDay:=1;
               if SystemTime.wMonth > 12 then
               begin
                  SystemTime.wMonth:=1;
                  SystemTime.wYear:=SystemTime.wYear+1;
               end;
            end;
         end;
         SystemTime.wDay:=CurrentDay;
         SetSystemTime(SystemTime);
         RemoteControl.Execute(EOD.Text);
         RemoteControl.Execute('Complete');
      end;
      Inc(Day);

   end;
   if (NumbDays > 1) and RD.Checked then
   begin
      GetSystemTime(SystemTime);
      StartSystemTime.wHour        :=SystemTime.wHour;
      StartSystemTime.wMinute      :=SystemTime.wMinute;
      StartSystemTime.wSecond      :=SystemTime.wSecond;
      StartSystemTime.wMilliseconds:=SystemTime.wMilliseconds;
      SetSystemTime(StartSystemTime);
   end;
   if Application.Terminated then RemoteControl:=nil;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
   I:Integer;
   S:String;
begin
   if Trim(ExecMemo.Text) <> '' then
   begin
      for I:=0 to ExecMemo.Lines.Count-1 do
      begin
         if Trim(ExecMemo.Lines[I]) <> '' then
         begin
            WinExecAndWait(Trim(ExecMemo.Lines[I]),S,False);
         end;

      end;
   end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   CustomerSessions:=0;
end;

end.
