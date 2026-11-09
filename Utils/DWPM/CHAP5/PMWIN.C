/* Window test frame
   compile with
   Borland: BWINCOMP appname
   Microsoft: MWINCOMP appname
*/
#include <windows.h>
#include <stdlib.h>
#include <stdarg.h>
#include "pmwin.h"

#define MKSTR(x) #x
#define STR(x) MKSTR(x)

#ifndef TITLE
#define PMWIN_TITLE "Protected Mode Test Bed"
#else
#define PMWIN_TITLE STR(TITLE)
#endif


HANDLE hInst;
HWND topwindow;

/* user's function */
char *test(void);
/* stray prototype */
int vsprintf(char *s,char *fmt,...);


/* Main window function */
int PASCAL WinMain(HANDLE hInstance, HANDLE hPrevInstance,
                   LPSTR lpCmdLine, int nCmdShow)
    {
    MSG msg;
/* check for protected mode */
    if (!(GetWinFlags()&WF_PMODE))
        {
        MessageBox(NULL,"You must run " PMWIN_TITLE
                        " in standard or enhanced mode",
                        "Error",MB_OK|MB_ICONSTOP);

        }

    if (!hPrevInstance)
        {
        if (!InitApplication(hInstance))
/* Exit if unable to initialize */
            return FALSE;
        }
    else
        {
/* Only allow one copy to run since some interrupt routines
   that we will experiment with want to run alone */
        MessageBox(NULL,"You may only run one "
                   "copy of " PMWIN_TITLE " at a time",
                   "Error",MB_OK|MB_ICONSTOP);
        return FALSE;
        }
    /* Perform instance init */
    if (!InitInstance(hInstance, nCmdShow))
        return FALSE;

    /* Vanilla loop */
    while (GetMessage(&msg,NULL,NULL,NULL))
        {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
        }
    return (msg.wParam);
    }



/* Create window class here */
BOOL InitApplication(HANDLE hInstance)
    {
    WNDCLASS  wc;
    wc.style=NULL;
    wc.lpfnWndProc=(void _far *)MainWndProc;
    wc.cbClsExtra=0;
    wc.cbWndExtra=0;
    wc.hInstance=hInstance;
    wc.hIcon=LoadIcon(NULL, IDI_APPLICATION);
    wc.hCursor=LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground=GetStockObject(WHITE_BRUSH);
    wc.lpszMenuName= "WinPMMenu";
    wc.lpszClassName="WPM_Class";
    return (RegisterClass(&wc));
    }



/* Create window here */
BOOL InitInstance(HANDLE hInstance, int nCmdShow)
    {
    HWND            hWnd;
    /* Save the instance handle in global variable */
    hInst=hInstance;

    /* Create a main window */
    topwindow=hWnd=CreateWindow(
        "WPM_Class",
        PMWIN_TITLE,
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        NULL,
        NULL,
        hInstance,
        NULL
    );

    if (!hWnd)
        return FALSE;

/* Make the window visible, update its client area,
     and return "success" */
    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);
    return (TRUE);
    }


/* Window procedure */
long FAR PASCAL _export MainWndProc(HWND hWnd, WORD message,
                            WORD wParam, LONG lParam)
    {
/* pointer for "About" function */
    FARPROC lpProcAbout;

    switch (message)
        {
        case WM_COMMAND:
            if (wParam==IDM_ABOUT)
                {
                lpProcAbout=MakeProcInstance(About, hInst);
                DialogBox(hInst,"AboutBox",hWnd,lpProcAbout);
                FreeProcInstance(lpProcAbout);
                break;
                }
            else if (wParam==IDM_TEST)
                {
/* Run user's program */
                MessageBox(hWnd,test(),"Test result",MB_OK);
                break;
                }
            else if (wParam==IDM_STOP)
                {
                DestroyWindow(hWnd);
                }
            else
                return (DefWindowProc(hWnd, message,
                        wParam, lParam));

        case WM_DESTROY:
            PostQuitMessage(0);
            break;

        default:
            return (DefWindowProc(hWnd, message,
                    wParam, lParam));
        }
    return NULL;
    }


/* Ordinary about box */
BOOL FAR PASCAL _export About(HWND hDlg, unsigned message,
                      WORD wParam, LONG lParam)
    {
    switch (message)
      {
      case WM_INITDIALOG:
            return (TRUE);

        case WM_COMMAND:
            if (wParam==IDOK|| wParam==IDCANCEL)
               {
               EndDialog(hDlg, TRUE);
               return (TRUE);
               }
            break;
      }
    return FALSE;
   }

/* buffers for I/O dialogs */
static char print_buf[513];
static char in_buf[513];

/* Sort of a printf for user's program -- maximum output
   is 512 characters */
int win_printf(char *title,char *fmt,...)
  {
  int rc;
  va_list alist;
  va_start(alist,fmt);
  rc=vsprintf(print_buf,fmt,alist);
  if (rc!=-1)
    MessageBox(NULL,print_buf,title?title:"Output",MB_OK);
  return rc;
  }



/* Dialog callback for input function */
BOOL FAR PASCAL _export inp_dlg(HWND hDlg, unsigned message,
                        WORD wParam, LONG lParam)
    {
    switch (message)
      {
      case WM_INITDIALOG:
/* Set title */
            SendMessage(hDlg,WM_SETTEXT,0,lParam);
/* Set prompt */
            SetDlgItemText(hDlg,101,print_buf);
            return (TRUE);

        case WM_COMMAND:
            if (wParam==IDOK)
             {
/* read input */
             GetDlgItemText(hDlg,102,in_buf,sizeof(in_buf));
             EndDialog(hDlg, TRUE);
             return (TRUE);
             }
            break;
      }
    return FALSE;
   }


/* line input for user's program
   title is the dialog title -- the
   remaining arguments are used as a prompt */
char *win_input(char *title,char *fmt,...)
  {
  FARPROC dlgfunc;
  int rc;
  va_list alist;
  va_start(alist,fmt);
/* print prompt to print_buf */
  rc=vsprintf(print_buf,fmt,alist);
  if (rc!=-1)
     {
     dlgfunc=MakeProcInstance(inp_dlg,hInst);
     if (!dlgfunc)
        win_printf("Error","MakeProcInstance failed");
     else
       {
/* call dialog */
       rc=DialogBoxParam(hInst,"InputBox",topwindow,
          dlgfunc,(long)title);
       FreeProcInstance(dlgfunc);
       }
     }
  return in_buf;
  }


