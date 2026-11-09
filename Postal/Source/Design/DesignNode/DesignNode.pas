unit DesignNode;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,ExtCtrls,CheckLst,DesignNodeBase,PackStrListU;

const
   StockUnitNodeColor  = $004FFFA7;
   StockGroupNodeColor = $006BBFF8;
   StockItemNodeColor  = $00FFFF80;
   SiteNodeColor       = $0000FFFF;
   TransModeNodeColor  = $008080FF;
   
type
  TMeasureType = (mtQuantity,mtValue);
  
  TLevelsForm = class(TForm)
    TypeCB: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Min: TEdit;
    Nom: TEdit;
    Max: TEdit;
  end;
  
  TStockItemNode = class(TBaseDesignNode)
  private
     FLevelsForm:TLevelsForm;
     FMType:TMeasureType;
     FMinimum:Currency;
     FNominal:Currency;
     FMaximum:Currency;
  protected
    procedure CheckPosition;                override;
    procedure DoOnPicture1Click;            override;
    procedure DoOnPicture2Click;            override;
    procedure CreateDropdown;               override;
    procedure FreeDropDown;                 override;
    procedure SetVisible(Value:Boolean);    override;
    procedure DoOnMeasureItem(var WidthValue,HeightValue:Integer); override;
  public                
    constructor Create(AOwner: TComponent); override;
  published
     property MeasureType:TMeasureType read FMType   write FMType  ;
     property Minimum    :Currency     read FMinimum write FMinimum;
     property Nominal    :Currency     read FNominal write FNominal;
     property Maximum    :Currency     read FMaximum write FMaximum;
     property NodeParent;
     property NodeChild ;
     property NodeNext  ;
     property NodePrev  ;
  end;               
  TStockGroupNodeBase = class(TBaseDesignNode)
  protected
    procedure DoOnPicture1Click;            override;
    procedure DoOnPicture2Click;            override;
    procedure CheckPosition;                override;
    procedure DoOnMeasureItem(var WidthValue,HeightValue:Integer); override;
  public                
    constructor Create(AOwner: TComponent); override;
  end;
  TStockGroupNode = class(TStockGroupNodeBase)
  published
     property NodeParent;
     property NodeChild ;
     property NodeNext  ;
     property NodePrev  ;
  end;
  
  TTickListNode = class(TStockGroupNodeBase)
  private
    FCheckList:TCheckListBox; 
    FItems:TStrings;
    procedure SetItems(Value:TStrings);
    procedure ItemChecked(Sender:TObject);
  protected
    procedure CheckPosition;                override;
    procedure CreateDropdown;               override;
    procedure FreeDropDown;                 override;
    procedure SetVisible(Value:Boolean);    override;
    procedure DoOnMeasureItem(var WidthValue,HeightValue:Integer); override;
  public                
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;     
  
  TStockUnitNode = class(TTickListNode)
  public                
    constructor Create(AOwner: TComponent); override;
  published
    property UserGroups:TStrings read FItems write SetItems;
    property NodeParent;
    property NodeChild ;
    property NodeNext  ;
    property NodePrev  ;
  end;
  TSiteNode = class(TTickListNode)
  public                
    constructor Create(AOwner: TComponent); override;
  published
    property Workstations:TStrings read FItems write SetItems;
    property NodeParent;
    property NodeChild ;
    property NodeNext  ;
    property NodePrev  ;
  end;
  TFromToNode = class(TTickListNode)
  public
    constructor Create(AOwner: TComponent); override;
    property SUTypes:TStrings read FItems write SetItems;
  published
  end;
  TTransModeNode = class(TTickListNode)
  public                
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property SUTypes:TStrings read FItems write SetItems;
    property NodeParent;
    property NodeChild ;
    property NodeNext  ;
    property NodePrev  ;
  end;

procedure Register;

implementation

{$R DesNode.DCR}  // Button pictures
{$R LevelsFU.DFM} // Levels Form File

{TStockItemNode}
procedure TStockItemNode.DoOnPicture1Click;         
begin
   Expanded:=0;
   if psLowered in PictureState1 then
   begin
      PictureState2:=PictureState2+[psRaised];
      PictureState2:=PictureState2-[psLowered];
      Expanded:=1;
   end;
end;
procedure TStockItemNode.DoOnPicture2Click;         
begin
   Expanded:=0;
   if psLowered in PictureState2 then
   begin
      PictureState1:=PictureState1-[psLowered];
      PictureState1:=PictureState1+[psRaised];
      Expanded:=2;
   end;
end;                 
procedure TStockItemNode.DoOnMeasureItem(var WidthValue,HeightValue:Integer);
begin
//   WidthValue:=136;
   HeightValue:=0;
   if Expanded = 1 then
   begin
      HeightValue:=150;
//      WidthValue:=200;
   end
   else if Expanded = 2 then
   begin
      HeightValue:=100;
//      WidthValue:=136;
   end;             
//   NodeWidth:=WidthValue-(Width-NodeWidth);
end;
constructor TStockItemNode.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   ControlStyle:=ControlStyle+[csSetCaption];
   Color:=StockItemNodeColor;
   Picture1.Bitmap.LoadFromResourceName(HInstance,'TRANSFER');
   Picture2.Bitmap.LoadFromResourceName(HInstance,'LEVELS');
   PictureState1:=[psRaised];
   PictureState2:=[psRaised];
end;
procedure TStockItemNode.CreateDropDown;
begin            
   Get3Colours(Color,Low,Mid,High);
   if Expanded = 2 then // Levels Button Pressed
   begin
      FLevelsForm:=TLevelsForm.Create(Parent);
      FLevelsForm.Parent:=Parent;
      with FLevelsForm do
      begin
        Name       :=Self.Name+'_LevelsForm';
        Font       :=Self.Font;
        Color      :=Mid;
        TabOrder   :=0;
        Enabled    :=True;
        Visible    :=True;
        Left       :=Self.Left+(Self.Width-NodeWidth)+2;
        Width      :=NodeWidth-4;
        Top        :=Self.Top+NodeHeight;
        Height     :=MeasureHeight-1;
        Min   .Color:=Self.Mid;
        Nom   .Color:=Self.Mid;
        Max   .Color:=Self.Mid;
        TypeCB.Color:=Self.Mid;
        TypeCB.Clear;
        if FMType = mtQuantity then
        begin
          TypeCB.ItemIndex:=TypeCB.Items.Add('Quantity');
          TypeCB.Items.Add('Value');
          Min.Text:=IntToStr(Trunc(FMinimum));
          Nom.Text:=IntToStr(Trunc(FNominal));
          Max.Text:=IntToStr(Trunc(FMaximum));
        end 
        else if FMType = mtValue then
        begin
          TypeCB.Items.Add('Quantity');
          TypeCB.ItemIndex:=TypeCB.Items.Add('Value');
          Min.Text:=CurrToStr(FMinimum);
          Nom.Text:=CurrToStr(FNominal);
          Max.Text:=CurrToStr(FMaximum);
        end;
        TypeCB.Text:=TypeCB.Items[TypeCB.ItemIndex];
      end;    
   end;
end;
procedure TStockItemNode.FreeDropDown;
begin
   if FLevelsForm <> nil then
   begin
      if (Parent <> nil) and Parent.ContainsControl(FLevelsForm) then 
      Parent.RemoveControl(FLevelsForm);
      FLevelsForm.Free;
      FLevelsForm:=nil;
   end;
end; 
procedure TStockItemNode.CheckPosition; 
begin
  inherited CheckPosition; 
  if FLevelsForm = nil then Exit;
  with FLevelsForm do
  begin
     Left       :=Self.Left+(Self.Width-NodeWidth)+2;
     Width      :=NodeWidth-4;
     Top        :=Self.Top+NodeHeight;
     Height     :=MeasureHeight-1;
  end;
end;
procedure TStockItemNode.SetVisible(Value:Boolean);
begin
   inherited SetVisible(Value);
   if FLevelsForm <> nil then FLevelsForm.Visible:=Value;
end;
                
{TStockGroupNodeBase}
procedure TStockGroupNodeBase.DoOnPicture1Click;         
begin
   if psHidden in PictureState1 then Exit;
   if psLowered in PictureState1 then
      Expanded:=1
   else
      Expanded:=0;
   Inherited DoOnPicture1Click;
end;  
procedure TStockGroupNodeBase.DoOnPicture2Click;         
begin
   PictureState2:=PictureState2-[psRaised];
   PictureState2:=PictureState2-[psLowered];
   if NodeChild <> nil then
   begin
      if NodeChild.Visible then
      begin
         NodeChild.Visible:=False;
         Picture2.Bitmap.LoadFromResourceName(HInstance,'RPOINT');
      end
      else
      begin
         NodeChild.Visible:=True;
         Picture2.Bitmap.LoadFromResourceName(HInstance,'LPOINT');
      end;
      PictureState2:=PictureState2-[psRaised];
      PictureState2:=PictureState2-[psLowered];
      if (psHidden in PictureState2) then
         PictureState2:=PictureState2-[psHidden];
   end
   else
   begin
      if not (psHidden in PictureState2) then
         PictureState2:=PictureState2+[psHidden];
   end;
   Inherited DoOnPicture2Click;
end;                 
procedure TStockGroupNodeBase.CheckPosition; 
begin
  inherited CheckPosition; 
   if (NodeChild = nil) then 
   begin   
      if not (psHidden in PictureState2) then
         PictureState2:=PictureState2+[psHidden];
   end
   else
   begin   
      if (psHidden in PictureState2) then
         PictureState2:=PictureState2-[psHidden];
      if NodeChild.Visible then
         Picture2.Bitmap.LoadFromResourceName(HInstance,'LPOINT')
      else
         Picture2.Bitmap.LoadFromResourceName(HInstance,'RPOINT');
   end;
end;
constructor TStockGroupNodeBase.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   ControlStyle:=ControlStyle+[csSetCaption];
   Color:=StockGroupNodeColor;
   Picture1.Bitmap.LoadFromResourceName(HInstance,'TRANSFER');
   Picture2.Bitmap.LoadFromResourceName(HInstance,'RPOINT');
   PictureState1:=[psRaised];
   PictureState2:=[psFlat];
end;
procedure TStockGroupNodeBase.DoOnMeasureItem(var WidthValue,HeightValue:Integer);
begin
   if Expanded > 0 then
   begin
      HeightValue:=100;
   end
   else
   begin
      HeightValue:=0;
   end;              
end;

{TTickListNode}
constructor TTickListNode.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FItems:=TPackStringList.Create;
end;
procedure TTickListNode.CheckPosition; 
begin
   inherited CheckPosition; 
   if (FItems = nil) or (FItems.Count = 0) then 
   begin   
      if not (psHidden in PictureState1) then
         PictureState1:=PictureState1+[psHidden];
   end
   else
   begin   
      if (psHidden in PictureState1) then
         PictureState1:=PictureState1-[psHidden];
   end;
  if FCheckList = nil then Exit;
  with FCheckList do
  begin
     Left       :=Self.Left+(Self.Width-NodeWidth)+2;
     Width      :=NodeWidth-4;
     Top        :=Self.Top+NodeHeight;
     Height     :=MeasureHeight-1;
   end;
end;
destructor TTickListNode.Destroy;
begin
   FItems.Free;
   inherited Destroy;
end;
procedure TTickListNode.CreateDropDown;
var
   I:Integer;
begin            
   Get3Colours(Color,Low,Mid,High);
   FCheckList:=TCheckListBox.Create(nil);
   FCheckList.Parent:=Parent;
   with FCheckList do
   begin
     Name       :=Self.Name+'_CheckList';
     Ctl3D      :=False;
     BorderStyle:=bsNone;
     Font       :=Self.Font;
     Color      :=Mid;
     TabOrder   :=0;
     Enabled    :=True;
     Left       :=Self.Left+(Self.Width-NodeWidth)+2;
     Width      :=NodeWidth-4;
     Top        :=Self.Top+NodeHeight;
     Height     :=MeasureHeight-1;
     Visible    :=True;
     ItemHeight:=Self.Canvas.TextHeight('Wg');
     Items.Assign(Self.FItems);
     for I:=0 to Items.Count-1 do
     begin
        Checked[I]:=Boolean(Self.FItems.Objects[I]);
     end;
     OnClickCheck:=ItemChecked;
   end;
end;
procedure TTickListNode.ItemChecked(Sender:TObject);
var
   I:Integer;
begin
  for I:=0 to FItems.Count-1 do
     FItems.Objects[I]:=TObject(FCheckList.Checked[I]);
end;
procedure TTickListNode.FreeDropDown;
begin
  if FCheckList = nil then Exit;
  if (Parent <> nil) and Parent.ContainsControl(FCheckList) then 
     Parent.RemoveControl(FCheckList);
  FCheckList.Free;
  FCheckList:=nil;
end;
procedure TTickListNode.SetVisible(Value:Boolean);
begin
   inherited SetVisible(Value);
   if FCheckList <> nil then FCheckList.Visible:=Value;
end;
procedure TTickListNode.DoOnMeasureItem(var WidthValue,HeightValue:Integer);
begin
   WidthValue:=Width;
   if Expanded > 0 then
      HeightValue:=(Canvas.TextHeight('Wg')*FItems.Count)+2
   else
      HeightValue:=0;
end;
procedure TTickListNode.SetItems(Value:TStrings);
begin
   if Value = nil then
   begin
      FItems.Clear;
   end
   else
   begin
      FItems.Assign(Value);
   end;
end;

{TStockUnitNode}
constructor TStockUnitNode.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   Color:=StockUnitNodeColor;
   Picture1.Bitmap.LoadFromResourceName(HInstance,'OPTIONS');
end;
{TSiteNode}
constructor TSiteNode.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   Color:=SiteNodeColor;
   Picture1.Bitmap.LoadFromResourceName(HInstance,'MACHINE');
end;
{TFromToNode}
constructor TFromToNode.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   Color:=TransModeNodeColor;
   Picture1.Bitmap.LoadFromResourceName(HInstance,'OPTIONS');
end;
{TTransModeNode}
constructor TTransModeNode.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   Color:=TransModeNodeColor;
   Picture1.Bitmap.LoadFromResourceName(HInstance,'OPTIONS');
end;                     
destructor TTransModeNode.Destroy;
begin
   inherited Destroy;
end;
procedure Register;
begin
  RegisterComponents('DesTree', [TStockUnitNode,TStockGroupNode,TStockItemNode,
                                 TSiteNode,TTransModeNode]);
end;

end.
