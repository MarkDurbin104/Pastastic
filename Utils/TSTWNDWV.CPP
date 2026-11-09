/*  Project test
    
    Copyright © 1994. All Rights Reserved.

    SUBSYSTEM:    test.exe Application
    FILE:         tstwndwv.cpp
    AUTHOR:       


    OVERVIEW
    ========
    Source file for implementation of testWindowView (TWindowView).      
*/


#include <owl\owlpch.h>
#pragma hdrstop

#include "testapp.h"
#include "tstwndwv.h"

#include <stdio.h>


//{{testWindowView Implementation}}


//
// Build a response table for all messages/commands handled
// by testWindowView derived from TWindowView.
//
DEFINE_RESPONSE_TABLE1(testWindowView, TWindowView)
//{{testWindowViewRSP_TBL_BEGIN}}
    EV_WM_GETMINMAXINFO,
//{{testWindowViewRSP_TBL_END}}
END_RESPONSE_TABLE;


//////////////////////////////////////////////////////////
// testWindowView
// ==========
// Construction/Destruction handling.
testWindowView::testWindowView (TDocument& doc, TWindow* parent)
    : TWindowView(doc, parent)
{
    // INSERT>> Your constructor code here.

}


testWindowView::~testWindowView ()
{
    // INSERT>> Your destructor code here.

}


//
// Paint routine for Window, Printer, and PrintPreview for a TWindowView client.
//
void testWindowView::Paint (TDC&, bool, TRect& rect)
{
    testApp *theApp = TYPESAFE_DOWNCAST(GetApplication(), testApp);
    if (theApp) {
        // Only paint if we're printing and we have something to paint, otherwise do nothing.
        if (theApp->Printing && theApp->Printer && !rect.IsEmpty()) {
            // Use pageSize to get the size of the window to render into.  For a Window it's the client area,
            // for a printer it's the printer DC dimensions and for print preview it's the layout window.
            TSize   pageSize(rect.right - rect.left, rect.bottom - rect.top);

            TPrintDialog::TData &printerData = theApp->Printer->GetSetup();

            // Compute the number of pages to print.
            printerData.MinPage = 1;
            printerData.MaxPage = 1;

            // INSERT>> Special printing code goes here.

        } else {
            // INSERT>> Normal painting code goes here.

        }
    }
}


void testWindowView::EvGetMinMaxInfo (MINMAXINFO far& minmaxinfo)
{
    testApp *theApp = TYPESAFE_DOWNCAST(GetApplication(), testApp);
    if (theApp) {
        if (theApp->Printing) {
            minmaxinfo.ptMaxSize = TPoint(32000, 32000);
            minmaxinfo.ptMaxTrackSize = TPoint(32000, 32000);
            return;
        }
    }
    TWindowView::EvGetMinMaxInfo(minmaxinfo);
}
