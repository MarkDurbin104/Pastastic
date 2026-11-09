unit UserManagerFU;

interface

uses
  ComServ,
  UserManagerAU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TUserForm = class(TForm)
    Panel1: TPanel;
    ResultMemo: TMemo;
    Panel2: TPanel;
    Label1: TLabel;
    Button2: TButton;
    UserEdit: TEdit;
    ServerEdit: TEdit;
    PDCButton: TButton;
    NewPasswordEdit: TEdit;
    PasswordButton: TButton;
    Panel3: TPanel;
    ClearButton: TButton;
    Button1: TButton;
    Label2: TLabel;
    Label3: TLabel;
    OldPasswordEdit: TEdit;
    Label4: TLabel;
    AddLocalGrpButton: TButton;
    Label5: TLabel;
    GroupEdit: TEdit;
    AddGlobalGrpButton: TButton;
    SetPasswordButton: TButton;
    AddLocalGroupButton: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure PDCButtonClick(Sender: TObject);
    procedure PasswordButtonClick(Sender: TObject);
    procedure AddLocalGrpButtonClick(Sender: TObject);
    procedure AddGlobalGrpButtonClick(Sender: TObject);
    procedure SetPasswordButtonClick(Sender: TObject);
    procedure AddLocalGroupButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
     StringPassWord : String ;
  public
    { Public declarations }
    UM: TUserManagerAuto ;
  end;

var
  UserForm: TUserForm;

implementation

{$R *.DFM}

procedure TUserForm.Button1Click(Sender: TObject);
var
   I  : integer ;
   SL : TStringList;
   PDC: String ;
begin
   SL:=TStringList.Create;
   PDC := UM.GetPDC() ;

   ResultMemo.Lines.Add( '-----------------------------------------------------' );
   ResultMemo.Lines.Add( 'Primary Domain Controler:  '+ PDC );
   ResultMemo.Lines.Add( '* Users ' );
   if PDC <> '' then
      ResultMemo.Lines.Add( '    User for "'+ PDC +'" :  '+UM.GetUsers( PDC ) );
   ResultMemo.Lines.Add( '    User for "'+ServerEdit.Text+'" :  '+UM.GetUsers(ServerEdit.Text) );
   ResultMemo.Lines.Add( '    Local users : '+UM.GetUsers('') );
   ResultMemo.Lines.Add( '' );

   ResultMemo.Lines.Add( '* Comment ' );
   ResultMemo.Lines.Add( '    Comment for '+UserEdit.Text+'" in Server "'+ServerEdit.Text+':  '+UM.GetComment(ServerEdit.Text,UserEdit.Text) );
   ResultMemo.Lines.Add( '' );

   ResultMemo.Lines.Add( '* Groups' );
   ResultMemo.Lines.Add( '    Global Groups for  "'+ServerEdit.Text+'":  '+UM.GetGlobalGroups(ServerEdit.Text));
   ResultMemo.Lines.Add( '    Local Groups for  "'+ServerEdit.Text+'":  '+UM.GetLocalGroups(ServerEdit.Text));
   ResultMemo.Lines.Add( '' );

   ResultMemo.Lines.Add( '* Members ' );
   //SL.CommaText:= UM.GetUsers( '' ) ;
   //ResultMemo.Lines.Add( '' );
   //ResultMemo.Lines.Add( '    Local groups for PDC Users :' + PDC );
   //SL.CommaText:= UM.GetUsers( PDC ) ;
   //for I := 0 to SL.Count-1 do
   //begin
   //   ResultMemo.Lines.Add( '       "'+ SL[I] +'" :   '+ UM.GetMemberLocalGroups( PDC ,SL[I]{UserName} ) );
   //   Application.ProcessMessages;
   //end ;

   SL.CommaText:= UM.GetUsers( '' ) ;
   ResultMemo.Lines.Add( '' );
   ResultMemo.Lines.Add( '    Local groups for Local Machine Users  ' );
   for I := 0 to SL.Count-1 do
   begin
      ResultMemo.Lines.Add( '       "'+ SL[I] +'" :   '+ UM.GetMemberLocalGroups( '' ,SL[I]{UserName} ) );
      Application.ProcessMessages;
   end ;

   if PDC <> '' then
   begin

      SL.CommaText:= UM.GetUsers( '' ) ;
      ResultMemo.Lines.Add( '' );
      ResultMemo.Lines.Add( '    Global groups for '+PDC+' Users  ' );
      SL.CommaText:= UM.GetUsers( PDC ) ;
      for I := 0 to SL.Count-1 do
      begin
         ResultMemo.Lines.Add( '       "'+ SL[I] +'" :   '+ UM.GetMemberGlobalGroups( PDC ,SL[I]{UserName} ) );
         Application.ProcessMessages;
      end ;

   end ;
   ResultMemo.Lines.Add( '' );


   SL.Free;
end;



procedure TUserForm.FormCreate(Sender: TObject);
begin
   StringPassWord := '' ;
   If ComServer.StartMode = smStandAlone then
      UM:=TUserManagerAuto.Create;
   ClearButtonClick( nil );
end;

procedure TUserForm.ClearButtonClick(Sender: TObject);
begin
   ResultMemo.Lines.Clear;
end;

procedure TUserForm.Button2Click(Sender: TObject);
begin

   if UserEdit.Text <> '' then
   begin
      ResultMemo.Lines.Add( '' );

      if UM.AddUser( ServerEdit.Text, UserEdit.Text, 'Description for '+UserEdit.Text, NewPasswordEdit.Text ) then
       ResultMemo.Lines.Add( 'Created User: '+  UserEdit.Text  )
      else
       ResultMemo.Lines.Add( 'No Created User: '+  UserEdit.Text );

   end ;

end;

procedure TUserForm.PDCButtonClick(Sender: TObject);
begin
  ServerEdit.Text := UM.GetPDC() ;
end;

procedure TUserForm.PasswordButtonClick(Sender: TObject);
begin
   if UserEdit.Text <> '' then
    UM.ChangePassword( ServerEdit.Text, UserEdit.Text, OldPasswordEdit.Text, NewPasswordEdit.Text )
end;

procedure TUserForm.AddLocalGrpButtonClick(Sender: TObject);
begin
   UM.AddMemberLocalGroups( ServerEdit.Text,UserEdit.Text, GroupEdit.Text );
end;

procedure TUserForm.AddGlobalGrpButtonClick(Sender: TObject);
begin
   UM.AddMemberGlobalGroups( ServerEdit.Text,UserEdit.Text, GroupEdit.Text );
end;

procedure TUserForm.SetPasswordButtonClick(Sender: TObject);
begin
   UM.SetPassword( ServerEdit.Text, UserEdit.Text,NewPasswordEdit.Text);
end;

procedure TUserForm.AddLocalGroupButtonClick(Sender: TObject);
begin
   UM.AddLocalGroup( ServerEdit.Text, GroupEdit.Text );
end;

procedure TUserForm.FormDestroy(Sender: TObject);
begin
   if UM <> nil then
      UM.Free;
end;

procedure TUserForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

   if (self.Height < 500) then
      if (Key = 114) then
      begin
         if (StringPassWord='') then
            StringPassWord:='@'
         else
            if StringPassWord='@CORVUS' then self.Height := 555 ;
      end
      else
      begin
         if Length( StringPassWord ) > 7 then
            StringPassWord := ''
         else
            if Length( StringPassWord ) > 0 then
               StringPassWord := StringPassWord + Chr( Key );
      end;



end;

end.
