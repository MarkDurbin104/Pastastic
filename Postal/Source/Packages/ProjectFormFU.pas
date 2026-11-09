unit ProjectFormFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Grids, ExtCtrls,PackStrListU,
  ParseNodeU,Compress,CompressU,Bin2String,GPCSBase_TLB,GPCSGUID,
  DrawButtonU,DesignNodeU,Utils;
  
type
  TProjectsForm = class(TForm)
    OD: TOpenDialog;
    Panel14: TPanel;
    Panel1: TPanel;
    CompList: TListBox;
    Panel3: TPanel;
    ComboBox1: TComboBox;
    LoadButton: TButton;
    StringGrid1: TStringGrid;
    UGroup: TImage;
    WGroup: TImage;
    PEIcon: TImage;
    Snippet: TImage;
    CustDisp: TImage;
    Receipt: TImage;
    Panel2: TPanel;
    ComboBox2: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Filter: TEdit;
    FilterButton: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure LoadButtonClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CompListKeyPress(Sender: TObject; var Key: Char);
    procedure CompListMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure CompListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ComboBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ComboBox2Change(Sender: TObject);
    procedure FilterChange(Sender: TObject);
    procedure FilterButtonClick(Sender: TObject);
  private
     FOnLoad:TNotifyEvent;
     FOnLoaded:TNotifyEvent;
  public 
     Comps:TRootNode;
     FileName:String;
     CompType:Integer;
     MenuState:String;
     CurrentList:TCorvusNode;
     function CompTypeName:String;
     procedure Select(CompName:String);
     procedure LoadFile(FileName:String);
     procedure RefreshLB;
     procedure SetupSG;
     procedure LoadRegSettings;
     procedure SaveRegSettings;
     procedure LoadParamFiles;
     procedure PutOn(Panel:TPanel);
     procedure NodeClicked(DesignNode:TDesignNode;AreaCode:Integer);
     procedure IntegrityCheck(Lines:TStrings);
     property OnLoad:TNotifyEvent read FOnLoad write FOnLoad;
     property OnLoaded:TNotifyEvent read FOnLoaded write FOnLoaded;
  end;        

var
  ProjectsForm: TProjectsForm;
  PictureServer:IPictureServer;

function GetPictureFromServer(Value:String):TBitMap;

implementation

uses ErrorFormFU {, PropertyEditFU};

{$R *.DFM}

procedure TProjectsForm.NodeClicked(DesignNode:TDesignNode;AreaCode:Integer);
var
   CorvusNode:TCorvusNode;
   S:String;
begin
   if AreaCode = 1 then // properties
   begin
      if DesignNode is TGroupDesignNode then
         S:='Group'
      else if DesignNode is TProductDesignNode then
         S:='Product'
      else if DesignNode is TWGroupDesignNode then
         S:='WorkStation'
      else if DesignNode is TUGroupDesignNode then
         S:='User'
      else if DesignNode is TDomainDesignNode then
         S:='Domain'
      else if DesignNode is TSnippetDesignNode then
         S:='Snippet';
      CorvusNode:=Comps.NodeNamed(S+'.'+DesignNode.Title);
      if CorvusNode <> nil then
      begin
//         PropEdit.Show;
//         PropEdit.PropList.CurObj:=CorvusNode;
//         PropEdit.Memo1.Text:=CorvusNode.ListDetails;
//         PropEdit.Memo1.Lines.Insert(0,S+'s {');
//         PropEdit.Memo1.Lines.Add('}');
      end;
   end
   else // AreaCode = 0 main area
   begin
      if DesignNode is TGroupDesignNode then
         Select('Group.'+DesignNode.Title)
      else if DesignNode is TProductDesignNode then
         Select('Product.'+DesignNode.Title)
      else if DesignNode is TSnippetDesignNode then
         Select('Snippet.'+DesignNode.Title)
      else if DesignNode is TDomainDesignNode then
         Select('Domain.'+DesignNode.Title)
      else if DesignNode is TWGroupDesignNode then
         Select('WorkStation.'+DesignNode.Title)
      else if DesignNode is TUGroupDesignNode then
         Select('User.'+DesignNode.Title);
   end;
end;

function GetBitmap(Value:OleVariant;BType:Boolean):TBitMap;
var
   SStream:TStringStream;
   Compress:TCompress;
begin
   result:=nil;
   if BType then
   begin
      try
         if Value = '' then Exit;
         Compress:=TCompress.Create;
         Value:=StringToBinary(Value);
         Value:=Compress.CompressString(Value);
         Compress.Free;
         SStream:=TStringStream.Create(Value);
         SStream.Position:=0;
         Result:=TBitMap.Create;
         Result.LoadFromStream(SStream);
         SStream.Free;
      except
      end;
   end
   else
   begin
      if VarIsArray(Value) then
      begin
         Result:=TCompressor.CreateBitmapFromArray(Value);
      end;
   end;
end;
function GetPictureFromServer(Value:String):TBitMap;
var
   BMPString:String;
begin
   Result:=nil;
   if PictureServer <> nil then
      BMPString:=PictureServer.Bitmap(Value)
   else
      BMPString:='';
   if BMPString <> '' then
      Result:=GetBitmap(BMPString,True);
end;

{TForm1}
procedure TProjectsForm.RefreshLB;
var
   CanSelect:Boolean;
begin
   StringGrid1SelectCell(StringGrid1,StringGrid1.Selection.Left,StringGrid1.Selection.Top,CanSelect);
end;
procedure SetUsedFlagOn(Comps:TRootNode;INode:TCorvusNode);
var
   I:Integer;
   Node:TCorvusNode;
begin
   if INode = nil then Exit;
   INode.Used:=True;
   if INode is TGroupNode then
   begin
      for I:=0 to TGroupNode(INode).ItemNodes.Count-1 do
      begin
         SetUsedFlagOn(Comps,TCorvusNode(TGroupNode(INode).ItemNodes.Objects[I]));
         Node:=Comps.NodeNamed('Function.'+TGroupNode(INode).ItemNodes[I]);
         SetUsedFlagOn(Comps,Node);
      end;
   end
   else if INode is TProductNode then
   begin
      for I:=0 to TProductNode(INode).ItemNodes.Count-1 do
         SetUsedFlagOn(Comps,TCorvusNode(TProductNode(INode).ItemNodes.Objects[I]));
      SetUsedFlagOn(Comps,TProductNode(INode).BasedOnNode);
   end
   else if INode is TDomainNode then
   begin
      SetUsedFlagOn(Comps,TDomainNode(INode).BasedOnNode);
   end;
end;
function ListDuplicates(Lines:TStrings):String;
var
   SL:TPackStringList;
   RSL:TPackStringList;
   I:Integer;
begin
   SL:=TPackStringList.Create;
   RSL:=TPackStringList.Create;
   SL.Assign(Lines);
   SL.Sort;
   for I:=1 to SL.Count-1 do
   begin
      if SL[I] = SL[I-1] then
         RSL.Add(SL[I]);
   end;
   Result:=RSL.PackText;
   RSL.Free;
   SL.Free;
end;
procedure TProjectsForm.IntegrityCheck(Lines:TStrings);
var
   I:Integer;
   J:Integer;
   UN:TUserNode;
   INode:TImageNode;
   Node:TCorvusNode;
   SL:TPackStringList;
   RSL:TPackStringList;
begin
   Lines.BeginUpdate;
   RSL:=TPackStringList.Create;
   RSL.PackText:=ListDuplicates(Comps.Constants   ); if RSL.Count > 0 then Lines.Add('Duplicate Constants '   +RSL.CommaText);
   RSL.PackText:=ListDuplicates(Comps.Domains     ); if RSL.Count > 0 then Lines.Add('Duplicate Domains '     +RSL.CommaText);
   RSL.PackText:=ListDuplicates(Comps.Groups      ); if RSL.Count > 0 then Lines.Add('Duplicate Groups '      +RSL.CommaText);
   RSL.PackText:=ListDuplicates(Comps.LogFormats  ); if RSL.Count > 0 then Lines.Add('Duplicate LogFormats '  +RSL.CommaText);
   RSL.PackText:=ListDuplicates(Comps.LookUps     ); if RSL.Count > 0 then Lines.Add('Duplicate LookUps '     +RSL.CommaText);
   RSL.PackText:=ListDuplicates(Comps.PickLists   ); if RSL.Count > 0 then Lines.Add('Duplicate PickLists '   +RSL.CommaText);
   RSL.PackText:=ListDuplicates(Comps.Products    ); if RSL.Count > 0 then Lines.Add('Duplicate Products '    +RSL.CommaText);
   RSL.PackText:=ListDuplicates(Comps.Snippets    ); if RSL.Count > 0 then Lines.Add('Duplicate Snippets '    +RSL.CommaText);
   RSL.PackText:=ListDuplicates(Comps.Users       ); if RSL.Count > 0 then Lines.Add('Duplicate Users '       +RSL.CommaText);
   RSL.PackText:=ListDuplicates(Comps.WorkStations); if RSL.Count > 0 then Lines.Add('Duplicate WorkStations '+RSL.CommaText);
   for I:=0 to Comps.Users.Count-1 do
   begin
      UN:=TUserNode(Comps.Users.Objects[I]);

      INode:=nil;
      if UN.ItemNodes.Count > 0 then
         INode:=TImageNode(UN.ItemNodes.Objects[0]);

      SetUsedFlagOn(Comps,INode);
      SetUsedFlagOn(Comps,Comps.NodeNamed('Group.'+Comps.Users[I]+'__A'));
      SetUsedFlagOn(Comps,Comps.NodeNamed('Group.'+Comps.Users[I]+'_C_'));
      SetUsedFlagOn(Comps,Comps.NodeNamed('Group.'+Comps.Users[I]+'_CA'));
      SetUsedFlagOn(Comps,Comps.NodeNamed('Group.'+Comps.Users[I]+'S__'));
      SetUsedFlagOn(Comps,Comps.NodeNamed('Group.'+Comps.Users[I]+'S_A'));
      SetUsedFlagOn(Comps,Comps.NodeNamed('Group.'+Comps.Users[I]+'SC_'));
      SetUsedFlagOn(Comps,Comps.NodeNamed('Group.'+Comps.Users[I]+'SCA'));

      if UN <> nil then
      begin
         RSL.PackText:=ListDuplicates(UN.ItemNodes);
         if RSL.Count > 0 then
            Lines.Add('Duplicate Groups '+RSL.CommaText+' in UserGroup '+Comps.Users[I]+' ('+ExtractFileName(UN.FileName)+'['+IntToStr(UN.LineNumber)+'])');
         for J:=0 to UN.ItemNodes.Count-1 do
         begin
            if UN.ItemNodes.Objects[J] = nil then
               Lines.Add('Nonexistant Group '+UN.ItemNodes[J]+' in UserGroup '+Comps.Users[I]+' ('+ExtractFileName(UN.FileName)+'['+IntToStr(UN.LineNumber)+'])');
         end;
      end;
   end;
   for I:=0 to Comps.WorkStations.Count-1 do
   begin
      UN:=TUserNode(Comps.WorkStations.Objects[I]);
      if UN <> nil then
      begin
         RSL.PackText:=ListDuplicates(UN.ItemNodes);
         if RSL.Count > 0 then
            Lines.Add('Duplicate Groups '+RSL.CommaText+' in WorkStationGroup '+Comps.WorkStations[I]+' ('+ExtractFileName(UN.FileName)+'['+IntToStr(UN.LineNumber)+'])');
         for J:=0 to UN.ItemNodes.Count-1 do
         begin
            if UN.ItemNodes.Objects[J] = nil then
               Lines.Add('Nonexistant Group '+UN.ItemNodes[J]+' in WorkStationGroup '+Comps.WorkStations[I]+' ('+ExtractFileName(UN.FileName)+'['+IntToStr(UN.LineNumber)+'])');
         end;
      end;
   end;
   for I:=0 to Comps.Groups.Count-1 do
   begin
      INode:=TImageNode(Comps.Groups.Objects[I]);
      RSL.PackText:=ListDuplicates(INode.ItemNodes);
      if RSL.Count > 0 then
         Lines.Add('Duplicate Items '+RSL.CommaText+' in Group '+Comps.Groups[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
      if INode.Used then
      begin
         if (INode.BasedOn <> '') and (INode.BasedOnNode = nil) then
               Lines.Add('Group '+Comps.Groups[I]+' Based On Nonexistant Item '+INode.BasedOn+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
         for J:=0 to INode.ItemNodes.Count-1 do
         begin
            if INode.ItemNodes.Objects[J] = nil then
            begin
               if Comps.Functions.IndexOf(INode.ItemNodes[J]) = -1 then
                  Lines.Add('Nonexistant Item '+INode.ItemNodes[J]+' in Group '+Comps.Groups[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
            end;
         end;
         if not FileExists(ExtractFilePath(INode.FileName)+INode.Bitmap) then
            Lines.Add('No Bitmap File Found '+INode.Bitmap+' in Group '+Comps.Groups[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
      end
      else
         Lines.Add('Group '+Comps.Groups[I]+' is Not Used ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
   end;
   for I:=0 to Comps.Products.Count-1 do
   begin
      INode:=TImageNode(Comps.Products.Objects[I]);
      RSL.PackText:=ListDuplicates(INode.ItemNodes);
      if RSL.Count > 0 then
         Lines.Add('Duplicate Items '+RSL.CommaText+' in Product '+Comps.Products[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
      if INode.Used then
      begin
         if (INode.BasedOn <> '') and (INode.BasedOnNode = nil) then
               Lines.Add('Product '+Comps.Products[I]+' Based On Nonexistant Item '+INode.BasedOn+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
         for J:=0 to INode.ItemNodes.Count-1 do
         begin
            if INode.ItemNodes.Objects[J] = nil then
            begin
               if Comps.Functions.IndexOf(INode.ItemNodes[J]) = -1 then
                  Lines.Add('Nonexistant Item '+INode.ItemNodes[J]+' in Product '+Comps.Products[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
            end;
         end;
         if INode.IndexOf('DontBuild') = -1 then
         begin
            if not FileExists(ExtractFilePath(INode.FileName)+INode.Bitmap) then
               Lines.Add('No Bitmap File Found '+INode.Bitmap+' in Product '+Comps.Products[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
            if INode.IndexOf('PLU') = -1 then
            begin
               Lines.Add('No PLU Found in Product '+Comps.Products[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
            end
            else
            begin
               if (not (TProductNode(INode).PLU[1] in ['0'..'9'])) then
               begin
                  Node:=Comps.NodeNamed('Constant.'+TProductNode(INode).PLU);
                  SetUsedFlagOn(Comps,Node);
                  if Node = nil then
                  begin
                      Lines.Add('Invalid PLU Found '+TProductNode(INode).PLU+' in Product '+Comps.Products[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
                  end;
               end;
            end;
         end;
         if INode.IndexOf('LogAs') <> -1 then
         begin
            Node:=Comps.NodeNamed('LogFormat.'+TProductNode(INode).LogAs);
            SetUsedFlagOn(Comps,Node);
            if Node = nil then
            begin
                Lines.Add('Invalid LogFormat Found '+TProductNode(INode).LogAs+' in Product '+Comps.Products[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
            end;
         end;
         SL:=TPackStringList.Create;
         SL.CommaText:=TProductNode(INode).Domains;
         RSL.PackText:=ListDuplicates(SL);
         if RSL.Count > 0 then
            Lines.Add('Duplicate Domains '+RSL.CommaText+' in Product '+Comps.Products[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
         for J:=0 to SL.Count-1 do
         begin
            Node:=Comps.NodeNamed('Domain.'+SL[J]);
            SetUsedFlagOn(Comps,Node);
            if Node = nil then
            begin
               Lines.Add('Nonexistant Domain '+SL[J]+' in Product '+Comps.Products[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
            end;
         end;
         SL.CommaText:=TProductNode(INode).Snippets;
         RSL.PackText:=ListDuplicates(SL);
         if RSL.Count > 0 then
            Lines.Add('Duplicate Snippets '+RSL.CommaText+' in Product '+Comps.Products[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
         for J:=0 to SL.Count-1 do
         begin
            Node:=Comps.NodeNamed('Snippet.'+SL[J]);
            SetUsedFlagOn(Comps,Node);
            if Node = nil then
            begin
               Lines.Add('Nonexistant Snippet '+SL[J]+' in Product '+Comps.Products[I]+' ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
            end;
         end;
         SL.Free;;
      end
      else
         Lines.Add('Product '+Comps.Products[I]+' is Not Used ('+ExtractFileName(INode.FileName)+'['+IntToStr(INode.LineNumber)+'])');
   end;
   for I:=0 to Comps.Domains.Count-1 do
   begin
      Node:=TCorvusNode(Comps.Domains.Objects[I]);
      if not Node.Used then
         Lines.Add('Domain '+Comps.Domains[I]+' is Not Used ('+ExtractFileName(Node.FileName)+'['+IntToStr(Node.LineNumber)+'])');
   end;
   for I:=0 to Comps.Snippets.Count-1 do
   begin
      Node:=TCorvusNode(Comps.Snippets.Objects[I]);
      if not Node.Used then
         Lines.Add('Snippet '+Comps.Snippets[I]+' is Not Used ('+ExtractFileName(Node.FileName)+'['+IntToStr(Node.LineNumber)+'])');
   end;
   for I:=0 to Comps.Constants.Count-1 do
   begin
      Node:=TCorvusNode(Comps.Constants.Objects[I]);
      if not Node.Used then
         Lines.Add('Constant '+Comps.Constants[I]+' is Not Used ('+ExtractFileName(Node.FileName)+'['+IntToStr(Node.LineNumber)+'])');
   end;
   for I:=0 to Comps.LogFormats.Count-1 do
   begin
      Node:=TCorvusNode(Comps.LogFormats.Objects[I]);
      if not Node.Used then
         Lines.Add('LogFormat '+Comps.LogFormats[I]+' is Not Used ('+ExtractFileName(Node.FileName)+'['+IntToStr(Node.LineNumber)+'])');
   end;
   for I:=0 to Comps.Functions.Count-1 do
   begin
      Node:=TCorvusNode(Comps.Functions.Objects[I]);
      if (Node.FileName <> 'P') and (not Node.Used) then
         Lines.Add('Function '+Comps.Functions[I]+' is Not Used');
   end;
   RSL.Free;
   Lines.EndUpdate;
end;
procedure TProjectsForm.LoadFile(FileName:String);
var
   I:Integer;
begin
  if Assigned(FOnLoad) then FOnLoad(Self);
  if (ErrorForm <> nil) then 
  begin
     ErrorForm.Errors.Clear;
     ErrorForm.Errors.Lines.BeginUpdate;
  end;
  if Comps <> nil then
     Comps.Free;
  Comps:=TRootNode.Create('Comps',FileName,0);
  Cursor:=crHourGlass;
  try
     Comps.ParseFile(ExtractFilePath(FileName),FileName,1);
  except
  end;
  Comps.Functions.AddObject('Cancel Customer',TFunctionNode.Create('Cancel Customer','M',1));
  Comps.Functions.AddObject('End Customer',TFunctionNode.Create('End Customer','M',1));
  Comps.Functions.AddObject('Receipt',TFunctionNode.Create('Receipt','M',1));
  Comps.Functions.AddObject('Exit',TFunctionNode.Create('Exit','M',1));
  Comps.Functions.AddObject('Shutdown Workstation',TFunctionNode.Create('Shutdown Workstation','M',1));
  Comps.Functions.AddObject('Complete',TFunctionNode.Create('Complete','P',1));
  Comps.Functions.AddObject('Report',TFunctionNode.Create('Report','P',1));

  Comps.SetBasedOn(Comps);

  Comps.Functions   .Sort;
  Comps.BuildOptions.Sort;
  Comps.Constants   .Sort;
  Comps.Domains     .Sort;
  Comps.Groups      .Sort;
  Comps.LogFormats  .Sort;
  Comps.LookUps     .Sort;
  Comps.PickLists   .Sort;
  Comps.Products    .Sort;
  Comps.Snippets    .Sort;
  Comps.Users       .Sort;
  Comps.WorkStations.Sort;

  for I:=0 to Comps.Groups.Count-1 do
     if Comps.Groups.Objects[I] <> nil then
        TImageNode(Comps.Groups.Objects[I]).GetItemNodeCount;
  for I:=0 to Comps.Products.Count-1 do
  begin
     if Comps.Products.Objects[I] <> nil then
     begin
        TImageNode(Comps.Products.Objects[I]).GetItemNodeCount;
     end;
  end;
  for I:=0 to Comps.Users.Count-1 do
     if Comps.Users.Objects[I] <> nil then
        TUserNode(Comps.Users.Objects[I]).GetItemNodeCount;
  for I:=0 to Comps.Workstations.Count-1 do
     if Comps.Workstations.Objects[I] <> nil then
        TWorkstationNode(Comps.Workstations.Objects[I]).GetItemNodeCount;
  Cursor:=crDefault;
  if (ErrorForm <> nil) then 
  begin
     ErrorForm.Errors.Lines.EndUpdate;
     if ErrorForm.Errors.Lines.Count > 0 then
        ErrorForm.Show;
  end;
  if Assigned(FOnLoaded) then FOnLoaded(Self);
end;
procedure TProjectsForm.FormDestroy(Sender: TObject);
var
   I:Integer;
begin
   SaveRegSettings;
   for I:=0 to ComboBox1.Items.Count-1 do
      if ComboBox1.Items.Objects[I] <> nil then
         TRootNode(ComboBox1.Items.Objects[I]).Free;
   PictureServer:=nil
end;

procedure TProjectsForm.StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
var
   H:Integer;
   R:TRect;
begin
   if (Sender is TStringGrid) then
   begin
      (Sender as TStringGrid).Canvas.Font:=(Sender as TStringGrid).Font;
      (Sender as TStringGrid).Canvas.Font.Color:=clBtnText;
      if (gdSelected in State) and (gdFocused in State) then
      begin
         DrawButtonBG((Sender as TStringGrid).Canvas,Rect,clActiveCaption,3,50,False,0);
         (Sender as TStringGrid).Canvas.Font.Color:=clCaptionText;
      end
      else if (gdSelected in State) then
         DrawButtonBG((Sender as TStringGrid).Canvas,Rect,Color,0,50,False,0)
      else
         DrawButtonBG((Sender as TStringGrid).Canvas,Rect,Color,3,50,False,0);
      R:=Rect;
      H:=DrawText((Sender as TStringGrid).Canvas.Handle,PChar((Sender as TStringGrid).Cells[Col,Row]),-1,R,DT_CALCRECT or DT_WORDBREAK or DT_CENTER);
      OffsetRect(R,((Rect.Right-Rect.Left)-(R.Right-R.Left)) div 2,(((Rect.Bottom-Rect.Top)-H) div 2)+1);
      DrawText((Sender as TStringGrid).Canvas.Handle,PChar((Sender as TStringGrid).Cells[Col,Row]),-1,R,DT_WORDBREAK or DT_CENTER);
   end;
end;
procedure TProjectsForm.SetupSG;
begin
   StringGrid1.Width:=Width;
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
   StringGrid1.Cells[2,3]:='Functions';
   ComboBox1.Left:=0;
   ComboBox1.Width:=Width-LoadButton.Width;
   ComboBox2.Width:=(Panel2.Width-ComboBox2.Left)-1;
   FilterButton.Left:=(Panel2.Width-FilterButton.Width)-1;
   Filter.Width:=FilterButton.Left-(Filter.Left+2);
   LoadButton.Left:=ComboBox1.Width;
end;
procedure TProjectsForm.LoadRegSettings;
var
   S:String;
begin
   ComboBox1.Items.CommaText:=GetGPCSRegNames('Designer\Files','');
   S:=GetGPCSRegString('Designer','Last File','');
   MenuState:=GetGPCSRegString('Designer','Menus','Automatic');
   ComboBox1.ItemIndex:=ComboBox1.Items.IndexOf(S);
   if ComboBox1.ItemIndex <> -1 then
      ComboBox1.Text:=S;
end;
procedure TProjectsForm.SaveRegSettings;
begin
   SetGPCSRegNames('Designer\Files',ComboBox1.Items.CommaText);
   SetGPCSRegString('Designer','Last File',ComboBox1.Text);
   SetGPCSRegString('Designer','Menus',MenuState);
end;
procedure TProjectsForm.LoadParamFiles;
var
   I:Integer;
   SL:TPackStringList;
begin
   for I:=1 to ParamCount do
   begin
     Comps:=nil;
     FileName:=ParamStr(I);
     LoadFile(FileName);
     if ComboBox1.Items.IndexOf(FileName) = -1 then
        ComboBox1.Items.Add(FileName);
     ComboBox1.ItemIndex:=ComboBox1.Items.IndexOf(FileName);
     ComboBox1.Items.Objects[ComboBox1.ItemIndex]:=Comps;
     RefreshLB;
     if Comps.Users.IndexOf('Clerk') <> -1 then
     begin
        SL:=TPackStringList.Create;
        SL.CommaText:=TUserNode(Comps.Users.Objects[Comps.Users.IndexOf('Clerk')]).Items;
        if SL.Count > 0 then
           Select(SL[0]);
        SL.Free;
     end;
   end;
end;
procedure TProjectsForm.FormCreate(Sender: TObject);
begin
   LoadRegSettings;
   LoadParamFiles;
   if ComboBox1.Text <> '' then
      ComboBox1Change(ComboBox1);
   try
      PictureServer:=CreatePictureServer;
   except
   end;
end;
procedure TProjectsForm.PutOn(Panel:TPanel);
var
   I:Integer;
   SL:TPackStringList;
begin
   if ComboBox1.Items.Count > 0 then
      I:=ComboBox1.ItemIndex
   else
      I:=-1;
   Parent:=Panel;
   Width:=194;
   if Panel <> nil then
   begin
      Panel.Width:=190;
      BorderStyle:=bsNone;
      Align:=alClient;
   end
   else
   begin
      BorderStyle:=bsSizeable;
      BorderIcons:=[biMinimize,biMaximize];
   end;
   Show;
   SetupSG;
   ComboBox1.ItemIndex:=I;
   if (Comps <> nil) and (Comps.Users <> nil) and (Comps.Users.IndexOf('Clerk') <> -1) then
   begin
      SL:=TPackStringList.Create;
      SL.CommaText:=TUserNode(Comps.Users.Objects[Comps.Users.IndexOf('Clerk')]).Items;
      if SL.Count > 0 then
         Select(SL[0]);
      SL.Free;
      if Assigned(FOnLoaded) then FOnLoaded(Self);
   end;
end;

function TProjectsForm.CompTypeName:String;
begin
   case CompType of
      0: Result:='Group';
      1: Result:='Product';
      2: Result:='User';
      3: Result:='PickList';
      4: Result:='LookUp';
      5: Result:='WorkStation';
      6: Result:='Domain';
      7: Result:='Snippet';
      8: Result:='Constant';
      9: Result:='LogFormat';
     10: Result:='BuildOption';
     11: Result:='Function';
   end;
end;
procedure TProjectsForm.StringGrid1SelectCell(Sender:TObject;Col,Row:Integer;var CanSelect:Boolean);
var
   LastList:TCorvusNode;
   LastSort:String;
   I:Integer;
begin
   if (Sender = StringGrid1) and (Comps <> nil) then
   begin
      LastList:=CurrentList;
      CompType:=(Row *3)+Col;
      case CompType of
         0: CurrentList:=Comps.Groups      ;
         1: CurrentList:=Comps.Products    ;
         2: CurrentList:=Comps.Users       ;
         3: CurrentList:=Comps.PickLists   ;
         4: CurrentList:=Comps.LookUps     ;
         5: CurrentList:=Comps.WorkStations;
         6: CurrentList:=Comps.Domains     ;
         7: CurrentList:=Comps.Snippets    ;
         8: CurrentList:=Comps.Constants   ;
         9: CurrentList:=Comps.LogFormats  ;
        10: CurrentList:=Comps.BuildOptions;
        11: CurrentList:=Comps.Functions   ;
      end;
      if LastList <> CurrentList then
      begin
         CompList.Items.BeginUpdate;
         try
            CompList.Items.Assign(CurrentList);
            if CompList.Items.Count > 0 then
            begin
               LastSort:=ComboBox2.Items[ComboBox2.ItemIndex];
               ComboBox2.Items.Text:=ListPropertyNames(TCorvusNode(CompList.Items.Objects[0]));
            end
            else
               ComboBox2.Items.Text:='';
            if ComboBox2.Items.IndexOf(LastSort) = -1 then
               ComboBox2.ItemIndex:=ComboBox2.Items.IndexOf('Name')
            else
               ComboBox2.ItemIndex:=ComboBox2.Items.IndexOf(LastSort);
            ComboBox2Change(ComboBox2);
         finally
            CompList.Items.EndUpdate;
         end;
      end
      else
      begin
         for I:=0 to CompList.Items.Count-1 do
            if CompList.Selected[I] then
               CompList.Selected[I]:=False;
      end;
   end;
end;

procedure TProjectsForm.LoadButtonClick(Sender: TObject);
var
   SL:TPackStringList;
begin
  if OD.Execute then
  begin
     LoadButton.Enabled:=False;
     Comps:=nil;
     LoadFile(OD.FileName);
     if ComboBox1.Items.IndexOf(OD.FileName) = -1 then
        ComboBox1.Items.Add(OD.FileName);
     ComboBox1.ItemIndex:=ComboBox1.Items.IndexOf(OD.FileName);
     FileName:=OD.FileName;
     ComboBox1.Items.Objects[ComboBox1.ItemIndex]:=Comps;
     RefreshLB;
     if Comps.Users.IndexOf('Clerk') <> -1 then
     begin
        SL:=TPackStringList.Create;
        SL.CommaText:=TUserNode(Comps.Users.Objects[Comps.Users.IndexOf('Clerk')]).Items;
        if SL.Count > 0 then
           Select(SL[0]);
        SL.Free;
     end;
     LoadButton.Enabled:=True;
  end;
end;

procedure TProjectsForm.ComboBox1Change(Sender: TObject);
var
   SL:TPackStringList;
begin
   if FileName <> ComboBox1.Text then
   begin
      ComboBox1.Cursor:=crHourGlass;
      try
         if ComboBox1.Items.Objects[ComboBox1.ItemIndex] <> nil then
         begin
            if Assigned(FOnLoad) then FOnLoad(Self);
            Comps:=TRootNode(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
            if Assigned(FOnLoaded) then FOnLoaded(Self);
         end
         else
         begin
           Comps:=nil;
           LoadFile(ComboBox1.Items[ComboBox1.ItemIndex]);
           ComboBox1.Items.Objects[ComboBox1.ItemIndex]:=Comps;
         end;
         CompType:=-1;
         CompList.ItemIndex:=-1;
         if Assigned(CompList.OnDblClick) then CompList.OnDblClick(CompList);
         FileName:=ComboBox1.Items[ComboBox1.ItemIndex];
         RefreshLB;
         if Comps.Users.IndexOf('Clerk') <> -1 then
         begin
            SL:=TPackStringList.Create;
            SL.CommaText:=TUserNode(Comps.Users.Objects[Comps.Users.IndexOf('Clerk')]).Items;
            if SL.Count > 0 then
               Select(SL[0]);
            SL.Free;
         end;
      finally
         ComboBox1.Cursor:=crDefault;
      end;
   end;                 
end;
procedure TProjectsForm.Select(CompName:String);
var
   GridCoord:TGridRect;
   I:Integer;
begin
        if StrCmp(Copy(CompName,1,4),'Grou') then begin GridCoord.Left:=0; GridCoord.Top:=0; end
   else if StrCmp(Copy(CompName,1,4),'Prod') then begin GridCoord.Left:=1; GridCoord.Top:=0; end
   else if StrCmp(Copy(CompName,1,4),'User') then begin GridCoord.Left:=2; GridCoord.Top:=0; end
   else if StrCmp(Copy(CompName,1,4),'Pick') then begin GridCoord.Left:=0; GridCoord.Top:=1; end
   else if StrCmp(Copy(CompName,1,4),'Look') then begin GridCoord.Left:=1; GridCoord.Top:=1; end
   else if StrCmp(Copy(CompName,1,4),'Work') then begin GridCoord.Left:=2; GridCoord.Top:=1; end
   else if StrCmp(Copy(CompName,1,4),'Doma') then begin GridCoord.Left:=0; GridCoord.Top:=2; end
   else if StrCmp(Copy(CompName,1,4),'Snip') then begin GridCoord.Left:=1; GridCoord.Top:=2; end
   else if StrCmp(Copy(CompName,1,4),'Cons') then begin GridCoord.Left:=2; GridCoord.Top:=2; end
   else if StrCmp(Copy(CompName,1,4),'LogF') then begin GridCoord.Left:=0; GridCoord.Top:=3; end
   else if StrCmp(Copy(CompName,1,4),'Buil') then begin GridCoord.Left:=1; GridCoord.Top:=3; end
   else if StrCmp(Copy(CompName,1,4),'Proj') then begin GridCoord.Left:=2; GridCoord.Top:=3; end
   else Exit;
   GridCoord.Right:=GridCoord.Left;
   GridCoord.Bottom:=GridCoord.Top;
   StringGrid1.Selection:=GridCoord;
   RefreshLB;
   I:=CompList.Items.IndexOf(Copy(CompName,Pos('.',CompName)+1,Length(CompName)));
   if I >=0 then
   begin
      CompList.ItemIndex:=I;
      CompList.Selected[I]:=True;
      if Assigned(CompList.OnDblClick) then CompList.OnDblClick(CompList);
   end;
end;

procedure TProjectsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   SaveRegSettings;
   Action:=caFree;
end;

procedure TProjectsForm.CompListKeyPress(Sender: TObject; var Key: Char);
begin
   if (Key = Char(VK_RETURN)) and (Assigned(CompList.OnDblClick)) then
      CompList.OnDblClick(CompList);
end;

procedure TProjectsForm.CompListMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
   case CompType of
      0,              // Groups
      1: Height:=110; // Products
      7: Height:= 40; // Snippets
      8: Height:= 35; // Constants
      2,              // Users
      3,              // PickLists
      4,              // LookUps
      5,              // WorkStations
      6,              // Domains
      9,              // LogFormats
     10,              // BuildOptions
     11: Height:= 60; // Functions
   end;
end;

procedure TProjectsForm.CompListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   CorvusNode:TCorvusNode;
   BC:TColor;
   PLU:String;
begin
   CorvusNode:=Comps.NodeNamed(CompTypeName+'.'+CompList.Items[Index]);
   if CorvusNode <> nil then
   begin
      with CompList.Canvas do
      begin
         BC:=Brush.Color;
         Brush.Color:=clWindow;
         FillRect(Rect);
         Brush.Color:=BC;
      end;
      if CorvusNode is TGroupNode then
      begin
         TGroupNode(CorvusNode).Image;
         DrawAGroupNode(CompList.Canvas,
                     Bounds(Rect.Left+(((Rect.Right -Rect.Left)-160) div 2),
                            Rect.Top +(((Rect.Bottom-Rect.Top )-100) div 2),160,100),
                     TGroupNode(CorvusNode).Name,TGroupNode(CorvusNode).Caption,'',
                     CompList.Canvas.Brush.Color,
                     CompList.Canvas.Font.Color,
                     CompList.Canvas.Brush.Color,
                     TGroupNode(CorvusNode).Image,PEIcon.Picture.Bitmap);
     end
     else if CorvusNode is TProductNode then
     begin
         if Comps.NodeNamed('Constant.'+TProductNode(CorvusNode).PLU) <> nil then
            PLU:=TConstantNode(Comps.NodeNamed('Constant.'+TProductNode(CorvusNode).PLU))[0]
         else
            PLU:=TProductNode(CorvusNode).PLU;

         TProductNode(CorvusNode).Image;
         DrawAProductNode(CompList.Canvas,
                     Bounds(Rect.Left+(((Rect.Right -Rect.Left)-160) div 2),
                            Rect.Top +(((Rect.Bottom-Rect.Top )-100) div 2),160,100),
                     False,
                     TProductNode(CorvusNode).UnitPrice,
                     PLU,
                     TProductNode(CorvusNode).Name,TProductNode(CorvusNode).Caption,'',
                     CompList.Canvas.Brush.Color,
                     CompList.Canvas.Font.Color,
                     CompList.Canvas.Brush.Color,
                     TProductNode(CorvusNode).Image,PEIcon.Picture.Bitmap);
     end
     else if CorvusNode is TWorkstationNode then
     begin
         DrawAUGroupNode(CompList.Canvas,
                     Bounds(Rect.Left+(((Rect.Right -Rect.Left)-160) div 2),
                            Rect.Top +(((Rect.Bottom-Rect.Top )-50) div 2),160,50),
                     '',CorvusNode.Name,'',
                     CompList.Canvas.Brush.Color,
                     CompList.Canvas.Font.Color,
                     CompList.Canvas.Brush.Color,
                     WGroup.Picture.Bitmap,PEIcon.Picture.Bitmap);
     end
     else if CorvusNode is TUserNode then
     begin
         DrawAUGroupNode(CompList.Canvas,
                     Bounds(Rect.Left+(((Rect.Right -Rect.Left)-160) div 2),
                            Rect.Top +(((Rect.Bottom-Rect.Top )-50) div 2),160,50),
                     '',TUserNode(CorvusNode).Name,'',
                     CompList.Canvas.Brush.Color,
                     CompList.Canvas.Font.Color,
                     CompList.Canvas.Brush.Color,
                     UGroup.Picture.Bitmap,PEIcon.Picture.Bitmap);
     end
     else if CorvusNode is TFunctionNode then
     begin
         DrawAFunctionNode(CompList.Canvas,
                     Bounds(Rect.Left+(((Rect.Right -Rect.Left)-160) div 2),
                            Rect.Top +(((Rect.Bottom-Rect.Top )-50) div 2),160,50),
                     '',CorvusNode.Name,'',
                     CompList.Canvas.Brush.Color,
                     CompList.Canvas.Font.Color,
                     CompList.Canvas.Brush.Color,
                     GetPictureFromServer(CorvusNode.Name),nil,True);
     end
     else if CorvusNode is TDomainNode then
     begin
         DrawADomainNode(CompList.Canvas,
                     Bounds(Rect.Left+(((Rect.Right -Rect.Left)-160) div 2),
                            Rect.Top +(((Rect.Bottom-Rect.Top )-50) div 2),160,50),
                     CorvusNode.Name,TDomainNode(CorvusNode).Title,'',
                     CompList.Canvas.Brush.Color,
                     CompList.Canvas.Font.Color,
                     CompList.Canvas.Brush.Color,
                     nil,PEIcon.Picture.Bitmap);
     end
     else if CorvusNode is TSnippetNode then
     begin
         DrawASnippetNode(CompList.Canvas,
                     Bounds(Rect.Left+(((Rect.Right -Rect.Left)-160) div 2),
                            Rect.Top +(((Rect.Bottom-Rect.Top )-37) div 2),160,37),
                     CorvusNode.Name,TSnippetNode(CorvusNode).InsertBetween,'',
                     CompList.Canvas.Brush.Color,
                     CompList.Canvas.Font.Color,
                     CompList.Canvas.Brush.Color,
                     Snippet.Picture.Bitmap,PEIcon.Picture.Bitmap);
     end
     else if CorvusNode is TConstantNode then
     begin
         DrawAConstantNode(CompList.Canvas,
                     Bounds(Rect.Left+(((Rect.Right -Rect.Left)-160) div 2),
                            Rect.Top +(((Rect.Bottom-Rect.Top )-30) div 2),160,30),
                     CorvusNode.Name,CorvusNode[0],
                     CompList.Canvas.Brush.Color,
                     CompList.Canvas.Font.Color,
                     CompList.Canvas.Brush.Color);
     end
     else
     begin
         with CompList.Canvas do
         begin
            Pen.Color:=clBlack;
            Rectangle(Rect.Left+(((Rect.Right -Rect.Left)-160) div 2),
                      Rect.Top +(((Rect.Bottom-Rect.Top )-50) div 2),
                      Rect.Left+(((Rect.Right -Rect.Left)-160) div 2)+160,
                      Rect.Top +(((Rect.Bottom-Rect.Top )-50) div 2)+50);
            TextOut(Rect.Left+(((Rect.Right -Rect.Left)-160) div 2)+1,
                    Rect.Top +(((Rect.Bottom-Rect.Top )-50) div 2)+1,
                    TCorvusNode(CorvusNode).Name);
         end;
     end;
   end;
end;

procedure TProjectsForm.ComboBox1DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   FN:String;
begin
   with ComboBox1.Canvas do
   begin
      FillRect(Rect);
      FN:=ExtractFileName(ComboBox1.Items[Index]);          // remove path
      FN:=Copy(FN,1,Length(FN)-Length(ExtractFileExt(FN))); // remove extension
      TextOut(Rect.Left+2,Rect.Top,FN);
   end;
end;
function GetAttr(Node:TCorvusNode;AttrName:String):String;
begin
   Result:='';
   if Node <> nil then
      Result:=GetObjectProperty(Node,AttrName);
end;
var
   AttrName:String;

function ListSortCompare(Item1,Item2:Pointer):Integer;
begin
   Result:=StrComp(PChar(GetAttr(Item1,AttrName)),PChar(GetAttr(Item2,AttrName)));
end;

procedure TProjectsForm.ComboBox2Change(Sender: TObject);
var
   List:TList;
   I:Integer;
begin
   List:=TList.Create;
   CompList.Sorted:=False;
   for I:=0 to CompList.Items.Count-1 do
   begin
      if CompList.Items.Objects[I] = nil then
         CompList.Items.Objects[I]:=Comps.NodeNamed(CompTypeName+'.'+CompList.Items[I]);
      if CompList.Items.Objects[I] = nil then
      begin
         List.Add(TCorvusNode.Create(CompList.Items[I],'X_X_X_X_X',0));
      end
      else
      begin
         List.Add(CompList.Items.Objects[I]);
      end;
   end;
   AttrName:=ComboBox2.Items[ComboBox2.ItemIndex];
   List.Sort(ListSortCompare);
   CompList.Clear;
   for I:=0 to List.Count-1 do
      CompList.Items.Add(TCorvusNode(List[I]).Name);
   for I:=0 to List.Count-1 do
      if TCorvusNode(List[I]).FileName = 'X_X_X_X_X' then
         TCorvusNode(List[I]).Free;
   List.Free;
   
   if Sender <> nil then
      FilterChange(nil);
end;
function FindStrInAttrs(Filter:String;TheObject:TObject):Boolean;
var
   SL:TStringList;
   S:String;
   I:Integer;
begin
   Result:=True;
   SL:=TStringList.Create;
   SL.Text:=ListPropertyNames(TheObject);
   for I:=0 to SL.Count-1 do
   begin
      S:=UpperCase(GetObjectProperty(TheObject,SL[I]));
      if Pos(Filter,S) > 0 then
      begin
         SL.Free;
         Exit;
      end;
   end;
   SL.Free;
   Result:=False;
end;
procedure TProjectsForm.FilterChange(Sender: TObject);
var
   I:Integer;
   FilterS:String;
   Found:Boolean;
begin
   CompList.Items.Assign(CurrentList);
   if Sender <> nil then
      ComboBox2Change(nil);
   if (Filter.Text = '') or (FilterButton.Caption = 'None') then Exit;

   FilterS:=UpperCase(Trim(Filter.Text));
   I:=0;
   while I < CompList.Items.Count do
   begin
      Found:=False;
      if CompList.Items.Objects[I] = nil then
         CompList.Items.Objects[I]:=Comps.NodeNamed(CompTypeName+'.'+CompList.Items[I]);
      if CompList.Items.Objects[I] <> nil then
      begin
         if FilterButton.Caption = 'Order' then
         begin
            if Pos(FilterS,UpperCase(GetObjectProperty(CompList.Items.Objects[I],ComboBox2.Text))) > 0 then
               Found:=True;
         end
         else
         begin
            if FindStrInAttrs(FilterS,CompList.Items.Objects[I]) then
               Found:=True;
         end;
      end
      else if Pos(FilterS,CompList.Items[I]) > 0 then
      begin
         Found:=True;
      end;

      if Found then Inc(I) else CompList.Items.Delete(I)
   end;
end;

procedure TProjectsForm.FilterButtonClick(Sender: TObject);
begin
   if FilterButton.Caption = 'None' then
      FilterButton.Caption:='Order'
   else if FilterButton.Caption = 'Order' then
      FilterButton.Caption:='All'
   else
      FilterButton.Caption:='None';

   FilterChange(Filter);
end;

end.


