unit AccountBase;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,PackStrListU;

type
  TAccountBase = class(TPaintBox)
  private
     FLineItemList:TPackStringList;
     FReporitingItemList:TPackStringList; 
     FLineItemHeight:Integer;
  protected
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    procedure SetLineItemList(Value:TStrings); virtual;
    function  GetLineItemList:TStrings; virtual;
    procedure SetLineItemHeight(Value:Integer); virtual;
  public
  published
     property LineItems:TStrings read GetLineItemList write SetLineItemList;
     property LineItemHeight:Integer read FLineItemHeight write SetLineItemHeight;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Accounts', [TAccountBase]);
end;

constructor TAccountBase.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   FLineItemHeight:=16;
   FLineItemList:=TPackStringList.Create;
end;
destructor TAccountBase.Destroy;
begin
   FLineItemList.Free;
   inherited Destroy;
end;
procedure TAccountBase.SetLineItemList(Value:TStrings);
begin
   FLineItemList.Assign(Value);
   Height:=FLineItemList.Count*FLineItemHeight+1;
   Invalidate;
end;
function TAccountBase.GetLineItemList:TStrings;
begin
   Result:=FLineItemList;
end;
procedure TAccountBase.SetLineItemHeight(Value:Integer);
begin
   if Value = FLineItemHeight then Exit;
   FLineItemHeight:=Value;
   Height:=FLineItemList.Count*Value+1;
   Invalidate;
end;
procedure TAccountBase.Paint;
var
   I:Integer;
begin
   Canvas.Font:=Font;
   Canvas.Pen.Color:=Font.Color;
   Canvas.Brush.Color:=Color;
   with Canvas do
   begin
      FillRect(Bounds(0,0,Width,Height));
      for I:=0 to FLineItemList.Count-1 do
      begin 
         Rectangle(0,I*FLineItemHeight,Width,(I+1)*FLineItemHeight+1);
         TextOut(2,1+I*FLineItemHeight,FLineItemList[I]);
      end;
   end;
end;
end.

