unit TranslatorAU;

interface
uses
  Windows,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  TranslatorFU;
  
type
  TGPCSTranslate = class(TTranslate, ITranslate)
  public
    procedure Initialize; override;
    destructor Destroy; override;
    function Get_AvailableLanguages:WideString;                                   override;
    function Get_CurrentLanguage:WideString;                                      override;
    function Get_CurrentLanguageID:Integer;                                       override;
    function Get_DefaultLanguage:WideString;                                      override;
    function Get_DefaultLanguageID:Integer;                                       override;
    function Get_LanguageDataPath:WideString;                                     override;
    function Get_Modified:WordBool;                                               override;
    function Get_SaveOnAdd:WordBool;                                              override;
    function Get_SaveOnClose:WordBool;                                            override;
    function Translate(const Text:WideString):WideString;                               override;
    function TranslateCommaText(const Text,TransCols:WideString):WideString;            override;
    function TranslateFromTo(const Text,FromLanguage,ToLanguage:WideString):WideString; override;
    procedure Save;                                                               override;
    procedure Set_CurrentLanguage(const Value:WideString);                        override;
    procedure Set_CurrentLanguageID(Value:Integer);                               override;
    procedure Set_SaveOnAdd(Value:WordBool);                                      override;
    procedure Set_SaveOnClose(Value:WordBool);                                    override;
    function AccessFunction(const FunctionName, Value: WideString): WideString;   override;
  end;                  
  
implementation
uses
   ComServ2;

{TGPCSTranslate}
procedure TGPCSTranslate.Initialize;
begin
	 inherited Initialize;
end;                 
destructor TGPCSTranslate.Destroy;
begin
   inherited Destroy;
end;
function TGPCSTranslate.Get_AvailableLanguages:WideString;                                   
begin
   Result:=TransForm.LanguageList.CommaText;
end;
function TGPCSTranslate.Get_CurrentLanguage:WideString;                                      
begin
   Result:=TransForm.LanguageName;
end;              
function TGPCSTranslate.Get_CurrentLanguageID:Integer;                                       
begin
   Result:=TransForm.LanguageCode;
end;                             
function TGPCSTranslate.Get_DefaultLanguage:WideString;                                      
begin
   Result:=TransForm.DefaultLanguage.Name;
end;
function TGPCSTranslate.Get_DefaultLanguageID:Integer;                                       
begin
   Result:=TransForm.DefaultLanguage.Code;
end;
function TGPCSTranslate.Get_LanguageDataPath:WideString;                                     
begin
   Result:=TransForm.DefaultLanguage.Path;
end;
function TGPCSTranslate.Get_Modified:WordBool;                                               
begin
   Result:=TransForm.DefaultLanguage.Modified;
end;
function TGPCSTranslate.Get_SaveOnAdd:WordBool;                                              
begin
   Result:=TransForm.CurrentLanguage.SaveOnAdd;
end;
function TGPCSTranslate.Get_SaveOnClose:WordBool;                                            
begin
   Result:=TransForm.CurrentLanguage.SaveOnClose;
end;                                           
function TGPCSTranslate.Translate(const Text:WideString):WideString;
begin
   Result:=TransForm.CurrentLanguage.TranslateString(Text);
end;
function TGPCSTranslate.TranslateCommaText(const Text,TransCols:WideString):WideString;            
begin
   Result:=TransForm.CurrentLanguage.TranslateList(TransCols,Text);
end;
function TGPCSTranslate.TranslateFromTo(const Text,FromLanguage,ToLanguage:WideString):WideString; 
begin
end;
procedure TGPCSTranslate.Save;                                                               
begin
   TransForm.SaveAll;
end;
procedure TGPCSTranslate.Set_CurrentLanguage(const Value:WideString);
begin
   TransForm.LanguageName:=Value;
end;
procedure TGPCSTranslate.Set_CurrentLanguageID(Value:Integer);                               
begin
   TransForm.LanguageCode:=Value;
end;
procedure TGPCSTranslate.Set_SaveOnAdd(Value:WordBool);                                      
begin
   TransForm.SetSaveOnAdd(Value);
end;
procedure TGPCSTranslate.Set_SaveOnClose(Value:WordBool);
begin
   TransForm.SetSaveOnClose(Value);
end;
function TGPCSTranslate.AccessFunction(const FunctionName, Value: WideString): WideString; safecall;
begin

   if FunctionName='ReverseTranslate' then
   begin
      TransForm.CurrentLanguage.InvertTranslationOn;
      Result:=TransForm.CurrentLanguage.TranslateString(Value);
      TransForm.CurrentLanguage.InvertTranslationOff ;
   end;

end;

initialization
  TGPCSCompFactory.Create(ComServer,TGPCSTranslate,Class_GPCSTranslate,
                          'Support.Translate','GPCS Language Translator',
                          ciMultiInstance);
end.
