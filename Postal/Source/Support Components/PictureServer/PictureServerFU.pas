unit PictureServerFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtDlgs, ExtCtrls, Mask, Domain, Db, DBTables, GPCSGUID,
  Bin2String,CompressU,StretchU;

type
  TPString = class(TObject)
     FValue:String;
  public
     property Value:String read FValue write FValue;
  end;
  TForm1 = class(TForm)
    Pictures: TListBox;       
    Panel2: TPanel;
    Panel1: TPanel;
    Panel3: TPanel;
    OpenPictureDialog: TOpenPictureDialog;
    Panel4: TPanel;
    Button3: TButton;
    Panel5: TPanel;
    Button1: TButton;
    RemoveButton: TButton;
    Image1: TImage;
    Panel6: TPanel;
    Label1: TLabel;
    ImageName: TDomainEdit;
    PictureTable: TTable;
    Splitter1: TSplitter;
    Button2: TButton;
    SavePictureDialog: TSavePictureDialog;
    PictureDatabase: TDatabase;
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PicturesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RemoveButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    function GetBitmap(Value:String):TBitMap;
  public
    function GetNames:String;
    function GetPicture(Value:String):String;
    function GetBitmapByName(Value:String):TBitMap;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button3Click(Sender: TObject);
begin
  Close;
end;

function TForm1.GetNames:String;
begin
   Result:=Pictures.Items.CommaText;
end;
function TForm1.GetPicture(Value:String):String;
var
   I:Integer;
begin
   Result:='';
   I:=Pictures.Items.IndexOf(Value);
   if I <> -1 then
      Result:=TPString(Pictures.Items.Objects[I]).Value;
end;
function TForm1.GetBitmapByName(Value:String):TBitMap;
begin
   Result:=GetBitmap(GetPicture(Value));
end;
function TForm1.GetBitmap(Value:String):TBitMap;
var
   SStream:TStringStream;
   Compressor:TCompress;
begin
   result:=nil;
   try
      Compressor:=TCompress.Create;
      Value:=StringToBinary(Value);
      Value:=Compressor.CompressString(Value);
      Compressor.Free;
      SStream:=TStringStream.Create(Value);
      SStream.Position:=0;
      Result:=TBitMap.Create;
      Result.LoadFromStream(SStream);
      SStream.Free;
   except
      ;
   end;
end;  
procedure TForm1.Button1Click(Sender: TObject);
var
   I:Integer;
   J:Integer;
   SStream:TStringStream;
   Compressor:TCompress;
   S:String;
   PString:TPString;
begin
   if OpenPictureDialog.Execute then
   begin
      Image1.Picture.LoadFromFile(OpenPictureDialog.FileName);
      if (Image1.Picture.Width  > Panel1.ClientWidth )
      or (Image1.Picture.Height > Panel1.ClientHeight) Then
         Image1.Stretch:=True
      else
         Image1.Stretch:=False;
      S:=OpenPictureDialog.FileName;
      J:=Length(S);
      for I:=Length(S) downto 1 do
      begin
         if S[I] = '.' then J:=I;
         if (S[I] = '\') or (S[I] = ':') then
         begin
            S:=Copy(S,I+1,J-(I+1));
            break;
         end;
      end;
      ImageName.Text:=S;

      SStream:=TStringStream.Create('');
      Image1.Picture.Bitmap.SaveToStream(SStream);
      SStream.Position:=0;
      Compressor:=TCompress.Create;
      S:=SStream.DataString;
      SStream.Free;
      S:=Compressor.CompressString(S);
      Compressor.Free;
      S:=BinaryToString(S);
      with PictureTable do
      begin
         if FindKey([ImageName.Text]) then
         begin
            Edit;
            PictureTable.FieldByName('Picture').AsString:=S;
            Post;
            Pictures.ItemIndex:=Pictures.Items.IndexOf(ImageName.Text);
            if Pictures.ItemIndex <> -1 then
            begin
               TPString(Pictures.Items.Objects[Pictures.ItemIndex]).Value:=S;
            end;
         end
         else
         begin
            Append;
            PictureTable.FieldByName('PICTURENAME').AsString:=ImageName.Text;
            PictureTable.FieldByName('PICTURE').AsString :=S;
            Post;
            PString:=TPString.Create;
            PString.Value:=S;
            Pictures.ItemIndex:=Pictures.Items.AddObject(ImageName.Text,PString);
         end;
         Pictures.OnClick(Pictures);
      end;
   end;   
end;          

procedure TForm1.FormCreate(Sender: TObject);
var
   PString:TPString;
begin
   if GetGPCSRegString('WorkStation','DBType','Paradox') = 'Oracle' then
   begin
      PictureDataBase.Params.Add('USER NAME=' + GetGPCSRegString('','UserName','psl'));
      PictureDataBase.Params.Add('PASSWORD='  + GetGPCSRegString('','Password','suvroc'));
   end
   else if GetGPCSRegString('WorkStation','DBType','Paradox') = 'SQLServer' then
      PictureTable.TableName:='dbo.PICTURES';

   PictureDataBase.DatabaseName:=GetGPCSRegString('','Picture Alias','PSL');
   if PictureDataBase.DatabaseName <> 'PSL' then
      PictureTable.TableName:='PICTURES';
      
   PictureTable.DatabaseName:=PictureDataBase.DatabaseName;
   
   with PictureTable do
   begin
      Open;
      First;
      while not EOF do
      begin
         PString:=TPString.Create;
         PString.Value:=PictureTable.FieldByName('PICTURE').AsString;
         Pictures.Items.AddObject(PictureTable.FieldByName('PICTURENAME').AsString,PString);
         Next;
      end;
   end;
end;

procedure TForm1.PicturesClick(Sender: TObject);
var
   BMP:TBitMap;
   R:TRect;
begin
 //  if Length(TPString(Pictures.Items.Objects[Pictures.ItemIndex]).Value) > 32000 then
 //     ShowMessage(IntToStr(Length(TPString(Pictures.Items.Objects[Pictures.ItemIndex]).Value)));


   BMP:=GetBitMap(TPString(Pictures.Items.Objects[Pictures.ItemIndex]).Value);
   Image1.Picture.Bitmap.Assign(BMP);
   R:=Panel1.ClientRect;
   InflateRect(R,-8,-8);
   if (BMP.Width  >= (R.Right-R.Left)) 
   or (BMP.Height >= (R.Bottom-R.Top)) Then
   begin
      AdjustRatio(R,BMP.Width,BMP.Height,True);
      Image1.Picture.Bitmap.Width :=R.Right-R.Left;
      Image1.Picture.Bitmap.Height:=R.Bottom-R.Top;
      OffsetRect(R,0-R.Left,0-R.Top);
      Image1.Picture.Bitmap.Canvas.FillRect(R);
      StretchU.Stretch(BMP,Image1.Picture.Bitmap);
   end;
   BMP.Free;

   ImageName.Text:=Pictures.Items[Pictures.ItemIndex];
   RemoveButton.Enabled:=True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
   I:Integer;
begin
   for I:=0 to Pictures.Items.Count-1 do
      TPString(Pictures.Items.Objects[I]).Free;
   
end;

procedure TForm1.RemoveButtonClick(Sender: TObject);
var
   S:String;
begin
   Pictures.ItemIndex:=Pictures.Items.IndexOf(ImageName.Text);
   if Pictures.ItemIndex <> -1 then
   begin
      S:=Pictures.Items[Pictures.ItemIndex];
      TPString(Pictures.Items.Objects[Pictures.ItemIndex]).Free;
      Pictures.Items.Delete(Pictures.ItemIndex);
      with PictureTable do if FindKey([S]) then Delete;
      ImageName.Text:='';
      Image1.Picture.Bitmap.Assign(nil);
      RemoveButton.Enabled:=False;
   end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   BMP:TBitMap;
begin
   BMP:=GetBitMap(TPString(Pictures.Items.Objects[Pictures.ItemIndex]).Value);
   SavePictureDialog.FileName:=Pictures.Items[Pictures.ItemIndex]+'.bmp';
   if SavePictureDialog.Execute then
      BMP.SaveToFile(SavePictureDialog.FileName);
   BMP.Free;
end;

end.
