unit RegistryEx;


interface

uses
	StringUtil,
  Windows,
  SysUtils,
  Classes,Registry;

  function DeleteKeyTree(KeyPath: string): Boolean;
  //deletes key and all sub keys/values (works on NT)

  function GetRegistryValues(const RegistryPath : String; ValueNames : TStringList; ValueValues : Variant) : Boolean;
  //returns list of value names and values

	function GetRootKey(KeyPath : String) : DWord; // Cardinal;
  //returns root key value from short/long key path

  function ReadRegistryValue(const RegistryPath : String) : Variant;
  //returns value at registry key

  function WriteRegistryValue(const RegistryPath : String; Value : Variant) : Boolean;
  //writes value to registry key

  function ReadRegistryStringValue(const RegistryPath : String) : String;
  //returns string value at registry key


implementation

function DeleteKeyTree(KeyPath: string): Boolean;
//deletes key and all sub keys/values (works on NT)
var
  Index 				: Integer;
  Registry 			: TRegistry;
  RootKeyString : String;
  SubKeys 			: TStringList;
  ValueNames  	: TStringList;

begin
  Result := False;
  Registry := TRegistry.Create;
  SubKeys := TStringList.Create;
  ValueNames := TStringList.Create;
  try
    With Registry do
    begin
			//open root and key
      RootKey := GetRootKey(KeyPath);
      RootKeyString := DelimitedString(KeyPath,'\', False);
      KeyPath := DelimitedString(KeyPath,'\',True);
      If OpenKey(KeyPath,False) then
      begin

        //delete subkeys
        GetKeyNames(SubKeys);
        CloseKey;
        for Index  :=  0 to  SubKeys.Count-1 do
        begin
          DeleteKeyTree(RootKeyString + '\' +KeyPath + '\' + SubKeys[Index]);
        end;

        //delete values
//        GetValueNames(ValueNames);
//        for Index := 0 to ValueNames.Count -1 do
//        begin
//          DeleteValue(ValueNames[Index]);
//        end;

        //delete the actual key
//        If OpenKey(LeftString(KeyPath, PosOccurrence('\', KeyPath, CountStr('\', KeyPath))-1),False) then
//          DeleteKey(ReverseDelimitedString(KeyPath, '\', True));
        Result := DeleteKey(KeyPath);
      end;  //opened original key
    end;  //with registry
  finally
    Registry.Free;
    SubKeys.Free;
    ValueNames.Free;
  end;
end;

function GetRegistryValues(const RegistryPath : String; ValueNames : TStringList; ValueValues : Variant) : Boolean;
//returns list of value names
var
  RegPath     : String; //validated registry path
  ValueIndex  : Integer;
  KeyPath     : String;
begin
  Result    := False;
  If Copy(RegistryPath,Length(RegistryPath),1) <> '\' then
    RegPath := RegistryPath + '\';
  With TRegistry.Create do
  begin
    try
      RootKey := GetRootKey(RegistryPath);
      KeyPath := DelimitedString(RegistryPath,'\',True);

      If OpenKey(KeyPath, False) then
      begin
        GetValueNames(ValueNames);
        VarArrayRedim(ValueValues, ValueNames.Count);
        For ValueIndex :=  0 to ValueNames.Count -1 do
        begin
          ValueValues[ValueIndex] :=
            ReadRegistryValue(RegPath + ValueNames[ValueIndex]);
        end;
      end;
    finally
      Free;
    end;
  end;
end;

function GetRootKey(KeyPath : String) : DWord;
//returns root key value from short/long key path
var                                        
	RootKey : String;
begin
	RootKey := UpperCase(DelimitedString(KeyPath,'\', False));
        If (RootKey = 'HKEY_LOCAL_MACHINE')		or (RootKey = 'HKLM') then Result := HKEY_LOCAL_MACHINE
  else  If (RootKey = 'HKEY_CLASSES_ROOT') 	  or (RootKey = 'HKCR') then Result := HKEY_CLASSES_ROOT
  else  If (RootKey = 'HKEY_CURRENT_USER') 	  or (RootKey = 'HKCU') then Result := HKEY_CURRENT_USER
  else  If (RootKey = 'HKEY_USERS') 					or (RootKey = 'HKUS') then Result := HKEY_USERS
  else  If (RootKey = 'HKEY_CURRENT_CONFIG')	or (RootKey = 'HKCC') then Result := HKEY_CURRENT_CONFIG
  else  If (RootKey = 'HKEY_DYN_DATA')				or (RootKey = 'HKDD') then Result := HKEY_DYN_DATA
	else	Result := 0;
end;

{function MoveKeyTree(FromKeyPath, ToKeyPath: string): Boolean;
//moves key and all sub keys/values to new path(works on NT)
var
  Index 															: Integer;
  Registry 														: TRegistry;
  FromRootKeyString, ToRootKeyString 	: String;
  SubKeys 														: TStringList;
  ValueNames  												: TStringList;

begin
  Registry := TRegistry.Create;
  SubKeys := TStringList.Create;
  ValueNames := TStringList.Create;
  try
    With Registry do
    begin
			//open from root and key
      RootKey 					:= GetRootKey(FromKeyPath);
      FromRootKeyString := DelimitedString(FromKeyPath,'\', False);
      ToRootKeyString		:= DelimitedString(ToKeyPath,'\',False);
      FromKeyPath       := DelimitedString(FromKeyPath,'\',True);
      ToKeyPath         := DelimitedString(ToKeyPath,'\',True);
      OpenKey(KeyPath,False);

      //move subkeys
      GetKeyNames(SubKeys);
      for Index  :=  0 to  SubKeys.Count-1 do
      begin
        MoveKeyTree(FromRootKeyString + '\' + FromKeyPath + '\' + SubKeys[Index],
        						ToRootKeyString   + '\' + ToKeyPath + '\' + SubKeys[Index]);
      end;

      //move the actual key
      OpenKey('\' + DelimitedString(KeyPath,'\',False),False);	//parent of key to move
      MoveKey(DelimitedString(KeyPath,'\',True), ToRootKeyString + '\' + );

    end;
    Result := True;
  finally
    Registry.Free;
    SubKeys.Free;
    ValueNames.Free;
  end;
end;
}


function ReadRegistryStringValue(const RegistryPath : String) : String;
//reads value to registry key
var
  KeyPath : String;
  ValueName : String;
begin
  Result    := '';
  With TRegistry.Create do
  begin
  	try
      RootKey   := GetRootKey(RegistryPath);
      KeyPath   := ExtractFilePath(RegistryPath);
      KeyPath   := DelimitedString(KeyPath,'\',True); //remove root key portion
      ValueName := ExtractFileName(RegistryPath);

      If OpenKey(KeyPath, False) then
      	if ValueExists(ValueName) then
          Result := ReadString(ValueName);
    finally
			Free;
    end;
  end;  //with TRegistry
end;

function ReadRegistryValue(const RegistryPath : String) : Variant;
//reads value to registry key
var
  KeyPath : String;
  ValueName : String;
begin
  Result    := Null;
  With TRegistry.Create do
  begin
    RootKey   := GetRootKey(RegistryPath);
    KeyPath   := ExtractFilePath(RegistryPath);
    KeyPath   := DelimitedString(KeyPath,'\',True);
    ValueName := ExtractFileName(RegistryPath);

    If OpenKey(KeyPath, False) then
    begin
      If ValueExists(ValueName) then
      begin
        Case GetDataType(ValueName) of
          rdString    : Result := ReadString(ValueName);
          rdInteger   : Result := ReadInteger(ValueName);
          rdBinary    : ReadBinaryData(ValueName, Result, GetDataSize(ValueName));
          else Result := Null;
        end;  //case
      end;  //if ValueExists
    end;  //if OpenKey
  end;  //with TRegistry
end;

function WriteRegistryValue(const RegistryPath : String; Value : Variant) : Boolean;
//writes value to registry key
var
  KeyPath : String;
  ValueName : String;
begin
  Result    := False;
  With TRegistry.Create do
  begin
    try
      RootKey   := GetRootKey(RegistryPath);
      KeyPath   := ExtractFilePath(RegistryPath);
      KeyPath   := DelimitedString(KeyPath,'\',True); //remove root key portion
      ValueName := ExtractFileName(RegistryPath);

      If OpenKey(KeyPath, True) then
      begin
        Case VarType(Value) of
          VarSmallint, varInteger           : WriteInteger(ValueName,Value);
          varSingle, varDouble, varCurrency : WriteFloat(ValueName, Value);
          varDate                           : WriteDate(ValueName, Value);
          varString, varOLEStr              : WriteString(ValueName, Value);
          varBoolean                        : WriteBool(ValueName, Value);

          varEmpty,                         //Unassigned
          varNull,                          //Null
          varDispatch, 	                    //Reference to an OLE automation object (an IDispatch interface pointer).
          varError,	                        //Operating system error code.
          varUnknown :	                    //Reference to an unknown OLE object (an IUnknown interface pointer).
            Result := False;
        end;  //case
      end;  //if openkey
    finally
      Free;
    end;
  end;  //with TRegistry
end;

end.
