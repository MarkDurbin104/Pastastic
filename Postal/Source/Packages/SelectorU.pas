unit SelectorU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, 
  Forms, Dialogs,Buttons,Menus;

type
  TSelector = class;
  TItemSelected = procedure(Sender:TSelector) of object;
  TRename = procedure(Sender:TSelector;OldName,NewName:String) of object;
  TDelete = procedure(Sender:TSelector;Name:String) of object;
  TSelector = class(TCustomControl)
  private
    FItems:TStringList;
    FSelected:Integer;
    FItemSelected:TItemSelected;
    FSelectorPopUp:TPopupMenu;
    FRename:TRename;
    FDelete:TDelete;
   procedure AddClick(Sender: TObject);
   procedure DeleteClick(Sender: TObject);
   procedure RenameClick(Sender: TObject);
  protected
    function GetCount:Integer;
    function GetItem(Index:Integer):String;
    procedure SetItems(Value:TStringList);
    procedure SetSelected(Value:Integer);
    procedure MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
    function DrawTabFace(Canvas:TCanvas;const Client:TRect;BevelWidth:Integer;IsDown:Boolean):TRect;
    procedure ItemsChanged(Sender:TObject);
    function GetGroup(Index:Integer):TStringList;
    procedure SetGroup(Index:Integer;Value:TStringList);
  public                      
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    property Count:Integer read GetCount;
    procedure Add(Value:String);
    procedure AddObject(Value:String;AObject:TObject);
    property Item[Index:Integer]:String read GetItem; default;
    property Group[Index:Integer]:TStringList read GetGroup write SetGroup;
  published
    property Items:TStringList read FItems write SetItems;
    property Selected:Integer read FSelected write SetSelected;
    property Color;   
    property Font;
    property ParentColor;
    property ParentFont;
    property ShowHint; 
    property Align;    
    property DragMode;    
    property OnItemSelected:TItemSelected read FItemSelected write FItemSelected;
    property OnRename:TRename read FRename write FRename;
    property OnDelete:TDelete read FDelete write FDelete;
    property OnDragOver;
    property OnDragDrop;
  end;

procedure Register;

implementation

procedure TSelector.AddClick(Sender: TObject);
var
   G:String;
begin
   G:=InputBox('Group','Enter a new Group Name','');
   if G <> '' then
   begin
      Items.Add(G);
      Selected:=Selected;
   end;
end;
                          
function TSelector.GetGroup(Index:Integer):TStringList;
begin
   if Index < Count then
   begin
      if FItems.Objects[Index] = nil then
         FItems.Objects[Index]:=TStringList.Create;
      Result:=TStringList(FItems.Objects[Index])
   end
   else
      Result:=nil;
end;
procedure TSelector.SetGroup(Index:Integer;Value:TStringList);
begin
   if Index < Count then
   begin
      if FItems.Objects[Index] = nil then
         FItems.Objects[Index]:=TStringList.Create;
      TStringList(FItems.Objects[Index]).Assign(Value)
   end;
end;
procedure TSelector.DeleteClick(Sender: TObject);
begin                     
   if Assigned(FDelete) then FDelete(Self,Items[Selected]);
   Items.Delete(Selected);
end;

procedure TSelector.RenameClick(Sender: TObject);
var
   G:String;
   OG:String;
begin
   G:=InputBox('Product Group','Enter a new Group Name',Items[Selected]);
   if G <> Items[Selected] then
   begin
     OG:=Items[Selected];
     Items[Selected]:=G;
     if Assigned(FRename) then FRename(Self,OG,G);
   end;
end;
procedure TSelector.ItemsChanged(Sender:TObject);
begin
   Invalidate;
end;
constructor TSelector.Create(AOwner: TComponent);
var
   NewItem:TMenuItem;
begin
   inherited Create(AOwner);
   FItems:=TStringList.Create;
   FItems.OnChange:=ItemsChanged;
   Width:=100;
   Height:=100;
   FSelectorPopUp:=TPopupMenu.Create(nil);
   
   NewItem:=TMenuItem.Create(Self);
   NewItem.Caption:='&Add';
   NewItem.OnClick:=AddClick;
   FSelectorPopUp.Items.Add(NewItem);
   
   NewItem:=TMenuItem.Create(Self);
   NewItem.Caption:='&Delete';
   NewItem.OnClick:=DeleteClick;
   FSelectorPopUp.Items.Add(NewItem);
   
   NewItem:=TMenuItem.Create(Self);
   NewItem.Caption:='-';
   FSelectorPopUp.Items.Add(NewItem);
   
   NewItem:=TMenuItem.Create(Self);
   NewItem.Caption:='&Rename';
   NewItem.OnClick:=RenameClick;
   FSelectorPopUp.Items.Add(NewItem);
   
   NewItem:=TMenuItem.Create(Self);
   NewItem.Caption:='-';
   FSelectorPopUp.Items.Add(NewItem);
   
   NewItem:=TMenuItem.Create(Self);
   NewItem.Caption:='&Cut';
   FSelectorPopUp.Items.Add(NewItem);
   
   NewItem:=TMenuItem.Create(Self);
   NewItem.Caption:='C&opy';
   FSelectorPopUp.Items.Add(NewItem);
   
   NewItem:=TMenuItem.Create(Self);
   NewItem.Caption:='&Paste';
   FSelectorPopUp.Items.Add(NewItem);
   PopUpMenu:=FSelectorPopUp;
end;                        
destructor TSelector.Destroy;
var
   I:Integer;
begin
   for I:=0 to Count-1 do 
      if FItems.Objects[I] <> nil then 
         TStringList(FItems.Objects[I]).Free;
   FItems.Free;
   FSelectorPopUp.Free;
   inherited Destroy;        
end;
procedure TSelector.MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
  inherited MouseDown(Button,Shift,X,Y);
  if Button = mbLeft then
     BeginDrag(False);
  Selected:=Y div (Height div Count);
end;
procedure TSelector.SetItems(Value:TStringList);
begin
   if FItems <> nil then
   begin
      FItems.Assign(Value);
      Invalidate;
   end;
end;             
procedure TSelector.SetSelected(Value:Integer);
var
   R:TRect;
   BH:Integer;
begin
   if (FItems <> nil) and (Value >= 0) and (Value < Count) then
   begin
      BH:=(Height div Count);
      R:=Bounds(0,BH*FSelected,Width,BH-1);
      InvalidateRect(Handle,@R,True);
      FSelected:=Value;
      R:=Bounds(0,BH*FSelected,Width,BH-1);
      InvalidateRect(Handle,@R,True);
      if Assigned(FItemSelected) then FItemSelected(Self);
   end;
end;             
procedure TSelector.Add(Value:String);
begin
   if FItems <> nil then
   begin
      FItems.Add(Value);
      Invalidate;
   end;
end;             
procedure TSelector.AddObject(Value:String;AObject:TObject);
begin
   if FItems <> nil then
   begin
      FItems.AddObject(Value,AObject);
      Invalidate;
   end;
end;
function TSelector.GetCount:Integer;               
begin
   if FItems <> nil then
      Result:=FItems.Count
   else
      Result:=0
end;   
function TSelector.GetItem(Index:Integer):String;
begin
   if Index < Count then
      Result:=FItems[Index]
   else
      Result:=''
end;
function TSelector.DrawTabFace(Canvas:TCanvas;const Client:TRect;BevelWidth:Integer;IsDown:Boolean):TRect;
var
  R:TRect;
  DC:THandle;
begin
  R:=Client;
  with Canvas do
  begin
      Brush.Color:=Color; //clBtnFace
      Brush.Style:=bsSolid;
      DC:=Canvas.Handle;    { Reduce calls to GetHandle }
      if not IsDown then
      begin
        DrawEdge(DC,R,BDR_RAISEDOUTER,BF_BOTTOMRIGHT);          { black }
        Dec(R.Bottom);
        Dec(R.Right);
        DrawEdge(DC,R,BDR_RAISEDINNER,BF_TOPLEFT);              { btnhilite }
        Inc(R.Top);
        Inc(R.Left);
        DrawEdge(DC,R,BDR_RAISEDINNER,BF_BOTTOMRIGHT or BF_MIDDLE); { btnshadow }
      end
      else
        FillRect(R);
         
  end;
  Result:=Rect(Client.Left+1,Client.Top+1,Client.Right-2,Client.Bottom-2);
  if IsDown then OffsetRect(Result,1,1);
end;
procedure TSelector.Paint;
var
   I,BH:Integer;
   R:TRect;
begin
   inherited Paint;
   Canvas.Brush.Color:=Color;
   Canvas.Font:=Font;
   with Canvas do
   begin
      Canvas.Brush.Color:=clBtnFace;
      R:=Bounds(0,0,Width,Height);
      FillRect(R);
      Canvas.Brush.Color:=Self.Color;
      if Count = 0 then
      begin
         R:=Bounds(0,0,Width,Height);
         R:=DrawTabFace(Canvas,R,2,False);
         Font.Style:=[fsBold];
         DrawText(Canvas.Handle,PChar(Name),Length(Name),R,DT_WORDBREAK or DT_CALCRECT);
         OffsetRect(R,(Width-R.Right) div 2,0);
         Brush.Style:=bsClear;
         DrawText(Canvas.Handle,PChar(Name),Length(Name),R,DT_WORDBREAK or DT_CENTER);
         Brush.Style:=bsSolid;
         Font.Style:=[];
      end
      else
      begin
         for I:=0 to Count-1 do
         begin
            BH:=(Height div Count);
            R:=Bounds(0,BH*I,Width,BH-1);
            R:=DrawTabFace(Canvas,R,2,I = FSelected);
            Brush.Style:=bsClear;
            if I = FSelected then
               Font.Style:=[fsBold];
            DrawText(Canvas.Handle,PChar(Item[I]),Length(Item[I]),R,DT_WORDBREAK or DT_CALCRECT);
            OffsetRect(R,(Width-R.Right) div 2,0);
            Brush.Style:=bsClear;
            DrawText(Canvas.Handle,PChar(Item[I]),Length(Item[I]),R,DT_WORDBREAK or DT_CENTER);
            Font.Style:=[];
            Brush.Style:=bsSolid;
         end;
      end;    
   end;
end;

procedure Register;
begin
  RegisterComponents('CorvusVCL', [TSelector]);
end;

end.
