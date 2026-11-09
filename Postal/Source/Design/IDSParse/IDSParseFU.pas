
unit IDSParseFU;

interface

uses
  WaitF, StringUtil, SavePosFormU,MAth,GridUtil,Windows,ShellAPI,
  ComObj, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,ParseNode,ProjectElements,Printers, Buttons,
  GPCSBase_TLB,GPCSGUID,StretchU, Menus, ComCtrls,Utils,WinExecU,DrawNodeU,DrawButtonU,Grids;
  
const
   BaseNodeHeight  : Integer = 75;
   BaseNodeWidth   : Integer = 120;
   BaseNodeSpace   : Integer = 10;
   BaseNodeVSpacing: Integer = 50;
   
type
  TIDSDiag = class;
  TIDSDiagItem = class(TObject)
    private
       FParent:TIDSDiag;
       FGroupNode:TGroupNode;
       procedure CentreCompName(Canvas:TCanvas;X,Y:Integer;CompName:String);
       procedure CentreCompTitle(Canvas:TCanvas;InRect:TRect;Title:String);
       procedure MenuBox(Canvas:TCanvas;InRect:TRect;Caption,Title:String);
       procedure FormBox(Canvas:TCanvas;InRect:TRect;Caption,Title:String);
       procedure FunctionBox(Canvas:TCanvas;InRect:TRect;Title:String);
       procedure DrawArrow(Canvas:TCanvas;X,Y,StartPointX,TurnPointY,BottomLine,ArrowH,ArrowW,FNumb:Integer);
    public       
       constructor Create(Parent:TIDSDiag;GroupNode:TGroupNode);
       procedure Draw(Canvas:TCanvas;X,Y:Integer;Translator:ITranslate;ShowBMPS:Boolean);
       function Width:Integer;
       function Height:Integer;
  end;
  TIDSDiag = class(TObject)
    private
       FWidth:Integer;
			 FHeight:Integer;
			 FNodeHeight       :Integer;
			 FNodeWidth        :Integer;
			 FNodeSpace        :Integer;
			 FNodeVSpacing     :Integer;
			 List:TList;
		public
			 Parser:TParser;
			 constructor Create(FileName:String);
			 destructor Destroy; override;
			 procedure Draw(Canvas:TCanvas;Translator:ITranslate;ShowBMPS:Boolean);
			 procedure Print(Translator:ITranslate;ShowBMPS:Boolean);
			 function DrawTDS(ProdName:String; var BitMap:TBitMap):String;
			 procedure CreateMetaFiles(Title:String;Font:TFont;Translator:ITranslate;ShowBMPS:Boolean);
			 property Width       :Integer read FWidth        write FWidth       ;
			 property Height      :Integer read FHeight       write FHeight      ;
			 property NodeHeight  :Integer read FNodeHeight   write FNodeHeight  ;
			 property NodeWidth   :Integer read FNodeWidth    write FNodeWidth   ;
			 property NodeSpace   :Integer read FNodeSpace    write FNodeSpace   ;
			 property NodeVSpacing:Integer read FNodeVSpacing write FNodeVSpacing;
	end;
	TMainForm = class(TSavePosForm) //TSavePosForm
		OD: TOpenDialog;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Load1: TMenuItem;
    View1: TMenuItem;
    Domains1: TMenuItem;
    IDS: TMenuItem;
    TDS: TMenuItem;
    Print1: TMenuItem;
    Document1: TMenuItem;
    Domains2: TMenuItem;
    IDS1: TMenuItem;
    TDS1: TMenuItem;
    BuildOptions1: TMenuItem;
    Build1: TMenuItem;
    All1: TMenuItem;
    Changed1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Bitmaps1: TMenuItem;
    hrlp1: TMenuItem;
    PissOff1: TMenuItem;
    N4: TMenuItem;
    Products1: TMenuItem;
    Groups1: TMenuItem;
    LookUps1: TMenuItem;
    PickLists1: TMenuItem;
    UserGroups1: TMenuItem;
    WorkstationGroups1: TMenuItem;
    N5: TMenuItem;
    AcceptanceCriteria1: TMenuItem;
    N6: TMenuItem;
    UnRegReRegOnBuild1: TMenuItem;
    N7: TMenuItem;
    ComponentList1: TMenuItem;
    PLUList1: TMenuItem;
    Tools1: TMenuItem;
    LookupTester1: TMenuItem;
    UnRegReRegOnBuildRegServer1: TMenuItem;
    MainSplitter: TSplitter;
    BatchMenu: TMenuItem;
    UtilisationReport1: TMenuItem;
    HelpSkeleton1: TMenuItem;
    PageControl3: TPageControl;
    TabSheet1: TTabSheet;
    Panel2: TPanel;
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    PaintBox2: TPaintBox;
    Panel1: TPanel;
    BatchSplitter: TSplitter;
    CompListBox: TListBox;
    TopPanel: TPanel;
    CompTypeComboBox: TComboBox;
    BatchGroupBox: TGroupBox;
    BatchMemo: TMemo;
    TabSheet2: TTabSheet;
    Panel3: TPanel;
    StringGrid1: TStringGrid;
    PageControl1: TPageControl;
    Panel4: TPanel;
    ScrollBox2: TScrollBox;
    Panel5: TPanel;
    Splitter1: TSplitter;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    Memo1: TMemo;
    TabSheet4: TTabSheet;
    Memo2: TMemo;
    TabSheet5: TTabSheet;
    Memo3: TMemo;
    Panel8: TPanel;
    Panel7: TPanel;
    Button1: TButton;
    Panel6: TPanel;
    Panel9: TPanel;
    TabSheet6: TTabSheet;
    Memo4: TMemo;
    ListProductDescriptions1: TMenuItem;
    BuildReloadMenu: TMenuItem;
    N8: TMenuItem;
    DebugInfoinBinaries1: TMenuItem;
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox2Paint(Sender: TObject);
    procedure CompListBoxClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IDS1Click(Sender: TObject);
    procedure TDS1Click(Sender: TObject);
    procedure Domains2Click(Sender: TObject);
    procedure BuildOptions1Click(Sender: TObject);
    procedure Domains1Click(Sender: TObject);
    procedure IDSClick(Sender: TObject);
    procedure TDSClick(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure All1Click(Sender: TObject);
    procedure Bitmaps1Click(Sender: TObject);
    procedure CompTypeComboBoxChange(Sender: TObject);
    procedure AcceptanceCriteria1Click(Sender: TObject);
    procedure UnRegReRegOnBuild1Click(Sender: TObject);
    procedure PissOff1Click(Sender: TObject);
    procedure ComponentList1Click(Sender: TObject);
    procedure Groups1Click(Sender: TObject);
    procedure PLUList1Click(Sender: TObject);
    procedure LookupTester1Click(Sender: TObject);
    procedure UnRegReRegOnBuildRegServer1Click(Sender: TObject);
    procedure BatchMemoDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure BatchMemoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure BatchMemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BatchMenuClick(Sender: TObject);
    procedure UtilisationReport1Click(Sender: TObject);
    procedure HelpSkeleton1Click(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGrid1SelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure ListProductDescriptions1Click(Sender: TObject);
    procedure BuildReloadMenuClick(Sender: TObject);
    procedure DebugInfoinBinaries1Click(Sender: TObject);
  private
    procedure SubProductClick(Sender: TObject);
  public
     IDSDiag:TIDSDiag;
     Translator:ITranslate;
     SubGroupToBuild:String;
     GDrawNode:TGroupDrawNode;
     PDrawNode:TProductDrawNode;
     SelectedNode:TNode; 
     procedure EmptyScrollBox;
     procedure LoadProject;
     procedure ProdDrawItem    (Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
     procedure GroupDrawItem   (Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
     procedure DomainDrawItem  (Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
     procedure OtherDrawItem   (Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
     procedure GroupListBoxDblClick(Sender: TObject);
     procedure ProductListBoxDblClick(Sender: TObject);
     procedure SelectItem(Sender: TObject);
     procedure ReParse(Sender: TObject);
  end;     

var
  MainForm: TMainForm;
  ProdPC:TPageControl;
  ProdSG:TStringGrid;

implementation

uses DomainsFU, BuilderFU, CompListFormFU, LookTestFU;

{$R *.DFM}

procedure TMainForm.EmptyScrollBox;
var
   Control:TControl;
begin
   while ScrollBox2.ControlCount > 0 do
   begin
      Control:=ScrollBox2.Controls[0];
      ScrollBox2.RemoveControl(Control);
      Control.Free;
   end;
end;
procedure TMainForm.ProdDrawItem(Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
var
   LB:TListBox;
   Node:TProdNode;
   R:TRect;
   H:Integer;
begin
   LB:=(Control as TListBox);
   Node:=TProdNode(LB.Items.Objects[Index]);
   if Node = nil then Exit;
   with LB.Canvas do
   begin
      R:=Rect;
      InflateRect(R,-2,-2);
      PaintButton(R,LB.Canvas,Brush.Color);
      Brush.Style:=bsClear;
      BrushCopy(Bounds(R.Left+2,R.Top+2,37,25),Node.Image,Bounds(0,0,Node.Image.Width,Node.Image.Height),Node.Image.Canvas.Pixels[0,0]);
      R.Left:=R.Left+41;
      H:=CentreTextH(LB.Canvas,R,Node.Title);
      OffsetRect(R,0,H);
      CentreTextH(LB.Canvas,R,Node.NodeName);
      Brush.Style:=bsSolid;
   end;
end;

procedure TMainForm.GroupDrawItem(Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
var
   LB:TListBox;
   Node:TGroupNode;
   R:TRect;
   H:Integer;
begin
   LB:=(Control as TListBox);
   Node:=TGroupNode(LB.Items.Objects[Index]);
   if Node = nil then Exit;
   with LB.Canvas do
   begin
      R:=Rect;
      InflateRect(R,-2,-2);
      PaintButton(R,LB.Canvas,Brush.Color);
      Brush.Style:=bsClear;
      BrushCopy(Bounds(R.Left+2,R.Top+2,37,25),Node.Image,Bounds(0,0,Node.Image.Width,Node.Image.Height),Node.Image.Canvas.Pixels[0,0]);
      R.Left:=R.Left+41;
      H:=CentreTextH(LB.Canvas,R,Node.Title);
      OffsetRect(R,0,H);
      CentreTextH(LB.Canvas,R,Node.NodeName);
      Brush.Style:=bsSolid;
   end;
end;

procedure TMainForm.DomainDrawItem(Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
var
   LB:TListBox;
   Node:TDomainNode;
   R:TRect;
   H:Integer;
begin
   LB:=(Control as TListBox);
   Node:=TDomainNode(LB.Items.Objects[Index]);
   if Node = nil then Exit;
   with LB.Canvas do
   begin
      FillRect(Rect);
      with Rect do R:=Classes.Rect(Left,Top,Right,Bottom);
      OffsetRect(R,0,TextHeight('Wg') div 2);
      R.Bottom:=R.Top+TextHeight(Node.NodeName);
      H:=CentreTextH(LB.Canvas,R,Node.NodeName);
      OffsetRect(R,0,H);
      CentreTextH(LB.Canvas,R,Node.Title);
   end;
end;
procedure TMainForm.OtherDrawItem(Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
var
   LB:TListBox;
   Node:TDomainNode;
   R:TRect;
begin
   LB:=(Control as TListBox);
   Node:=TDomainNode(LB.Items.Objects[Index]);
   if Node = nil then Exit;
   with LB.Canvas do
   begin
      FillRect(Rect);
      with Rect do R:=Classes.Rect(Left,Top,Right,Bottom);
      OffsetRect(R,0,TextHeight('Wg') div 2);
      R.Bottom:=R.Top+TextHeight(Node.NodeName);
      CentreTextH(LB.Canvas,R,Node.NodeName);
   end;
end;
procedure TMainForm.GroupListBoxDblClick(Sender: TObject);
var
   LB:TListBox;
   Node:TGroupNode;
begin
   LB:=(Sender as TListBox);
   Node:=TGroupNode(LB.Items.Objects[LB.ItemIndex]);
   if Node = nil then Exit;
   EmptyScrollBox;
   GDrawNode:=TGroupDrawNode.Create(nil);
   GDrawNode.Visible:=True;
   ScrollBox2.InsertControl(GDrawNode);
   GDrawNode.Left:=10;
   GDrawNode.Top:=10;
   GDrawNode.Caption:=Node.Title;
   GDrawNode.SetNode(Node);
   GDrawNode.AddNodes(IDSDiag.Parser);
end;
procedure TMainForm.ProductListBoxDblClick(Sender: TObject);
var
   LB:TListBox;
   Node:TProdNode;
begin
   LB:=(Sender as TListBox);
   Node:=TProdNode(LB.Items.Objects[LB.ItemIndex]);
   if Node = nil then Exit;
   EmptyScrollBox;
   PDrawNode:=TProductDrawNode.Create(nil);
   PDrawNode.Visible:=True;
   ScrollBox2.InsertControl(PDrawNode);
   PDrawNode.Left:=10;
   PDrawNode.Top:=10;
   PDrawNode.Caption:=Node.Title;
   PDrawNode.SetNode(Node);
   PDrawNode.AddNodes(IDSDiag.Parser);
end;
function LineOffsetInChars(Buffer:String;LineNo:Integer):Integer;
var
   P:PChar;
   CurrLine:Integer;
begin
   P:=PChar(Buffer);
   CurrLine:=1;
   while (P^ <> #0) and (CurrLine < LineNo) do
   begin
      if P^ = #10 then Inc(CurrLine);
      Inc(P);
   end;
   Result:=P-PChar(Buffer);
end;
procedure TMainForm.SelectItem(Sender: TObject);
var
   LB:TListBox;
   Node:TNode;
   S:String;
   I:Integer;
begin
   LB:=(Sender as TListBox);
   Node:=TNode(LB.Items.Objects[LB.ItemIndex]);
   SelectedNode:=Node;
   if Node = nil then Exit;
   Panel6.Caption:=Node.FileName;
   Panel9.Caption:=IntToStr(Node.LineNo);
   if Node.Modified then
      S:=Node.ModText
   else
      SetString(S,Node.DPtr,Node.EndDPtr-Node.DPtr);
   Memo1.Text:=S;
   Memo2.Lines.BeginUpdate;
   Memo2.Text:=Node.AsString;
   for I:=0 to Memo2.Lines.Count-1 do
      Memo2.Lines[I]:='  '+Memo2.Lines[I];
   Memo2.Lines.Insert(0,Node.NodeName+' {');
   Memo2.Lines.Add('}');
   Memo2.Lines.EndUpdate;
   Memo3.Lines.LoadFromFile(Panel6.Caption);
   Memo3.SelStart:=LineOffsetInChars(Memo3.Text,Node.LineNo);
   Memo3.SelLength:=Node.EndDPtr-Node.DPtr;
   Memo3.SelStart:=LineOffsetInChars(Memo3.Text,Node.LineNo)+Node.EndDPtr-Node.DPtr;
   Memo3.SelLength:=0-(Node.EndDPtr-Node.DPtr);
   Memo4.Text:=TextBuffer;
//   Memo5.Text:=IDSDiag.Parser.Nodes.AsObject;
   Memo1.OnExit:=ReParse;
end;
procedure TMainForm.ReParse(Sender: TObject);
var
   P:PChar;
   S:String;
begin
   if SelectedNode.Modified then
      S:=SelectedNode.ModText
   else
      SetString(S,SelectedNode.DPtr,SelectedNode.EndDPtr-SelectedNode.DPtr);
   if S <> Memo1.Text then
   begin
     SelectedNode.Modified:=True;
     SelectedNode.ModText:=Memo1.Text;
     P:=PChar(SelectedNode.ModText);
     IDSDiag.Parser.ReParseNode(SelectedNode,P);
   end;
end;

function DoubleAmpersand(Value:String):String;
var
   I:Integer;
begin
   Result:='';
   for I:=1 to Length(Value) do
      if Value[I] = '&' then
         Result:=Result+'&&'
      else
         Result:=Result+Value[I];
end;      
procedure TDSBox(Canvas:TCanvas;InRect:TRect;ActionActor:String;WithArrowIn:Boolean;Translator:ITranslate);
var
   MPH:Integer;
   Corner:Integer;
   AA:TStringList;
   Action,Actor:String;
begin
   AA:=TStringList.Create;
   AA.CommaText:=DoubleAmpersand(ActionActor);;
   if AA.Count > 0 then Action:=AA[0] else Action:='Select';
   if AA.Count > 1 then Actor :=AA[1] else Actor :='Dont Know';
   if (Translator <> nil) then
   begin
      Action:=Translator.Translate(Action);
      Actor:=Translator.Translate(Actor);
   end;
   
   with Canvas,InRect do
   begin
      if WithArrowIn then
      begin
         Corner:=(Bottom-Top) div 8;
         Brush.Color:=clBlack;
         Brush.Style:=bsSolid;
         PolyGon([Point(Left+(Right-Left) div 2,Top-BaseNodeVSpacing div 2),
                  Point(Left+(Right-Left) div 2,Top-1),
                  Point(Left+(Right-Left) div 2-Corner div 2,Top-Corner),
                  Point(Left+(Right-Left) div 2+Corner div 2,Top-Corner),
                  Point(Left+(Right-Left) div 2,Top-1)]);
      end;
      Corner:=(Bottom-Top) div 6;
      Font.Style:=[fsBold];
      Font.Name:='Arial';
      MPH:=(Bottom-Top) div 4;
      Font.Height:=0-(MPH*11) div 16;
      Brush.Color:=$00F0F0F0;
      RoundRect(Left,Top,Right,Bottom,Corner,Corner);
      TextOut(Left+MPH div 8+1,Top+MPH div 8,Action);
      Inc(Top,MPH+2);
      Inc(Left,4);
      Dec(Right,4);
      Dec(Bottom,Corner div 2);
      Brush.Color:=clWhite;
      Rectangle(Left,Top,Right,Bottom);
      InflateRect(InRect,-1,-1);
      Font.Style:=[];
      DrawText(Canvas.Handle,PChar(Actor),Length(Actor),InRect,DT_CENTER or DT_WORDBREAK);
   end;
end;
procedure DrawTDSDiag(X,Y:Integer;Canvas:TCanvas;Nodes:String;Translator:ITranslate; var TitleDiagram : String; BitMap: TBitMap;
                      ShowBMPS: Boolean );
var
   SL:TStringList;
   CSL:TStringList;
   MaxYOfs,XOfs,YOfs:Integer;
   CentreLine,Columns:Integer;
   I,J:Integer;
   SelectNode,MainRoute,AltRoutes,Final:String;
begin
  try
   SL:=TStringList.Create;
   CSL:=TStringList.Create;
   SL.CommaText:=Nodes;
   if SL.Count > 0 then SelectNode:=SL[0] else Exit;
   if SL.Count > 1 then MainRoute :=SL[1] else begin CSL.Add('"Input","Weight"'); MainRoute:=CSL.CommaText; CSL.Clear; end;
   if SL.Count > 2 then AltRoutes :=SL[2] else AltRoutes :='';
   if SL.Count > 3 then Final     :=SL[3] else Final:=''; // begin CSL.Add('"Select","Complete"'); Final:=CSL.CommaText; CSL.Clear; end;

   Canvas.Font.Style:=[fsBold];
   Canvas.Font.Name:='Arial';
   SL.CommaText:=SelectNode;
   If Sl.Count > 0 then
   begin
     I:=Canvas.Font.Size;
     Canvas.Font.Size:=20;
     TitleDiagram := Trim(SL[1]) ;
     // Canvas.TextOut(X,Y,Trim(SL[1])); // Title -----------------
     Inc(Y,Canvas.TextHeight(Trim(SL[1]))*2);
     Canvas.Font.Size:=I;
     Canvas.Font.Style:=[];

     SL.CommaText:=AltRoutes;
     YOfs:=Y;
     Columns:=SL.Count+1;
     CentreLine:=X+(((Columns*(BaseNodeWidth+BaseNodeSpace))-BaseNodeSpace) div 2)-BaseNodeWidth div 2;
     TDSBox(Canvas,Bounds(CentreLine,YOfs,BaseNodeWidth,BaseNodeHeight),SelectNode,False,Translator);

     if (ShowBMPS) and (BitMap <> nil )then
     begin
        PlacePictAt(Canvas,Bounds(  CentreLine + BaseNodeWidth+ (BaseNodeWidth Div 4) ,YOfs+(BaseNodeWidth Div 6), BaseNodeWidth Div 2 ,BaseNodeWidth Div 3),BitMap,clWhite);
     end;

     if Columns > 1 then
     begin
        Canvas.PolyLine([Point(CentreLine+BaseNodeWidth div 2,Y+BaseNodeHeight),
                         Point(CentreLine+BaseNodeWidth div 2,Y+BaseNodeHeight+BaseNodeVSpacing div 2)]);
        Canvas.Pen.Width:=(BaseNodeHeight div 16);
        Canvas.PolyLine([Point(X+BaseNodeWidth div 2-(BaseNodeHeight div 4),Y+BaseNodeHeight+BaseNodeVSpacing div 2),
                         Point(X+((Columns*(BaseNodeWidth+BaseNodeSpace))-BaseNodeSpace)-BaseNodeWidth div 2+(BaseNodeHeight div 4),Y+BaseNodeHeight+BaseNodeVSpacing div 2)]);
        Canvas.Pen.Width:=1;
     end;
     MaxYOfs:=Y;
     for I:=0 to Columns-1 do
     begin
        if I = 0 then
           CSL.CommaText:=MainRoute
        else
           CSL.CommaText:=SL[I-1];
        YOfs:=Y+(BaseNodeHeight+BaseNodeVSpacing div 2)*CSL.Count+1;
        if MaxYOfs < YOfs then MaxYOfs:=YOfs;
     end;
     Inc(MaxYOfs,BaseNodeHeight+(BaseNodeVSpacing div 2)-3);
     if Columns > 1 then
        Inc(MaxYOfs,BaseNodeVSpacing div 2);
     Canvas.Brush.Color:=clBlack;
     Canvas.Brush.Style:=bsSolid;
     if Columns > 1 then
     begin
        for I:=0 to Columns-1 do
        begin
           XOfs:=X+(BaseNodeWidth+BaseNodeSpace)*I+BaseNodeWidth div 2;
           Canvas.PolyGon([Point(XOfs,Y+BaseNodeHeight+BaseNodeVSpacing div 2),
                           Point(XOfs,MaxYOfs),
                           Point(XOfs+BaseNodeHeight div 16,MaxYOfs-BaseNodeHeight div 8),
                           Point(XOfs-BaseNodeHeight div 16,MaxYOfs-BaseNodeHeight div 8),
                           Point(XOfs,MaxYOfs)]);
        end;
     end;
     Canvas.Brush.Color:=clWhite;
     MaxYOfs:=Y;
     XOfs:=X;
     for I:=0 to Columns-1 do
     begin
        YOfs:=Y+BaseNodeHeight+BaseNodeVSpacing div 2;
        if Columns > 1 then
           Inc(YOfs,BaseNodeVSpacing div 2);
        if I = 0 then
        begin
           CSL.CommaText:=MainRoute;
           for J:=0 to CSL.Count-1 do
           begin
              TDSBox(Canvas,Bounds(XOfs,YOfs,BaseNodeWidth,BaseNodeHeight),CSL[J],True,Translator);
              Inc(YOfs,BaseNodeHeight+BaseNodeVSpacing div 2);
           end;
        end
        else
        begin
           CSL.CommaText:=SL[I-1];
           for J:=0 to CSL.Count-1 do
           begin
              TDSBox(Canvas,Bounds(XOfs,YOfs,BaseNodeWidth,BaseNodeHeight),CSL[J],True,Translator);
              if J = 0 then
                 Canvas.Ellipse((XOfs+BaseNodeWidth div 2)-(BaseNodeHeight div 16),
                                (YOfs-BaseNodeVSpacing div 2)+(BaseNodeHeight div 32),
                                (XOfs+BaseNodeWidth div 2)+(BaseNodeHeight div 16)+1,
                                (YOfs-BaseNodeVSpacing div 2)+(BaseNodeHeight div 8)+(BaseNodeHeight div 32)+1);
              Inc(YOfs,BaseNodeHeight+BaseNodeVSpacing div 2);
           end;
        end;
        Inc(XOfs,BaseNodeWidth+BaseNodeSpace);
        if MaxYOfs < YOfs then MaxYOfs:=YOfs;
     end;
     YOfs:=MaxYOfs;
     if Columns > 1 then
     begin
        Canvas.Pen.Width:=(BaseNodeHeight div 16);
        Canvas.PolyLine([Point(X+BaseNodeWidth div 2-(BaseNodeHeight div 4),MaxYOfs),
                         Point(X+((Columns*(BaseNodeWidth+BaseNodeSpace))-BaseNodeSpace)-BaseNodeWidth div 2+(BaseNodeHeight div 4),MaxYOfs)]);
        Canvas.Pen.Width:=1;
        Inc(YOfs,BaseNodeVSpacing div 2);
     end;
     CSL.CommaText:=Final;
     for J:=0 to CSL.Count-1 do
     begin
        TDSBox(Canvas,Bounds(CentreLine,YOfs,BaseNodeWidth,BaseNodeHeight),CSL[J],True,Translator);
        Inc(YOfs,BaseNodeHeight+BaseNodeVSpacing div 2);
     end;
     CSL.Free;
     SL.Free;
   end; //if sl.count > 0
  except
  end;
end;
{TIDSDiagItem}
constructor TIDSDiagItem.Create(Parent:TIDSDiag;GroupNode:TGroupNode);
begin
   inherited Create;
   FParent:=Parent;
   FGroupNode:=GroupNode;
end;
procedure TIDSDiagItem.CentreCompName(Canvas:TCanvas;X,Y:Integer;CompName:String);
var
   S:String;
   I:Integer;
begin
   S:=CompName;
   for I:=1 to Length(CompName) do
   begin
      if CompName[I] = '.' then
      begin
         S:=Copy(CompName,I+1,Length(CompName));
         break;
      end;
   end;
   Canvas.Brush.Style:=bsClear;
   Canvas.TextOut(X-(Canvas.TextWidth(S) div 2),Y+1,S);
   Canvas.Brush.Style:=bsSolid;
end;
procedure TIDSDiagItem.CentreCompTitle(Canvas:TCanvas;InRect:TRect;Title:String);
begin
   with InRect do begin Inc(Left,3); Inc(Top); Dec(Right,3); Dec(Bottom); end;
   Canvas.Brush.Style:=bsClear;
   DrawText(Canvas.Handle,PChar(Title),Length(Title),InRect,DT_CENTER or DT_WORDBREAK);
   Canvas.Brush.Style:=bsSolid;
end;
procedure TIDSDiagItem.MenuBox(Canvas:TCanvas;InRect:TRect;Caption,Title:String);
var
   MPH:Integer;
begin
   with Canvas,InRect do
   begin
      MPH:=(Bottom-Top) div 4;
      PolyGon([Point(Left,Top+MPH),
                Point(Left+MPH,Top),
                Point(Right-MPH,Top),
                Point(Right,Top+MPH),
                Point(Right,Bottom-MPH),
                Point(Right-MPH,Bottom),
                Point(Left+MPH,Bottom),
                Point(Left,Bottom-MPH),
                Point(Left,Top+MPH)]);
      PolyLine([Point(Left,Top+MPH),Point(Right,Top+MPH)]);
      CentreCompName(Canvas,Left+(Right-Left) div 2,Top+1,Caption);
      Top:=Top+MPH+1;
      CentreCompTitle(Canvas,InRect,Title);
   end;
end;
procedure InsertPictureInWord(Width:Integer;Word:Variant;FileName:String;WithPageBreak:Boolean; TitleDiagram : String );
var
   Ratio : Double ;
   a:Integer;

begin
   if TitleDiagram <> '' then
   begin
      //Word.Selection.Style := Word.ActiveDocument.Styles('Heading 1') ;
      Word.Selection.TypeText( Text:= TitleDiagram );
      Word.Selection.ParagraphFormat.Alignment := 1 ;
      Word.Selection.MoveRight(Unit:=1,Count:=1); // de-select picture
      Word.Selection.TypeParagraph ;
   end ;
    Word.Selection.InlineShapes.AddPicture(FileName,False,True); // insert picture
    Word.Selection.MoveLeft(Unit:=1,Count:=1,Extend:=1); // Select Picture
    //Word.Selection.InlineShapes.Width :=62*Width; // Set width
    if TitleDiagram <> '' then
    begin
      Word.Selection.InlineShapes.item( Word.Selection.InlineShapes.Count ).Height :=
         4.1*Word.Selection.InlineShapes.item( Word.Selection.InlineShapes.Count ).Height ;
      Word.Selection.InlineShapes.item( Word.Selection.InlineShapes.Count ).Width := 62*Width; // Set width
    end
    else
    begin
       Ratio := ( Word.Selection.InlineShapes.item( Word.Selection.InlineShapes.Count ).Width /
                 Word.Selection.InlineShapes.item( Word.Selection.InlineShapes.Count ).Height );
       Word.Selection.InlineShapes.item( Word.Selection.InlineShapes.Count ).Width := 62*Width; // Set width
       a:=Trunc( (62*width) / Ratio ) ;
       Word.Selection.InlineShapes.item( Word.Selection.InlineShapes.Count ).Height := a;

     end ;


    // Word.Selection.ParagraphFormat.Alignment:=1;// Centre Picture on page
    // Word.Selection.Paragraphs.Item(Word.Selection.Paragraphs.Count ).Format.Alignment:=1;// Centre Picture on page
    Word.Selection.MoveRight(Unit:=1,Count:=1); // de-select picture
    Word.Selection.TypeParagraph;               // add line after picture
    if WithPageBreak then
    begin
       Word.Selection.InsertBreak(Type:=0);        // add page break
       Word.Selection.MoveLeft(Unit:=1,Count:=2);  // move back to picture
       Word.Selection.MoveLeft(Unit:=1,Count:=1,Extend:=1); // re-select picture
       Word.WordBasic.DrawDisassemblePicture; // dissassemble into component parts
       Sleep( 200 ) ;
       Word.Selection.ShapeRange.Group.Select; // group parts
       if TitleDiagram <> '' then
         Word.Selection.ShapeRange.Top := 20
       else
         Word.Selection.ShapeRange.Top := 35 ;
//      Word.Selection.ParagraphFormat.Alignment := 1 ;

       Word.Selection.ShapeRange.Left := -999995 ;
       Word.Selection.MoveRight(Unit:=1,Count:=2); // move to end of doc
       if TitleDiagram <> '' then
       begin
         Word.Selection.EndKey(Unit:=6);
//         Word.Selection.MoveDown(Unit:=6,Count:=1); // Move down Unit :7 -> one screen
//         Word.Selection.MoveRight(Unit:=1,Count:=2); // move to end of doc
       end ;
    end
    else
    begin
       Word.Selection.MoveLeft(Unit:=1,Count:=1);  // move back to picture
       Word.Selection.MoveLeft(Unit:=1,Count:=1,Extend:=1); // re-select picture
       Word.WordBasic.DrawDisassemblePicture; // dissassemble into component parts
       Sleep( 200 );
       Word.Selection.ShapeRange.Group.Select; // group parts
       if TitleDiagram <>'' then
         Word.Selection.ShapeRange.Top:=20
       else
         Word.Selection.ShapeRange.Top:=35;

       Word.Selection.ShapeRange.Left := -999995 ;
       Word.Selection.MoveRight(Unit:=1,Count:=1); // move to end of doc
       if TitleDiagram <> '' then
       begin
         Word.Selection.MoveDown(Unit:=7,Count:=1); // Move down Unit :7 -> one screen
         //Word.Selection.MoveRight(Unit:=1,Count:=2); // move to end of doc
       end ;

    end;
end;
procedure TIDSDiagItem.FormBox(Canvas:TCanvas;InRect:TRect;Caption,Title:String);
var
   MPH:Integer;
begin
   with Canvas,InRect do
   begin
      MPH:=(Bottom-Top) div 4;
      RoundRect(Left,Top,Right,Bottom,(Bottom-Top) div 6,(Bottom-Top) div 6);
      PolyLine([Point(Left,Top+MPH),Point(Right,Top+MPH)]);
      CentreCompName(Canvas,Left+(Right-Left) div 2,Top+1,Caption);
      Top:=Top+MPH+1;
      CentreCompTitle(Canvas,InRect,Title);
   end;
end;
procedure TIDSDiagItem.FunctionBox(Canvas:TCanvas;InRect:TRect;Title:String);
begin
   with Canvas,InRect do
   begin
      RoundRect(Left,Top,Right,Bottom-(Bottom-Top) div 4,(Bottom-Top) div 2,(Bottom-Top) div 2);
      CentreCompName(Canvas,Left+(Right-Left) div 2,Top+(Bottom-Top) div 4,Title);
   end;
end;
procedure TIDSDiagItem.DrawArrow(Canvas:TCanvas;X,Y,StartPointX,TurnPointY,BottomLine,ArrowH,ArrowW,FNumb:Integer);
var
  BC:TColor;
begin
   with Canvas do
   begin
      PolyLine([Point(StartPointX,Y),Point(StartPointX,TurnPointY),Point(X,TurnPointY),Point(X,BottomLine)]);
      BC:=Brush.Color;
      Brush.Color:=Pen.Color;
      PolyGon ([Point(X,BottomLine),Point(X+ArrowW div 2,BottomLine-ArrowH),
                Point(X-ArrowW div 2,BottomLine-ArrowH),Point(X,BottomLine)]);
      Brush.Color:=BC;
      Brush.Style:=bsClear;
      TextOut(X+ArrowW,BottomLine-(ArrowH+2),'F'+IntToStr(FNumb));
      Brush.Style:=bsSolid;
   end;   
end;
procedure TIDSDiagItem.Draw(Canvas:TCanvas;X,Y:Integer;Translator:ITranslate;ShowBMPS:Boolean);
var
   I,W:Integer;
   XOfs,YOfs:Integer;
   R:TRect;
   StartPointX:Integer;
   TurnPointY :Integer;
   Dest:TRect;
   Title:String;
begin
   with Canvas do
   begin
      XOfs:=X+Width div 2;
      YOfs:=Y;
      R:=Rect(XOfs-FParent.NodeWidth div 2,YOfs,XOfs+FParent.NodeWidth div 2,YOfs+FParent.NodeHeight);
      Title:=FGroupNode.Title;
      if (Translator <> nil) then Title:=Translator.Translate(Title);
      MenuBox(Canvas,R,FGroupNode.NodeName,Title);
      if (ShowBMPS) and (FGroupNode.Image <> nil) then
      begin
         W:=((R.Right-R.Left) * 1) div 3;
         Dest:=Bounds(R.Left+(((R.Right-R.Left)-W) div 2),(R.Bottom-(W*2) div 3)-1,W,(W*2) div 3);
         PlacePictAt(Canvas,Dest,FGroupNode.Image,clWhite);
      end;
      StartPointX:=XOfs-((FGroupNode.Count-1)*(FParent.NodeWidth div 15) div 2);
      TurnPointY :=(Y+FParent.NodeHeight+FParent.NodeVSpacing div 2)-(((FGroupNode.Count-1)*(FParent.NodeVSpacing div 8)) div 2);
      Inc(TurnPointY,FParent.NodeVSpacing div 8);
      XOfs:=X+FParent.NodeWidth div 2;
      Inc(YOfs,FParent.NodeHeight+FParent.NodeVSpacing);
      for I:=0 to FGroupNode.Count-1 do
      begin
         R:=Rect(XOfs-FParent.NodeWidth div 2,YOfs,XOfs+FParent.NodeWidth div 2,YOfs+FParent.NodeHeight);
         if (FGroupNode[I] = nil) then
         begin
            Title:=FGroupNode.Item[I];
            if (Translator <> nil) then 
               Title:=Title+' - '+Translator.Translate('Not Found');
            if Copy(FGroupNode.Item[I],1,6) = 'Group.' then
            begin
               Pen.Color:=clBlue;
               MenuBox(Canvas,R,Copy(FGroupNode.Item[I],7,999),Title);
            end
            else if Copy(FGroupNode.Item[I],1,8) = 'Product.' then
            begin
               Pen.Color:=clBlue;
               FormBox(Canvas,R,Copy(FGroupNode.Item[I],9,999),Title);
            end
            else
            begin
               FunctionBox(Canvas,R,FGroupNode.Item[I]);
            end;
         end
         else
         begin
            Title:=FGroupNode[I].Title;
            if (Translator <> nil) then Title:=Translator.Translate(Title);
            if FGroupNode[I] is TGroupNode then
               MenuBox(Canvas,R,FGroupNode.Item[I],Title)
            else
               FormBox(Canvas,R,FGroupNode.Item[I],Title);
            if (ShowBMPS) and (FGroupNode[I].Image <> nil) then
            begin
               W:=(R.Right-R.Left) div 3;
               Dest:=Bounds(R.Left+(((R.Right-R.Left)-W) div 2),(R.Bottom-(W*2) div 3)-1,W,(W*2) div 3);
               PlacePictAt(Canvas,Dest,FGroupNode[I].Image,clWhite);
            end;
         end;    
         Pen.Color:=clBlack;
         DrawArrow(Canvas,XOfs,Y+FParent.NodeHeight,StartPointX,TurnPointY,Y+FParent.NodeHeight+FParent.NodeVSpacing,FParent.NodeVSpacing div 3,FParent.NodeVSpacing div 6,I+1);
         Inc(StartPointX,FParent.NodeWidth div 15);
         Inc(XOfs,FParent.NodeWidth+FParent.NodeSpace);
         if XOfs <= StartPointX then
            Inc(TurnPointY,FParent.NodeVSpacing div 8)
         else
            if I <> (FGroupNode.Count div 2)-1 then Dec(TurnPointY,FParent.NodeVSpacing div 8)
      end;     
   end;     
end;
function TIDSDiagItem.Width:Integer;
begin
   Result:=(FGroupNode.Count*(FParent.NodeWidth+FParent.NodeSpace))-FParent.NodeSpace;
   if Result <= FParent.NodeWidth+FParent.NodeSpace then Result:=FParent.NodeWidth;
end;
function TIDSDiagItem.Height:Integer;
begin
   Result:=FParent.NodeVSpacing+FParent.NodeHeight*2;
end;

{TIDSDiag}
constructor TIDSDiag.Create(FileName:String);
var
   I:Integer;
   SL:TStringList;
   IDSDiagItem:TIDSDiagItem;
begin
   inherited Create;

   FNodeHeight   :=BaseNodeHeight  ;
   FNodeWidth    :=BaseNodeWidth   ;
   FNodeSpace    :=BaseNodeSpace   ;
   FNodeVSpacing :=BaseNodeVSpacing;

   List:=TList.Create;

   Parser:=TParser.Create(FileName);
   if Parser.Nodes.Groups = nil then Exit;
    Parser.Nodes.Products.Sort;
   IDSDiagItem:=nil;
   SL:=TStringList.Create;
   for I:=0 to Parser.Nodes.Groups.Count-1 do
   begin
      IDSDiagItem:=TIDSDiagItem.Create(Self,Parser.Nodes.Groups.Node[I]);
      if IDSDiagItem <> nil then
      begin
         List.Add(IDSDiagItem);
         if FWidth < IDSDiagItem.Width then FWidth:=IDSDiagItem.Width+10;
      end;
   end;
   if (IDSDiagItem <> nil) and (FHeight < Parser.Nodes.Groups.Count * IDSDiagItem.Height) then
      FHeight:=Parser.Nodes.Groups.Count*(IDSDiagItem.Height+NodeVSpacing);
   SL.Free;
end;
destructor TIDSDiag.Destroy;
begin
   Parser.Free;
   List.Free;
   inherited Destroy;
end;
procedure TIDSDiag.Draw(Canvas:TCanvas;Translator:ITranslate;ShowBMPS:Boolean);
var
   I:Integer;
   IDSDiag:TIDSDiagItem;
   YOfs:Integer;
begin        
   if List <> nil then
   begin
      YOfs:=0;
      Canvas.Font.Height:=0-(NodeHeight div 6);
      for I:=0 to List.Count-1 do
      begin
         IDSDiag:=List[I]; 
         IDSDiag.Draw(Canvas,(Width-IDSDiag.Width) div 2,YOfs,Translator,ShowBMPS);
         Inc(YOfs,IDSDiag.Height+NodeVSpacing);
      end;
   end;
end;
function TIDSDiag.DrawTDS(ProdName:String; var BitMap:TBitMap ):String;
var
   ProdNode:TProdNode;
   ProductsNode:TProductsNode;
   OptionNode:TProdNode;
   I,J:Integer;
   SL:TStringList;
   ISL:TStringList;
   Sel,Main,Alt,Final:String;
   TotalIn :String;
   Complete:Boolean;
begin
   SL:=TStringList.Create;
   ISL:=TStringList.Create;
   Complete:=False;
   TotalIn:='';
   ProductsNode:=Parser.Nodes.Products;
   if ProductsNode <> nil then
   begin
      ProdNode:=ProductsNode.GetItemByName(ProdName);
      if ProdNode <> nil then
      begin
         Sel:='"Select","'+ProdNode.Title+'"';
         BitMap := ProdNode.Image ;
         for I:=0 to ProdNode.Domains.Count-1 do
         begin
            if ProdNode.Domain[I] <> nil then
            begin
               ISL.Add('"'+ProdNode.Domain[I].Action+'","'+ProdNode.Domain[I].Title+'"');
               if ProdNode.Domain[I].TotalInDomain <> nil then
                  TotalIn:=ProdNode.Domain[I].TotalInDomain.Title;
            end;
         end;
         Main:=ISL.CommaText;

         ISL.Clear;
         for J:=0 to ProdNode.Count-1 do
         begin
            if ProdNode.Item[J] = 'Complete' then
            begin
               Complete:=True;
            end
            else if ProdNode[J] <> nil then
            begin
               ISL.Add('"Toggle","'+ProdNode[J].Title+'"');
               OptionNode:=ProdNode[J];
               for I:=0 to OptionNode.Domains.Count-1 do
               begin
                  if OptionNode.Domain[I] <> nil then
                  begin
                     ISL.Add('"'+OptionNode.Domain[I].Action+'","'+OptionNode.Domain[I].Title+'"');
                     if OptionNode.Domain[I].TotalInDomain <> nil then
                        TotalIn:=OptionNode.Domain[I].TotalInDomain.Title;
                  end;
               end;
            end;
            
            if ISL.Count > 0 then
               SL.Add(ISL.CommaText);
            ISL.Clear;
         end;
         Alt:=SL.CommaText;
      end;
   end;
   ISL.Clear;
   if TotalIn <> '' then
      ISL.Add('"Show","'+TotalIn+'"');
   if Complete then
      ISL.Add('"Select","Complete"');
   Final:=ISL.CommaText;

   ISL.Clear;
   ISL.Add(Sel);
   ISL.Add(Main);
   ISL.Add(Alt);
   ISL.Add(Final);
   Result:=ISL.CommaText;
   SL.Free;
   ISL.Free;  
end;                                           
{function TIDSDiag.DrawTDS(ProdName:String; var BitMap:TBitMap):String;
var
   ProdNode:TProdNode;
   ProductsNode:TProductsNode;
   OptionNode:TProdNode;
   I,J:Integer;
   SL:TStringList;
   ISL:TStringList;
   Sel,Main,Alt,Final:String;
   TotalIn :String;
   Complete:Boolean;
begin
   SL:=TStringList.Create;
   ISL:=TStringList.Create;
   Complete:=False;
   TotalIn:='';
   ProductsNode:=Parser.Nodes.Products;
   if ProductsNode <> nil then
   begin
      ProdNode:=ProductsNode.GetItemByName(ProdName);
      if ProdNode <> nil then
      begin
         Sel:='"Select","'+ProdNode.Title+'"';
         for I:=0 to ProdNode.Domains.Count-1 do
         begin
            if ProdNode.Domain[I] <> nil then
            begin
               ISL.Add('"'+ProdNode.Domain[I].Action+'","'+ProdNode.Domain[I].Title+'"');
               if ProdNode.Domain[I].TotalInDomain <> nil then
                  TotalIn:=ProdNode.Domain[I].TotalInDomain.Title;
            end;
         end;
         Main:=ISL.CommaText;

         ISL.Clear;
         for J:=0 to ProdNode.Count-1 do
         begin
            if ProdNode.Item[J] = 'Complete' then
            begin
               Complete:=True;
            end
            else if ProdNode[J] <> nil then
            begin
               ISL.Add('"Toggle","'+ProdNode[J].Title+'"');
               OptionNode:=ProdNode[J];
               for I:=0 to OptionNode.Domains.Count-1 do
               begin
                  if OptionNode.Domain[I] <> nil then
                  begin
                     ISL.Add('"'+OptionNode.Domain[I].Action+'","'+OptionNode.Domain[I].Title+'"');
                     if OptionNode.Domain[I].TotalInDomain <> nil then
                        TotalIn:=OptionNode.Domain[I].TotalInDomain.Title;
                  end;
               end;
            end;

            if ISL.Count > 0 then
               SL.Add(ISL.CommaText);
            ISL.Clear;
         end;
         Alt:=SL.CommaText;
      end;
   end;
   ISL.Clear;
   if TotalIn <> '' then
      ISL.Add('"Show","'+TotalIn+'"');
   if Complete then
      ISL.Add('"Select","Complete"');
   Final:=ISL.CommaText;

   ISL.Clear;
   ISL.Add(Sel);
   ISL.Add(Main);
   ISL.Add(Alt);
   ISL.Add(Final);
   Result:=ISL.CommaText;
   SL.Free;
   ISL.Free;
end; }
procedure TIDSDiag.Print(Translator:ITranslate;ShowBMPS:Boolean);
var
   I:Integer;
   IDSDiag:TIDSDiagItem;
   YOfs:Integer;
   Mag:Integer;
begin        
   Printer.Title:='IDS Diagrams';
   Printer.Orientation:=poLandscape;
   Printer.BeginDoc;
   Mag:=Printer.PageWidth div FWidth;
   FNodeHeight   :=BaseNodeHeight  *Mag;
   FNodeWidth    :=BaseNodeWidth   *Mag;
   FNodeSpace    :=BaseNodeSpace   *Mag;
   FNodeVSpacing :=BaseNodeVSpacing*Mag;
   
   if List <> nil then
   begin
      YOfs:=Printer.PageHeight div 8;
      Printer.Canvas.Font.Height:=0-(NodeHeight div 6);
      for I:=0 to List.Count-1 do
      begin
         IDSDiag:=List[I];
         IDSDiag.Draw(Printer.Canvas,(Printer.PageWidth-IDSDiag.Width) div 2,YOfs,Translator,ShowBMPS);
         Inc(YOfs,IDSDiag.Height+NodeVSpacing);
         if (I <> List.Count-1) and (YOfs+IDSDiag.Height > Printer.PageHeight) then
         begin
            Printer.NewPage;
            YOfs:=Printer.PageHeight div 8;
         end;               
      end;
   end;
   Printer.EndDoc;
   FNodeHeight   :=BaseNodeHeight  ;
   FNodeWidth    :=BaseNodeWidth   ;
   FNodeSpace    :=BaseNodeSpace   ;
   FNodeVSpacing :=BaseNodeVSpacing;
end;
procedure TIDSDiag.CreateMetaFiles(Title:String;Font:TFont;Translator:ITranslate;ShowBMPS:Boolean);
var
   Metafile:TMetafile;
   MFCanvas:TMetafileCanvas;
   IDSDiag:TIDSDiagItem;
   I:Integer;
   WB:Variant;
begin
   FNodeHeight   :=BaseNodeHeight  *10;
   FNodeWidth    :=BaseNodeWidth   *10;
   FNodeSpace    :=BaseNodeSpace   *10;
   FNodeVSpacing :=BaseNodeVSpacing*10;

   WB:=CreateOleObject('Word.Application');
   WB.Documents.Add;
   WB.Visible:=True;
   WB.ActiveDocument.PageSetup.Orientation:=1; // Landscape
   if List <> nil then
   begin
      for I:=0 to List.Count-1 do
      begin
         IDSDiag:=List[I];
         Metafile:=TMetafile.Create;
         Metafile.Width:=IDSDiag.Width+1;
         Metafile.Height:=IDSDiag.Height+2;
         MFCanvas:=TMetafileCanvas.Create(Metafile,0);
         MFCanvas.Font:=Font;
         MFCanvas.Font.Height:=0-(NodeHeight div 6);
         IDSDiag.Draw(MFCanvas,0,0,Translator,ShowBMPS);
         MFCanvas.Free;
         Metafile.SaveToFile(ExtractFilePath(ParamStr(0))+'\'+Title+' '+IDSDiag.FGroupNode.Title+' IDS.wmf');
         Sleep( 500 ) ;
         InsertPictureInWord(IDSDiag.FGroupNode.Count,WB,ExtractFilePath(ParamStr(0))+'\'+Title+' '+IDSDiag.FGroupNode.Title+' IDS.wmf',I < List.Count-1,'');
         Metafile.Free;
      end;
   end;
   WB.Visible:=True;
   WB:=UnAssigned;
   FNodeHeight   :=BaseNodeHeight  ;
   FNodeWidth    :=BaseNodeWidth   ;
   FNodeSpace    :=BaseNodeSpace   ;
   FNodeVSpacing :=BaseNodeVSpacing;
end;
procedure TMainForm.PaintBox1Paint(Sender: TObject);
begin
   if IDSDiag <> nil then
      IDSDiag.Draw(PaintBox1.Canvas,Translator,Bitmaps1.Checked);
end;

procedure TMainForm.LoadProject;
var
   PNode:TProdNode;
   ProdsNode:TProductsNode;
//   GroupsNode : TGroupsNode;
//   GroupNode  : TGroupNode;
   DNode:TDomainsNode;
   ONode:TOptionsNode;
   Index,J,I:Integer;
   MW:array[0..9] of Integer;
   DomNode:TDomainNode;
   Path:String;
   Name:String;
   MenuItem:TMenuItem;
   MenuIndex : Integer;
   SubMenuItem:TMenuItem;
   SortedDomainsSL : TStringList;
begin
  //assume last project required
  Path:=GetGPCSRegString('IDS','Initial Directory','E:\Bermuda\IDS');
  Name:=GetGPCSRegString('IDS','Initial File','Bermuda.IDS');
  if FileExists(Path+'\'+Name) then
  begin
    OD.InitialDir:=Path;
    ChDir(Path);
    OD.FileName  :=Name;
  end;

  //check for manual mode
  If FindParamIndex('batch') <= 0 then
  begin
    if OD.Execute then
    begin
      SetGPCSRegString('IDS','Initial Directory',ExtractFilePath(OD.FileName));
      SetGPCSRegString('IDS','Initial File',ExtractFileName(OD.FileName));
    end
    else
      Exit;  //not in batch mode with valid file or manual mode
  end;

  //get required project
  Path:=GetGPCSRegString('IDS','Initial Directory','E:\Bermuda\IDS');
  Name:=GetGPCSRegString('IDS','Initial File','Bermuda.IDS');
  Bitmaps1.Checked:=GetGPCSRegString('IDS','Show Bitmaps','N') = 'Y';
  UnRegReRegOnBuild1.Checked:=GetGPCSRegString('IDS','Un-ReReg On Build','N') = 'Y';
  UnRegReRegOnBuildRegServer1.Checked:=GetGPCSRegString('IDS','Un-ReReg On Build RegServer','N') = 'Y';
  BuildReloadMenu.Checked := GetGPCSRegString('IDS','Reload Before Build','N') = 'Y';
  DebugInfoinBinaries1.Checked := GetGPCSRegString('IDS','Debug Info In Binaries','N') = 'Y';
  If not FileExists(Path+'\'+Name) then Exit;

   if IDSDiag <> nil then IDSDiag.Free;
   IDSDiag:=nil;
   Waitform.SetBounds(Left + Trunc(0.5 * (Width-WaitForm.Width)),
                      Top  + Trunc(0.5 * (Height-WaitForm.Height)),
                      WaitForm.Width, Waitform.Height);
   WaitForm.WaitPanel.Caption := 'Loading ' + Path + Name;
   MainForm.Caption := 'IDS Parser - ' + Path +Name;
   WaitForm.Show;
   Waitform.Refresh;
   try
      IDSDiag:=TIDSDiag.Create(OD.FileName);
   except
   end;
   WaitForm.Hide;
   CompListBox.Clear;
   ProdsNode:=IDSDiag.Parser.Nodes.Products;
   if ProdsNode <> nil then
   begin
      for I:=0 to ProdsNode.Count-1 do
         CompListBox.Items.Add(ProdsNode.Name[I]);
   end;
   DNode:=IDSDiag.Parser.Nodes.Domains;
   if DNode <> nil then
   begin
      with DomainsForm do
      begin
         SG.ColCount:=9;
         SG.Cells[0,0]:='Name';
         SG.Cells[1,0]:='Title';
         SG.Cells[2,0]:='Format';
         SG.Cells[3,0]:='Action';
         SG.Cells[4,0]:='Prompt';
         SG.Cells[5,0]:='Hint';
         SG.Cells[6,0]:='Error';
         SG.Cells[7,0]:='Input From';
         SG.Cells[8,0]:='Total Into';
         SG.Cells[9,0]:='Locale';
         for J:=0 to 9 do
             MW[J]:=SG.Canvas.TextWidth(SG.Cells[J,0]);

         SG.RowCount:=DNode.Count+1;

          SortedDomainsSL := TStringList.Create;
          With TStringList.Create do
          begin
            try
              SortedDomainsSL.Sorted := True;
              for I:=0 to DNode.Count-1 do
              begin
                DomNode:=DNode.Node[I];

                //prepare new grid row
                Clear;
                Add(DomNode.NodeName);
                Add(DomNode.Title);
                Add(DomNode.Action);
                Add(DomNode.Format+'('+DomNode.FmtData+')');
                Add(DomNode.Prompt);
                Add(DomNode.Hint);
                Add(DomNode.Error);
                Add(DomNode.InputFrom);
                Add(DomNode.TotalIn);
                Add(DomNode.Locale);
                //record max col widths
                for J:=0 to 9 do
                   MW[J] := MaxIntValue([MW[J],SG.Canvas.TextWidth(Strings[J])]);
                SortedDomainsSL.Add(CommaText); //add this domain to list
              end;  //for all domains
              //add header
              SortedDomainsSL.Sorted := False;
              Clear;
              Add('Name');
              Add('Title');
              Add('Format');
              Add('Action');
              Add('Prompt');
              Add('Hint');
              Add('Error');
              Add('Input From');
              Add('Total Into');
              Add('Locale');

              SortedDomainsSL.Insert(0,CommaText); //insert header row
              CommaTextIntoGrid(SG, SortedDomainsSL.CommaText); //fill grid

            finally
              Free; //temp string list
              SortedDomainsSL.Free;
            end;
          end;  //with temp sl

          //adjust col widths
          for J:=0 to 9 do
            SG.ColWidths[J]:=MW[J]+5;
      end;
   end;
   ONode:=IDSDiag.Parser.Nodes.BuildOptions;
   if ONode <> nil then
   begin
      with Builder do
      begin
         Builder.BuildAll.Checked:=(ONode.BldAll = 'Y');
         Builder.CommandLine.Text:=ONode.CmdLine;
         Builder.OutEXEDir.Text:=ONode.EXEDir;
         Builder.OutDCUDir.Text:=ONode.DCUDir;
         Builder.OutPASDir.Text:=ONode.SrcDir;
         Builder.Aliases.Lines.Text:=ONode.Aliases.Text;
         Builder.InDCUDirs.Lines.Text:=ONode.LibPath.Text;
         Builder.InPASDirs.Lines.Text:=ONode.SrchPath.Text;
         Builder.Packages.Lines.Text:=ONode.Packages.Text;
      end;
   end;
   PaintBox1.Width:=IDSDiag.Width;
   PaintBox1.Height:=IDSDiag.Height;
   PaintBox2.Width:=1000;
   PaintBox2.Height:=1000;
   PaintBox2.Visible:=False;
   PaintBox1.Visible:=True;

{   //build groups menus
   GroupsNode:=IDSDiag.Parser.Nodes.Groups;
   If GroupsNode <> nil then
   begin
     //add 'All' Groups
     Groups1.Add(TMenuItem.Create(self));
     Groups1.Items[0].Caption := 'All';
     Groups1.Items[Groups1.Count-1].OnClick:=SubProductClick;
     For I := 0 to GroupsNode.Count -1 do
     begin
       //get a single group
       GroupNode := GroupsNode.Node[I];
       If not GroupNode.DontBuild then
       begin
         //find subgroup
         Index := -1; //index of subgroup
         For J := 0 to Groups1.Count -1 do
         begin
           If Groups1.Items[J].caption = GroupNode.SubGroup then
           begin
             Index := J;
             Break;
           end;
         end;

         //add subgroup if not found
         If Index = -1 then
         begin
           MenuItem:=TMenuItem.Create(nil);
           MenuItem.Caption:=GroupNode.SubGroup;
           Groups1.Add(MenuItem);
         end
         else
         begin
           MenuItem := Groups1.Items[Index];
         end;

         //add groups to subgroups
         MenuItem.Add(TMenuItem.Create(self));
         MenuItem.Items[MenuItem.Count-1].Caption := GroupsNode.Node[I].NodeName;
         MenuItem.Items[MenuItem.Count-1].OnClick:=SubProductClick;
       end;
     end;
  end;
}

   ProdsNode:=IDSDiag.Parser.Nodes.Products;
   while Products1.Count > 0 do Products1.Delete(0);
   if ProdsNode <> nil then
   begin
      for I:=0 to ProdsNode.Count-1 do
      begin
         PNode:=ProdsNode.Node[I];
         if not PNode.DontBuild then
         begin
            Index:=-1;
            for J:=0 to Products1.Count-1 do
            begin
               if Products1.Items[J].Caption = PNode.SubGroup then
               begin
                  Index:=J;
                  break;
               end;
            end;
            if Index = -1 then
            begin
              MenuItem:=TMenuItem.Create(nil);
              MenuItem.Caption:=PNode.SubGroup;
              //insert menu in alpha order
              If Products1.Count = 0 then //no product subgroups yet
              begin
               Products1.Add(MenuItem)
              end
              else  //some groups  - find correct place to insert
              begin
                For MenuIndex := 0 to Products1.Count -1 do
                begin
                  If Products1[MenuIndex].Caption > MenuItem.Caption then
                  begin
                    Products1.Insert(MenuIndex,MenuItem);
                    Break;
                  end;
                  //at end of list 
                  If (MenuIndex = Products1.Count-1)  then
                    Products1.Add(MenuItem);
                end;  //for all menu items
              end;  //if some product subgroups already exist
            end
            else
            begin
               MenuItem:=Products1.Items[Index];
            end;
            SubMenuItem:=TMenuItem.Create(nil);
            SubMenuItem.Caption:=PNode.NodeName;
            SubMenuItem.OnClick:=SubProductClick;
            MenuItem.Add(SubMenuItem);
         end;
      end;
      if Products1.Count > 1 then
      begin
         MenuItem:=TMenuItem.Create(nil);
         MenuItem.Caption:='All';
         MenuItem.OnClick:=SubProductClick;
         Products1.Insert(0,MenuItem);
         for I:=1 to Products1.Count-1 do
         begin
            MenuItem:=Products1[I];
            if MenuItem.Count > 1 then
            begin
               SubMenuItem:=TMenuItem.Create(nil);
               SubMenuItem.Caption:='All';
               SubMenuItem.OnClick:=SubProductClick;
               MenuItem.Insert(0,SubMenuItem);
            end;
         end;
      end
      else if Products1.Count = 1 then
      begin
         MenuItem:=Products1[0];
         if MenuItem.Count > 1 then
         begin
            SubMenuItem:=TMenuItem.Create(nil);
            SubMenuItem.Caption:='All';
            SubMenuItem.OnClick:=SubProductClick;
            MenuItem.Insert(0,SubMenuItem);
         end;
      end;
   end;
end;
procedure TMainForm.SubProductClick(Sender: TObject);
var
   MenuItem:TMenuItem;
   Parent:TMenuItem;
begin
   MenuItem:=(Sender as TMenuItem);
   Parent:=MenuItem.Parent;

   if MenuItem.Caption = 'All' then
   begin
      If Parent = Groups1 then
      begin
        All1Click(Groups1);
      end
      else if Parent = Products1 then
      begin
         All1Click(Products1);
      end
      else
      begin
         SubGroupToBuild:=Parent.Caption;
         All1Click(Products1);
         SubGroupToBuild:='';
      end;
   end
   else
   begin
      if Parent = Groups1 then
      begin
        SubGroupToBuild := MenuItem.Caption; //individual group
        All1Click(Groups1);
        SubGroupToBuild:='';
      end
      else
      begin
        SubGroupToBuild:='Product.'+MenuItem.Caption;
        All1Click(Products1);
        SubGroupToBuild:='';
      end;
   end;
end;
procedure TMainForm.PaintBox2Paint(Sender: TObject);
var
   TitleDiagram : String ;
   DrawTDSStr:String ;
   BitMapPrd:TBitMap ;
begin
   if (CompListBox.ItemIndex >= 0) and (CompListBox.ItemIndex < CompListBox.Items.Count) then
   begin
      DrawTDSStr := IDSDiag.DrawTDS( CompListBox.Items[CompListBox.ItemIndex], BitMapPrd );
      DrawTDSDiag(10,10,PaintBox2.Canvas,DrawTDSStr,Translator, TitleDiagram, BitMapPrd, BitMaps1.Checked );
   end;
end;

procedure TMainForm.CompListBoxClick(Sender: TObject);
begin
   if not PaintBox2.Visible then
      TDSClick(nil);
   PaintBox2.Refresh;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
	 I:Integer;
begin
	 BatchMemo.Lines.SaveToFile(ExtractFilePath(Application.EXEname) + '\IDSParseBatchList.txt');

	 IDSDiag.Free;
   if Translator <> nil then Translator.Save;
   Translator:=nil;
   
   PictureServer:=nil;
   if PictureList <> nil then
   begin
      for I:=0 to PictureList.Count-1 do
      begin
         if PictureList.Objects[I] <> nil then
            TBitmap(PictureList.Objects[I]).Free;
      end;
      PictureList.Free;
   end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Load1Click(Self);
//  LoadProject;
  If FindParamIndex('batch') > 0 then
  begin
    BatchMenuClick(Sender);
    Application.ProcessMessages;
    Builder.BringToFront;
	end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
	If FileExists(ExtractFilePath(Application.EXEname) + '\IDSParseBatchList.txt') then
		BatchMemo.Lines.LoadFromFile(ExtractFilePath(Application.EXEname) + '\IDSParseBatchList.txt');

	 try
//      Translator:=CreateTranslator;
	 except
	 end;
	 StringGrid1.RowCount:=4;
	 StringGrid1.ColCount:=3;
	 StringGrid1.DefaultColWidth :=(StringGrid1.Width -4) div StringGrid1.ColCount;
	 StringGrid1.DefaultRowHeight:=(StringGrid1.Height-4) div StringGrid1.RowCount;
	 StringGrid1.Width :=(StringGrid1.DefaultColWidth  * StringGrid1.ColCount)+4;
	 StringGrid1.Height:=(StringGrid1.DefaultRowHeight * StringGrid1.RowCount)+4;

	 StringGrid1.Cells[0,0]:='Groups';
	 StringGrid1.Cells[1,0]:='Products';
	 StringGrid1.Cells[2,0]:='Users';
	 StringGrid1.Cells[0,1]:='PickLists';
	 StringGrid1.Cells[1,1]:='LookUps';
	 StringGrid1.Cells[2,1]:='WorkStations';
	 StringGrid1.Cells[0,2]:='Domains';
	 StringGrid1.Cells[1,2]:='Snippets';
	 StringGrid1.Cells[2,2]:='Constants';
	 StringGrid1.Cells[0,3]:='LogFormats';
	 StringGrid1.Cells[1,3]:='BuildOptions';
	 StringGrid1.Cells[2,3]:='ProjectInfo';

end;

procedure TMainForm.IDS1Click(Sender: TObject);
var
	 AFont:TFont;
begin
	 AFont:=TFont.Create;
	 AFont.Assign(Font);
	 AFont.Name:='Arial';
	 if IDSDiag <> nil then
			IDSDiag.CreateMetaFiles('Bermuda',AFont,Translator,Bitmaps1.Checked);
	 AFont.Free;
end;

procedure TMainForm.TDS1Click(Sender: TObject);
var
   AFont:TFont;
   Metafile:TMetafile;
   MFCanvas:TMetafileCanvas;
   I:Integer;
   WB:Variant;
   FNodeHeight  :Integer;
   FNodeWidth   :Integer;
   FNodeSpace   :Integer;
   FNodeVSpacing:Integer;
   TitleDiagram : String ;
   DrawTDSStr:String ;
   BitMapPrd:TBitMap ;
begin
   AFont:=TFont.Create;
   AFont.Assign(Font);
   AFont.Name:='Arial';
   FNodeHeight   :=BaseNodeHeight  ;
   FNodeWidth    :=BaseNodeWidth   ;
   FNodeSpace    :=BaseNodeSpace   ;
   FNodeVSpacing :=BaseNodeVSpacing;
   BaseNodeHeight   :=FNodeHeight  *2;
   BaseNodeWidth    :=FNodeWidth   *2;
   BaseNodeSpace    :=FNodeSpace   *2;
   BaseNodeVSpacing :=FNodeVSpacing*2;

   WB:=CreateOleObject('Word.Application');
   WB.Documents.Add;
   WB.Visible:=True;
   WB.ActiveDocument.PageSetup.Orientation:=0; // Portrait
   for I:=0 to CompListBox.Items.Count-1 do
   begin
      Metafile:=TMetafile.Create;
      Metafile.Width:=750;
      Metafile.Height:=800;
      MFCanvas:=TMetafileCanvas.Create(Metafile,0);
      MFCanvas.Font:=Font;
      MFCanvas.Font.Height:=0-(BaseNodeHeight div 6);
      DrawTDSStr := IDSDiag.DrawTDS(CompListBox.Items[I], BitMapPrd );
      DrawTDSDiag(0,0,MFCanvas,DrawTDSStr,Translator, TitleDiagram, BitMapPrd, BitMaps1.Checked );
      MFCanvas.Free;
      Metafile.SaveToFile(ExtractFilePath(ParamStr(0))+'\'+'Bermuda '+CompListBox.Items[I]+' TDS.wmf');
      InsertPictureInWord(4,WB,ExtractFilePath(ParamStr(0))+'\'+'Bermuda '+CompListBox.Items[I]+' TDS.wmf',I < CompListBox.Items.Count-1, TitleDiagram );
      Metafile.Free;
   end;
   WB.Visible:=True;
   WB:=UnAssigned;
   BaseNodeHeight   :=FNodeHeight  ;
   BaseNodeWidth    :=FNodeWidth   ;
   BaseNodeSpace    :=FNodeSpace   ;
   BaseNodeVSpacing :=FNodeVSpacing;
   AFont.Free;
end;

procedure TMainForm.Domains2Click(Sender: TObject);
var
   WB:Variant;
   I,J:Integer;
begin
   WB:=CreateOleObject('Word.Application');
   WB.Documents.Add;
   WB.Visible:=True;
   WB.ActiveDocument.PageSetup.Orientation :=0; // LandScape
   for I:=1 to DomainsForm.SG.RowCount-1 do
   begin
      if (I mod 4 = 1) and (I <> 1) then
           WB.Selection.InsertBreak(Type:=0); // page break
      WB.ActiveDocument.Tables.Add(Range:=WB.Selection.Range,NumRows:=7,NumColumns:=2);

      WB.Selection.SelectColumn;
      WB.Selection.Font.Size:=14;
      WB.Selection.Font.Bold:=9999998; // wdToggle
      WB.Selection.ParagraphFormat.Alignment:=2; // wdAlignParagraphRight
      WB.Selection.MoveRight(Unit:=1,Count:=1); // 1 = wdCharacter
      WB.Selection.SelectColumn;
      WB.Selection.Font.Size:=14;
      WB.Selection.MoveLeft(Unit:=1,Count:=1); // 1 = wdCharacter
      WB.Selection.SelectRow;
      WB.Selection.Font.Bold:=9999998; // wdToggle
      WB.Selection.Font.Bold:=9999998; // wdToggle
      WB.Selection.MoveLeft(Unit:=1,Count:=1); // 1 = wdCharacter

      WB.Selection.TypeText('Name');
      WB.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine
      WB.Selection.TypeText('Title');
      WB.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine
      WB.Selection.TypeText('Format');
      WB.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine
      WB.Selection.TypeText('Action');
      WB.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine
      WB.Selection.TypeText('Prompt');
      WB.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine
      WB.Selection.TypeText('Hint');
      WB.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine
      WB.Selection.TypeText('Error');
      WB.Selection.MoveUp(Unit:=5,Count:=6); // 5=wdLine
      WB.Selection.SelectColumn;
      WB.Selection.Cells.AutoFit;
      WB.Selection.MoveLeft(Unit:=1,Count:=1); // 1 = wdCharacter
      WB.Selection.SelectRow;
      WB.Selection.Font.Bold:=9999998; // wdToggle
      WB.Selection.Font.Bold:=9999998; // wdToggle
      WB.Selection.MoveLeft(Unit:=1,Count:=1); // 1 = wdCharacter
      WB.Selection.MoveRight(Unit:=12); // 12 = wdCell
      for J:=0 to 6 do
      begin
         WB.Selection.TypeText(DomainsForm.SG.Cells[J,I]);
         if J <> 6 then
            WB.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine
      end;
      WB.Selection.SelectColumn;
      WB.Selection.Cells.AutoFit;
      WB.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine

      WB.Selection.TypeParagraph;
      WB.Selection.TypeParagraph;
   end;
   WB.Visible:=True;
   WB:=Unassigned;
end;

procedure TMainForm.BuildOptions1Click(Sender: TObject);
begin
   Builder.Show;
   Builder.PageControl1.ActivePage:=Builder.BuildOptions;
end;

procedure TMainForm.Domains1Click(Sender: TObject);
begin
   DomainsForm.Show;
end;

procedure TMainForm.IDSClick(Sender: TObject);
begin
   if not PaintBox1.Visible then
   begin
      PaintBox2.Visible:=False;
      PaintBox1.Visible:=True;
      ScrollBox1.HorzScrollBar.Position:=0;
      ScrollBox1.VertScrollBar.Position:=0;
   end;                        
end;

procedure TMainForm.TDSClick(Sender: TObject);
begin
   if not PaintBox2.Visible then
   begin
      PaintBox2.Visible:=True;
      PaintBox1.Visible:=False;
      if (CompListBox.ItemIndex < 0) and (CompListBox.Items.Count > 0) then 
         CompListBox.ItemIndex:=0;
      ScrollBox1.HorzScrollBar.Position:=0;
      ScrollBox1.VertScrollBar.Position:=0;
   end;                        
end;

procedure TMainForm.Load1Click(Sender: TObject);
var
   I,J:Integer;
   TabSheet:TTabSheet;
   ListBox:TListBox;
   Node:TNode;
   SL:TStringList;
   SSL:TStringList;
   PNode:TProdNode;
   PageIndex:Integer;
   B:Boolean;
   Comp:TComponent;
begin
   while PageControl1.ComponentCount > 0 do
   begin
      Comp:=PageControl1.Components[0];
      PageControl1.RemoveComponent(Comp);
      Comp.Free;
   end;
   EmptyScrollBox;
   LoadProject;
   SL:=TStringList.Create;
   if IDSDiag = nil then Exit;
   if IDSDiag.Parser = nil then Exit;
   if IDSDiag.Parser.Nodes = nil then Exit;
   for I:=0 to IDSDiag.Parser.Nodes.Count-1 do
   begin
      if Trim(IDSDiag.Parser.Nodes.Name[I]) <> '' then
         SL.Add(Trim(IDSDiag.Parser.Nodes.Name[I]));
   end;
   SL.Sort;
   for I:=0 to SL.Count-1 do
   begin
      TabSheet:=TTabSheet.Create(PageControl1);
      TabSheet.TabVisible:=False;
      TabSheet.PageControl:=PageControl1;
      TabSheet.Name:='TS'+SL[I];
      TabSheet.Caption:=SL[I];
      Node:=IDSDiag.Parser.Nodes.SelectNode(SL[I]);
      if Node <> IDSDiag.Parser.Nodes then
      begin
         if Node is TProductsNode then
         begin
            SSL:=TStringList.Create;
            ProdPC:=TPageControl.Create(TabSheet);
            TabSheet.InsertControl(ProdPC);
            ProdSG:=TStringGrid.Create(TabSheet);
            TabSheet.InsertControl(ProdSG);
            ProdSG.Align:=alBottom;
            ProdSG.BorderStyle := bsNone;
            ProdSG.Color := clBtnFace;
            ProdSG.DefaultColWidth := 120;
            ProdSG.DefaultRowHeight := 16;
            ProdSG.DefaultDrawing := False;
            ProdSG.FixedCols := 0;
            ProdSG.FixedRows := 0;
            ProdSG.Options := [goVertLine, goHorzLine, goRangeSelect];
            ProdSG.ScrollBars := ssNone;
            ProdSG.OnDrawCell := StringGrid1DrawCell;
            ProdSG.OnSelectCell := StringGrid1SelectCell;

            ProdPC.Align:=alClient;
            ProdSG.RowCount:=50;
            ProdSG.ColCount:=2;

//            PageControl.MultiLine:=True;
            for J:=0 to Node.Count-1 do
            begin
               PNode:=Node[J] as TProdNode;
               if PNode.DontBuild then PNode.SubGroup:='Don''t Build';
               PageIndex:=SSL.IndexOf(PNode.SubGroup);
               if PageIndex = -1 then
               begin
                  TabSheet:=TTabSheet.Create(ProdPC);
                  TabSheet.PageControl:=ProdPC;
                  TabSheet.TabVisible:=False;
                  TabSheet.Name:='PTS'+IntToStr(J);
                  TabSheet.Caption:=PNode.SubGroup;
                  ListBox:=TListBox.Create(TabSheet);
                  TabSheet.InsertControl(ListBox);
                  ListBox.Sorted:=True;
                  ListBox.DragMode:=dmAutomatic;
                  ListBox.Align:=alClient;
                  ListBox.MultiSelect:=True;
                  SSL.AddObject(PNode.SubGroup,TabSheet);
                  ListBox.ItemHeight:=ListBox.Canvas.TextHeight('Wg')*3;
                  ListBox.OnDrawItem:=ProdDrawItem    ;
                  ListBox.Style     :=lbOwnerDrawFixed;
                  ListBox.OnDblClick:=ProductListBoxDblClick;
                  ListBox.OnClick   :=SelectItem;
               end
               else
               begin
                  TabSheet:=ProdPC.Pages[PageIndex];
                  ListBox:=TabSheet.Components[0] as TListBox;
               end;
               ListBox.Items.AddObject(TProdNode(Node[J]).Title,Node[J]);
            end;
            ProdSG.RowCount:=(ProdPC.PageCount div 2);
            if ((ProdSG.RowCount*2) <> ProdPC.PageCount) then
               ProdSG.RowCount:=ProdSG.RowCount+1;
            ProdSG.Height:=ProdSG.DefaultRowHeight*ProdSG.RowCount+8;
            ProdSG.DefaultColWidth :=(PageControl1.Width-8) div ProdSG.ColCount;
            ProdSG.DefaultRowHeight:=(ProdSG.Height-6) div ProdSG.RowCount;
            SSL.Sort;
            for J:=0 to SSL.Count-1 do
            begin
               ProdSG.Cells[J mod 2,J div 2]:=SSL[J];
            end;
            ProdSG.Invalidate;
            SSL.Free;
         end
         else
         begin
            ListBox:=TListBox.Create(TabSheet);
            TabSheet.InsertControl(ListBox);
            ListBox.Sorted:=True;
            ListBox.DragMode:=dmAutomatic;
            ListBox.Align:=alClient;
            ListBox.MultiSelect:=True;
            if Node is TGroupsNode then
            begin
               ListBox.ItemHeight:=ListBox.Canvas.TextHeight('Wg')*3;
               ListBox.OnDrawItem:=GroupDrawItem   ;
               ListBox.Style     :=lbOwnerDrawFixed;
               ListBox.OnDblClick:=GroupListBoxDblClick;
               ListBox.OnClick   :=SelectItem;
               for J:=0 to Node.Count-1 do
                  ListBox.Items.AddObject(TGroupNode(Node[J]).Title,Node[J]);
            end
            else if Node is TDomainsNode then
            begin
               ListBox.ItemHeight:=ListBox.Canvas.TextHeight('Wg')*3;
               ListBox.OnDrawItem:=DomainDrawItem  ;
               ListBox.Style     :=lbOwnerDrawFixed;
               ListBox.OnClick   :=SelectItem;
               for J:=0 to Node.Count-1 do
                  ListBox.Items.AddObject(Node[J].NodeName,Node[J]);
            end
            else
            begin
               ListBox.ItemHeight:=ListBox.Canvas.TextHeight('Wg')*2;
               ListBox.OnDrawItem:=OtherDrawItem  ;
               ListBox.Style     :=lbOwnerDrawFixed;
               ListBox.OnClick   :=SelectItem;
               for J:=0 to Node.Count-1 do
                  ListBox.Items.AddObject(Node[J].NodeName,Node[J]);
            end;
         end;
      end;
   end;
   SL.Free;
   StringGrid1SelectCell(StringGrid1,0,0,B);
   StringGrid1SelectCell(ProdSG,0,0,B);
end;

procedure TMainForm.Print1Click(Sender: TObject);
var
   FNodeHeight  :Integer;
   FNodeWidth   :Integer;
   FNodeSpace   :Integer;
   FNodeVSpacing:Integer;
   Mag:Integer;
   TitleDiagram : String ;
   DrawTDSStr:String ;
   BitMapPrd:TBitMap ;
   I : integer ;
   Comp:TWinControl;
   Size:TSize;
   OSize:TSize;
   Extent:TRect;
   FirstComp:Boolean;
   X,Y:Integer;
   MaxX,MaxY:Integer;
   XOfs,YOfs:Integer;
begin          
   if PageControl3.ActivePage = TabSheet2 then
   begin
      FirstComp:=True;
      for I:=0 to ScrollBox2.ControlCount-1 do
      begin
         if ScrollBox2.Controls[I] is TWinControl then
         begin
            Comp:=TWinControl(ScrollBox2.Controls[I]);
            if Comp.Visible then
            begin
               if FirstComp then
               begin
                  FirstComp:=False;
                  Extent.Left  :=Comp.Left;
                  Extent.Top   :=Comp.Top ;
                  Extent.Right :=Comp.Left+Comp.Width ;
                  Extent.Bottom:=Comp.Top +Comp.Height;
               end;
               if Comp.Left < Extent.Left               then Extent.Left  :=Comp.Left;
               if Comp.Top  < Extent.Top                then Extent.Top   :=Comp.Top ;
               if Comp.Left+Comp.Width  > Extent.Right  then Extent.Right :=Comp.Left+Comp.Width ;
               if Comp.Top +Comp.Height > Extent.Bottom then Extent.Bottom:=Comp.Top +Comp.Height;
            end;
         end;
      end;
      Printer.BeginDoc;
      Printer.Title:='Component Diagram';
      SetMapMode(Printer.Handle,MM_HIMETRIC);
      GetWindowExtEx(Printer.Canvas.Handle,Size);
      SetMapMode(Printer.Handle,MM_ANISOTROPIC);
      Size.cx:=Size.cx div 15;
      Size.cy:=Size.cy div 15;
      SetWindowExtEx(Printer.Canvas.Handle,Size.cx,0-Size.cy,@OSize);
      Size.cx:=Size.cx-40;
      Size.cy:=Size.cy-40;
      MaxX:=((Extent.Right-Extent.Left) div Size.cx);
      MaxY:=((Extent.Bottom-Extent.Top) div Size.cy);
      for X:=0 to MaxX do
      begin
         XOfs:=0-(Extent.Left+X*Size.cx);
         for Y:=0 to MaxY do
         begin
            YOfs:=0-(Extent.Top+Y*Size.cy);
            for I:=0 to ScrollBox2.ControlCount-1 do
            begin
               if ScrollBox2.Controls[I] is TWinControl then
               begin
                  Comp:=TWinControl(ScrollBox2.Controls[I]);
                  if Comp.Visible then
                     Comp.PaintTo(Printer.Canvas.Handle,XOfs+Comp.Left,YOfs+Comp.Top);
               end;
            end;
            if (X <> MaxX) or (Y <> MaxY) then
               Printer.NewPage;
         end;
      end;
      SetWindowExtEx(Printer.Canvas.Handle,OSize.cx,OSize.cy,@Size);
      Printer.EndDoc;
   end
   else if PaintBox2.Visible then
   begin
      if CompListBox.ItemIndex >= 0 then
      begin
         Printer.Title:='TDS Diagrams';
         Printer.Orientation:=poPortrait;
         Printer.BeginDoc;
         Mag:=Printer.PageWidth div 750;
         FNodeHeight   :=BaseNodeHeight  ;
         FNodeWidth    :=BaseNodeWidth   ;
         FNodeSpace    :=BaseNodeSpace   ;
         FNodeVSpacing :=BaseNodeVSpacing;
         BaseNodeHeight  :=FNodeHeight  *Mag;
         BaseNodeWidth   :=FNodeWidth   *Mag;
         BaseNodeSpace   :=FNodeSpace   *Mag;
         BaseNodeVSpacing:=FNodeVSpacing*Mag;
         for I := 0 to CompListBox.SelCount -1 do
         begin
            DrawTDSStr := IDSDiag.DrawTDS(CompListBox.Items[CompListBox.ItemIndex + I ], BitMapPrd );
            DrawTDSDiag(0,0,Printer.Canvas,DrawTDSStr,Translator, TitleDiagram, BitMapPrd, BitMaps1.Checked );
         end ;

         BaseNodeHeight  :=FNodeHeight  ;
         BaseNodeWidth   :=FNodeWidth   ;
         BaseNodeSpace   :=FNodeSpace   ;
         BaseNodeVSpacing:=FNodeVSpacing;
         Printer.EndDoc;                     
      end;
   end
   else
   begin
      if IDSDiag <> nil then
      begin
         IDSDiag.Print(Translator,Bitmaps1.Checked);
      end;
   end;
end;
procedure TMainForm.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TMainForm.All1Click(Sender: TObject);
var
   I,J:Integer;
   SubGroupsToBuildSL : TStringList;
   CompList:TStringList;
   ProdsNode:TProductsNode;
   DomainsNode:TDomainsNode;
   GroupsNode:TGroupsNode;
   UsersNode:TUsersNode;
   WSsNode:TWorkStationsNode;
   PickListsNode:TPickListsNode;
   LookUpsNode:TLookUpsNode;
   PNode:TProdNode;
   DNode:TDomainNode;
   FieldList:TStringList;
   LineList:TStringList;
   S:String;
   TotalInDomain:TDomainNode;
   CompListIndex : Integer;
begin
  //reload if required
  CompListIndex := CompListBox.ItemIndex;
  IF BuildReloadMenu.Checked then
    LoadProject;
  CompListBox.ItemIndex := CompListIndex;

   if CompListBox.ItemIndex >=0 then
   begin
      CompList:=TStringList.Create;
      SubGroupsToBuildSL :=TStringList.Create;
      SubGroupsToBuildSL.CommaText := SubGroupToBuild;
      if (Sender = All1) or (Sender = Changed1) or (Sender = Products1) then
      begin
         LineList:=TStringList.Create;
         FieldList:=TStringList.Create;
         ProdsNode:=IDSDiag.Parser.Nodes.Products;
         if ProdsNode <> nil then
         begin
            for I:=0 to ProdsNode.Count-1 do
            begin
               PNode:=ProdsNode.Node[I];
               if ((SubGroupToBuild = '')
               or  (SubGroupToBuild = PNode.SubGroup)
               or  (SubGroupsToBuildSL.IndexOf('Product.'+PNode.NodeName) > -1))
               and (not PNode.DontBuild) then
               begin
                  FieldList.Clear;
                  FieldList.Add('Product');
                  FieldList.Add(ProdsNode.Name[I]);
                  DomainsNode:=IDSDiag.Parser.Nodes.Domains;
                  if (DomainsNode <> nil) then
                  begin
                     TotalInDomain:=nil;
                     for J:=0 to PNode.Domains.Count-1 do
                     begin
                        DNode:=PNode.Domain[J];
                        if DNode <> nil then
                        begin
                           LineList.Clear;
                           LineList.Add(DNode.NodeName); // 0 Name
                           LineList.Add(DNode.Title   ); // 1 Caption
                           LineList.Add(DNode.Prompt  ); // 2 Prompt
                           LineList.Add(DNode.Hint    ); // 3 Hint
                           LineList.Add(DNode.Error   ); // 4 Error
                           LineList.Add(DNode.Format+'('+DNode.FmtData+')'); // 5 Mask
                           // In case the value is entered by keyboard doesn't need to get de UnitPrice
                              if ( DNode.TotalIn <> '' ) then
                           begin

                              if ( UpperCase( DNode.InputFrom ) = 'PARAMS' ) or
                                 ( UpperCase( DNode.InputFrom ) = 'ATTRIB(UNITPRICE)' ) then
                                 LineList.Add(ProdsNode.Name[I]) // 6 nog prog Id but with UseDefault
                              else
                                 LineList.Add('NoParams'); // 6 Set ProgId

                              TotalInDomain:=DNode.TotalInDomain;


                           end
                           else
                           begin
                              LineList.Add('');
                           end;
                           LineList.Add(DNode.DefaultValue); // 7 Default Value
                           if DNode.Action = 'Show' then
                              LineList.Add('N') // 8 Disabled
                           else
                              LineList.Add('Y'); // 8 Enabled
                           LineList.Add('N'); // 9 Ignore
                           LineList.Add(PNode.DomainParams[J]); // 10 DomainParams
                           LineList.Add(DNode.Locale);  //11 Locale language
                           FieldList.Add(LineList.CommaText);
                        end;
                     end;
                     if TotalInDomain <> nil then
                     begin
                        LineList.Clear;
                        LineList.Add(TotalInDomain.NodeName); // Name
                        LineList.Add(TotalInDomain.Title   ); // Caption
                        LineList.Add(TotalInDomain.Prompt  ); // Prompt
                        LineList.Add(TotalInDomain.Hint    ); // Hint
                        LineList.Add(TotalInDomain.Error   ); // Error
                        LineList.Add(TotalInDomain.Format+'('+TotalInDomain.FmtData+')'); // Mask
                        LineList.Add('TotalField'); // ProgId
                        LineList.Add('');   // Default Value
                        LineList.Add('N'); // Enabled
                        LineList.Add('N'); // Ignore
                        LineList.Add(''); // Domain Params
                        LineList.Add('0');   //Locale Language
                        FieldList.Add(LineList.CommaText);
                     end;
                  end;
                  CompList.Add(FieldList.CommaText);
               end;
            end;
         end;
         FieldList.Free;
         LineList.Free;
      end;
      if (Sender = All1) or (Sender = Changed1) or (Sender = Groups1) then
      begin
        If SubGroupToBuild <> '' then
        begin
          CompList.Add('"Group","' + SubGroupToBuild +'"');
        end
        else
        begin
           GroupsNode:=IDSDiag.Parser.Nodes.Groups;
           if GroupsNode <> nil then
           begin
              for I:=0 to GroupsNode.Count-1 do
                 CompList.Add('"Group","'+GroupsNode.Name[I]+'"');
           end;
        end;
      end;
      if (Sender = All1) or (Sender = Changed1) or (Sender = UserGroups1) then
      begin
         UsersNode:=IDSDiag.Parser.Nodes.Users;
         if UsersNode <> nil then
         begin
            for I:=0 to UsersNode.Count-1 do
               CompList.Add('"User","'+UsersNode.Name[I]+'"');
         end;
      end;
      if (Sender = All1) or (Sender = Changed1) or (Sender = WorkstationGroups1) then
      begin
         WSsNode:=IDSDiag.Parser.Nodes.Workstations;
         if WSsNode <> nil then
         begin
            for I:=0 to WSsNode.Count-1 do
               CompList.Add('"WorkStation","'+WSsNode.Name[I]+'"');
         end;
      end;
      if (Sender = All1) or (Sender = Changed1) or (Sender = PickLists1) then
      begin
         PickListsNode:=IDSDiag.Parser.Nodes.PickLists;
         if PickListsNode <> nil then
         begin
            for I:=0 to PickListsNode.Count-1 do
               CompList.Add('"PickList","'+PickListsNode.Name[I]+'"');
         end;
      end;
      if (Sender = All1) or (Sender = Changed1) or (Sender = LookUps1) then
      begin
         LookUpsNode:=IDSDiag.Parser.Nodes.LookUps;
         if LookUpsNode <> nil then
         begin
            for I:=0 to LookUpsNode.Count-1 do
               CompList.Add('"LookUp","'+LookUpsNode.Name[I]+'"');
         end;
      end;
      CancelBuild:=False;
      if (Sender = Changed1) then
      begin
         S:=CompList.Text;
         Builder.RemOldFrom(S,IDSDiag.Parser.Nodes);
         CompList.Text:=S;
      end;
      Builder.GenNewSource(CompList.Text,IDSDiag.Parser.Nodes);
      Builder.BuildComponent(CompList.Text,IDSDiag.Parser.Nodes,UnRegReRegOnBuild1.Checked or UnRegReRegOnBuildRegServer1.Checked,DebugInfoinBinaries1.Checked);
      if CancelBuild then
      begin
         Builder.ListBox1.Items.AddObject('Build Canceled !',TObject(1));
         Builder.ListBox1.ItemIndex:=Builder.ListBox1.Items.Count-1;
      end;
      CompList.Free;
      SubGroupsToBuildSL.Free;
   end;
end;

procedure TMainForm.Bitmaps1Click(Sender: TObject);
begin
   Bitmaps1.Checked:=not Bitmaps1.Checked;
   if PaintBox1.Visible then PaintBox1.Invalidate;
   if PaintBox2.Visible then PaintBox2.Invalidate;
   if Bitmaps1.Checked then
      SetGPCSRegString('IDS','Show Bitmaps','Y')
   else
      SetGPCSRegString('IDS','Show Bitmaps','N');
end;

procedure TMainForm.CompTypeComboBoxChange(Sender: TObject);
var
   I:Integer;
begin
   CompListBox.Clear;
   if CompTypeComboBox.Text = 'Products' then
   begin
      if IDSDiag.Parser.Nodes.Products <> nil then
      begin
         for I:=0 to IDSDiag.Parser.Nodes.Products.Count-1 do
            CompListBox.Items.Add(IDSDiag.Parser.Nodes.Products.Name[I]);
      end;
   end
   else if CompTypeComboBox.Text = 'Groups' then
   begin
      if IDSDiag.Parser.Nodes.Groups <> nil then
      begin
         for I:=0 to IDSDiag.Parser.Nodes.Groups.Count-1 do
            CompListBox.Items.Add(IDSDiag.Parser.Nodes.Groups.Name[I]);
      end;
   end
   else if CompTypeComboBox.Text = 'Users' then
   begin
      if IDSDiag.Parser.Nodes.Users <> nil then
      begin
         for I:=0 to IDSDiag.Parser.Nodes.Users.Count-1 do
            CompListBox.Items.Add(IDSDiag.Parser.Nodes.Users.Name[I]);
      end;
   end
   else if CompTypeComboBox.Text = 'Workstations' then
   begin
      if IDSDiag.Parser.Nodes.Workstations <> nil then
      begin
         for I:=0 to IDSDiag.Parser.Nodes.Workstations.Count-1 do
            CompListBox.Items.Add(IDSDiag.Parser.Nodes.Workstations.Name[I]);
      end;
   end
   else if CompTypeComboBox.Text = 'PickLists' then
   begin
      if IDSDiag.Parser.Nodes.PickLists <> nil then
      begin
         for I:=0 to IDSDiag.Parser.Nodes.PickLists.Count-1 do
            CompListBox.Items.Add(IDSDiag.Parser.Nodes.PickLists.Name[I]);
      end;
   end
   else if CompTypeComboBox.Text = 'LookUps' then
   begin
      if IDSDiag.Parser.Nodes.LookUps <> nil then
      begin
         for I:=0 to IDSDiag.Parser.Nodes.LookUps.Count-1 do
            CompListBox.Items.Add(IDSDiag.Parser.Nodes.LookUps.Name[I]);
      end;
   end;
end;
function AbsolutePath(RelativePath:String):String;
var
   CurDir:String;
   P:PChar;
begin
   GetDir(0,CurDir);
   if Copy(RelativePath,1,2) = '..' then
   begin
      P:=StrRScan(PChar(CurDir),'\');
      if P <> nil then
         CurDir:=Copy(CurDir,1,Integer(P-PChar(CurDir)));
      Result:=CurDir+'\'+Copy(RelativePath,4,Length(RelativePath));
   end
   else if (Copy(RelativePath,1,1) <> '\')  and (Copy(RelativePath,2,1) <> ':') then
      Result:=CurDir+'\'+Copy(RelativePath,3,Length(RelativePath))
   else
      Result:=RelativePath;
end;
const
  wdBorderTop = -1;
  wdBorderLeft = -2;
  wdBorderBottom = -3;
  wdBorderRight = -4;
  wdBorderHorizontal = -5;
  wdBorderVertical = -6;
  wdBorderDiagonalDown = -7;
  wdBorderDiagonalUp = -8;

procedure InsertTableInWord(WordApp:Variant;List:TStrings;WithBreak:Boolean);
var
   I:Integer;
   Table:Variant;
   Shape:Variant;
   LastCell:String;
begin
   WordApp.Selection.TypeParagraph;
   Table:=WordApp.ActiveDocument.Tables.Add(Range:=WordApp.Selection.Range,NumRows:=2,NumColumns:=2);
   Table.AutoFormat(0,False,False,False,False,False,False,False,False,Unassigned);
   WordApp.Selection.SelectColumn;
   WordApp.Selection.Columns.PreferredWidthType := 3; // wdPreferredWidthPoints
   WordApp.Selection.Columns.PreferredWidth := 50;
   WordApp.Selection.Font.Size:=12;
   WordApp.Selection.Font.Bold:=9999998; // wdToggle
   WordApp.Selection.ParagraphFormat.Alignment:=2; // wdAlignParagraphRight
   WordApp.Selection.MoveRight(Unit:=1,Count:=1); // 1 = wdCharacter
   WordApp.Selection.SelectColumn;
   WordApp.Selection.Font.Size:=14;
   WordApp.Selection.MoveLeft(Unit:=1,Count:=1); // 1 = wdCharacter
   WordApp.Selection.SelectRow;
   WordApp.Selection.Font.Bold:=9999998; // wdToggle
   WordApp.Selection.Font.Bold:=9999998; // wdToggle
   WordApp.Selection.Font.Size:=18;
   WordApp.Selection.MoveLeft(Unit:=1,Count:=1); // 1 = wdCharacter
   Table.AutoFitBehavior(2); // wdAutoFitContent
   LastCell:='';
   for I:=0 to List.Count-1 do
   begin
      if LastCell = 'Bitmap' then
      begin
         if FileExists(AbsolutePath(List[I])) then
         begin
            WordApp.Selection.TypeParagraph;
            WordApp.Selection.InlineShapes.AddPicture(AbsolutePath(List[I]),False,True);
            WordApp.Selection.MoveLeft(Unit:=1,Count:=1,Extend:=1); // Select Picture
            Shape:=WordApp.Selection.InlineShapes.item(WordApp.Selection.InlineShapes.Count);
            Shape.Height:=50;
            Shape.Width:=75;
            WordApp.Selection.MoveRight(Unit:=1,Count:=1); // De-Select Picture
            WordApp.Selection.TypeParagraph;
         end
         else
         begin
            WordApp.Selection.TypeText('File Not Found ('+List[I]+')');
         end;
      end
      else
      begin
         if (I mod 2 = 1) or (List[I] <> ' ') then
         begin
            WordApp.Selection.TypeText(List[I]);
            if (Copy(List[I],1,8) = 'Product.')
            or (Copy(List[I],1,6) = 'Group.')
            or (Copy(List[I],1,7) = 'UGroup.')
            or (Copy(List[I],1,7) = 'WGroup.')
            or (Copy(List[I],1,9) = 'PickList.')
            or (Copy(List[I],1,7) = 'LookUp.') then
            begin
                WordApp.Selection.MoveLeft(Unit:=2,Count:=3,Extend:=1); // Select Text
                WordApp.ActiveDocument.Indexes.MarkEntry(Range:=WordApp.Selection.Range,Entry:=List[I],EntryAutoText:=List[I]);
                WordApp.Selection.MoveRight(Unit:=1,Count:=1); // De-Select Text
            end;
         end;
      end;
      LastCell:=List[I];
      if I <> List.Count-1 then
      begin
         if (I mod 2 = 1) and (List[I+1] = ' ') then
            WordApp.Selection.TypeParagraph
         else if not ((I mod 2 = 0) and (List[I] = ' ')) then
            WordApp.Selection.MoveRight(Unit:=12); // 12 = wdCell
      end;
   end;
   WordApp.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine
   if WithBreak then
   begin
      WordApp.Selection.InsertBreak(Type:=0); // page break
   end
   else
   begin
      WordApp.Selection.TypeText('_________________________________________________________________');
      WordApp.Selection.TypeParagraph;
   end;
{
    Selection.HomeKey Unit:=wdLine, Extend:=wdExtend
    ActiveDocument.Indexes.MarkEntry Range:=Selection.Range, Entry:= _
        "Group.Main", EntryAutoText:="Group.Main", CrossReference:="", _
        CrossReferenceAutoText:="", BookmarkName:="", Bold:=False, Italic:=False
    Selection.EndKey Unit:=wdLine
    With ActiveDocument
        .Indexes.Add Range:=Selection.Range, HeadingSeparator:= _
            wdHeadingSeparatorNone, Type:=wdIndexIndent, RightAlignPageNumbers:= _
            False, NumberOfColumns:=2, IndexLanguage:=wdEnglishUS
        .Indexes(1).TabLeader = wdTabLeaderDots

}
   
end;
procedure ProdPage(WordApp:Variant;PNode:TProdNode;WithBreak:Boolean);
var
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   SL.Add('Product');
   SL.Add(PNode.NodeName);
   if PNode.Title        <> '' then begin SL.Add('Title');        SL.Add(PNode.Title       ); end;
   if PNode.ProgID       <> '' then begin SL.Add('ProgID');       SL.Add(PNode.ProgID      ); end;
   if PNode.RegDesc      <> '' then begin SL.Add('RegDesc');      SL.Add(PNode.RegDesc     ); end;
   if PNode.BarCode      <> '' then begin SL.Add('BarCode');      SL.Add(PNode.BarCode     ); end;
   if PNode.Description  <> '' then begin SL.Add('Description');  SL.Add(PNode.Description ); end;
   if PNode.EndDate      <> '' then begin SL.Add('EndDate');      SL.Add(PNode.EndDate     ); end;
   if PNode.HighDays     <> '' then begin SL.Add('HighDays');     SL.Add(PNode.HighDays    ); end;
   if PNode.MCRCode      <> '' then begin SL.Add('MCRCode');      SL.Add(PNode.MCRCode     ); end;
   if PNode.OCRCode      <> '' then begin SL.Add('OCRCode');      SL.Add(PNode.OCRCode     ); end;
   if PNode.OtherCode    <> '' then begin SL.Add('OtherCode');    SL.Add(PNode.OtherCode   ); end;
   if PNode.Regulations  <> '' then begin SL.Add('Regulations');  SL.Add(PNode.Regulations ); end;
   if PNode.StartDate    <> '' then begin SL.Add('StartDate');    SL.Add(PNode.StartDate   ); end;
   if PNode.UseDays      <> '' then begin SL.Add('UseDays');      SL.Add(PNode.UseDays     ); end;
   if PNode.Prompt       <> '' then begin SL.Add('Prompt');       SL.Add(PNode.Prompt      ); end;
   if PNode.Hint         <> '' then begin SL.Add('Hint');         SL.Add(PNode.Hint        ); end;
   if PNode.UnitQuantity <> '' then begin SL.Add('UnitQuantity'); SL.Add(PNode.UnitQuantity); end;
   if PNode.MaxQuantity  <> '' then begin SL.Add('MaxQuantity');  SL.Add(PNode.MaxQuantity ); end;
   if PNode.MinQuantity  <> '' then begin SL.Add('MinQuantity');  SL.Add(PNode.MinQuantity ); end;
   if PNode.PLU          <> '' then begin SL.Add('PLU');          SL.Add(PNode.PLU         ); end;
   if PNode.UnitPrice    <> '' then begin SL.Add('UnitPrice');    SL.Add(PNode.UnitPrice   ); end;
   if PNode.LogAs        <> '' then begin SL.Add('LogAs');        SL.Add(PNode.LogAs       ); end;
   if PNode.Bitmap       <> '' then begin SL.Add('Bitmap');       SL.Add(PNode.Bitmap      ); end;
   if PNode.PrintList    <> '' then begin SL.Add('PrintList');    SL.Add(PNode.PrintList   ); end;
   if PNode.FillList     <> '' then begin SL.Add('FillList');     SL.Add(PNode.FillList    ); end;
   if PNode.Endorse      <> '' then begin SL.Add('Endorse  ');    SL.Add(PNode.Endorse     ); end;
   if PNode.Customer     <> '' then begin SL.Add('Customer ');    SL.Add(PNode.Customer    ); end;
   for I:=0 to PNode.Domains.Count-1 do
   begin
      if I= 0 then SL.Add('Domains') else SL.Add(' ');
      SL.Add(PNode.Domains[I]); 
   end;
   for I:=0 to PNode.Count-1 do
   begin
      if I= 0 then SL.Add('Items') else SL.Add(' ');
      SL.Add(PNode.Item[I]); 
   end;
   InsertTableInWord(WordApp,SL,WithBreak);
   SL.Free;
end;
procedure GroupPage(WordApp:Variant;GNode:TGroupNode;WithBreak:Boolean);
var
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   SL.Add('Group');
   SL.Add(GNode.NodeName);
   if GNode.Title        <> '' then begin SL.Add('Title');        SL.Add(GNode.Title       ); end;
   if GNode.ProgID       <> '' then begin SL.Add('ProgID');       SL.Add(GNode.ProgID      ); end;
   if GNode.RegDesc      <> '' then begin SL.Add('RegDesc');      SL.Add(GNode.RegDesc     ); end;
   if GNode.Bitmap       <> '' then begin SL.Add('Bitmap');       SL.Add(GNode.Bitmap      ); end;
   for I:=0 to GNode.Count-1 do
   begin
      if I= 0 then SL.Add('Items') else SL.Add(' ');
      SL.Add(GNode.Item[I]);
   end;
   InsertTableInWord(WordApp,SL,WithBreak);
   SL.Free;
end;
procedure UGroupPage(WordApp:Variant;UNode:TUGroupNode;WithBreak:Boolean);
var
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   SL.Add('UGroup');
   SL.Add(UNode.NodeName);
   if UNode.ProgID       <> '' then begin SL.Add('ProgID');       SL.Add(UNode.ProgID      ); end;
   if UNode.RegDesc      <> '' then begin SL.Add('RegDesc');      SL.Add(UNode.RegDesc     ); end;
   for I:=0 to UNode.Count-1 do
   begin
      if I= 0 then SL.Add('Items') else SL.Add(' ');
      SL.Add(UNode.Item[I]); 
   end;
   InsertTableInWord(WordApp,SL,WithBreak);
   SL.Free;
end;
procedure WGroupPage(WordApp:Variant;WNode:TWGroupNode;WithBreak:Boolean);
var
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   SL.Add('WGroup');
   SL.Add(WNode.NodeName);
   if WNode.ProgID       <> '' then begin SL.Add('ProgID');       SL.Add(WNode.ProgID      ); end;
   if WNode.RegDesc      <> '' then begin SL.Add('RegDesc');      SL.Add(WNode.RegDesc     ); end;
   for I:=0 to WNode.Count-1 do
   begin
      if I= 0 then SL.Add('Items') else SL.Add(' ');
      SL.Add(WNode.Item[I]); 
   end;
   InsertTableInWord(WordApp,SL,WithBreak);
   SL.Free;
end;
procedure PickListPage(WordApp:Variant;KNode:TPickListNode;WithBreak:Boolean);
var
   SL:TStringList;
   I,Z:Integer;
   ZD:String;
   ZoneList:TStringList;
begin
   SL:=TStringList.Create;
   SL.Add('PickList');
   SL.Add(KNode.NodeName);
   if KNode.ProgID       <> '' then begin SL.Add('ProgID');       SL.Add(KNode.ProgID      ); end;
   if KNode.RegDesc      <> '' then begin SL.Add('RegDesc');      SL.Add(KNode.RegDesc     ); end;
   if KNode.DefaultItem <> '' then begin SL.Add('Default'); SL.Add(KNode.DefaultItem); end;
   ZoneList:=TStringList.Create;
   for I:=0 to KNode.Zones.Count-1 do
      if ZoneList.IndexOf(KNode.Zones[I]) = -1 then
         ZoneList.Add(KNode.Zones[I]);
   ZoneList.Sort;
   for Z:=0 to ZoneList.Count-1 do
   begin
      SL.Add(ZoneList[Z]);
      ZD:='';
      for I:=0 to KNode.Zones.Count-1 do
      begin
         if KNode.Zones[I] = ZoneList[Z] then
         begin
           if ZD <> '' then
              ZD:=ZD+', '+KNode.Items[I]
           else
              ZD:=KNode.Items[I];
         end;
      end;
      SL.Add(ZD);
   end;
   ZoneList.Free;
   InsertTableInWord(WordApp,SL,WithBreak);
   SL.Free;
end;
procedure LookUpPage(WordApp:Variant;LNode:TLookUpNode;WithBreak:Boolean);
var
   SL:TStringList;
   I,J,K:Integer;
   ZD:String;
begin
   SL:=TStringList.Create;
   SL.Add('Tariff');
   SL.Add(LNode.NodeName);
   if LNode.ProgID       <> '' then begin SL.Add('ProgID');       SL.Add(LNode.ProgID      ); end;
   if LNode.RegDesc      <> '' then begin SL.Add('RegDesc');      SL.Add(LNode.RegDesc     ); end;
   
   ZD:='';
   for I:=0 to LNode.Ranges.Count-1 do
      if ZD <> '' then ZD:=ZD+', '+LNode.Ranges[I] else ZD:=LNode.Ranges[I];
   SL.Add('Ranges');
   SL.Add(ZD);
   
   K:=0;
   for I:=0 to LNode.ZoneNames.Count-1 do
   begin
      SL.Add(LNode.ZoneNames[I]);
      ZD:='';
      for J:=0 to LNode.Ranges.Count-1 do
      begin
         if ZD <> '' then ZD:=ZD+', '+LNode.Zones[K] else ZD:=LNode.Zones[K];
         Inc(K);
      end;
      SL.Add(ZD);
   end;
           
   InsertTableInWord(WordApp,SL,WithBreak);
   SL.Free;
end;
procedure DomainPage(WordApp:Variant;DNode:TDomainNode;WithBreak:Boolean);
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
   SL.Add('Domain');
   SL.Add(DNode.NodeName);
   if DNode.Title  <> '' then begin SL.Add('Title');  SL.Add(DNode.Title ); end;
   if DNode.Prompt <> '' then begin SL.Add('Prompt'); SL.Add(DNode.Prompt); end;
   if DNode.Hint   <> '' then begin SL.Add('Hint');   SL.Add(DNode.Hint  ); end;
   if DNode.Error  <> '' then begin SL.Add('Error');  SL.Add(DNode.Error ); end;
   if DNode.Format <> '' then begin SL.Add('Format'); SL.Add(DNode.Format+'('+DNode.FmtData+')'); end;
   InsertTableInWord(WordApp,SL,WithBreak);
   SL.Free;
end;
procedure LogFormatPage(WordApp:Variant;LNode:TLogFormatNode;WithBreak:Boolean);
var
   SL:TStringList;
   FSL:TStringList;
   F,S:String;
   I:Integer;
begin
   SL:=TStringList.Create;
   SL.Add('LogFormat');
   SL.Add(LNode.NodeName);
   if LNode.Format <> '' then 
   begin 
      FSL:=TStringList.Create;
      FSL.CommaText:=LNode.Format;
      FSL.CommaText:=FSL.Text;
      F:='Format';
      S:='';
      for I:=0 to FSL.Count-1 do
      begin
         if FSL[I] = '^' then
         begin
            SL.Add(F);
            SL.Add(S);
            F:=' ';
            S:='';
         end
         else
         begin
            if Copy(FSL[I],1,1) = '*' then
            begin
               if S <> '' then S:=S+', "'+Copy(FSL[I],2,999)+'"' else S:=S+'"'+Copy(FSL[I],2,999)+'"';
            end
            else
            begin
               if S <> '' then S:=S+', '+FSL[I] else S:=S+FSL[I];
            end;
         end;  
      end;   
      if S <> '' then
      begin
         SL.Add(F);
         SL.Add(S);
      end;
      FSL.Free;
   end;
   InsertTableInWord(WordApp,SL,WithBreak);
   SL.Free;
end;
procedure TMainForm.AcceptanceCriteria1Click(Sender: TObject);
var
   I:Integer;
   WordApp:Variant;
begin
   WordApp:=CreateOleObject('Word.Application');
//   try
      WordApp.Documents.Add;
      WordApp.Visible:=True;
      WordApp.ActiveDocument.PageSetup.Orientation :=0; // LandScape
      with IDSDiag.Parser.Nodes do
      begin
         if Users        <> nil then for I:=0 to Users.       Count-1 do    UGroupPage(WordApp,Users       .Node[I],((I mod 2 = 1) or (I = Users.       Count-1)));
         if Workstations <> nil then for I:=0 to Workstations.Count-1 do    WGroupPage(WordApp,Workstations.Node[I],((I mod 2 = 1) or (I = Workstations.Count-1)));
         if Groups       <> nil then for I:=0 to Groups.      Count-1 do     GroupPage(WordApp,Groups      .Node[I],((I mod 2 = 1) or (I = Groups.      Count-1)));
         if Products     <> nil then for I:=0 to Products.    Count-1 do      ProdPage(WordApp,Products    .Node[I],((I mod 2 = 1) or (I = Products.    Count-1)));
         if Domains      <> nil then for I:=0 to Domains     .Count-1 do    DomainPage(WordApp,Domains     .Node[I],((I mod 4 = 3) or (I = Domains     .Count-1)));
         if LogFormats   <> nil then for I:=0 to LogFormats  .Count-1 do LogFormatPage(WordApp,LogFormats  .Node[I],((I mod 8 = 7) or (I = LogFormats  .Count-1)));
         if LookUps      <> nil then for I:=0 to LookUps     .Count-1 do    LookUpPage(WordApp,LookUps     .Node[I],((I mod 5 = 4) or (I = LookUps     .Count-1)));
         if PickLists    <> nil then for I:=0 to PickLists   .Count-1 do  PickListPage(WordApp,PickLists   .Node[I],False);
      end;
//   except
//   end;
   WordApp:=Unassigned;
end;

procedure TMainForm.UnRegReRegOnBuild1Click(Sender: TObject);
begin
   UnRegReRegOnBuild1.Checked:=not UnRegReRegOnBuild1.Checked;
   if UnRegReRegOnBuild1.Checked then
      UnRegReRegOnBuildRegServer1.Checked:=False;
   if UnRegReRegOnBuild1.Checked then
      SetGPCSRegString('IDS','Un-ReReg On Build','Y')
   else
      SetGPCSRegString('IDS','Un-ReReg On Build','N');
   if UnRegReRegOnBuildRegServer1.Checked then
      SetGPCSRegString('IDS','Un-ReReg On Build RegServer','Y')
   else
      SetGPCSRegString('IDS','Un-ReReg On Build RegServer','N');
end;

procedure TMainForm.PissOff1Click(Sender: TObject);
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
   SL.Text:=IDSDiag.Parser.Nodes.AsString;
   SL.SaveToFile(OD.FileName+'.txt');
   SL.Free;
end;

procedure AddGroupToList(Group:TGroupNode;SL:TStrings;Section:String);
var
  I:Integer;
  ProdNode:TProdNode;
begin
   SL.Add('Group.'+Group.NodeName+'^'+Section+'^0');
   for I:=0 to Group.Count-1 do
   begin
      if (Group.ItemNode[I] is TGroupNode) then
      begin
         AddGroupToList(TGroupNode(Group.ItemNode[I]),SL,Section+'.'+IntToStr(I+1))
      end
      else if (Group.ItemNode[I] is TProdNode) then
      begin
         ProdNode:=TProdNode(Group.ItemNode[I]);
         if ProdNode.Domains.IndexOf('Weight') <> -1 then
            SL.Add('Product.'+Group.ItemNode[I].NodeName+'^'+Section+'.'+IntToStr(I+1)+'^10')
         else
            SL.Add('Product.'+Group.ItemNode[I].NodeName+'^'+Section+'.'+IntToStr(I+1)+'^0');
      end;
   end;
end;
procedure TMainForm.ComponentList1Click(Sender: TObject);
var
   I:Integer;
   UGroup:TUGroupNode;
   Group:TGroupNode;
begin
   CompListForm.Memo1.Lines.Clear;
   with IDSDiag.Parser.Nodes do
   begin
      for I:=0 to Users.Count-1 do
      begin
         UGroup:=Users[I];
         if UGroup.Count > 0 then
         begin
            Group:=TGroupNode(UGroup.ItemNode[0]);
            AddGroupToList(Group,CompListForm.Memo1.Lines,'1');
         end;
      end;
   end;
   CompListForm.Show;
end;

procedure TMainForm.Groups1Click(Sender: TObject);
begin
  All1Click(Sender);
end;

procedure AddGroupProds(Group:TExecNode;SL:TStrings;Depth:String);
var
  I:Integer;
begin
   if (Group is TGroupNode) then
      SL.Add(Depth+'Group '+Group.Title)
   else if (Group is TProdNode) then
   begin
      SL.Add(Depth+(Group as TProdNode).Title+'     '+(Group as TProdNode).PLU);
   end;
   for I:=0 to Group.Count-1 do    
   begin
      if (Group.ItemNode[I] is TGroupNode) then
      begin
         AddGroupProds(TGroupNode(Group.ItemNode[I]),SL,Depth+'      ');
      end
      else if (Group.ItemNode[I] is TProdNode) then
      begin
         AddGroupProds(TProdNode(Group.ItemNode[I]),SL,Depth+'      ');
      end;
   end;
end;
procedure TMainForm.PLUList1Click(Sender: TObject);
var
   I:Integer;
   UGroup:TUGroupNode;
   Group:TGroupNode;
begin
   CompListForm.Memo1.Lines.Clear;
   with IDSDiag.Parser.Nodes do
   begin
      CompListForm.Memo1.Lines.Clear;
      for I:=0 to Users.Count-1 do
      begin
         UGroup:=Users[I];
         if UGroup.Count > 0 then
         begin
            Group:=TGroupNode(UGroup.ItemNode[0]);
            AddGroupProds(Group,CompListForm.Memo1.Lines,'    ');
         end;
      end;
   end;
   CompListForm.Show;
end;

procedure TMainForm.LookupTester1Click(Sender: TObject);
begin
   LookTest.Show;
end;

procedure TMainForm.UnRegReRegOnBuildRegServer1Click(Sender: TObject);
begin
   UnRegReRegOnBuildRegServer1.Checked:= not UnRegReRegOnBuildRegServer1.Checked;
   if UnRegReRegOnBuildRegServer1.Checked then
      UnRegReRegOnBuild1.Checked:=False;
   if UnRegReRegOnBuildRegServer1.Checked then
      SetGPCSRegString('IDS','Un-ReReg On Build RegServer','Y')
   else
      SetGPCSRegString('IDS','Un-ReReg On Build RegServer','N');
   if UnRegReRegOnBuild1.Checked then
      SetGPCSRegString('IDS','Un-ReReg On Build','Y')
   else
      SetGPCSRegString('IDS','Un-ReReg On Build','N');
end;

procedure TMainForm.BatchMemoDragOver(Sender, Source: TObject; X,
	Y: Integer; State: TDragState; var Accept: Boolean);
begin
	If Source = CompListBox then Accept := True;
end;

procedure TMainForm.BatchMemoDragDrop(Sender, Source: TObject; X,
	Y: Integer);
var
	CompProgID : String;
begin
	If (Source = CompListBox) and (CompListBox.ItemIndex >= 0) then
	begin
		CompProgID := LeftStringExcept(CompTypeComboBox.Text,1) + '.' + CompListBox.Items[CompListBox.ItemIndex];
		With BatchMemo.Lines do
		begin
			If IndexOf(CompProgID) < 0 then
				Add(CompProgID);
		end;
	end;
end;


procedure TMainForm.BatchMemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key in [VK_DELETE, VK_BACK] then
  begin
		BatchMemo.Lines.Delete(BatchMemo.Perform(EM_LINEFROMCHAR, -1, 0));
		Key := 0;
	end;

end;

procedure TMainForm.BatchMenuClick(Sender: TObject);
var
	CompType  : String;
	CompIndex : Integer;
begin
	With TStringList.Create do
	begin
		try
			For CompIndex := 0 To BatchMemo.Lines.Count -1 do
      begin
        CompType := DelimitedString(BatchMemo.Lines[CompIndex],'.',False);
        Add(BatchMemo.Lines[CompIndex])
      end;
      SubGroupToBuild := CommaText;
    finally
      Free;
    end;
  end;  //with TSL.Create
  All1Click(FindComponent(CompType + 's1')); //Products1, Groups1 ,etc as sender
  SubGroupToBuild := '';
end;

procedure TMainForm.UtilisationReport1Click(Sender: TObject);
var
   I,J:Integer;
   WordApp:Variant;
   Element:TNode;
   Product:TProdNode;
   ANode:TNode;
begin
   with IDSDiag.Parser.Nodes do
   begin
      ResetUsedBy;
      if Users <> nil then
      begin
         for I:=0 to Users.Count-1 do
         begin
            for J:=0 to Users[I].Count-1 do
            begin
               Element:=Users[I][J];
               if Element <> nil then
               begin
                  if Element.UsedBy = '' then
                     Element.UsedBy:=Users[I].ProgID
                  else
                     Element.UsedBy:=Element.UsedBy+', '+Users[I].ProgID;
               end;
            end;
         end;
      end;
      if Workstations <> nil then
      begin
         for I:=0 to Workstations.Count-1 do
         begin
            for J:=0 to Workstations[I].Count-1 do
            begin
               Element:=Workstations[I][J];
               if Element <> nil then
               begin
                  if Element.UsedBy = '' then
                     Element.UsedBy:=Workstations[I].ProgID
                  else
                     Element.UsedBy:=Element.UsedBy+', '+Workstations[I].ProgID;
               end;
            end;
         end;
      end;
      if Groups <> nil then
      begin
         for I:=0 to Groups.Count-1 do
         begin
            for J:=0 to Groups[I].Count-1 do
            begin
               Element:=Groups[I][J];
               if Element <> nil then
               begin
                  if Element.UsedBy = '' then
                     Element.UsedBy:=Groups[I].ProgID
                  else
                     Element.UsedBy:=Element.UsedBy+', '+Groups[I].ProgID;
               end;
               Element:=Groups[I].BasisNode;
               if (Element <> nil) and (Element <> Groups[I]) then
               begin
                  if Element.UsedBy = '' then
                     Element.UsedBy:=Groups[I].ProgID
                  else
                     Element.UsedBy:=Element.UsedBy+', '+Groups[I].ProgID;
               end;
            end;
         end;
      end;
      if Products <> nil then
      begin
         for I:=0 to Products.Count-1 do
         begin
            for J:=0 to Products[I].Count-1 do
            begin
               Element:=Products[I][J];
               if Element <> nil then
               begin
                  if Element.UsedBy = '' then
                     Element.UsedBy:=Products[I].ProgID
                  else
                     Element.UsedBy:=Element.UsedBy+', '+Products[I].ProgID;
               end;
            end;
            Element:=Products[I].BasisNode;
            if (Element <> nil) and (Element <> Products[I]) then
            begin
               if Element.UsedBy = '' then
                  Element.UsedBy:=Products[I].ProgID
               else
                  Element.UsedBy:=Element.UsedBy+', '+Products[I].ProgID;
            end;
            Product:=Products[I];
            for J:=0 to Product.Domains.Count-1 do
            begin
               if Product.Domain[J] <> nil then
               begin
                  if Product.Domain[J].UsedBy = '' then
                     Product.Domain[J].UsedBy:=Product.ProgID
                  else
                     Product.Domain[J].UsedBy:=Product.Domain[J].UsedBy+', '+Product.ProgID;
                  if Product.Domain[J].TotalIn <> '' then
                  begin
                     if Product.Domain[J].TotalInDomain.UsedBy = '' then
                        Product.Domain[J].TotalInDomain.UsedBy:=Product.ProgID
                     else
                        Product.Domain[J].TotalInDomain.UsedBy:=Product.Domain[J].TotalInDomain.UsedBy+', '+Product.ProgID;

                  end;
               end;
            end;
            for J:=0 to Product.Snippets.Count-1 do
            begin
               if Product.Snippet[J] <> nil then
               begin
                  if Product.Snippet[J].UsedBy = '' then
                     Product.Snippet[J].UsedBy:=Product.ProgID
                  else
                     Product.Snippet[J].UsedBy:=Product.Snippet[J].UsedBy+', '+Product.ProgID;
               end;
            end;
            ANode:=IDSDiag.Parser.Nodes.LogFormats.SelectNode(Product.LogAs);
            if ANode <> IDSDiag.Parser.Nodes.LogFormats then
            begin
               if ANode.UsedBy = '' then
                  ANode.UsedBy:=Product.ProgID
               else
                  ANode.UsedBy:=ANode.UsedBy+', '+Product.ProgID;
            end;
         end;
      end;
   end;
   WordApp:=CreateOleObject('Word.Application');
   try
      WordApp.Documents.Add;
      WordApp.Visible:=True;
//      WordApp.ActiveDocument.PageSetup.Orientation :=0; // LandScape
      with IDSDiag.Parser.Nodes do
      begin
         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('Group Utilisation');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if Groups <> nil then
         begin
            for I:=0 to Groups.Count-1 do
            begin
               if Groups[I].UsedBy <> '' then
               begin
                  WordApp.Selection.Style:='Body Text Indent';
                  WordApp.Selection.TypeText(Groups[I].NodeName+' Used By:'+Groups[I].UsedBy+'.');
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('Product Utilisation');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if Products <> nil then
         begin
            for I:=0 to Products.Count-1 do
            begin
               if Products[I].UsedBy <> '' then
               begin
                  WordApp.Selection.Style:='Body Text Indent';
                  WordApp.Selection.TypeText(Products[I].NodeName+' Used By:'+Products[I].UsedBy+'.');
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('Domain Utilisation');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if Domains <> nil then
         begin
            for I:=0 to Domains.Count-1 do
            begin
               if Domains[I].UsedBy <> '' then
               begin
                  WordApp.Selection.Style:='Body Text Indent';
                  WordApp.Selection.TypeText(Domains[I].NodeName+' Used By:'+Domains[I].UsedBy+'.');
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('Snippet Utilisation');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if Snippets <> nil then
         begin
            for I:=0 to Snippets.Count-1 do
            begin
               if Snippets[I].UsedBy <> '' then
               begin
                  WordApp.Selection.Style:='Body Text Indent';
                  WordApp.Selection.TypeText(Snippets[I].NodeName+' Used By:'+Snippets[I].UsedBy+'.');
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('LogFormat Utilisation');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if LogFormats <> nil then
         begin
            for I:=0 to LogFormats.Count-1 do
            begin
               if LogFormats[I].UsedBy <> '' then
               begin
                  WordApp.Selection.Style:='Body Text Indent';
                  WordApp.Selection.TypeText(LogFormats[I].NodeName+' Used By:'+LogFormats[I].UsedBy+'.');
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
//         if LookUps <> nil then
//         if PickLists <> nil then


         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('Unused Groups');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if Groups <> nil then
         begin
            for I:=0 to Groups.Count-1 do
            begin
               if Groups[I].UsedBy = '' then
               begin
                  WordApp.Selection.TypeText(Groups[I].NodeName);
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('Unused Products');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if Products <> nil then
         begin
            for I:=0 to Products.Count-1 do
            begin
               if Products[I].UsedBy = '' then
               begin
                  WordApp.Selection.TypeText(Products[I].NodeName);
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('Unused Domains');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if Domains <> nil then
         begin
            for I:=0 to Domains.Count-1 do
            begin
               if Domains[I].UsedBy = '' then
               begin
                  WordApp.Selection.TypeText(Domains[I].NodeName);
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('Unused Snippets');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if Snippets <> nil then
         begin
            for I:=0 to Snippets.Count-1 do
            begin
               if Snippets[I].UsedBy = '' then
               begin
                  WordApp.Selection.TypeText(Snippets[I].NodeName);
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('Unused LogFormats');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if LogFormats <> nil then
         begin
            for I:=0 to LogFormats.Count-1 do
            begin
               if LogFormats[I].UsedBy = '' then
               begin
                  WordApp.Selection.TypeText(LogFormats[I].NodeName);
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
         WordApp.Selection.Style:='Heading 1';
         WordApp.Selection.TypeText('Unused Constants');
         WordApp.Selection.TypeParagraph;
         WordApp.Selection.Style:='Normal';
         if Constants <> nil then          
         begin
            for I:=0 to Constants.Count-1 do
            begin
               if not Constants[I].InUse then
               begin
                  WordApp.Selection.TypeText(Constants[I].NodeName);
                  WordApp.Selection.TypeParagraph;
               end;
            end;
         end;
         
//         if LookUps <> nil then
//         if PickLists <> nil then
      end;
   except
   end;
   WordApp:=Unassigned;
end;

procedure AddGroupHelpToList(Group:TGroupNode;SL:TStrings);
var
  S:String;
  I,J:Integer;
  ProdNode:TProdNode;
begin
   S:='^Group.'+Group.NodeName;
   if SL.IndexOf(S) = -1 then
   begin
      SL.Add(S);
      SL.Add(Group.Title+' Help');
      SL.Add('');
      for I:=0 to Group.Count-1  do
      begin
         if Group.ItemNode[I] <> nil then
            SL.Add('Press F'+IntToStr(I+1)+' for '+Group.ItemNode[I].Title)
         else
            SL.Add('Press F'+IntToStr(I+1)+' for '+Group.Item[I]);
      end;
   end;
   for I:=0 to Group.Count-1 do
   begin
      if (Group.ItemNode[I] is TGroupNode) then
      begin
         AddGroupHelpToList(TGroupNode(Group.ItemNode[I]),SL);
      end
      else if (Group.ItemNode[I] is TProdNode) then
      begin
         ProdNode:=TProdNode(Group.ItemNode[I]);
         S:='^Product.'+ProdNode.NodeName;
         if SL.IndexOf(S) = -1 then
         begin
            SL.Add(S);
            SL.Add(ProdNode.Title+' Help');
            SL.Add('');
            for J:=0 to ProdNode.Domains.Count-1  do
            begin
               if ProdNode.Domain[J] <> nil then
                  SL.Add(ProdNode.Domain[J].Title)
               else
                  SL.Add(ProdNode.Domains[J]);
            end;
            for J:=0 to ProdNode.Count-1  do
            begin
               if ProdNode.ItemNode[J] <> nil then
                  SL.Add('Press F'+IntToStr(J+1)+' for '+ProdNode.ItemNode[J].Title)
               else
                  if ProdNode.Item[J] = 'Complete' then
                     SL.Add('Press F'+IntToStr(J+1)+' when '+ProdNode.Item[J])
                  else
                     SL.Add('Press F'+IntToStr(J+1)+' for '+ProdNode.Item[J]);
            end;
         end;
      end;
   end;
end;
procedure TMainForm.HelpSkeleton1Click(Sender: TObject);
var
   I:Integer;
   UGroup:TUGroupNode;
   Group:TGroupNode;
begin
   CompListForm.Memo1.Lines.Clear;
   with IDSDiag.Parser.Nodes do
   begin
      for I:=0 to Users.Count-1 do
      begin
         UGroup:=Users[I];
         if UGroup.Count > 0 then
         begin
            Group:=TGroupNode(UGroup.ItemNode[0]);
            AddGroupHelpToList(Group,CompListForm.Memo1.Lines);
         end;
      end;
   end;
   CompListForm.Show;
end;

procedure TMainForm.StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
var
   H:Integer;
   R:TRect;
begin
   if (Sender is TStringGrid) then
   begin
      (Sender as TStringGrid).Canvas.Font.Color:=clBtnText;
      if (gdSelected in State) and (gdFocused in State) then
      begin
         DrawButtonBG((Sender as TStringGrid).Canvas,Rect,clActiveCaption,5,50,False,0);
         (Sender as TStringGrid).Canvas.Font.Color:=clCaptionText;
      end
      else if (gdSelected in State) then
         DrawButtonBG((Sender as TStringGrid).Canvas,Rect,Color,5,50,False,0)
      else
         DrawButtonBG((Sender as TStringGrid).Canvas,Rect,Color,3,50,False,0);
      R:=Rect;
      H:=DrawText((Sender as TStringGrid).Canvas.Handle,PChar((Sender as TStringGrid).Cells[Col,Row]),-1,R,DT_CALCRECT or DT_WORDBREAK or DT_CENTER);
      OffsetRect(R,((Rect.Right-Rect.Left)-(R.Right-R.Left)) div 2,((Rect.Bottom-Rect.Top)-H) div 2);
      DrawText((Sender as TStringGrid).Canvas.Handle,PChar((Sender as TStringGrid).Cells[Col,Row]),-1,R,DT_WORDBREAK or DT_CENTER);
   end;
end;

procedure TMainForm.StringGrid1SelectCell(Sender: TObject; Col, Row: Integer;
  var CanSelect: Boolean);
var
   I:Integer;
begin
   if Sender = StringGrid1 then
   begin
      for I:=0 to PageControl1.PageCount-1 do
      begin
         if PageControl1.Pages[I].Name = 'TS'+StringGrid1.Cells[Col,Row] then
         begin
            PageControl1.ActivePage:=PageControl1.Pages[I];
            break;
         end;
      end;
   end
   else if Sender = ProdSG then
   begin
      for I:=0 to ProdPC.PageCount-1 do
      begin
         if ProdPC.Pages[I].Caption = ProdSG.Cells[Col,Row] then
         begin
            ProdPC.ActivePage:=ProdPC.Pages[I];
            break;
         end;
      end;
   end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
   if Panel6.Caption <> '' then
      ShellExecute(Handle,'open',PChar(Panel6.Caption),'','C:\',SW_SHOWNORMAL);
end;

procedure TMainForm.ListProductDescriptions1Click(Sender: TObject);
var
   I:Integer;
   UGroup:TUGroupNode;
   Group:TGroupNode;
begin
   CompListForm.Memo1.Lines.Clear;
   with IDSDiag.Parser.Nodes do
   begin
      for I:=0 to Users.Count-1 do
      begin
         UGroup:=Users[I];
         if UGroup.Count > 0 then
         begin
            Group:=TGroupNode(UGroup.ItemNode[0]);
            AddGroupToList(Group,CompListForm.Memo1.Lines,'1');
         end;
      end;
   end;
   CompListForm.Show;
end;

procedure TMainForm.BuildReloadMenuClick(Sender: TObject);
begin
  BuildReloadMenu.Checked := not BuildReloadMenu.Checked;
  If BuildReloadMenu.Checked then SetGPCSRegString('IDS','Reload Before Build','Y')
  else SetGPCSRegString('IDS','Reload Before Build','N') 
end;

procedure TMainForm.DebugInfoinBinaries1Click(Sender: TObject);
begin
  DebugInfoinBinaries1.Checked := not DebugInfoinBinaries1.Checked;
  If DebugInfoinBinaries1.Checked then SetGPCSRegString('IDS','Debug Info In Binaries','Y')
  else SetGPCSRegString('IDS','Debug Info In Binaries','N');
end;

end.

