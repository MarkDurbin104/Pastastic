unit TxnlogU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,GPCSGUID,GPCSErrorLine,PackStrListU;

type
  TTxnLog = class;
  TTxnItem = class;
  TTxnList = class(TList)
  private
     function GetItem(Index:Integer):TTxnItem;
     procedure SetItem(Index:Integer;Value:TTxnItem);
  public
     property Items[Index:Integer]:TTxnItem read GetItem write SetItem;
  end;
  TTxnItem = class(TObject)
  private
     FParent      : TTxnLog;
     FTxnType     : String;
     FQuantity    : Integer;
     FPrice       : Currency;
     FValue       : Currency;
     FAddIndex    : Integer;
     FPLU         : Integer;  
     FDescription : String;
     FAdditional  : String;    
     FProgID      : String;
     FDomInfo     : String; 
     FAssociatedData:TTxnList;
     function  GetPrice      :Currency;
     function  GetValue      :Currency;
     procedure SetQuantity   (Value:Integer );
     procedure SetPrice      (Value:Currency);
     procedure SetValue      (Value:Currency);
     procedure SetDescription(Value:String  );
     procedure SetAddIndex   (Value:Integer );
     procedure SetPLU        (Value:Integer );
     procedure SetProgID     (Value:String  );
     procedure SetDomInfo    (Value:String  );
     function  GetValueAsString:String;
  protected
     QWidth:Integer;
     VWidth:Integer;
  public
    constructor Create(Parent:TTxnLog;Index,Quantity,PLU:Integer;Value,Price:Currency;
                       Description,Additional,ProgID,DomInfo:String);
    destructor Destroy; override;
    property AssociatedData:TTxnList read FAssociatedData write FAssociatedData;
  published
    property Quantity     : Integer  read FQuantity    write SetQuantity   ;
    property TxnType      : String   read FTxnType     write FTxnType      ;
    property Price        : Currency read GetPrice     write SetPrice      ;
    property Value        : Currency read GetValue     write SetValue      ;
    property Description  : String   read FDescription write SetDescription;
    property Additional   : String   read FAdditional  write FAdditional   ;
    property ValueAsString: String   read GetValueAsString     ;
    property AddIndex     : Integer  read FAddIndex    write SetAddIndex   ;
    property PLU          : Integer  read FPLU         write SetPLU        ;
    property ProgID       : String   read FProgID      write SetProgID     ;
    property DomInfo      : String   read FDomInfo     write SetDomInfo    ;
  end;

  TTxnLog = class(TCustomControl)
  private
    FTotalVisible   :Boolean;
    FTotal          :Currency;
    FSubLogTotal    :Currency;
    ItemHeight      :Integer;
    FTopItem        :Integer;
    FItemIndex      :Integer;
    TitleHeight     :Integer;
    TitleFontHeight :Integer;
    QWidth          :Integer;
    VWidth          :Integer;
    FItems          :TPackStringList;
    FSubLog         :TPackStringList;
    FSubLogColor    :TColor;
    FLineColor      :TColor;
    FSubLogVisible  :Boolean;
    FShowVLines     :Boolean;
    FShowHLines     :Boolean;
    FDigits         :Integer;
    FDecimals       :Integer;
    function  GetItems (Index:Integer):TTxnItem;
    function  GetSubLog(Index:Integer):TTxnItem;
    function  GetCount:Integer;
    procedure SetWidths;
    procedure SetBoolean(Index:Integer;Value:Boolean);
    procedure SetInteger(Index:Integer;Value:Integer);
    procedure SetColor  (Index:Integer;Value:TColor );
    procedure OutTextRect(Dest:TRect;Text:String;uFormat:Integer);
    procedure ReCalc;
  protected
    procedure Paint; override;
    procedure MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
    procedure WMSize      (var Message: TMessage);      message WM_SIZE      ;
    procedure WMSetFocus  (var Message: TWMSetFocus);   message WM_SETFOCUS  ;
    procedure WMKillFocus (var Message: TWMSetFocus);   message WM_KILLFOCUS ;
    procedure CNKeyDown   (var Message: TWMKeyDown);    message CN_KEYDOWN   ;
    procedure CNSysKeyDown(var Message: TWMKeyDown);    message CN_SYSKEYDOWN;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddToSubLog(Index,Quantity,PLU:Integer;Value,Price:Currency;Description,Additional,ProgID,DomInfo:String):Integer;
    function Add(Index,Quantity,PLU:Integer;Value,Price:Currency;Description,Additional,ProgID,DomInfo:String):Integer;
    procedure Delete(Index:Integer);
    procedure ClearSubLog;
    procedure Clear;
    property Items[Index:Integer]:TTxnItem  read GetItems;      default;
    property SubLog[Index:Integer]:TTxnItem read GetSubLog;
  published
    property Align;
    property Color;
    property Font;
    property ParentColor;
    property ParentFont;
    property TabStop;
    property Total:Currency                 read FTotal;
    property Count:Integer                  read GetCount;
    property SubLogColor:TColor    index 0  read FSubLogColor   write SetColor;
    property LineColor:TColor      index 1  read FLineColor     write SetColor;
    property SubLogVisible:Boolean index 0  read FSubLogVisible write SetBoolean;
    property ShowVLines:Boolean    index 1  read FShowVLines    write SetBoolean;
    property ShowHLines:Boolean    index 2  read FShowHLines    write SetBoolean;
    property TotalVisible:Boolean  index 3  read FTotalVisible  write SetBoolean;
    property Digits   :Integer     index 0  read FDigits        write SetInteger;
    property Decimals :Integer     index 1  read FDecimals      write SetInteger;
    property TopItem  :Integer     index 2  read FTopItem       write SetInteger;
    property ItemIndex:Integer     index 3  read FItemIndex     write SetInteger;
  end;

procedure Register;

implementation
var
   ZeroValues:Boolean = False;
//{$R TxnLogBmp.Res}
{TTxnList}
function TTxnList.GetItem(Index:Integer):TTxnItem;
begin
   Result:=TTxnItem(inherited Items[Index]);
end;
procedure TTxnList.SetItem(Index:Integer;Value:TTxnItem);
begin
   if (Index >= 0) and (Index < Count) then
   inherited Items[Index]:=Value
end;
{TTxnItem}
constructor TTxnItem.Create(Parent:TTxnLog;Index,Quantity,PLU:Integer;
                            Value,Price:Currency;
                            Description,Additional,ProgID,DomInfo:String);
begin
   FParent:=Parent;
   FPrice:=Price;
   FAddIndex:=Index;
   FPLU     :=PLU;
   FProgID  :=ProgID ;
   FDomInfo :=DomInfo;
   FTxnType :='TxnLine';
   FAdditional:=Additional;
   FAssociatedData:=TTxnList.Create;
   if (Price = 0) and (Quantity < 2) then //only when 0/1 items passed in 
      FQuantity:=1
   else
      FQuantity:=Quantity;
      
//   if Value = 0 then
//      FValue:=Price*FQuantity
//   else
   FValue:=Value;
      
   FDescription:=Description;
   QWidth:=0;
   VWidth:=0;
end;
destructor TTxnItem.Destroy;
var
   I:Integer;
begin
   for I:=0 to FAssociatedData.Count-1 do
       FAssociatedData.Items[I].Free;
   FAssociatedData.Free;
   FAssociatedData:=nil;
   inherited Destroy;
end;
procedure TTxnItem.SetQuantity(Value:Integer);
begin
   try
      if FQuantity <> Value then
      begin
         if ((FPrice = 0) or (FValue = 0))
         and (FTxnType <> 'PrLabel') then Exit;
         QWidth:=0;
         VWidth:=0;
         FQuantity:=Value;
         FValue:=FQuantity*FPrice;
         if FParent <> nil then // the first PrLabel entry (WriteTransaction with no *) has no Parent!
            FParent.ReCalc;
      end;
   except
      on E : Exception do RaiseGUIDException('{B3F71C11-ACE1-4528-B6A8-FA08014F42E4}', E);
   end;
end;
function TTxnItem.GetPrice:Currency;
begin
   if ZeroValues then
      Result:=0
   else
      Result:=FPrice;
end;
function TTxnItem.GetValue:Currency;
begin
   if ZeroValues then
      Result:=0
   else
      Result:=FValue;
end;
procedure TTxnItem.SetPrice(Value:Currency);
begin
   if FPrice <> Value then
   begin
      VWidth:=0;
      FPrice:=Value;
      FValue:=FQuantity*FPrice;
      if FParent <> nil then // the first PrLabel entry (WriteTransaction with no *) has no Parent!
         FParent.ReCalc;
   end;
end;
procedure TTxnItem.SetValue(Value:Currency);
begin
   if FValue <> Value then
   begin
      if FPrice <> 0 then
      begin
         FQuantity:=Trunc(Value/FPrice);
         FValue:=FQuantity*FPrice;
      end
      else
      begin
         FValue:=Value;
      end;
      VWidth:=0;
      QWidth:=0;
      if FParent <> nil then // the first PrLabel entry (WriteTransaction with no *) has no Parent!
         FParent.ReCalc;
   end;
end;
procedure TTxnItem.SetDescription(Value:String);
begin
   if FDescription <> Value then
   begin
      FDescription:=Value;
      if FParent <> nil then // the first PrLabel entry (WriteTransaction with no *) has no Parent!
         FParent.ReCalc;
   end;
end;
procedure TTxnItem.SetAddIndex(Value:Integer);
begin
   if FAddIndex <> Value then
   begin          
      FAddIndex:=Value;
      if FParent <> nil then // the first PrLabel entry (WriteTransaction with no *) has no Parent!
         FParent.ReCalc;
   end;
end;
procedure TTxnItem.SetPLU(Value:Integer);
begin
   if FPLU <> Value then
   begin
      FPLU:=Value;
      if FParent <> nil then // the first PrLabel entry (WriteTransaction with no *) has no Parent!
         FParent.ReCalc;
   end;
end;
procedure TTxnItem.SetProgID(Value:String);
begin
   if FProgID <> Value then
   begin
      FProgID:=Value;
      if FParent <> nil then // the first PrLabel entry (WriteTransaction with no *) has no Parent!
         FParent.ReCalc;
   end;
end;
procedure TTxnItem.SetDomInfo(Value:String);
begin
   if FDomInfo <> Value then
   begin
      FDomInfo:=Value;
      if FParent <> nil then // the first PrLabel entry (WriteTransaction with no *) has no Parent!
         FParent.ReCalc;
   end;
end;
function TTxnItem.GetValueAsString:String;
begin
   if FParent <> nil then // the first PrLabel entry (WriteTransaction with no *) has no Parent!
      Str(FValue:FParent.Digits:FParent.Decimals,Result);
   Result:=Trim(Result);
end;
 
{TTxnLog}
constructor TTxnLog.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   ZeroValues:=False;
   ControlStyle:=[csClickEvents];
   Name:='DontReCalc';
   FItems:=TPackStringList.Create;
   FSubLog:=TPackStringList.Create;
   ItemHeight:=14;
   TitleHeight:=40;
   TitleFontHeight:=30;
   FSubLogColor:=clGreen;
   FLineColor:=clBlack;
   Width :=150;
   Height:=300;
   QWidth:=25;
   VWidth:=40;
   ParentColor:=False;
   if (csDesigning in ComponentState) then 
   begin
      Add(0,100,0,0,9.99,'Item Description' ,'Info','Product.Test','');
      Add(1,  0,0,0,   0,'Additional'       ,'Info','Product.Test','');
      Add(2,  1,0,0,   1,'Priced Additional','Info','Product.Test','');
      AddToSubLog(0,1,0,0,0.99,'Sublog Item','Info','Product.Test','');
      AddToSubLog(1,0,0,0,0   ,'Sublog Item','Info','Product.Test','');
      AddToSubLog(2,1,0,0,0.99,'Sublog Item','Info','Product.Test','');
   end;
end;                                      
destructor TTxnLog.Destroy;
var
  I:Integer;
begin
   for I:=0 to Count-1 do if Items[I] <> nil then Items[I].Free;
   FItems.Free;
   FSubLog.Free;
   inherited Destroy;
end;
procedure TTxnLog.WMSize(var Message: TMessage);
begin
   if Width < 100 then Width:=100;
   if Height < 100 then Height:=100;
   ReCalc;
end;
procedure TTxnLog.MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
var
   I:Integer;
   Pos:Integer;
   CurPos:Integer;
begin
   CurPos:=FItemIndex;
   Pos:=(Y-3) div ItemHeight;
   if (Pos >= 0) and (Pos < FItems.Count) then
   begin
      for I:=Pos downto 0 do
      begin
         if Items[I].AddIndex = 0 then
         begin
            FItemIndex:=I;
            break;
         end;
      end;
   end; 
   if (CurPos = FItemIndex) and (Focused) then Exit;
   if Focused then 
      Recalc
   else
      SetFocus;
end;
procedure TTxnLog.WMSetFocus (var Message: TWMSetFocus);
var
   NextControl:TWinControl;
begin
   inherited;     
   if Count = 0 then
   begin
      NextControl:=FindNextControl(Self,False,True,False);
      if NextControl <> nil then NextControl.SetFocus;      
      Exit;
   end;
   ReCalc;
end; 
procedure TTxnLog.WMKillFocus(var Message: TWMSetFocus);
begin
   inherited;     
   ReCalc;   
end; 
procedure TTxnLog.CNKeyDown(var Message: TWMKeyDown);
var
  I:Integer;
begin
   if Count = 0 then 
   begin
      inherited;
      Exit;
   end;
   case Message.CharCode of
      VK_INSERT : 
         if SubLogVisible then 
            SubLogVisible:=False
         else
            SubLogVisible:=True;
      VK_HOME : if FItems.Count > 0 then FItemIndex:=0;
      VK_END  : 
         begin
            for I:=FItems.Count-1 downto 0 do
            begin
               if Items[I].AddIndex = 0 then
               begin
                  FItemIndex:=I;
                  break;
               end;
            end;
         end;
      VK_DELETE : 
         begin
            if FItemIndex <> -1 then
            begin
               Delete(FItemIndex);
               if FItemIndex >= FItems.Count then
               begin
                  FItemIndex:=FItems.Count-1;
                  for I:=FItemIndex downto 0 do
                  begin
                     if Items[I].AddIndex = 0 then
                     begin
                        FItemIndex:=I;
                        break;
                     end;
                  end;
               end;
            end;
         end;
      VK_RETURN : ;
      VK_UP :
         begin
            if FItemIndex = -1 then
            begin
               FItemIndex:=0;
            end
            else 
            begin
               for I:=FItemIndex-1 downto 0 do
               begin
                  if Items[I].AddIndex = 0 then
                  begin
                     FItemIndex:=I;
                     break;
                  end;
               end;
            end;
         end;
      VK_DOWN :
         begin
            if FItemIndex = -1 then
            begin
               FItemIndex:=0;
            end
            else 
            begin
               for I:=FItemIndex+1 to FItems.Count-1 do
               begin
                  if Items[I].AddIndex = 0 then
                  begin
                     FItemIndex:=I;
                     break;
                  end;
               end;
            end;
         end;
      else
      begin
         inherited;
         Exit;
      end;
   end;
   Recalc;
end;
procedure TTxnLog.CNSysKeyDown(var Message: TWMKeyDown);
begin
   CNKeyDown(Message);
end;
procedure TTxnLog.SetWidths;
var
   I:Integer;
   MVW:Integer;
   MQW:Integer;
   FS:Integer;
begin
   MVW:=20;       
   MQW:=15;
   with Canvas do
   begin
      if ItemHeight <> TextHeight('Wg') then
      begin
         ItemHeight:=TextHeight('Wg');
         for I:=0 to Count-1 do
            with Items[I] do begin QWidth:=0; VWidth:=0; end;
      end;
      FS:=Font.Size;
      Font.Size:=40;
      while TextWidth('8')*(FDigits+FDecimals+1) > Width do Font.Size:=Font.Size-1;
      if (FTotalVisible) and (TitleHeight <> TextHeight('Wg')) then
      begin
         TitleHeight:=TextHeight('Wg');
         TitleFontHeight:=Font.Size;
      end;
      if not FTotalVisible then TitleHeight:=0;
      Font.Size:=FS;
      for I:=0 to Count-1 do
      begin
         with Items[I] do
         begin
            if QWidth = 0 then QWidth:=TextWidth(IntToStr(Quantity));
            if VWidth = 0 then VWidth:=TextWidth(ValueAsString);
            if VWidth > MVW then MVW:=VWidth;
            if QWidth > MQW then MQW:=QWidth;
         end;
      end;
   end;
   if VWidth <> MVW+2 then VWidth:=MVW+2;
   if QWidth <> MQW+2 then QWidth:=MQW+2;
end;   
procedure TTxnLog.OutTextRect(Dest:TRect;Text:String;uFormat:Integer);
begin
   DrawText(Canvas.Handle,PChar(Text),Length(Text),Dest,uFormat);
end;
procedure TTxnLog.Paint;
var
   I:Integer;
   FS:Integer;
   ItemRect:TRect;
   ControlRect:TRect;
   CurrentItem:TTxnItem;
   TotalItem:TTxnItem;
   Dest:TRect;
   TStr:String;
   FC:TColor;
   HighLight:Boolean;
begin
   Canvas.Font:=Font;
   Canvas.Brush.Color:=Color;
   SetWidths;
   Str(FTotal:FDigits:FDecimals,TStr);
   TStr:=Trim(TStr);
   TotalItem:=nil;
   
   with Canvas do
   begin
      Pen.Color:=FLineColor;
      ControlRect:=ClientRect;
      DrawEdge(Handle,ControlRect,EDGE_SUNKEN,BF_TOPLEFT or BF_BOTTOMRIGHT);
      Inc(ControlRect.Top,Height-(TitleHeight+4));
      HighLight:=False;
      for I:=FTopItem to FTopItem+((Height-TitleHeight) div ItemHeight) do
      begin
         ItemRect:=Bounds(2,2+(I-FTopItem)*ItemHeight,(Width-4),((I-FTopItem)+1)*ItemHeight);
         FillRect(ItemRect);
         with ItemRect do 
         begin
            if (FItems <> nil) and (I < FItems.Count) then
            begin
               CurrentItem:=Items[I];
               if CurrentItem <> nil then
               begin
                  if (I = FItemIndex) and (Focused) then
                  begin
                     HighLight:=True;
                  end 
                  else if (I > FItemIndex) and (CurrentItem.AddIndex = 0) then
                  begin
                     HighLight:=False;
                  end;
                  FC:=Font.Color;
                  if HighLight then
                  begin
                     Font.Color:=Color;
                     Brush.Color:=FC;
                  end
                  else
                  begin
                     Brush.Color:=Color;
                  end;
                     
                  Pen.Color:=FLineColor;
                  if FShowHLines then Rectangle(Left,Top,Right,Bottom+1);
                  if CurrentItem.AddIndex <> 0 then
                  begin
                     Pen.Color:=Brush.Color;
                     PolyLine([Point(Left+1,Top),Point(Left+QWidth,Top)]);
                     if CurrentItem.Value = 0 then
                     begin
                        PolyLine([Point(Left+QWidth+1,Top),Point(Right-VWidth,Top)]);
                        PolyLine([Point(Right-VWidth,Top),Point(Right-1,Top)]);
                     end;
                     Pen.Color:=Font.Color;   
                     if (I = FItems.Count-1) or (Items[I+1].AddIndex = 0) then
                     begin
                        PolyLine([Point(Left+QWidth div 2,Top),Point(Left+QWidth div 2,Top+ItemHeight div 2),Point(Left+QWidth,Top+ItemHeight div 2)]);
                     end
                     else
                     begin
                        PolyLine([Point(Left+QWidth div 2,Top),Point(Left+QWidth div 2,Top+ItemHeight)]);
                        PolyLine([Point(Left+QWidth div 2,Top+ItemHeight div 2),Point(Left+QWidth,Top+ItemHeight div 2)]);
                     end;
                     Pen.Color:=FLineColor;
                  end                      
                  else
                  begin
                     Dest:=Bounds(Left+2,Top+1,QWidth-1,ItemHeight-1);
                     OutTextRect(Dest,IntToStr(CurrentItem.Quantity),DT_CENTER);
                  end;
                  Dest:=Bounds(Left+QWidth+3,Top+1,((ItemRect.Right-ItemRect.Left)-(VWidth+QWidth))-4,ItemHeight-1);
                  OutTextRect(Dest,CurrentItem.Description,0);
                  if CurrentItem.Value <> 0 then
                  begin
                     Dest:=Bounds((Left+Right)-(VWidth+2),Top+1,VWidth-1,ItemHeight-1);
                     OutTextRect(Dest,CurrentItem.ValueAsString,DT_RIGHT);
                  end;
                  Font.Color:=FC;
               end;  
            end 
            else
            begin
               HighLight:=False;
               Brush.Color:=Color;
               Pen.Color:=FLineColor;
               if FShowHLines then Rectangle(Left,Top,Right,Bottom+1);
               if (FSubLogVisible) and  (FSubLog <> nil) then 
               begin    
                  if (FItems = nil) then
                  begin
                     if I < FSubLog.Count then
                        CurrentItem:=SubLog[I]
                     else
                        CurrentItem:=nil;
                  end
                  else
                  begin
                     if (I-FItems.Count) < FSubLog.Count then
                     begin
                        CurrentItem:=SubLog[I-FItems.Count]
                     end
                     else
                     begin
                        if ((I-FItems.Count) = FSubLog.Count) and (FSubLog.Count <> 0) then
                        begin
                           TotalItem:=TTxnItem.Create(Self,1,0,0,FSubLogTotal,0,'Sub Total','Info','','');
                           CurrentItem:=TotalItem;
                        end 
                        else
                           CurrentItem:=nil;
                     end;
                  end;
                  if CurrentItem <> nil then
                  begin
                     FC:=Font.Color;
                     Font.Color:=FSubLogColor;
                     if CurrentItem.AddIndex <> 0 then
                     begin
                        Pen.Color:=Brush.Color;
                        PolyLine([Point(Left+1,Top),Point(Left+QWidth,Top)]);
                        if CurrentItem.Value = 0 then
                        begin
                           PolyLine([Point(Left+QWidth+1,Top),Point(Right-VWidth,Top)]);
                           PolyLine([Point(Right-VWidth,Top),Point(Right-1,Top)]);
                        end;
                        Pen.Color:=Font.Color;       
                        if TotalItem <> nil then
                        begin
                           PolyLine([Point(Left+QWidth div 2,Top),Point(Left+QWidth div 2,Top+ItemHeight div 2),Point(Left+QWidth,Top+ItemHeight div 2)]);
                        end
                        else
                        begin
                           PolyLine([Point(Left+QWidth div 2,Top),Point(Left+QWidth div 2,Top+ItemHeight)]);
                           PolyLine([Point(Left+QWidth div 2,Top+ItemHeight div 2),Point(Left+QWidth,Top+ItemHeight div 2)]);
                        end;
                        Pen.Color:=FLineColor;
                     end                      
                     else
                     begin
                        Dest:=Bounds(Left+2,Top+1,QWidth-1,ItemHeight-1);
                        OutTextRect(Dest,IntToStr(CurrentItem.Quantity),DT_CENTER);
                     end;
                     Dest:=Bounds(Left+QWidth+3,Top+1,((ItemRect.Right-ItemRect.Left)-(VWidth+QWidth))-4,ItemHeight-1);
                     if TotalItem <> nil then 
                        OutTextRect(Dest,CurrentItem.Description,DT_RIGHT)
                     else
                        OutTextRect(Dest,CurrentItem.Description,0);
                     if CurrentItem.Value <> 0 then
                     begin
                        Dest:=Bounds((Left+Right)-(VWidth+2),Top+1,VWidth-1,ItemHeight-1);
                        OutTextRect(Dest,CurrentItem.ValueAsString,DT_RIGHT);
                     end;
                     Font.Color:=FC;  
                     if TotalItem <> nil then 
                     begin
                        TotalItem.Free;
                        TotalItem:=nil;
                     end;
                  end;
               end;
            end;
         end;
         if FShowVLines then
         begin
            Pen.Color:=FLineColor;
            PolyLine([Point(QWidth+2,2),Point(QWidth+2,ControlRect.Top)]);
            PolyLine([Point(ItemRect.Right-VWidth,2),Point(ItemRect.Right-VWidth,ControlRect.Top)]);
         end;                          
      end;                          
      if FTotalVisible then
      begin
         Brush.Color:=Self.Color;
         DrawEdge(Handle,ControlRect,EDGE_SUNKEN,BF_TOPLEFT or BF_BOTTOMRIGHT or BF_ADJUST);
         FillRect(ControlRect);
         FS:=Font.Size;
         Font.Size:=TitleFontHeight;
         OutTextRect(ControlRect,TStr,DT_RIGHT);
         Font.Size:=FS;
      end;
   end;                    
end;
procedure TTxnLog.SetInteger(Index:Integer;Value:Integer);
var
   Item:PInteger;
begin
   case Index of  
      0 : Item:=@FDigits;
      1 : Item:=@FDecimals;
      2 : Item:=@FTopItem;
      3 : Item:=@FItemIndex;
      else Exit;
   end;
   if Item^ <> Value then
   begin
      Item^:=Value;
      ReCalc;
   end;
end;
procedure TTxnLog.SetBoolean(Index:Integer;Value:Boolean);
type
   PBoolean = ^Boolean;
var
   Item:PBoolean;
begin
   case Index of  
      0 : Item:=@FSubLogVisible;
      1 : Item:=@FShowVLines;
      2 : Item:=@FShowHLines;
      3 : Item:=@FTotalVisible;
      else Exit;
   end;
   if Item^ <> Value then
   begin
      Item^:=Value;
      ReCalc;
   end;
end;
procedure TTxnLog.SetColor(Index:Integer;Value:TColor);
type
   PColor = ^TColor;
var
   Item:PColor;
begin
   case Index of  
      0 : Item:=@FSubLogColor;
      1 : Item:=@FLineColor;
      else Exit;
   end;
   if Item^ <> Value then
   begin
      Item^:=Value;
      ReCalc;
   end;
end;
function TTxnLog.GetSubLog(Index:Integer):TTxnItem;   
begin
   if Index < FSubLog.Count then
      Result:=TTxnItem(FSubLog.Objects[Index])
   else
      Result:=nil
end;   
function TTxnLog.GetItems(Index:Integer):TTxnItem;
begin
   if Index < FItems.Count then
      Result:=TTxnItem(FItems.Objects[Index])
   else if (FSubLogVisible) and (Index < (FItems.Count+FSubLog.Count)) then
      Result:=TTxnItem(FSubLog.Objects[Index-FItems.Count])
   else
      Result:=nil
end;   
function TTxnLog.AddToSubLog(Index,Quantity,PLU:Integer;Value,Price:Currency;Description,Additional,ProgID,DomInfo:String):Integer;
var
   TxnItem:TTxnItem;
begin
   if FSubLog.Count > 0 then
      TxnItem:=TTxnItem.Create(Self,1,Quantity,PLU,Value,Price,Description,Additional,ProgID,DomInfo)
   else
      TxnItem:=TTxnItem.Create(Self,Index,Quantity,PLU,Value,Price,Description,Additional,ProgID,DomInfo);
   Result:=FSubLog.AddObject(Description,TxnItem);
   ReCalc;
end;
function TTxnLog.Add(Index,Quantity,PLU:Integer;Value,Price:Currency;Description,Additional,ProgID,DomInfo:String):Integer;
var
   TxnItem:TTxnItem;
begin
   if Index = -1 then
   begin
      Result:=FItems.Count-1;
      if ZeroValues then
         ZeroValues:=False
      else
         ZeroValues:=True;
   end
   else
   begin
      TxnItem:=TTxnItem.Create(Self,Index,Quantity,PLU,Value,Price,Description,Additional,ProgID,DomInfo);
      Result:=FItems.AddObject(Description,TxnItem);
   end;
   ReCalc;
end;
procedure TTxnLog.Delete(Index:Integer);
begin
   if Index < FItems.Count then
   begin
      if Items[Index] <> nil then Items[Index].Free;
      FItems.Delete(Index);
      while (Index < FItems.Count) and (Items[Index].AddIndex <> 0) do
      begin
         if Items[Index] <> nil then Items[Index].Free;
         FItems.Delete(Index);
      end;
      ReCalc;
   end;
end;
procedure TTxnLog.ClearSubLog;
var
  I:Integer;
begin
   for I:=0 to FSubLog.Count-1 do if FSubLog.Objects[I] <> nil then TTxnItem(FSubLog.Objects[I]).Free;
   FSubLog.Clear;
   ReCalc;
end;
procedure TTxnLog.Clear;
var
  I:Integer;
begin
   for I:=0 to FItems.Count-1 do if FItems.Objects[I] <> nil then TTxnItem(FItems.Objects[I]).Free;
   FItems.Clear;
   ZeroValues:=False;
   ReCalc;             
end;
function TTxnLog.GetCount:Integer;
begin
   Result:=FItems.Count;
   if FSubLogVisible then Result:=Result+FSublog.Count;
end;
procedure TTxnLog.ReCalc;
var
   I:Integer;
   CRect:TRect;
begin
   try
      if Name = 'DontReCalc' then Exit;
      FTopItem:=(Count+1)-((Height-TitleHeight) div ItemHeight);
      if FTopItem < 0 then FTopItem:=0;
      FTotal:=0;
      FSubLogTotal:=0;
      for I:=0 to FItems.Count-1 do
      begin
         FTotal:=FTotal+Items[I].Value;
         if (not Focused) and (Items[I].AddIndex = 0) then
            FItemIndex:=I; // highlight last line
      end;
      if FSubLogVisible then
      begin
         for I:=0 to FSubLog.Count-1 do
         begin
            FSubLogTotal:=FSubLogTotal+SubLog[I].Value;
         end;
         FTotal:=FTotal+FSubLogTotal;
      end;
      CRect:=ClientRect;
      InvalidateRect(Handle,@CRect,False);
   except
      on E : Exception do RaiseGUIDException('{84B6730C-5220-4D4E-B81A-D0D23B006B8E}', E);
   end;
end;
    
procedure Register;
begin
  RegisterComponents('CorvusVCL', [TTxnLog]);
end;

end.
 