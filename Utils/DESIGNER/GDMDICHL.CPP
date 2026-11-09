/*  Project gd
    Unisys Ltd.
    Copyright Unisys Ltd. © 1994. All Rights Reserved.

    SUBSYSTEM:    gd.exe Application
    FILE:         gdmdichl.cpp
    AUTHOR:       Mark Durbin


    OVERVIEW
    ========
    Source file for implementation of gdMDIChild (TMDIChild).      
*/


#include <owl\owlpch.h>
#pragma hdrstop

#include "gd.h"
#include "gdmdichl.h"

#include <stdio.h>


//{{gdMDIChild Implementation}}


//
// Build a response table for all messages/commands handled
// by gdMDIChild derived from TMDIChild.
//
DEFINE_RESPONSE_TABLE1(gdMDIChild, TMDIChild)
//{{gdMDIChildRSP_TBL_BEGIN}}
    EV_WM_GETMINMAXINFO,
//{{gdMDIChildRSP_TBL_END}}
END_RESPONSE_TABLE;


//////////////////////////////////////////////////////////
// gdMDIChild
// ==========
// Construction/Destruction handling.
gdMDIChild::gdMDIChild (TMDIClient &parent, const char far *title, TWindow *clientWnd, BOOL shrinkToClient, TModule *module)
    : TMDIChild (parent, title, clientWnd == 0 ? new TEditFile(0, 0, 0) : clientWnd, shrinkToClient, module)
{
    // INSERT>> Your constructor code here.

}


gdMDIChild::~gdMDIChild ()
{
    Destroy();

    // INSERT>> Your destructor code here.

}


//
// Paint routine for Window, Printer, and PrintPreview for an TEdit client.
//
void gdMDIChild::Paint (TDC& dc, BOOL, TRect& rect)
{
    gdApp *theApp = TYPESAFE_DOWNCAST(GetApplication(), gdApp);
    if (theApp) {
        // Only paint if we're printing and we have something to paint, otherwise do nothing.
        if (theApp->Printing && theApp->Printer && !rect.IsEmpty()) {
            // Use pageSize to get the size of the window to render into.  For a Window it's the client area,
            // for a printer it's the printer DC dimensions and for print preview it's the layout window.
            TSize   pageSize(rect.right - rect.left, rect.bottom - rect.top);

            HFONT   hFont = (HFONT)GetClientWindow()->GetWindowFont();
            TFont   font("Arial", -12);
            if (hFont == 0)
              dc.SelectObject(font);
            else
              dc.SelectObject(TFont(hFont));
    
            TEXTMETRIC  tm;
            int fHeight = (dc.GetTextMetrics(tm) == TRUE) ? tm.tmHeight + tm.tmExternalLeading : 10;
    
            // How many lines of this font can we fit on a page.
            int linesPerPage = MulDiv(pageSize.cy, 1, fHeight);
            if (linesPerPage) {    
                TPrintDialog::TData &printerData = theApp->Printer->GetSetup();

                int maxPg = 1;

                // Get the client class window (this is the contents we're going to print).
                TEdit *clientEditWindow = 0;
                TListBox *clientListWindow = 0;

                clientEditWindow = TYPESAFE_DOWNCAST(GetClientWindow(), TEdit);
                if (clientEditWindow)
                    maxPg = ((clientEditWindow->GetNumLines() / linesPerPage) + 1.0);
                else {
                    clientListWindow = TYPESAFE_DOWNCAST(GetClientWindow(), TListBox);
                    if (clientListWindow)
                        maxPg = ((clientListWindow->GetCount() / linesPerPage) + 1.0);
                }

                // Compute the number of pages to print.
                printerData.MinPage = 1;
                printerData.MaxPage = maxPg;

                // Do the text stuff:
                int     fromPage = printerData.FromPage == -1 ? 1 : printerData.FromPage;
                int     toPage = printerData.ToPage == -1 ? 1 : printerData.ToPage;
                char    buffer[255];
                int     currentPage = fromPage;

                while (currentPage <= toPage) {
                    int startLine = (currentPage - 1) * linesPerPage;
                    int lineIdx = 0;
                    while (lineIdx < linesPerPage) {
                        // If the string is no longer valid then there's nothing more to display.
                        if (clientEditWindow) {
                            if (!clientEditWindow->GetLine(buffer, sizeof(buffer), startLine + lineIdx))
                                break;
                        }
                        if (clientListWindow) {
                            if (clientListWindow->GetString(buffer, startLine + lineIdx) < 0)
                                break;
                        }
                        dc.TabbedTextOut(TPoint(0, lineIdx * fHeight), buffer, lstrlen(buffer), 0, NULL, 0);
                        lineIdx++;
                    }
                    currentPage++;
                }
            }
        }
    }
}


void gdMDIChild::EvGetMinMaxInfo (MINMAXINFO far& minmaxinfo)
{
    gdApp *theApp = TYPESAFE_DOWNCAST(GetApplication(), gdApp);
    if (theApp) {
        if (theApp->Printing) {
            minmaxinfo.ptMaxSize = TPoint(32000, 32000);
            minmaxinfo.ptMaxTrackSize = TPoint(32000, 32000);
            return;
        }
    }
    TMDIChild::EvGetMinMaxInfo(minmaxinfo);
}
