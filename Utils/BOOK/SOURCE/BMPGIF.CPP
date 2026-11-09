//--------------------------------------------------------//
//                                                        //
//   File:    BMPGIF.CPP                                  //
//                                                        //
//   Desc:    A program to convert image files in the     //
//            BMP and GIF formats to the other format     //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"
#include "ctype.h"

#include "color.hpp"
#include "imgstore.hpp"

//--------------------------------------------------------//
//                     General Code                       //
//--------------------------------------------------------//

#define UNKNOWN 0
#define BMP2GIF 1
#define GIF2BMP 2

//..................Program globals

char      InFn[80],     // path to the input file
          OutFn[80];    // path to the output file

ImgStore  *imgmap;      // image bitmap

rgb       *imgpal,      // image palette
          *gblpal,
          *lclpal;

int        ncolors,     // palette size
           ngbl,
           nlcl,
           cnvdir;      // conversion direction

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
   printf( "........... BMP <-> GIF File Converter ......\n" );
   printf( "\n" );
   printf( "Usage:  BMPGIF  in_file  out_file\n" );
   printf( "\n" );
   printf( "Args:   in_file  - either a GIF or BMP file\n" );
   printf( "        out_file - name of a file of the\n" );
   printf( "                   opposite format\n" );
   printf( "\n" );
   printf( ".............................................\n" );
   printf( "\n" );
}

//..................Determine if the passed file exists

int file_exists( char *path )
{
   FILE *f;
   if( (f=fopen(path,"rb")) != 0 )
   {
      fclose( f );
      return 1;
   }
   return 0;
}

//..................Process pgm argument list

void process_args( int argc, char *argv[] )
{
   char tmp[133];

   if( argc < 2 )
   {
      explain_pgm();
      exit( 0 );
   }

   cnvdir = UNKNOWN;

   strcpy( InFn, argv[1] );
   strupr( InFn );
   if( strchr(InFn,'.') == 0 )
   {
      strcpy( tmp, InFn );
      strcat( tmp, ".BMP" );
      if( file_exists(tmp) )
      {
         strcat( InFn, ".BMP" );
         cnvdir = BMP2GIF;
      }
      else
      {
         strcpy( tmp, InFn );
         strcat( tmp, ".GIF" );
         if( file_exists(tmp) )
         {
            strcat( InFn, ".GIF" );
            cnvdir = GIF2BMP;
         }
         else
         {
            sprintf( tmp,
                    "Input file %s [BMP|GIF] not found",
                     InFn );
            exit_pgm( tmp );
         }
      }
   }
   else if( file_exists(InFn) )
   {
      if( strstr( InFn, ".BMP" ) != 0 )
         cnvdir = BMP2GIF;
      else if( strstr( InFn, ".GIF" ) != 0 )
         cnvdir = GIF2BMP;
   }

   if( cnvdir == UNKNOWN )
   {
      sprintf( tmp, "Ambiguous or impossible conversion "
               "of '%s' - please be more specific.", InFn );
      exit_pgm( tmp );
   }

   if( argc > 2 )
   {
      strcpy( OutFn, argv[2] );
      strupr( OutFn );
   }
   else
   {
      strcpy( OutFn, InFn );
      char *p = strchr( OutFn, '.' );
      *p = 0;
    }

   if( strchr(OutFn,'.') == 0 )
   {
      if( cnvdir == BMP2GIF )
         strcat( OutFn, ".GIF" );
      else
         strcat( OutFn, ".BMP" );
   }

   if( strcmp( InFn, OutFn ) == 0 )
   {
      sprintf( tmp, "%s == %s - no conversion implied",
               InFn, OutFn );
      exit_pgm( tmp );
   }

   printf( "Converting %s to %s...", InFn, OutFn );
   if( file_exists(OutFn) )
   {
      printf( "%s exists - overwrite (y|n)? ", OutFn );
      while( 1 )
      {
        int i = getch();
        if( (i=='y') || (i=='Y') )
           break;
        if( (i=='n') || (i=='N') )
           exit( 0 );
      }
   }
   printf( "\n" );
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

//--------------------------------------------------------//
//                   BMP-Specific Code                    //
//--------------------------------------------------------//

#include "bmp.hpp"
#include "wrtbmp.cpp"

//..................Load the BMP file

void load_bmp( char *fn )
{
   // open file
   FILE *fbmp = fopen( fn, "rb" );
   if( fbmp == 0 )
      exit_pgm( "BMP file not found" );

   // read header and check
   xBITMAPFILEHEADER bmfh;
   if( fread(&bmfh,sizeof(xBITMAPFILEHEADER),1,fbmp) != 1 )
      exit_pgm( "Error reading BMP file" );
   if( bmfh.bfType != BMP_SIGNATURE_WORD )
      exit_pgm( "File is not a valid BMP file" );

   // determine which format version is used
   // from structure size field
   long offset = ftell( fbmp );
   long nbytes = 0;
   fread( &nbytes, sizeof(long), 1, fbmp );
   fseek( fbmp, offset, SEEK_SET );

   // read bitmap header and palette
   int width, height, depth, rle;

   // pre Windows 3.0 version
   if( nbytes == sizeof(xBITMAPCOREHEADER) )
   {
      xBITMAPCOREHEADER bmch;
      if( fread(&bmch,sizeof(xBITMAPCOREHEADER),1,fbmp) != 1 )
         exit_pgm( "Error reading xBITMAPCOREHEADER" );
      width   = bmch.bcWidth;
      height  = bmch.bcHeight;
      depth   = bmch.bcBitCount;
      rle     = 0;
      ncolors = 1 << depth;
      if( ncolors > 0 )
      {
         imgpal = new rgb [ncolors];
         if( imgpal == 0 )
            exit_pgm( "Error allocating image palette" );
         xRGBTRIPLE t;
         for( int i=0; i<ncolors; i++ )
         {
            if( fread(&t,sizeof(xRGBTRIPLE),1,fbmp) != 1 )
               exit_pgm( "Error reading xRGBTRIPLE" );
            imgpal[i] = rgb(t.rgbRed,t.rgbGreen,t.rgbBlue);
         }
      }
   }

   // Windows 3.0 and later version
   else if( nbytes == sizeof(xBITMAPINFOHEADER) )
   {
      xBITMAPINFOHEADER bmih;
      if( fread(&bmih,sizeof(xBITMAPINFOHEADER),1,fbmp) != 1 )
         exit_pgm( "Error reading xBITMAPINFOHEADER" );
      width   = (int) bmih.biWidth;
      height  = (int) bmih.biHeight;
      depth   = bmih.biBitCount;
      rle     = (int) bmih.biCompression;
      ncolors = 1 << depth;
      if( ncolors > 0 )
      {
         imgpal = new rgb [ncolors];
         if( imgpal == 0 )
            exit_pgm( "Error allocating image palette" );
         xRGBQUAD q;
         for( int i=0; i<ncolors; i++ )
         {
            if( fread(&q,sizeof(xRGBQUAD),1,fbmp) != 1 )
               exit_pgm( "Error reading xRGBQUAD" );
            imgpal[i] = rgb(q.rgbRed,q.rgbGreen,q.rgbBlue);
         }
      }
   }

   // unknown format
   else
   {
      exit_pgm( "Format error or input file not a BMP file" );
   }

   // check pixel size - 24-bit imagery not supported by GIF
   if( depth == 24 )
   {
      exit_pgm( "Error - BMP file is 24-bit color - "
                "not supported by the GIF format\n" );
   }

   // position to start of bitmap
   fseek( fbmp, bmfh.bfOffBits, SEEK_SET );

   // create a scan line buffer
   int rowbytes = (width + 3) / 4;
   rowbytes *= 4;
   unsigned char *scanline = new unsigned char [rowbytes];

   // create an image storage buffer
   imgmap = istore( height, width, 8 );

   // and check
   if( (imgmap == 0) || (scanline == 0) )
   {
      if( imgmap )   delete imgmap;
      if( scanline ) delete scanline;
      exit_pgm( "Insufficient memory to load BMP image" );
   }

   // load the image
   printf( "Loading BMP file '%s'...", fn );
   BmpDecoder bmp( fbmp, rle, depth );
   bmp.init( );
   int n = height;
   for( int i=0; i<height; i++ )
   {
      bmp.decode( scanline, width );
      imgmap->put( scanline, --n );
   }
   bmp.term( );
   printf( "done\n" );

   fclose( fbmp );
   delete scanline;
}

//--------------------------------------------------------//
//                   GIF-Specific Code                    //
//--------------------------------------------------------//

#include "gif.hpp"
#include "gifcodec.hpp"
#include "wrtgif.cpp"

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

void do_image( char *fn, FILE *f )
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
   printf( "Loading GIF file '%s'...", fn );
   GifDecoder dec( f, size, ncols );
   dec.init();
   for( int i=0; i<nrows; i++ )
   {
      dec.decode( scanln, ncols );
      int n = imd.isinterlaced() ? row( nrows ) : i;
      imgmap->put( scanln, n );
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
   char msg[81];
   int  label = fgetc( f );
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
              exit_pgm( "Error reading GIF extension" );
           else
           {
              sprintf( msg,
                      "Unknown/invalid GIF extension %02Xh\n",
                      label );
              exit_pgm( msg );
           }
           break;
   }
}


//..................Load the GIF file

void load_gif( char *fn )
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

   printf( "Loading GIF file '%s'...", fn );
   int type;
   while( (type=fgetc(fgif)) > 0 )
   {
      if( type == 0x2C )       // image descriptor
      {
         do_image( fn, fgif );
         break;
      }
      else if( type == 0x21 )  // extension
         do_extension( fgif );
      else if( type == 0x3B )  // trailer
         exit_pgm( "Unexpected GIF trailer" );
      else
         exit_pgm( "Unknown or invalid construct" );
   }
   printf( "done\n" );
}

//--------------------------------------------------------//
//                        M A I N                         //
//--------------------------------------------------------//

int main( int argc, char *argv[] )
{
   process_args( argc, argv );

   if( cnvdir == GIF2BMP )
   {
      load_gif( InFn );
      imgpal  = lclpal ? lclpal : gblpal;
      printf( "Writing BMP file '%s'...", OutFn );
      WriteBMP( *imgmap, imgpal, OutFn );
      printf( "done\n" );
   }
   else
   {
      load_bmp( InFn );
      printf( "Writing GIF file '%s'...", OutFn );
      WriteGIF( *imgmap, imgpal, OutFn );
      printf( "done\n" );
   }

   return 0;
}
