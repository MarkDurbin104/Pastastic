//--------------------------------------------------------//
//                                                        //
//   File:    QGIF.CPP                                    //
//                                                        //
//   Desc:    GIF File Query Program                      //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"

#include "gif.hpp"

//..................program globals

char fn[80],
     dumpfn[80];

int  listpal,
     dump;

//..................program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "..............GIF Query Program..............\n" );
   printf( "\n" );
   printf( "Usage:      QGIF  gif_file  [ switches ]\n" );
   printf( "\n" );
   printf( "Switches:  -dXXX  = dump image to file XXX\n" );
   printf( "           -h     = display program usage\n" );
   printf( "           -p     = display palette (clr tbl)\n" );
   printf( "\n" );
   printf( ".GIF extension assumed\n" );
   printf( ".............................................\n" );
   printf( "\n" );
}

//..................process args

void process_args( int argc, char *argv[] )
{
   // establish default values
   fn[0]     = 0;
   dumpfn[0] = 0;
   listpal   = 0;
   dump      = 0;

   // process the program's argument list
   for( int i=1; i<argc; i++ )
   {
      if( (*argv[i] == '-') || (*argv[i] == '/') )
      {
         char sw = *(argv[i] + 1);
         switch( toupper(sw) )
         {
            case 'D' :
               dump = 1;
               strcpy( dumpfn, argv[i]+2 );
               break;

            case 'H' :
               explain_pgm();
               exit( 0 );
               break;

            case 'P' :
               listpal = 1;
               break;

            default:
               printf( "Unknown switch '%s' ignored\n",
                        argv[i] );
               break;
         }
      }
      else  // presumably a file idengifier
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

//..................skip data blocks

void skip_blocks( FILE *f )
{
   int nbytes;
   while( (nbytes=fgetc(f)) > 0 )
      fseek( f, nbytes, SEEK_CUR );
}

//..................copy data blocks

void copy_blocks( FILE *fi, FILE *fo )
{
   int nbytes;
   do
   {
      nbytes = fgetc( fi );
      fputc( nbytes, fo );
      for( int i=0; i<nbytes; i++ )
         fputc( fgetc(fi), fo );
   }
   while( nbytes > 0 );
}

//..................list comment blocks

static int nbytes=0;

int getcomchar( FILE *f )
{
   if( nbytes < 1 )
   {
      nbytes = fgetc( f );
      if( nbytes < 1 )
         return 0;
   }
   nbytes--;
   return fgetc( f );
}

void list_comments( FILE *f )
{
   char word[256];
   int  c, nch=0, nco=0;
   while( (c = getcomchar( f )) > 0 )
   {
      if( c > ' ' )
      {
         word[nch++] = c;
         if( nch == 255 )
         {
            word[nch] = 0;
            printf( "%s\n", word );
            nco = 0;
         }
      }
      else
      {
         if( nch > 0 )
         {
            if( (nco+nch) > 78 )
            {
              printf( "\n" );
              nco = 0;
            }
            word[nch] = 0;
            printf( "%s", word );
            nco += nch;
            nch = 0;
         }
         if( c == ' ' )
         {
            printf( " " );
            nco++;
         }
         else if( (c == 13) || (c == 10) )
         {
            printf( "\n" );
            nco = 0;
         }
      }
   }
}

//..................process image description

void do_image( FILE *f )
{
   GIFIMDESC imd;
   if( imd.get( f ) )
   {
      printf( "Error reading GIF image descriptot\n" );
      exit( 0 );
   }
   imd.list();
   printf( "\n" );

   // process local color table
   if( imd.islct() )
   {
      for( int i=0; i<imd.ncolors(); i++ )
      {
         int r = fgetc( f );
         int g = fgetc( f );
         int b = fgetc( f );
         if( listpal )
            printf( "LCT[%d] = (%d,%d,%d)\n",
                     i, r, g, b );
      }
      if( listpal ) printf( "\n" );
   }

   // read min LZW code size
   int size = fgetc( f );
   printf( "Mininimum LZW code size = %d\n", size );
   printf( "\n" );

   if( dump )
   {
      printf( "Dumping image to %s...", dumpfn );
      FILE * fdump = fopen( dumpfn, "wb" );
      fwrite( &imd.imwidth, 2, 1, fdump );
      fwrite( &imd.imheight, 2, 1, fdump );
      fputc( size, fdump );
      copy_blocks( f, fdump );
      fclose( fdump );
      printf( "done\n" );
      printf( "\n" );
   }
   else
      skip_blocks( f );

}

//..................process control extension

void do_ctl_ext( FILE *f )
{
   GIFCTLEXT ctl;
   if( ctl.get( f ) )
   {
      printf( "Error reading GIF control extension\n" );
      exit( 0 );
   }
   ctl.list();
   printf( "\n" );
   skip_blocks( f );
}

//..................process comment extension

void do_com_ext( FILE *f )
{
   GIFCOMEXT com;
   if( com.get( f ) )
   {
      printf( "Error reading GIF comment extension\n" );
      exit( 0 );
   }
   com.list();
   printf( "\n" );
   list_comments( f );
}

//..................process text extension

void do_txt_ext( FILE *f )
{
   GIFTXTEXT txt;
   if( txt.get( f ) )
   {
      printf( "Error reading GIF text extension\n" );
      exit( 0 );
   }
   txt.list();
   printf( "\n" );
   skip_blocks( f );
}

//..................process application extension

void do_app_ext( FILE *f )
{
   GIFAPPEXT app;
   if( app.get( f ) )
   {
      printf( "Error reading GIF application extension\n" );
      exit( 0 );
   }
   app.list();
   printf( "\n" );
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

//..................main

int main( int argc, char *argv[] )
{
   process_args( argc, argv );

   // open the file
   FILE *fgif = fopen( fn, "rb" );
   if( fgif == 0 )
   {
      printf( "File '%s' not found\n", fn );
      return 0;
   }

   // read header and screen descriptor
   GIFHEADER hdr;
   if( hdr.get( fgif ) )
   {
      printf( "Error reading GIF header\n" );
      exit( 0 );
   }
   if( ! hdr.isvalid() )
   {
      printf( "File is not a valid GIF file\n" );
      exit( 0 );
   }
   GIFSCDESC scd;
   if( scd.get( fgif ) )
   {
      printf( "Error reading GIF screen descriptor\n" );
      exit( 0 );
   }

   printf( "Listing of file '%s'\n", fn );
   printf( "\n" );
   hdr.list();
   printf( "\n" );
   scd.list();
   printf( "\n" );

   // process global color table
   if( scd.isgct() )
   {
      for( int i=0; i<scd.ncolors(); i++ )
      {
         int r = fgetc( fgif );
         int g = fgetc( fgif );
         int b = fgetc( fgif );
         if( listpal )
            printf( "GCT[%d] = (%d,%d,%d)\n",
                     i, r, g, b );
      }
      if( listpal ) printf( "\n" );
   }

   // process remainder of file
   int type;
   while( (type=fgetc(fgif)) > 0 )
   {
      if( type == 0x2C )       // image descriptor
         do_image( fgif );
      else if( type == 0x21 )  // extension
         do_extension( fgif );
      else if( type == 0x3B )  // trailer
      {
         printf( "..... End of Stream .....\n" );
         break;
      }
      else
      {
         printf( "Unknown type %02Xh\n", type );
         break;
      }
   }

   return 0;
}
