/*  Project gd
    Unisys Ltd.
    Copyright Unisys Ltd. © 1994. All Rights Reserved.

    SUBSYSTEM:    gd.exe Application
    FILE:         gdmdicln.cpp
    AUTHOR:       Mark Durbin


    OVERVIEW
    ========
    Source file for implementation of gdMDIClient (TMDIClient).      
*/


#include <owl\owlpch.h>
#pragma hdrstop

#include <dir.h>

#include "gd.h"
#include "gdmdicln.h"
#include "gdmdichl.h"
#include "apxprint.h"
#include "apxprev.h"


//{{gdMDIClient Implementation}}


//
// Build a response table for all messages/commands handled
// by gdMDIClient derived from TMDIClient.
//
DEFINE_RESPONSE_TABLE1(gdMDIClient, TMDIClient)
//{{gdMDIClientRSP_TBL_BEGIN}}
    EV_COMMAND(CM_MDIFILENEW, CmFileNew),
    EV_COMMAND(CM_MDIFILEOPEN, CmFileOpen),
    EV_COMMAND(CM_FILEPRINT, CmFilePrint),
    EV_COMMAND(CM_FILEPRINTERSETUP, CmFilePrintSetup),
    EV_COMMAND(CM_FILEPRINTPREVIEW, CmFilePrintPreview),
    EV_COMMAND_ENABLE(CM_FILEPRINT, CmPrintEnable),
    EV_COMMAND_ENABLE(CM_FILEPRINTERSETUP, CmPrintEnable),
    EV_COMMAND_ENABLE(CM_FILEPRINTPREVIEW, CmPrintEnable),
    EV_WM_DROPFILES,
//{{gdMDIClientRSP_TBL_END}}
END_RESPONSE_TABLE;


//////////////////////////////////////////////////////////
// gdMDIClient
// ===========
// Construction/Destruction handling.
 gdMDIClient::gdMDIClient ()
 : TMDIClient ()
{
    // Change the window's background color
    SetBkgndColor(RGB(0xc0, 0xc0, 0xc0));

    ChildCount = 0;

    // INSERT>> Your constructor code here.

}


 gdMDIClient::~gdMDIClient ()
{
    Destroy();

    // INSERT>> Your destructor code here.

}


//////////////////////////////////////////////////////////
// gdMDIClient
// ===========
// MDIClient site initialization.
void gdMDIClient::SetupWindow ()
{
    // Default SetUpWindow processing.
    TMDIClient::SetupWindow ();

    // Common file file flags and filters for Open/Save As dialogs.  Filename and directory are
    // computed in the member functions CmFileOpen, and CmFileSaveAs.
    FileData.Flags = OFN_FILEMUSTEXIST | OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT;
    FileData.SetFilter("All Files (*.*)|*.*|");

    // Accept files via drag/drop in the client window.
    DragAcceptFiles(TRUE);
}


//////////////////////////////////////////////////////////
// gdMDIClient
// ===========
// Menu File New command
void gdMDIClient::CmFileNew ()
{
    char    title[255];

    // Generate a title for the MDI child window.
    wsprintf(title, "%d", ChildCount++);

    gdMDIChild* child = new gdMDIChild(*this, title, 0);

    // Associate ICON w/ this child window.
    child->SetIcon(GetApplication(), IDI_DOC);

    // If the current active MDI child is maximize then this one should be also.
    gdMDIChild *curChild = (gdMDIChild *)GetActiveMDIChild();
    if (curChild && (curChild->GetWindowLong(GWL_STYLE) & WS_MAXIMIZE))
        child->Attr.Style |= WS_MAXIMIZE;

    child->Create();
}


void gdMDIClient::OpenFile (const char *fileName)
{
    if (fileName)
        lstrcpy(FileData.FileName, fileName);

    //
    // Create a MDIChild window whose client is TEditFile.
    //
    gdMDIChild* child = new gdMDIChild(*this, "", new TEditFile(0, 0, 0, 0, 0, 0, 0, FileData.FileName));

    // Associate ICON w/ this child window.
    child->SetIcon(GetApplication(), IDI_DOC);

    // If the current active MDI child is maximize then this one should be also.
    gdMDIChild *curChild = (gdMDIChild *)GetActiveMDIChild();
    if (curChild && (curChild->GetWindowLong(GWL_STYLE) & WS_MAXIMIZE))
        child->Attr.Style |= WS_MAXIMIZE;

    child->Create();

    LoadTextFile();
}


//////////////////////////////////////////////////////////
// gdMDIClient
// ===========
// Menu File Open command
void gdMDIClient::CmFileOpen ()
{
    //
    // Display standard Open dialog box to select a file name.
    //
    *FileData.FileName = 0;
    if (TFileOpenDialog(this, FileData).Execute() == IDOK)
        OpenFile();
}


// Used by ListBox client to read a text file into the list box.
void gdMDIClient::LoadTextFile ()
{
    char            buf[255+1];
    ifstream        *inStream;

    gdMDIChild  *curChild = (gdMDIChild *)GetActiveMDIChild();
    TListBox        *client = TYPESAFE_DOWNCAST(curChild->GetClientWindow(), TListBox);

    // Only work if the client class is a TListBox.
    if (client) {
        client->ClearList();
        inStream = new ifstream(FileData.FileName);
        while (inStream->good()) {
            inStream->getline(buf, sizeof(buf) - 1);
            if (inStream->good())
                client->AddString(buf);
        }

        // Return an error message if we had a stream error and it wasn't the eof.
        if (inStream->bad() && !inStream->eof()) {
            string msgTemplate(*GetModule(), IDS_UNABLEREAD);
            char*  msg = new char[MAXPATH + msgTemplate.length()];
            wsprintf(msg, msgTemplate.c_str(), *FileData.FileName);
            MessageBox(msg, GetApplication()->GetName(), MB_ICONEXCLAMATION | MB_OK);
            delete msg;
        }

        delete inStream;
    }
}


//////////////////////////////////////////////////////////
// gdMDIClient
// ==========
// Menu File Print command
void gdMDIClient::CmFilePrint ()
{
    //
    // Create Printer object if not already created.
    // 
    gdApp *theApp = TYPESAFE_DOWNCAST(GetApplication(), gdApp);
    if (theApp) {
        if (!theApp->Printer)
            theApp->Printer = new TPrinter;

        //
        // Create Printout window and set characteristics.
        //
        APXPrintOut printout(theApp->Printer, Title, GetActiveMDIChild(), TRUE);

        theApp->Printing = TRUE;

        //
        // Bring up the Print dialog and print the document.
        //
        theApp->Printer->Print(GetActiveMDIChild()->GetClientWindow(), printout, TRUE);

        theApp->Printing = FALSE;
    }
}


//////////////////////////////////////////////////////////
// gdMDIClient
// ==========
// Menu File Print Setup command
void gdMDIClient::CmFilePrintSetup ()
{
    gdApp *theApp = TYPESAFE_DOWNCAST(GetApplication(), gdApp);
    if (theApp) {
        if (!theApp->Printer)
            theApp->Printer = new TPrinter;

        //
        // Bring up the Print Setup dialog.
        //
        theApp->Printer->Setup(this);
    }
}


//////////////////////////////////////////////////////////
// gdMDIClient
// ==========
// Menu File Print Preview command
void gdMDIClient::CmFilePrintPreview ()
{
    gdApp *theApp = TYPESAFE_DOWNCAST(GetApplication(), gdApp);
    if (theApp) {
        if (!theApp->Printer)
            theApp->Printer = new TPrinter;

        theApp->Printing = TRUE;

        PreviewWindow *prevW = new PreviewWindow(Parent, theApp->Printer, GetActiveMDIChild(), "Print Preview", new TLayoutWindow(0));
        prevW->Create();

        GetApplication()->BeginModal(GetApplication()->MainWindow);

        // We must destroy the preview window explicitly.  Otherwise, the window will not be destroyed until
        // it's parent the MainWindow is destroyed.
        prevW->Destroy();
        delete prevW;

        theApp->Printing = FALSE;
    }
}


//////////////////////////////////////////////////////////
// gdMDIClient
// ==========
// Menu enabler used by Print, Print Setup and Print Preview.
void gdMDIClient::CmPrintEnable (TCommandEnabler &tce)
{
    if (GetActiveMDIChild()) {
        gdApp *theApp = TYPESAFE_DOWNCAST(GetApplication(), gdApp);
        if (theApp) {
            // If we have a Printer already created just test if all is okay.
            // Otherwise create a Printer object and make sure the printer
            // really exists and then delete the Printer object.
            if (!theApp->Printer) {
                theApp->Printer = new TPrinter;
                
                tce.Enable(theApp->Printer->GetSetup().Error == 0);
            } else
                tce.Enable(theApp->Printer->GetSetup().Error == 0);
        }
    } else
        tce.Enable(FALSE);
}


void gdMDIClient::EvDropFiles (TDropInfo)
{
    Parent->ForwardMessage();
}
