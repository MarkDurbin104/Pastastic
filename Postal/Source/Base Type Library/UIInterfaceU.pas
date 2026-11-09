{

   <Synopsis>
   <Unit>          Automation Unit
   <Copyright(c)>  Postal Solutions Limited 1996..1999
   <Author>        MJD
   <Description>
   <Modifications> 20/7/99 - MJD
                              Original Release

                   25/7/99 - DDB & MD
                              Commenting Code.

}
unit UIInterfaceU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComObj,GPCSBase_TLB,KGButton,StdCtrls,Compress,extCtrls,crc32,UIStatesU;

const
  PickError    = -1;
  PickContinue = -2;
  PickCancel   = -3;
  PickUpLine   = -4;
  PickDownLine = -5;
  PickUpPage   = -6;
  PickDownPage = -7;
  PickMoveTo   = -8;

  Key_FuncMin    = VK_F1 ;
  Key_FuncMax    = VK_F24;
  
  Key_Function1  = VK_F1 ;
  Key_Function2  = VK_F2 ;
  Key_Function3  = VK_F3 ;
  Key_Function4  = VK_F4 ;
  Key_Function5  = VK_F5 ;
  Key_Function6  = VK_F6 ;
  Key_Function7  = VK_F7 ;
  Key_Function8  = VK_F8 ;
  Key_Function9  = VK_F9 ;
  Key_Function10 = VK_F10;
  Key_Function11 = VK_F11;
  Key_Function12 = VK_F12;
  Key_Function13 = VK_F13;
  Key_Function14 = VK_F14;
  Key_Function15 = VK_F15;
  Key_Function16 = VK_F16;
  Key_Function17 = VK_F17;
  Key_Function18 = VK_F18;
  Key_Function19 = VK_F19;
  Key_Function20 = VK_F20;
  Key_Function21 = VK_F21;
  Key_Function22 = VK_F22;
  Key_Function23 = VK_F23;
  Key_Function24 = VK_F24;
  
  Key_Cancel     = VK_ESCAPE;
  Key_BackSpace  = 8;
  Key_ControlMax = 31;
  Key_Select     = VK_RETURN;
  Key_Up         = VK_UP;
  Key_Down       = VK_DOWN;
  Key_PageUp     = VK_PRIOR;
  Key_PageDown   = VK_NEXT;
  Key_Delete     = VK_DELETE;
  Key_Home       = VK_HOME;
  Key_Help       = Key_Function11;
  Key_Info       = Key_Function12;
  
type
  TIFont = class;
  TIButton = class;
  TIBitmap = class;
  TILabel = class;
  TIUIStyle = class;

  TFormChange   = procedure(Sender:TIUIStyle) of object;
  TAddButton    = function(Sender:TIUIStyle):TKGButton of object;
  TLabelChange  = procedure(Sender:TILabel)   of object;
  TButtonClick  = procedure(Sender:TKGButton)  of object;
  TGetNewImage  = function(Sender:TIUIStyle):TImage of object;

  TIFont = class(TAutoObject,IGPCSFont)
  private
    FIdent:Integer;
    FFont:TFont;
  protected
    procedure Initialize; override;
    destructor Destroy; override;
    function Get_Color:Integer; safecall;
    procedure Set_Color(Value:Integer); safecall;
    function Get_Height:Integer; safecall;
    procedure Set_Height(Value:Integer); safecall;
    function Get_Name:WideString; safecall;
    procedure Set_Name(const Value:WideString); safecall;
    function Get_Size:Integer; safecall;
    procedure Set_Size(Value:Integer); safecall;
    function Get_Style:FontStyle; safecall;
    procedure Set_Style(Value:FontStyle); safecall;
    function Get_Ident:Integer; safecall;
    procedure Set_Ident(Value:Integer); safecall;
  public
    procedure SetFromFont(Font:TFont);
    function AsFont:TFont;
    property Color: Integer read Get_Color write Set_Color;
    property Height: Integer read Get_Height write Set_Height;
    property Name: WideString read Get_Name write Set_Name;
    property Size: Integer read Get_Size write Set_Size;
    property Style: FontStyle read Get_Style write Set_Style;
    property Ident: Integer read Get_Ident write Set_Ident;
  end;
  TIBitmap = class(TAutoObject,IBitmap)
  private
    FImage:TImage;
    FBitMap:TBitMap;
    FData:OleVariant;
    FIdent:Integer;
    FName:String;
    FLeft:Integer;
    FTop:Integer;
    FVisible:Boolean;
    FTransparent:Boolean;
    FCRC:Integer;
  protected
    Parent:TIUIStyle;
    procedure Initialize; override;
    destructor Destroy; override;
    function Get_Data:OleVariant; safecall;
    procedure Set_Data(Value:OleVariant); safecall;
    function Get_Width:Integer; safecall;
    procedure Set_Width(Value:Integer); safecall;
    function Get_Height:Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function Get_Ident:Integer; safecall;
    procedure Set_Ident(Value:Integer); safecall;
    function Get_Name:WideString; safecall;
    procedure Set_Name(const Value:WideString); safecall;
    function Get_Left: Integer; safecall;
    procedure Set_Left(Value: Integer); safecall;
    function Get_Top: Integer; safecall;
    procedure Set_Top(Value: Integer); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Transparent: WordBool; safecall;
    procedure Set_Transparent(Value: WordBool); safecall;
  public         
    procedure SetFromBitMap(BitMap:TBitMap);
    function AsBitMap:TBitMap;
    property Data: OleVariant read Get_Data write Set_Data;
    property Top: Integer read Get_Top write Set_Top;
    property Left: Integer read Get_Left write Set_Left;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property Ident: Integer read Get_Ident write Set_Ident;
    property Name: WideString read Get_Name write Set_Name;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Transparent: WordBool read Get_Transparent write Set_Transparent;
    property CRC:Integer read FCRC;
  end;           
  TILabel = class(TAutoObject,IGPCSLabel)
  private
    FLabel:TLabel;
    FFontIdent:Integer;
    FName:String;
  protected
    Parent:TIUIStyle;
    procedure Initialize; override;
    function Get_Alignment:TextAlign; safecall;
    procedure Set_Alignment(Value:TextAlign); safecall;
    function Get_AutoSize:WordBool; safecall;
    procedure Set_AutoSize(Value:WordBool); safecall;
    function Get_Transparent:WordBool; safecall;
    procedure Set_Transparent(Value:WordBool); safecall;
    function Get_WordWrap:WordBool; safecall;
    procedure Set_WordWrap(Value:WordBool); safecall;
    function Get_Visible:WordBool; safecall;
    procedure Set_Visible(Value:WordBool); safecall;
    function Get_Top:Integer; safecall;
    procedure Set_Top(Value:Integer); safecall;
    function Get_Left:Integer; safecall;
    procedure Set_Left(Value:Integer); safecall;
    function Get_Width:Integer; safecall;
    procedure Set_Width(Value:Integer); safecall;
    function Get_Height:Integer; safecall;
    procedure Set_Height(Value:Integer); safecall;
    function Get_FontIdent:Integer; safecall;
    procedure Set_FontIdent(Value:Integer); safecall;
    function Get_Caption:WideString; safecall;
    procedure Set_Caption(const Value:WideString); safecall;
    function Get_Name:WideString; safecall;
    procedure Set_Name(const Value:WideString); safecall;
    function Get_Color:Integer; safecall;
    procedure Set_Color(Value:Integer); safecall;
  public
    property Alignment: TextAlign read Get_Alignment write Set_Alignment;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property Transparent: WordBool read Get_Transparent write Set_Transparent;
    property WordWrap: WordBool read Get_WordWrap write Set_WordWrap;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Top: Integer read Get_Top write Set_Top;
    property Left: Integer read Get_Left write Set_Left;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property FontIdent: Integer read Get_FontIdent write Set_FontIdent;
    property Caption:WideString read Get_Caption write Set_Caption;
    property AsLabel:TLabel read FLabel write FLabel;
    property Name: WideString read Get_Name write Set_Name;
  end;
  TIButton = class(TAutoObject,IButton)
  private
    FLeft:Integer;
    FTop:Integer;
    FEnabled:WordBool;
    FDown:WordBool;
    FToggle:WordBool;
    FFontIdent:Integer;
    FBitMapUpIdent:Integer;
    FBitMapDownIdent:Integer;
    FGlyphIdent:Integer;
    FText:WideString;
    FPrice:WideString;
    FKey:WideString;
    FKGButton:TKGButton;
    FName:String;
  protected
    Parent:TIUIStyle;
    procedure Initialize; override;
    destructor Destroy; override;
    function Get_Left:Integer; safecall;
    procedure Set_Left(Value:Integer); safecall;
    function Get_Top:Integer; safecall;
    procedure Set_Top(Value:Integer); safecall;
    function Get_Enabled:WordBool; safecall;
    procedure Set_Enabled(Value:WordBool); safecall;
    function Get_Down:WordBool; safecall;
    procedure Set_Down(Value:WordBool); safecall;
    function Get_Toggle:WordBool; safecall;
    procedure Set_Toggle(Value:WordBool); safecall;
    function Get_FontIdent:Integer; safecall;
    procedure Set_FontIdent(Value:Integer); safecall;
    function Get_BitMapUpIdent:Integer; safecall;
    procedure Set_BitMapUpIdent(Value:Integer); safecall;
    function Get_BitMapDownIdent:Integer; safecall;
    procedure Set_BitMapDownIdent(Value:Integer); safecall;
    function Get_GlyphIdent:Integer; safecall;
    procedure Set_GlyphIdent(Value:Integer); safecall;
    function Get_Text:WideString; safecall;
    procedure Set_Text(const Value:WideString); safecall;
    function Get_Price:WideString; safecall;
    procedure Set_Price(const Value:WideString); safecall;
    function Get_Key:WideString; safecall;
    procedure Set_Key(const Value:WideString); safecall;
    procedure Set_KGButton(AButton:TKGButton);
    function Get_Name:WideString; safecall;
    procedure Set_Name(const Value:WideString); safecall;
    procedure ButtonClick(Sender:TObject);
  public
    property Left:Integer read Get_Left write Set_Left;
    property Top:Integer read Get_Top write Set_Top;
    property Enabled:WordBool read Get_Enabled write Set_Enabled;
    property Down:WordBool read Get_Down write Set_Down;
    property Toggle:WordBool read Get_Toggle write Set_Toggle;
    property FontIdent:Integer read Get_FontIdent write Set_FontIdent;
    property BitMapUpIdent:Integer read Get_BitMapUpIdent write Set_BitMapUpIdent;
    property BitMapDownIdent:Integer read Get_BitMapDownIdent write Set_BitMapDownIdent;
    property GlyphIdent:Integer read Get_GlyphIdent write Set_GlyphIdent;
    property Text:WideString read Get_Text write Set_Text;
    property Price:WideString read Get_Price write Set_Price;
    property Key:WideString read Get_Key write Set_Key;
    property Button:TKGButton read FKGButton write Set_KGButton;
    property Name: WideString read Get_Name write Set_Name;
  end;
  TIPickItem = class(TAutoObject,IPickItem)
  private
    FBitMap:TIBitMap;
    FPickItem:TPickItem;
  protected
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Picture: IBitMap; safecall;
    procedure Set_Picture(const Value: IBitMap); safecall;
    function Get_Selected: WordBool; safecall;
    procedure Set_Selected(Value: WordBool); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function Get_Price: Currency; safecall;
    procedure Set_Price(Value: Currency); safecall;
  public
    procedure Initialize; override;
    destructor Destroy; override;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Picture: IBitMap read Get_Picture write Set_Picture;
    property Selected: WordBool read Get_Selected write Set_Selected;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Price: Currency read Get_Price write Set_Price;
  end;

  TIPickItemList = class(TAutoObject,IPickItemList)
  private
    FBitMap:TIBitMap;
    FPickList:TPickList;
  protected
    function Get_Title: WideString; safecall;
    procedure Set_Title(const Value: WideString); safecall;
    function Get_Prompt: WideString; safecall;
    procedure Set_Prompt(const Value: WideString); safecall;
    function Get_Hint: WideString; safecall;
    procedure Set_Hint(const Value: WideString); safecall;
    function Get_Picture: IBitMap; safecall;
    procedure Set_Picture(const Value: IBitMap); safecall;
    function Get_Items(Index: Integer): IPickItem; safecall;
    function Get_Count: Integer; safecall;
  public
    procedure Initialize; override;
    destructor Destroy; override;
    procedure LoadFromInterface(PickItemList:IPickItemList);
    property PickList:TPickList read FPickList;
    function Add(const PickItem: IPickItem): Integer; safecall;
    procedure Delete(Index: Integer); safecall;
    property Title  : WideString read Get_Title write Set_Title;
    property Prompt : WideString read Get_Prompt write Set_Prompt;
    property Hint   : WideString read Get_Hint write Set_Hint;
    property Picture: IBitMap read Get_Picture write Set_Picture;
    property Items[Index: Integer]: IPickItem read Get_Items;
    property Count: Integer read Get_Count;
  end;
  
  TIUIStyle = class(TAutoObject,IUIStyle)
  private
    FWidth:Integer;
    FHeight:Integer;
    FBGColor:Integer;
    FDefaultFontIdent:Integer;
    FButtons:TList;
    FBitMaps:TList;
    FFonts:TList;
    FTextLabels:TList;
    FRightAnchored:WordBool;
    FFormChange  :TFormChange  ;
    FAddButton   :TAddButton   ;
    FLabelChange :TLabelChange ;
    FButtonClick :TButtonClick;
    FGetNewImage :TGetNewImage;
    FVisible:WordBool;
    function GetUniqueId:Integer;
  protected
    procedure Initialize; override;
    destructor Destroy; override;
    function Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    function Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function Get_BGColor: Integer; safecall;
    procedure Set_BGColor(Value: Integer); safecall;
    function Get_DefaultFontIdent: Integer; safecall;
    procedure Set_DefaultFontIdent(Value: Integer); safecall;
    function Get_ButtonCount: Integer; safecall;
    function Get_BitMapCount: Integer; safecall;
    function Get_FontCount: Integer; safecall;
    function Get_TextLabelCount: Integer; safecall;
    function Get_Button(Index: Integer): IButton; safecall;
    function Get_BitMap(Index: Integer): IBitMap; safecall;
    function Get_Font(Index: Integer): IGPCSFont; safecall;
    function Get_TextLabel(Index: Integer): IGPCSLabel; safecall;
    function AddButton: Integer; safecall;
    function AddFont: Integer; safecall;
    function AddTextLabel:Integer; safecall;
    function Get_RightAnchored: WordBool; safecall;
    procedure Set_RightAnchored(Value: WordBool); safecall;
    function Get_TButton(Index: Integer): TIButton;
    function Get_TBitMap(Index: Integer): TIBitMap;
    function Get_TFont(Index: Integer): TIFont;
    function Get_TTextLabel(Index: Integer): TILabel;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
  public
    function AddBitMap: Integer; safecall;
    function IndexOfBitMap(Ident:Integer):Integer;
    function IndexOfFont(Ident:Integer):Integer;
    property Width:Integer read Get_Width write Set_Width;
    property Height:Integer read Get_Height write Set_Height;
    property BGColor:Integer read Get_BGColor write Set_BGColor;
    property DefaultFontIdent:Integer read Get_DefaultFontIdent write Set_DefaultFontIdent;
    property ButtonCount:Integer read Get_ButtonCount;
    property BitMapCount:Integer read Get_BitMapCount;
    property FontCount:Integer read Get_FontCount;
    property TextLabelCount:Integer read Get_TextLabelCount;
    property Button[Index:Integer]:IButton read Get_Button;
    property BitMap[Index:Integer]:IBitMap read Get_BitMap;
    property Font[Index:Integer]:IGPCSFont read Get_Font;
    property TextLabel[Index:Integer]:IGPCSLabel read Get_TextLabel;
    property RightAnchored:WordBool read Get_RightAnchored write Set_RightAnchored;
    property OnFormChange  :TFormChange   read FFormChange   write FFormChange;
    property OnAddButton   :TAddButton    read FAddButton    write FAddButton;
    property OnLabelChange :TLabelChange  read FLabelChange  write FLabelChange ;
    property OnButtonClick :TButtonClick  read FButtonClick  write FButtonClick ;
    property GetNewImage   :TGetNewImage  read FGetNewImage  write FGetNewImage ;
    property TButton[Index:Integer]:TIButton read Get_TButton;
    property TBitMap[Index:Integer]:TIBitMap read Get_TBitMap;
    property TFont[Index:Integer]:TIFont read Get_TFont;
    property TTextLabel[Index:Integer]:TILabel read Get_TTextLabel;
    property Visible: WordBool read Get_Visible write Set_Visible;
 end;
 
procedure CreateInterfaceFactories;

implementation

uses ComServ2;

{TIFont}

{===============================================================================

<Sysnopsis>       Initialize the TIFont object

<Description>     Create Object of class TFont and Assign to variable  FFont,
                  assign values to properties Color, Name, Size, Style.


<Post state>      FFont has been assinged and initialized.
________________________________________________________________________________}
procedure TIFont.Initialize;
begin
   inherited Initialize;
   _AddRef;
   FFont:=TFont.Create;
   FFont.Color:=clBlack;
   FFont.Name:='Arial';
   FFont.Size:=10;
   FFont.Style:=[];
end;
{===============================================================================

<Sysnopsis>       Unassign FFont.

<Description>     Executed when 'free' is called.
                  Unassign memory allocated for FFont.

<Post state>      FFont freed.

________________________________________________________________________________}
destructor TIFont.Destroy;
begin
   if FFont <> nil then FFont.Free;
   FFont:=nil;
   inherited Destroy;
end;
{===============================================================================

<Sysnopsis>       Return  TFont object information.

<Description>     Return the private variable FFont.

<Result>          Variable FFont.

________________________________________________________________________________}
function TIFont.AsFont:TFont;
begin
   Result:=FFont;
end;
{===============================================================================

<Sysnopsis>       Assign font properties.

<Description>     Set properties of FFont to match parameter Font.

<Font>            Variable to assign from.

<Post state>      FFont assigned.
________________________________________________________________________________}
procedure TIFont.SetFromFont(Font:TFont);
begin
   FFont.Assign(Font);
end;
{===============================================================================

<Sysnopsis>       Return font color.

<Description>     Return the color property of FFont.

<Result>          Color property of FFont.

________________________________________________________________________________}
function TIFont.Get_Color:Integer;
begin
   Result:=FFont.Color;
end;
{===============================================================================

<Sysnopsis>       Set color property.

<Description>     Set color property of FFont to Value .

<Value>           Variable to assign color property from.

<Post state>      Color property of FFont assigned.
________________________________________________________________________________}

procedure TIFont.Set_Color(Value:Integer);
begin
   FFont.Color:=Value;
end;
{===============================================================================

<Sysnopsis>       Return font height.

<Description>     Return the Height property of FFont.

<Result>          Height property of FFont.

________________________________________________________________________________}

function TIFont.Get_Height:Integer;
begin
   Result:=FFont.Height;
end;
{===============================================================================

<Sysnopsis>       Set height property.

<Description>     Set height property of FFont to Value .

<Value>           Variable to assign height property from.

<Post state>      Height property of FFont assigned.

________________________________________________________________________________}

procedure TIFont.Set_Height(Value:Integer);
begin
   FFont.Height:=Value;
end;
{===============================================================================

<Sysnopsis>       Return font Name.

<Description>     Return the Name property of FFont.

<Result>          Name property of FFont.

________________________________________________________________________________}

function TIFont.Get_Name:WideString;
begin
   Result:=FFont.Name;
end;
{===============================================================================

<Sysnopsis>       Set Name property.

<Description>     Set Name property of FFont to Value .

<Value>           Variable to assign Name property from.

<Post state>      Name property of FFont assigned.

________________________________________________________________________________}

procedure TIFont.Set_Name(const Value:WideString);
begin
   FFont.Name:=Value;
end;
{===============================================================================

<Sysnopsis>       Return font Size.

<Description>     Return the Size property of FFont.

<Result>          Size property of FFont.

________________________________________________________________________________}

function TIFont.Get_Size:Integer;
begin
   Result:=FFont.Size;
end;

{===============================================================================

<Sysnopsis>       Set Size property.

<Description>     Set Size property of FFont to Value .

<Value>           Variable to assign Size property from.

<Post state>      Name property of FFont assigned.

________________________________________________________________________________}

procedure TIFont.Set_Size(Value:Integer);
begin
   FFont.Size:=Value;
end;
function TIFont.Get_Style:FontStyle;
begin
   if FFont.Style = [fsBold] then
      Result:=ifsBold
   else if FFont.Style = [fsItalic] then
      Result:=ifsItalic
   else if FFont.Style = [fsBold,fsItalic] then
      Result:=ifsBoldItalic
   else
      Result:=ifsNormal;
end;
{===============================================================================

<Sysnopsis>       Set Style property.

<Description>     Set Style property of FFont to Value .

<Value>           Variable to assign Style property from.

<Post state>      Style property of FFont assigned.

________________________________________________________________________________}

procedure TIFont.Set_Style(Value:FontStyle);
begin
   case Value of
      ifsBold       : FFont.Style:=[fsBold];
      ifsItalic     : FFont.Style:=[fsItalic];
      ifsBoldItalic : FFont.Style:=[fsBold,fsItalic];
      ifsNormal     : FFont.Style:=[];
   end;
end;
{===============================================================================

<Sysnopsis>       Return font Ident.

<Description>     Return the Ident property of FFont.

<Result>          Ident property of FFont.

_______________________________________________________________________________}

function TIFont.Get_Ident:Integer;
begin
   Result:=FIdent;
end;
{===============================================================================

<Sysnopsis>       Set Ident property.

<Description>     Set Ident property of FFont to Value .

<Value>           Variable to assign Ident property from.

<Post state>      Ident property of FFont assigned.

________________________________________________________________________________}

procedure TIFont.Set_Ident(Value:Integer);
begin
   FIdent:=Value;
end;

{TILabel}

{===============================================================================

<Sysnopsis>       Initialize the object

<Description>     Create Object of class TLable and Assign to variable  FLable,
                  assign values to properties Alignment, AutoSize, Transparent,
                  WordWrap, Visible, Top, Left, Width, Height.


<Post state>      FLablel has been assinged and initialized.
________________________________________________________________________________}

procedure TILabel.Initialize;
begin
   inherited Initialize;
   _AddRef;
   FLabel:=TLabel.Create(nil);
   FLabel.Alignment   :=taLeftJustify;
   FLabel.AutoSize    :=False;
   FLabel.Transparent :=False;
   FLabel.WordWrap    :=False;
   FLabel.Visible     :=True;
   FLabel.Top         :=0;
   FLabel.Left        :=0;
   FLabel.Width       :=100;
   FLabel.Height      :=10;
end;
function TILabel.Get_Name:WideString;
begin
    Result:=FName;
end;
procedure TILabel.Set_Name(const Value:WideString);
begin
    FName:=Value;
    if FLabel <> nil then
       FLabel.Name:=Value;
end;
function TILabel.Get_Color:Integer;
begin
   Result:=FLabel.Color;
end;
procedure TILabel.Set_Color(Value:Integer);
begin
   FLabel.Color:=Value;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return alignment property.

<Description>     Return alignment property of FLabel.

<Result>          Alignment property of FLabel.

________________________________________________________________________________}

function TILabel.Get_Alignment:TextAlign;
begin
   case FLabel.Alignment of
      taLeftJustify  : Result:=aLeft;
      taRightJustify : Result:=aRight;
      taCenter       : Result:=aCentre;
   end;
end;
{===============================================================================

<Sysnopsis>       Set Alignment property.

<Description>     Set Alignment property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign Alignment property from.

<Post state>      Alignment property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_Alignment(Value:TextAlign);
begin
   case Value of
      aLeft   : FLabel.Alignment:=taLeftJustify ;
      aRight  : FLabel.Alignment:=taRightJustify;
      aCentre : FLabel.Alignment:=taCenter      ;
   end;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return Autosize property.

<Description>     Return Autosize property of FLabel.

<Result>          Autosize property of FLabel.
________________________________________________________________________________}

function TILabel.Get_AutoSize:WordBool;
begin
   Result:=FLabel.AutoSize;
end;
{===============================================================================

<Sysnopsis>       Set Autosize property.

<Description>     Set Autosize property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign AutoSize property from.

<Post state>      AutoSize property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_AutoSize(Value:WordBool);
begin
   FLabel.AutoSize:=Value;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return Transparent property.

<Description>     Return Transparent property of FLabel.

<Result>          Transparent property of FLabel.
________________________________________________________________________________}

function TILabel.Get_Transparent:WordBool;
begin
   Result:=FLabel.Transparent;
end;
{===============================================================================

<Sysnopsis>       Set Transparent property.

<Description>     Set Transparent property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign Transparent property from.

<Post state>      Transparent property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_Transparent(Value:WordBool);
begin
   FLabel.Transparent:=Value;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return WordWrap property.

<Description>     Return WordWrap property of FLabel.

<Result>          WordWrap property of FLabel.
________________________________________________________________________________}

function TILabel.Get_WordWrap:WordBool;
begin
   Result:=FLabel.WordWrap;
end;
{===============================================================================

<Sysnopsis>       Set WordWrap property.

<Description>     Set WordWrap property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign WordWrap property from.

<Post state>      WordWrap property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_WordWrap(Value:WordBool);
begin
   FLabel.WordWrap:=Value;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return Visible property.

<Description>     Return Visible property of FLabel.

<Result>          Visible property of FLabel.
________________________________________________________________________________}

function TILabel.Get_Visible:WordBool;
begin
   Result:=FLabel.Visible;
end;
{===============================================================================

<Sysnopsis>       Set Visible  property.

<Description>     Set Visible property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign Visible property from.

<Post state>      Visible property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_Visible(Value:WordBool);
begin
   FLabel.Visible:=Value;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return Visible property.

<Description>     Return Visible property of FLabel.

<Result>          Visible property of FLabel.
________________________________________________________________________________}

function TILabel.Get_Top:Integer;
begin
   Result:=FLabel.Top;
end;
{===============================================================================

<Sysnopsis>       Set Top property.

<Description>     Set Top property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign Top property from.

<Post state>      Top property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_Top(Value:Integer);
begin
   FLabel.Top:=Value;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return Left property.

<Description>     Return Left property of FLabel.

<Result>          Left property of FLabel.
________________________________________________________________________________}

function TILabel.Get_Left:Integer;
begin
   Result:=FLabel.Left;
end;
{===============================================================================

<Sysnopsis>       Set Left property.

<Description>     Set Left property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign Left property from.

<Post state>      Left property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_Left(Value:Integer);
begin
   FLabel.Left:=Value;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return Width property.

<Description>     Return Width property of FLabel.

<Result>          Width property of FLabel.
________________________________________________________________________________}

function TILabel.Get_Width:Integer;
begin
   Result:=FLabel.Width;
end;
{===============================================================================

<Sysnopsis>       Set Width property.

<Description>     Set Width property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign Width property from.

<Post state>      Width property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_Width(Value:Integer);
begin
   FLabel.Width:=Value;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return Height property.

<Description>     Return Height property of FLabel.

<Result>          Height property of FLabel.
________________________________________________________________________________}

function TILabel.Get_Height:Integer;
begin
   Result:=FLabel.Height;
end;
{===============================================================================

<Sysnopsis>       Set Height property.

<Description>     Set Height property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign Height property from.

<Post state>      Height property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_Height(Value:Integer);
begin
   FLabel.Height:=Value;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return FontIdent property.

<Description>     Return FontIdent property of FLabel.

<Result>          FontIdent property of FLabel.
________________________________________________________________________________}

function TILabel.Get_FontIdent:Integer;
begin
   Result:=FFontIdent;
end;
{===============================================================================

<Sysnopsis>       Set FontIdent property.

<Description>     Set FontIdent property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign FontIdent property from.

<Post state>      FontIdent property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_FontIdent(Value:Integer);
begin
   FFontIdent:=Value;
   FLabel.Font:=Parent.TFont[Parent.IndexOfFont(Value)].AsFont;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return Caption property.

<Description>     Return Caption property of FLabel.

<Result>          WordWrap Caption of FLabel.
________________________________________________________________________________}

function TILabel.Get_Caption:WideString;
begin
   Result:=FLabel.Caption;
end;
{===============================================================================

<Sysnopsis>       Set Caption property.

<Description>     Set Caption property of FLabel to Value.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.

<Value>           Variable to assign Caption property from.

<Post state>      Caption property of FLabel assigned.
                  If the onLableChange procedure of parent has been assigned,
                  then execute.
________________________________________________________________________________}

procedure TILabel.Set_Caption(const Value:WideString);
begin
   FLabel.Caption:=Value;
   if Assigned(Parent.OnLabelChange) then Parent.OnLabelChange(Self);
end;
{TIBitmap}
{===============================================================================

<Sysnopsis>       Initialize the object

<Description>     Create Object of class TIBitmap and Assign to variables
                  FData, FIdent.

<Post state>      FBitMap, FData, FIdent have been assinged and initialized.
________________________________________________________________________________}

procedure TIBitmap.Initialize;
begin
   inherited Initialize;
   _AddRef;
   FBitMap:=TBitMap.Create;
   FImage:=nil;
   FData:=UnAssigned;
   FIdent:=0;                
end;
{===============================================================================

<Sysnopsis>       Unassign FBitMap.

<Description>     Executed when 'free' is called.
                  Unassign memory allocated for FBitMap.
                  Unassign FData.

<Post state>      FBitMap freed.

________________________________________________________________________________}

destructor TIBitmap.Destroy;
begin
   if not VarIsEmpty(FData) then FData:=UnAssigned;
   if FBitMap <> nil then FBitMap.Free;
   FBitMap:=nil;
   inherited Destroy;
end;

function TIBitmap.Get_Left: Integer;
begin
   Result:=FLeft;
end;
procedure TIBitmap.Set_Left(Value: Integer);
begin
   if FLeft <> Value then
   begin
      FLeft:=Value;
      if (FImage <> nil) then
         FImage.Left:=FLeft;
   end;         
end;
function TIBitmap.Get_Top: Integer;
begin
   Result:=FTop;
end;
procedure TIBitmap.Set_Top(Value: Integer);
begin
   if FTop <> Value then
   begin
      FTop:=Value;
      if (FImage <> nil) then
         FImage.Top:=FTop;
   end;
end;
function TIBitmap.Get_Transparent: WordBool;
begin
   Result:=FTransparent;
end;   
procedure TIBitmap.Set_Transparent(Value: WordBool);
begin
   FTransparent:=Value;
   if FImage <> nil then
      FImage.Transparent:=FTransparent;
end;   
function TIBitmap.Get_Visible: WordBool;
begin
   Result:=FVisible;
end;   
procedure TIBitmap.Set_Visible(Value: WordBool);
begin
   if FVisible <> Value then
   begin
      if (FImage = nil) and (Assigned(Parent.FGetNewImage)) then
      begin
         FImage:=Parent.FGetNewImage(Parent);
         FImage.Picture.BitMap.Assign(FBitMap);
      end;
      FVisible:=Value;
      if (FImage <> nil) then
      begin
         FImage.SetBounds(FLeft,FTop,FBitmap.Width,FBitmap.Height);
         FImage.Visible:=FVisible;
         FImage.Name:=FName;
         FImage.Transparent:=FTransparent;
      end;
   end;  
end;
function TIBitmap.Get_Name:WideString;
begin
    Result:=FName;
end;
procedure TIBitmap.Set_Name(const Value:WideString);
begin
    FName:=Value;
    if (FImage <> nil) then
       FImage.Name:=Value;
end;
{===============================================================================

<Sysnopsis>       Return Data property.

<Description>     Return Data property of TIBitMap object.

<Result>          Data property of TIBitMap object.
________________________________________________________________________________}

function TIBitmap.Get_Data:OleVariant;
begin
   Result:=FData;
end;
{===============================================================================

<Sysnopsis>       Assign Bitmap to FData property.

<Description>     Copies the Bitmap image to FData, via a Variant array.

<Value>           Bitmap to assign to FData.

<Post state>      Bitmap assigned to FData.
________________________________________________________________________________}

procedure TIBitmap.SetFromBitMap(BitMap:TBitMap);
var
   Compressor:TCompressor;
   P:PChar;
   ASize:Integer;
begin
   FBitMap.Assign(BitMap);
   Compressor:=TCompressor.Create;
   FData:=Compressor.CreateArrayFromBitmap(FBitMap);
   Compressor.Free;
   ASize:=(VarArrayHighBound(FData,1)-VarArrayLowBound(FData,1))+1;
   P:=VarArrayLock(FData);
   try
      FCRC:=CalcMemCCITTCRC(P,ASize);
   except
   end;
   VarArrayUnLock(FData);
end;

{===============================================================================

<Sysnopsis>       Copy OleVariant (Value) FBitMap

<Description>     Reads Value (variant array) into MemStream, loads Memstream
                  into FBitMap, then call SetFromBitMap.

<Value>           Variable to pass into FBitmap.

<Post state>      Value copied to FBitMap .
________________________________________________________________________________}

procedure TIBitmap.Set_Data(Value:OleVariant);//Variant Array
var
   Compressor:TCompressor;
begin   
   if FBitMap <> nil then
      FBitMap.Free;
      
   Compressor:=TCompressor.Create;
   FBitMap:=Compressor.CreateBitmapFromArray(Value);
   Compressor.Free;
   
   SetFromBitMap(FBitMap);
end;

{===============================================================================

<Sysnopsis>       Return  TIBitMap object information.

<Description>     Return the private variable FBitMap.

<Result>          FBitMap.

________________________________________________________________________________}

function TIBitmap.AsBitMap:TBitMap;
begin
   Result:=FBitMap;
end;
{===============================================================================

<Sysnopsis>       Return TIBitmap object information.

<Description>     Return Width property of TIBitMap object.

<Result>          Width property of TIBitMap object.
________________________________________________________________________________}

function TIBitmap.Get_Width:Integer;
begin
   Result:=FBitMap.Width;
end;
{===============================================================================

<Sysnopsis>       Assign Value to Width.

<Description>     Return Width property of TIBitMap object.

<Value>           Variable to assign to Width property of FBitMap.

<Post state>      Width property of FBitMap assigned.
_______________________________________________________________________________}

procedure TIBitmap.Set_Width(Value:Integer);
begin
   FBitMap.Width:=Value;
   if (FImage <> nil) then
      FImage.Width:=FBitMap.Width;
end;
{===============================================================================

<Sysnopsis>       Return TIBitmap object information.

<Description>     Return Height property of TIBitMap object.

<Result>          Height property of TIBitMap object.
________________________________________________________________________________}

function TIBitmap.Get_Height:Integer;
begin
   Result:=FBitMap.Height;
end;
{===============================================================================

<Sysnopsis>       Assign Value to Height.

<Description>     Return Height property of TIBitMap object.

<Value>           Variable to assign to Height property of FBitMap.

<Post state>      Height property of FBitMap assigned.
________________________________________________________________________________}

procedure TIBitmap.Set_Height(Value: Integer);
begin
   FBitMap.Height:=Value;
   if (FImage <> nil) then
      FImage.Height:=FBitMap.Height;
end;     
{===============================================================================

<Sysnopsis>       Return TIBitmap object information.

<Description>     Return private variable FIdent.

<Result>          FIdent variable of TIBitMap object.
________________________________________________________________________________}

function TIBitmap.Get_Ident:Integer;
begin
   Result:=FIdent;
end;
{===============================================================================

<Sysnopsis>       Assign Value to FIdent.

<Description>     Assign Value to FIdent variable of TIBitMap object.

<Value>           Variable to assign to FIdent property of FBitMap.

<Post state>      FIdent variable of FBitMap assigned.

________________________________________________________________________________}

procedure TIBitmap.Set_Ident(Value:Integer);
begin
   FIdent:=Value;
end;


{TIButton}
{===============================================================================

<Sysnopsis>       Initialize the TIButton object

<Description>     Call inherited initialize, and initialize variables here.

<Post state>      TIButton initialized.
_______________________________________________________________________________}
procedure  TIButton.Initialize;
begin
   inherited Initialize;
   _AddRef;
   FKGButton            :=nil;
   FLeft                :=0;
   FTop                 :=0;
   FEnabled             :=True;
   FDown                :=False;
   FToggle              :=False;
   FFontIdent           :=0;
   FBitMapUpIdent       :=0;
   FBitMapDownIdent     :=0;
   FGlyphIdent          :=0;
   FText                :='';
   FPrice               :='';
   FKey                 :='';
end;
{===============================================================================

<Sysnopsis>       Unassign TIButton Object.

<Description>     Executed when 'free' is called.
                  Unassign memory allocated for TIButton object.

<Post state>      TiButton Object freed.
________________________________________________________________________________}

destructor TIButton.Destroy;
begin
   inherited Destroy;
end;
function TIButton.Get_Name:WideString;
begin
    Result:=FName;
end;
procedure TIButton.Set_Name(const Value:WideString);
begin
    FName:=Value;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FLeft.

<Result>          FLeft variable of TIButton object.
________________________________________________________________________________}

function  TIButton.Get_Left:Integer;
begin
   Result:=FLeft;
end;

procedure TIButton.Set_Left(Value:Integer);
begin
   FLeft:=Value;
   if FKGButton <> nil then FKGButton.Left:=FLeft;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FTop.

<Result>          FTop variable of TIButton object.
________________________________________________________________________________}

function  TIButton.Get_Top:Integer;
begin
   Result:=FTop;
end;
procedure TIButton.Set_Top(Value:Integer);
begin
   FTop:=Value;
   if FKGButton <> nil then FKGButton.Top:=FTop;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FEnabled.

<Result>          FEnabled variable of TIButton object.
________________________________________________________________________________}

function  TIButton.Get_Enabled:WordBool;
begin
   Result:=FEnabled;
end;

procedure TIButton.Set_Enabled(Value:WordBool);
begin
   FEnabled:=Value;
   if FKGButton <> nil then
   begin
      FKGButton.Enabled:=FEnabled;
      FKGButton.IsAvailable:=FEnabled;
   end;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FDown.

<Result>          FDown variable of TIButton object.
________________________________________________________________________________}

function  TIButton.Get_Down:WordBool;
begin
   Result:=FDown;
end;
procedure TIButton.Set_Down(Value:WordBool);
begin
   FDown:=Value;
   if FKGButton <> nil then FKGButton.ButtonIsUp:=not FDown;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FToggle.

<Result>          FToggle variable of TIButton object.
________________________________________________________________________________}

function TIButton.Get_Toggle:WordBool;
begin
   Result:=FToggle;
end;

procedure TIButton.Set_Toggle(Value:WordBool);
begin
   FToggle:=Value;
   if FKGButton <> nil then FKGButton.ToggleWhenClicked:=FToggle;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FFontIdent.

<Result>          FFontIdent variable of TIButton object.
________________________________________________________________________________}

function TIButton.Get_FontIdent:Integer;
begin
   Result:=FFontIdent;
end;
procedure TIButton.Set_FontIdent(Value:Integer);
begin
   FFontIdent:=Value;
   if FKGButton <> nil then
      FKGButton.Font:=
         Parent.TFont[Parent.IndexOfFont(Value)].AsFont;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FBitMapUpIdent.

<Result>          FBitMapUpIdent variable of TIButton object.
________________________________________________________________________________}

function  TIButton.Get_BitMapUpIdent:Integer;
begin
   Result:=FBitMapUpIdent;
end;
procedure TIButton.Set_BitMapUpIdent(Value:Integer);
begin
   FBitMapUpIdent:=Value;
   if FKGButton <> nil then
      FKGButton.UpBitMap:=
         Parent.TBitMap[Parent.IndexOfBitMap(Value)].AsBitMap;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FBitMapDownIdent.

<Result>          FBitMapDownIdent variable of TIButton object.
________________________________________________________________________________}

function  TIButton.Get_BitMapDownIdent:Integer;
begin
   Result:=FBitMapDownIdent;
end;
procedure TIButton.Set_BitMapDownIdent(Value:Integer);
begin
   FBitMapDownIdent:=Value;
   if FKGButton <> nil then
      FKGButton.DownBitMap:=
         Parent.TBitMap[Parent.IndexOfBitMap(Value)].AsBitMap;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FGlyphIdent.

<Result>          FGlyphIdent variable of TIButton object.
________________________________________________________________________________}

function  TIButton.Get_GlyphIdent:Integer;
begin
   Result:=FGlyphIdent;
end;
procedure TIButton.Set_GlyphIdent(Value:Integer);
var
   GlyphIndex:Integer;
begin
   FGlyphIdent:=Value;
   if FKGButton <> nil then
   begin
      GlyphIndex:=Parent.IndexOfBitMap(Value);
      if GlyphIndex <> -1 then
      begin
         FKGButton.Glyph:=Parent.TBitMap[GlyphIndex].AsBitMap;
      end
      else
      begin
         FKGButton.Glyph:=nil;
      end;
   end;   
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FText.

<Result>          FText variable of TIButton object.
________________________________________________________________________________}

function  TIButton.Get_Text:WideString;
begin
   Result:=FText;
end;
procedure TIButton.Set_Text(const Value:WideString);
begin
   FText:=Value;
   if FKGButton <> nil then FKGButton.Caption:=FText;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FPrice.

<Result>          FPrice variable of TIButton object.
________________________________________________________________________________}

function  TIButton.Get_Price:WideString;
begin
   Result:=FPrice;
end;
procedure TIButton.Set_Price(const Value:WideString);
begin
   FPrice:=Value;
   if FKGButton <> nil then
   begin
      FKGButton.Price:=FPrice;
      FKGButton.ShowPrice:=True;
   end;
end;
{===============================================================================

<Sysnopsis>       Return TIButton object information.

<Description>     Return private variable FKey.

<Result>          FKey variable of TIButton object.
________________________________________________________________________________}
function  TIButton.Get_Key:WideString;
begin
   Result:=FKey;
end;
procedure TIButton.Set_Key(const Value:WideString);
begin
   FKey:=Value;
   if FKGButton <> nil then FKGButton.KeyName:=FKey;
end;
procedure TIButton.ButtonClick(Sender:TObject);
begin
   if Assigned(Parent.OnButtonClick) then
   begin
      FDown:=not FKGButton.ButtonIsUp;
      Parent.OnButtonClick(FKGButton);
   end;
end;
procedure TIButton.Set_KGButton(AButton:TKGButton);
begin
   FKGButton:=AButton;
   FKGButton.OnClick:=ButtonClick;
end;
{TIUIStyle}
procedure TIUIStyle.Initialize;
begin
   inherited Initialize;
   _AddRef;
   FWidth           :=1024;
   FHeight          :=768;
   FBGColor         :=clBtnFace;
   FDefaultFontIdent:=0;
   FButtons         :=TList.Create;
   FBitMaps         :=TList.Create;
   FFonts           :=TList.Create;
   FTextLabels      :=TList.Create;
   FRightAnchored   :=False;
   FVisible         :=False;
end;
destructor TIUIStyle.Destroy;
var
   I:Integer;
begin
   for I:=0 to FontCount-1 do
      if FFonts[I] <> nil then
         TIFont(FFonts[I]).Free;
   for I:=0 to ButtonCount-1 do
      if FButtons[I] <> nil then
        TIButton(FButtons[I]).Free;
   for I:=0 to BitMapCount-1 do
      if FBitMaps[I] <> nil then
         TIBitMap(FBitMaps[I]).Free;
   for I:=0 to TextLabelCount-1 do
      if FTextLabels[I] <> nil then
         TILabel(FTextLabels[I]).Free;

   FFonts.Free;
   FButtons.Free;
   FBitMaps.Free;
   FTextLabels.Free;

   inherited Destroy;
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return private variable FWidth.

<Result>          FWidth variable of TIUIStyle object.
________________________________________________________________________________}

function  TIUIStyle.Get_Width: Integer;
begin
   Result:=FWidth;
end;
procedure TIUIStyle.Set_Width(Value: Integer);
begin
   FWidth:=Value;
   if Assigned(OnFormChange) then OnFormChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return private variable FHeight.

<Result>          FHeight variable of TIUIStyle object.
________________________________________________________________________________}

function  TIUIStyle.Get_Height: Integer;
begin
   Result:=FHeight;
end;
procedure TIUIStyle.Set_Height(Value: Integer);
begin
   FHeight:=Value;
   if Assigned(OnFormChange) then OnFormChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return private variable FBGColor.

<Result>          FBGColor variable of TIUIStyle object.
________________________________________________________________________________}

function  TIUIStyle.Get_BGColor: Integer;
begin
   Result:=FBGColor;
end;
procedure TIUIStyle.Set_BGColor(Value: Integer);
begin
   FBGColor:=Value;
   if Assigned(OnFormChange) then OnFormChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return private variable FDefaultFontIdent.

<Result>          FDefaultFontIdent variable of TIUIStyle object.
________________________________________________________________________________}

function  TIUIStyle.Get_DefaultFontIdent: Integer;
begin
   Result:=FDefaultFontIdent;
end;
procedure TIUIStyle.Set_DefaultFontIdent(Value: Integer);
begin
   FDefaultFontIdent:=Value;
   if Assigned(OnFormChange) then OnFormChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return Count property of FButtons.

<Result>          Count property of FButtons.
________________________________________________________________________________}

function  TIUIStyle.Get_ButtonCount: Integer;
begin
   Result:=FButtons.Count;
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return Count property of FBitMaps.

<Result>          Count property of FBitMaps.
________________________________________________________________________________}

function  TIUIStyle.Get_BitMapCount: Integer;
begin
   Result:=FBitMaps.Count;
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return Count property of FFonts.

<Result>          Count property of FFonts.
________________________________________________________________________________}

function  TIUIStyle.Get_FontCount: Integer;
begin
   Result:=FFonts.Count;
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return Count property of FTextLabels.

<Result>          Count property of FTextLabels.
________________________________________________________________________________}

function  TIUIStyle.Get_TextLabelCount: Integer;
begin
   Result:=FTextLabels.Count;
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return TIButton object at position Index from list FButtons.

<Result>          TIButton object.
________________________________________________________________________________}

function TIUIStyle.Get_TButton(Index: Integer): TIButton;
begin
   Result:=TIButton(FButtons[Index]);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return TIBitMap object at position Index from list FBitMaps.

<Result>          TIBitMap object.
________________________________________________________________________________}

function TIUIStyle.Get_TBitMap(Index: Integer): TIBitMap;
begin
   Result:=TIBitMap(FBitMaps[Index]);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return TIFont object at position Index from list FFonts.

<Result>          TIFont object.
________________________________________________________________________________}

function TIUIStyle.Get_TFont(Index: Integer): TIFont;
begin
   Result:=TIFont(FFonts[Index]);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return TILabel object at position Index from list FTextLabels.

<Result>          TILabel object.
________________________________________________________________________________}

function TIUIStyle.Get_TTextLabel(Index: Integer): TILabel;
begin
   Result:=TILabel(FTextLabels[Index]);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return TIButton object at position Index from list FButtons.

<Result>          TILabel object.
________________________________________________________________________________}

function  TIUIStyle.Get_Button(Index: Integer): IButton;
begin
   Result:=TIButton(FButtons[Index]);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return TIBitMap object at position Index from list FBitMaps.

<Result>          TIBitMap object.
________________________________________________________________________________}

function  TIUIStyle.Get_BitMap(Index: Integer): IBitMap;
begin
   Result:=TIBitMap(FBitMaps[Index]);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return TIFonts object at position Index from list FFonts.

<Result>          TIFont object.
________________________________________________________________________________}

function  TIUIStyle.Get_Font(Index: Integer): IGPCSFont;
begin
   Result:=TIFont(FFonts[Index]);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return TILabel object at position Index from list FTextLabels.

<Result>          TILabel object.
________________________________________________________________________________}

function  TIUIStyle.Get_TextLabel(Index: Integer): IGPCSLabel;
begin
   Result:=TILabel(FTextLabels[Index]);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return private variable FRightAnchored.

<Result>          FRightAnchored variable of TIUIStyle object.
________________________________________________________________________________}

function  TIUIStyle.Get_RightAnchored: WordBool;
begin
   Result:=FRightAnchored;
end;

procedure TIUIStyle.Set_RightAnchored(Value: WordBool);
begin
   FRightAnchored:=Value;
   if Assigned(OnFormChange) then OnFormChange(Self);
end;
{===============================================================================

<Sysnopsis>       Return TIUIStyle object information.

<Description>     Return private variable FVisible.

<Result>          FVisible variable of TIUIStyle object.
________________________________________________________________________________}

function TIUIStyle.Get_Visible: WordBool;
begin
   Result:=FVisible;
end;
procedure TIUIStyle.Set_Visible(Value: WordBool);
begin
   FVisible:=Value;
   if Assigned(OnFormChange) then OnFormChange(Self);
end;                           
{===============================================================================
<Sysnopsis>       Return TIUIStyle object information.

<Description>     Returns a unique ID by incrementing constant ResValue.

<Result>          Constant ResValue.
________________________________________________________________________________}

function TIUIStyle.GetUniqueId:Integer;
const
   ResValue:Integer = 0;
begin
   Inc(ResValue);
   Result:=ResValue;
end;
{===============================================================================
<Sysnopsis>       Adds a TIButton object to list FButtons.

<Description>     Creates object IButton. Sets Self to be parent.
                  Adds Button to list FButtons. If OnAddButton property(function)
                  is assigned then set Button property (procedure) to OnAddButton.
                  Add IButton to list FButtons

<Result>          Index of IButton.
________________________________________________________________________________}

function TIUIStyle.AddButton: Integer;
var
   IButton:TIButton;
begin
   IButton:=TIButton.Create;
   IButton.Parent:=Self;
   if Assigned(OnAddButton) then
      IButton.Button:=OnAddButton(Self);
   Result:=FButtons.Add(IButton);
end;
{===============================================================================
<Sysnopsis>       Adds a TBitMap object to list FBitMaps.

<Description>     Creates object IBitMap. Set Ident property to a unique number
                  by calling GetUniqueID functions. Adds object IBitMap to list
                  FBitMaps.

<Result>          Index of IBitMap.
________________________________________________________________________________}

function  TIUIStyle.AddBitMap: Integer;
var
   IBitMap:TIBitMap;
begin
   IBitMap:=TIBitMap.Create;
   IBitMap.Ident:=GetUniqueId;
   Result:=FBitMaps.Add(IBitMap);
   IBitMap.Parent:=Self;
end;
{===============================================================================
<Sysnopsis>       Adds a TIFont object to list FFonts.

<Description>     Creates object IFont. Sets Ident property to a unique number
                  by calling GetUniqeId function. Adds object IFonts to list
                  FFonts.

<Result>          Index of IFont.
________________________________________________________________________________}

function  TIUIStyle.AddFont: Integer;
var
   IFont:TIFont;
begin
   IFont:=TIFont.Create;
   IFont.Ident:=GetUniqueId;
   Result:=FFonts.Add(IFont);
end;
{===============================================================================
<Sysnopsis>       Adds a TILabel object to list FTextLabels.

<Description>     Creates object ILabel. Sets Ident property to a unique number
                  by calling GetUniqeId function. Adds object ILabel to list
                  FTextLabels.

<Result>          Index of ILabel.
________________________________________________________________________________}

function TIUIStyle.AddTextLabel:Integer;
var
   ILabel:TILabel;
begin
   ILabel:=TILabel.Create;
   ILabel.Parent:=Self;
   Result:=FTextLabels.Add(ILabel);
end;
{===============================================================================
<Sysnopsis>       Returns the index of property Font.

<Description>     Returns index of font which has ident property of parameter
                  ident. If parameter ident is not equal to any index value of
                  Font then result is -1.

<Result>          Index of property Font.
________________________________________________________________________________}

function TIUIStyle.IndexOfFont(Ident:Integer):Integer;
var
   I:Integer;
begin
   Result:=-1;
   for I:=0 to FontCount-1 do
   begin
      if Font[I].Ident = Ident then
      begin
         Result:=I;
         Break;
      end;
   end;
end;
{===============================================================================
<Sysnopsis>       Returns the index of property BitMap.

<Description>     Returns index of font which has ident property of parameter
                  ident. If parameter ident is not equal to any index value of
                  Font then result is -1.

<Result>          Index of property Font.
________________________________________________________________________________}

function TIUIStyle.IndexOfBitMap(Ident:Integer):Integer;
var
   I:Integer;
begin
   Result:=-1;
   for I:=0 to BitMapCount-1 do
   begin
      if BitMap[I].Ident = Ident then
      begin
         Result:=I;
         Break;
      end;
   end;
end;

{TIPickItem}
procedure TIPickItem.Initialize;
begin
   inherited Initialize;
   _AddRef;
   FPickItem:=TPickItem.Create('',nil,False,True,0);
   FBitMap:=TIBitMap.Create;
end;
destructor TIPickItem.Destroy;
begin
   FPickItem.Parent:=nil;
   if FPickItem <> nil then FPickItem.Free;
   FPickItem:=nil;
   if FBitMap <> nil then FBitMap.Free;
   FBitMap:=nil;
   inherited Destroy;
end;
function TIPickItem.Get_Caption: WideString;
begin
   Result:=FPickItem.Caption;
end;
procedure TIPickItem.Set_Caption(const Value: WideString);
begin
   FPickItem.Caption:=Value;
end;
function TIPickItem.Get_Picture: IBitMap;
begin
   Result:=FBitMap;
end;
procedure TIPickItem.Set_Picture(const Value: IBitMap);
begin
   FBitMap.Data:=Value.Data;
   FPickItem.Picture:=FBitMap.AsBitMap;
end;
function TIPickItem.Get_Selected: WordBool;
begin
   Result:=FPickItem.Selected;
end;                      
procedure TIPickItem.Set_Selected(Value: WordBool);
begin
   FPickItem.Selected:=Value;
end;
function TIPickItem.Get_Enabled: WordBool;
begin
   Result:=FPickItem.Enabled;
end;         
procedure TIPickItem.Set_Enabled(Value: WordBool);
begin
   FPickItem.Enabled:=Value;
end;
function TIPickItem.Get_Price: Currency;
begin
   Result:=FPickItem.Price;
end;
procedure TIPickItem.Set_Price(Value: Currency);
begin
   FPickItem.Price:=Value;
end;

{TIPickItemList}
procedure TIPickItemList.Initialize;
begin
   inherited Initialize;
   FPickList:=TPickList.Create('','','',nil);
   FBitMap:=TIBitMap.Create;
   _AddRef;
end;
destructor TIPickItemList.Destroy;
begin
   if FBitMap <> nil then FBitMap.Free;
   FBitMap:=nil;
   if FPickList <> nil then FPickList.Free;
   FPickList:=nil;
   inherited Destroy;
end;
function TIPickItemList.Get_Title: WideString;
begin
   Result:=FPickList.Title;
end;
procedure TIPickItemList.Set_Title(const Value: WideString);
begin
   FPickList.Title:=Value;
end;
function TIPickItemList.Get_Prompt: WideString;
begin
   Result:=FPickList.Prompt;
end;
procedure TIPickItemList.Set_Prompt(const Value: WideString);
begin
   FPickList.Prompt:=Value;
end;
function TIPickItemList.Get_Hint: WideString;
begin
   Result:=FPickList.Hint;
end;
procedure TIPickItemList.Set_Hint(const Value: WideString);
begin
   FPickList.Hint:=Value;
end;
function TIPickItemList.Get_Picture:IBitMap;
begin
   Result:=FBitMap;
end;
procedure TIPickItemList.Set_Picture(const Value: IBitMap);
begin
   FBitMap.Data:=Value.Data;
   FPickList.Picture:=FBitMap.AsBitMap;
end;
function TIPickItemList.Get_Count: Integer;
begin
   Result:=FPickList.Count;
end;
function TIPickItemList.Get_Items(Index: Integer): IPickItem;
begin
   if FPickList.Items[Index] <> nil then
      Result:=(FPickList.Items[Index].Parent as TIPickItem)
   else
      Result:=nil;
end;
procedure TIPickItemList.LoadFromInterface(PickItemList:IPickItemList);
var
   I:Integer;
begin
   Title  :=PickItemList.Title  ;
   Prompt :=PickItemList.Prompt ;
   Hint   :=PickItemList.Hint   ;
   Picture:=PickItemList.Picture;
   for I:=0 to PickItemList.Count-1 do
      Add(PickItemList.Items[I]);
end;
function TIPickItemList.Add(const PickItem: IPickItem): Integer;
var
   NewPickItem:TIPickItem;
begin
   NewPickItem:=TIPickItem.Create;
   NewPickItem.Caption  :=PickItem.Caption;
   NewPickItem.Picture  :=PickItem.Picture;
   NewPickItem.Selected :=PickItem.Selected;
   NewPickItem.Enabled  :=PickItem.Enabled;
   NewPickItem.Price    :=PickItem.Price;
   NewPickItem.FPickItem.Parent:=NewPickItem;
   Self.FPickList.Add(NewPickItem.FPickItem);
end;
procedure TIPickItemList.Delete(Index: Integer);
var
   PickItem:TIPickItem;
begin
   if FPickList.Items[Index] <> nil then
   begin
      PickItem:=(FPickList.Items[Index].Parent as TIPickItem);
      FPickList.Delete(Index);
      PickItem.FPickItem:=nil;
      PickItem.Free;
   end;
end;

procedure CreateInterfaceFactories;
begin
  TComObjectFactory.Create(ComServer,TIFont,
                          StringToGUID('{A05A8680-CE92-11D2-AA05-00A0CC3A61B2}'),
                          'TIFont.Font','Corvus Internal IFont',ciInternal);
  TComObjectFactory.Create(ComServer,TIBitMap,
                          StringToGUID('{FD7439E1-CE94-11D2-AA05-00A0CC3A61B2}'),
                          'TIBitMap.BitMap','Corvus Internal IBitMap',ciInternal);
  TComObjectFactory.Create(ComServer,TILabel,
                          StringToGUID('{273517E1-CF2B-11D2-AA05-00A0CC3A61B2}'),
                          'TILabel.Label','Corvus Internal ILabel',ciInternal);
  TComObjectFactory.Create(ComServer,TIButton,
                          StringToGUID('{B20C0142-CF20-11D2-AA05-00A0CC3A61B2}'),
                          'TIButton.Button','Corvus Internal IButton',ciInternal);
  TComObjectFactory.Create(ComServer,TIPickItem,
                          StringToGUID('{8646391D-3AC9-4F2F-8C06-058323330137}'),
                          'TIPickItem.PickItem','Corvus Internal IPickItem',ciInternal);
  TComObjectFactory.Create(ComServer,TIPickItemList,
                          StringToGUID('{4979CC84-3A3A-4963-8A3B-FAEB600693D2}'),
                          'TIPickItem.PickItemList','Corvus Internal IPickItemList',ciInternal);
end;

end.

