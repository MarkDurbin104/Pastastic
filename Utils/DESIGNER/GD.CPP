/*  Project gd
    Unisys Ltd.
    Copyright Unisys Ltd. © 1994. All Rights Reserved.

    SUBSYSTEM:    gd.exe Application
    FILE:         gd.cpp
    AUTHOR:       Mark Durbin


    OVERVIEW
    ========
    Source file for implementation of gdApp (TApplication).      
*/


#include <owl\owlpch.h>
#pragma hdrstop

#include <dir.h>

#include "gd.h"
#include "gdmdicln.h"
#include "gdabtdlg.h"                        // Definition of about dialog.       


//
// Generated help file.
//
const char HelpFileName[] = "gd.hlp";


// Drag / Drop support:
TFileDrop::TFileDrop (char* fileName, TPoint& p, BOOL inClient, TModule* module)
{
    char    exePath[MAXPATH];
    
    exePath[0] = 0;
    FileName = strcpy(new char[strlen(fileName) + 1], fileName);
    Point = p;
    InClientArea = inClient;
    
    Icon = (WORD)FindExecutable(FileName, ".\\", exePath) <= 32 ? 0 : ::ExtractIcon(*module, exePath, 0);

    // Use a question mark if couldn't get the icon from the executable.
	 //
    if ((WORD)Icon <= 1) {  // 0=no icons in exe,  1=not an exe
        Icon = LoadIcon(0, (WORD)Icon == 1 ? IDI_APPLICATION : IDI_QUESTION);
        DefIcon = TRUE;
    } else
		  DefIcon = FALSE;
}

TFileDrop::~TFileDrop ()
{
    delete FileName;
    if (!DefIcon)
        FreeResource(Icon);
}

const char *TFileDrop::WhoAmI ()
{
  return FileName;
}


//{{gdApp Implementation}}

//
// Build a response table for all messages/commands handled
// by the application.
//
DEFINE_RESPONSE_TABLE1(gdApp, TApplication)
//{{gdAppRSP_TBL_BEGIN}}
	 EV_COMMAND(CM_HELPCONTENTS, CmHelpContents),
	 EV_COMMAND(CM_HELPUSING, CmHelpUsing),
	 EV_COMMAND(CM_HELPABOUT, CmHelpAbout),
	 EV_WM_DROPFILES,
	 EV_WM_WININICHANGE,
//{{gdAppRSP_TBL_END}}
END_RESPONSE_TABLE;


//////////////////////////////////////////////////////////
// gdApp
// =====
//
gdApp::gdApp () : TApplication("GPA Designer")
{
    HelpState = FALSE;
    ContextHelp = FALSE;
    HelpCursor = 0;

    Printer = 0;
	 Printing = FALSE;

    // INSERT>> Your constructor code here.

}


gdApp::~gdApp ()
{
    if (Printer)
        delete Printer;

    // INSERT>> Your destructor code here.

}


BOOL gdApp::CanClose ()
{
    BOOL result = TApplication::CanClose();

    //
	 // Close the help engine if we used it.
    //
    if (result && HelpState)
        MainWindow->WinHelp(HelpFileName, HELP_QUIT, 0L);
 
    return result;
}


void gdApp::SetupSpeedBar (TDecoratedMDIFrame *frame)
{ 
    //
    // Create default toolbar New and associate toolbar buttons with commands.
    //   
    TControlBar* cb = new TControlBar(frame);
    cb->Insert(*new TButtonGadget(CM_MDIFILENEW, CM_MDIFILENEW));
    cb->Insert(*new TButtonGadget(CM_MDIFILEOPEN, CM_MDIFILEOPEN));
    cb->Insert(*new TButtonGadget(CM_FILESAVE, CM_FILESAVE));
    cb->Insert(*new TSeparatorGadget(6));
    cb->Insert(*new TButtonGadget(CM_EDITCUT, CM_EDITCUT));
    cb->Insert(*new TButtonGadget(CM_EDITCOPY, CM_EDITCOPY));
    cb->Insert(*new TButtonGadget(CM_EDITPASTE, CM_EDITPASTE));
	 cb->Insert(*new TSeparatorGadget(6));
    cb->Insert(*new TButtonGadget(CM_EDITUNDO, CM_EDITUNDO));
//    cb->Insert(*new TSeparatorGadget(6));
//    cb->Insert(*new TButtonGadget(CM_TOOLFORM, CM_TOOLFORM));
//    cb->Insert(*new TButtonGadget(CM_TOOLACTION, CM_TOOLACTION));
	 cb->Insert(*new TSeparatorGadget(6));
	 cb->Insert(*new TButtonGadget(CM_FILEPRINT, CM_FILEPRINT));
	 cb->Insert(*new TButtonGadget(CM_FILEPRINTPREVIEW, CM_FILEPRINTPREVIEW));
	 cb->Insert(*new TSeparatorGadget(6));
	 cb->Insert(*new TButtonGadget(CM_HELPCONTENTS, CM_HELPCONTENTS));

	 // Add fly-over help hints.
	 cb->SetHintMode(TGadgetWindow::EnterHints);

	 frame->Insert(*cb, TDecoratedFrame::Top);
}


//////////////////////////////////////////////////////////
// gdApp
// =====
// Application intialization.
//
void gdApp::InitMainWindow ()
{
	 TDecoratedMDIFrame* frame = new TDecoratedMDIFrame(Name, MDI_MENU, *(new gdMDIClient), TRUE);

	 // Override the default window style for the main window.
	 frame->Attr.Style |= WS_BORDER | WS_CAPTION | WS_CLIPCHILDREN | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU | WS_THICKFRAME | WS_VISIBLE;
	 frame->Attr.Style &= ~(WS_CHILD);

	 nCmdShow = (nCmdShow != SW_SHOWMINNOACTIVE) ? SW_SHOWNORMAL : nCmdShow;

	 //
	 // Assign ICON w/ this application.
	 //
	 frame->SetIcon(this, IDI_MDIAPPLICATION);

	 //
	 // Menu associated with window and accelerator table associated with table.
	 //
	 frame->AssignMenu(MDI_MENU);
	 
	 //
	 // Associate with the accelerator table.
    //
    frame->Attr.AccelTable = MDI_MENU;


    SetupSpeedBar(frame);

    TStatusBar *sb = new TStatusBar(frame, TGadget::Recessed,
                                    TStatusBar::CapsLock        |
                                    TStatusBar::NumLock         |
                                    TStatusBar::ScrollLock      |
                                    TStatusBar::Overtype);
    frame->Insert(*sb, TDecoratedFrame::Bottom);
  
    MainWindow = frame;

    //
    // Windows 3-D controls.
    //
    EnableCtl3d(TRUE);
}


//////////////////////////////////////////////////////////
// gdApp
// =====
// Menu Help Contents command
void gdApp::CmHelpContents ()
{
    //
    // Show the help table of contents.
    //
    HelpState = MainWindow->WinHelp(HelpFileName, HELP_CONTENTS, 0L);
}


//////////////////////////////////////////////////////////
// gdApp
// =====
// Menu Help Using Help command
void gdApp::CmHelpUsing ()
{
    //
    // Display the contents of the Windows help file.
    //
    HelpState = MainWindow->WinHelp(HelpFileName, HELP_HELPONHELP, 0L);
}


//////////////////////////////////////////////////////////
// gdApp
// ===========
// Menu Help About gd.exe command
void gdApp::CmHelpAbout ()
{
    //
    // Show the modal dialog.
    //
    gdAboutDlg(MainWindow).Execute();
}


void gdApp::InitInstance ()
{
    TApplication::InitInstance();

    // Accept files via drag/drop in the frame window.
    MainWindow->DragAcceptFiles(TRUE);
}


void gdApp::EvDropFiles (TDropInfo drop)
{
    // Number of files dropped.
    int totalNumberOfFiles = drop.DragQueryFileCount();

    TFileList* files = new TFileList;

    for (int i = 0; i < totalNumberOfFiles; i++) {
        // Tell DragQueryFile the file interested in (i) and the length of your buffer.
        int     fileLength = drop.DragQueryFileNameLen(i) + 1;
        char    *fileName = new char[fileLength];

        drop.DragQueryFile(i, fileName, fileLength);

        // Getting the file dropped. The location is relative to your client coordinates,
        // and will have negative values if dropped in the non client parts of the window.
        //
        // DragQueryPoint copies that point where the file was dropped and returns whether
        // or not the point is in the client area.  Regardless of whether or not the file
        // is dropped in the client or non-client area of the window, you will still receive
        // the file name.
        TPoint  point;
        BOOL    inClientArea = drop.DragQueryPoint(point);
        files->Add(new TFileDrop(fileName, point, inClientArea, this));
    }

    // Open the files that were dropped.
    AddFiles(files);

    // Release the memory allocated for this handle with DragFinish.
    drop.DragFinish();
}


void gdApp::AddFiles (TFileList* files)
{
    // Open all files dragged in.
    TFileListIter fileIter(*files);

    TFrameWindow *tfw = TYPESAFE_DOWNCAST(MainWindow, TFrameWindow);
    if (tfw) {
        gdMDIClient *theClient = TYPESAFE_DOWNCAST(tfw->GetClientWindow(), gdMDIClient);

        if (theClient)
            while (fileIter) {
                theClient->OpenFile(fileIter.Current()->WhoAmI());
                fileIter++;
            }
    }
}


BOOL gdApp::ProcessAppMsg (MSG& msg)
{
    if (msg.message == WM_COMMAND) {
        if (ContextHelp || (GetKeyState(VK_F1) < 0)) {
            ContextHelp = FALSE;
            MainWindow->WinHelp(HelpFileName, HELP_CONTEXT, msg.wParam);
            return TRUE;
        }
    } else
        switch (msg.message) {
        case WM_KEYDOWN:
            if (msg.wParam == VK_F1) {
                // If the Shift/F1 then set the help cursor and turn on the modal help state.
                if (::GetKeyState(VK_SHIFT) < 0) {
                    ContextHelp = TRUE;
                    HelpCursor = ::LoadCursor(MainWindow->GetModule()->GetInstance(), MAKEINTRESOURCE(IDC_HELPCURSOR));
                    ::SetCursor(HelpCursor);
                    return TRUE;        // Gobble up the message.
                } else {
                    // If F1 w/o the Shift key then bring up help's main index.
                    MainWindow->WinHelp(HelpFileName, HELP_INDEX, 0L);
                    return TRUE;        // Gobble up the message.
                }
            } else {
                if (ContextHelp && (msg.wParam == VK_ESCAPE)) {
                    if (HelpCursor)
                        ::DestroyCursor(HelpCursor);
                    ContextHelp = FALSE;
                    HelpCursor = 0;
                    MainWindow->SetCursor(0, IDC_ARROW);
                    return TRUE;    // Gobble up the message.
                }
            }
            break;

        case WM_MOUSEMOVE:
        case WM_NCMOUSEMOVE:
            if (ContextHelp) {
                ::SetCursor(HelpCursor);
                return TRUE;        // Gobble up the message.
            }
            break;

        case WM_INITMENU:
            if (ContextHelp) {
                ::SetCursor(HelpCursor);
                return TRUE;        // Gobble up the message.
            }
            break;
        
        case WM_ENTERIDLE:
            if (msg.wParam == MSGF_MENU)
                if (GetKeyState(VK_F1) < 0) {
                ContextHelp = TRUE;
                MainWindow->PostMessage(WM_KEYDOWN, VK_RETURN, 0L);
                return TRUE;       // Gobble up the message.
            }
            break;
        
        default:
            ;
        };  // End of switch

    // Continue normal processing.
    return TApplication::ProcessAppMsg(msg);
}


void gdApp::EvWinIniChange (char far* section)
{
    if (lstrcmp(section, "windows") == 0) {
        // If the device changed in the WIN.INI file then the printer
        // might have changed.  If we have a TPrinter (Printer) then
        // check and make sure it's identical to the current device
        // entry in WIN.INI.
        if (Printer) {
            char printDBuffer[255];
            LPSTR printDevice = printDBuffer;
            LPSTR devName = 0;
            LPSTR driverName = 0;
            LPSTR outputName = 0;
        
            if (::GetProfileString("windows", "device", "", printDevice, sizeof(printDevice))) {
                // The string which should come back is something like:
                //
                //      HP LaserJet III,hppcl5a,LPT1:
                //
                // Where the format is:
                //
                //      devName,driverName,outputName
                //
                devName = printDevice;
                while (*printDevice) {
                    if (*printDevice == ',') {
                        *printDevice++ = 0;
                        if (!driverName)
                            driverName = printDevice;
                        else
                            outputName = printDevice;
                    } else
                        printDevice = AnsiNext(printDevice);
                }

                if ((Printer->GetSetup().Error != 0)                                ||
                    (lstrcmp(devName, Printer->GetSetup().GetDeviceName()) != 0)    ||
                    (lstrcmp(driverName, Printer->GetSetup().GetDriverName()) != 0) ||
                    (lstrcmp(outputName, Printer->GetSetup().GetOutputName()) != 0)) {
                
                    // New printer installed so get the new printer device now.
                    delete Printer;
                    Printer = new TPrinter;
                }
            } else {
                // No printer installed (GetProfileString failed).
                delete Printer;
                Printer = new TPrinter;
            }
        }
    }
}


int OwlMain (int , char* [])
{
    gdApp     App;
    int             result;

    result = App.Run();

    return result;
}
