//******************************************************************************
// FILENAME: labeldev.h
//------------------------------------------------------------------------------
// DESCRIPTION: Header file for defines and equates and prototypes for the
//              label printer device driver.
//
//
//******************************************************************************
#ifndef LABELDEV_H
#define LABELDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef LABELDEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOL S  
#ifdef LABELDEV_C
int label_control(int type, va_list ap);
#endif


PUBLIC DEVHEADER dev_label
#if INIT
= {
  DEVSIG,
  "Label Printer Device Copyright (c) Unisys 1994 version 1.00",
  "OUTPUT 01",
  "LABEL",
  "IEP",
  NULL,
  NULL,
  (DFPTR)label_control,
  NULL,
  DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E
#ifdef LABELDEV_C

//===========================================================================
// General purpose defines for the commands sent to the label printer.
//===========================================================================
#define GS                  0x1D
#define ESCAPE              0x1B
#define PRTRDY              0xD0

//===========================================================================
// Defines for the commands sent to the label printer.
//===========================================================================
#define HORIZONTAL_TAB      0x9         // Horizontal Tab of 8 characters
#define NL                  0xA         // Print buffer and go to newline
#define VERTICAL_TAB        0xB         // Vertical Tab in line numbers
#define CR                  13          // Carriage return (same as newline)
#define DBL_WIDE            0xE         // Set double width character mode
#define NO_DBL_WIDE         0xF         // End double width mode
#define RESET               0x10        // Reset to standard character mode
#define GRAPHIC_MODE        0x11        // Print graphic data
#define DBL_HI              0x12        // Start double high printing
#define NO_DBL_HI           0x13        // End double high printing
#define UNDERLINE           0x15        // Select underline printing
#define PAPER_CUT           0x16        // Paper cut command
#define NO_UNDERLINE        0x18        // End underline mode
#define INVERSE             0x1E        // Select inverse print mode
#define NO_INVERSE          0x1F        // End inverse print mode
#define ASCII_DOWNLOAD      "\x1b\x26"  // Download ASCII character(ESC'&')
#define PRINT_BUFFER        "\x1b\x4A"  // Print all data in buffer(ESC'J')
#define SIDE_CHARS          "\x1b\x74"  // Set # of side-writing chars(ESC't')
#define PRINTER_STATUS      "\x1b\x76"  // Get printer status(ESC'v')
#define SIDE_WRITE_MODE     "\x1b\x56"  // Set side write mode(ESC'V')
#define BAR_POSITION        "\x1d\x41"   // Select X position of bar code(GS'A')
#define BAR_HEIGHT          "\x1d\x68"   // Select height of bar code(GS'h')
#define BAR_PRINT           "\x1d\x6b"   // Print bar code(GS'k')
#define MOTOR_ADVANCE       "\x1d\x4b"   // Motor advance 1/3 sec (GS'K')
#define BAR_ORIENT_VERT     "\x1d\x4f\0" // Set bar code to vertical orientation
                                         // (GS'O'0 = Vertical)
#define BAR_ORIENT_SIDE     "\x1d\x4f\1" // Set bar code to side print orienta-
                                         //tion (GS'O'1 = Side mode)
#define BAR_SIDE_PASS_1     "\x1d\x52\0" // Print bar code with 1 pass (GS'R'0)
#define BAR_SIDE_PASS_2     "\x1d\x52\1" // Print bar code with 2 pass (GS'R'1)
#define DISABLE_SENSOR      "\x1d\x54"   // Disable ticket sensor (GS'T')
#define BAR_SIZE            "\x1d\x57"   // Select size of barcode lines(GS'W')

//==============================================================================
// Defines for LPT1 Port Communications. Label printer is assigned to LPT1.
//==============================================================================
#define LP         0x278
#define LP_STAT    (LP+1)
#define LP_CONT    (LP+2)
#define STROBE     0xD
#define NO_STROBE  0xC
#define PRINTER    0x17

//==============================================================================
// Prototypes for the internal label printer driver.
//==============================================================================
int init_label(unsigned char *ch);
unsigned char prtrdy(void);
unsigned char reset_prn(void);
int outpch(unsigned char *str, int num_bytes);
#endif  // def LABELDEV_C
#endif  // def LABELDEV_H
