unit RVol;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBTables, DB, Grids, DBGrids,Printers, Buttons;

type
  TByVol = class(TForm)
    DataSource1: TDataSource;
    Table1: TTable;
    DBGrid1: TDBGrid;
    Table1LabelCount: TIntegerField;
    Table1Country: TStringField;
    Button1: TButton;
    BarRep: TTable;
    SpeedButton1: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ByVol: TByVol;

implementation

{$R *.DFM}

procedure TByVol.FormShow(Sender: TObject);
var
   Found:Boolean;
begin
    Table1.First;
    While not Table1.EoF do
    begin
       Table1.Delete;
       Table1.First;
    end; 
    BarRep.Open;
    BarRep.First;
    while not BarRep.Eof do
    begin
       Table1.First;
       Found:=False;
       While (not Table1.EoF) and (not Found) do
       begin
          if Table1Country.Value = BarRep.FieldByName('Country').AsString then
             Found:=True
          else
             Table1.Next;
       end; 
       if Found then
       begin
          Table1.Edit;
          Table1LabelCount.Value:=Table1LabelCount.Value+BarRep.FieldByName('LabelCount').AsInteger;
          Table1.Post;
       end
       else
       begin
          Table1.Insert;
          Table1Country.Value:=BarRep.FieldByName('Country').AsString;
          Table1LabelCount.Value:=BarRep.FieldByName('LabelCount').AsInteger;
          Table1.Post;
       end;
       BarRep.Next;
    end;        
    BarRep.Close;
end;

procedure TByVol.SpeedButton1Click(Sender: TObject);
var
   W,H,YOfs:Integer;
   C1W:Integer;
   C2W:Integer;
   C3W:Integer;
   C4W:Integer;
begin
   Printer.Title:='EMS Barcode Report By Volume';
   Printer.BeginDoc;
   W:=Printer.PageWidth;
   with Printer.Canvas do
   begin
      C1W:=TextWidth(Table1LabelCount.DisplayLabel);
      C2W:=TextWidth(Table1Country   .DisplayLabel);
      Table1.First;
      while not Table1.EOF do
      begin
         if C1W < TextWidth(Table1LabelCount.AsString) then C1W:=TextWidth(Table1LabelCount.AsString);
         if C2W < TextWidth(Table1Country   .AsString) then C2W:=TextWidth(Table1Country   .AsString);
         Table1.Next;
      end;
      W:=(W-(C1W+C2W)) div 2;
      C1W:=C1W+W;
      C2W:=C2W+W;
      YOfs:=10;
      Font.Style:=[fsBold];
      TextOut(10            ,YOfs,Table1LabelCount.DisplayLabel);
      TextOut(20+C1W        ,YOfs,Table1Country   .DisplayLabel);
      YOfs:=Yofs+TextHeight(',"')*2;
      Font.Style:=[];
      Table1.First;
      while not Table1.EOF do
      begin
         if YOfs+TextHeight(',"') >= Printer.PageHeight then
         begin
            Printer.NewPage;
            Font.Style:=[fsBold];
            YOfs:=10;
            TextOut(10            ,YOfs,Table1LabelCount.DisplayLabel);
            TextOut(20+C1W        ,YOfs,Table1Country   .DisplayLabel);
            YOfs:=Yofs+TextHeight(',"')*2;
            Font.Style:=[];
         end;
         TextOut(10            ,YOfs,Table1LabelCount.AsString);
         TextOut(20+C1W        ,YOfs,Table1Country   .AsString);
         YOfs:=Yofs+TextHeight(',"');
         Table1.Next;
      end;
   end;
   Printer.EndDoc;
end;

end.
 