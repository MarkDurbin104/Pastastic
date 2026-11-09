//--------------------------------------------------------//
//                                                        //
//   File:    VGIF.CPP                                    //
//                                                        //
//   Desc:    Program to view or print a GIF file.        //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"
#include "ctype.h"

#include "gif.hpp"
#include "gifcodec.hpp"
#include "imgviewr.hpp"
#include "imgprntr.hpp"
#include "laserjet.hpp"
#include "paintjet.hpp"
#include "epjx80.hpp"
#include "eplq24.hpp"
#include "pscript.hpp"

//..................Printer types

#define  LJ  0x4C4A
#define  PJ  0x504A
#define  JX  0x4A58
#define  LQ  0x4C51
#define  PS  0x5053

//..................Program globals

char      fn[80];       // path to GIF file

int       gmode;        // video display mode
int       pmode;        // printer ID
int       ropt;         // rendering flags
int       iopt;         // itensity mapping flags

ImgStore  *imgmap;      // image bitmap

rgb       *gblpal,      // global palette
          *lclpal;      // local palette

int        ngbl,        // global palette
           nlcl;        // local palette

//..................Exit with a message

void exit_pgm( char *msg )
{
   printf( "%s\n", msg );
   exit( 0 );
}

//..................Program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "..........CompuServe GIF Viewer/Printer..........\n" );
   printf( "\n" );
   printf( "Usage:      VGIF  gif_file  [ switches ]\n" );
   printf( "\n" );
   printf( "Switches:  -h      = display program usage\n" );
   printf( "           -vXX    = force video display mode XX\n" );
   printf( "                     (XX = 12, 13, 2E, 62)\n" );
   printf( "           -pXX    = print using printer XX\n" );
   printf( "                     (XX = LJ, PJ, JX, LQ, PS)\n" );
   printf( "           -b[+|-] = increase or decrease brightness\n" );
   printf( "           -c[+|-] = increase or decrease contrast\n" );
   printf( "           -d      = force dithered rendering\n" );
   printf( "           -g      = force gray scale rendering\n" );
   printf( "           -m      = force palette mapping\n" );
   printf( "\n" );
   printf( ".................................................\n" );
   printf( "\n" );
}

//..................Process pgm argument list

void process_args( int argc, char *argv[] )
{
   // establish default values
   fn[0] = 0;
   gmode = 0x12;
   pmode = 0;
   ropt  = 0;
   iopt  = 0;

   // process the program's argument list
   for( int i=1; i<argc; i++ )
   {
      if( (*argv[i] == '-') || (*argv[i] == '/') )
      {
         char sw = *(argv[i] + 1);
         switch( toupper(sw) )
         {
            case 'H' :
               explain_pgm();
               exit( 0 );
               break;

            case 'V' :
               sscanf( argv[i]+2, "%x", &gmode );
               break;

            case 'P' :
               pmode = toupper( *(argv[i]+2) );
               pmode <<= 8;
               pmode += toupper( *(argv[i]+3) );
               break;

            case 'B' :
               if( *(argv[i]+2) == '-' )
                  iopt |= intensDBRI;
               else
                  iopt |= intensIBRI;
               break;

            case 'C' :
               if( *(argv[i]+2) == '-' )
                  iopt |= intensDCNT;
               else
                  iopt |= intensICNT;
               break;

            case 'D' :
               ropt |= renderDITHER;
               break;

            case 'G' :
               ropt |= renderGRAY;
               break;

            case 'M' :
               ropt |= renderMAP;
               break;

            default:
               printf( "Unknown switch '%s' ignored\n",
                        argv[i] );
               break;
         }
      }
      else  // presumably a file identifier
      {
         strcpy( fn, argv[i] );
         char *p = strchr( fn, '.' );
         if( p == 0 )
            strcat( fn, ".gif" );
         else if( *(p+1) == 0 )
            *p = 0;
      }
   }

   // was a file name specified?
   if( fn[0] == 0 )
   {
      explain_pgm();
      exit( 0 );
   }
}

//..................Create an image storage buffer

ImgStore * istore( int h, int w, int d )
{
   ImgStore *ist = 0;

   // attempt to create in order of preference
   ist = new XmsImgStore( h, w, d );
   if( (ist != 0) && (ist->status != imgstoreOKAY) )
   {
      delete ist;
      ist = new EmsImgStore( h, w, d );
      if( (ist != 0) && (ist->status != imgstoreOKAY) )
      {
         delete ist;
         ist = new CnvImgStore( h, w, d );
         if( (ist != 0) && (ist->status != imgstoreOKAY) )
         {
            delete ist;
            ist = new DskImgStore( h, w, d );
            if( (ist != 0) && (ist->status != imgstoreOKAY) )
            {
               delete ist;
               ist = 0;
            }
         }
      }
   }

   return ist;
}

//..................Create a printer

PrinterDriver * printer( int which )
{
   PrinterDriver *p;

   switch( which )
   {
      case LJ : p = new LaserJet( "LPT1" );
                break;
      case PJ : p = new PaintJet( "LPT1" );
                break;
      case JX : p = new EpsonJX80( "LPT1" );
                break;
      case LQ : p = new EpsonLQ24( "LPT1" );
                break;
      default : p = new PsPrinter( "LPT1" );
                break;
   }

   return p;
}

//..................skip data blocks

void skip_blocks( FILE *f )
{
   int nbytes;
   while( (nbytes=fgetc(f)) > 0 )
      fseek( f, nbytes, SEEK_CUR );
}

//..................determine interlaced row number

static int currow   = -8;
static int curpass  = 0;
static int delta[]  = { 8, 8, 4, 2 };
static int origin[] = { 0, 4, 2, 1 };

int row( int nrows )
{
   currow += delta[curpass];
   if( currow >= nrows )
   {
      curpass++;
      currow = origin[curpass];
   }
   return currow;
}

//..................process image description

void do_image( FILE *f )
{
   GIFIMDESC imd;
   if( imd.get( f ) )
      exit_pgm( "Error reading GIF image descriptor" );

   // process local color table
   lclpal = 0;
   if( imd.islct() )
   {
      nlcl = imd.ncolors();
      lclpal = new rgb [nlcl];
      if( lclpal == 0 )
         exit_pgm( "No memory for local color table" );
      for( int i=0; i<nlcl; i++ )
      {
         int r = fgetc( f );
         int g = fgetc( f );
         int b = fgetc( f );
         lclpal[i] = rgb( r, g, b );
      }
      if( feof(f) || ferror(f) )
         exit_pgm( "Error reading global color table" );
   }

   // create bitmap to be filled
   int ncols = imd.imwidth;
   int nrows = imd.imheight;

   unsigned char *scanln = new unsigned char [ncols];
   imgmap = istore( nrows, ncols, 8 );
   if( (imgmap == 0) || (scanln == 0) )
   {
      delete imgmap;
      exit_pgm( "Insufficient memory to load image" );
   }

   // read min LZW code size
   int size = fgetc( f );

   // decode image
   printf( "Loading image..." );
   GifDecoder dec( f, size, ncols );
   dec.init();
   for( int i=0; i<nrows; i++ )
   {
      dec.decode( scanln, ncols );
      int n = imd.isinterlaced() ? row( nrows ) : i;
      imgmap->put( scanln, n );
      if( (i % 10) == 9 ) printf( "." );
   }
   dec.term();
   printf( "done\n" );
}

//..................process control extension

void do_ctl_ext( FILE *f )
{
   GIFCTLEXT ctl;
   if( ctl.get( f ) )
      exit_pgm( "Error reading GIF control extension" );
   skip_blocks( f );
}

//..................process comment extension

void do_com_ext( FILE *f )
{
   GIFCOMEXT com;
   if( com.get( f ) )
      exit_pgm( "Error reading GIF comment extension" );
   skip_blocks( f );
}

//..................process text extension

void do_txt_ext( FILE *f )
{
   GIFTXTEXT txt;
   if( txt.get( f ) )
      exit_pgm( "Error reading GIF text extension" );
   skip_blocks( f );
}

//..................process application extension

void do_app_ext( FILE *f )
{
   GIFAPPEXT app;
   if( app.get( f ) )
      exit_pgm( "Error reading GIF application extension" );
   skip_blocks( f );
}

//..................process extension

void do_extension( FILE *f )
{
   int label = fgetc( f );
   switch( label )
   {
      case 0xF9 : // control extension
           do_ctl_ext( f );
           break;

      case 0xFE : // comment extension
           do_com_ext( f );
           break;

      case 0x01 : // text extension
           do_txt_ext( f );
           break;

      case 0xFF : // application extension
           do_app_ext( f );
           break;

      default :   // unknown or invalid
           if( label < 0 )
              printf( "Error reading extension\n" );
           else
              printf( "Unknown or invalid extension %02Xh\n",
                       label );
           exit( 0 );
           break;
   }
}


//..................Load the GIF file

void load_gif( void )
{
   // open the file
   FILE *fgif = fopen( fn, "rb" );
   if( fgif == 0 )
      exit_pgm( "GIF file not found" );

   // read header
   GIFHEADER hdr;
   if( hdr.get( fgif ) )
      exit_pgm( "Error reading GIF header" );
   if( ! hdr.isvalid() )
      exit_pgm( "File is not a valid GIF file" );

   // read screen descriptor
   GIFSCDESC scd;
   if( scd.get( fgif ) )
      exit_pgm( "Error reading GIF screen descriptor" );

   // process global color table
   gblpal = 0;
   if( scd.isgct() )
   {
      ngbl = scd.ncolors();
      gblpal = new rgb [ngbl];
      if( gblpal == 0 )
         exit_pgm( "No memory for global color table" );
      for( int i=0; i<ngbl; i++ )
      {
         int r = fgetc( fgif );
         int g = fgetc( fgif );
         int b = fgetc( fgif );
         gblpal[i] = rgb( r, g, b );
      }
      if( feof(fgif) || ferror(fgif) )
         exit_pgm( "Error reading global color table" );
   }

   // scan for image
   int type;
   while( (type=fgetc(fgif)) > 0 )
   {
      if( type == 0x2C )       // image descriptor
      {
         do_image( fgif );
         break;
      }
      else if( type == 0x21 )  // extension
         do_extension( fgif );
      else if( type == 0x3B )  // trailer
         exit_pgm( "Unexpected GIF trailer" );
      else
         exit_pgm( "Unknown or invalid construct" );
   }
}

//..................Main

int main( int argc, char *argv[] )
{
   process_args( argc, argv );

   load_gif( );

   // determine palette
   int ncolors = nlcl > 0 ? nlcl : ngbl;
   rgb *pal = lclpal ? lclpal : gblpal;

   // print the image
   if( pmode != 0 )
   {
      PrinterDriver *prt = printer( pmode );
      if( prt )
      {
         printf( "Printing..." );
         ImagePrinter ip( prt, imgmap, pal, ncolors,
                          ropt, iopt, 100, 100 );
         ip.print( 1 );
         printf( "done\n" );
         delete prt;
      }
      else
         printf( "Printer instantiation failed\n" );
   }

   // display the image
   else
   {
      VgaDisplay vga( gmode );
      ImageViewer iv( &vga, imgmap, pal, ncolors,
                      ropt, iopt );
      iv.view( );
   }

   delete imgmap;
   delete gblpal;
   delete lclpal;

   return 0;
}
