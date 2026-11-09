unit AccountsFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Db, Grids, DBGrids, DBTables,AccountList;

type
  TAccountsForm = class(TForm)
    AV: TTable;
    AVAGOffice: TIntegerField;
    AVAGWorkStation: TIntegerField;
    AVAGUser: TStringField;
    AVAGPeriod: TIntegerField;
    AVAGName: TStringField;
    AVAGValue: TCurrencyField;
    AVAGQuantity: TIntegerField;
    AVGrid: TDBGrid;
    AVDS: TDataSource;
    PickLB: TListBox;
    ReportsToLB: TListBox;
    IncreasesLB: TListBox;
    DecreasesLB: TListBox;
    DragLB: TListBox;
    Panel1: TPanel;
    ApplyUpdate: TButton;
    Label1: TLabel;
    NewValue: TEdit;
    Label2: TLabel;
    NewQuantity: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    NewAccount: TEdit;
    Save: TButton;
    ViewTable: TButton;
    procedure NewAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure PickLBClick(Sender: TObject);
    procedure ReportsToLBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ReportsToLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ApplyUpdateClick(Sender: TObject);
    procedure ViewTableClick(Sender: TObject);
    procedure PickLBDblClick(Sender: TObject);
  private
     FWorkstation:Integer;
     FOffice     :Integer;
     FPeriod     :Integer;
     FUser       :String;
    AccountItemList:TAccountItemList;
  public
    function CommaTextOfAccount(Office,WorkStation,Period:Integer;User,Name:String):String;
    function ShouldPop(Office,WorkStation,Period:Integer;User,Name:String;Value:Currency;Quantity:Integer;IncludeTop:Boolean):Boolean;
    procedure ApplyUpdates(Office,WorkStation,Period:Integer;User,Name:String;Value:Currency;Quantity:Integer);
    procedure LogItem(Office,WorkStation,Period:Integer;User,Name:String;Value:Currency;Quantity:Integer;IncludeTop:Boolean);
  end;

var
  AccountsForm: TAccountsForm;

implementation
uses
   ComServ2;
{$R *.DFM}

procedure TAccountsForm.NewAccountKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 13 then
   begin
      AccountItemList.AddLine(NewAccount.Text);
      if PickLB.Items.IndexOf(NewAccount.Text) = -1 then
         PickLB.Items.Add(NewAccount.Text);
      if DragLB.Items.IndexOf(NewAccount.Text) = -1 then
         DragLB.Items.Add(NewAccount.Text);
   end;
end;

procedure TAccountsForm.FormCreate(Sender: TObject);
begin
   AccountItemList:=TAccountItemList.Create;
   AccountItemList.LoadFromFile('C:\Accounts.txt');
   PickLB.Items.CommaText:=AccountItemList.Items.CommaText;
   DragLB.Items.CommaText:=AccountItemList.Items.CommaText;
   FWorkstation:=99;
   FOffice     :=9999;
   FPeriod     :=99999;
   FUser       :='Mark';
end;

procedure TAccountsForm.FormDestroy(Sender: TObject);
begin
   AccountItemList.Free;
end;

procedure TAccountsForm.SaveClick(Sender: TObject);
begin
   AccountItemList.SaveToFile('C:\Accounts.txt');
end;

procedure TAccountsForm.PickLBClick(Sender: TObject);
var
   R,D,I:String;
   Name:String;
begin
   if PickLB.ItemIndex > 0 then
   begin
      Name:=PickLB.Items[PickLB.ItemIndex];
      AccountItemList.GetUpDateLinesFor(Name,R,D,I);
      ReportsToLB.Items.CommaText:=R;
      DecreasesLB.Items.CommaText:=D;
      IncreasesLB.Items.CommaText:=I;
   end;
end;

procedure TAccountsForm.ReportsToLBDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept:=True;
  if (Source <> DragLB) or (PickLB.ItemIndex < 0) then Accept:=False;
end;

procedure TAccountsForm.ReportsToLBDragDrop(Sender, Source: TObject; X,Y: Integer);
var
   I:Integer;
   DestLB:TListBox;
begin
  if (Source <> DragLB) or (PickLB.ItemIndex < 0) or (DragLB.SelCount <= 0) then 
     Exit;
  DestLB:=(Sender as TListBox);
  for I:=0 to DragLB.Items.Count-1 do
  begin
     if DragLB.Selected[I] then
     begin
        if DestLB = ReportsToLB then
           AccountItemList.AddReportsToLine(PickLB.Items[PickLB.ItemIndex],DragLB.Items[I])
        else if DestLB = DecreasesLB then
           AccountItemList.AddDecreasesLine(PickLB.Items[PickLB.ItemIndex],DragLB.Items[I])
        else if DestLB = IncreasesLB then
           AccountItemList.AddIncreasesLine(PickLB.Items[PickLB.ItemIndex],DragLB.Items[I]);
        DestLB.Items.Add(DragLB.Items[I]);
     end;
  end;
end;

procedure TAccountsForm.ApplyUpdates(Office,WorkStation,Period:Integer;User,Name:String;Value:Currency;Quantity:Integer);
var
   CurState:Boolean;
begin
   CurState:=AV.Active;
   if not CurState then AV.Active:=True;
   AV.SetKey;
   AVAGOffice     .Value:=Office;
   AVAGWorkStation.Value:=WorkStation;
   AVAGUser       .Value:=User;
   AVAGPeriod     .Value:=Period;
   AVAGName       .Value:=Name;
   if AV.GotoKey then
   begin
      AV.Edit;
      AVAGOffice     .Value:=Office;
      AVAGWorkStation.Value:=WorkStation;
      AVAGUser       .Value:=User;
      AVAGPeriod     .Value:=Period;
      AVAGName       .Value:=Name;
      AVAGValue      .Value:=AVAGValue   .Value+Value;
      AVAGQuantity   .Value:=AVAGQuantity.Value+Quantity;
      AV.Post;
   end
   else
   begin
      AV.Append;
      AVAGOffice     .Value:=Office;
      AVAGWorkStation.Value:=WorkStation;
      AVAGUser       .Value:=User;
      AVAGPeriod     .Value:=Period;
      AVAGName       .Value:=Name;
      AVAGValue      .Value:=Value;
      AVAGQuantity   .Value:=Quantity;
      AV.Post;
   end;    
   if not CurState then AV.Active:=False;
end;
function TAccountsForm.ShouldPop(Office,WorkStation,Period:Integer;User,Name:String;Value:Currency;Quantity:Integer;IncludeTop:Boolean):Boolean;
var
   R,D,I:String;
begin
   Result:=False;
   AccountItemList.GetUpDateLinesFor(Name,R,D,I);
   if (R = '') and (D = '') and (I = '') then
   begin
      NewAccount.Text:=Name;
      NewValue.Text:=CurrToStr(Value   );
      NewQuantity.Text:=IntToStr (Quantity);
      FWorkstation:=Workstation;
      FOffice     :=Office     ;
      FPeriod     :=Period     ;
      FUser       :=User       ;
      AccountItemList.AddLine(NewAccount.Text);
      if PickLB.Items.IndexOf(NewAccount.Text) = -1 then
         PickLB.ItemIndex:=PickLB.Items.Add(NewAccount.Text);
      if DragLB.Items.IndexOf(NewAccount.Text) = -1 then
         DragLB.Items.Add(NewAccount.Text);
//      ApplyUpdateClick(ApplyUpdate);
      Result:=True;
   end;                     
end;
procedure TAccountsForm.LogItem(Office,WorkStation,Period:Integer;User,Name:String;Value:Currency;Quantity:Integer;IncludeTop:Boolean);
var
   R,D,I:String;
   Index:Integer;
   DecreasesSL:TStringList;
   IncreasesSL:TStringList;
begin
   AccountItemList.GetUpDateLinesFor(Name,R,D,I);
   DecreasesSL:=TStringList.Create;
   IncreasesSL:=TStringList.Create;
   DecreasesSL.CommaText:=D;
   IncreasesSL.CommaText:=I;
   if IncludeTop then ApplyUpdates(Office,Workstation,Period,User,Name,Value,Quantity);
   for Index:=0 to IncreasesSL.Count-1 do
   begin
      ApplyUpdates(Office,Workstation,Period,User,IncreasesSL[Index],Value,Quantity);
      LogItem(Office,WorkStation,Period,User,IncreasesSL[Index],Value,Quantity,False);
   end;
   for Index:=0 to DecreasesSL.Count-1 do
   begin
      ApplyUpdates(Office,Workstation,Period,User,DecreasesSL[Index],0-Value,0-Quantity);
      LogItem(Office,WorkStation,Period,User,DecreasesSL[Index],0-Value,0-Quantity,False);
   end;
end;

procedure TAccountsForm.ApplyUpdateClick(Sender: TObject);
var
   Name:String;
   Value   :Currency;
   Quantity:Integer;
begin
   if PickLB.ItemIndex < 0 then Exit;
   Name:=PickLB.Items[PickLB.ItemIndex];
   Value   :=StrToIntDef(NewValue.Text,0);
   Quantity:=StrToIntDef(NewQuantity.Text,0);
   LogItem(FOffice,FWorkstation,FPeriod,FUser,Name,Value,Quantity,True);
   if ComServer.StartMode <> smStandalone then Visible:=True;
end;

procedure TAccountsForm.ViewTableClick(Sender: TObject);
begin
   AV.Active:=not AV.Active;
   if AV.Active then
      ViewTable.Caption:='Hide Table'
   else
      ViewTable.Caption:='View Table';
end;
function TAccountsForm.CommaTextOfAccount(Office,WorkStation,Period:Integer;User,Name:String):String;
var
   SL:TStringList;
   ResSL:TStringList;
   I:Integer;
   CurState:Boolean;
begin
   SL:=TStringList.Create;
   SL.CommaText:=AccountItemList.GetAllThatAdjust(Name);
   ResSL:=TStringList.Create;
   CurState:=AV.Active;
   if not CurState then AV.Active:=True;
   for I:=0 to SL.Count-1 do
   begin
      AV.SetKey;
      AVAGOffice     .Value:=Office;
      AVAGWorkStation.Value:=WorkStation;
      AVAGUser       .Value:=User;
      AVAGPeriod     .Value:=Period;
      AVAGName       .Value:=SL[I];        
      if AV.GotoKey then
         ResSL.Add('"'+SL[I]+'","'+AVAGValue.AsString+'","'+AVAGQuantity.AsString+'"')
      else
         ResSL.Add('"'+SL[I]+'","0","0"');
   end;
   if not CurState then AV.Active:=False;
   Result:=ResSL.CommaText;
   SL.Free;
   ResSL.Free;
end;
procedure TAccountsForm.PickLBDblClick(Sender: TObject);
var
   Name:String;
begin
   if PickLB.ItemIndex < 0 then Exit;
   Name:=PickLB.Items[PickLB.ItemIndex];
   DragLB.Items.CommaText:=AccountItemList.GetAllThatAdjust(Name);
end;

end.
