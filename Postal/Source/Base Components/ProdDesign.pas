unit ProdDesign;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CompInspector, StdCtrls, ExtCtrls,GPCSBase_TLB,GPCSBaseAU,ProdGenU;

type
  TDesForm = class(TForm)
    ProdDes: TCompInspector;
    Panel1: TPanel;
    ReBuild: TButton;
    Cancel: TButton;
    Panel2: TPanel;
    procedure CancelClick(Sender: TObject);
    procedure ReBuildClick(Sender: TObject);
  public
    FEVSink:IDesignEventSink;
    BaseProd:TGPCSAbstractProduct;
  end;

var
  DesForm: TDesForm;

implementation

uses BaseProduct;

{$R *.DFM}

procedure TDesForm.CancelClick(Sender: TObject);
begin
   if FEVSink <> nil then
      FEVSink.Cancel;
end;

procedure TDesForm.ReBuildClick(Sender: TObject);
var
   BaseProduct:TBaseProduct;
   BuildDir:String;           
   ProductGen:TProductGen;
   Version:String;
   PName:String;
begin   
   if FEVSink <> nil then
   begin
      BaseProduct:=TBaseProduct(BaseProd);
      Version:=IntToStr(BaseProduct.Get_Version+1);
      PName:=BaseProduct.Get_Name;
      ProductGen:=TProductGen.Create('');
      ProductGen.PClass      :='T'+PName+'Product';
      ProductGen.PName       :='P_'+PName+'_'+Version;
      ProductGen.UName       :='P_'+PName+'AU_'+Version;
      ProductGen.UFile       :=ProductGen.UName+'.pas';
      ProductGen.FName       :='P_'+PName+'FU_'+Version;
      ProductGen.FFile       :=ProductGen.FName+'.pas';
      ProductGen.PGUID       :='';
      ProductGen.PProgID     :='Product.'+PName;
      if Copy(BaseProduct.Get_Description,1,5) <> 'GPCS ' then
         ProductGen.PRegDesc    :='GPCS '+BaseProduct.Get_Description
      else
         ProductGen.PRegDesc    :=BaseProduct.Get_Description;
         
      ProductGen.Version     :=Version;
      
      ProductGen.BarCode     :=          BaseProduct.Get_BarCode       ;
      ProductGen.Description :=          BaseProduct.Get_Description   ;
      ProductGen.EndDate     :=          BaseProduct.Get_EndDate       ;
      ProductGen.HighDays    :=          BaseProduct.Get_HighDays      ;
      ProductGen.MaxQuantity :=IntToStr (BaseProduct.Get_MaxQuantity  );
      ProductGen.MCRCode     :=          BaseProduct.Get_MCRCode       ;
      ProductGen.MinQuantity :=IntToStr (BaseProduct.Get_MinQuantity  );
      ProductGen.OCRCode     :=          BaseProduct.Get_OCRCode       ;
      ProductGen.OtherCode   :=          BaseProduct.Get_OtherCode     ;
      ProductGen.PLU         :=IntToStr (BaseProduct.Get_PLU          );
      ProductGen.Regulations :=          BaseProduct.Get_Regulations   ;
      ProductGen.StartDate   :=          BaseProduct.Get_StartDate     ;
      ProductGen.UnitPrice   :=CurrToStr(BaseProduct.Get_UnitPrice    );
      ProductGen.UnitQuantity:=IntToStr (BaseProduct.Get_UnitQuantity );
      ProductGen.UseDays     :=          BaseProduct.Get_UseDays       ;
      ProductGen.Caption     :=          BaseProduct.Get_Caption       ;
      ProductGen.Title       :=          BaseProduct.Get_Title         ;
      ProductGen.Prompt      :=          BaseProduct.Get_Prompt        ;
      ProductGen.Hint        :=          BaseProduct.Get_PMessage      ;
      ProductGen.Name        :=          PName                         ;
      ProductGen.ProjectFiles:=          ProductGen.PName+'.dpr,'+ProductGen.UFile+','+ProductGen.FFile  ;
      ProductGen.BitMap      :=GetBitMap(BaseProduct.Get_BitMap       );
                                           
      BuildDir:=FEVSink.BuildParams;

      ProductGen.LoadFromFile(BuildDir+'\'+'P_'+PName+'_'+IntToStr(BaseProduct.Get_Version)+'.dpr');
      ProductGen.SaveToFile(BuildDir+'\'+ProductGen.PName+'.dpr');
      ProductGen.LoadFromFile(BuildDir+'\'+'P_'+PName+'AU_'+IntToStr(BaseProduct.Get_Version)+'.pas');
      ProductGen.SaveToFile(BuildDir+'\'+ProductGen.UFile);
      FEVSink.ReBuild;
   end;
end;    

end.
