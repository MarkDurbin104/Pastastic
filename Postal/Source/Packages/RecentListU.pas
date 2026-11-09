unit RecentListU;

interface

uses
  Menus, Registry,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TRecentList = class(TComponent)
  private
    { Private declarations }
    FMenuItem     : TMenuItem;
    FNumberItems  : Integer;
    FOnRecentClick: TNotifyEvent;
    FShowOrder    : Boolean;
    RecentStringList    : TStringList;
    function RegistryKeyPath : String;
    procedure SaveToRegistry;
    procedure SetMenuItem(Value : TMenuItem);
    procedure UpdateMenu;

  protected
    { Protected declarations }
    procedure Loaded; override;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    procedure LoadFromRegistry;

  published
    { Published declarations }
    property NumberItems : Integer read FNumberItems write FNumberItems;
    property MenuItem : TMenuItem read FMenuItem write SetMenuItem;
    property OnRecentClick: TNotifyEvent read FOnRecentClick write FOnRecentClick;
    property ShowOrder : Boolean read FShowOrder write FShowOrder;

    procedure AddRecent(FileName : String);
  end;

procedure Register;

implementation

procedure TRecentList.AddRecent(FileName : String);
var
  RecentIndex : Integer;
begin
  //move if already in list
  RecentIndex := RecentStringList.IndexOf(FileName);
  If RecentIndex  >= 0 then  //found entry already in list
    RecentStringList.Move(RecentIndex, 1)  //move to after separator
  else
  begin
    //add separator
    If RecentStringList.Count = 0 then  //first recent entry
      RecentStringList.Insert(0, '-');
    RecentStringList.Insert(1, FileName); //insert new at top
  end;

  //delete extra (allowing for separator
  For RecentIndex := RecentStringList.Count -1 downto FNumberItems + 1 do
  begin
    RecentStringList.Objects[RecentIndex].Free;
    RecentStringList.Delete(RecentIndex);
  end;

  UpdateMenu;
  SaveToRegistry;
end;

constructor TRecentList.Create(AOwner :TComponent);
begin
  Inherited;
  RecentStringList := TStringList.Create;

end;


procedure TRecentList.Loaded;
begin
  LoadFromRegistry;
end;

procedure TRecentList.LoadFromRegistry;
var
  FoundEntry : Boolean;
  RecentIndex : Integer;
  Registry : TRegistry;
begin
  Registry := TRegistry.Create;
  try
    FoundEntry := False;
    with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      if OpenKey(RegistryKeyPath, False) then
      begin
        For RecentIndex := 1 to FNumberItems do
        begin
          if ValueExists('Recent File ' + IntToStr(RecentIndex)) then
          begin
            If not FoundEntry then  //first entry
            begin
              RecentStringList.Add('-');
              FoundEntry := True;
            end;
            //add each recent entry
            RecentStringList.Add(ReadString('Recent File ' + IntToStr(RecentIndex)));
          end;
        end;
      end;
    end;
    UpdateMenu;
  finally
    Registry.Free;
  end;
end;


procedure TRecentList.SaveToRegistry;
var
  KeyName : String;
  RecentIndex : Integer;
  Registry    : TRegistry;
begin

  If (FMenuItem = nil) or (FNumberItems <1) then Exit;

  Registry := TRegistry.Create;
  try
    with Registry do
    begin
      KeyName := RegistryKeyPath;
      RootKey:=HKEY_CURRENT_USER;
      Registry.DeleteKey(KeyName);
      if OpenKey(KeyName, True) then
      begin

        //write then delete recent entries
        For RecentIndex := 1 to RecentStringList.Count -1 do
          Registry.WriteString('Recent File ' + IntToStr(RecentIndex), RecentStringList.Strings[RecentIndex]);
      end;  //opened registry key
    end;
  finally
    Registry.Free;
  end;
end;

procedure TRecentList.SetMenuItem(Value : TMenuItem);
var
  RecentIndex : Integer;
begin
  If FMenuItem <> Value then  //new menu
  begin //delete from old menu
    If Value <> nil then  //menu attached
    begin
      For RecentIndex := 0 to RecentStringList.Count -1 do
      begin
        If FMenuItem <> nil then
          RecentStringList.Objects[RecentIndex].Free; //free from old menu
      end;
    end;
    FMenuItem := Value;
    UpdateMenu;
  end;
end;

function TRecentList.RegistryKeyPath : String;
begin
  Result := '';
  If (Owner <> nil) and (FMenuItem <> nil) then
  begin
    Result := '\SOFTWARE\Ash\Recent List'
              + '\' + Application.Title
              + '\' + Owner.Name
              + '\' + FMenuItem.Name;
  end;
end;

procedure TRecentList.UpdateMenu;
var
  NewMenuItem : TMenuItem;
  RecentIndex : Integer;
begin
  If (FMenuItem = nil) then Exit;

  //remove old entries from menu
  For RecentIndex := 0 to RecentStringList.Count -1 do
  begin
    RecentStringList.Objects[RecentIndex].Free;
  end;

  //add each menu item
  For RecentIndex := 0 to RecentStringList.Count -1 do
  begin
    //add each recent entry
    NewMenuItem := TMenuItem.Create(self);
    NewMenuItem.Caption := RecentStringList.Strings[RecentIndex];
    NewMenuItem.OnClick := FOnRecentClick;
    FMenuItem.Add(NewMenuItem);
    //reference menu item
    RecentStringList.Objects[RecentIndex] := NewMenuItem;
  end;
end;

procedure Register;
begin
  RegisterComponents('P.S.L.', [TRecentList]);
end;

end.
