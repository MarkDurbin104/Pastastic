unit UseCaseFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ComObj,Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus,Printers, ExtDlgs,clipbrd,SavePosFormU;

type
  TUCNode = class;
  TReorder = class(TObject)
     Node:TUCNode;
  end;
  TBevelType = (btOuterOnly,btInnerOnly,btBevel);
  TUCSDForm = class;
  TUCConfig = class(TCustomControl)
  protected
     FIntroduction :String;
     FOutputFile   :String;
     FTemplateFile :String;
     FHeadingStyle :String;
     FTitlesStyle :String;
     FNormalStyle  :String;
     FEmphasisStyle:String;
  published
     property Introduction :String read FIntroduction  write FIntroduction ;
     property OutputFile   :String read FOutputFile    write FOutputFile   ;
     property TemplateFile :String read FTemplateFile  write FTemplateFile ;
     property HeadingStyle :String read FHeadingStyle  write FHeadingStyle ;
     property TitlesStyle  :String read FTitlesStyle   write FTitlesStyle  ;
     property NormalStyle  :String read FNormalStyle   write FNormalStyle  ;
     property EmphasisStyle:String read FEmphasisStyle write FEmphasisStyle;
  end;
  TCopyPad = class(TCustomControl)
  published
     property Left   stored False;
     property Top    stored False;
     property Width  stored False;
     property Height stored False;
  end;
  TUCNode = class(TCustomControl)
  protected
     FParentForm  :TUCSDForm;
     FSelected    :Boolean;
     FHighLight   :Boolean;
     FMoving      :Boolean;
     FCollapsed   :Boolean;
     FParentNode  :TUCNode;
     FDuplicateOf :TUCNode;
     FDuplicatedIn:TList;
     FChildNodes  :TList;
     FBoxHeight   :Integer;
     FText        :String;
     FUser        :String;
     FVerb        :String;
     FNote        :String;
     FBRules      :String;
     FClarif      :String;
     procedure DeSelect;
     procedure MoveSelected(X,Y:Integer);
     procedure SetCaption(Value:TCaption);
     procedure SetVerb(Value:String);
     function  GetCaption:TCaption;
     function  GetText:String;
     function  GetNote  :String;
     function  GetBRules:String;
     function  GetClarif:String;
     function  GetUser:String;
     function  GetVerb:String;
     procedure SetUser(Value:String);
     procedure ForceVerb(Value:TCaption;Force:Boolean);
     procedure ForceCaption(Value:TCaption;Force:Boolean);
     procedure SetText(Value:String);
     procedure SetNote(Value:String);
     procedure SetBRules(Value:String);
     procedure SetClarif(Value:String);
     procedure ForceText(Value:TCaption;Force:Boolean);
     procedure ForceNote(Value:TCaption;Force:Boolean);
     procedure ForceBRules(Value:TCaption;Force:Boolean);
     procedure ForceClarif(Value:TCaption;Force:Boolean);
     procedure SetParentNode(Value:TUCNode);
     procedure SetDuplicateOfNode(Value:TUCNode);
     procedure GetLineStates(var HasParent,HasChild,HasUpperSibling,HasLowerSibling:Boolean);
     function  IsOver:TUCNode;
     procedure PositionNode(XPos:Integer;var YPos:Integer);
     procedure ResetNodePositions;
     procedure DetachSelected;
     procedure UnlinkSelected;
     procedure SetChildrenUser;
     procedure SetParentUser;
     procedure DeleteSelected;
     procedure CollapseSelected;
     procedure SelectTree;
     procedure SetHighLight(Value:Boolean);
  public
     constructor Create(AOwner:TComponent); override;
     destructor Destroy; override;
     procedure Paint; override;
     procedure AssignTo(Dest: TPersistent); override;
     procedure MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
     procedure MouseUp  (Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
     procedure MouseMove(Shift:TShiftState;X,Y:Integer); override;
     function CaptionString:String;
     property ParentForm  :TUCSDForm read FParentForm   write FParentForm;
     property Selected    :Boolean   read FSelected     write FSelected  ;
     property HighLight   :Boolean   read FHighLight    write SetHighLight ;
     property Moving      :Boolean   read FMoving       write FMoving    ;
     property ChildNodes  :TList     read FChildNodes   write FChildNodes;
     property DuplicatedIn:TList     read FDuplicatedIn write FDuplicatedIn;
  published
     property Left   stored False;
     property Top    stored False;
     property Width  stored False;
     property Height stored False;
     property ParentNode  :TUCNode   read FParentNode   write SetParentNode;
     property DuplicateOf :TUCNode   read FDuplicateOf  write SetDuplicateOfNode;
     property Caption                read GetCaption    write SetCaption   ;
     property Text        :String    read GetText       write SetText      ;
     property User        :String    read GetUser       write SetUser      ;
     property Verb        :String    read GetVerb       write SetVerb      ;
     property Note        :String    read GetNote       write SetNote      ;
     property BRules      :String    read GetBRules     write SetBRules    ;
     property Clarif      :String    read GetClarif     write SetClarif    ;
     property BoxHeight   :Integer   read FBoxHeight    write FBoxHeight   stored False;
     property Collapsed   :Boolean   read FCollapsed    write FCollapsed   default False;
  end;
  TUCSDForm = class(TSavePosForm)
    Panel1: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    MainPad: TScrollBox;
    Splitter1: TSplitter;
    N1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Close1: TMenuItem;
    od: TOpenDialog;
    SD: TSaveDialog;
    Document1: TMenuItem;
    All1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    N3: TMenuItem;
    UseCaseHelp1: TMenuItem;
    PopupMenu1: TPopupMenu;
    NewUseCase1: TMenuItem;
    DetachNodefromParent1: TMenuItem;
    DeleteNode1: TMenuItem;
    PrintDiagram1: TMenuItem;
    Print1: TMenuItem;
    N4: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Panel4: TPanel;
    Panel3: TPanel;
    Label3: TLabel;
    CaptionEdit: TEdit;
    TabSheet2: TTabSheet;
    Panel5: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    OFile: TEdit;
    DFile: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Heading: TEdit;
    Normal: TEdit;
    Emphasis: TEdit;
    UserEdit: TEdit;
    TabSheet3: TTabSheet;
    Label9: TLabel;
    ComboBox1: TComboBox;
    Label10: TLabel;
    Panel6: TPanel;
    ProdImage: TImage;
    OPD: TOpenPictureDialog;
    ComboBox2: TComboBox;
    Label11: TLabel;
    ComboBox3: TComboBox;
    Label12: TLabel;
    Panel7: TPanel;
    Label1: TLabel;
    PopupMenu2: TPopupMenu;
    Move1: TMenuItem;
    Copy1: TMenuItem;
    N2: TMenuItem;
    Cancel1: TMenuItem;
    N5: TMenuItem;
    UnlinkfromDuplicates1: TMenuItem;
    Node2: TMenuItem;
    New1: TMenuItem;
    Delete1: TMenuItem;
    Detach1: TMenuItem;
    Unlink1: TMenuItem;
    CollapseNode1: TMenuItem;
    Collapse1: TMenuItem;
    VerbEdit: TEdit;
    Edit1: TMenuItem;
    Undo1: TMenuItem;
    Copy2: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    N6: TMenuItem;
    PasteasChild1: TMenuItem;
    N7: TMenuItem;
    PasteasDuplicate1: TMenuItem;
    Node1: TMenuItem;
    PageControl2: TPageControl;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TextEdit: TMemo;
    ListBox1: TListBox;
    BEdit: TMemo;
    NEdit: TMemo;
    CEdit: TMemo;
    Full1: TMenuItem;
    Titles: TEdit;
    Label2: TLabel;
    Introduction: TMemo;
    procedure Exit1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure NewUseCase1Click(Sender: TObject);
    procedure MainPadMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DetachNodefromParent1Click(Sender: TObject);
    procedure DeleteNode1Click(Sender: TObject);
    procedure PrintDiagram1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure All1Click(Sender: TObject);
    procedure Node1Click(Sender: TObject);
    procedure Full1Click(Sender: TObject);
    procedure ProdImageClick(Sender: TObject);
    procedure ComboBox1Exit(Sender: TObject);
    procedure Move1Click(Sender: TObject);
    procedure Cancel1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure UnlinkfromDuplicates1Click(Sender: TObject);
    procedure CollapseNode1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure IntroductionChange(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Copy2Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    FUCNode:TUCNode;
    FModified:Boolean;
    CanUndo:Boolean;
    UndoList:TList;
    procedure EmptyUndoList;
    procedure SetModified(Value:Boolean);
    procedure SaveState;
    function CheckSave:Boolean;
  public
    OrigX,OrigY:Integer;
    CurrentDropTarget:TUCNode;
    procedure LoadFromFile(FileName:String);
    procedure SaveToFile(FileName:String);
    procedure SetCurrentNode(UCNode:TUCNode);
    procedure InsertTextInWord(WSel:Variant;Text:String;Indent:String);
    procedure InsertParentTextInWord(ParentNode:TUCNode;WSel:Variant;Indent:String);
    procedure InsertChildTextInWord(ChildNodes:TList;WSel:Variant;Indent:String);
    procedure CreateMetafile(FileName:String;var Ratio:Real);
    property Modified:Boolean read FModified write SetModified;
  end;

var
  UCSDForm:TUCSDForm;

implementation

{$R *.DFM}
function CalcColor(Color:TColor;Offset,Mag:Integer):TColor;
var
   R,G,B:Integer;
begin
   Mag:=Offset*Mag;
   Color:=ColorToRGB(Color);
   R:=((Color and $0000FF)       )+Mag;
   G:=((Color and $00FF00) shr 8 )+Mag;
   B:=((Color and $FF0000) shr 16)+Mag;
   if R > 255 then R:=255 else if R < 0 then R:=0;
   if G > 255 then G:=255 else if G < 0 then G:=0;
   if B > 255 then B:=255 else if B < 0 then B:=0;
   Result:=RGB(R,G,B);
end;
procedure DrawRim(Canvas:TCanvas;R:TRect;LTColor,BRColor:TColor;IsDown:Boolean);
begin
   with Canvas do
   begin
      with R do
      begin
         Pen.Color:=LTColor;
         if not IsDown then
         begin
            Brush.Color:=LTColor;
            PolyLine([Point(Left,Bottom),Point(Left,Top),Point(Right,Top)]);
         end;
         Pen.Color:=BRColor;
         PolyLine([Point(Right,Top),Point(Right,Bottom),Point(Left,Bottom)]);
      end;
   end;
end;
procedure DrawButton(Canvas:TCanvas;var R:TRect;Color:TColor;BevelWidth,ColourDepth:Integer;DrawBorder,IsDown:Boolean;ShadowLength:Integer;BevelType:TBevelType);
var
   I:Integer;
begin
   with Canvas do
   begin
      Brush.Color:=CalcColor(Color,0,ColourDepth);
      if IsDown then
         FillRect(R);
      R.Bottom:=R.Bottom-ShadowLength;
      R.Right:=R.Right-ShadowLength;
      if IsDown then
      begin
         InflateRect(R,-2,-2);
         Color:=CalcColor(Color,-1,3);
      end
      else
      begin
         Pen.Color:=CalcColor(Color,0-BevelWidth div 2,ColourDepth);
         with R do
            for I:=0 to ShadowLength-1 do
               PolyLine([Point(Left+I,Bottom+I),Point(Right+I,Bottom+I),Point(Right+I,Top+I)]);
      end;
      if DrawBorder then
      begin
         Pen.Color:=clBlack;
         Rectangle(R.Left,R.Top,R.Right+1,R.Bottom+1);
         InflateRect(R,-1,-1);
      end;
      FillRect(R);
      for I:=0 to BevelWidth do
      begin
         if (BevelType = btOuterOnly) and (I > BevelWidth div 2) then break;
         if (BevelType <> btInnerOnly) or (I > BevelWidth div 2)  or (I =0) then
         begin
            DrawRim(Canvas,R,CalcColor(Color,(BevelWidth div 2)-I,ColourDepth),CalcColor(Color,(0-(BevelWidth div 2))+I,ColourDepth),False);
         end;
         InflateRect(R,-1,-1);
      end;
      InflateRect(R,1,1);
      Brush.Color:=CalcColor(Color,0,ColourDepth);
      FillRect(R);
   end;
end;

procedure TUCSDForm.SaveState;
var
   US:TMemoryStream;
begin
   Undo1.Enabled:=True;
   US:=TMemoryStream.Create;
   US.WriteComponent(MainPad);
   UndoList.Add(US);
end;
procedure TUCSDForm.SetModified(Value:Boolean);
begin
//   if Value and CanUndo then
//      SaveState;
   FModified:=Value;
end;
function GetComponentAsText(Comp:TComponent):String;
var
   MS:TMemoryStream;
   SS:TStringStream;
begin
   MS:=TMemoryStream.Create;
   SS:=TStringStream.Create('');
   MS.WriteComponent(Comp); // write published properties
   MS.Position:=0;
   ObjectBinaryToText(MS,SS);
   MS.Free;
   SS.Position:=0;
   Result:=SS.DataString;
   SS.Free;
end;
function GetComponentFromText(S:String):TComponent;
var
   MS:TMemoryStream;
   SS:TStringStream;
begin
   MS:=TMemoryStream.Create;
   SS:=TStringStream.Create(S);
   SS.Position:=0;
   ObjectTextToBinary(SS,MS);
   MS.Position:=0;
//   Result:=nil;
   Result:=MS.ReadComponent(nil); // read published properties
   MS.Free;
   SS.Free;
end;
function NewComponentName(Parent:TComponent;StartName:String):String;
var
   NameCount:Integer;
begin
   NameCount:=0;
   while Parent.FindComponent(StartName+IntToHex(NameCount,4)) <> nil do
      Inc(NameCount);
   Result:=StartName+IntToHex(NameCount,4);
end;

procedure TUCSDForm.LoadFromFile(FileName:String);
var
   MS:TMemoryStream;
   FS:TFileStream;
   I:Integer;
   UCConfig:TUCConfig;
begin
    CanUndo:=False;
    EmptyUndoList;
    UCConfig:=nil;
    FUCNode:=nil;
    Panel2.RemoveControl(MainPad);
    MS:=TMemoryStream.Create;
    FS:=TFileStream.Create(FileName,fmOpenRead);
    MainPad.Free;
    MainPad:=TScrollBox.Create(UCSDForm);
    ObjectTextToBinary(FS,MS);
    MS.Position:=0;
    MS.ReadComponent(MainPad);
    FS.Free;
    MS.Free;
    Panel2.InsertControl(MainPad);
    for I:=0 to MainPad.ComponentCount-1 do
    begin
       if MainPad.Components[I] is TUCNode then
       begin
          (MainPad.Components[I] as TUCNode).ParentForm:=Self;
          if (Copy((MainPad.Components[I] as TUCNode).Name,1,7) = 'UseCase')
          or (Copy((MainPad.Components[I] as TUCNode).Name,1,2) = 'UA')
          or (Copy((MainPad.Components[I] as TUCNode).Name,1,2) = 'UC') then
             (MainPad.Components[I] as TUCNode).Name:=NewComponentName(MainPad,'U');
       end
       else if MainPad.Components[I] is TUCConfig then
       begin
          UCConfig:=MainPad.Components[I] as TUCConfig;
       end;
    end;
    if UCConfig <> nil then
    begin
       Introduction.Text:=UCConfig.Introduction ;
       OFile       .Text:=UCConfig.OutputFile   ;
       DFile       .Text:=UCConfig.TemplateFile ;
       Heading     .Text:=UCConfig.HeadingStyle ;
       Normal      .Text:=UCConfig.NormalStyle  ;
       Emphasis    .Text:=UCConfig.EmphasisStyle;
       Titles      .Text:=UCConfig.TitlesStyle  ;
       MainPad.RemoveControl(UCConfig);
    end;
    MainPad.OnMouseDown:=MainPadMouseDown;
    Caption:='Use Case Scenario Developer - '+ExtractFileName(OD.FileName);
    if MainPad.ComponentCount > 0 then
       (MainPad.Components[0] as TUCNode).ResetNodePositions;
    MainPad.HorzScrollBar.Position:=0;
    MainPad.VertScrollBar.Position:=0;
    Modified:=False;
    CanUndo:=True;
end;
function CompareFunc(Item1, Item2: Pointer): Integer;
begin
   if TReorder(Item1).Node.Top < TReorder(Item2).Node.Top then Result:=-2
   else if TReorder(Item1).Node.Top > TReorder(Item2).Node.Top then Result:=2
   else if TReorder(Item1).Node.Left < TReorder(Item2).Node.Left then Result:=-1
   else if TReorder(Item1).Node.Left > TReorder(Item2).Node.Left then Result:=1
   else Result:=0;
end;
procedure AddNodesToList(Node:TUCNode;List:TList);
var
   I:Integer;
   ReOrder:TReorder;
begin
   if Node.ParentNode = nil then
   begin
      ReOrder:=TReorder.Create;
      ReOrder.Node:=Node;
      List.Add(ReOrder);
   end;
   for I:=0 to Node.ChildNodes.Count-1 do
   begin
      ReOrder:=TReorder.Create;
      ReOrder.Node:=TUCNode(Node.ChildNodes[I]);
      List.Add(ReOrder);
   end;
   for I:=0 to Node.ChildNodes.Count-1 do
      AddNodesToList(TUCNode(Node.ChildNodes[I]),List);
end;
procedure TUCSDForm.SaveToFile(FileName:String);
var
   MS:TMemoryStream;
   OS:TFileStream;
   UCConfig:TUCConfig;
   HSBP:Integer;
   VSBP:Integer;
   ReOrderList:TList;
   ReOrder:TReorder;
   I:Integer;
begin
   ReOrderList:=TList.Create;
   for I:=0 to MainPad.ControlCount-1 do
   begin
      if TUCNode(MainPad.Controls[I]).ParentNode = nil then
      begin
         AddNodesToList(TUCNode(MainPad.Controls[I]),ReOrderList);
      end;
   end;
   while MainPad.ControlCount > 0 do
      MainPad.RemoveControl(MainPad.Controls[0]);
   for I:=0 to ReOrderList.Count-1 do
   begin
      ReOrder:=TReorder(ReOrderList[I]);
      MainPad.InsertControl(ReOrder.Node);
   end;
   for I:=0 to ReOrderList.Count-1 do
      TReorder(ReOrderList[I]).Free;
   ReOrderList.Free;
   CanUndo:=False;
   HSBP:=MainPad.HorzScrollBar.Position;
   VSBP:=MainPad.VertScrollBar.Position;
   MainPad.HorzScrollBar.Position:=0;
   MainPad.VertScrollBar.Position:=0;
   MS:=TMemoryStream.Create;
   OS:=TFileStream.Create(FileName,fmCreate);
   UCConfig:=TUCConfig.Create(MainPad);
   UCConfig.Introduction :=Introduction.Text;
   UCConfig.OutputFile   :=OFile.Text;
   UCConfig.TemplateFile :=DFile.Text;
   UCConfig.HeadingStyle :=Heading.Text;
   UCConfig.NormalStyle  :=Normal.Text;
   UCConfig.EmphasisStyle:=Emphasis.Text;
   UCConfig.TitlesStyle  :=Titles.Text;
   MainPad.InsertControl(UCConfig);
   MS.WriteComponent(MainPad); // write published properties
   MainPad.RemoveControl(UCConfig);
   UCConfig.Free;

   MS.Position:=0;
   ObjectBinaryToText(MS,OS);
   OS.Free;
   MS.Free;

   MainPad.HorzScrollBar.Position:=HSBP;
   MainPad.VertScrollBar.Position:=VSBP;
   Modified:=False;
   CanUndo:=True;
end;
{TUCNode}
constructor TUCNode.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   FSelected:=False;
   FCollapsed:=False;
   FMoving:=False;
   FParentNode:=nil;
   FDuplicateOf:=nil;
   FDuplicatedIn:=TList.Create;
   FChildNodes:=TList.Create;
   FUser:='Clerk';
   FVerb:='';
   Name:='';
   Caption:='';
   FText:='';
   FNote:='';
   FBRules:='';
   FClarif:='';
   Canvas.Font.Style:=[fsBold];
end;
destructor TUCNode.Destroy;
begin
   FParentNode:=nil;
   FChildNodes.Free;
   FDuplicatedIn.Free;
   inherited Destroy;
end;
procedure TUCNode.AssignTo(Dest: TPersistent);
var
   DestNode:TUCNode;
begin
   if (Dest is TUCNode) then
   begin
      DestNode:=(Dest as TUCNode);
      DestNode.ForceCaption(Caption,True);
      DestNode.FText        :=FText        ;
      DestNode.FNote        :=FNote        ;
      DestNode.FBRules      :=FBRules      ;
      DestNode.FClarif      :=FClarif      ;
      DestNode.FParentForm  :=FParentForm  ;
      DestNode.FSelected    :=FSelected    ;
      DestNode.FCollapsed   :=FCollapsed   ;
      DestNode.FHighLight   :=FHighLight   ;
      DestNode.FMoving      :=FMoving      ;
      DestNode.FBoxHeight   :=FBoxHeight   ;
      DestNode.FUser        :=FUser        ;
      DestNode.FVerb        :=FVerb        ;
      DestNode.Left         :=Left         ;
      DestNode.Top          :=Top          ;
      DestNode.Width        :=Width        ;
      DestNode.Height       :=Height       ;
   end
   else
   begin
      inherited AssignTo(Dest);
   end;
end;
procedure TUCNode.SetHighLight(Value:Boolean);
begin
   if FHighLight <> Value then
   begin
      FHighLight:=Value;
      Invalidate;
   end;
end;
procedure TUCNode.SetParentNode(Value:TUCNode);
var
  Index:Integer;
  PN:TUCNode;
begin
   PN:=Value;
   while (PN <> nil) and (PN <> Self) do
      PN:=PN.ParentNode;
   if PN = Self then Exit; // circular reference

   if FParentNode <> nil then
   begin
      ParentForm.Modified:=True;
      Index:=FParentNode.ChildNodes.IndexOf(Self);
      if Index >= 0 then
         FParentNode.ChildNodes.Delete(Index);
   end;

   FParentNode:=Value;
   if FParentNode <> nil then
      FParentNode.ChildNodes.Add(Self);
end;
procedure TUCNode.SetDuplicateOfNode(Value:TUCNode);
var
  Index:Integer;
begin
   if Value = Self then Exit;
   if ParentForm <> nil then
      ParentForm.Modified:=True;

   if FDuplicateOf <> nil then
   begin
      Index:=FDuplicateOf.DuplicatedIn.IndexOf(Self);
      if Index >= 0 then
         FDuplicateOf.DuplicatedIn.Delete(Index);
   end;
   FDuplicateOf:=Value;
   if csLoading in ComponentState then
   begin
      FUser      :=FDuplicateOf.FUser;
      ForceVerb   (FDuplicateOf.Verb   ,True);
      ForceText   (FDuplicateOf.Text   ,True);
      ForceCaption(FDuplicateOf.Caption,True);
      ForceNote   (FDuplicateOf.Note  ,True);
      ForceBRules (FDuplicateOf.BRules,True);
      ForceClarif (FDuplicateOf.Clarif,True);
   end;        
   if FDuplicateOf <> nil then
      FDuplicateOf.DuplicatedIn.Add(Self);
end;
function TUCNode.GetCaption:TCaption;
begin
   if (csWriting in ComponentState) and (FDuplicateOf <> nil) then
      Result:=''
   else
      Result:=inherited Caption;
end;
function TUCNode.GetText:String;
begin
   if (csWriting in ComponentState) and (FDuplicateOf <> nil) then
      Result:=''
   else
      Result:=FText;
end;
function TUCNode.GetUser:String;
begin
   if (csWriting in ComponentState) and (FDuplicateOf <> nil) then
      Result:=''
   else
      Result:=FUser;
end;
function TUCNode.GetVerb:String;
begin
   if (csWriting in ComponentState) and (FDuplicateOf <> nil) then
      Result:=''
   else
      Result:=FVerb;
end;
function TUCNode.GetNote:String;
begin
   if (csWriting in ComponentState) and (FDuplicateOf <> nil) then
      Result:=''
   else
      Result:=FNote;
end;
function TUCNode.GetBRules:String;
begin
   if (csWriting in ComponentState) and (FDuplicateOf <> nil) then
      Result:=''
   else
      Result:=FBRules;
end;
function TUCNode.GetClarif:String;
begin
   if (csWriting in ComponentState) and (FDuplicateOf <> nil) then
      Result:=''
   else
      Result:=FClarif;
end;

procedure TUCNode.SetUser(Value:String);
begin
   if ParentForm <> nil then
      ParentForm.Modified:=True;
   if (csReading in ComponentState) and (FDuplicateOf <> nil) then
      FUser:=FDuplicateOf.FUser
   else
      FUser:=Value;
end;
procedure TUCNode.SetText(Value:String);
begin
   if ParentForm <> nil then
      ParentForm.Modified:=True;
   if (csReading in ComponentState) and (FDuplicateOf <> nil) then
      ForceText(FDuplicateOf.FUser,False)
   else
      ForceText(Value,False);
end;
procedure TUCNode.ForceNote(Value:TCaption;Force:Boolean);
var
   I:Integer;
begin
   if (not Force) and (FDuplicateOf <> nil) then
   begin
      FDuplicateOf.Note:=Value;
      Exit;
   end;
   if FDuplicatedIn.Count > 0 then
   begin
      for I:=0 to FDuplicatedIn.Count-1 do
         TUCNode(FDuplicatedIn[I]).ForceNote(Value,True);
   end;
   FNote:=Value;
end;
procedure TUCNode.ForceBRules(Value:TCaption;Force:Boolean);
var
   I:Integer;
begin
   if (not Force) and (FDuplicateOf <> nil) then
   begin
      FDuplicateOf.BRules:=Value;
      Exit;
   end;
   if FDuplicatedIn.Count > 0 then
   begin
      for I:=0 to FDuplicatedIn.Count-1 do
         TUCNode(FDuplicatedIn[I]).ForceBRules(Value,True);
   end;
   FBRules:=Value;
end;
procedure TUCNode.ForceClarif(Value:TCaption;Force:Boolean);
var
   I:Integer;
begin
   if (not Force) and (FDuplicateOf <> nil) then
   begin
      FDuplicateOf.Clarif:=Value;
      Exit;
   end;
   if FDuplicatedIn.Count > 0 then
   begin
      for I:=0 to FDuplicatedIn.Count-1 do
         TUCNode(FDuplicatedIn[I]).ForceClarif(Value,True);
   end;
   FClarif:=Value;
end;
procedure TUCNode.ForceText(Value:TCaption;Force:Boolean);
var
   I:Integer;
begin
   if (not Force) and (FDuplicateOf <> nil) then
   begin
      FDuplicateOf.Text:=Value;
      Exit;
   end;
   if FDuplicatedIn.Count > 0 then
   begin
      for I:=0 to FDuplicatedIn.Count-1 do
         TUCNode(FDuplicatedIn[I]).ForceText(Value,True);
   end;
   FText:=Value;
end;

procedure TUCNode.SetVerb(Value:String);
begin
   if ParentForm <> nil then
      ParentForm.Modified:=True;
   if (csReading in ComponentState) and (FDuplicateOf <> nil) then
      ForceVerb(FDuplicateOf.FVerb,False)
   else
      ForceVerb(Value,False);
end;
procedure TUCNode.SetNote(Value:String);
begin
   if ParentForm <> nil then
      ParentForm.Modified:=True;
   if (csReading in ComponentState) and (FDuplicateOf <> nil) then
      ForceNote(FDuplicateOf.FNote,False)
   else
      ForceNote(Value,False);
end;
procedure TUCNode.SetClarif(Value:String);
begin
   if ParentForm <> nil then
      ParentForm.Modified:=True;
   if (csReading in ComponentState) and (FDuplicateOf <> nil) then
      ForceClarif(FDuplicateOf.FClarif,False)
   else
      ForceClarif(Value,False);
end;
procedure TUCNode.SetBRules(Value:String);
begin
   if ParentForm <> nil then
      ParentForm.Modified:=True;
   if (csReading in ComponentState) and (FDuplicateOf <> nil) then
      ForceBRules(FDuplicateOf.FBRules,False)
   else
      ForceBRules(Value,False);
end;
procedure TUCNode.ForceVerb(Value:TCaption;Force:Boolean);
var
   I:Integer;
begin
   if (not Force) and (FDuplicateOf <> nil) then
   begin
      FDuplicateOf.Verb:=Value;
      Exit;
   end;
   if FDuplicatedIn.Count > 0 then
   begin
      for I:=0 to FDuplicatedIn.Count-1 do
         TUCNode(FDuplicatedIn[I]).ForceVerb(Value,True);
   end;
   FVerb:=Value;
end;
procedure TUCNode.SetCaption(Value:TCaption);
begin
   if ParentForm <> nil then
      ParentForm.Modified:=True;
   if (csReading in ComponentState) and (FDuplicateOf <> nil) then
      ForceCaption(FDuplicateOf.Caption,False)
   else
      ForceCaption(Value,False);
end;
procedure TUCNode.ForceCaption(Value:TCaption;Force:Boolean);
var
   H:Integer;
   R:TRect;
   I:Integer;
   TCap:String;
begin
   if (not Force) and (FDuplicateOf <> nil) then
   begin
      FDuplicateOf.Caption:=Value;
      Exit;
   end;
   if Copy(Value,1,Length(FUser)) = FUser then
      Value:=Trim(Copy(Value,Length(FUser)+1,Length(Value)));
   if Copy(Value,1,Length(FVerb)) = FVerb then
      Value:=Trim(Copy(Value,Length(FVerb)+1,Length(Value)));
   TCap:=Caption;
   if FDuplicatedIn.Count > 0 then
   begin
      for I:=0 to FDuplicatedIn.Count-1 do
         TUCNode(FDuplicatedIn[I]).ForceCaption(Value,True);
   end;
   inherited Caption:=Value;
   if (csLoading in ComponentState) or (Parent = nil) or (Parent is TCopyPad) then Exit;
   R:=Bounds(0,0,Width,FBoxHeight);
   InflateRect(R,-12,-7);
   H:=DrawText(Canvas.Handle,PChar(Value),-1,R,DT_WORDBREAK or DT_CALCRECT);
   if (not FCollapsed) and (FBoxHeight <> H+14) then
   begin
      FBoxHeight:=H+14;
      if Height < FBoxHeight then Height:=FBoxHeight;
   end
   else if TCap <> Value then
   begin
      Invalidate;
   end;
end;
procedure TUCNode.MoveSelected(X,Y:Integer);
var
   I:Integer;
begin
   for I:=0 to Parent.ComponentCount-1 do
   begin
      if (Parent.Components[I] is TUCNode) and ((Parent.Components[I] as TUCNode).Selected) then
      begin
         (Parent.Components[I] as TUCNode).Left:=(Parent.Components[I] as TUCNode).Left-X;
         (Parent.Components[I] as TUCNode).Top :=(Parent.Components[I] as TUCNode).Top -Y;
      end;
   end;
end;
procedure TUCNode.SelectTree;
var
   I:Integer;
begin
   FSelected:=True;
   for I:=0 to ChildNodes.Count-1 do
      TUCNode(ChildNodes[I]).SelectTree;
end;
procedure TUCNode.CollapseSelected;
var
   I:Integer;
   UCNode:TUCNode;
   State:Integer;
begin
   for I:=0 to Parent.ComponentCount-1 do
   begin
      if (Parent.Components[I] is TUCNode) and ((Parent.Components[I] as TUCNode).Selected) then
      begin
         (Parent.Components[I] as TUCNode).SelectTree;
      end;
   end;
   State:=0;
   for I:=0 to Parent.ComponentCount-1 do
   begin
      if (Parent.Components[I] is TUCNode) and ((Parent.Components[I] as TUCNode).Selected) then
      begin
         UCNode:=(Parent.Components[I] as TUCNode);
         if State = 0 then
         begin
            if UCNode.Collapsed then
               State:=1
            else
               State:=2;
         end;
         if State = 1 then
            UCNode.Collapsed:=False
         else
            UCNode.Collapsed:=True;
      end;
   end;
   ResetNodePositions;
end;

procedure TUCNode.DeleteSelected;
var
   I:Integer;
   UCNode:TUCNode;
begin
   I:=0;
   while I < Parent.ComponentCount do
   begin
      if (Parent.Components[I] is TUCNode) and ((Parent.Components[I] as TUCNode).Selected) then
      begin
         UCNode:=(Parent.Components[I] as TUCNode);
         UCNode.ParentNode:=nil;
         while UCNode.ChildNodes.Count > 0 do
            TUCNode(UCNode.ChildNodes[0]).ParentNode:=nil;
         UCNode.ParentNode:=nil;

         UCNode.DuplicateOf:=nil;
         if UCNode.DuplicatedIn.Count > 0 then
         begin
            while UCNode.DuplicatedIn.Count > 1 do
                 TUCNode(UCNode.DuplicatedIn[1]).DuplicateOf:=TUCNode(UCNode.DuplicatedIn[0]);
            TUCNode(UCNode.DuplicatedIn[0]).DuplicateOf:=nil;
         end;
         Parent.RemoveControl(UCNode);
         UCNode.Free;
      end
      else
         Inc(I);
   end;
   ResetNodePositions;
end;
procedure TUCNode.SetChildrenUser;
var
   I:Integer;
begin
   ParentForm.Modified:=True;
   for I:=0 to ChildNodes.Count-1 do
   begin
      TUCNode(ChildNodes[I]).User:=User;
      TUCNode(ChildNodes[I]).SetChildrenUser;
   end;
end;
procedure TUCNode.SetParentUser;
begin
   ParentForm.Modified:=True;
   if ParentNode <> nil then
   begin
      ParentNode.User:=FUser;
      ParentNode.SetParentUser;
   end
   else
   begin
      SetChildrenUser;
   end;
end;
procedure TUCNode.UnlinkSelected;
var
   I:Integer;
   UCNode:TUCNode;
begin
   for I:=0 to Parent.ComponentCount-1 do
   begin
      if (Parent.Components[I] is TUCNode) and ((Parent.Components[I] as TUCNode).Selected) then
      begin
         UCNode:=(Parent.Components[I] as TUCNode);
         UCNode.DuplicateOf:=nil;
         if UCNode.DuplicatedIn.Count > 0 then
         begin
            while UCNode.DuplicatedIn.Count > 1 do
                 TUCNode(UCNode.DuplicatedIn[1]).DuplicateOf:=TUCNode(UCNode.DuplicatedIn[0]);
            TUCNode(UCNode.DuplicatedIn[0]).DuplicateOf:=nil;
         end;
      end;
   end;
   ResetNodePositions;
   Invalidate;
end;
procedure TUCNode.DetachSelected;
var
   I:Integer;
   HadDetach:Boolean;
begin
   HadDetach:=False;
   for I:=0 to Parent.ComponentCount-1 do
   begin
      if (Parent.Components[I] is TUCNode) and ((Parent.Components[I] as TUCNode).Selected) then
      begin
         (Parent.Components[I] as TUCNode).ParentNode:=nil;
         HadDetach:=True;
      end;
   end;
   if HadDetach then ResetNodePositions;
   Invalidate;
end;
function RectInRect(R1,R2:TRect):Boolean;
var
   R:TRect;
begin
   Result:=IntersectRect(R,R1,R2);
end;
function TUCNode.IsOver:TUCNode;
var
   I:Integer;
   R1:TRect;
   R2:TRect;
begin
   Result:=nil;
   R1:=Bounds(Left,Top,Width,FBoxHeight);
   for I:=0 to Parent.ComponentCount-1 do
   begin
      if (Parent.Components[I] is TUCNode) and (Parent.Components[I] <> Self) then
      begin
         with (Parent.Components[I] as TUCNode) do
            R2:=Bounds(Left,Top,Width,FBoxHeight);
         if RectInRect(R1,R2) then
         begin
            Result:=(Parent.Components[I] as TUCNode);
            Exit;
         end;
      end;
   end;
end;
procedure TUCNode.DeSelect;
var
   I:Integer;
begin
   for I:=0 to Parent.ComponentCount-1 do
   begin
      if (Parent.Components[I] is TUCNode) and ((Parent.Components[I] as TUCNode).Selected) then
      begin
         (Parent.Components[I] as TUCNode).Selected:=False;
         (Parent.Components[I] as TUCNode).Invalidate;
      end;
   end;
end;
procedure TUCNode.MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
var
   R:TRect;
begin
   inherited MouseDown(Button,Shift,X,Y);
   if ParentForm.CurrentDropTarget <> nil then
      ParentForm.CurrentDropTarget.HighLight:=False;
   ParentForm.CurrentDropTarget:=nil;
   R:=Bounds(0,0,Width,FBoxHeight);
   if not PtInRect(R,Point(X,Y)) then
   begin
      DeSelect;
      ParentForm.OrigX:=Left+X;
      ParentForm.OrigY:=Top+Y;
      Exit;
   end;
   if not FMoving then
   begin
      if (not FSelected) and (not (ssShift in Shift)) then
         Deselect;
      if not FCollapsed then
         Height:=FBoxHeight;
      FSelected:=True;
      ParentForm.OrigX:=X;
      ParentForm.OrigY:=Y;
      FMoving:=True;
      ParentForm.SetCurrentNode(Self);
      Invalidate;
   end;
end;
procedure TUCNode.PositionNode(XPos:Integer;var YPos:Integer);
var
   I:Integer;
begin
   if FCollapsed then
   begin
      Height:=5;
      Width:=30;
      FBoxHeight:=Height;
   end
   else
   begin
      Height:=FBoxHeight;
      if Width <> 180 then Width:=180;
   end;
   Left:=XPos;
   Inc(XPos,Width);
   Top:=YPos;
   Caption:=Caption;
   for I:=0 to ChildNodes.Count-1 do
      TUCNode(ChildNodes[I]).PositionNode(XPos,YPos);
   if YPos < Top+Height then
      Inc(YPos,Height);
   Height:=(YPos-Top);
end;

procedure AddToNodeList(Node:TUCNode;List:TList);
var
   I:Integer;
begin
   List.Add(Node);
   for I:=0 to Node.ChildNodes.Count-1 do
      AddToNodeList(TUCNode(Node.ChildNodes[I]),List);
end;
procedure TUCNode.ResetNodePositions;
var
   PN:TUCNode;
   I:Integer;
   TopOfs:Integer;
   HSBP:Integer;
   VSBP:Integer;
begin
   HSBP:=ParentForm.MainPad.HorzScrollBar.Position;
   VSBP:=ParentForm.MainPad.VertScrollBar.Position;
   ParentForm.MainPad.HorzScrollBar.Position:=0;
   ParentForm.MainPad.VertScrollBar.Position:=0;
   TopOfs:=10;
   for I:=0 to Parent.ComponentCount-1 do
   begin
      if (Parent.Components[I] is TUCNode) then
      begin
         PN:=(Parent.Components[I] as TUCNode);
         if PN.ParentNode = nil then
         begin
            PN.PositionNode(10,TopOfs);
         end;
      end;
   end;
   ParentForm.MainPad.HorzScrollBar.Position:=HSBP;
   ParentForm.MainPad.VertScrollBar.Position:=VSBP;
end;
procedure TUCNode.MouseUp(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
var
   Over:TUCNode;
   P:TPoint;
begin
   inherited MouseUp(Button,Shift,X,Y);
   if ParentForm.CurrentDropTarget <> nil then
      ParentForm.CurrentDropTarget.HighLight:=False;
   ParentForm.CurrentDropTarget:=nil;
   FMoving:=False;
   Over:=IsOver;
   if Over <> nil then
   begin
      P:=ClientToScreen(Point(X,Y));
      ParentForm.PopupMenu2.Popup(P.X,P.Y);
   end
   else
      Invalidate;
end;
procedure TUCNode.MouseMove(Shift:TShiftState;X,Y:Integer);
var
   Over:TUCNode;
begin
   if FMoving then
   begin
      if not FCollapsed then
         Height:=FBoxHeight;
      MoveSelected(ParentForm.OrigX-X,ParentForm.OrigY-Y);
      Over:=IsOver;
      if Over <> ParentForm.CurrentDropTarget then
      begin
         if ParentForm.CurrentDropTarget <> nil then
            ParentForm.CurrentDropTarget.HighLight:=False;
         ParentForm.CurrentDropTarget:=Over;
         if ParentForm.CurrentDropTarget <> nil then
            ParentForm.CurrentDropTarget.HighLight:=True;
      end;
   end;
end;
procedure TUCNode.GetLineStates(var HasParent,HasChild,HasUpperSibling,HasLowerSibling:Boolean);
begin
   HasParent      :=False;
   HasChild       :=False;
   HasUpperSibling:=False;
   HasLowerSibling:=False;
   if FParentNode <> nil then
   begin
      HasParent:=True;

      if FParentNode.ChildNodes.IndexOf(Self) > 0 then
         HasUpperSibling:=True;

      if FParentNode.ChildNodes.IndexOf(Self) < FParentNode.ChildNodes.Count-1 then
         HasLowerSibling:=True;
   end;
   if ChildNodes.Count > 0 then
      HasChild:=True;
end;
function TUCNode.CaptionString:String;
begin
   Result:=Trim(FUser);
   if Trim(FVerb) <> '' then
      Result:=Result+' '+Trim(FVerb)+' '+Trim(inherited Caption)
   else
      Result:=Result+' '+Trim(inherited Caption);
end;
procedure TUCNode.Paint;
var
   SaveR:TRect;
   R:TRect;
   H:Integer;
   HasParent:Boolean;
   HasChild:Boolean;
   HasUpperSibling:Boolean;
   HasLowerSibling:Boolean;
begin
   with Canvas do
   begin
      if not FMoving then
      begin
         GetLineStates(HasParent,HasChild,HasUpperSibling,HasLowerSibling);
         Brush.Color:=Parent.Brush.Color;
         FillRect(ClientRect);
         R:=Bounds(0,0,Width,FBoxHeight);
         InflateRect(R,-5,0);
         Pen.Color:=clBlack;
         if HasParent then
         begin
            PolyLine([Point(0,15),Point(R.Left,15)]);
            if HasUpperSibling then
               PolyLine([Point(0,0),Point(0,15)]);
            if HasLowerSibling then
               PolyLine([Point(0,Height),Point(0,15)]);
         end;
         if HasChild then
            PolyLine([Point(R.Right,15),Point(Width,15)]);
      end
      else
      begin
         R:=ClientRect;
         InflateRect(R,-5,0);
      end;
      InflateRect(R,0,-2);
      Font.Color :=clWhite;
      if FSelected then
      begin
         if FMoving then
            Brush.Color:=clBlue
         else
            Brush.Color:=clGreen;
      end
      else
      begin
         if FHighLight then
           Brush.Color:=clRed
         else
            Brush.Color:=clNavy;
      end;
      DrawButton(Canvas,R,Brush.Color,8,20,True,False,0,btOuterOnly);
      SaveR:=R;
      H:=DrawText(Canvas.Handle,PChar(Caption),-1,R,DT_WORDBREAK or DT_CALCRECT);
      SaveR.Top:=SaveR.Top+(((SaveR.Bottom-SaveR.Top)-H) div 2);
      DrawText(Canvas.Handle,PChar(Caption),-1,SaveR,DT_WORDBREAK or DT_CENTER);
      if (FDuplicateOf <> nil) or (FDuplicatedIn.Count > 0) then
      begin
         Pen.Color:=clYellow;
         PolyLine([Point(15,2),Point(2,15)]);
      end;
   end;
end;

procedure TUCSDForm.Exit1Click(Sender: TObject);
begin
   Close;
end;
procedure TUCSDForm.Open1Click(Sender: TObject);
begin
   if not CheckSave then Exit;
   if OD.Execute then
   begin
      LoadFromFile(OD.FileName);
      SD.FileName:=OD.FileName;
      Modified:=False;
      Application.Title:='UseCase('+ExtractFileName(OD.FileName)+')';
   end;
end;
procedure TUCSDForm.SaveAs1Click(Sender: TObject);
begin
   if SD.Execute then
   begin
      SaveToFile(SD.FileName);
   end;
end;
procedure TUCSDForm.Save1Click(Sender: TObject);
begin
   if SD.FileName = '' then
   begin
      if SD.Execute then
      begin
         SaveToFile(SD.FileName);
      end;
   end
   else
      SaveToFile(SD.FileName);
end;
procedure TUCSDForm.SetCurrentNode(UCNode:TUCNode);
begin
   FUCNode:=UCNode;
   CaptionEdit.Tag:=1;
   CaptionEdit.Text:=FUCNode.Caption;
   TextEdit.Text   :=FUCNode.Text;
   UserEdit.Text   :=FUCNode.User;
   VerbEdit.Text   :=FUCNode.Verb;
   NEdit.Text      :=FUCNode.Note  ;
   BEdit.Text      :=FUCNode.BRules;
   CEdit.Text      :=FUCNode.Clarif;
   CaptionEdit.Tag:=0;
end;
function RemSpace(S:String):String;
var
   I:Integer;
begin
   Result:='';
   for I:=1 to Length(S) do
   begin
      if (Result = '') then
      begin
        if (S[I] in ['A'..'Z','a'..'z','_']) then
            Result:=Result+S[I];
      end
      else
      begin
         if (S[I] in ['0'..'9','A'..'Z','a'..'z','_']) then
            Result:=Result+S[I];
      end;
   end;
end;
procedure TUCSDForm.NameEditChange(Sender: TObject);
begin
   if FUCNode <> nil then
   begin
      if CaptionEdit.Tag <> 1 then // if not set programatically
         SaveState;
      if Sender = CaptionEdit then
      begin
         Modified:=True;
         FUCNode.Caption:=CaptionEdit.Text;
      end
      else if Sender = TextEdit then
      begin
         Modified:=True;
         FUCNode.Text:=TextEdit.Text;
      end
      else if Sender = UserEdit then
      begin
         Modified:=True;
         FUCNode.User:=UserEdit.Text;
         FUCNode.SetParentUser;
      end
      else if Sender = VerbEdit then
      begin
         Modified:=True;
         FUCNode.Verb:=VerbEdit.Text;
      end
      else if Sender = NEdit then
      begin
         Modified:=True;
         FUCNode.Note:=NEdit.Text;
      end
      else if Sender = BEdit then
      begin
         Modified:=True;
         FUCNode.BRules:=BEdit.Text;
      end
      else if Sender = CEdit then
      begin
         Modified:=True;
         FUCNode.Clarif:=CEdit.Text;
      end;
   end;            
end;
procedure TUCSDForm.NewUseCase1Click(Sender: TObject);
var
   UCNode:TUCNode;
   HSBP:Integer;
   VSBP:Integer;
begin
   SaveState;
   HSBP:=MainPad.HorzScrollBar.Position;
   VSBP:=MainPad.VertScrollBar.Position;
   UCNode:=TUCNode.Create(MainPad);
   MainPad.InsertControl(UCNode);
   UCNode.ParentForm:=Self;
   UCNode.Left:=OrigX;
   UCNode.Top :=OrigY;
   UCNode.Width:=130;
   UCNode.Height:=40;
   UCNode.FBoxHeight:=40;
   UCNode.Name:=NewComponentName(MainPad,'U');

   UCNode.Caption:='Caption';
   UCNode.Text:='Text';
   UCNode.Color:=clBtnFace;
   UCNode.DeSelect;
   SetCurrentNode(UCNode);
   MainPad.HorzScrollBar.Position:=HSBP;
   MainPad.VertScrollBar.Position:=VSBP;
   UCNode.Selected:=True;
   UCNode.Invalidate;
   PageControl1.ActivePage:=TabSheet1;
   CaptionEdit.SetFocus;
   CaptionEdit.SelectAll;
end;

procedure TUCSDForm.MainPadMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   UCNode:TUCNode;
begin
   OrigX:=X;
   OrigY:=Y;
   if Button <> mbRight then
   begin
      UCNode:=TUCNode.Create(MainPad);
      MainPad.InsertControl(UCNode);
      UCNode.ParentForm:=Self;
      UCNode.DeSelect;
      MainPad.RemoveControl(UCNode);
      UCNode.Free;
   end;
end;

procedure TUCSDForm.DetachNodefromParent1Click(Sender: TObject);
var
   UCNode:TUCNode;
begin
   SaveState;
   UCNode:=TUCNode.Create(MainPad);
   MainPad.InsertControl(UCNode);
   UCNode.ParentForm:=Self;
   UCNode.DetachSelected;
   MainPad.RemoveControl(UCNode);
   UCNode.Free;
end;

procedure TUCSDForm.DeleteNode1Click(Sender: TObject);
var
   UCNode:TUCNode;
begin
   SaveState;
   UCNode:=TUCNode.Create(MainPad);
   MainPad.InsertControl(UCNode);
   UCNode.ParentForm:=Self;
   UCNode.DeleteSelected;
   MainPad.RemoveControl(UCNode);
   UCNode.Free;
end;
procedure TUCSDForm.CreateMetaFile(FileName:String;var Ratio:Real);
var
   I:Integer;
   Comp:TWinControl;
   Extent:TRect;
   FirstComp:Boolean;
   XOfs,YOfs:Integer;
   Metafile:TMetafile;
   MFCanvas:TMetafileCanvas;
begin
   FirstComp:=True;
   for I:=0 to MainPad.ControlCount-1 do
   begin
      if MainPad.Controls[I] is TWinControl then
      begin
         Comp:=TWinControl(MainPad.Controls[I]);
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
   Metafile:=TMetafile.Create;
   Metafile.Width :=(Extent.Right-Extent.Left);
   Metafile.Height:=(Extent.Bottom-Extent.Top);
   Ratio:=Metafile.Height / Metafile.Width;
   MFCanvas:=TMetafileCanvas.Create(Metafile,0);
   MFCanvas.Font:=MainPad.Font;
   XOfs:=0-Extent.Left;
   YOfs:=0-Extent.Top;
   for I:=0 to MainPad.ControlCount-1 do
   begin
      if MainPad.Controls[I] is TWinControl then
      begin
         Comp:=TWinControl(MainPad.Controls[I]);
         if Comp.Visible then
            Comp.PaintTo(MFCanvas.Handle,XOfs+Comp.Left,YOfs+Comp.Top);
      end;
   end;

   MFCanvas.Free;
   Metafile.SaveToFile(FileName);
   Metafile.Free;
end;

procedure TUCSDForm.PrintDiagram1Click(Sender: TObject);
var
   I:Integer;
   Comp:TWinControl;
   Size:TSize;
   OSize:TSize;
   Extent:TRect;
   FirstComp:Boolean;
   X,Y:Integer;
   MaxX,MaxY:Integer;
   XOfs,YOfs:Integer;
begin
   FirstComp:=True;
   for I:=0 to MainPad.ControlCount-1 do
   begin
      if MainPad.Controls[I] is TWinControl then
      begin
         Comp:=TWinControl(MainPad.Controls[I]);
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
   if ExtractFileName(SD.FileName) <> '' then
     Printer.Title:='Use Case Hierarchy Diagram - '+ExtractFileName(SD.FileName)
   else
     Printer.Title:='Use Case Hierarchy Diagram';

   // change printer to 0.01 mm with origin top left
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
         for I:=0 to MainPad.ControlCount-1 do
         begin
            if MainPad.Controls[I] is TWinControl then
            begin
               Comp:=TWinControl(MainPad.Controls[I]);
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
end;

procedure TUCSDForm.Close1Click(Sender: TObject);
var
   Control:TControl;
begin
   if not CheckSave then Exit;
   FUCNode:=nil;
   while MainPad.ControlCount > 0 do
   begin
      Control:=MainPad.Controls[0];
      MainPad.RemoveControl(Control);
      Control.free;
   end;
   CaptionEdit.Tag:=1;
   CaptionEdit.Text:='';
   TextEdit.Text:='';
   UserEdit.Text:='Clerk';
   VerbEdit.Text:='';
   CaptionEdit.Tag:=0;
   Caption:='Use Case Scenario Developer';
   Application.Title:='Use Case';
   SD.FileName:='';
   EmptyUndoList;
   Modified:=False;
end;

procedure TUCSDForm.InsertTextInWord(WSel:Variant;Text:String;Indent:String);
var
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   SL.Text:=Text;
   for I:=0 to SL.Count-1 do
   begin
      WSel.TypeText(Indent+SL[I]);
      WSel.TypeParagraph;
   end;
   if SL.Count > 0 then
      WSel.TypeParagraph;
   SL.Free;
end;

procedure TUCSDForm.InsertParentTextInWord(ParentNode:TUCNode;WSel:Variant;Indent:String);
begin
   if ParentNode.ParentNode <> nil then
      InsertParentTextInWord(ParentNode.ParentNode,WSel,Indent);

   WSel.Style:=Emphasis.Text;
   WSel.TypeParagraph;

   WSel.TypeText(Indent+ParentNode.CaptionString);
   WSel.TypeParagraph;
   InsertTextInWord(WSel,ParentNode.Text,Indent);
end;
procedure TUCSDForm.InsertChildTextInWord(ChildNodes:TList;WSel:Variant;Indent:String);
var
   J:Integer;
begin
   if ChildNodes.Count > 0 then
   begin
      WSel.Style:=Emphasis.Text;
      for J:=0 to ChildNodes.Count-1 do
      begin
         WSel.TypeText(Indent+TUCNode(ChildNodes[J]).CaptionString);
         WSel.TypeParagraph;
         InsertTextInWord(WSel,TUCNode(ChildNodes[J]).Text,Indent);
         WSel.TypeParagraph;
         if TUCNode(ChildNodes[J]).ChildNodes.Count > 0 then
            InsertChildTextInWord(TUCNode(ChildNodes[J]).ChildNodes,WSel,Indent);
      end;
      WSel.Style:=Normal.Text;
   end;
end;
procedure TUCSDForm.All1Click(Sender: TObject);
var
   I,J:Integer;
   WB:Variant;
   Shape:Variant;
   ActiveDocument:Variant;
   SL:TStringList;
   Title:String;
   Template:String;
   UCNode:TUCNode;
   Ratio:Real;
begin
   SL:=TStringList.Create;
   WB:=CreateOleObject('Word.Application');
   Template:=DFile.Text;
   ActiveDocument:=WB.Documents.Add(Template);
   if FileExists(OFile.Text) then
      DeleteFile(OFile.Text);
   ActiveDocument.SaveAs(FileName:=OFile.Text);
   try
      WB.Selection.GoTo(What:=-1,Name:='MainDoc'); // wdGoToBookmark = -1
   except
   end;
//   WB.Selection.(What:=1,Which:=1,Count:=4);
   WB.Visible:=True;
   try
      WB.Selection.InsertBreak(7); // wdPageBreak = 7;
//      ActiveDocument.TablesOfContents.Add;
      WB.Selection.Style:=Normal.Text;
      WB.Selection.Style:=Heading.Text;
      Title:='Introduction';
      WB.Selection.TypeText(Title);
//      WB.Selection.MoveLeft(Unit:=1,Count:=1,Extend:=1); // Select Text
      WB.ActiveDocument.Indexes.MarkEntry(Range:=WB.Selection.Range,Entry:=Title,EntryAutoText:=Title);
      WB.Selection.MoveRight(Unit:=1,Count:=1,Extend:=1); // Select Text
      WB.Selection.MoveRight(Unit:=1,Count:=1,Extend:=0); // Select Text
      WB.Selection.TypeParagraph;
      WB.Selection.Style:=Normal.Text;
      WB.Selection.TypeParagraph;
      InsertTextInWord(WB.Selection,Introduction.Text,'');
      for I:=0 to MainPad.ComponentCount-1 do
      begin
         if MainPad.Components[I] is TUCNode then
         begin
            UCNode:=TUCNode(MainPad.Components[I]);
            if UCNode.DuplicateOf = nil then
            begin
               WB.Selection.Style:=Heading.Text;
               Title:=UCNode.CaptionString;
               try
                  WB.Selection.TypeText(Title);
//                  WB.Selection.MoveLeft(Unit:=1,Count:=1,Extend:=1); // Select Text
                  WB.ActiveDocument.Indexes.MarkEntry(Range:=WB.Selection.Range,Entry:=Title,EntryAutoText:=Title);
                  WB.Selection.MoveRight(Unit:=1,Count:=1,Extend:=1); // Select Text
                  WB.Selection.MoveRight(Unit:=1,Count:=1,Extend:=0); // Select Text
                  WB.Selection.TypeParagraph;
                  WB.Selection.Style:=Normal.Text;
                  WB.Selection.TypeParagraph;
                  if UCNode.ParentNode <> nil then
                  begin
                     WB.Selection.Style:=Emphasis.Text;
                     WB.Selection.TypeText('Extends: ');
                     WB.Selection.TypeText(UCNode.ParentNode.CaptionString);
                     WB.Selection.TypeParagraph;
                     WB.Selection.Style:=Normal.Text;
                  end;
                  SL.Text:=UCNode.Text;
                  for J:=0 to SL.Count-1 do
                  begin
                     WB.Selection.TypeText(SL[J]);
                     WB.Selection.TypeParagraph;
                  end;
                  if UCNode.ChildNodes.Count > 0 then
                  begin
                     WB.Selection.Style:=Emphasis.Text;
                     WB.Selection.TypeText('Extended By: ');
                     if UCNode.ChildNodes.Count > 1 then
                        WB.Selection.TypeParagraph;
                     for J:=0 to UCNode.ChildNodes.Count-1 do
                     begin
                        WB.Selection.TypeText(TUCNode(UCNode.ChildNodes[J]).CaptionString);
                        WB.Selection.TypeParagraph;
                     end;
                     WB.Selection.Style:=Normal.Text;
                     WB.Selection.TypeParagraph;
                  end;
               except
                  WB.Selection.TypeText('------------- Exception ! -------------');
                  WB.Selection.TypeParagraph;
               end;
            end;
            if (I mod 10) = 0 then ActiveDocument.Save;
         end;
      end;
   except
   end;
   SL.Free;
   CreateMetaFile('C:\UseCase.WMF',Ratio);
   WB.Selection.InsertBreak(7);
   WB.Selection.InsertBreak(7);
   WB.Selection.MoveUp(Unit:=5,Count:=1); // 5=wdLine
   Shape:=WB.Selection.InlineShapes.AddPicture('C:\UseCase.WMF',False,True);
   Shape.LockAspectRatio:=True;
   if (Ratio*500) > 720 then
   begin
      Shape.Height:=720;
      Shape.Width:=Trunc(720/Ratio);
   end
   else
   begin
      Shape.Width:=500;
      Shape.Height:=Trunc(Ratio*500);
   end;
   WB.Selection.MoveLeft(Unit:=2,Count:=1,Extend:=1); // Select Text
   WB.WordBasic.DrawDisassemblePicture;
   WB.Selection.ShapeRange.Group.Select;
   WB.Selection.ShapeRange.RelativeHorizontalPosition:=1; // relative to page
   WB.Selection.ShapeRange.RelativeVerticalPosition:=1;
   WB.Selection.ShapeRange.Left:=-999995; // centre
   WB.Selection.ShapeRange.Top:=-999995;
   WB.Selection.MoveRight(Unit:=1,Count:=1); // De-Select Text
   WB.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine
   ActiveDocument.Save;
   WB:=Unassigned;
end;
procedure TUCSDForm.Full1Click(Sender: TObject);
var
   I,J:Integer;
   WB:Variant;
   PrintList:TList;
//   Shape:Variant;
   ActiveDocument:Variant;
   SL:TStringList;
   Title:String;
   Template:String;
   UCNode:TUCNode;
//   Ratio:Real;
begin
   SL:=TStringList.Create;
   WB:=CreateOleObject('Word.Application');
   Template:=DFile.Text;
   ActiveDocument:=WB.Documents.Add(Template);
   if FileExists(OFile.Text) then
      DeleteFile(OFile.Text);
   ActiveDocument.SaveAs(FileName:=OFile.Text);
   try
      WB.Selection.GoTo(What:=-1,Name:='MainDoc'); // wdGoToBookmark = -1
   except
   end;
   WB.Visible:=True;
   try
      WB.Selection.InsertBreak(7); // wdPageBreak = 7;
      WB.Selection.Style:=Normal.Text;
      WB.Selection.Style:=Heading.Text;
      Title:='Introduction';
      WB.Selection.TypeText(Title);
      WB.Selection.TypeParagraph;
      WB.Selection.Style:=Normal.Text;
      WB.Selection.TypeParagraph;
      InsertTextInWord(WB.Selection,Introduction.Text,'');
      PrintList:=TList.Create;
      for I:=0 to MainPad.ComponentCount-1 do
      begin
         Application.ProcessMessages;
         if MainPad.Components[I] is TUCNode then
         begin
            UCNode:=TUCNode(MainPad.Components[I]);
            if UCNode.ParentNode = nil then
               AddToNodeList(UCNode,PrintList);
         end;
      end;
      for I:=0 to PrintList.Count-1 do
      begin      
         UCNode:=TUCNode(PrintList[I]);
         WB.Selection.Style:=Heading.Text;
         Title:=UCNode.CaptionString;
         try
            WB.Selection.TypeText(Title);
            WB.Selection.TypeParagraph;
            WB.Selection.Style:=Normal.Text;
            WB.Selection.TypeParagraph;
            if UCNode.ParentNode <> nil then
            begin
               WB.Selection.Style:=Emphasis.Text;
               WB.Selection.TypeText('Extends: ');
               WB.Selection.TypeText(UCNode.ParentNode.CaptionString);
               WB.Selection.TypeParagraph;
               WB.Selection.Style:=Normal.Text;
            end;
            SL.Text:=UCNode.Text;
            for J:=0 to SL.Count-1 do
            begin
               WB.Selection.TypeText(SL[J]);
               WB.Selection.TypeParagraph;
            end;
            if UCNode.ChildNodes.Count > 0 then
            begin
               WB.Selection.Style:=Emphasis.Text;
               WB.Selection.TypeText('Extended By: ');
               if UCNode.ChildNodes.Count > 1 then
                  WB.Selection.TypeParagraph;
               for J:=0 to UCNode.ChildNodes.Count-1 do
               begin
                  WB.Selection.TypeText(TUCNode(UCNode.ChildNodes[J]).CaptionString);
                  WB.Selection.TypeParagraph;
               end;
               WB.Selection.Style:=Normal.Text;
               WB.Selection.TypeParagraph;
            end;
            if (UCNode.BRules <> '') or (UCNode.Clarif <> '') or (UCNode.Note <> '') then
            begin
               WB.Selection.TypeParagraph;
            end;
            if UCNode.BRules <> '' then        
            begin
               WB.Selection.Style:=Titles.Text;
               WB.Selection.TypeText('Business Rules:');
               WB.Selection.TypeParagraph;
               WB.Selection.Style:=Normal.Text;
               WB.Selection.TypeParagraph;
               SL.Text:=UCNode.BRules;             
               for J:=0 to SL.Count-1 do
               begin
                  WB.Selection.TypeText(SL[J]);
                  WB.Selection.TypeParagraph;
               end;
            end;
            if UCNode.Note <> '' then
            begin
               WB.Selection.Style:=Titles.Text;
               WB.Selection.TypeText('Note:');
               WB.Selection.TypeParagraph;
               WB.Selection.Style:=Normal.Text;
               WB.Selection.TypeParagraph;
               SL.Text:=UCNode.Note;             
               for J:=0 to SL.Count-1 do
               begin
                  WB.Selection.TypeText(SL[J]);
                  WB.Selection.TypeParagraph;
               end;
            end;
            if UCNode.Clarif <> '' then
            begin
               WB.Selection.Style:=Titles.Text;
               WB.Selection.TypeText('Clarification Required:');
               WB.Selection.TypeParagraph;
               WB.Selection.Style:=Normal.Text;
               WB.Selection.TypeParagraph;
               SL.Text:=UCNode.Clarif;             
               for J:=0 to SL.Count-1 do
               begin
                  WB.Selection.TypeText(SL[J]);
                  WB.Selection.TypeParagraph;
               end;
            end; 
         except
            WB.Selection.TypeText('------------- Exception ! -------------');
            WB.Selection.TypeParagraph;
         end;
         if (I mod 20) = 0 then ActiveDocument.Save;
      end;
   except
   end;
   SL.Free;
   ActiveDocument.Save;
   WB:=Unassigned;
end;
procedure TUCSDForm.Node1Click(Sender: TObject);
var
   I:Integer;
   WB:Variant;
   WSel:Variant;
   ActiveDocument:Variant;
   Title:String;
   Template:String;
   UCNode:TUCNode;
begin
   WB:=CreateOleObject('Word.Application');
   Template:=DFile.Text;
   ActiveDocument:=WB.Documents.Add(Template);
   if FileExists(OFile.Text) then
      DeleteFile(OFile.Text);
   ActiveDocument.SaveAs(FileName:=OFile.Text);
   try
      WB.Selection.GoTo(What:=-1,Name:='MainDoc'); // wdGoToBookmark = -1
   except
   end;
//   WB.Selection.GoTo(What:=1,Which:=1,Count:=4);
   WB.Visible:=True;
   WSel:=WB.Selection;
   try
      for I:=0 to MainPad.ComponentCount-1 do
      begin
         if (MainPad.Components[I] is TUCNode) and (MainPad.Components[I] as TUCNode).Selected then
         begin
            UCNode:=TUCNode(MainPad.Components[I]);
            WSel.Style:=Normal.Text;
            WSel.Style:=Heading.Text;
            Title:=UCNode.Caption;
            try
               WSel.TypeText(Title);
//               WSel.MoveLeft(Unit:=1,Count:=1,Extend:=1); // Select Text
               WB.ActiveDocument.Indexes.MarkEntry(Range:=WSel.Range,Entry:=Title,EntryAutoText:=Title);
               WB.Selection.MoveRight(Unit:=1,Count:=1,Extend:=1); // Select Text
               WB.Selection.MoveRight(Unit:=1,Count:=1,Extend:=0); // Select Text
               WSel.TypeParagraph;
               WSel.Style:=Normal.Text;
               if UCNode.ParentNode <> nil then
               begin
                  WSel.Style:=Emphasis.Text;
                  WSel.TypeText('Extends: '); WSel.TypeParagraph;
                  InsertParentTextInWord(UCNode.ParentNode,WSel,' ');
                  WSel.Style:=Normal.Text;
               end;
               InsertTextInWord(WSel,UCNode.Text,'');
               if UCNode.ChildNodes.Count > 0 then
               begin
                  WSel.Style:=Emphasis.Text;
                  WSel.TypeText('Extended by: ');
                  WSel.TypeParagraph;
                  InsertChildTextInWord(UCNode.ChildNodes,WSel,' ');
                  WSel.Style:=Normal.Text;
               end;
            except
               WSel.TypeText('------------- Exception ! -------------');
               WSel.TypeParagraph;
            end;
         end;
         if (I mod 10) = 0 then ActiveDocument.Save;
      end;
   except
   end;
   ActiveDocument.Save;
   WB:=Unassigned;
end;

procedure TUCSDForm.ProdImageClick(Sender: TObject);
begin
   if OPD.Execute then
   begin
      ProdImage.Picture.LoadFromFile(OPD.FileName);
   end;
end;

procedure TUCSDForm.ComboBox1Exit(Sender: TObject);
var
   Combo:TComboBox;
begin
   if Sender is TComboBox then
   begin
      Combo:=(Sender as TComboBox);
      if Sender <> ComboBox3 then
         Combo.Text:=RemSpace(Combo.Text);
      if Combo.Items.IndexOf(Combo.Text) < 0 then
         Combo.Items.Add(Combo.Text);
   end;
end;

procedure TUCSDForm.Move1Click(Sender: TObject);
var
   Over:TUCNode;
   I:Integer;
begin
   SaveState;
   if FUCNode <> nil then
   begin
      Over:=FUCNode.IsOver;
      if Over <> nil then
      begin
         for I:=0 to MainPad.ComponentCount-1 do
         begin
            if (MainPad.Components[I] is TUCNode) and ((MainPad.Components[I] as TUCNode).Selected) then
            begin
               (MainPad.Components[I] as TUCNode).ParentNode:=Over;
            end;
         end;
         FUCNode.ResetNodePositions;
         FUCNode.Invalidate;
      end;
   end;
end;

procedure TUCSDForm.Cancel1Click(Sender: TObject);
begin
   if FUCNode <> nil then
   begin
      FUCNode.ResetNodePositions;
      FUCNode.Invalidate;
   end;
end;

procedure TUCSDForm.Copy1Click(Sender: TObject);
var
   Over:TUCNode;
   CopyUCNode:TUCNode;
   I:Integer;
   CC:Integer;
const
   NameCount:Integer=0;
begin
   SaveState;
   if FUCNode <> nil then
   begin
      Over:=FUCNode.IsOver;
      if Over <> nil then
      begin
         CC:=MainPad.ComponentCount;
         for I:=0 to CC-1 do
         begin
            if (MainPad.Components[I] is TUCNode) and ((MainPad.Components[I] as TUCNode).Selected) then
            begin
               (MainPad.Components[I] as TUCNode).Selected:=False;
               CopyUCNode:=TUCNode.Create(MainPad);
               MainPad.InsertControl(CopyUCNode);
               CopyUCNode.ParentForm:=Self;
               CopyUCNode.Name:=NewComponentName(MainPad,'U');
               CopyUCNode.Assign((MainPad.Components[I] as TUCNode));
               CopyUCNode.DuplicateOf:=(MainPad.Components[I] as TUCNode);
               CopyUCNode.ParentNode:=Over;
               CopyUCNode.Selected:=True;
            end;
         end;
         FUCNode.ResetNodePositions;
         FUCNode.Invalidate;
      end;
   end;
end;

procedure TUCSDForm.UnlinkfromDuplicates1Click(Sender: TObject);
var
   UCNode:TUCNode;
begin
   SaveState;
   UCNode:=TUCNode.Create(MainPad);
   MainPad.InsertControl(UCNode);
   UCNode.ParentForm:=Self;
   UCNode.UnlinkSelected;
   MainPad.RemoveControl(UCNode);
   UCNode.Free;
end;

procedure TUCSDForm.CollapseNode1Click(Sender: TObject);
var
   UCNode:TUCNode;
begin
   SaveState;
   UCNode:=TUCNode.Create(MainPad);
   MainPad.InsertControl(UCNode);
   UCNode.ParentForm:=Self;
   UCNode.CollapseSelected;
   MainPad.RemoveControl(UCNode);
   UCNode.Free;
end;

procedure TUCSDForm.FormCreate(Sender: TObject);
begin
   UndoList:=TList.Create;
   CanUndo:=True;
   Modified:=False;
end;
// check if save needed and ask return False if cancel selected
function TUCSDForm.CheckSave:Boolean;
var
   Res:Integer;
begin
   Result:=True;
   if Modified then
   begin
      if ExtractfileName(SD.FileName) <> '' then
         Res:=Application.MessageBox('Do you want to save the changes ?',PChar(ExtractfileName(SD.FileName)+' has been Modified'),MB_YESNOCANCEL)
      else
         Res:=Application.MessageBox('Do you want to save the changes ?','Use Case Has been Modified',MB_YESNOCANCEL);
      case Res of
         IDYES    : Save1Click(nil);
         IDCANCEL	: Result:=False;
      end;
   end;
end;
procedure TUCSDForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if CheckSave then
      Action:=caFree
   else
      Action:=caNone;
end;
procedure TUCSDForm.EmptyUndoList;
begin
   Undo1.Enabled:=False;
   while UndoList.Count > 0 do
   begin
      TMemoryStream(UndoList[0]).Free;
      UndoList.Delete(0);
   end;
end;

procedure TUCSDForm.FormDestroy(Sender: TObject);
begin
   EmptyUndoList;
   UndoList.Free;
end;

procedure TUCSDForm.IntroductionChange(Sender: TObject);
begin
   Modified:=True;
//   SaveState;
end;

procedure TUCSDForm.Undo1Click(Sender: TObject);
var
   I:Integer;
   US:TMemoryStream;
   UCConfig:TUCConfig;
begin
    if UndoList.Count = 0 then Exit;
    US:=UndoList[UndoList.Count-1];
    UndoList.Delete(UndoList.Count-1);
    if UndoList.Count = 0 then Undo1.Enabled:=False;
    UCConfig:=nil;
    FUCNode:=nil;
    Panel2.RemoveControl(MainPad);
    MainPad.Free;
    MainPad:=TScrollBox.Create(UCSDForm);
    US.Position:=0;
    US.ReadComponent(MainPad);
    US.Free;
    Panel2.InsertControl(MainPad);
    for I:=0 to MainPad.ComponentCount-1 do
    begin
       if MainPad.Components[I] is TUCNode then
       begin
          (MainPad.Components[I] as TUCNode).ParentForm:=Self;
       end
       else if MainPad.Components[I] is TUCConfig then
       begin
          UCConfig:=MainPad.Components[I] as TUCConfig;
       end;
    end;
    if UCConfig <> nil then
    begin
       Introduction.Text:=UCConfig.Introduction ;
       OFile       .Text:=UCConfig.OutputFile   ;
       DFile       .Text:=UCConfig.TemplateFile ;
       Heading     .Text:=UCConfig.HeadingStyle ;
       Normal      .Text:=UCConfig.NormalStyle  ;
       Emphasis    .Text:=UCConfig.EmphasisStyle;
       Titles      .Text:=UCConfig.TitlesStyle;
       MainPad.RemoveControl(UCConfig);
    end;
    MainPad.OnMouseDown:=MainPadMouseDown;
    if MainPad.ComponentCount > 0 then
       (MainPad.Components[0] as TUCNode).ResetNodePositions;
end;

procedure TUCSDForm.Copy2Click(Sender: TObject);
var
   Clipboard:TClipboard;
   I:Integer;
   CopyPad:TCopyPad;
   CopyUCNode:TUCNode;
   S:String;
begin
   CopyPad:=TCopyPad.Create(Self);
   Clipboard:=TClipboard.Create;
   if FUCNode <> nil then
   begin
      for I:=0 to MainPad.ComponentCount-1 do
      begin
         if (MainPad.Components[I] is TUCNode) and ((MainPad.Components[I] as TUCNode).Selected) then
         begin
            CopyUCNode:=TUCNode.Create(CopyPad);
            CopyPad.InsertControl(CopyUCNode);
            CopyUCNode.ParentForm:=Self;
            CopyUCNode.Name:=NewComponentName(CopyPad,'U');
            CopyUCNode.Assign((MainPad.Components[I] as TUCNode));
         end;
      end;
      if CopyPad.ComponentCount > 0 then
      begin
         S:=GetComponentAsText(CopyPad);
         Clipboard.SetTextBuf(PChar(S));
      end;
   end;
   Clipboard.Free;
   CopyPad.Free;
end;

procedure TUCSDForm.Cut1Click(Sender: TObject);
begin
//   SaveState;
//   CopySelected;
//   DeleteSelected;
end;

procedure TUCSDForm.Paste1Click(Sender: TObject);
var
   Clipboard:TClipboard;
   I:Integer;
   CopyPad:TCopyPad;
   CopyUCNode:TUCNode;
begin
   SaveState;
   Clipboard:=TClipboard.Create;
   CopyPad:=Clipboard.GetComponent(nil,nil) as TCopyPad;
   Clipboard.Free;

   if (CopyPad <> nil) and (CopyPad.ComponentCount > 0) then
   begin
      for I:=0 to CopyPad.ComponentCount-1 do
      begin
         CopyUCNode:=TUCNode.Create(MainPad);
         MainPad.InsertControl(CopyUCNode);
         CopyUCNode.ParentForm:=Self;
         CopyUCNode.Name:=NewComponentName(MainPad,'U');
         CopyUCNode.Assign((CopyPad.Components[I] as TUCNode));
      end;
   end;
   CopyPad.Free;
//   InsertFromClipBoard;
end;

procedure TUCSDForm.FormShow(Sender: TObject);
begin
   if (ParamCount > 0) and (FileExists(ParamStr(1))) then
   begin
      OD.FileName:=ParamStr(1);
      LoadFromFile(OD.FileName);
      SD.FileName:=OD.FileName;
      Modified:=False;
      Application.Title:='UseCase('+ExtractFileName(OD.FileName)+')';
   end;
end;

procedure TUCSDForm.About1Click(Sender: TObject);
begin
   ShowMessage('Version 666');
end;

initialization
   RegisterClasses([TScrollBox,TUCNode,TUCConfig]);

end.
