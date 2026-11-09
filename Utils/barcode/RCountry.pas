unit RCountry;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBTables, DB, Grids, DBGrids,Printers, Buttons;

type
  TByCountry = class(TForm)
    DataSource1: TDataSource;
    Table1: TTable;
    DBGrid1: TDBGrid;
    Table1Country   : TStringField;
    Table1LabelCount: TIntegerField;
    Table1BadLabels : TIntegerField;
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
  ByCountry: TByCountry;

implementation

{$R *.DFM}

procedure TByCountry.FormShow(Sender: TObject);
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
       Table1.SetKey;
       Table1Country.Value:=BarRep.FieldByName('Country').AsString;
       if Table1.GotoKey then
       begin
          Table1.Edit;
          Table1LabelCount.Value:=Table1LabelCount.Value+BarRep.FieldByName('LabelCount').AsInteger;
          Table1BadLabels.Value:=Table1BadLabels.Value+BarRep.FieldByName('BadLabels').AsInteger;
          Table1.Post;
       end
       else
       begin
          Table1.Insert;
          Table1Country.Value:=BarRep.FieldByName('Country').AsString;
          Table1LabelCount.Value:=BarRep.FieldByName('LabelCount').AsInteger;
          Table1BadLabels.Value:=BarRep.FieldByName('BadLabels').AsInteger;
          Table1.Post;
       end;
       BarRep.Next;
    end;        
    BarRep.Close;
end;            

procedure TByCountry.SpeedButton1Click(Sender: TObject);
var
   W,H,YOfs:Integer;
   C1W:Integer;
   C2W:Integer;
   C3W:Integer;
   C4W:Integer;
begin
   Printer.Title:='EMS Barcode Report By Country';
   Printer.BeginDoc;
   W:=Printer.PageWidth;
   with Printer.Canvas do
   begin
      C2W:=TextWidth(Table1Country.DisplayLabel    );
      C3W:=TextWidth(Table1LabelCount.DisplayLabel );
      C4W:=TextWidth(Table1BadLabels.DisplayLabel  );
      Table1.First;
      while not Table1.EOF do
      begin
         if C2W < TextWidth(Table1Country.AsString   ) then C2W:=TextWidth(Table1Country.AsString   );
         if C3W < TextWidth(Table1LabelCount.AsString) then C3W:=TextWidth(Table1LabelCount.AsString);
         if C4W < TextWidth(Table1BadLabels.AsString ) then C4W:=TextWidth(Table1BadLabels.AsString );
         Table1.Next;
      end;
      W:=(W-(C2W+C3W+C4W)) div 3;
      C1W:=-10;
      C2W:=C2W+W;
      C3W:=C3W+W;
      C4W:=C4W+W;
      YOfs:=10;
      Font.Style:=[fsBold];
      TextOut(20+C1W        ,YOfs,Table1Country.DisplayLabel   );
      TextOut(30+C1W+C2W    ,YOfs,Table1LabelCount.DisplayLabel);
      TextOut(40+C1W+C2W+C3W,YOfs,Table1BadLabels.DisplayLabel );
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
            TextOut(20+C1W        ,YOfs,Table1Country.DisplayLabel   );
            TextOut(30+C1W+C2W    ,YOfs,Table1LabelCount.DisplayLabel);
            TextOut(40+C1W+C2W+C3W,YOfs,Table1BadLabels.DisplayLabel );
            YOfs:=Yofs+TextHeight(',"')*2;
            Font.Style:=[];
         end;
         TextOut(20+C1W        ,YOfs,Table1Country.AsString   );
         TextOut(30+C1W+C2W    ,YOfs,Table1LabelCount.AsString);
         TextOut(40+C1W+C2W+C3W,YOfs,Table1BadLabels.AsString );
         YOfs:=Yofs+TextHeight(',"');
         Table1.Next;
      end;
   end;
   Printer.EndDoc;
end;

end.
 