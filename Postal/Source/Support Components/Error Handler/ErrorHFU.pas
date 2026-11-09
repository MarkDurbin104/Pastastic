{  Module          Corvus Error Handler
   Unit            Form
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     Display and log errors form the rest of the Corvus system.
   Modifications   19/03/98 - MJD
                              Original Release
   									27/03/00 - ASH
                    					MeasureItem used to wrap multi-line
                              Buttons changed
}
unit ErrorHFU;

interface

uses

	GPCSGUID, StringUtil, Clipbrd,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,ComServ2,afpEventLog;

type
  TErrorForm = class(TForm)
    ErrorPanel: TPanel;
    TitlePanel: TPanel;
    LTitle: TLabel;
    Exclaimation: TImage;
    Logo: TImage;
    MessagePanel: TPanel;
    Lsource: TLabel;
    LPriority: TLabel;
    LData: TLabel;
    LType: TLabel;
    EModule: TEdit;
    EType: TEdit;
    EData: TEdit;
    EPriority: TEdit;
    ButtonPanel: TPanel;
    CompleteButton: TButton;
    ErrorListBox: TListBox;
    ClearLogButton: TButton;
    ViewAsTextButton: TButton;
    CopyButton: TButton;
    procedure CompleteButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ClearLogButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ViewAsTextButtonClick(Sender: TObject);
    procedure ErrorListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ErrorListBoxMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CopyButtonClick(Sender: TObject);
  private
    procedure Reactivate(Sender: TObject);
    procedure FileIsDropped ( VAR Msg : TWMDropFiles ) ; Message WM_DropFiles ;

  public
    EventLog: TafpEventLog;
    procedure RefreshLog;
    function FromAsString(CompVal,ClassVal,MethVal:Integer):String;
    function PriAsString(ErrorPriority:Integer):String;
    function ErrorMessage(Code:Integer):String;
    procedure PopulateListBox(SL : TStringList);
  end;

var
  ErrorForm: TErrorForm;

implementation

uses
  ErrorHAU,
  shellapi,
  LogFileU,GPCSErrorLine,GPCSErrorCode;
   
{$R *.DFM}

{===============================================================================
  Class        TErrorForm 
  Method       CompleteButtonClick
  Description  Acknoledge the error and close window
  Params       Sender
  Result       None
________________________________________________________________________________}
procedure TErrorForm.CompleteButtonClick(Sender: TObject);
begin
   try
      Application.OnDeactivate:=nil; // stop - force to top
      if ComServer.StartMode = smStandalone then // i.e. viewing log 
         Close;
   except
      // Can't Raise an error here !
   end;
end;   

{===============================================================================
  Class        TErrorForm 
  Method       FromAsString
  Description  Return the 'Error came from' string based upon then
               component, class and  method identifiers
  Params       CompVal,ClassVal,MethVal
  Result       The 'Error came from' string
________________________________________________________________________________}
function TErrorForm.FromAsString(CompVal,ClassVal,MethVal:Integer):String;
var
   Index:Integer;
   CompName:String;
   ClassName:String;
   MethName:String;
begin
   // set default names 
   CompName :='Component('+IntToHex(CompVal ,2)+')';
   ClassName:='Class('    +IntToHex(ClassVal,2)+')';
   MethName :='Method('   +IntToHex(MethVal ,2)+')';
   try
      // adjust params for ECToIndexList look up
      CompVal :=CompVal shl 8;
      ClassVal:=(CompVal or ClassVal) shl 8;
      MethVal :=(ClassVal or MethVal) shl 8;
      
      // go through the index list and find each entry
      for Index:=0 to ECToIndexListCount-1 do
      begin
         // if you find an entry then change the default name
         if ECToIndexList[Index] = CompVal then CompName:=ECToStringList[Index]
         else if ECToIndexList[Index] = ClassVal then ClassName:=ECToStringList[Index]
         else if ECToIndexList[Index] = MethVal then MethName:=ECToStringList[Index];
      end;
      // concatinate the result
      Result:=CompName+' - '+ClassName+' - '+MethName;
   except
      Result:='Exception '+CompName+' - '+ClassName+' - '+MethName;
   end;
end;  
{===============================================================================
  Class        TErrorForm 
  Method       PriAsString 
  Description  Return the Priority string form an integer
  Params       ErrorPriority
  Result       the Priority string
________________________________________________________________________________}
function TErrorForm.PriAsString(ErrorPriority:Integer):String;
begin
   try
{      case ErrorPriority of
         EP_Severe        : Result:=EPM_Severe       ;
         EP_UnRecoverable : Result:=EPM_UnRecoverable;
         EP_Recoverable   : Result:=EPM_Recoverable  ;
         EP_Warning       : Result:=EPM_Warning      ;
         EP_Information   : Result:=EPM_Information  ;

         else}
         Result:='Priority '+IntToStr(ErrorPriority);
//      end;
   except
      // Can't Raise an error here !
   end;
end;
{===============================================================================
  Class        TErrorForm 
  Method       ErrorMessage
  Description  Convert an Error Code into an Error message
  Params       The Error Code
  Result       Error message or 'Error Message Number [Code]' on error
________________________________________________________________________________}
function TErrorForm.ErrorMessage(Code:Integer):String;
begin
   try
      // if we have a message for this code
      if Code < EMessageCount then
         Result:=EMessages[Code]
      else
         Result:='Error Message Number '+IntToStr(Code);
   except
      Result:='Exception Error Message Number '+IntToStr(Code);
   end;
end;
{===============================================================================
  Class        TErrorForm 
  Method       Reactivate
  Description  Bring form back to front if deactivated
  Params       Sender
  Result       None
________________________________________________________________________________}
procedure TErrorForm.Reactivate(Sender: TObject);
begin
   SetForegroundWindow(Handle);
end;

procedure TErrorForm.PopulateListBox(SL : TStringList);
var
  I : Integer;
  EFrom:Integer;
  EType:Integer;
  EPriority:Integer;
  EStr:String;
  EDateTime:TDateTime;
  Component:Integer;
  CompClass:Integer;
  Method   :Integer;
  ErrNo    :Integer;
begin
  for I:=SL.Count-1 downto 0 do  // traverse in reverse order (last entry first)
  begin
    EDateTime:=IntToDateTime(Integer(SL.Objects[I])); // get error time
    EFrom:=HexToInt(Copy(SL[I],1,8));                         // get error source
    EType:=HexToInt(Copy(SL[I],9,8));                         // get error type
    EPriority:=EType shr 28;                                  // get priority
    EType:=EType and $0FFFFFFF;
    EStr:=Copy(SL[I],17,999);                                 // get additional info
    Component:=$FF and (EFrom shr 24);                        // convert from code to
    CompClass:=$FF and (EFrom shr 16);                        // separate codes
    Method   :=$FF and (EFrom shr  8);
    ErrNo    :=$FF and (EFrom       );

    ErrorListBox.Items.Add(DoubleQuote(DateTimeToStr(EDateTime)));             // Add to list
    ErrorListBox.Items.Add(DoubleQuote(FromAsString(Component,CompClass,Method)));
    ErrorListBox.Items.Add(DoubleQuote(IntToHex(ErrNo,2)));
    ErrorListBox.Items.Add(DoubleQuote(PriAsString(EPriority)));
    ErrorListBox.Items.Add(DoubleQuote(ErrorMessage(EType)));
    ErrorListBox.Items.Add(DoubleQuote(EStr));
    ErrorListBox.Items.Add('');
  end;
end;

{===============================================================================
  Class        TErrorForm
  Method       RefreshLog
  Description  Refresh the information in list from the log file
  Params       None
  Result       None
________________________________________________________________________________}
procedure TErrorForm.RefreshLog;
var
   LogFile:TLogFile;
   I,DTVal:Integer;
   SL:TStringList;
   MaxErrorLines : Integer;
begin
  ErrorListBox.Items.BeginUpdate;
  SL:=TStringList.Create;                  // to hold raw log
  try
    ErrorListBox.Items.Clear;
    LogFile:=TLogFile.Create(GetGPCSRegString('ErrorManager','LogFile','C:\GPCSErr.Log'));
    LogFile.ReadIntoList(SL);                // get log entries
    //truncate file
    MaxErrorLines := StrToIntDef(GetGPCSRegString('ErrorManager','Lines','500'),500);
    If SL.Count > MaxErrorLines then
    begin
      While SL.count > MaxErrorLines do
      begin
        SL.Delete(0);
        Application.ProcessMessages;
      end;

      //replace datetime
      for I:=0 to SL.Count-1 do
      begin
        DTVal := Integer(SL.Objects[I]);
        SL[I] := IntToHex(DTVal,8) + SL[I]; //put back datetime
      end;
      SL.SAveToFile(GetGPCSRegString('ErrorManager','LogFile','C:\GPCSErr.Log'));
      LogFile.ReadIntoList(SL);                // get log entries
    end;
    LogFile.Free;                            // release logfile
    PopulateListBox(SL);
  finally
    ErrorListBox.Items.EndUpdate;
    SL.Free;
  end;
end;
{===============================================================================
  Class        TErrorForm
  Method       FormCreate
  Description  Form Create Event
  Params       Sender
  Result       None
________________________________________________________________________________}
procedure TErrorForm.FormCreate(Sender: TObject);
begin
   try
     DragAcceptFiles( Handle,True ) ;
   		//setup eventlog
      EventLog:= TafpEventLog.Create(nil);
    	EventLog.ApplicationName 			:= 'Corvus Error Handler';
    	EventLog.RegisterApplication 	:= True;
    	EventLog.IncludeUserName 			:= True;
    	EventLog.EventType 						:= etError;
    	EventLog.EventID 							:= 0;
    	EventLog.EventCategory 				:= 0;

      if ComServer.StartMode <> smStandalone then
      begin
         BorderIcons:=[];                         // Turn off border icons
         ErrorPanel.Visible    :=True;            // Show Error
         ErrorListBox.Visible      :=False;           // Don't Show Log
         ClearLogButton.Visible:=False;           // Don't Show Log Clear Button
         ViewAsTextButton.Visible:=False;         // Don't Show View As Text Button
         Visible:=False;
      end
      else
      begin
         ErrorPanel.Visible    :=False;           // Dont Show Error Window
         ErrorListBox.Visible      :=True;            // Show Log
         ClearLogButton.Visible:=True;            // Show Log Clear Button
         ViewAsTextButton.Visible:=True;          // Show View As Text Button
         Caption:='Error Log';                    // Change Default Caption
         RefreshLog;
      end;
   except
      // Can't Raise an error here !
   end;
end;
{===============================================================================
  Class        TErrorForm 
  Method       ClearLogButtonClick
  Description  Clear the Error Log
  Params       Sender
  Result       None
________________________________________________________________________________}
procedure TErrorForm.ClearLogButtonClick(Sender: TObject);
var
   LogFile:TLogFile;
begin           
   try
      LogFile:=TLogFile.Create(GetGPCSRegString('ErrorManager','LogFile','C:\GPCSErr.Log'));
      LogFile.Clear;
      LogFile.Free;
      ErrorListBox.Clear;
   except
      // Can't Raise an error here !
   end;
end;
{===============================================================================
  Class        TErrorForm 
  Method       FormShow
  Description  FormShow
  Params       Sender
  Result       None
________________________________________________________________________________}
procedure TErrorForm.FormShow(Sender: TObject);
begin
   try
      if ComServer.StartMode <> smStandalone then  // if showing an error
      begin                                       
         Application.OnDeactivate:=Reactivate;     // dont loose focus
      end;
   except
      // Can't Raise an error here !
   end;
end;
{===============================================================================
  Class        TErrorForm 
  Method       ViewAsTextButtonClick
  Description  View the Error Log as raw text 
  Params       Sender
  Result       None
________________________________________________________________________________}
procedure TErrorForm.ViewAsTextButtonClick(Sender: TObject);
begin           
   try
      if ViewAsTextButton.Caption = '&Text' then
      begin
         ErrorListBox.Style:=lbStandard;
         ErrorListBox.Items.LoadFromFile(GetGPCSRegString('ErrorManager','LogFile','C:\GPCSErr.Log'));
         ViewAsTextButton.Caption:='&Log';
      end
      else
      begin
         ErrorListBox.Style:=lbOwnerDrawVariable;
         RefreshLog;
         ViewAsTextButton.Caption:='&Text';
      end;
   except
      // Can't Raise an error here !
   end;
end;
{===============================================================================
  Class        TErrorForm
  Method       ErrorListBoxDrawItem
  Description  Draw the 7 lines of the Error in a box
  Params       Control: ErrorListBox
               Index  : The index of the line to draw
               Rect   : The rectangle containing the line to draw
               State  : Focused, Selected etc...
  Result       None
________________________________________________________________________________}
procedure TErrorForm.ErrorListBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  CentreLine	: Integer;
  Title				: String;
  ErrorTextSL : TStringList;
begin
   try
      with ErrorListBox.Canvas do
      begin
         // position of the Centre line
         CentreLine:=Rect.Left+TextWidth('Priority')+10;
         // if it's the last line
         if ((Index mod 7) = 6) then
         begin
            Brush.Color:=clWindow; // White background
            FillRect(Rect);
            MoveTo(Rect.Left,Rect.Top);  // draw line across top
            LineTo(Rect.Right,Rect.Top);
         end
         else
         begin
            Brush.Color:=$00E1FFFF; // Light Yellow background
            FillRect(Rect);
            MoveTo(CentreLine,Rect.Top);       // draw vertical Centre line
            LineTo(CentreLine,Rect.Bottom);
            MoveTo(Rect.Left,Rect.Top);        // draw vertical Left Side
            LineTo(Rect.Left,Rect.Bottom);
            MoveTo(Rect.Right-1,Rect.Top);     // draw vertical Right Side
            LineTo(Rect.Right-1,Rect.Bottom);
            case Index mod 7 of
               0 : begin
                      Title:='Time';
                      MoveTo(Rect.Left,Rect.Top);  // draw line across top
                      LineTo(Rect.Right-1,Rect.Top)
                   end;
               1 : Title:='Origin';
               2 : Title:='Error';
               3 : Title:='Priority';
               4 : Title:='Type';
               5 : Title:='Info';
            end;
            Font.Color:=clBlack;
            TextOut(CentreLine-(TextWidth(Title)+5),Rect.Top+1,Title); // output title
            Font.Color:=clNavy;
            //TextOut(CentreLine+5,Rect.Top+1,ErrorListBox.Items[Index]); // output item
            Rect.TopLeft 			:= Point(CentreLine +5, Rect.Top+1);
            Rect.BottomRight 	:= Point(Rect.Right-1, Rect.Bottom);
            ErrorTextSL       := TStringList.Create;
            try
              ErrorTextSL.CommaText := ErrorListBox.Items[Index];
              DrawText(ErrorListBox.Canvas.Handle,
                      PChar(Trim(ErrorTextSL.Text)),
                      -1,
                      Rect,
                      DT_WORDBREAK);
            finally
               ErrorTextSL.Free;
            end;
         end;
      end;
   except
      // Can't Raise an error here !
   end;
end;

{===============================================================================
  Class        TErrorForm
  Method       ErrorListMeasure
  Description  Calculates height of items to allow for multilines in error list
  Params       Control		: ErrorListBox
               Index 			: The index of the line to draw
               var Height : Height for this item
  Result       None
________________________________________________________________________________}
procedure TErrorForm.ErrorListBoxMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
var
  Rect 				: TRect;
begin
  try
  With ErrorListBox.Canvas do
    begin
      //passed rectangle must have correct width
      Rect.TopLeft	:= Point(TextWidth('Priority')+15 , 0);
      Rect.BottomRight 	:= Point(Control.Width-10, Height);

      with TStringList.Create do
      begin
        try
          Height := 0;
          CommaText := ErrorListBox.Items[Index]; //grab all lines
          //DT_CALCRECT returns height without drawing text
          Height := DrawText(ErrorListBox.Canvas.Handle,
                                      PChar(Trim(Text)),  //each line of item
                                      -1,
                                      Rect,
                                      DT_WORDBREAK + DT_CALCRECT );
        finally
          Free;
        end;
      end;  //with temp stringlist
      Inc(Height);
    end;	//with ErrorListBox.Canvas
  except
    // Can't Raise an error here !
  end;
end;

procedure TErrorForm.FormResize(Sender: TObject);
var
  TopIndex : Integer;
begin
	If ErrorListBox.Style = lbOwnerDrawVariable then
  begin
    If ErrorListBox.Items.Count > 0 then
    begin
      TopIndex := ErrorListBox.TopIndex;
      ErrorListBox.Items.BeginUpdate;
      ErrorListBox.Items[0] := ErrorListBox.Items[0];
      ErrorListBox.TopIndex := TopIndex;
      ErrorListBox.Items.EndUpdate;
    end;
//  	RefreshLog;
  end;

end;

procedure TErrorForm.FormDestroy(Sender: TObject);
begin
	EventLog.Free;
end;

procedure TErrorForm.CopyButtonClick(Sender: TObject);
begin
  ErrorListBox.Items[ErrorListBox.ItemIndex];
  ClipBoard.SetTextBuf(PChar(ErrorListBox.Items[ErrorListBox.ItemIndex]));
end;


procedure TErrorForm.FileIsDropped ( var Msg : TWMDropFiles ) ;
var
  fName         : array[0..254] of char;
  fCounter      : integer;
  Names         : string;
  NumberOfFiles : Integer;
  Sl            : TStringList;
  Logfile       : TLogFile;
begin
  SL := TStringList.Create;
  try
    NumberOfFiles := DragQueryFile(Msg.Drop, $FFFFFFFF, NIL, 0) ;
    Names          := '' ;
    for fCounter   := 0 to NumberOfFiles-1 do
    begin
      DragQueryFile(Msg.Drop,fCounter,@fName,SizeOf(fName)-1);
      LogFile:=TLogFile.Create( StrPas(fName) ); // Create Error Log
      LogFile.ReadInToList(SL);
      LogFile.Free;
      PopulateListBox(SL);
    end;
    DragFinish ( Msg.Drop);
  finally
    SL.Free;
  end;
end;

end.


