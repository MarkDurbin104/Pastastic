unit NewAccountsFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, Grids, StdCtrls, Db, DBTables, DBGrids,ComServ2,GPCSGUID,GPCSErrorLine;

type
   TRefLink = class (TObject)
      FGrid:TStringGrid;              
      FCol :Integer;
      FRow :Integer;
   public
      constructor Create(Grid:TStringGrid;Col,Row:Integer);
      property Grid:TStringGrid read FGrid write FGrid;
      property Col :Integer     read FCol  write FCol ;
      property Row :Integer     read FRow  write FRow ;
   end;
   TAccountsForm = class(TForm)
    AccountPC: TPageControl;
    Receipts: TTabSheet;
    Payments: TTabSheet;
    Stock: TTabSheet;
    StockSG: TStringGrid;
    Panel2: TPanel;
    StockAddLine: TButton;
    Panel1: TPanel;
    PayAddLine: TButton;
    Panel3: TPanel;
    RecAddLine: TButton;
    PaymentsSG: TStringGrid;
    ReceiptsSG: TStringGrid;
    ItemPanel: TPanel;
    Splitter1: TSplitter;
    Panel5: TPanel;
    Label1: TLabel;
    GroupItems: TListBox;
    Panel6: TPanel;
    Panel7: TPanel;
    Button1: TButton;
    AllItems: TListBox;
    Edit1: TEdit;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit2: TEdit;
    Edit3: TEdit;
    AV: TTable;
    AVAGUser: TStringField;
    AVAGPeriod: TIntegerField;
    AVAGName: TStringField;
    AVAGValue: TCurrencyField;
    AVAGQuantity: TIntegerField;
    Button5: TButton;
    Query1: TQuery;
    Query1AGUser: TStringField;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    AU: TTable;
    AUUser: TStringField;
    AUCurrentPeriod: TIntegerField;
    AULastPeriod: TIntegerField;
    AUOpeningCash: TCurrencyField;
    AUOpeningStock: TCurrencyField;
    AUClosingCash: TCurrencyField;
    AUClosingStock: TCurrencyField;
    AULoggedOn: TSmallintField;
    TabSheet1: TTabSheet;
    Table1: TTable;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Table1AGUser: TStringField;
    Table1AGPeriod: TIntegerField;
    Table1AGName: TStringField;
    Table1AGValue: TCurrencyField;
    Table1AGQuantity: TIntegerField;
    TabSheet2: TTabSheet;
    Table2: TTable;
    DataSource2: TDataSource;
    DBGrid2: TDBGrid;
    Table2User: TStringField;
    Table2CurrentPeriod: TIntegerField;
    Table2LastPeriod: TIntegerField;
    Table2LoggedOn: TSmallintField;
    Table2OpeningCash: TCurrencyField;
    Table2OpeningStock: TCurrencyField;
    Table2ClosingCash: TCurrencyField;
    Table2ClosingStock: TCurrencyField;
    Button6: TButton;
    TabSheet3: TTabSheet;
    Table3: TTable;
    DataSource3: TDataSource;
    DBGrid3: TDBGrid;
    Table4: TTable;
    Table4PName: TStringField;
    Table4PPrice: TCurrencyField;
    Table4PAType: TStringField;
    Table4PReportsTo: TStringField;
    PSLDatabase: TDatabase;
    procedure FormCreate(Sender: TObject);
    procedure StockSGDrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StockSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure RecAddLineClick(Sender: TObject);
    procedure PaymentsSGDblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure GroupItemsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure GroupItemsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Button2Click(Sender: TObject);
    procedure AllItemsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure AllItemsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
//    procedure DataGRxDataGram(Sender: TDGramSocket; From, Data: String);
    procedure FormDestroy(Sender: TObject);
  private
    AllLists:TList;
    ItemList:TStringList;
    FModified:Boolean;
    ItemSelected:String;
    SelectedList:TStringList;
    procedure SetGridData(Grid:TStringGrid;Data,Titles:String);
    function GetGridData(Grid:TStringGrid):String;
    function GridCell(Name:String):TStringList;
    procedure AttachAccountGroup(Group:String);
    procedure AssignLinks(Grid:TStringGrid);
    function GetReportsToSS(Name:String):String;
    function GetReportsToRR(Name:String):String;
    function GetReportsToRD(Name:String):String;
    function GetReportsTo  (Name:String):String;
//    function TotalUsersStock(ExceptUser:String;Period:Integer):Currency;
    function GetUsers:String;
    procedure UpdateItem(Data,User,Name:String;Value:Currency;Quantity,Period:Integer);
    procedure UpdateLine(User,Name:String;Value:Currency;Quantity,Period:Integer);
    procedure FillFromGrid(Add:Boolean;var Index:Integer;Period:Integer;User:String;Grid:TStringGrid;
                      var NameList,ValueList,QuantityList:TStringList; var Total:Currency);
//    procedure SendAVDG;
//    procedure SendAUDG;
  public
    function  CommaText(Name,User,Periods:String):String;
    function  LogItem(User,Name:String;Value:Currency;Quantity,Period:Integer):Boolean;
    procedure LogReceipt(User,Name:String;Value:Currency;Quantity,Period:Integer);
    procedure LogDispatch(User,Name:String;Value:Currency;Quantity,Period:Integer);
    procedure EndOfDay(User:String;Period:Integer;var CashValue, StockValue: Currency);
    procedure StartOfDay(User:String;Period:Integer;var CashValue, StockValue: Currency);
    procedure LogStock(User,Name:String;Value:Currency;Quantity,Period:Integer);
    procedure TransferStock(UserFrom,UserTo,Name:String;Value:Currency;Quantity,Period:Integer);
    procedure ReturnStock(User,Name:String;Value:Currency;Quantity,Period:Integer);
    procedure ReceiveStock(User,Name:String;Value:Currency;Quantity,Period:Integer);
    procedure GetLineValue(User,Name:String;var Value:Currency;var Quantity,Period:Integer);
    function GetLastEndOfDay(User:String;var CashValue,StockValue:Currency):Integer;
    function HasPeriodStarted(User:String):Boolean;
  end;

var
  AccountsForm: TAccountsForm;

implementation

uses CommatextFU;

{$R *.DFM}
function StrToCurrDef(S:String;Default:Currency):Currency;
begin
   try
      Result:=StrToCurr(S);
   except
      Result:=Default;
   end;                    
end;
{TRefLink}
constructor TRefLink.Create(Grid:TStringGrid;Col,Row:Integer);
begin
   FGrid:=Grid;
   FCol :=Col ;
   FRow :=Row ;
end;
procedure SetGridWidth(Grid:TStringGrid);
var
  I,J:Integer;
  MaxWidth,ItemWidth:Integer;
begin
   for I:=0 to Grid.ColCount-1 do
   begin
      MaxWidth:=0;
      for J:=0 to Grid.RowCount-1 do
      begin
         ItemWidth:=Grid.Canvas.TextWidth(Grid.Cells[I,J]);
         if ItemWidth > MaxWidth then MaxWidth:=ItemWidth;
      end;
      Grid.ColWidths[I]:=MaxWidth+15;
   end;
end;
function TAccountsForm.HasPeriodStarted(User:String):Boolean;
begin
   Result:=False;
   AU.Active:=True;
   try
      AU.SetKey;
      AUUser.Value:=User;
      if (AU.GotoKey) and (AULoggedOn.Value = 1) then
          Result:=True;
   except
   end;
   AU.Active:=False;
end;
function TAccountsForm.GetLastEndOfDay(User:String;var CashValue,StockValue:Currency):Integer;
begin
   Result:=0;
   AU.Active:=True;
   try
      AU.SetKey;
      AUUser.Value:=User;
      if AU.GotoKey then
      begin
         CashValue :=AUClosingCash .Value;
         StockValue:=AUClosingStock.Value;
         Result:=AUCurrentPeriod.Value;
      end
      else
      begin
         CashValue :=0;
         StockValue:=0;
         Result:=0;
      end;
   except
   end;
end;
procedure TAccountsForm.EndOfDay(User:String;Period:Integer;var CashValue, StockValue: Currency);
begin
   AU.Active:=True;
   try
      AU.SetKey;
      AUUser.Value:=User;
      if AU.GotoKey then
      begin
         AU.Edit;
         AULastPeriod.Value:=Period;
         AUClosingCash.Value:=CashValue;
         AUClosingStock.Value:=StockValue;
         AUOpeningCash .Value:=0;
         AUOpeningStock.Value:=0;
         AULoggedOn.Value:=0;
//         SendAUDG;
         AU.Post;
      end;
   except
   end;
   AU.Active:=False;
end;
procedure TAccountsForm.StartOfDay(User:String;Period:Integer;var CashValue, StockValue: Currency);
var
  LPeriod:Integer;
  I,J,K:Integer;
  Value   :Currency;
  Quantity:Integer;
  SValue   :Currency;
  DValue   :Currency;
  RValue   :Currency;
  SQuantity:Integer;
  DQuantity:Integer;
  RQuantity:Integer;
  SL:TStringList;
begin
   AU.Active:=True;
   try
      AU.SetKey;
      AUUser.Value:=User;
      if AU.GotoKey then
      begin
         try
            AU.Edit;
            AUCurrentPeriod.Value:=Period;
            LPeriod:=AULastPeriod.Value;
            AUOpeningCash.Value :=CashValue ;
            AUOpeningStock.Value:=StockValue;
            AULoggedOn.Value:=1;
//            SendAUDG;
            AU.Post;
            for I:=1 to StockSG.RowCount-1 do
            begin
//               GetLineValue(User,StockSG.Item[0,I],Value,Quantity,LPeriod);
//               LogStock(User,StockSG.Item[0,I],Value,Quantity,Period);
               for J:=1 to StockSG.ColCount-1 do
               begin
                  if StockSG.Cells[J,I] <> 'Cash' then
                  begin
                     SL:=(StockSG.Objects[J,I] as TStringList);
                     if SL <> nil then
                     begin
                        for K:=0 to SL.Count-1 do
                        begin
                           GetLineValue(User,SL[K],Value,Quantity,LPeriod);
                           GetLineValue(User,'S'+SL[K],SValue,SQuantity,LPeriod);
                           GetLineValue(User,'D'+SL[K],DValue,DQuantity,LPeriod);
                           GetLineValue(User,'R'+SL[K],RValue,RQuantity,LPeriod);
                           if (((SValue+RValue)-(Value+DValue)) <> 0) 
                           or (((SQuantity+RQuantity)-(Quantity+DQuantity)) <> 0) then
                              LogStock(User,SL[K],(SValue+RValue)-(Value+DValue),(SQuantity+RQuantity)-(Quantity+DQuantity),Period);
                        end;
                     end; 
                  end
                  else
                  begin
                     if not AV.Active then AV.Active:=True;
                     AV.Append;
                     AVAGUser    .Value:=User;
                     AVAGPeriod  .Value:=Period;
                     AVAGName    .Value:=StockSG.Cells[0,I];
                     AVAGValue   .Value:=CashValue;
                     AVAGQuantity.Value:=1;
//                     SendAVDG;
                     AV.Post;
                  end;
               end;  
            end;    
            
            if not AV.Active then AV.Active:=True;
            AV.Append;
            AVAGUser    .Value:=User;
            AVAGPeriod  .Value:=Period;
            AVAGName    .Value:='Balance B/Fwd from line 80';
            AVAGValue   .Value:=CashValue+StockValue;
            AVAGQuantity.Value:=1; 
//            SendAVDG;
            AV.Post;
         except
         end;
         if AU.Active then AU.Active:=False;
         if AV.Active then AV.Active:=False;
      end
      else
      begin
         AU.Append;
         AUUser.Value:=User;
         AULastPeriod.Value:=0;
         AUCurrentPeriod.Value:=Period;
         AUOpeningCash.Value:=CashValue ;
         AUOpeningStock.Value:=StockValue;
         AUClosingCash.Value :=0;
         AUClosingStock.Value:=0;
         CashValue :=0;
         StockValue:=0;
//         SendAUDG;
         AU.Post;
      end;
   except
   end;
   if AU.Active then AU.Active:=False;
end;
function TAccountsForm.GridCell(Name:String):TStringList;
var
   I,J:Integer;
begin
   Result:=nil;
   if Name = 'All Items' then 
   begin
      Result:=ItemList;
      Exit;
   end;
   for I:=1 to StockSG.ColCount-1 do
   begin
      J:=StockSG.Cols[I].IndexOf(Name);
      if J <> -1 then
      begin
         Result:=(StockSG.Objects[I,J] as TStringList);
         if Result = nil then
         begin
            StockSG.Objects[I,J]:=TStringList.Create;
            Result:=(StockSG.Objects[I,J] as TStringList);
         end;
         Exit;
      end;
   end;  
   for I:=1 to PaymentsSG.ColCount-1 do
   begin
      J:=PaymentsSG.Cols[I].IndexOf(Name);
      if J <> -1 then
      begin
         Result:=(PaymentsSG.Objects[I,J] as TStringList);
         if Result = nil then
         begin
            PaymentsSG.Objects[I,J]:=TStringList.Create;
            Result:=(PaymentsSG.Objects[I,J] as TStringList);
         end;
         Exit;
      end;
   end;  
   for I:=1 to ReceiptsSG.ColCount-1 do
   begin
      J:=ReceiptsSG.Cols[I].IndexOf(Name);
      if J <> -1 then
      begin
         Result:=(ReceiptsSG.Objects[I,J] as TStringList);
         if Result = nil then
         begin
            ReceiptsSG.Objects[I,J]:=TStringList.Create;
            Result:=(ReceiptsSG.Objects[I,J] as TStringList);
         end;
         Exit;
      end;
   end;  
end;
procedure TAccountsForm.AttachAccountGroup(Group:String);
var
   GS:TStringList;
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   SL.CommaText:=Group;
   if SL.Count < 1 then Exit;
   GS:=GridCell(SL[0]);
   if GS <> nil then
      for I:=1 to SL.Count-1 do GS.Add(SL[I]);
   SL.Free;
end;
procedure TAccountsForm.FormCreate(Sender: TObject);
var
   SL:TStringList;
   I:Integer;
   Titles:String;
begin
//   DataG.Active:=True;
   PSLDataBase.Params.Add('USER NAME=' + GetGPCSRegString('','UserName','psl'));
   PSLDataBase.Params.Add('PASSWORD='  + GetGPCSRegString('','Password','suvroc'));
   ItemList:=TStringList.Create;
   AllLists:=TList.Create;
   if ComServer.StartMode = smStandAlone then
   begin
      Table1.Active:=True;
      Table2.Active:=True;
      Table3.Active:=True; 
   end;
   
   SL:=TStringList.Create;
   if FileExists(ApplicationRootPath+'Accounts2.txt') then
      SL.LoadFromFile(ApplicationRootPath+'Accounts2.txt');
//   SL.LoadFromFile('C:\Tan\Accounts2.txt'); // Tanzania
   if SL.Count > 0 then
   begin
      SetGridData(StockSG,SL[0],''); // Line 0 = Stock;
      Titles:=StockSG.Rows[0].CommaText;
      if SL.Count > 1 then SetGridData(ReceiptsSG,SL[1],Titles); // Line 1 = Receipts;
      if SL.Count > 2 then SetGridData(PaymentsSG,SL[2],Titles); // Line 0 = Payments;
      for I:=3 to SL.Count-1 do AttachAccountGroup(SL[I]);
   end;
   SL.Free;
   AllLists.Clear;
   AssignLinks(StockSG);
   AssignLinks(ReceiptsSG);
   AssignLinks(PaymentsSG);
end;

procedure TAccountsForm.StockSGDrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
begin
   with (Sender as TStringGrid).Canvas do
   begin
      Brush.Color:=clWindow;  
      Font.Color:=clBlack;
      if gdSelected in State then begin Brush.Color:=clNavy;    Font.Color:=clWhite; end;
      if (gdFixed in State) or (Col = 0) then begin Brush.Color:=clBtnFace; Font.Color:=clBlack; end;
      if Col = 0 then 
         with Rect do Rectangle(Left-1,Top-1,Right+1,Bottom+1)
      else
         FillRect(Rect);
      TextOut(Rect.Left+2,Rect.Top+2,(Sender as TStringGrid).Cells[Col,Row]);
      if gdFocused in State then DrawFocusRect(Rect);
      if Sender = StockSG then
      begin
         if (Col <> 0) and (Row = 0) then
         begin
            Brush.Color:=clGreen;
            Pen.Color:=clGreen;
            PolyGon([Point(Rect.Right-3,Rect.Top+12),Point(Rect.Right-9,Rect.Top+12),Point(Rect.Right-6,Rect.Top+4),Point(Rect.Right-3,Rect.Top+12)]);
         end
         else if (Col = 0) and (Row <> 0) then
         begin
            Brush.Color:=clRed;
            Pen.Color:=clRed;
            PolyGon([Point(Rect.Right-3,Rect.Top+4),Point(Rect.Right-9,Rect.Top+4),Point(Rect.Right-6,Rect.Top+12),Point(Rect.Right-3,Rect.Top+4)]);
         end; 
      end
      else if Sender = ReceiptsSG then
      begin
         if (Col = 0) xor (Row = 0) then
         begin
            Brush.Color:=clGreen;
            Pen.Color:=clGreen;
            PolyGon([Point(Rect.Right-3,Rect.Top+12),Point(Rect.Right-9,Rect.Top+12),Point(Rect.Right-6,Rect.Top+4),Point(Rect.Right-3,Rect.Top+12)]);
         end;
      end
      else
      begin
         if (Col <> 0) and (Row = 0) then
         begin
            Brush.Color:=clRed;
            Pen.Color:=clRed;
            PolyGon([Point(Rect.Right-3,Rect.Top+4),Point(Rect.Right-9,Rect.Top+4),Point(Rect.Right-6,Rect.Top+12),Point(Rect.Right-3,Rect.Top+4)]);
         end
         else if (Col = 0) and (Row <> 0) then
         begin
            Brush.Color:=clGreen;
            Pen.Color:=clGreen;
            PolyGon([Point(Rect.Right-3,Rect.Top+12),Point(Rect.Right-9,Rect.Top+12),Point(Rect.Right-6,Rect.Top+4),Point(Rect.Right-3,Rect.Top+12)]);
         end; 
      end;
      Pen.Color:=clBlack;
   end; 
end;
procedure TAccountsForm.SetGridData(Grid:TStringGrid;Data,Titles:String);
var
   I:Integer;
   SL:TStringList;
   LSL:TStringList;
   TitleSL:TStringList;
   J:Integer;
begin
   TitleSL:=TStringList.Create;
   SL:=TStringList.Create;
   LSL:=TStringList.Create;
   SL.CommaText:=Data;
   TitleSL.CommaText:=Titles;
   Grid.RowCount:=SL.Count+1;
   if Titles = '' then
      Grid.ColCount:=SL.Count+1
   else
      Grid.ColCount:=TitleSL.Count;
   for I:=1 to SL.Count do
   begin
      LSL.CommaText:=SL[I-1];
      J:=0;
      while J < LSL.Count do
      begin
         Grid.Cells[StrToIntDef(LSL[J],1),I]:=LSL[J+1];
         Inc(J,2);
      end;
   end;
   if Titles = '' then
      for I:=1 to SL.Count do Grid.Cells[I,0]:=Grid.Cells[0,I]
   else
      for I:=1 to TitleSL.Count-1 do Grid.Cells[I,0]:=TitleSL[I];
   SL.Free;
   LSL.Free;  
   TitleSL.Free;
   SetGridWidth(Grid);
end;
function TAccountsForm.GetGridData(Grid:TStringGrid):String;
var
   SL:TStringList;
   LSL:TStringList;
   I,J:Integer;
begin
   Result:='';
   SL:=TStringList.Create;
   LSL:=TStringList.Create;
   for I:=1 to Grid.RowCount-1 do
   begin
      LSL.Clear;
      for J:=0 to Grid.ColCount-1 do
      begin
         if Trim(Grid.Cells[J,I]) <> '' then
         begin
            LSL.Add(IntToStr(J));
            LSL.Add(Trim(Grid.Cells[J,I]));
         end;
      end;
      SL.Add(LSL.CommaText);
   end;
   LSL.Free;
   Result:=SL.CommaText;
   SL.Free;
end;
procedure GetGroupsFrom(Grid:TStringGrid;Into:TStringList);
var
   I,J:Integer;
begin
   for I:=0 to Grid.ColCount-1 do
      for J:=0 to Grid.RowCount-1 do
         if (Grid.Objects[I,J] <> nil) and (TStringList(Grid.Objects[I,J]).Count > 0) then
            Into.Add('"'+Grid.Cells[I,J]+'",'+TStringList(Grid.Objects[I,J]).CommaText);
end;
procedure TAccountsForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
   SL:TStringList;
   Res:Integer;
begin
   if Not FModified then Exit;
   Res:=MessageDlg('The accounts have been modified. Do you want to save the changes ?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
   if Res = mrYes then
   begin
      SL:=TStringList.Create;
      SL.Add(GetGridData(StockSG   ));
      SL.Add(GetGridData(ReceiptsSG));
      SL.Add(GetGridData(PaymentsSG));
      GetGroupsFrom(StockSG   ,SL);
      GetGroupsFrom(ReceiptsSG,SL);
      GetGroupsFrom(PaymentsSG,SL);
      SL.Add('"All Items",'+ItemList.CommaText);
      SL.SaveToFile(ApplicationRootPath+'Accounts2.txt');
//      SL.SaveToFile('C:\Tan\Accounts2.txt'); // Tanzania
      SL.Free;
   end
   else if Res = mrCancel then
   begin
      Action:=caNone;
   end;
end;  

procedure TAccountsForm.StockSGSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: String);
var
   SG:TStringGrid;
begin
   SG:=(Sender as TStringGrid);
   FModified:=True;
   if ACol = 0 then 
   begin
      SG.Invalidate;
      if SG = StockSG then
      begin
         StockSG   .Cells[ARow,ACol]:=SG.Cells[ACol,ARow]; 
         SetGridWidth(StockSG   );
         PaymentsSG.Cells[ARow,ACol]:=SG.Cells[ACol,ARow]; 
         SetGridWidth(PaymentsSG);
         ReceiptsSG.Cells[ARow,ACol]:=SG.Cells[ACol,ARow]; 
         SetGridWidth(ReceiptsSG);
      end
      else
        SetGridWidth(SG);
   end;
end;

procedure TAccountsForm.RecAddLineClick(Sender: TObject);
var
   SG:TStringGrid;
begin
   if Sender = RecAddLine then
      SG:=ReceiptsSG
   else if Sender = PayAddLine then
      SG:=PaymentsSG
   else
      SG:=StockSG;
      
   SG.RowCount:=SG.RowCount+1;
   if SG = StockSG then
   begin
      StockSG.ColCount   :=SG.ColCount+1;
      PaymentsSG.ColCount:=StockSG.ColCount;
      ReceiptsSG.ColCount:=StockSG.ColCount;
   end;
end;                   

procedure TAccountsForm.PaymentsSGDblClick(Sender: TObject);
var
   SGSelected:TStringGrid;
begin                        
   SGSelected:=(Sender as TStringGrid);
   if SGSelected = StockSG then
      ItemSelected:='Stock.'+SGSelected.Cells[SGSelected.Selection.Left,SGSelected.Selection.Top]
   else if SGSelected = PaymentsSG then
      ItemSelected:='Payments.'+SGSelected.Cells[SGSelected.Selection.Left,SGSelected.Selection.Top]
   else
      ItemSelected:='Receipts.'+SGSelected.Cells[SGSelected.Selection.Left,SGSelected.Selection.Top];
   if SGSelected.Objects[SGSelected.Selection.Left,SGSelected.Selection.Top] <> nil then
   begin
      SelectedList:=(SGSelected.Objects[SGSelected.Selection.Left,SGSelected.Selection.Top] as TStringList);
      GroupItems.Items.Assign(SelectedList);
   end
   else
   begin
      SelectedList:=TStringList.Create;
      SGSelected.Objects[SGSelected.Selection.Left,SGSelected.Selection.Top]:=SelectedList;
      GroupItems.Items.Assign(SelectedList);
   end;
   
   Caption:=ItemSelected+' Account Group';
   AllItems.Items.Assign(ItemList);
   ItemPanel.Visible:=True;
   AccountPC.Visible:=False;
end;                

procedure TAccountsForm.Button1Click(Sender: TObject);
begin
   ItemPanel.Visible:=False;
   AccountPC.Visible:=True;
   Caption:='GPCS Accounts';
   if FModified then
   begin
      AllLists.Clear;
      AssignLinks(StockSG);
      AssignLinks(ReceiptsSG);
      AssignLinks(PaymentsSG);
   end;
end;

procedure TAccountsForm.GroupItemsDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   Accept:=(Source = AllItems);
end;

procedure TAccountsForm.GroupItemsDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
   I:Integer;
begin
   if Source = AllItems then
   begin
      for I:=0 to AllItems.Items.Count-1 do
         if AllItems.Selected[I] then GroupItems.Items.Add(AllItems.Items[I]);
      SelectedList.Assign(GroupItems.Items);
      FModified:=True;
   end;
end;

procedure TAccountsForm.Button2Click(Sender: TObject);
begin
   if ItemList.IndexOf(Edit1.Text) = -1 then
   begin
      AllItems.Items.Add(Edit1.Text);
      ItemList.Add(Edit1.Text);
      FModified:=True;
   end;
end;    

procedure TAccountsForm.AllItemsDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   Accept:=(Source = GroupItems);
end;

procedure TAccountsForm.AllItemsDragDrop(Sender, Source: TObject; X, Y: Integer);
var
   I:Integer;
begin
   if Source <> GroupItems then Exit;
   I:=0;
   while I < GroupItems.Items.Count do
      if GroupItems.Selected[I] then GroupItems.Items.Delete(I) else Inc(I);
   SelectedList.Assign(GroupItems.Items);
end;

procedure TAccountsForm.AssignLinks(Grid:TStringGrid);
var
   I,J,K:Integer;
   List:TStringList;
begin      
   for I:=0 to Grid.ColCount-1 do
   begin
      for J:=0 to Grid.RowCount-1 do
      begin
         List:=TStringList(Grid.Objects[I,J]);
         if (List <> nil) and (List.Count > 0) then
         begin
            for K:=0 to List.Count-1 do
               List.Objects[K]:=TRefLink.Create(Grid,I,J);
            AllLists.Add(List);
         end;
      end;
   end;
end;
procedure TAccountsForm.Button3Click(Sender: TObject);
var
   I,J,K:Integer;
   Grid:TStringGrid;
begin               
   for K:=0 to AllItems.Items.Count-1 do
   begin
      Grid:=StockSG;
      for I:=0 to Grid.ColCount-1 do
         for J:=0 to Grid.RowCount-1 do
            if (Grid.Objects[I,J] <> nil) and (TStringList(Grid.Objects[I,J]).Count > 0) then
               if TStringList(Grid.Objects[I,J]).IndexOf(AllItems.Items[K]) <> -1 then
                  AllItems.Selected[K]:=True;
      Grid:=PaymentsSG;
      for I:=0 to Grid.ColCount-1 do
         for J:=0 to Grid.RowCount-1 do
            if (Grid.Objects[I,J] <> nil) and (TStringList(Grid.Objects[I,J]).Count > 0) then
               if TStringList(Grid.Objects[I,J]).IndexOf(AllItems.Items[K]) <> -1 then
                  AllItems.Selected[K]:=True;
      Grid:=ReceiptsSG;
      for I:=0 to Grid.ColCount-1 do
         for J:=0 to Grid.RowCount-1 do
            if (Grid.Objects[I,J] <> nil) and (TStringList(Grid.Objects[I,J]).Count > 0) then
               if TStringList(Grid.Objects[I,J]).IndexOf(AllItems.Items[K]) <> -1 then
                  AllItems.Selected[K]:=True;
      AllItems.Selected[K]:=not AllItems.Selected[K];
   end;
end;
function TAccountsForm.GetReportsToRR(Name:String):String;
var
   I,J:Integer;
   SL:TStringList;
   RefLink:TRefLink;
   ResList:TStringList;
begin
   ResList:=TStringList.Create;
   ResList.Add('"+R'+Name+'"');
   for I:=0 to AllLists.Count-1 do
   begin
      SL:=TStringList(AllLists[I]);
      for J:=0 to SL.Count-1 do
      begin
         RefLink:=TRefLink(SL.Objects[J]);
         if (RefLink <> nil) 
         and (SL[J] = Name) 
         and (RefLink.Grid = ReceiptsSG) 
         and (Copy(RefLink.Grid.Cells[0,RefLink.Row],1,2) = 'RR') then
         begin
            ResList.Add('"+'+RefLink.Grid.Cells[RefLink.Col,RefLink.Row]+'","+'+RefLink.Grid.Cells[RefLink.Col,0]+'","+'+RefLink.Grid.Cells[0,RefLink.Row]+'"');
         end;
      end;
   end;
   Result:=ResList.CommaText;
   ResList.Free;
end;
function TAccountsForm.GetReportsToSS(Name:String):String;
var
   I,J:Integer;
   SL:TStringList;
   RefLink:TRefLink;
   ResList:TStringList;
begin
   ResList:=TStringList.Create;
   ResList.Add('"+S'+Name+'"');
   for I:=0 to AllLists.Count-1 do
   begin
      SL:=TStringList(AllLists[I]);
      for J:=0 to SL.Count-1 do
      begin
         RefLink:=TRefLink(SL.Objects[J]);
         if (RefLink <> nil) 
         and (SL[J] = Name) 
         and (RefLink.Grid = StockSG) then
         begin
            ResList.Add('"+'+RefLink.Grid.Cells[0,RefLink.Row]+'"');
         end;
      end;
   end;
   Result:=ResList.CommaText;
   ResList.Free;
end;
function TAccountsForm.GetReportsToRD(Name:String):String;
var
   I,J:Integer;
   SL:TStringList;
   RefLink:TRefLink;
   ResList:TStringList;
begin
   ResList:=TStringList.Create;
   ResList.Add('"+D'+Name+'"');
   for I:=0 to AllLists.Count-1 do
   begin
      SL:=TStringList(AllLists[I]);
      for J:=0 to SL.Count-1 do
      begin
         RefLink:=TRefLink(SL.Objects[J]);
         if (RefLink <> nil) 
         and (SL[J] = Name) 
         and (RefLink.Grid = PaymentsSG) 
         and (Copy(RefLink.Grid.Cells[0,RefLink.Row],1,2) = 'RD') then
         begin
            ResList.Add('"+'+RefLink.Grid.Cells[RefLink.Col,RefLink.Row]+'","-'+RefLink.Grid.Cells[RefLink.Col,0]+'","+'+RefLink.Grid.Cells[0,RefLink.Row]+'"');
         end;
      end;
   end;
   Result:=ResList.CommaText;
   ResList.Free;
end;
function TAccountsForm.GetReportsTo  (Name:String):String;
var
   I,J:Integer;
   SL:TStringList;
   RefLink:TRefLink;
   ResList:TStringList;
   Updates:String;
begin
   ResList:=TStringList.Create;
   ResList.Add('"+'+Name+'"');
   for I:=0 to AllLists.Count-1 do
   begin
      SL:=TStringList(AllLists[I]);
      for J:=0 to SL.Count-1 do
      begin
         RefLink:=TRefLink(SL.Objects[J]);
         if (RefLink <> nil) 
         and (SL[J] = Name) 
         and (Copy(RefLink.Grid.Cells[0,RefLink.Row],1,2) <> 'RD')
         and (Copy(RefLink.Grid.Cells[0,RefLink.Row],1,2) <> 'RR') then
         begin
            if RefLink.Grid = StockSG then
            begin
               Updates:='"+'+RefLink.Grid.Cells[RefLink.Col,0]+'","-'+RefLink.Grid.Cells[0,RefLink.Row]+'"';
            end
            else if RefLink.Grid = ReceiptsSG then
            begin
               Updates:='"+'+RefLink.Grid.Cells[RefLink.Col,0]+'","+'+RefLink.Grid.Cells[0,RefLink.Row]+'"';
            end
            else if RefLink.Grid = PaymentsSG then
            begin
               Updates:='"-'+RefLink.Grid.Cells[RefLink.Col,0]+'","+'+RefLink.Grid.Cells[0,RefLink.Row]+'"';
            end;
            ResList.Add('"+'+RefLink.Grid.Cells[RefLink.Col,RefLink.Row]+'",'+UpDates);
         end;
      end;
   end;
   Result:=ResList.CommaText;
   ResList.Free;
end;
procedure TAccountsForm.TransferStock(UserFrom,UserTo,Name:String;Value:Currency;Quantity,Period:Integer);
begin
    LogStock(UserFrom,Name,0-Value,0-Quantity,Period);
    LogStock(UserTo,Name,Value,Quantity,Period);
end; 
procedure TAccountsForm.ReturnStock(User,Name:String;Value:Currency;Quantity,Period:Integer);
begin
    LogDispatch(User,Name,Value,Quantity,Period);
end;
procedure TAccountsForm.ReceiveStock(User,Name:String;Value:Currency;Quantity,Period:Integer);
begin
    LogReceipt(User,Name,Value,Quantity,Period);
end; 
function TAccountsForm.GetUsers:String;
var
   UsersList:TStringList;
begin
   UsersList:=TStringList.Create;
   Query1.SQL.Text:='select AGUser from AccountValues group by AGUser';
   Query1.Active:=True;
   try 
      While not Query1.EOF do
      begin
         UsersList.Add(Query1AGUser.AsString);
         Query1.Next;
      end;
   except
   end;
   Query1.Active:=False;
   Result:=UsersList.CommaText;
   UsersList.Free;
end;
{function TAccountsForm.TotalUsersStock(ExceptUser:String;Period:Integer):Currency;
var
   I,J:Integer;
   UserList:TStringList;
begin
   UserList:=TStringList.Create;
   UserList.CommaText:=GetUsers;
   Result:=0;
   I:=UserList.IndexOf(ExceptUser);
   if I <> -1 then UserList.Delete(I);
   for J:=0 to UserList.Count-1 do
   begin
      for I:=1 to StockSG.RowCount-1 do
      begin
         AV.SetKey;       
         AVAGUser  .Value:=UserList[J];
         AVAGPeriod.Value:=Period;
         AVAGName  .Value:=StockSG.Cells[0,I];
         if AV.GotoKey then
            Result:=Result+AVAGValue.Value
      end;
   end;
   UserList.Free;
end;}
procedure TAccountsForm.Button4Click(Sender: TObject);
begin
   case Edit3.Text[1] of
      'R' : LogReceipt (Edit4.Text,Edit2.Text,10,1,1);
      'D' : LogDispatch(Edit4.Text,Edit2.Text,10,1,1);
      'S' : TransferStock(Edit4.Text,'Mark',Edit2.Text,10,1,1);
      else  LogItem    (Edit4.Text,Edit2.Text,10,1,1);
   end;
end;
procedure TAccountsForm.LogStock(User,Name:String;Value:Currency;Quantity,Period:Integer);
begin
   UpdateItem(GetReportsToSS(Name),User,Name,Value,Quantity,Period);
end;
function TAccountsForm.LogItem(User,Name:String;Value:Currency;Quantity,Period:Integer):Boolean;
var
   NameList:TStringList;
begin
   NameList:=TStringList.Create;
   NameList.CommaText:=GetReportsTo(Name);
   if NameList.Count > 1 then
      Result:=True
   else
      Result:=False;
   UpdateItem(NameList.CommaText,User,Name,Value,Quantity,Period);
   NameList.Free;
end;
procedure TAccountsForm.LogReceipt(User,Name:String;Value:Currency;Quantity,Period:Integer);
begin
   UpdateItem(GetReportsToRR(Name),User,Name,Value,Quantity,Period);
end;
procedure TAccountsForm.LogDispatch(User,Name:String;Value:Currency;Quantity,Period:Integer);
begin
   UpdateItem(GetReportsToRD(Name),User,Name,Value,Quantity,Period);
end;
procedure TAccountsForm.UpdateItem(Data,User,Name:String;Value:Currency;Quantity,Period:Integer);
var
   SL,ISL:TStringList;
   I,J:Integer;
begin
   SL:=TStringList.Create;
   ISL:=TStringList.Create;
   AV.Active:=True;
   try 
      SL.CommaText:=Data;
      if SL.Count = 0 then
      begin
         UpdateLine(User,Name,Value,Quantity,Period);
      end;
      for I:=0 to SL.Count-1 do
      begin
         ISL.CommaText:=SL[I];
         for J:=0 to ISL.Count-1 do
         begin
            if ISL[J] <> '' then
            begin
               case ISL[J][1] of
                 '+' : UpdateLine(User,Copy(ISL[J],2,Length(ISL[J])),Value,Quantity,Period);
                 '-' : UpdateLine(User,Copy(ISL[J],2,Length(ISL[J])),0-Value,0-Quantity,Period);
               end;
            end;
         end;
      end;
   except
   end;
   AV.Active:=False;
   ISL.Free;
   SL.Free;
end;
procedure TAccountsForm.GetLineValue(User,Name:String;var Value:Currency;var Quantity,Period:Integer);
begin
   Value   :=0;
   Quantity:=0;
   AV.Active:=True;
   try
      AV.SetKey;       
      AVAGUser  .Value:=User;
      AVAGPeriod.Value:=Period;
      AVAGName  .Value:=Name;
      if AV.GotoKey then 
      begin
         Value   :=AVAGValue.Value;
         Quantity:=AVAGQuantity.Value;
      end;
   except
   end;
   AV.Active:=False;
end;                                
procedure TAccountsForm.UpdateLine(User,Name:String;Value:Currency;Quantity,Period:Integer);
begin
   AV.SetKey;       
   AVAGUser  .Value:=User;
   AVAGPeriod.Value:=Period;
   AVAGName  .Value:=Name;
   if AV.GotoKey then
   begin
      AV.Edit;
      AVAGUser    .Value:=User;
      AVAGPeriod  .Value:=Period;
      AVAGName    .Value:=Name;
      AVAGValue   .Value:=AVAGValue   .Value+Value;
      AVAGQuantity.Value:=AVAGQuantity.Value+Quantity;
//      SendAVDG;
      AV.Post;
   end
   else
   begin
      AV.Append;
      AVAGUser    .Value:=User;
      AVAGPeriod  .Value:=Period;
      AVAGName    .Value:=Name;
      AVAGValue   .Value:=Value;
      AVAGQuantity.Value:=Quantity;
//      SendAVDG;
      AV.Post;
   end;    
end;
procedure TAccountsForm.FillFromGrid(Add:Boolean;var Index:Integer;Period:Integer;User:String;Grid:TStringGrid;
                      var NameList,ValueList,QuantityList:TStringList;
                      var Total:Currency);
var
   StartIndex,I,J:Integer;
   Users:TStringList;
   Name:String;
begin
   StartIndex:=Index;
   Users:=TStringList.Create;
//   if Grid = StockSG then
//      Users.Add(User)
//   else
   if User = '' then
      Users.CommaText:=GetUsers
   else
      Users.Add(User);
   if Users.Count = 0 then Users.Add('*');
   for J:=0 to Users.Count-1 do
   begin
      Index:=StartIndex;
      for I:=1 to Grid.RowCount-1 do
      begin
         Name:=Grid.Cells[0,I];
         AV.SetKey;
         AVAGUser       .Value:=Users[J];
         AVAGPeriod     .Value:=Period;
         AVAGName       .Value:=Name;
         if AV.GotoKey then
         begin
            if Add then
            begin
               NameList.Add(Name);
               ValueList.Add(AVAGValue.AsString);
               QuantityList.Add(AVAGQuantity.AsString);
            end
            else
            begin
               ValueList[Index]:=CurrToStr(AVAGValue.Value+StrToCurrDef(ValueList[Index],0));
               QuantityList[Index]:=IntToStr(AVAGQuantity.Value+StrToIntDef(QuantityList[Index],0));
            end;
            Total:=Total+AVAGValue.Value;
         end
         else
         begin
            if Add then
            begin
               NameList.Add(Name);
               ValueList.Add('0');
               QuantityList.Add('0');
            end;
         end;
         Inc(Index);
      end;
      Add:=False;
   end;
   Users.Free;
end;
function TAccountsForm.CommaText(Name,User,Periods:String):String;
var
   Found:Boolean;
   Period,I,J:Integer;
   ResSL:TStringList;
   SL:TStringList;
   TotalReceipts:Currency;
   TotalPayments:Currency;
   TotalStock:Currency;
   TotalValue:Currency;
   TotalUncharged:Currency;
   TotalUsersSt:Currency;
   PeriodList:TStringList;
   NameList:TStringList;
   ValueList:TStringList;
   QuantityList:TStringList;
   Index:Integer;
   RefLink:TRefLink;
begin       
   SL:=nil;
   PeriodList:=TStringList.Create;
   NameList:=TStringList.Create;
   ValueList:=TStringList.Create;
   QuantityList:=TStringList.Create;
   
   PeriodList.CommaText:=Periods;
   
   TotalReceipts  :=0;
   TotalPayments  :=0;
   TotalStock     :=0;
   TotalUncharged :=0;
   TotalUsersSt      :=0;
   if Name = 'Cash Account' then
   begin
      AV.Active:=True;
      try
         for I:=0 to PeriodList.Count-1 do
         begin
            Index:=0;
            Period:=StrToInt(PeriodList[I]);
//            TotalUsersSt:=TotalUsersSt+TotalUsersStock(User,Period);
            FillFromGrid(I=0,Index,Period,'',ReceiptsSG,NameList,ValueList,QuantityList,TotalReceipts);
            if I = 0 then
            begin
               NameList.Add('Total Receipts  (1-39) (40)');
               ValueList.Add(CurrToStr(TotalReceipts));
               QuantityList.Add('0');
            end
            else
               ValueList[Index]:=CurrToStr(TotalReceipts);
            Inc(Index);   
            FillFromGrid(I=0,Index,Period,'',PaymentsSG,NameList,ValueList,QuantityList,TotalPayments);
            if I = 0 then
            begin
               NameList.Add('Total Payments (41-62) (63)');
               ValueList.Add(CurrToStr(TotalPayments));
               QuantityList.Add('0');
            end
            else
               ValueList[Index]:=CurrToStr(TotalPayments);
            Inc(Index);   
            FillFromGrid(I=0,Index,Period,'',StockSG,NameList,ValueList,QuantityList,TotalStock);
            if I = 0 then
            begin
               NameList.Add('Total Stock (64-77) (78)');
               ValueList.Add(CurrToStr(TotalStock));
               QuantityList.Add('0');
            end
            else
               ValueList[Index]:=CurrToStr(TotalStock);
            Inc(Index);
            AV.SetKey;
            AVAGUser       .Value:=User;
            AVAGPeriod     .Value:=Period;
            AVAGName       .Value:='Uncharged Receipts';
            if AV.GotoKey then
            begin
               TotalUncharged:=TotalUncharged+AVAGValue.Value;
               if I = 0 then               
               begin
                  NameList.Add('Less Uncharged Receipts (79)');
                  ValueList.Add(CurrToStr(TotalUncharged));
                  QuantityList.Add('0');
               end
               else
                  ValueList[Index]:=CurrToStr(TotalUncharged);
            end
            else if I = 0 then
            begin
               NameList.Add('Less Uncharged Receipts (79)');
               ValueList.Add('0');
               QuantityList.Add('0');
            end;
         end;
         I:=NameList.IndexOf('Total Sub-Postmasters Stock');
         if I <> -1 then
            ValueList[I]:=CurrToStr(TotalUsersSt);
         NameList.Add('Net Total - Stock On Hand (80)'  ); ValueList.Add(CurrToStr((TotalStock+TotalUsersSt)-TotalUncharged)); QuantityList.Add('0');
         NameList.Add('Total Of Lines 63 (81)'          ); ValueList.Add(CurrToStr(TotalPayments)); QuantityList.Add('0');
         NameList.Add('Total To Agree with Line 40 (82)'); ValueList.Add(CurrToStr(((TotalStock+TotalUsersSt)-TotalUncharged)+TotalPayments)); QuantityList.Add('0');
      except
      end;
      AV.Active:=False;
   end
   else if Name = 'Stock' then
   begin
      AV.Active:=True;
      try
         for I:=0 to PeriodList.Count-1 do
         begin
            Index:=0;
            Period:=StrToInt(PeriodList[I]);
            FillFromGrid(I=0,Index,Period,User,StockSG,NameList,ValueList,QuantityList,TotalStock);
         end;
      except
      end;
      AV.Active:=False;
   end
   else if Name = 'Receipts' then
   begin
      AV.Active:=True;
      try
         for I:=0 to PeriodList.Count-1 do
         begin
            Index:=0;
            Period:=StrToInt(PeriodList[I]);
            FillFromGrid(I=0,Index,Period,User,ReceiptsSG,NameList,ValueList,QuantityList,TotalStock);
         end;
      except
      end;
      AV.Active:=False;
   end
   else if Name = 'Payments' then
   begin
      AV.Active:=True;
      try
         for I:=0 to PeriodList.Count-1 do
         begin
            Index:=0;
            Period:=StrToInt(PeriodList[I]);
            FillFromGrid(I=0,Index,Period,User,PaymentsSG,NameList,ValueList,QuantityList,TotalStock);
         end;
      except
      end;
      AV.Active:=False;
   end
   else if Copy(Name,1,7) = 'Single.' then
   begin
      Name:=Copy(Name,8,Length(Name));
      TotalValue:=0;
      TotalStock:=0;
      Period:=StrToInt(PeriodList[0]);
      AV.Active:=True;
      try
         AV.SetKey;
         AVAGUser       .Value:=User;
         AVAGPeriod     .Value:=Period;
         AVAGName       .Value:=Name;
         NameList.Add(Name);
         if AV.GotoKey then
         begin
            ValueList.Add(AVAGValue.AsString);
            QuantityList.Add(AVAGQuantity.AsString);
            TotalValue:=0-AVAGValue.Value;
            TotalStock:=0-AVAGQuantity.Value;
         end         
         else
         begin
            ValueList.Add('0');
            QuantityList.Add('0');
         end;
         AV.SetKey;
         AVAGUser       .Value:=User;
         AVAGPeriod     .Value:=Period;
         AVAGName       .Value:='S'+Name;
         NameList.Add('S'+Name);
         if AV.GotoKey then
         begin
            ValueList.Add(AVAGValue.AsString);
            QuantityList.Add(AVAGQuantity.AsString);
            TotalValue:=TotalValue+AVAGValue.Value;
            TotalStock:=TotalStock+AVAGQuantity.Value;
         end                           
         else
         begin
            ValueList.Add('0');
            QuantityList.Add('0');
         end;
         AV.SetKey;
         AVAGUser       .Value:=User;
         AVAGPeriod     .Value:=Period;
         AVAGName       .Value:='D'+Name;
         NameList.Add('D'+Name);
         if AV.GotoKey then
         begin
            ValueList.Add(AVAGValue.AsString);
            QuantityList.Add(AVAGQuantity.AsString);
            TotalValue:=TotalValue-AVAGValue.Value;
            TotalStock:=TotalStock-AVAGQuantity.Value;
         end                           
         else
         begin
            ValueList.Add('0');
            QuantityList.Add('0');
         end;
         AV.SetKey;
         AVAGUser       .Value:=User;
         AVAGPeriod     .Value:=Period;
         AVAGName       .Value:='R'+Name;
         NameList.Add('R'+Name);
         if AV.GotoKey then
         begin
            ValueList.Add(AVAGValue.AsString);
            QuantityList.Add(AVAGQuantity.AsString);
            TotalValue:=TotalValue+AVAGValue.Value;
            TotalStock:=TotalStock+AVAGQuantity.Value;
         end                           
         else
         begin
            ValueList.Add('0');
            QuantityList.Add('0');
         end;
         NameList.Add('T'+Name);
         ValueList.Add(CurrToStr(TotalValue));
         QuantityList.Add(CurrToStr(TotalStock));
      except
      end;
      AV.Active:=False;
      Result:='"T'+Name+'","'+CurrToStr(TotalValue)+'","'+CurrToStr(TotalStock)+'"';
      Exit;
   end  
   else
   begin
      Period:=StrToInt(PeriodList[0]);
      Found:=False;
      for I:=0 to AllLists.Count-1 do
      begin
         SL:=TStringList(AllLists[I]);
         for J:=0 to SL.Count-1 do
         begin
            RefLink:=TRefLink(SL.Objects[J]);
            if (RefLink <> nil) 
            and (SL[J] = Name) then
            begin
               SL:=TStringList(RefLink.Grid.Objects[RefLink.Col,RefLink.Row]);
               Found:=True;
               break;
            end;
         end;
         if Found then Break;
      end;
      if Found and (SL <> nil) then 
      begin
         AV.Active:=True;
         try
            for I:=0 to SL.Count-1 do    
            begin
               AV.SetKey;
               AVAGUser       .Value:=User;
               AVAGPeriod     .Value:=Period;
               AVAGName       .Value:=SL[I];
               if AV.GotoKey then
               begin
                  NameList.Add(SL[I]);
                  ValueList.Add(AVAGValue.AsString);
                  QuantityList.Add(AVAGQuantity.AsString);
               end
               else
               begin
                  NameList.Add(SL[I]);
                  ValueList.Add('0');
                  QuantityList.Add('0');
               end;
            end;
         except
         end;
         AV.Active:=False;
      end
      else
      begin
         J:=StockSG.Cols[0].IndexOf(Name); 
         if J <> -1 then 
         begin
            for I:=1 to StockSG.ColCount do
            begin
               if StockSG.Cells[I,J] <> '' then
               begin
                  Name:=StockSG.Cells[I,J];
                  break;
               end;
            end;
         end;
         for I:=0 to StockSG.ColCount-1 do
         begin
            J:=StockSG.Cols[I].IndexOf(Name);
            if (J <> -1) and (StockSG.Objects[I,J] <> nil) then
            begin
               SL:=TStringList(StockSG.Objects[I,J]);
               AV.Active:=True;
               try
                  for J:=0 to SL.Count-1 do
                  begin
                     AV.SetKey;
                     AVAGUser       .Value:=User;
                     AVAGPeriod     .Value:=Period;
                     AVAGName       .Value:=SL[J];
                     Index:=NameList.Add(SL[J]);
                     if AV.GotoKey then
                     begin
                        ValueList.Add(AVAGValue.AsString);
                        QuantityList.Add(AVAGQuantity.AsString);
                     end
                     else
                     begin
                        ValueList.Add('0');
                        QuantityList.Add('0');
                     end;
                     AV.SetKey;
                     AVAGUser       .Value:=User;
                     AVAGPeriod     .Value:=Period;
                     AVAGName       .Value:='S'+SL[J];
                     if AV.GotoKey then
                     begin
                        ValueList[Index]:=CurrToStr(AVAGValue.Value-StrToCurrDef(ValueList[Index],0));
                        QuantityList[Index]:=CurrToStr(AVAGQuantity.Value-StrToCurrDef(QuantityList[Index],0));
                     end;
                  end;
                  Found:=True;
               except
               end;
               AV.Active:=False;
            end;
            if Found then Break;
         end;
         if not Found then
         begin
            J:=ReceiptsSG.Cols[0].IndexOf(Name); 
            if J <> -1 then 
            begin
               for I:=1 to ReceiptsSG.ColCount do
               begin
                  if ReceiptsSG.Cells[I,J] <> '' then
                  begin
                     Name:=ReceiptsSG.Cells[I,J];
                     break;
                  end;
               end;
            end;
            for I:=0 to ReceiptsSG.ColCount-1 do
            begin
               J:=ReceiptsSG.Cols[I].IndexOf(Name);
               if (J <> -1) and (ReceiptsSG.Objects[I,J] <> nil) then
               begin
                  SL:=TStringList(ReceiptsSG.Objects[I,J]);
                  AV.Active:=True;
                  try
                     for J:=0 to SL.Count-1 do
                     begin
                        AV.SetKey;
                        AVAGUser       .Value:=User;
                        AVAGPeriod     .Value:=Period;
                        AVAGName       .Value:=SL[J];
                        NameList.Add(SL[J]);
                        if AV.GotoKey then
                        begin
                           ValueList.Add(AVAGValue.AsString);
                           QuantityList.Add(AVAGQuantity.AsString);
                        end
                        else
                        begin
                           ValueList.Add('0');
                           QuantityList.Add('0');
                        end;
                     end;
                     Found:=True;
                  except
                  end;
                  AV.Active:=False;
               end;
               if Found then Break;
            end;
         end;
         if not Found then
         begin
            J:=PaymentsSG.Cols[0].IndexOf(Name); 
            if J <> -1 then 
            begin
               for I:=1 to PaymentsSG.ColCount do
               begin
                  if PaymentsSG.Cells[I,J] <> '' then
                  begin
                     Name:=PaymentsSG.Cells[I,J];
                     break;
                  end;
               end;
            end;
            for I:=0 to PaymentsSG.ColCount-1 do
            begin
               J:=PaymentsSG.Cols[I].IndexOf(Name);
               if (J <> -1) and (PaymentsSG.Objects[I,J] <> nil) then
               begin
                  SL:=TStringList(PaymentsSG.Objects[I,J]);
                  AV.Active:=True;
                  try
                     for J:=0 to SL.Count-1 do
                     begin
                        AV.SetKey;
                        AVAGUser       .Value:=User;
                        AVAGPeriod     .Value:=Period;
                        AVAGName       .Value:=SL[J];
                        NameList.Add(SL[J]);
                        if AV.GotoKey then
                        begin
                           ValueList.Add(AVAGValue.AsString);
                           QuantityList.Add(AVAGQuantity.AsString);
                        end
                        else
                        begin
                           ValueList.Add('0');
                           QuantityList.Add('0');
                        end;
                     end;
                     Found:=True;
                  except
                  end;
                  AV.Active:=False;
               end;
               if Found then Break;
            end;
         end;
         if not Found then
         begin
            AV.Active:=True;
            try
               AV.SetKey;
               AVAGUser       .Value:=User;
               AVAGPeriod     .Value:=Period;
               AVAGName       .Value:=Name;
               NameList.Add(Name);
               if AV.GotoKey then
               begin
                  ValueList.Add(AVAGValue.AsString);
                  QuantityList.Add(AVAGQuantity.AsString);
               end
               else
               begin
                  ValueList.Add('0');
                  QuantityList.Add('0');
               end;
            except
            end;
            AV.Active:=False;
         end;
      end;                    
   end;   
   ResSL:=TStringList.Create;
   for I:=0 to NameList.Count-1 do
      ResSL.Add('"'+NameList[I]+'","'+ValueList[I]+'","'+QuantityList[I]+'"');
   Result:=ResSL.CommaText;
   ResSL.Free;
   PeriodList.Free;
   NameList.Free;
   ValueList.Free;
   QuantityList.Free;
end;
procedure TAccountsForm.Button5Click(Sender: TObject);
begin
   Form2.Memo1.Lines.CommaText:=CommaText(Edit5.Text,Edit4.Text,Edit6.Text);
   Form2.ShowModal;
end;
procedure TAccountsForm.Button6Click(Sender: TObject);
begin
   try
      Query1.DatabaseName:='PSL';
      Query1.SQL.Text:='Delete from Txnlog';
      Query1.ExecSQL;
      Query1.DatabaseName:='PSLAccount';
      Query1.SQL.Text:='Delete from AccountValues';
      Query1.ExecSQL;
      Query1.SQL.Text:='Delete from AccountUser';
      Query1.ExecSQL;
      Query1.SQL.Text:='Delete from AccountOther';
      Query1.ExecSQL;
   except
      on E : Exception do RaiseGUIDException('{F4A42C7A-D708-4620-A826-A55E8CB055CA}',E);
   end;
end;

{procedure TAccountsForm.SendAVDG;
var
   SL:TStringList;
begin
   if not AV.Active then Exit;
   SL:=TStringList.Create;
   SL.Add('AV');
   SL.Add(AVAGUser    .AsString);
   SL.Add(AVAGPeriod  .AsString);
   SL.Add(AVAGName    .AsString);
   SL.Add(AVAGValue   .AsString);
   SL.Add(AVAGQuantity.AsString);
   DataG.SendDGram(SL.CommaText);
   SL.Free;
end;
procedure TAccountsForm.SendAUDG;
var
   SL:TStringList;
begin
   if not AU.Active then Exit;
   SL:=TStringList.Create;
   SL.Add('AU');
   SL.Add(AUUser         .AsString);
   SL.Add(AUCurrentPeriod.AsString);
   SL.Add(AULastPeriod   .AsString);
   SL.Add(AUOpeningCash  .AsString);
   SL.Add(AUOpeningStock .AsString);
   SL.Add(AUClosingCash  .AsString);
   SL.Add(AUClosingStock .AsString);
   SL.Add(AULoggedOn     .AsString);
   DataG.SendDGram(SL.CommaText);
   SL.Free;
end;
procedure TAccountsForm.DataGRxDataGram(Sender: TDGramSocket; From,
  Data: String);
var
   SL:TStringList;
begin
   if From <> GetLocalMachineName then
   begin
      SL:=TStringList.Create;
      SL.CommaText:=Data;
      if SL.Count > 2 then
      begin
         if SL[0] = 'AU' then
         begin
            AU.Active:=True;
            AU.SetKey;
            AUUser.AsString:=SL[1];
            if AU.GotoKey then
               AU.Edit
            else
               AU.Append;
            AUUser         .AsString:=SL[1];
            AUCurrentPeriod.AsString:=SL[2];
            AULastPeriod   .AsString:=SL[3];
            AUOpeningCash  .AsString:=SL[4];
            AUOpeningStock .AsString:=SL[5];
            AUClosingCash  .AsString:=SL[6];
            AUClosingStock .AsString:=SL[7];
            AULoggedOn     .AsString:=SL[8];
            AU.Post;
            AU.Active:=False;
         end
         else if SL[0] = 'AV' then
         begin
            AV.Active:=True;
            AV.SetKey;
            AVAGUser     .AsString:=SL[1];
            AVAGPeriod   .AsString:=SL[2];
            AVAGName     .AsString:=SL[3];
            if AV.GotoKey then
               AV.Edit
            else
               AV.Append;
            AVAGUser     .AsString:=SL[1];
            AVAGPeriod   .AsString:=SL[2];
            AVAGName     .AsString:=SL[3];
            AVAGValue    .AsString:=SL[4];
            AVAGQuantity .AsString:=SL[5];
            AV.Post;
            AV.Active:=False;
         end;
      end;
      SL.Free;
   end;
end;
}
procedure TAccountsForm.FormDestroy(Sender: TObject);
begin
//   DataG.Active:=False;
end;

end.
    
