//----------------------------------------------------------------------------
//  Project Testcom
//  
//  Copyright © 1996. All Rights Reserved.
//
//  SUBSYSTEM:    Testcom Application
//  FILE:         tstcmdlc.h
//  AUTHOR:       
//
//  OVERVIEW
//  ~~~~~~~~
//  Class definition for TTestcomDlgClient (TDialog).
//
//----------------------------------------------------------------------------
#if !defined(tstcmdlc_h)              // Sentry, use file only if it's not already included.
#define tstcmdlc_h

#include <owl/docview.h>

#include "tstcmapp.rh"                  // Definition of all resources.


//{{TDialog = TTestcomDlgClient}}
class TTestcomDlgClient : public TDialog, public TView {
  public:
//  TTestcomDlgClient(TWindow* parent, TResId resId = IDD_CLIENT, TModule* module = 0);  //{{DIALOG_ASSOCIATION}}

    TTestcomDlgClient(TDocument& doc, TWindow* parent = 0);
    virtual ~TTestcomDlgClient();

    static const char far* StaticName() {return "Dialog View";}  // put in resource

    // Inherited virtuals from TView
    //
    const char far* GetViewName() {return StaticName();}
    TWindow* GetWindow() {return(TWindow*)this;}
    bool     SetDocTitle(const char far* docname, int index)
             { return TWindow::SetDocTitle(docname, index); }
  private:
    // Event handlers
    //
    bool     VnIsWindow(HWND hWnd)
             { return ((HWindow == hWnd) || IsChild(hWnd)); }

//{{TTestcomDlgClientVIRTUAL_BEGIN}}
  public:
    virtual bool CanClose();
//{{TTestcomDlgClientVIRTUAL_END}}

//{{TTestcomDlgClientRSP_TBL_BEGIN}}
  protected:
//{{TTestcomDlgClientRSP_TBL_END}}
DECLARE_RESPONSE_TABLE(TTestcomDlgClient);
};    //{{TTestcomDlgClient}}


#endif  // tstcmdlc_h sentry.
