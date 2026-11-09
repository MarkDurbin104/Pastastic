{  Module          Corvus Error Handler
   Unit            Automation
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     Display and log errors form the rest of the Corvus system.
   Modifications   19/03/98 - MJD
                              Original Release
   									27/03/00 - ASH
                    					RaiseGUIDError, RaiseGUIDException added
                    30/03/00 - ASH
                    					Registry reads for Logfile, Visible and NTEventLog

}
unit ErrorHAU;

interface

uses
  Forms,
  Dialogs,
   //	GetMACAddrU, //MainMAC,
  Windows,SysUtils,ComObj,Classes, ActiveX, GPCSBase_TLB,GPCSBaseAU,GPCSGUID,ErrorHFU, LogFileU, Registry;

type
  TErrorHandler = class(TGPCSBaseComponent, IErrorHandler)
  private
    FVisible:Boolean;
    LogFile:TLogFile;
  public
    procedure Initialize; override;
    destructor Destroy; override;
  protected
    procedure RaiseError(ErrorPlaceCode, ErrorTypeCode, ErrorPriority: Integer;
      const ErrorData: WideString); safecall;
    function Get_LogFile: WideString; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_LogFile(const Value: WideString); safecall;
    procedure Set_Visible(Value: WordBool); safecall;
  end;

implementation

uses ComServ2;

{===============================================================================
  Class        TErrorHandler
  Method       Initialize
  Description  Setup base parameters
  Params       None
  Result       None
________________________________________________________________________________}
procedure TErrorHandler.Initialize;
begin
   try
      inherited Initialize;
      FVisible:=False;                            // default to hidden
      LogFile:=TLogFile.Create( GetGPCSRegString('ErrorManager','LogFile','C:\GPCSErr.Log')); // Create Error Log
      FVisible := ('0' <> GetGPCSRegString('ErrorManager','Visible','0'));
   except  
      // Can't Raise an error here !
   end;
end;
{===============================================================================
  Class        TErrorHandler
  Method       Destroy
  Description  Free Logfile
  Params       None
  Result       None
________________________________________________________________________________}
destructor TErrorHandler.Destroy;
begin
   try
      LogFile.Free;
   except
      // Can't Raise an error here !
   end;
   inherited Destroy;
end;
{===============================================================================
  Class        TErrorHandler
  Method       RaiseError
  Description  The main entry point in the error handler
               calling this function logs and optionally displays an error
  Params       ErrorPlaceCode : where the error originated
               ErrorTypeCode  : the type of error e.g. 'File not found' etc.
               ErrorPriority  : the Priority i.e. information, Warning etc.
               ErrorData      : any relevant data
  Result       None
________________________________________________________________________________}
procedure TErrorHandler.RaiseError(ErrorPlaceCode, ErrorTypeCode,
  ErrorPriority: Integer; const ErrorData: WideString);
var
	FullErrorData : WideString;
  ErrorDataSL : TStringList;
  Component:Byte;
  CompClass:Byte;
  Method   :Byte;
  ErrNo    :Byte;
begin
   try
      //add MACAddress to Error Data
      ErrorDataSL := TStringList.Create;
      try
      //  ErrorDataSL.Text := '{' + GetMACAddr + '}-' + ErrorData;
        ErrorDataSL.Text := '{No MAC Addr}-' + ErrorData;
        FullErrorData := ErrorDataSL.CommaText;
      finally
        ErrorDataSL.Free;
      end;

      // log to file
      LogFile.Add(IntToHex(ErrorPlaceCode,8)+
                  IntToHex((ErrorPriority shl 28) or ErrorTypeCode,8)+
                  FullErrorData);

      //log to NTEvent log
      if GetGPCSRegString('ErrorManager','NTEventLog','0') <> '0' then
      begin
				ErrorForm.EventLog.EventID 				:= ErrorPlaceCode;
      	ErrorForm.EventLog.EventCategory 	:= ErrorPriority;
      	ErrorForm.EventLog.LogEvent(FullErrorData);
      end;

      // separate the code into component parts
      Component:=$FF and (ErrorPlaceCode shr 24);
      CompClass:=$FF and (ErrorPlaceCode shr 16);
      Method   :=$FF and (ErrorPlaceCode shr  8);
      ErrNo    :=$FF and (ErrorPlaceCode       );

      // if we are displaying errors to the user then
      if FVisible then
      begin
         ErrorForm.EModule.Text  :=ErrorForm.FromAsString(Component,CompClass,Method)+' Error:'+IntToHex(ErrNo,2);
         ErrorForm.EType.Text    :=ErrorForm.ErrorMessage(ErrorTypeCode);
         ErrorForm.EPriority.Text:=ErrorForm.PriAsString(ErrorPriority);
         ErrorForm.EData.Text    :=FullErrorData;
         ErrorForm.ShowModal;
      end
      else if (ErrorForm <> nil) and (ErrorForm.Visible) then
      begin
         ErrorForm.RefreshLog;
         If ErrorForm.WindowState = wsMinimized then
          ErrorForm.WindowState := wsNormal;
      end;

      If (ErrorForm.Visible) then
      begin
        ErrorForm.WindowState := wsMinimized; 
        ErrorForm.WindowState := wsNormal;
      end;

   except
      // Can't Raise an error here !
   end;
end;
{===============================================================================
  Class        TErrorHandler
  Method       Get_LogFile
  Description  get the current log file
  Params       None
  Result       a string containing the current log file
________________________________________________________________________________}
function TErrorHandler.Get_LogFile: WideString;
begin
   try 
      Result:=LogFile.FileName;
   except
      // Can't Raise an error here !
   end;
end;
{===============================================================================
  Class        TErrorHandler
  Method       Get_Visible
  Description  Get the current visible state
  Params       None
  Result       the current visible state
________________________________________________________________________________}
function TErrorHandler.Get_Visible: WordBool;
begin
   try
      Result:=FVisible;
   except
      // Can't Raise an error here !
   end;
end;
{===============================================================================
  Class        TErrorHandler
  Method       Set_LogFile
  Description  Set the current log file
  Params       Value:
  Result       None
________________________________________________________________________________}
procedure TErrorHandler.Set_LogFile(const Value: WideString);
begin
   try 
      LogFile.FileName:=Value;
   except
      // Can't Raise an error here !
   end;
end;  
{===============================================================================
  Class        TErrorHandler
  Method       Set_Visible
  Description  Set the current visible state
  Params       Value:
  Result       None
________________________________________________________________________________}
procedure TErrorHandler.Set_Visible(Value: WordBool);
begin
   try
      FVisible:=Value;
   except
      // Can't Raise an error here !
   end;
end;

initialization
  TGPCSCompFactory.Create(ComServer,TErrorHandler,
                          Class_GPCSErrorHandler,
                          'Support.ErrorHandler','GPCS Error Handler',ciMultiInstance);
end.
