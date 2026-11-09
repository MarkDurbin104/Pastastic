#if !defined(__gdabtdlg_h)              // Sentry, use file only if it's not already included.
#define __gdabtdlg_h

/*  Project gd
    Unisys Ltd.
    Copyright Unisys Ltd. © 1994. All Rights Reserved.

    SUBSYSTEM:    gd.exe Application
    FILE:         gdabtdlg.h
    AUTHOR:       Mark Durbin


    OVERVIEW
    ========
    Class definition for gdAboutDlg (TDialog).      
*/


#include <owl\owlpch.h>
#pragma hdrstop

#include "gd.rh"                  // Definition of all resources.


//{{TDialog = gdAboutDlg}}
class gdAboutDlg : public TDialog {
public:
    gdAboutDlg (TWindow *parent, TResId resId = IDD_ABOUT, TModule *module = 0);
    virtual ~gdAboutDlg ();

//{{gdAboutDlgVIRTUAL_BEGIN}}
public:
    void SetupWindow ();
//{{gdAboutDlgVIRTUAL_END}}
};    //{{gdAboutDlg}}


#endif                                      // __gdabtdlg_h sentry.
