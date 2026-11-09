unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    OK: TButton;
    StatTimer: TTimer;
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    SemaTimer: TTimer;
    ChecksemTime: TEdit;
    GetStatusTimer: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SemStat: TLabel;
    procedure OKClick(Sender: TObject);
    procedure SemaTimerTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure GetStatusTimerChange(Sender: TObject);
    procedure ChecksemTimeChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StatTimerTimer(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

const
{ Node Request values:  }  
XR_STATUS         =     0; {  Request Status                }
XR_REINIT         =     1; {  Reinitialize, reload nodeinit }
XR_REMOVE         =     2; {  Remove Background Task        }
XR_CONNECT1       =     4; {  Dial Inbound Phone #1         }
XR_CONNECT2       =     8; {  Dial Inbound Phone #2         }
XR_CANCEL         =    16; {  Cancel Dialing/Abort Session  }
XR_ENABLE_AA      =    32; {  Enable Auto Answer            }
XR_DISABLE_AA     =    64; {  Disable Auto Answer           }
XR_RELEASE_PORT   =   128; {  Release Comm Port             }
                           {  Use XR_REINIT to Reload Port  }
XR_ENABLE_ESD     =   256; {  Enable ESD                    }
XR_DISABLE_ESD    =   512; {  Disable ESD                   }
{ Node Status values: }
XS_LOADED         =     1; {  Background Task has Loaded   }
XS_AUTO_ANSWER    =     2; {  Auto Answer Enabled          }
XS_DIALING        =     4; {  Currently Dialing            }
XS_CONNECTING     =     8; {  Currently Connecting         }
XS_PASSWORD       =    16; {  Password Exchange            }
XS_CONNECTED      =    32; {  Currently Connected          }
XS_DISCONNECTED   =    64; {  Currently Disconnected       }
XS_ESD_DISABLED   =   256; {  ESD is Disabled              }
XS_PORT_RELEASED  =   512; {  Comm Port Released           }
XS_RESOURCE_READY =  1024; {  Resource is available        }
XS_COUNTER_MASK   = 49152; {  Execution Counter Mask       }

implementation

function  TestSemaphore: Word; far; external 'TESTSEMA';
procedure SignalPortFree;      far; external 'TESTSEMA';
procedure SignalPortInUse;     far; external 'TESTSEMA';
                                 
function RWNodeRequest(Request:Word): Word; far; external 'RWNWAPI';

{$R *.DFM}

procedure TForm1.OKClick(Sender: TObject);
begin
   Close;
end;

procedure TForm1.SemaTimerTimer(Sender: TObject);
var
   R:Word;
begin
    SemaTimer.Interval:=StrToInt(ChecksemTime.Text);
    if TestSemaphore <> 4 then  
    begin                      
       R:=RWNodeRequest(XR_STATUS);
       R:=R and (4095);    
       Memo1.Lines.Add('Request Status Return Value = ' + IntToStr(R));
    end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   R:Word;
begin
   R:=RWNodeRequest(XR_CANCEL);
   R:=R and (4095);    
   Memo1.Lines.Clear;
   Memo1.Lines.Add('Cancel Dialing/Abort Session Return Value = ' + IntToStr(R));
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   R:Word;
begin
   R:=RWNodeRequest(XR_RELEASE_PORT);                       
   R:=R and (4095);    
   Memo1.Lines.Clear;
   Memo1.Lines.Add('Release Comm Port Return Value = ' + IntToStr(R));
end;

procedure TForm1.Button3Click(Sender: TObject);
var
   R:Word;
begin
   R:=RWNodeRequest(XR_REINIT);
   R:=R and (4095);    
   Memo1.Lines.Clear;
   Memo1.Lines.Add('Reinitialize, reload nodeinit Return Value = ' + IntToStr(R));
end;

procedure TForm1.Button4Click(Sender: TObject);
var
   R:Word;
begin
   R:=RWNodeRequest(XR_REMOVE);
   R:=R and (4095);    
   Memo1.Lines.Clear;
   Memo1.Lines.Add('Remove Background Task Return Value = ' + IntToStr(R));
end;

procedure TForm1.GetStatusTimerChange(Sender: TObject);
begin
     StatTimer.Interval:=StrToInt(GetStatusTimer.Text);
end;

procedure TForm1.ChecksemTimeChange(Sender: TObject);
begin
     SemaTimer.Interval:=StrToInt(ChecksemTime.Text);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
     SignalPortInUse;
     ChecksemTime.Text  :=IntToStr(SemaTimer.Interval);
     GetStatusTimer.Text:=IntToStr(StatTimer.Interval);
end;

procedure TForm1.StatTimerTimer(Sender: TObject);
var
   R:Word;
begin
     R:=TestSemaphore;
     StatTimer.Interval:=StrToInt(GetStatusTimer.Text);
     if R=1 then
     begin
          SemStat.Caption:='Port Requested';
          SignalPortFree;
     end
     else if R=2 then
     begin
          SemStat.Caption:='Port In-Use';
     end  
     else if R=4 then
     begin
          SignalPortInUse;
          SemStat.Caption:='Port Available';
     end
     else
     begin
          SemStat.Caption:='Status ' + IntToStr(R);
     end;
end;     

procedure TForm1.FormHide(Sender: TObject);
begin
   SignalPortFree;
end;

end.
