//----------------------------------------------------------------------------
//  Project Testcom
//  
//  Copyright © 1996. All Rights Reserved.
//
//  SUBSYSTEM:    Testcom Application
//  FILE:         tstcmolv.h
//  AUTHOR:       
//
//  OVERVIEW
//  ~~~~~~~~
//  Class definition for TTestcomOleView (TOleView).
//
//----------------------------------------------------------------------------
#if !defined(tstcmolv_h)              // Sentry, use file only if it's not already included.
#define tstcmolv_h

#include <owl/oleview.h>

#include "tstcmapp.rh"            // Definition of all resources.


//{{TOleView = TTestcomOleView}}
class TTestcomOleView : public TOleView {
  public:
    TTestcomOleView(TDocument& doc, TWindow* parent = 0);
    virtual ~TTestcomOleView();

  private:
    TControlBar* ToolBar;

//{{TTestcomOleViewVIRTUAL_BEGIN}}
  public:
    virtual void Paint(TDC& dc, bool erase, TRect& rect);
//{{TTestcomOleViewVIRTUAL_END}}
//{{TTestcomOleViewRSP_TBL_BEGIN}}
  protected:
    void EvGetMinMaxInfo(MINMAXINFO far& minmaxinfo);
    bool EvOcViewShowTools(TOcToolBarInfo far& tbi);
//{{TTestcomOleViewRSP_TBL_END}}
DECLARE_RESPONSE_TABLE(TTestcomOleView);
};    //{{TTestcomOleView}}


#endif  // tstcmolv_h sentry.
