//----------------------------------------------------------------------------
//  Project Testcom
//  
//  Copyright © 1996. All Rights Reserved.
//
//  SUBSYSTEM:    Testcom Application
//  FILE:         tstcmabd.h
//  AUTHOR:       
//
//  OVERVIEW
//  ~~~~~~~~
//  Class definition for TTestcomAboutDlg (TDialog).
//
//----------------------------------------------------------------------------
#if !defined(tstcmabd_h)              // Sentry, use file only if it's not already included.
#define tstcmabd_h

#include <owl/static.h>

#include "tstcmapp.rh"                  // Definition of all resources.


//{{TDialog = TTestcomAboutDlg}}
class TTestcomAboutDlg : public TDialog {
  public:
    TTestcomAboutDlg(TWindow* parent, TResId resId = IDD_ABOUT, TModule* module = 0);
    virtual ~TTestcomAboutDlg();

//{{TTestcomAboutDlgVIRTUAL_BEGIN}}
  public:
    void SetupWindow();
//{{TTestcomAboutDlgVIRTUAL_END}}
};    //{{TTestcomAboutDlg}}


// Reading the VERSIONINFO resource.
//
class TProjectRCVersion {
  public:
    TProjectRCVersion(TModule* module);
    virtual ~TProjectRCVersion();

    bool GetProductName(LPSTR& prodName);
    bool GetProductVersion(LPSTR& prodVersion);
    bool GetCopyright(LPSTR& copyright);
    bool GetDebug(LPSTR& debug);

  protected:
    uint8 far*  TransBlock;
    void far*   FVData;

  private:
    // Don't allow this object to be copied.
    //
    TProjectRCVersion(const TProjectRCVersion&);
    TProjectRCVersion& operator = (const TProjectRCVersion&);
};


#endif  // tstcmabd_h sentry.
