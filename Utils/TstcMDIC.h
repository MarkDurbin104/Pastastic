//----------------------------------------------------------------------------
//  Project Testcom
//  
//  Copyright © 1996. All Rights Reserved.
//
//  SUBSYSTEM:    Testcom Application
//  FILE:         tstcmdic.h
//  AUTHOR:       
//
//  OVERVIEW
//  ~~~~~~~~
//  Class definition for TTestcomMDIClient (TMDIClient).
//
//----------------------------------------------------------------------------
#if !defined(tstcmdic_h)              // Sentry, use file only if it's not already included.
#define tstcmdic_h

#include "tstcmapp.rh"            // Definition of all resources.


//{{TMDIClient = TTestcomMDIClient}}
class TTestcomMDIClient : public TMDIClient {
  public:
    int      ChildCount;                 // Number of child window created.

    TTestcomMDIClient(TModule* module = 0);
    virtual ~TTestcomMDIClient();

    void OpenFile(const char* fileName = 0);

//{{TTestcomMDIClientVIRTUAL_BEGIN}}
  protected:
    virtual void SetupWindow();
//{{TTestcomMDIClientVIRTUAL_END}}

//{{TTestcomMDIClientRSP_TBL_BEGIN}}
  protected:
    void CmFilePrint();
    void CmFilePrintSetup();
    void CmFilePrintPreview();
    void CmPrintEnable(TCommandEnabler& tce);
    void EvDropFiles(TDropInfo);
//{{TTestcomMDIClientRSP_TBL_END}}
DECLARE_RESPONSE_TABLE(TTestcomMDIClient);
};    //{{TTestcomMDIClient}}


#endif  // tstcmdic_h sentry.
