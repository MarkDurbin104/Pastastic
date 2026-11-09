unit VersionInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,ExtCtrls;

type
  TVersionInfo = class(TGraphicControl)
  private
     FAutoUpdate:Boolean;
     FVersion:Integer;
     FDate:TDateTime;
     FCopyRight:String;
     FHeadingWidth:Integer;
     FColor:TColor;
     Timer:TTimer;
     FShowBorder:Boolean;
     FVisible:Boolean;
     FCopyRightT:String;
     FDateT     :String;
     FVersionT  :String;
     procedure SetWidthHeight;
     function  VersionAsString:String;
     function  DateAsString:String;
     function  CopyRightAsString:String;
     procedure SetShowBorder(Value:Boolean);
     procedure SetColor(Value:TColor);
     procedure SetVersion(Value:Integer);
     procedure SetVisible(Value:Boolean);
     procedure SetDate(Value:TDateTime);
     procedure SetCopyRight(Value:String);
     procedure TimerTick(Sender: TObject);
     function  CheckWidthHeight:Boolean;
     procedure SetCopyRightT(Value:String);
     procedure SetDateT     (Value:String);
     procedure SetVersionT  (Value:String);
  protected                                    
    procedure Paint; override;
  public
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
  published
     property AutoUpdate:Boolean    read FAutoUpdate write FAutoUpdate  ;
     property ShowBorder:Boolean    read FShowBorder write SetShowBorder;
     property Copyright:String      read FCopyRight  write SetCopyRight ;
     property Color:TColor          read FColor      write SetColor     ;
     property Date:TDateTime        read FDate       write SetDate      ;
     property Version:Integer       read FVersion    write SetVersion   ;
     property Visible:Boolean       read FVisible    write SetVisible   ;
     property CopyrightTitle:String read FCopyRightT write SetCopyRightT;
     property DateTitle:String      read FDateT      write SetDateT     ;
     property VersionTitle:String   read FVersionT   write SetVersionT  ;
     property Font;
  end;

procedure Register;

//{$R VersionInfo.Res}

implementation

function Max(A,B:Integer):Integer;
begin
   if A > B then Result:=A else Result:=B;
end;
function TVersionInFo.CheckWidthHeight:Boolean;
var
   W,H:Integer;
begin
   W:=Width;
   H:=Height;
   
   if not FVisible then
   begin
      Width :=Canvas.TextWidth(FVersionT+' '+IntToStr(FVersion))+4;
      Height:=Canvas.TextHeight('Wg')+2;
   end
   else
   begin
      with Canvas do
      begin
         FHeadingWidth:=Max(Max( TextWidth(FVersionT)  ,
                                 TextWidth(FDateT)     ),
                                 TextWidth(FCopyrightT)) + 5;
         Width:=Max(Max( TextWidth(VersionAsString)   ,
                         TextWidth(DateAsString)      ),
                         TextWidth(CopyRightAsString) ) + 10 + FHeadingWidth;
         Height:=TextHeight('Wg')*3+11;
      end;
   end;
   Result:=(W <> Width) or (H <> Height);
end;
   
procedure TVersionInFo.SetWidthHeight;
begin
   CheckWidthHeight;
   Invalidate;
end;    
function TVersionInFo.VersionAsString:String;
begin
   Result:=IntToStr(FVersion);
end;
function TVersionInFo.DateAsString:String;
begin
   Result:=DateToStr(FDate);
end;
function TVersionInFo.CopyRightAsString:String;
begin
   Result:=FCopyRight;
end;
procedure TVersionInFo.SetVersion(Value:Integer);
begin
   if FVersion <> Value then
   begin
      FVersion:=Value;
      SetWidthHeight;
   end;
end;                 
procedure TVersionInFo.SetDate(Value:TDateTime);
begin
   if (csDesigning in ComponentState) and (FAutoUpdate) then
      Value:=Now;
   if FDate <> Value then
   begin
      FDate:=Value;
      if FVisible then SetWidthHeight;
   end;
end;
procedure TVersionInFo.SetCopyRightT(Value:String);
begin
   if FCopyRightT <> Value then
   begin
      FCopyRightT:=Value;
      SetWidthHeight;
   end;
end;
procedure TVersionInFo.SetDateT     (Value:String);
begin
   if FDateT <> Value then
   begin
      FDateT:=Value;
      SetWidthHeight;
   end;
end;
procedure TVersionInFo.SetVersionT  (Value:String);
begin
   if FVersionT <> Value then
   begin
      FVersionT:=Value;
      SetWidthHeight;
   end;
end;
procedure TVersionInFo.SetCopyRight(Value:String);
begin
   if FCopyRight <> Value then
   begin
      FCopyRight:=Value;
      SetWidthHeight;
   end;
end;                 
procedure TVersionInFo.SetShowBorder(Value:Boolean);
begin
   if FShowBorder <> Value then
   begin
      FShowBorder:=Value;
      Invalidate;
   end;
end;                 
procedure TVersionInFo.SetVisible(Value:Boolean);
begin
   if FVisible <> Value then
   begin
      FVisible:=Value;
      inherited Visible:=Value;
      Invalidate;
   end;
end;                 
procedure TVersionInFo.SetColor(Value:TColor);
begin
   if FColor <> Value then
   begin
      FColor:=Value;
      Invalidate;
   end;
end;                 
procedure TVersionInFo.TimerTick(Sender: TObject);
begin
   Date:=FDate;
end;
constructor TVersionInFo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  FDate:=Now;
  FVersion:=1;
  FCopyRight:='Postal Solutions Limited';
  FCopyRightT:='Copyright';
  FVersionT:='Version';
  FDatet:='Build Date';
  FColor:=clBtnFace;
  FHeadingWidth:=0;
  FShowBorder:=True;
  if (csDesigning in ComponentState) then
  begin
     Timer:=TTimer.Create(Self);
     Timer.Interval:=1000;
     Timer.OnTimer:=TimerTick;
     Timer.Enabled:=True;
  end;
  Width:=100;
  Height:=50;
end;
destructor TVersionInFo.Destroy;
begin
  if Timer <> nil then Timer.Free;
  inherited Destroy;
end;
procedure TVersionInFo.Paint;
var
   TH:Integer;
   FC:TColor;
begin
   Canvas.Font:=Font;
   Canvas.Brush.Color:=FColor;
   if (not FVisible) then
   begin
      if (csDesigning in ComponentState) then
      begin
         CheckWidthHeight;
         Canvas.Pen.Color:=clBlack;
         Canvas.Rectangle(0,0,Width,Height);
         Canvas.Font:=Font;
         Canvas.TextOut(2,1,FVersionT+' '+IntToStr(FVersion));
      end;
      Exit;
   end;
   CheckWidthHeight;
   with Canvas do                                     
   begin
      TH:=TextHeight('Wg');
      if FShowBorder then
         Pen.Color:=clBlack
      else
         Pen.Color:=Brush.Color;
      Rectangle(0,0,Width,Height);
      FC:=Font.Color;
      Font.Color:=clBlack;
      TextOut(5,5     ,FVersionT);
      TextOut(5,5+TH  ,FDateT);
      TextOut(5,5+TH*2,FCopyrightT);
      Font.Color:=FC;
      TextOut(5+FHeadingWidth,5     ,VersionAsString);
      TextOut(5+FHeadingWidth,5+TH  ,DateAsString);
      TextOut(5+FHeadingWidth,5+TH*2,CopyRightAsString);
   end;
end;

procedure Register;
begin
  RegisterComponents('CorvusVCL', [TVersionInfo]);
end;

end.
