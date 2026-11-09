//----------------------------------------------------------------------------
//  Project Testcom
//  
//  Copyright © 1996. All Rights Reserved.
//
//  SUBSYSTEM:    Testcom Application
//  FILE:         tstcmapp.h
//  AUTHOR:       
//
//  OVERVIEW
//  ~~~~~~~~
//  Class definition for TTestcomApp (TApplication).
//
//----------------------------------------------------------------------------
#if !defined(tstcmapp_h)              // Sentry, use file only if it's not already included.
#define tstcmapp_h

#include <owl/controlb.h>
#include <owl/docking.h>
#include <owl/mailer.h>
#include <owl/olemdifr.h>
#include <owl/printer.h>
#include <owl/rcntfile.h>

#include <ocf/automacr.h>

#include <classlib/bags.h>

#include "tstcmdic.h"

#include "tstcmapp.rh"            // Definition of all resources.


//{{TApplication = TTestcomApp}}
class TTestcomApp : public TApplication, public TOcModule, public TRecentFiles {
  private:
    void SetupSpeedBar(TOleMDIFrame* frame);
    void AddFiles(TFileDropletList& files);
    void ProcessCmdLine(char * CmdLine);
    void RegisterInfo();
    void UnRegisterInfo();

  public:
    TTestcomApp();
    virtual ~TTestcomApp();

    void CreateGadgets(TControlBar *cb, bool server = false);

    TTestcomMDIClient* MdiClient;

    // Public data members used by the print menu commands and Paint routine in MDIChild.
    //
    TPrinter*       Printer;                           // Printer support.
    int             Printing;                          // Printing in progress.

    TMailer*        ApxMail;

//{{TTestcomAppVIRTUAL_BEGIN}}
  public:
    virtual void InitMainWindow();
    virtual void InitInstance();
//{{TTestcomAppVIRTUAL_END}}

//{{TTestcomAppRSP_TBL_BEGIN}}
  protected:
    void EvNewView(TView& view);
    void EvCloseView(TView& view);
    void CeFileSend(TCommandEnabler& ce);
    void CmFileSend();
    void CmHelpAbout();
    void EvDropFiles(TDropInfo drop);
    void EvWinIniChange(char far* section);
    void EvOwlDocument(TDocument& doc);
    int32 CmFileSelected(uint wp, int32 lp);
//{{TTestcomAppRSP_TBL_END}}

DECLARE_AUTOAGGREGATE(TTestcomApp)
AUTODETACH
//{{TTestcomAppAUTO_TBL_BEGIN}}
//{{TTestcomAppAUTO_TBL_END}}

DECLARE_RESPONSE_TABLE(TTestcomApp);
};    //{{TTestcomApp}}


#endif  // tstcmapp_h sentry.
