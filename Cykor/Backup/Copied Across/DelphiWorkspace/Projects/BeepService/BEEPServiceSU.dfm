object Beep: TBeep
  OldCreateOrder = False
  DisplayName = 'Beep'
  OnContinue = ServiceContinue
  OnPause = ServicePause
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 222
  Width = 281
  object IdHTTPServer1: TIdHTTPServer
    Bindings = <>
    DefaultPort = 8000
    AutoStartSession = True
    ServerSoftware = 'VU.iT HTTP Proxy Cache'
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 32
    Top = 16
  end
  object IdServerInterceptLogEvent1: TIdServerInterceptLogEvent
    Left = 104
    Top = 16
  end
end
