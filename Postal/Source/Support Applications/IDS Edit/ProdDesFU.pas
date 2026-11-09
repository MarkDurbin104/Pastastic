unit ProdDesFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,PackStrListU,GPCSGUID,GPCSBase_TLB,Compress,CompressU,Bin2String,
  StdCtrls,ProjectFormFU,ErrorFormFU;

type
  TProdDes = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Panel14: TPanel;
    Image11: TImage;
    Panel15: TPanel;
    Label1: TLabel;
    Panel16: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    TitleE: TEdit;
    CaptionE: TEdit;
    NameE: TEdit;
    Label8: TLabel;
    BasedOnE: TLabel;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Image1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  public
    ProductNode:TProductNode;
    procedure PutOn(Panel:TPanel);
    procedure SetupBmp(Image:TImage;Index:Integer;Text:String;Glyph:TBitmap);
    procedure SetProd;
  end;

var
  ProdDes: TProdDes;
  PictureServer:IPictureServer;

implementation

{$R *.DFM}


function GetBitmap(Value:OleVariant;BType:Boolean):TBitMap;
var
   SStream:TStringStream;
   Compress:TCompress;
begin
   result:=nil;
   if BType then
   begin
      try
         if Value = '' then Exit;
         Compress:=TCompress.Create;
         Value:=StringToBinary(Value);
         Value:=Compress.CompressString(Value);
         Compress.Free;
         SStream:=TStringStream.Create(Value);
         SStream.Position:=0;
         Result:=TBitMap.Create;
         Result.LoadFromStream(SStream);
         SStream.Free;
      except
      end;
   end
   else
   begin
      if VarIsArray(Value) then
      begin
//         Compressor:=TCompressor.Create;
         Result:=TCompressor.CreateBitmapFromArray(Value);
//         Compressor.Free;
      end;
   end;
end;
function GetPictureFromServer(Value:String):TBitMap;
var
   BMPString:String;
begin
   Result:=nil;
   BMPString:=PictureServer.Bitmap(Value);
   if BMPString <> '' then
      Result:=GetBitmap(BMPString,True);
end;

procedure TProdDes.PutOn(Panel:TPanel);
begin
   Parent:=Panel;
   BorderStyle:=bsNone;
   Show;
   Align:=alClient;
end;
procedure TProdDes.SetupBmp(Image:TImage;Index:Integer;Text:String;Glyph:TBitmap);
var
   BMP:TBitmap;
   R:TRect;
begin
   if Image.Picture.Bitmap = nil then
      Image.Picture.Bitmap:=TBitmap.Create;
   BMP:=Image.Picture.Bitmap;
   BMP.Width:=Panel4.Width-2;
   BMP.Height:=Panel4.Height-2;
   with BMP.Canvas do
   begin
      Brush.Color:=$4F270F;
      Font.Color:=clWhite;
      FillRect(Bounds(0,0,BMP.Width,BMP.Height));
      if Glyph <> nil then
      begin
         R:=Bounds((BMP.Width-75)div 2,1,75,50);
         BrushCopy(R,Glyph,Bounds(0,0,Glyph.Width,Glyph.Height),Glyph.Canvas.Pixels[0,0]);
      end;
      if Index > 0 then
      begin
         Font.Style:=[fsBold];
         TextOut(BMP.Width-(2+Textwidth('F88')),2,'F'+IntToStr(Index));
         Font.Style:=[];
      end;
      if Text <> '' then
      begin
         R:=Bounds(2,BMP.Height-(TextHeight('Wg')*2),BMP.Width-4,TextHeight('Wg')*2);
         DrawText(Handle,PChar(Text),-1,R,DT_WORDBREAK or DT_CENTER);
      end;
   end;
end;
procedure TProdDes.SetProd;
begin
   ProductNode:=nil;
   if (ProjectsForm.Comps <> nil) and (ProjectsForm.CompTypeName = 'Product') and (ProjectsForm.CompList.itemIndex >= 0) and (ProjectsForm.CompList.SelCount > 0) then
   begin
      ProductNode:=TProductNode(ProjectsForm.Comps.NodeNamed(
                              ProjectsForm.CompTypeName+'.'+
                              ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex]));
   end;
   FormResize(Self);
end;
procedure TProdDes.FormResize(Sender: TObject);
var
   Node:TCorvusNode;
   SL:TPackStringList;
   BMP:TBitmap;
   I:Integer;
   CurImage:TImage;
begin
   Panel1.Height:=Height div 3;
   Panel2.Height:=Panel1.Height div 2;
   Panel4.Width:=(Width-2) div 5;
   Panel14.Height:=Panel4.Height;
   Image11.Width:=Panel4.Width;
   Panel5.Width:=Panel4.Width;
   Panel6.Width:=Panel4.Width;
   Panel7.Width:=Panel4.Width;
   Panel10.Width:=Panel4.Width;
   Panel11.Width:=Panel4.Width;
   Panel12.Width:=Panel4.Width;
   Panel13.Width:=Panel4.Width;
   if ProductNode <> nil then
   begin
      Label1.Caption:=ProductNode.Name;
      NameE.Text    :=ProductNode.Name;
      TitleE.Text   :=ProductNode.Title;
      CaptionE.Text :=ProductNode.Caption;
//      HintE.Text    :=ProductNode.Hint;
//      PromptE.Text  :=ProductNode.Prompt;
//      BasedOnE.Caption:=ProductNode.BasedOn;
      SetupBmp(Image11,0,ProductNode.Caption,ProductNode.Image);
      SL:=TPackStringList.Create;
      SL.CommaText:=ProductNode.Items;
      CurImage:=Image1;
      for I:=0 to 9 do
      begin
         case I of
             0: CurImage:=Image1;
             1: CurImage:=Image2;
             2: CurImage:=Image3;
             3: CurImage:=Image4;
             4: CurImage:=Image5;
             5: CurImage:=Image6;
             6: CurImage:=Image7;
             7: CurImage:=Image8;
             8: CurImage:=Image9;
             9: CurImage:=Image10;
         end;
         if I < SL.Count then
            Node:=ProjectsForm.Comps.NodeNamed(SL[I])
         else
            Node:=nil;
         if Node is TGroupNode then
         begin
            BMP:=(Node as TGroupNode).Image;
            SetupBmp(CurImage,I+1,(Node as TGroupNode).Caption+'...',BMP);
         end
         else if Node is TProductNode then
         begin
            BMP:=(Node as TProductNode).Image;
            SetupBmp(CurImage,I+1,(Node as TProductNode).Caption,BMP);
         end
         else
         begin
            if I < SL.Count then
               SetupBmp(CurImage,I+1,SL[I],GetPictureFromServer(SL[I]))
            else
               SetupBmp(CurImage,I+1,'',nil);
         end;
      end;
      SL.Free;
   end;
end;

procedure TProdDes.FormCreate(Sender: TObject);
begin
   try
      PictureServer:=CreatePictureServer;
   except
   end;
end;

procedure TProdDes.FormDestroy(Sender: TObject);
begin
   PictureServer:=nil;
end;

procedure TProdDes.Image1Click(Sender: TObject);
var
   SL:TPackStringList;
begin
   if ProductNode <> nil then
   begin
      SL:=TPackStringList.Create;
      SL.CommaText:=ProductNode.Items;
      if (Sender = Image1 ) and (SL.Count > 0) then ProjectsForm.Select(SL[0]);
      if (Sender = Image2 ) and (SL.Count > 1) then ProjectsForm.Select(SL[1]);
      if (Sender = Image3 ) and (SL.Count > 2) then ProjectsForm.Select(SL[2]);
      if (Sender = Image4 ) and (SL.Count > 3) then ProjectsForm.Select(SL[3]);
      if (Sender = Image5 ) and (SL.Count > 4) then ProjectsForm.Select(SL[4]);
      if (Sender = Image6 ) and (SL.Count > 5) then ProjectsForm.Select(SL[5]);
      if (Sender = Image7 ) and (SL.Count > 6) then ProjectsForm.Select(SL[6]);
      if (Sender = Image8 ) and (SL.Count > 7) then ProjectsForm.Select(SL[7]);
      if (Sender = Image9 ) and (SL.Count > 8) then ProjectsForm.Select(SL[8]);
      if (Sender = Image10) and (SL.Count > 9) then ProjectsForm.Select(SL[9]);
      SL.Free;
   end;
end;

procedure TProdDes.Image1DragDrop(Sender, Source: TObject; X, Y: Integer);
var
   I:Integer;
   SL:TPackStringList;
begin
   if (Source = ProjectsForm.Complist) and (ProductNode <> nil) then
   begin
      SL:=TPackStringList.Create;
      SL.CommaText:=ProductNode.Items;
      for I:=SL.Count to 9 do
         SL.Add('');
      if (Sender = Image1 ) then SL[0]:=ProjectsForm.CompTypeName+'.'+ProjectsForm.Complist.Items[ProjectsForm.CompList.itemIndex];
      if (Sender = Image2 ) then SL[1]:=ProjectsForm.CompTypeName+'.'+ProjectsForm.Complist.Items[ProjectsForm.CompList.itemIndex];
      if (Sender = Image3 ) then SL[2]:=ProjectsForm.CompTypeName+'.'+ProjectsForm.Complist.Items[ProjectsForm.CompList.itemIndex];
      if (Sender = Image4 ) then SL[3]:=ProjectsForm.CompTypeName+'.'+ProjectsForm.Complist.Items[ProjectsForm.CompList.itemIndex];
      if (Sender = Image5 ) then SL[4]:=ProjectsForm.CompTypeName+'.'+ProjectsForm.Complist.Items[ProjectsForm.CompList.itemIndex];
      if (Sender = Image6 ) then SL[5]:=ProjectsForm.CompTypeName+'.'+ProjectsForm.Complist.Items[ProjectsForm.CompList.itemIndex];
      if (Sender = Image7 ) then SL[6]:=ProjectsForm.CompTypeName+'.'+ProjectsForm.Complist.Items[ProjectsForm.CompList.itemIndex];
      if (Sender = Image8 ) then SL[7]:=ProjectsForm.CompTypeName+'.'+ProjectsForm.Complist.Items[ProjectsForm.CompList.itemIndex];
      if (Sender = Image9 ) then SL[8]:=ProjectsForm.CompTypeName+'.'+ProjectsForm.Complist.Items[ProjectsForm.CompList.itemIndex];
      if (Sender = Image10) then SL[9]:=ProjectsForm.CompTypeName+'.'+ProjectsForm.Complist.Items[ProjectsForm.CompList.itemIndex];
      ProductNode.Items:=SL.CommaText;
      FormResize(Self);
      SL.Free;
   end;

end;

procedure TProdDes.Image1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   if (Source = ProjectsForm.Complist) and (ProductNode <> nil) then Accept:=True;
end;

end.
