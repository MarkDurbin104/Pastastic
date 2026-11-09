#if !defined(__tstwndwv_h)              // Sentry, use file only if it's not already included.
#define __tstwndwv_h

/*  Project test
    
    Copyright © 1994. All Rights Reserved.

    SUBSYSTEM:    test.exe Application
    FILE:         tstwndwv.h
    AUTHOR:       


    OVERVIEW
    ========
    Class definition for testWindowView (TWindowView).      
*/


#include <owl\owlpch.h>
#pragma hdrstop


#include "testapp.rh"            // Definition of all resources.


//{{TWindowView = testWindowView}}
class testWindowView : public TWindowView {
public:
    testWindowView (TDocument& doc, TWindow* parent = 0);
    virtual ~testWindowView ();

//{{testWindowViewVIRTUAL_BEGIN}}
public:
    virtual void Paint (TDC& dc, bool erase, TRect& rect);
//{{testWindowViewVIRTUAL_END}}
//{{testWindowViewRSP_TBL_BEGIN}}
protected:
    void EvGetMinMaxInfo (MINMAXINFO far& minmaxinfo);
//{{testWindowViewRSP_TBL_END}}
DECLARE_RESPONSE_TABLE(testWindowView);
};    //{{testWindowView}}


#endif                                      // __tstwndwv_h sentry.
