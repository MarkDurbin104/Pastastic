unit ProjectCopierFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, PackStrListU,ExtCtrls,FileCtrl,ParseNodeU;

type
  TMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    OPCompList: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure OPCompListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure OPCompListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    Dir:string;
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

uses ProjectFormFU;

{$R *.DFM}

procedure TMain.FormShow(Sender: TObject);
begin
   ProjectsForm.PutOn(Panel1);
end;

procedure TMain.Button2Click(Sender: TObject);
begin
   OPCompList.Clear;
end;

procedure TMain.OPCompListDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  LB:TListBox;
  I:Integer;
begin
   if Source = ProjectsForm.CompList then
   begin
      OPCompList.Items.BeginUpdate;
      try
         LB:=Source as TListBox;
         for I:=0 to LB.Items.Count-1 do
         begin
            if LB.Selected[I] then
            begin
               case ProjectsForm.CompType of
                  0: ProjectsForm.Comps.Groups      .NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                  1: ProjectsForm.Comps.Products    .NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                  2: ProjectsForm.Comps.Users       .NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                  3: ProjectsForm.Comps.PickLists   .NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                  4: ProjectsForm.Comps.LookUps     .NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                  5: ProjectsForm.Comps.WorkStations.NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                  6: ProjectsForm.Comps.Domains     .NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                  7: ProjectsForm.Comps.Snippets    .NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                  8: ProjectsForm.Comps.Constants   .NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                  9: ProjectsForm.Comps.LogFormats  .NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                 10: ProjectsForm.Comps.BuildOptions.NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
                 11: ProjectsForm.Comps.Functions   .NodeNamed(LB.Items[I]).SubItemDetails(OPCompList.Items);
               end;
            end;
         end;
      except
      end;
      OPCompList.Items.EndUpdate;
   end;
end;

procedure TMain.OPCompListDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   if Source = ProjectsForm.CompList then Accept:=True;
end;

procedure TMain.Button1Click(Sender: TObject);
var
   I:Integer;
   SL:TPackStringList;
   S:String;
   CType:String;
   Path:String;
   Base:String;
   ImageNode:TImageNode;
begin
  if SelectDirectory(Dir, [sdAllowCreate, sdPerformCreate, sdPrompt],0) then
   begin
      Path:=ExtractFilePath(Dir+'\');
      Base:=Copy(ExtractFileName(Dir),1,Length(ExtractFileName(Dir))-Length(ExtractFileExt(Dir)));
      ForceDirectories(Path+'\IDS');
      ForceDirectories(Path+'\Images');
      SL:=TPackStringList.Create;
      S:='';
      CType:='';
      for I:=0 to OPCompList.Items.Count-1 do
      begin
         if S <> Copy(OPCompList.Items[I],1,4) then
         begin
            if S <> '' then 
            begin
              SL.Add('}');
              SL.SaveToFile(Path+'IDS\'+Base+' '+CType+'.ids');
              SL.Clear;
            end;
            CType:=Copy(OPCompList.Items[I],1,Pos('.',OPCompList.Items[I])-1)+'s';
            SL.Add(CType+' {');
            S:=Copy(OPCompList.Items[I],1,4);
         end;
         try
            if (CType = 'Products') or (CType = 'Groups') then
            begin
               ImageNode:=TImageNode(ProjectsForm.Comps.NodeNamed(OPCompList.Items[I]));
               if ImageNode.BitMap <> '' then
               begin
                  ImageNode.BitMap:='..\Images\'+ExtractFileName(ImageNode.BitMap);
                  ImageNode.Image.SaveToFile(Path+'Images\'+ExtractFileName(ImageNode.BitMap));
               end;
            end;
            SL.Add(ProjectsForm.Comps.NodeNamed(OPCompList.Items[I]).ListDetails);
         except
            SL.Add('Exception in Node '+OPCompList.Items[I]);
         end;
      end;
      if S <> '' then 
      begin
         SL.Add('}');
         SL.SaveToFile(Path+'IDS\'+Base+' '+CType+'.ids');
      end;
      SL.Free;
   end;
end;

procedure TMain.Button3Click(Sender: TObject);
var
   Path:String;
   Base:String;
begin
  if SelectDirectory(Dir, [sdAllowCreate, sdPerformCreate, sdPrompt],0) then
  begin
     Path:=ExtractFilePath(Dir+'\');
     Base:=Copy(ExtractFileName(Dir),1,Length(ExtractFileName(Dir))-Length(ExtractFileExt(Dir)));
     ProjectsForm.Comps.SaveAs(Path,Base);
  end;
end;

end.
