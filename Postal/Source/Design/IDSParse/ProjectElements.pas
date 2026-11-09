unit ProjectElements;

interface

uses
   Classes,Controls,Graphics,ParseNode,PackStrListU;
   
type
  TProjectElements = class(TCustomControl)
  private
     FPenColor:TColor;
     FFileName:String;
     FModified:Boolean;
     procedure SetFileName(Value:String);
  protected
    procedure MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
    procedure MouseMove(Shift:TShiftState;X,Y:Integer); override;
    procedure MouseUp(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
  public
     Parser:TParser;
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
     procedure Paint; override;
     procedure Save;
     procedure SaveAs(FileName:String);
     procedure CalcRectSize;
  published
     property FileName:String  read FFileName write SetFileName;
     property Modified:Boolean read FModified write FModified;
     property PenColor:TColor  read FPenColor write FPenColor;
     property Color;
     property ParentColor;
     property Font;
     property ParentFont;
     property Align;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('CorvusDev', [TProjectElements]);
end;
{TProjectElements}
constructor TProjectElements.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   Parser:=nil;
   FFileName:='';
   FModified:=False;
   ParentColor:=False;
   Color:=clWindow;
   Width:=100;
   Height:=100;
end;   
destructor TProjectElements.Destroy;
begin
   if Parser <> nil then
      Parser.Free;
   inherited Destroy;
end;
procedure TProjectElements.Paint;
begin
   Canvas.Font:=Font;
   Canvas.Brush.Color:=Color;
   Canvas.Pen.Color:=FPenColor;
   with Canvas do
   begin
      FillRect(ClientRect);
      Parser.DrawNodes(Canvas);
   end;
end;
procedure TProjectElements.MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
var
   Node:TNode;
   Exp:Boolean;
begin
   inherited MouseDown(Button,Shift,X,Y);
   Exp:=False;
   Node:=Parser.FindNode(X,Y,Exp);
   if (Node <> nil) then 
   begin
      if Exp then
      begin
         Node.IsExpanded:=not Node.IsExpanded;
         CalcRectSize;
      end
      else
      begin
        Node.IsSelected:=not Node.IsSelected;
        Invalidate;
      end
   end;  
end;
procedure TProjectElements.MouseMove(Shift:TShiftState;X,Y:Integer);
begin
   inherited MouseMove(Shift,X,Y);
end;
procedure TProjectElements.MouseUp(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
   inherited MouseUp(Button,Shift,X,Y);
end;
procedure TProjectElements.CalcRectSize;
var
   H:Integer;
   W:Integer;
begin
   if Parser = nil then
   begin
      H:=100;
      W:=100;
   end
   else
   begin
      H:=Parser.GetHeight(Canvas);
      W:=Parser.GetWidth(Canvas);
   end; 
   if (Width <> W) or (Height <> H) then 
   begin
      SetBounds(Left,Top,W,H);
      Invalidate;
   end;
end;
procedure TProjectElements.Save;
begin
   if Modified then
   begin
      // Save Code Here
      Modified:=False;
   end;
end;
procedure TProjectElements.SaveAs(FileName:String);
begin
   FFileName:=FileName;
   Modified:=True;
   Save;
end;
procedure TProjectElements.SetFileName(Value:String);
var
   SL:TPackStringList;
begin
   if Value <> FFileName then
   begin
      if Parser <> nil then Parser.Free;
      FFileName:=Value;
      SL:=TPackStringList.Create;
      try
         SL.LoadFromFile(FFileName);
         Parser:=TParser.Create(SL.Text);
      except
      end;
      SL.Free;
      CalcRectSize;
   end;
end;

end.
