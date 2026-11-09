{  Module          Corvus Error Handler
   Unit            Error Messages
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     List of all Error Messages
   Modifications   19/03/98 - MJD
                              Original Release
}
unit GPCSErrorLine;

interface

uses
  ActiveX,Classes,SysUtils,ComObj,GPCSGUID,ExcMagic;

const

// ============================= Error Priorities ==============================
    EP_Severe        =0;
    EP_UnRecoverable =1;
    EP_Recoverable   =2;
    EP_Warning       =3;
    EP_Information   =4;

// ========================= Error Priority Messages ===========================
    EPM_Severe        ='Severe Error !! The system may now be unstable';
    EPM_UnRecoverable ='Un-Recoverable Error';
    EPM_Recoverable   ='Recoverable Error';
    EPM_Warning       ='Warning';
    EPM_Information   ='Information';

// =========================== Error Type Messages =============================
    EMessageCount = 5;
    EMessages :array[0..EMessageCount] of String =(
       'Drastic Failure',          // Error Code = 0
       'File Not Found',           // Error Code = 1
       'Error Loading Component',  // Error Code = 2
       'Index Out Of Bounds',      // Error Code = 3
       'Exception',                // Error Code = 4

       'Array Over Run' // included to make adding lines easy i.e. don't worry about last comma
    );

// =============================== Error Types =================================
    ET_DrasticFailure        = 0;
    ET_FileNotFound          = 1;
    ET_ErrorLoadingComponent = 2;
    ET_IndexOutOfBounds      = 3;
    ET_Exception             = 4;
type
   TErrorHandler = Class(TObject)
   public
     constructor Create;
     destructor Destroy; override;
     procedure ShowException(Title,ExceptionMessage:String;CallStack,Registers,CustomInfo:TStringList);
   end;

procedure RaiseError(ECode,EType,EPriority:Integer;EInfo:String);
procedure RaiseException(ECode:Integer;E:Exception);
procedure RaiseGUIDError(GUID : String; EInfo:String);
procedure RaiseGUIDException(GUID : String; E:Exception);

var
  ErrorHandler:TErrorHandler;
  
implementation

uses
   GPCSBase_TLB;

constructor TErrorHandler.Create;
begin
   inherited Create;
{$ifndef DONTUSEEXMAGIC}
   ExceptionHook.OnExceptionShow:=ShowException;
{$endif} // ndef DONTUSEEXMAGIC
end;
destructor TErrorHandler.Destroy;
begin
{$ifndef DONTUSEEXMAGIC}
   ExceptionHook.OnExceptionShow:=nil;
{$endif} // ndef DONTUSEEXMAGIC
   inherited Destroy;
end;
procedure TErrorHandler.ShowException(Title,ExceptionMessage:String;CallStack,Registers,CustomInfo:TStringList);
begin
   RaiseGUIDError('{854CF4C2-BCB9-4516-A27B-C61AF40EFC00}',
                  Title+' - '+ExceptionMessage+' - '+CallStack.CommaText);
end; 

{===============================================================================
  procedure    RaiseError
  Description  Call the Corvus Error handler
  Params       ECode     : The Error Origin Code
               EType     : The Error Type Code
               EPriority : The Error Priority Code
               EInfo     : The Error Information Text
________________________________________________________________________________}
procedure RaiseError(ECode,EType,EPriority:Integer;EInfo:String);
var
   FErrorHandler:IErrorHandler;
begin
   CoInitialize(nil);
   try
      FErrorHandler:=CreateErrorHandler;                     // create instance
      FErrorHandler.RaiseError(ECode,EType,EPriority,EInfo); // raise error
      FErrorHandler:=nil;                                    // release instance
   except
   end;
   CoUnInitialize;
end;

{function ExpandDBEngineErrorText(E : Exception)  :WideString;
var
  ErrorIndex : Integer;
begin
  If (E is EDBEngineError) then
  begin
    For ErrorIndex := 0 to (E as EDBEngineError).ErrorCount -1 do
      Result := Result + ' - ' + (E as EDBEngineError).Errors[ErrorIndex].Message;
  end
  else
    Result := E.Message;
end;
}


procedure RaiseException(ECode:Integer;E:Exception);
var
   FErrorHandler:IErrorHandler;
begin
   TDSAppShowException(E);
   CoInitialize(nil);         
   try
      FErrorHandler:=CreateErrorHandler;                                     // create instance
      FErrorHandler.RaiseError(ECode,ET_Exception,EP_Recoverable,{ExpandDBEngineErrorText(}E.Message); // raise error
      FErrorHandler:=nil;                                                    // release instance
   except
   end;
   CoUnInitialize;
end;        

procedure RaiseGUIDError(GUID : String; EInfo:String);
var
   FErrorHandler:IErrorHandler;
begin
   CoInitialize(nil);
   try
      FErrorHandler:=CreateErrorHandler;                     					// create instance
      FErrorHandler.RaiseError($FF, $FF, $FF ,GUID + '-' + EInfo); 	// raise error
      FErrorHandler:=nil;                                    					// release instance
   except
   end;
   CoUnInitialize;
end;        

procedure RaiseGUIDException(GUID : String; E:Exception);
var
   FErrorHandler:IErrorHandler;
begin
   TDSAppShowException(E);
   CoInitialize(nil);
   try
      FErrorHandler:=CreateErrorHandler;                                   // create instance
      FErrorHandler.RaiseError($FF, $FF, $FF ,GUID + '-' + {ExpandDBEngineErrorText}E.Message); 	// raise exception
      FErrorHandler:=nil;                                                  // release instance
   except
   end;
   CoUnInitialize;
end;        

initialization
  if ErrorHandler = nil then
     ErrorHandler:=TErrorHandler.Create;
     
finalization
  if ErrorHandler <> nil then
  begin
     ErrorHandler.Free;
     ErrorHandler:=nil;
  end;
    

end.
