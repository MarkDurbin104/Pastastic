unit BuildProgFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,GPCSRegistry,WinExecU, ExtCtrls,PackStrListU;

type
  TBuildLine = class(TObject)
    FFile:String;
    FLine:Integer;
    FError:String;
  public
     constructor Create(Path,ErrorLine:String);
  end;
  TBuildProg = class(TForm)
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1DblClick(Sender: TObject);
  private
    procedure BuildFiles;
  public
    CompType:String;
    Group   :String;
    Comps   :TPackStringList;
  end;

var
  BuildProg: TBuildProg;

implementation

uses CompOptionsFU, SourceFormFU;

{$R *.DFM}

constructor TBuildLine.Create(Path,ErrorLine:String);
var
   I,J:Integer;
begin
   inherited Create;
   FError:=ErrorLine;
   J:=1;
   for I:=1 to Length(ErrorLine) do
   begin
      if ErrorLine[I] = '(' then
      begin
         FFile:=Path+'\'+Copy(ErrorLine,J,I-1);
         J:=I+1;
      end
      else if ErrorLine[I] = ')' then
      begin
         FLine:=StrToIntDef(Copy(ErrorLine,J,I-J),0);
         FError:=Copy(ErrorLine,I+9,Length(ErrorLine));
         break;
      end
   end;        
end;
procedure TBuildProg.BuildFiles;
var
   S:String;
   CurrDir:String;
   Component:String;
   RegEntry:TGPCSRegistryEntry;
   ESL:TPackStringList;
   Errors,I,J:Integer;
   BuildLine:TBuildLine;
begin
   ListBox1.Clear;
   Errors:=0;
   for I:=0 to Comps.Count-1 do
   begin
      if ModalResult = mrCancel then Break;
      if CompType = '' then
      begin
         Component:=Comps[I];
         case Component[1] of
            'P' : CompType:='Product';
            'G' : CompType:='Group';
            'L' : CompType:='LookUp';
            'K' : CompType:='PickList';
            'W' : CompType:='WGroup';
            'U' : CompType:='UGroup';
            'S' : CompType:='Service';
         end;
         ListBox1.Items.Add('Building :- '+CompOptions.OutPASDir.Text+'\'+CompType+'\'+Component+'.dpr');
      
         CompOptions.BuildDCC32CFGFiles(CompType,Group);
   
         GetDir(0,CurrDir);
         ChDir(CompOptions.OutPASDir.Text+'\'+CompType);
         WinExecAndWait(CompOptions.CommandLine.Text+' '+Component,S,False);
         ChDir(CurrDir);
   
         ESL:=TPackStringList.Create;
         ESL.Text:=S;
         for J:=0 to ESL.Count-1 do
         begin
            if StrScan(PChar(Copy(ESL[J],3,Length(ESL[J]))),':') <> nil then
            begin
               Inc(Errors);
               BuildLine:=TBuildLine.Create(CompOptions.OutPASDir.Text+'\'+CompType,ESL[J]);
               ListBox1.Items.AddObject(ESL[J],BuildLine);
            end;
         end;
         ESL.Free;
         CompType:='';
      end
      else
      begin
         RegEntry:=TGPCSRegistryEntry(Comps.Objects[I]);
         if CompType = 'PickList' then 
            Component:='K_' 
         else 
            Component:=CompType[1]+'_';
      
         Component:=Component+RegEntry.Name+'_'+RegEntry.Version;

         ListBox1.Items.Add('Building :- '+CompOptions.OutPASDir.Text+'\'+CompType+'\'+Group+'\'+Component+'.dpr');
      
         CompOptions.BuildDCC32CFGFiles(CompType,Group);
   
         GetDir(0,CurrDir);
         ChDir(CompOptions.OutPASDir.Text+'\'+CompType+'\'+Group);
         WinExecAndWait(CompOptions.CommandLine.Text+' '+Component,S,False);
         ChDir(CurrDir);
   
         ESL:=TPackStringList.Create;
         ESL.Text:=S;
         for J:=0 to ESL.Count-1 do
         begin
            if StrScan(PChar(Copy(ESL[J],3,Length(ESL[J]))),':') <> nil then
            begin
               Inc(Errors);
               BuildLine:=TBuildLine.Create(CompOptions.OutPASDir.Text+'\'+CompType+'\'+Group,ESL[J]);
               ListBox1.Items.AddObject(ESL[J],BuildLine);
            end;
         end;
         ESL.Free;
      end;
   end;
   if Errors < 1 then
      ListBox1.Items.Add('Build Complete - No Errors')
   else if Errors < 2 then
      ListBox1.Items.Add('Build Complete - 1 Error')
   else
      ListBox1.Items.Add('Build Complete - '+IntToStr(Errors)+' Errors');
   ListBox1.ItemIndex:=ListBox1.Items.Count-1;
   Comps.Clear;
end;

procedure TBuildProg.FormShow(Sender: TObject);
begin
   Timer1.Enabled:=True;
end;

procedure TBuildProg.FormCreate(Sender: TObject);
begin
   Comps:=TPackStringList.Create;
end;

procedure TBuildProg.FormDestroy(Sender: TObject);
begin
   Comps.Free;
end;

procedure TBuildProg.Timer1Timer(Sender: TObject);
begin
   Timer1.Enabled:=False;
   BuildFiles;
end;

procedure TBuildProg.Button1Click(Sender: TObject);
begin
   ListBox1.Clear;
end;

procedure TBuildProg.Button2Click(Sender: TObject);
begin
   ListBox1.Clear;
end;

procedure TBuildProg.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  FC:TColor;
begin
   with ListBox1.Canvas do
   begin
      FillRect(Rect);
      FC:=Font.Color;
      if Copy(ListBox1.Items[Index],1,5) <> 'Build' then
         Font.Color:=clRed;
      TextOut(Rect.Left+2,Rect.Top,ListBox1.Items[Index]);
      Font.Color:=FC;
   end; 
end;

procedure TBuildProg.ListBox1DblClick(Sender: TObject);
var
   BuildLine:TBuildLine;
begin
   if Copy(ListBox1.Items[ListBox1.ItemIndex],1,5) <> 'Build' then
   begin
      BuildLine:=TBuildLine(ListBox1.Items.Objects[ListBox1.ItemIndex]);
      if BuildLine <> nil then
      begin
         if BuildLine.FFile <> '' then
         begin
            SourceForm.Memo1.Lines.LoadFromFile(BuildLine.FFile);
            SourceForm.LineNo:=BuildLine.FLine;
            SourceForm.Caption:=BuildLine.FError;
            SourceForm.ShowModal;
            if (SourceForm.ModalResult = mrOK) and (SourceForm.Memo1.Modified) then
               SourceForm.Memo1.Lines.SaveToFile(BuildLine.FFile);
         end
         else
            ShowMessage('Error: '+BuildLine.FError);
      end;
   end;              
end;

end.
