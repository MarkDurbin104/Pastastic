unit StockFU;

interface

uses
  StringUtil,
  GPCSErrorLine,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,StockU, StockData, Grids, ComCtrls,GPCSGUID,PackStrListU,
  DBGrids, Db, ExtCtrls;


const

   K_STOCKFILE       = 'Stock.dat'   ;
   //K_STOCKITEMFILE   = 'StockItem.dat' ;

type
  TStockForm = class(TForm)
    PageControl1: TPageControl;
    StockItems: TTabSheet;
    StockUnitTypes: TTabSheet;
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
    StockItemsLabel: TLabel;
    Label1: TLabel;
    SUItemList: TListBox;
    SUTypes: TListBox;
    SUTypesLabel: TLabel;
    NewSUType: TEdit;
    Button1: TButton;
    SUTypeItems: TListBox;
    Label2: TLabel;
    MinQ: TEdit;
    Label3: TLabel;
    MaxQ: TEdit;
    Label4: TLabel;
    NomQ: TEdit;
    Label5: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    PLU: TEdit;
    Label6: TLabel;
    ProgID: TEdit;
    Label7: TLabel;
    Button5: TButton;
    OD: TOpenDialog;
    Agency: TEdit;
    Label8: TLabel;
    ReportLine: TEdit;
    Label9: TLabel;
    StockGroup: TEdit;
    StockUnitItems: TTabSheet;
    StockUnitItemsDataSource: TDataSource;
    ReindexButton: TButton;
    Panel1: TPanel;
    UnitComboBox: TComboBox;
    Label10: TLabel;
    UnitItemListBox: TListBox;
    DescriptionEdit: TEdit;
    QuantityEdit: TEdit;
    MinLevelEdit: TEdit;
    MaxLevelEdit: TEdit;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    PriceEdit: TEdit;
    TempAdjustEdit: TEdit;
    NomLevelEdit: TEdit;
    TQuantityEdit: TEdit;
    GroupEdit: TEdit;
    AgencyEdit: TEdit;
    PLUEdit: TEdit;
    ProgIDEdit: TEdit;
    Label23: TLabel;
    AccountLineEdit: TEdit;
    ModifyUnitItemButton: TButton;
    procedure ItemListClick(Sender: TObject);
    procedure ModButtonClick(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure DelButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ItemListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SUTypeItemsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SUTypeItemsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SUTypesClick(Sender: TObject);
    procedure SUTypeItemsClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ReindexButtonClick(Sender: TObject);
    procedure UnitComboBoxChange(Sender: TObject);
    procedure UnitItemListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure UnitItemListBoxClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure ModifyUnitItemButtonClick(Sender: TObject);
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

implementation

{$R *.DFM}
uses
   ComServ2;
   
procedure TStockForm.ItemListClick(Sender: TObject);
var
   StockItem:TStockItem;
begin
   StockItem:=TStockItem(ItemList.Items.Objects[ItemList.ItemIndex]);
   if StockItem <> nil then
   begin
      Description.Text:=StockItem.Description;
      Price.Text:=CurrToStrF(StockItem.Price,ffNumber,2);
      PLU.Text:=IntToStr(StockItem.PLU);
      ProgID.Text:=StockItem.ProgID;
      LastDescription:=Description.Text;
      StockGroup.Text:=StockItem.Group;
      AccountingLine.Text:=StockItem.AccountID;
      Agency.Text        :=StockItem.Agency    ;
      ReportLine.Text    :=StockItem.ReportLine;
   end;
end;

procedure TStockForm.ModifyLine(Index:Integer);
var
   StockItem:TStockItem;
begin
   ItemList.Items[ItemList.ItemIndex]:=Description.Text;
   SUItemList.Items[ItemList.ItemIndex]:=Description.Text;
   StockItem:=TStockItem(ItemList.Items.Objects[ItemList.ItemIndex]);
   StockItem.Description:=Description.Text;
   StockItem.Price:=StrToCurrDef(Price.Text,0);
   StockItem.PLU:=StrToIntDef(PLU.Text,0);
   StockItem.ProgID:=ProgID.Text;
   StockItem.Group:=StockGroup.Text;
   StockItem.AccountID:=AccountingLine.Text;
   StockItem.Agency    :=Agency.Text    ;
   StockItem.ReportLine:=ReportLine.Text;
   StockItem.Save ;
   SUTypesClick(SUTypes);
   SiteStock.Modified:=True;
   //SiteStock.ItemModified:= True;
   //SiteStock.UnitItemModified:= True;
end;
procedure TStockForm.AddLine;
var
   StockItem:TStockItem;
begin
   StockItem:=TStockItem.Create(Description.Text,StrToCurrDef(Price.Text,0),0);
   StockItem.Group:=StockGroup.Text;
   StockItem.AccountID:=AccountingLine.Text;
   StockItem.Agency    :=Agency.Text    ;
   StockItem.ReportLine:=ReportLine.Text;
   StockItem.PLU:=StrToIntDef(PLU.Text,0);
   StockItem.ProgID:=ProgID.Text;
   StockItem.Identifier:=SiteStock.StockItems.Add(StockItem);
   StockItem.Save ;
   ItemList.ItemIndex:=ItemList.Items.AddObject(Description.Text,StockItem);
   SUItemList.Items.AddObject(Description.Text,StockItem);
   //SiteStock.ItemModified:=True;
   //SiteStock.UnitItemModified:= True;
   SiteStock.Modified:= True ;
end;
procedure TStockForm.DeleteLine(Index:Integer);
var
   StockItem:TStockItem;
begin
   StockItem:=TStockItem(ItemList.Items.Objects[ItemList.ItemIndex]);
   ItemList.Items.Delete(Index);
   SUItemList.Items.Delete(Index);
   SiteStock.DeleteStockItem(StockItem);
   SUTypesClick(SUTypes);
   SiteStock.Modified:=True;
   //SiteStock.ItemModified:=True;
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
   try

      PageControl1.ActivePage := StockItems ;
      SiteStock:=TSiteStock.Create;
      if ComServer.StartMode = smStandalone then
         SiteStock.AutoSave:=False;

      SiteStock.StockFile     := K_STOCKFILE ;
      //SiteStock.StockItemFile := K_STOCKITEMFILE ;

      if GetGPCSRegString('','System Name','Tanzania Post') = 'Bermuda Post' then
         SiteStock.CurrentDirectory := 'C:\Bermuda\Binary\'
      else if GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post' then
         SiteStock.CurrentDirectory := 'C:\Tan\Binary\'
      else if GetGPCSRegString('','System Name','Tanzania Post') = 'Pakistan Post' then
         SiteStock.CurrentDirectory := 'C:\Pakistan\Binary\'
      else if GetGPCSRegString('','System Name','Tanzania Post') = 'Vietnam Post' then
         SiteStock.CurrentDirectory := 'C:\Vietnam\Binary\'
      else
         SiteStock.CurrentDirectory := ExtractFilePath(Application.ExeName) ;

      if ( StockDataModule.StockItemTable.State <> dsInactive ) and
         ( StockDataModule.StockUnitItemTable.State <> dsInactive ) then
      begin

         SiteStock.LoadFromFile ;
      //   TextSave:=False;
         for I:=0 to SiteStock.StockItems.Count-1 do
         begin
            ItemList.Items.AddObject(SiteStock.StockItems[I].Description,SiteStock.StockItems[I]);
            SUItemList.Items.AddObject(SiteStock.StockItems[I].Description,SiteStock.StockItems[I]);
         end;
         for I:=0 to SiteStock.StockUnitTypes.Count-1 do
         begin
            SUTypes.Items.AddObject(SiteStock.StockUnitTypes[I].Name,SiteStock.StockUnitTypes[I]);
         end;

         SiteStock.Modified:=False;
         SiteStock.ItemModified:=False;
      end;
   except
      On E : Exception do RaiseGUIDException('{CAE00C74-0881-4BC3-B90F-8AAFBBD8FE24}', E);
   end ;
end;

procedure TStockForm.FormDestroy(Sender: TObject);
begin
   SiteStock.Free;
end;

procedure TStockForm.ItemListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   Value:String;
   StockItem:TStockItem;
   FC:TColor;
begin
   with (Control as TListBox).Canvas do
   begin
      FC:=Font.Color;
      StockItem:=TStockItem((Control as TListBox).Items.Objects[Index]);
      if ((StockItem.AccountID = '') or (StockItem.Group = '')) then
      begin
         if (odSelected in State) then
            Font.Color:=clYellow
         else
            Font.Color:=clBlue;
      end;
      Value:=CurrToStrF(StockItem.Price,ffNumber,2);
      FillRect(Rect);
      TextOut(Rect.Right-(TextWidth(Value)+1),Rect.Top,Value);
      TextOut(Rect.Left+1,Rect.Top,ItemList.Items[Index]);
      Font.Color:=FC;
   end;
end;

procedure TStockForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//var
//   Res:Word;
begin
   try
      CanClose:=True;
      if SiteStock <> nil then
      begin
         if SiteStock.Modified or SiteStock.ItemModified or SiteStock.UnitItemModified then
         begin
            //Res:=MessageDlg('The Stock has been Modified. Do you wish to save the changes?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
            //if Res = mrCancel then
            //begin
            //   CanClose:=False;
            //end
            //else if Res = mrYes then
            //begin
               SiteStock.StockFile     := K_STOCKFILE ;
               //SiteStock.StockItemFile := K_STOCKITEMFILE ;
               if GetGPCSRegString('','System Name','Tanzania Post') = 'Bermuda Post' then
                  SiteStock.CurrentDirectory := 'C:\Bermuda\Binary\'
               else if GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post' then
                  SiteStock.CurrentDirectory := 'C:\Tan\Binary\'
               else if GetGPCSRegString('','System Name','Tanzania Post') = 'Pakistan Post' then
                  SiteStock.CurrentDirectory := 'C:\Pakistan\Binary\'
               else
                 SiteStock.CurrentDirectory := ExtractFilePath(Application.ExeName) ;

               SiteStock.TextSaveMode := TRUE ;
              // SiteStock.SaveToFiles ;

            end;
            if SiteStock.Modified then
               SiteStock.SaveToStockFile ;
            if SiteStock.ItemModified then
               SiteStock.SaveToStockItemFile ;
            if SiteStock.UnitItemModified then
               SiteStock.SaveToStockUnitItemFile ;
      end;
   except
   end ;

   //end;
end;

procedure TStockForm.Button1Click(Sender: TObject);
var
  SUType:TStockUnitType;
begin
   If SUTypes.Items.IndexOf(NewSUType.Text) = -1 then
   begin
      SUType:=TStockUnitType.Create(NewSUType.Text);
      SiteStock.StockUnitTypes.Add(SUType);
      SUTypes.Items.AddObject(NewSUType.Text,SUType);
      SiteStock.Modified:=True;
      //SiteStock.ItemModified:=True;
   end;
end;

procedure TStockForm.Button2Click(Sender: TObject);
var
  SUType:TStockUnitType;
  I:Integer;
begin
   If SUTypes.ItemIndex >= 0 then
   begin
      I:=SUTypes.ItemIndex;
      SUType:=TStockUnitType(SUTypes.Items.Objects[I]);
      SiteStock.StockUnitTypes.Delete(SiteStock.StockUnitTypes.IndexOf(SUType.Name));
      SUTypes.Items.Delete(I);
      if (I >= 0) and (I < SUTypes.Items.Count) then
         SUTypes.ItemIndex:=I
      else if SUTypes.Items.Count > 0 then
         SUTypes.ItemIndex:=ItemList.Items.Count-1;
      SiteStock.Modified:=True;
      //SiteStock.ItemModified:=True;
   end;
end;

procedure TStockForm.SUTypeItemsDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   if (Source = SUItemList) and (SUTypes.ItemIndex >= 0) then
      Accept:=True
   else
      Accept:=False;
end;          

procedure TStockForm.SUTypeItemsDragDrop(Sender, Source: TObject; X, Y: Integer);
var
   I:Integer;
   StockUnitItem:TStockUnitItem;
   SUType:TStockUnitType;
begin          
   if (Source = SUItemList) and (SUTypes.ItemIndex >= 0) then
   begin
      for I:=0 to SUItemList.Items.Count-1 do
      begin
         if SUItemList.Selected[I] then
         begin
            if SUTypeItems.Items.IndexOf(SUItemList.Items[I]) = -1 then
            begin
               SUType:=TStockUnitType(SUTypes.Items.Objects[SUTypes.ItemIndex]);
               StockUnitItem:=TStockUnitItem.Create(TStockItem(SUItemList.Items.Objects[I]),0,0,0,0, SUType ) ;
               SUTypeItems.Items.AddObject(SUItemList.Items[I],StockUnitItem);
               SUType.Add(StockUnitItem);
               SiteStock.Modified:=True;
               //SiteStock.ItemModified:=True;
            end;
         end;
      end;
   end;
end;

procedure TStockForm.SUTypesClick(Sender: TObject);
var
   I:Integer;
   SUType:TStockUnitType;
begin
   If SUTypes.ItemIndex >= 0 then
   begin
      SUTypeItems.Items.Clear;
      SUType:=TStockUnitType(SUTypes.Items.Objects[SUTypes.ItemIndex]);
      for I:=0 to SUType.Count-1 do
      begin
         SUTypeItems.Items.AddObject(SUType[I].Description,SUType[I]);
      end;
   end;

end;

procedure TStockForm.SUTypeItemsClick(Sender: TObject);
var
   StockUnitItem:TStockUnitItem;
begin  
   if SUItemList.ItemIndex >= 0 then
   begin
      StockUnitItem:=TStockUnitItem(SUTypeItems.Items.Objects[SUTypeItems.ItemIndex]);
      MinQ.Text:=IntToStr(StockUnitItem.MinLevel);
      MaxQ.Text:=IntToStr(StockUnitItem.MaxLevel);
      NomQ.Text:=IntToStr(StockUnitItem.NomLevel);
   end;
end;

procedure TStockForm.Button3Click(Sender: TObject);
var

   StockUnitItem:TStockUnitItem;
begin
   if SUItemList.ItemIndex >= 0 then
   begin
      StockUnitItem:=TStockUnitItem(SUTypeItems.Items.Objects[SUTypeItems.ItemIndex]);
      StockUnitItem.MinLevel:=StrToIntDef(MinQ.Text,0);
      StockUnitItem.MaxLevel:=StrToIntDef(MaxQ.Text,0);
      StockUnitItem.NomLevel:=StrToIntDef(NomQ.Text,0);
      SiteStock.Modified:=True;
      //SiteStock.ItemModified:=True;
   end;
end;

procedure TStockForm.Button4Click(Sender: TObject);
var
   StockUnitItem:TStockUnitItem;
   SUType:TStockUnitType;
   I:Integer;
begin
   if SUItemList.ItemIndex >= 0 then
   begin
      StockUnitItem:=TStockUnitItem(SUTypeItems.Items.Objects[SUTypeItems.ItemIndex]);
      SUType:=TStockUnitType(SUTypes.Items.Objects[SUTypes.ItemIndex]);
      SUType.Delete(SUType.IndexOf(StockUnitItem.Description));
      I:=SUTypeItems.ItemIndex;
      SUTypeItems.Items.Delete(I);
      if (I >= 0) and (I < SUTypeItems.Items.Count) then
         SUTypeItems.ItemIndex:=I
      else if SUTypeItems.Items.Count > 0 then
         SUTypeItems.ItemIndex:=SUTypeItems.Items.Count-1;
      SiteStock.Modified:=True;
      //SiteStock.ItemModified:=True;
   end;
end;

procedure TStockForm.Button5Click(Sender: TObject);
var
   TSL:TPackStringList;
   SL:TPackStringList;
   LSL:TPackStringList;
   I,J:Integer;
begin
   if OD.Execute then
   begin
      SiteStock.Free;
      ItemList.Clear;
      SUItemList.Clear;
      SUTypes.Clear;
      SUTypeItems.Clear;
      NewSUType.Text:='';
      SiteStock:=TSiteStock.Create;
      SiteStock.AutoSave:=False;
      SL:=TPackStringList.Create;
      TSL:=TPackStringList.Create;
      LSL:=TPackStringList.Create;
      SL.LoadFromFile(OD.FileName);
      for I:=0 to SL.Count-1 do
      begin
         if Trim(SL[I]) <> '' then
         begin
            TSL.CommaText:=SL[I];
            for J:=0 to 7 do TSL.Delete(0);
            LSL.CommaText:=SL[I];
            //"Parking Tickets",0.00,Parking,0010000000,Magistrates,Receipt,"PARKING FINES","Product.ParkFine"
            //0=Description,1=Value,2=Group,3=PLU,4=AccountLine,5=AcctType,6=Report,7=ProgID
            SiteStock.AddNewStockItem(LSL[0],StrToCurrDef(LSL[1],0),LSL[2],StrToIntDef(LSL[3],0),LSL[4],LSL[5],LSL[6],LSL[7],TSL.CommaText);
         end;
      end;
      for I:=0 to SiteStock.StockItems.Count-1 do
      begin
         ItemList.Items.AddObject(SiteStock.StockItems[I].Description,SiteStock.StockItems[I]);
         SUItemList.Items.AddObject(SiteStock.StockItems[I].Description,SiteStock.StockItems[I]);
      end;
      for I:=0 to SiteStock.StockUnitTypes.Count-1 do
      begin
         SUTypes.Items.AddObject(SiteStock.StockUnitTypes[I].Name,SiteStock.StockUnitTypes[I]);
      end;
      LSL.Free;
      SL.Free;
      TSL.Free;
      SiteStock.Modified:=True;
      SiteStock.ItemModified:=True;
   end;
end;

procedure TStockForm.ReindexButtonClick(Sender: TObject);
begin
   StockDataModule.BuildIndexes;
end;
procedure TStockForm.UnitComboBoxChange(Sender: TObject);
begin

   SiteStock.GetStockUnitsItems( UnitComboBox.Text, UnitItemListBox.Items , VarArrayOf([tsDescription ]));
   UnitItemListBoxClick( nil ) ;   

end;

procedure TStockForm.UnitItemListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   ValuePrice, ValueQuantity:String;
   LenghtPrice, LenghtQuantity : Integer ;
   StockUnitItem:TStockUnitItem;
   FC:TColor;
begin
   with (Control as TListBox).Canvas do
   begin
      FC:=Font.Color;
      StockUnitItem:=TStockUnitItem((Control as TListBox).Items.Objects[Index]);
      if ((StockUnitItem.AccountID = '') or (StockUnitItem.Group = '')) then
      begin
         if (odSelected in State) then
            Font.Color:=clYellow
         else
            Font.Color:=clBlue;
      end;
      ValuePrice:=CurrToStrF(StockUnitItem.Price,ffNumber,2);
      LenghtPrice := TextWidth(ValuePrice)+1;
      ValueQuantity:=RightPad( IntToStr(StockUnitItem.Quantity), 8, ' ');
      LenghtQuantity := TextWidth(ValueQuantity)+1;

      FillRect(Rect);

      TextOut(Rect.Right-(LenghtPrice),Rect.Top,ValuePrice);
      TextOut(Rect.Left+1,Rect.Top,ValueQuantity);
      TextOut(Rect.Left+1+LenghtQuantity+3,Rect.Top,UnitItemListBox.Items[Index]);

      Font.Color:=FC;
   end;

end;

procedure TStockForm.UnitItemListBoxClick(Sender: TObject);
var
   StockUnitItem:TStockUnitItem;
begin

   if (UnitItemListBox.Items.Count > 0) and (UnitItemListBox.ItemIndex <=0) then
      UnitItemListBox.ItemIndex := 0 ;
      
   if UnitItemListBox.ItemIndex >= 0 then
   begin
      StockUnitItem:=TStockUnitItem(UnitItemListBox.Items.Objects[UnitItemListBox.ItemIndex]);
      if StockUnitItem <> nil then
      begin
         DescriptionEdit.Text := StockUnitItem.Description;
         QuantityEdit.Text    := IntToStr(StockUnitItem.Quantity);
         MinLevelEdit.Text    := IntToStr(StockUnitItem.MinLevel);
         MaxLevelEdit.Text    := IntToStr(StockUnitItem.MaxLevel);
         TQuantityEdit.Text   := IntToStr(StockUnitItem.TQuantity);
         NomLevelEdit.Text    := IntToStr(StockUnitItem.NomLevel);
         TempAdjustEdit.Text  := IntToStr(StockUnitItem.TempAdjust);
         PriceEdit.Text       :=CurrToStrF(StockUnitItem.Price,ffNumber,2);
         PLUEdit.Text         :=IntToStr(StockUnitItem.PLU);
         ProgIDEdit.Text      :=StockUnitItem.ProgID;
         GroupEdit.Text       :=StockUnitItem.Group;
         AccountLineEdit.Text :=StockUnitItem.AccountID;
         AgencyEdit.Text      :=StockUnitItem.Agency    ;
         ReportLine.Text      :=StockUnitItem.ReportLine;
      end;
   end ;

end;

procedure TStockForm.PageControl1Change(Sender: TObject);
begin
   if PageControl1.ActivePage = StockUnitItems then
   begin
   
      UnitComboBox.Items.CommaText := SiteStock.GetStockUnitsOwners ;
      UnitComboBox.Text := '' ;
      if UnitComboBox.Items.Count > 0 then
         UnitComboBox.ItemIndex := 0 ;

      UnitComboBoxChange( nil );
      if UnitItemListBox.Items.Count > 0 then
         UnitItemListBox.ItemIndex := 0 ;
      UnitItemListBoxClick( nil ) ;
   end ;
end;

procedure TStockForm.ModifyUnitItemButtonClick(Sender: TObject);
var
   StockUnitItem : TStockUnitItem;
begin

   if UnitItemListBox.ItemIndex >= 0 then
   begin
      StockUnitItem:=TStockUnitItem(UnitItemListBox.Items.Objects[UnitItemListBox.ItemIndex]);
      if ( StockUnitItem <> nil ) and
         ( StockUnitItem.Description = DescriptionEdit.Text ) then
      begin
         StockUnitItem.Quantity  := StrToInt( QuantityEdit.Text   );
         StockUnitItem.MinLevel  := StrToInt( MinLevelEdit.Text   );
         StockUnitItem.MaxLevel  := StrToInt( MaxLevelEdit.Text   );
         StockUnitItem.TQuantity := StrToInt( TQuantityEdit.Text  );
         StockUnitItem.NomLevel  := StrToInt( NomLevelEdit.Text   );
         StockUnitItem.TempAdjust:= StrToInt( TempAdjustEdit.Text );
         StockUnitItem.Save ;
         UnitComboBoxChange( nil ) ;

      end;
   end ;

end;

end.
