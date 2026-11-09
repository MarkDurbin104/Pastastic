unit HidePanelFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TLRTabPanel = class(TCustomControl)
  private
    FWindowRgn:THandle;
    FTabWidth :Integer;
    FTabHeight:Integer;
    FTabOffset:Integer;
    FMaxWidth :Integer;
    FIsMouseOver:Boolean;
    procedure GetBorders(var Points:Array of TPoint;Inner:Boolean);
  protected
    procedure Paint; override;
    procedure SetWinRgn; virtual;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public  
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property IsMouseOver:Boolean read FIsMouseOver;
  published
    property TabWidth :Integer read FTabWidth  write FTabWidth ;
    property TabHeight:Integer read FTabHeight write FTabHeight;
    property TabOffset:Integer read FTabOffset write FTabOffset;
    property MaxWidth :Integer read FMaxWidth  write FMaxWidth ;
  end;                  
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
{TLRTabPanel}
constructor TLRTabPanel.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FTabWidth :=20 ;
   FTabHeight:=100;
   FTabOffset:=0;
   FMaxWidth :=180;
   Width:=FTabWidth;
   FIsMouseOver:=False;
end;
destructor TLRTabPanel.Destroy;
begin
   inherited Destroy;   
end;
procedure TLRTabPanel.Paint;
var
  WBPoints : Array[0..8] of TPoint;
begin
   if (not FIsMouseOver) and (Width <> FTabWidth) then
      Width:=FTabWidth
   else if (FIsMouseOver) and (Width <> FMaxWidth) then
      Width:=FMaxWidth;
   SetWinRgn;
   GetBorders(WBPoints,True);
   Canvas.PolyLine(WBPoints);
end;
procedure TLRTabPanel.CMMouseEnter(var Message: TMessage);
begin
  if Parent <> nil then
    Parent.Perform(CM_MOUSEENTER,0,Longint(Self));
  FIsMouseOver:=True;
  Invalidate;
  BringToFront;
end;      

procedure TLRTabPanel.CMMouseLeave(var Message: TMessage);
begin
  if Parent <> nil then
    Parent.Perform(CM_MOUSELEAVE,0,Longint(Self));
  FIsMouseOver:=False;
  Invalidate;
end;
procedure TLRTabPanel.GetBorders(var Points:Array of TPoint;Inner:Boolean);
var
   IB:Integer;
begin
   if Inner then IB:=1 else IB:=0;
   Points[ 0 ].x := 0;           Points[ 0 ].y := TabOffset;
   Points[ 1 ].x := TabWidth;    Points[ 1 ].y := TabOffset;
   Points[ 2 ].x := TabWidth;    Points[ 2 ].y := 0;
   Points[ 3 ].x := Width-IB;    Points[ 3 ].y := 0;
   Points[ 4 ].x := Width-IB;    Points[ 4 ].y := Height-IB;
   Points[ 5 ].x := TabWidth;    Points[ 5 ].y := Height-IB;
   Points[ 6 ].x := TabWidth;    Points[ 6 ].y := TabOffset+TabHeight-IB;
   Points[ 7 ].x := 0;           Points[ 7 ].y := TabOffset+TabHeight-IB;
   if High(Points) = 8 then
   begin
      Points[ 8 ].x := 0;
      Points[ 8 ].y := TabOffset;
   end;
end;
procedure TLRTabPanel.SetWinRgn;
var
  WBPoints : Array[0..7] of TPoint;
begin
   GetBorders(WBPoints,False);
   FWindowRgn:=CreatePolygonRgn(WBPoints, 8, WINDING );
   if FWindowRgn <> 0 then
   begin
      SetWindowRgn(Handle,FWindowRgn,True);  //set region and redraw
       DeleteObject(FWindowRgn);
   end;
end;                       
procedure TForm1.Button1Click(Sender: TObject);
var
   LRTabPanel:TLRTabPanel;
begin
   LRTabPanel:=TLRTabPanel.Create(nil);
   InsertControl(LRTabPanel);
   LRTabPanel.SetBounds(0,0,180,ClientHeight);
   LRTabPanel.FTabOffset:=0;
 //  LRTabPanel.Color:=clRed;
   
   LRTabPanel:=TLRTabPanel.Create(nil);
   InsertControl(LRTabPanel);
   LRTabPanel.SetBounds(0,0,400,ClientHeight);
   LRTabPanel.FTabOffset:=LRTabPanel.TabHeight;
//   LRTabPanel.Color:=clGreen;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   y,m,d:Integer;	//	 1 <= m <= 12,  y > 1752
   dow:Integer;
Const 
   T:Array[0..11] of Integer= (0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4);
begin
   y:=1965;
   m:=1;
   d:=7;
   if m < 3 then  Dec(Y);
	dow:=(y + y div 4 - y div 100 + y div 400 + t[m-1] + d) mod 7;
   showmessage('Claire was born on day '+IntToStr(dow));
end;

end.
 