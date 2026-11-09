unit TDXFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,TxnTranslateU,ProjectFormFU,ParseNodeU, ExtCtrls,PackStrListU;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    QueryMemo: TMemo;
    OPFile: TEdit;
    Button1: TButton;
    Button2: TButton;
    Overrite: TCheckBox;
    SystemType: TComboBox;
    OD: TOpenDialog;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button2Click(Sender: TObject);
begin
   if OD.Execute then
     OPFile.Text:=OD.FileName;
end;

function MakeLine(S:String):String;
var
   I:Integer;
   L:Integer;
begin
   Result:='';
   
   L:=(80-Length(S)) div 2;
   for I:=1 to L do Result:=Result+'-';
   
   Result:=Result+' '+S+' ';
   
   L:=Length(Result);
   for I:=L to 79 do Result:=Result+'-';
end;
function FindProdFromPLU(PLU:Integer;Desc:String):String;
var
   P:Integer;
   ProdPLU:Integer;
   ProductNode:TProductNode;
   MainProdNode:TProductNode;
   Node:TConstantNode;
begin
   Result:=IntToStr(PLU);
   if copy(Desc,1,8) = 'Product.' then
   begin
      MainProdNode:=TProductNode(ProjectsForm.Comps.NodeNamed(Desc));
      if MainProdNode <> nil then
      begin
         for P:=0 to MainProdNode.GetItemNodeCount-1 do
         begin
            ProductNode:=TProductNode(MainProdNode.ItemNode[P]);
            if (ProductNode <> nil) then
            begin
               if (ProductNode.PLU <> '') and (ProductNode.PLU[1] in ['0'..'9']) then
               begin
                  ProdPLU:=StrToIntDef(ProductNode.PLU,-1)
               end
               else
               begin
                  Node:=TConstantNode(ProjectsForm.Comps.NodeNamed('Constant.'+ProductNode.PLU));
                  if (Node <> nil) and (Node.Count >= 0) then
                     ProdPLU:=StrToIntDef(Node[0],-1)
                  else
                     ProdPLU:=-1;
               end;
               if ProdPLU = PLU then
               begin
                  Result:='Product.'+ProductNode.Name;
                  Exit;
               end;
            end; 
         end;
      end;
      Desc:='';
   end;
   for P:=0 to ProjectsForm.Comps.Products.Count-1 do
   begin
      ProductNode:=TProductNode(ProjectsForm.Comps.Products.Objects[P]);
      if (ProductNode.PLU <> '') and (ProductNode.PLU[1] in ['0'..'9']) then
      begin
         ProdPLU:=StrToIntDef(ProductNode.PLU,-1)
      end
      else
      begin
         Node:=TConstantNode(ProjectsForm.Comps.NodeNamed('Constant.'+ProductNode.PLU));
         if (Node <> nil) and (Node.Count >= 0) then
            ProdPLU:=StrToIntDef(Node[0],-1)
         else
            ProdPLU:=-1;
      end;   
      if ProdPLU = PLU then
      begin
         if (Desc <> '') then
         begin
            if (Desc = ProductNode.Description) then
               Result:='Product.'+ProductNode.Name;
         end
         else
         begin
            if (Result <> '') and (Result[1] in ['0'..'9']) then
               Result:='Product.'+ProductNode.Name
            else
               Result:=Result+' Product.'+ProductNode.Name;
         end;
      end;
   end;
end;
function CheckProgID(ProgID:String):String;
var
   K:Integer;
   S:String;
begin
   Result:=ProgID;
   if ProjectsForm.Comps.NodeNamed(ProgID) = nil then
   begin
      for K:=0 to ProjectsForm.Comps.Products.Count-1 do
      begin
         if ProjectsForm.Comps.Products.Objects[K] <> nil then
         begin
            S:='Product.'+Copy(TProductNode(ProjectsForm.Comps.Products.Objects[K]).Name,1,12);
            if S = ProgID then
               Result:='Product.'+TProductNode(ProjectsForm.Comps.Products.Objects[K]).Name;
         end;
      end;
   end;
end;
procedure TForm1.Button1Click(Sender: TObject);
var
   Lines:TTransactionLines;
   Line:TTransactionLine;
   I,J:Integer;
   S:String;
   SL:TPackStringList;
   SelectedList:TStringList;
begin
   if OPFile.Text = '' then Exit;
   Button1.Enabled:=False;
   try
      Lines:=TxnTranslateU.TTxnTranslate.TranslateQuery('',QueryMemo.Text);
      
      SelectedList:=TStringList.Create;
      SL:=TPackStringList.Create;
      SL.PackText:=Lines.AsString;
      SL.SaveToFile('C:\Lines.txt');
      SL.Clear;
      if (not Overrite.Checked) and FileExists(OPFile.Text) then
         SL.LoadFromFile(OPFile.Text);
   
      SL.Add('SystemType '+SystemType.Text);
      for I:=0 to Lines.Count-1 do
      begin
         Line:=Lines[I];
         if Line.TransactionType = 'TxnLine' then
         begin
            if (Line.ProgramID <> 'Product.Cash') or (Line.Count > 0) then // cash transfer adjustment
            begin
               SL.Add(MakeLine(SystemType.Text+' - '+Line.Description));
            
               if Line.ProgramID = '' then
                  Line.ProgramID:=FindProdFromPLU(Line.PLU,Line.Description);
               
               Line.ProgramID:=CheckProgID(Line.ProgramID);
               if ProjectsForm.Comps.NodeNamed(Line.ProgramID) <> nil then
               begin
                  if Line.Count = 0 then
                     SL.Add('CompExecute '+Line.ProgramID)
                  else
                     SL.Add('Execute '+Line.ProgramID);
               end
               else
               begin
                  SL.Add('StockExecute '+Line.ProgramID);
                  SL.Add('PLU '+IntToStr(Line.PLU));
                  if Line.ItemQuantity > 1 then
                     SL.Add('Quantity '+IntToStr(Line.ItemQuantity));
                  SL.Add('Value '+CurrToStr(Line.ItemValue));
                  if Line.ItemPrice <> Line.ItemValue then
                     SL.Add('Price '+CurrToStr(Line.ItemPrice));
                  SL.Add('Description "'+Line.Description+'"');
               end;
               SelectedList.Clear;   
               for J:=0 to Line.Count-1 do
               begin
                  Line:=Lines[I];
                  Line[J].ParentProgID:=CheckProgID(Line[J].ParentProgID);
                  S:=Line[J].ParentProgID;
                  if S <> Line.ProgramID then
                  begin
                     if S = '' then 
                        S:=FindProdFromPLU(Line[J].PLU,Line.ProgramID)
                     else if Copy(S,1,8) <> 'Product.' then
                        S:='';
                  
                     if (S <> '') and (SelectedList.IndexOf(S) = -1) then 
                        SelectedList.Add(S);
                  end;
               end;
               for J:=0 to SelectedList.Count-1 do
                  SL.Add('Select '+SelectedList[J]);
               for J:=0 to Line.Count-1 do        
               begin
                  if Line[J].Enabled then
                  begin
//                     if (Line[J].ParentProgID <> '') and (Line[J].ParentProgID <> Line.ProgramID) then
//                        SL.Add('Dom '+Line[J].ParentProgID+'.'+Line[J].DomName+',"'+Line[J].Value+'"')
//                     else
                        SL.Add('Dom '+Line[J].DomName+',"'+Line[J].Value+'"');
                  end
               end;
               SL.Add('');
            end;
         end;  
      end;
      SL.SaveToFile(OPFile.Text);
      SL.Free;
      SelectedList.Free;
      Lines.Free;
   finally
      Button1.Enabled:=True;
   end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
   ProjectsForm.PutOn(Panel1);
end;

end.
