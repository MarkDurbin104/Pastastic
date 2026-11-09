library GPCSBase;

uses
  ComObj,
  ComServ2,
  GPCSBase_TLB in 'GPCSBase_TLB.pas',
  GPCSBaseAU in 'GPCSBaseAU.pas' {Component: CoClass};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

begin
   TAutoObjectFactory.Create(ComServer,TGPCSComponent             ,Class_GPCSComponent          ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSExecComponent         ,Class_GPCSExecComponent      ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSAbstractProduct       ,Class_GPCSAbstractProduct    ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSAbstractGroup         ,Class_GPCSAbstractGroup      ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSAbstractService       ,Class_GPCSAbstractService    ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSAbstractWUGroup       ,Class_GPCSAbstractWUGroup    ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSAbstractPickList      ,Class_GPCSAbstractPickList   ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSAbstractLookUp        ,Class_GPCSAbstractLookUp     ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSAbstractEventSink     ,Class_GPCSAbstractEventSink  ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSAbstractUIEventSink   ,Class_GPCSAbstractUIEventSink,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TAbstractCompLoad          ,Class_AbstractCompLoad       ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TAbstractCompMan           ,Class_AbstractCompMan        ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TAbstractErrorHandler      ,Class_AbstractErrorHandler   ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSAbstractSysGroup      ,Class_GPCSAbstractSysGroup   ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TAbstractTransactionLog    ,Class_AbstractTransactionLog ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TAbstractTxnEventSink      ,Class_AbstractTxnEventSink   ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSDevice                ,Class_GPCSDevice             ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TDeviceEventSink           ,Class_DeviceEventSink        ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TPictureServer             ,Class_PictureServer          ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TBaseExchangeRateServer    ,Class_BaseExchangeRateServer ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TBaseHotKeys               ,Class_BaseHotKeys            ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSAccounts              ,Class_GPCSAccounts           ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSSiteManager           ,Class_GPCSSiteManager        ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSRemoteControl         ,Class_GPCSRemoteControl      ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSHookUp                ,Class_GPCSHookUp             ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSStock                 ,Class_GPCSStock              ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TUIServer                  ,Class_UIServer               ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TTranslate                 ,Class_Translate              ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TMessenger                 ,Class_Messenger              ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TUILink                    ,Class_UILink                 ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TUIState                   ,Class_UIState                ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TPeriod                    ,Class_Period                 ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TTableMonitor              ,Class_TableMonitor           ,ciMultiInstance);
   TAutoObjectFactory.Create(ComServer,TGPCSBaseComponent         ,Class_GPCSBaseComponent      ,ciMultiInstance);
end.                                            
