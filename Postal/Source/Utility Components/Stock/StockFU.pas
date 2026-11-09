unit StockFU;

interface

uses
  GridUtil,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,SharedStockU, Grids, ComCtrls,GPCSGUID,PackStrListU,StringUtil,CRC32,
  ExtCtrls,StringWrapperU;

type
  TCSVFormatData = class(TStringWrapper)
  public
     property Description :Variant Index 0 read GetElement write SetElement;
     property Value       :Variant Index 1 read GetElement write SetElement;
     property Group       :Variant Index 2 read GetElement write SetElement;
     property PLU         :Variant Index 3 read GetElement write SetElement;
     property AccountLine :Variant Index 4 read GetElement write SetElement;
     property AcctType    :Variant Index 5 read GetElement write SetElement;
     property Report      :Variant Index 6 read GetElement write SetElement;
     property ProgID      :Variant Index 7 read GetElement write SetElement;
  end;
  TStockForm = class(TForm)
    PageControl1: TPageControl;
    StockItems: TTabSheet;
    ItemList: TListBox;
    Description: TEdit;
    Price: TEdit;
    AccountingLine: TEdit;
    DescriptionLabel: TLabel;
    PriceLabel: TLabel;
    AccountingLineLabel: TLabel;
    AddButton: TButton;
    DelButton: TButton;
    ModButton: TButton;
    GroupLabel: TLabel;
    Label1: TLabel;
    PLU: TEdit;
    Label6: TLabel;
    ProgID: TEdit;
    Label7: TLabel;
    Load: TButton;
    OD: TOpenDialog;
    Agency: TEdit;
    Label8: TLabel;
    ReportLine: TEdit;
    Label9: TLabel;
    StockGroup: TEdit;
    Save: TButton;
    UpdateFromCSVButton: TButton;
    SD: TSaveDialog;
    TabSheet1: TTabSheet;
    StockStringGrid: TStringGrid;
    Panel1: TPanel;
    ResetStockButton: TButton;
    UserComboBox: TComboBox;
    UserLabel: TLabel;
    procedure ItemListClick(Sender: TObject);
    procedure ModButtonClick(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure DelButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ItemListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LoadClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure UpdateFromCSVButtonClick(Sender: TObject);
    procedure ResetStockButtonClick(Sender: TObject);
    procedure UserComboBoxChange(Sender: TObject);
    procedure StockStringGridDrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    LastDescription:String;
    procedure ModifyLine(Index:Integer);
    procedure AddLine;
    procedure DeleteLine(Index:Integer);
  public
    SiteStock:TSiteStock;
  end;

var
  StockForm: TStockForm;
//  RefCount:Integer;

implementation

{$R *.DFM}
uses
   ComServ2;

procedure TStockForm.ItemListClick(Sender: TObject);
var
   StockIndex:Integer;
begin
   if SiteStock = nil then Exit;
   StockIndex:=SiteStock.Stock.IndexOfItem((ItemList.Items[ItemList.ItemIndex]));
   if StockIndex >= 0 then
   begin
      Description.Text:=SiteStock.Stock.Description[StockIndex];
      Price.Text      :=SiteStock.Stock.Price      [StockIndex];
      PLU.Text        :=SiteStock.Stock.PLU        [StockIndex];
      ProgID.Text     :=SiteStock.Stock.ProgID     [StockIndex];
      StockGroup.Text :=SiteStock.Stock.Group      [StockIndex];
      Agency.Text     :=SiteStock.Stock.Agency     [StockIndex];
      LastDescription:=Description.Text;
   end;
end;

procedure TStockForm.ModifyLine(Index:Integer);
var
   StockIndex:Integer;
begin
   ItemList.Items[ItemList.ItemIndex]:=Description.Text;
   if SiteStock = nil then Exit;
   StockIndex:=SiteStock.Stock.IndexOfItem((ItemList.Items[ItemList.ItemIndex]));
   if StockIndex >= 0 then
   begin
      SiteStock.Stock.Description[StockIndex]:=Description.Text;
      SiteStock.Stock.Price      [StockIndex]:=Price.Text      ;
      SiteStock.Stock.PLU        [StockIndex]:=PLU.Text        ;
      SiteStock.Stock.ProgID     [StockIndex]:=ProgID.Text     ;
      SiteStock.Stock.Group      [StockIndex]:=StockGroup.Text ;
      SiteStock.Stock.Agency     [StockIndex]:=Agency.Text     ;
   end;
end;
procedure TStockForm.AddLine;
begin
   if SiteStock = nil then Exit;
   SiteStock.Stock.AddItem(Description.Text,PLU.Text,StockGroup.Text,Agency.text,StrToCurrDef(Price.Text,0),ProgID.Text);
   ItemList.ItemIndex:=ItemList.Items.Add(Description.Text);
end;
procedure TStockForm.DeleteLine(Index:Integer);
begin
   if SiteStock = nil then Exit;
   SiteStock.DeleteStockItemByName(Description.Text);
   ItemList.Items.Delete(Index);
end;
procedure TStockForm.ModButtonClick(Sender: TObject);
begin
   if (ItemList.ItemIndex >= 0) then
   begin
      if (LastDescription <> Description.Text) then
      begin
         if ItemList.Items.IndexOf(Description.Text) = -1 then
            ModifyLine(ItemList.ItemIndex)
      end
      else
         ModifyLine(ItemList.ItemIndex);
   end;
end;

procedure TStockForm.AddButtonClick(Sender: TObject);
begin
   if ItemList.Items.IndexOf(Description.Text) = -1 then
      AddLine;
end;

procedure TStockForm.DelButtonClick(Sender: TObject);
var
   I:Integer;
begin
   I:=ItemList.ItemIndex;
   if (ItemList.ItemIndex >= 0) then
      DeleteLine(ItemList.ItemIndex);
   if (I >= 0) and (I < ItemList.Items.Count) then
      ItemList.ItemIndex:=I
   else if ItemList.Items.Count > 0 then
      ItemList.ItemIndex:=ItemList.Items.Count-1;
end;

procedure TStockForm.FormCreate(Sender: TObject);
var
  I:Integer;
begin
//  SiteStock:=TSiteStock.Create;

  UserComboBox.Clear;
  if SiteStock = nil then Exit;
  for I :=0 to SiteStock.Stock.UserCount-1 do
  begin
     if SiteStock.Stock.Owner[I] <> '' then
        UserComboBox.Items.Add(SiteStock.Stock.Owner[I]);
  end;

  for I:=0 to SiteStock.Stock.ItemCount-1 do
     if SiteStock.Stock.Description[I] <> '' then
        ItemList.Items.Add(SiteStock.Stock.Description[I]);
end;

procedure TStockForm.FormDestroy(Sender: TObject);
begin
   if SiteStock <> nil then
      SiteStock.Free;
end;

procedure TStockForm.ItemListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   Value:String;
   FC:TColor;
   StockIndex:Integer;
begin
   if SiteStock = nil then Exit;
   with (Control as TListBox).Canvas do
   begin
      FC:=Font.Color;
      StockIndex:=SiteStock.Stock.IndexOfItem((Control as TListBox).Items[Index]);
      if ((SiteStock.Stock.Agency[StockIndex] = '') or (SiteStock.Stock.Group[StockIndex] = '')) then
      begin
         if (odSelected in State) then
            Font.Color:=clYellow
         else
            Font.Color:=clBlue;
      end;
      Value:=CurrToStrF(SiteStock.Stock.Price[StockIndex],ffNumber,2);
      FillRect(Rect);
      TextOut(Rect.Right-(TextWidth(Value)+1),Rect.Top,Value);
      TextOut(Rect.Left+1,Rect.Top,ItemList.Items[Index]);
      Font.Color:=FC;
   end;
end;

procedure TStockForm.LoadClick(Sender: TObject);
var
   SL:TPackStringList;
   LSL:TCSVFormatData;
   I:Integer;
begin
   if SiteStock = nil then Exit;
   if OD.Execute then
   begin
      SiteStock.Free;
      ItemList.Clear;
      SiteStock:=TSiteStock.Create;
      SiteStock.Clear;
      SL:=TPackStringList.Create;
      LSL:=TCSVFormatData.Create;
      SL.LoadFromFile(OD.FileName);
      for I:=0 to SL.Count-1 do
      begin
         if Trim(SL[I]) <> '' then
         begin
            LSL.CommaText:=SL[I];
            SiteStock.Stock.AddItem(LSL.Description,LSL.PLU,
                                    LSL.Group,LSL.AcctType,LSL.Value,LSL.ProgID);
         end;
      end;
      for I:=0 to SiteStock.Stock.ItemCount-1 do
         if SiteStock.Stock.Description[I] <> '' then
            ItemList.Items.Add(SiteStock.Stock.Description[I]);
      LSL.Free;
      SL.Free;
   end;
end;

procedure TStockForm.SaveClick(Sender: TObject);
var
   SL,LSL:TStringList;
   I:Integer;
begin
   if SiteStock = nil then Exit;
   if SD.Execute then
   begin
      SL :=TStringList.Create;
      LSL:=TStringList.Create;
      for I:=0 to SiteStock.Stock.ItemCount-1 do
      begin
         if (not VarIsEmpty(SiteStock.Stock.Description[I])) and (SiteStock.Stock.Description[I] <> '') then
         begin
            SL.Add(SiteStock.Stock.Description[I]);
            SL.Add(CurrToStr(SiteStock.Stock.Price[I]));
            SL.Add(SiteStock.Stock.Group[I]);
            SL.Add(IntToStr(SiteStock.Stock.PLU[I])   );
            SL.Add('NotNeeded');
            SL.Add(SiteStock.Stock.Agency[I]);
            SL.Add('NotNeeded');
            SL.Add(SiteStock.Stock.ProgID[I]);
            SL.Add('Clerk');
            SL.Add('Supervisor');
            SL.Add('Declare');
            LSL.Add(SL.CommaText);
            SL.Clear;
         end;
      end;    
      SL .Free;
      LSL.SaveToFile(SD.FileName);
      LSL.Free;
   end;
end;

procedure TStockForm.UpdateFromCSVButtonClick(Sender: TObject);
var
   I:Integer;
begin
   if SiteStock = nil then Exit;
  if OD.Execute then
  begin
    UpdateFromCSV(OD.FileName,SiteStock);
    ItemList.Clear;
    for I:=0 to SiteStock.Stock.ItemCount-1 do
    begin
      If SiteStock.Stock.Description[I] <> '' then
        ItemList.Items.Add(SiteStock.Stock.Description[I]);
    end;
  end;
end;

procedure TStockForm.ResetStockButtonClick(Sender: TObject);
begin
   if SiteStock = nil then Exit;
  SiteStock.ResetStockFor(UserComboBox.Text);
  UserComboBoxChange(Sender);
end;

procedure TStockForm.UserComboBoxChange(Sender: TObject);
//var
//   I,ItemCount:Integer;
//   UserIndex:Integer;
//   MW:Array[0..4] of Integer;
begin
   if SiteStock = nil then Exit;
  SiteStock.EmptySetUp(UserComboBox.Text);
  CommaTextIntoGrid(StockStringGrid, SiteStock.Stock.ListStock(UserComboBox.Text, 'All', False));
  StockStringGrid.Rows[0].CommaText := 'Description,Quantity,Price,PLU,Product';

{   UserIndex:=SiteStock.Stock.IndexOfUser(UserComboBox.Text);

   MW[0]:=StockStringGrid.Canvas.TextWidth('Description');
   MW[1]:=StockStringGrid.Canvas.TextWidth('Quantity');
   MW[2]:=StockStringGrid.Canvas.TextWidth('Price');
   MW[3]:=StockStringGrid.Canvas.TextWidth('PLU');
   MW[4]:=StockStringGrid.Canvas.TextWidth('ProgID');
   ItemCount:=0;
   for I:=0 to SiteStock.Stock.ItemCount-1 do
   begin
      if SiteStock.Stock.Description[I] <> '' then
      begin
         if StockStringGrid.Canvas.TextWidth(SiteStock.Stock.Description[          I]) > MW[0] then MW[0]:=StockStringGrid.Canvas.TextWidth(SiteStock.Stock.Description[          I]);
         if StockStringGrid.Canvas.TextWidth(IntTostr(SiteStock.Stock.Quantity   [UserIndex,I])) > MW[1] then MW[1]:=StockStringGrid.Canvas.TextWidth(IntTostr(SiteStock.Stock.Quantity   [UserIndex,I]));
         if StockStringGrid.Canvas.TextWidth(SiteStock.Stock.Price      [          I]) > MW[2] then MW[2]:=StockStringGrid.Canvas.TextWidth(SiteStock.Stock.Price      [          I]);
         if StockStringGrid.Canvas.TextWidth(SiteStock.Stock.PLU        [          I]) > MW[3] then MW[3]:=StockStringGrid.Canvas.TextWidth(SiteStock.Stock.PLU        [          I]);
         if StockStringGrid.Canvas.TextWidth(SiteStock.Stock.ProgID     [          I]) > MW[4] then MW[4]:=StockStringGrid.Canvas.TextWidth(SiteStock.Stock.ProgID     [          I]);
         Inc(ItemCount);
      end;
   end;
   for I:=0 to 4 do StockStringGrid.ColWidths[I]:=MW[I]+10;
   StockStringGrid.RowCount:=ItemCount+1;
   StockStringGrid.Repaint;}
end;

procedure TStockForm.StockStringGridDrawCell(Sender: TObject; Col,
  Row: Integer; Rect: TRect; State: TGridDrawState);
var
   Value:String;
   UserIndex:Integer;
begin
   if SiteStock = nil then Exit;
   UserIndex:=SiteStock.Stock.IndexOfUser(UserComboBox.Text);
   if UserIndex = -1 then Exit;
   Value:='';
   if Row = 0 then
   begin
      case Col of
         0 : Value:='Description';
         1 : Value:='Quantity';
         2 : Value:='Price';
         3 : Value:='PLU';
         4 : Value:='ProgID';
      end;
   end
   else
   begin
      case Col of
         0 : Value:=SiteStock.Stock.Description[          Row-1];
         1 : Value:=IntToStr(SiteStock.Stock.Quantity   [UserIndex,Row-1]);
         2 : Value:=SiteStock.Stock.Price      [          Row-1];
         3 : Value:=SiteStock.Stock.PLU        [          Row-1];
         4 : Value:=SiteStock.Stock.ProgID     [          Row-1];
      end;
   end;
   StockStringGrid.Canvas.TextOut(Rect.Left+2,Rect.Top+2,Value);
end;

end.

