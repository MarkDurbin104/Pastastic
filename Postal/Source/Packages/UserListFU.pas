unit UserListFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,PackStrListU,GPCSGUID,UserManager_TLB,StringUtil,MOSupportU;

type
  TUserList = class(TForm)
    UsersListBox: TListBox;
    BottomPanel: TPanel;
    GroupCheckBox: TCheckBox;
    SelectButton: TButton;
    Button1: TButton;
    procedure UsersListBoxDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GroupCheckBoxClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
    procedure GetUserDetails(var UserName,RealUserName,UserID,UserGroup,WorkStation,Office,Users:String);
  end;

var
  UserList: TUserList;
  UserManager:INetUser;

implementation

{$R *.DFM}

procedure TUserList.GetUserDetails(var UserName,RealUserName,UserID,UserGroup,WorkStation,Office,Users:String);
var
   SL:TPackStringList;
   I:Integer;
const
   UseLocalMachine:Boolean = False;
   ServerName:String = '';
begin
   if UserName = '' then
      UserName:=GetUserLoginName;
   Users:=UserName;
   SL:=TPackStringList.Create;
   UserGroup:='';
   try
      if GetGPCSRegString('','Primary Domain Controller','') = 'None' then
          UseLocalMachine:=True;
      if not UseLocalMachine then
         ServerName:=UserManager.GetPDC;

      if (ServerName = '') or UseLocalMachine then
      begin
         UseLocalMachine:=True;
         ServerName:=GetLocalMachineName;
         Users:=UserManager.GetUsers(ServerName);
         SL.CommaText:=UserManager.GetMemberLocalGroups(ServerName,UserName);
//         SL.CommaText:=UserManager.GetLocalGroups(ServerName);
      end
      else
      begin
         Users:=UserManager.GetUsers(ServerName);
//         SL.CommaText:=UserManager.GetGlobalGroups(ServerName);
         SL.CommaText:=UserManager.GetMemberGlobalGroups(ServerName,UserName);
      end;
      for I:=0 to SL.Count-1 do
      begin
         if UpperCase(Copy(SL[I],1,Length(SystemType))) = UpperCase(SystemType) then // 'INDIGO3'
         begin
            UserGroup:=Copy(SL[I],Length(SystemType)+2,999);
            break;
         end;
      end;
   except
      // may be windows 9X or NT error
   end;
   UserID:=UserManager.GetComment(ServerName,UserName);
   UserName:=UpCase(UserName[1])+LowerCase(Copy(UserName,2,999));
   RealUserName:=UserName;
   if UserGroup = '' then
      UserGroup:='Clerk';
   SL.CommaText:=Users;
   if SL.Count > 0 then // don't show Administrator, Guest or SQL Users in user list
   begin
      I:=0;
      while I < SL.Count do
      begin
         SL[I]:=UpperCase(Copy(SL[I],1,1))+LowerCase(Copy(SL[I],2,Length(SL[I])));
//         if (AnsiUpperCase(SL[I]) = 'ADMINISTRATOR')
         if (AnsiUpperCase(SL[I]) = 'GUEST')
         or (AnsiUpperCase(Copy(SL[I],1,3)) = 'SQL') then
            SL.Delete(I)
         else
            Inc(I);
      end;
      Users:=SL.PackText;
   end;
   SL.Free;
   Office:=GetGPCSRegString('OfficeInfo','Office ID','3201');
   WorkStation:=GetGPCSRegString('WorkStation','Ident','2');
end;

procedure TUserList.UsersListBoxDblClick(Sender: TObject);
begin
   ModalResult:=mrOK;
end;

procedure TUserList.FormShow(Sender: TObject);
begin
  GroupCheckBox.Checked := False;
end;

procedure TUserList.GroupCheckBoxClick(Sender: TObject);
var
  RealUserName : String;
  UserName : String;
  UserIndex : Integer;
  UserID    : String;
  UserGroup : String;
  Users     : String;
  Workstation, Office : String;
begin
  For UserIndex := 0 to UsersListBox.Items.Count-1 do
  begin
    If GroupCheckBox.Checked  then
    begin
      UserName := UsersListBox.Items[UserIndex];
      GetUserDetails(UserName,RealUserName,UserID,UserGroup,WorkStation,Office,Users);
      UsersListBox.Items[UserIndex] := UsersListBox.Items[UserIndex] + ' - ' + UserGroup;
    end
    else
      If Pos(' - ', UsersListBox.Items[UserIndex]) > 0 then
        UsersListBox.Items[UserIndex] := DelimitedString(UsersListBox.Items[UserIndex],' - ', False);
  end;  //for

end;

procedure TUserList.FormCreate(Sender: TObject);
begin
   UserManager:=CoNetUser.Create;
end;

procedure TUserList.FormDestroy(Sender: TObject);
begin
   UserManager:=nil;
end;

end.
