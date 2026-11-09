//--------------------------------------------------------//
//                                                        //
//   File:    GROUP3.CPP                                  //
//                                                        //
//   Desc:    Class implementations for CCITT Group 3     //
//            compressor and decompressor.                //
//                                                        //
//--------------------------------------------------------//

#include "group3.hpp"

//..................structure to hold code definitions

struct codedef
{
   short bitcode;   // encoded representation
   short codelen;   // length of bitcode in bits
   short runlen;    // run length in pixels
};

// table entry count -- note that EOL codes are omitted

#define TBLSIZE 104

// code table for black runs, ordered by code length

static codedef black_bits[] =
{
   { 0x8000,  2,    3 },   { 0xC000,  2,    2 },
   { 0x4000,  3,    1 },   { 0x6000,  3,    4 },
   { 0x2000,  4,    6 },   { 0x3000,  4,    5 },
   { 0x1800,  5,    7 },   { 0x1000,  6,    9 },
   { 0x1400,  6,    8 },   { 0x0800,  7,   10 },
   { 0x0A00,  7,   11 },   { 0x0E00,  7,   12 },
   { 0x0400,  8,   13 },   { 0x0700,  8,   14 },
   { 0x0C00,  9,   15 },   { 0x0DC0, 10,    0 },
   { 0x05C0, 10,   16 },   { 0x0600, 10,   17 },
   { 0x0200, 10,   18 },   { 0x03C0, 10,   64 },
   { 0x0CE0, 11,   19 },   { 0x0D00, 11,   20 },
   { 0x0D80, 11,   21 },   { 0x06E0, 11,   22 },
   { 0x0500, 11,   23 },   { 0x02E0, 11,   24 },
   { 0x0300, 11,   25 },   { 0x0100, 11, 1792 },
   { 0x0180, 11, 1856 },   { 0x01A0, 11, 1920 },
   { 0x0CA0, 12,   26 },   { 0x0CB0, 12,   27 },
   { 0x0CC0, 12,   28 },   { 0x0CD0, 12,   29 },
   { 0x0680, 12,   30 },   { 0x0690, 12,   31 },
   { 0x06A0, 12,   32 },   { 0x06B0, 12,   33 },
   { 0x0D20, 12,   34 },   { 0x0D30, 12,   35 },
   { 0x0D40, 12,   36 },   { 0x0D50, 12,   37 },
   { 0x0D60, 12,   38 },   { 0x0D70, 12,   39 },
   { 0x06C0, 12,   40 },   { 0x06D0, 12,   41 },
   { 0x0DA0, 12,   42 },   { 0x0DB0, 12,   43 },
   { 0x0540, 12,   44 },   { 0x0550, 12,   45 },
   { 0x0560, 12,   46 },   { 0x0570, 12,   47 },
   { 0x0640, 12,   48 },   { 0x0650, 12,   49 },
   { 0x0520, 12,   50 },   { 0x0530, 12,   51 },
   { 0x0240, 12,   52 },   { 0x0370, 12,   53 },
   { 0x0380, 12,   54 },   { 0x0270, 12,   55 },
   { 0x0280, 12,   56 },   { 0x0580, 12,   57 },
   { 0x0590, 12,   58 },   { 0x02B0, 12,   59 },
   { 0x02C0, 12,   60 },   { 0x05A0, 12,   61 },
   { 0x0660, 12,   62 },   { 0x0670, 12,   63 },
   { 0x0C80, 12,  128 },   { 0x0C90, 12,  192 },
   { 0x05B0, 12,  256 },   { 0x0330, 12,  320 },
   { 0x0340, 12,  384 },   { 0x0350, 12,  448 },
   { 0x0120, 12, 1984 },   { 0x0130, 12, 2048 },
   { 0x0140, 12, 2112 },   { 0x0150, 12, 2176 },
   { 0x0160, 12, 2240 },   { 0x0170, 12, 2304 },
   { 0x01C0, 12, 2368 },   { 0x01D0, 12, 2432 },
   { 0x01E0, 12, 2496 },   { 0x01F0, 12, 2560 },
   { 0x0360, 13,  512 },   { 0x0368, 13,  576 },
   { 0x0250, 13,  640 },   { 0x0258, 13,  704 },
   { 0x0260, 13,  768 },   { 0x0268, 13,  832 },
   { 0x0390, 13,  896 },   { 0x0398, 13,  960 },
   { 0x03A0, 13, 1024 },   { 0x03A8, 13, 1088 },
   { 0x03B0, 13, 1152 },   { 0x03B8, 13, 1216 },
   { 0x0290, 13, 1280 },   { 0x0298, 13, 1344 },
   { 0x02A0, 13, 1408 },   { 0x02A8, 13, 1472 },
   { 0x02D0, 13, 1536 },   { 0x02D8, 13, 1600 },
   { 0x0320, 13, 1664 },   { 0x0328, 13, 1728 },
};

// code table for black runs, ordered by run length

static codedef black_runs[] =
{
   { 0x0DC0, 10,    0 },   { 0x4000,  3,    1 },
   { 0xC000,  2,    2 },   { 0x8000,  2,    3 },
   { 0x6000,  3,    4 },   { 0x3000,  4,    5 },
   { 0x2000,  4,    6 },   { 0x1800,  5,    7 },
   { 0x1400,  6,    8 },   { 0x1000,  6,    9 },
   { 0x0800,  7,   10 },   { 0x0A00,  7,   11 },
   { 0x0E00,  7,   12 },   { 0x0400,  8,   13 },
   { 0x0700,  8,   14 },   { 0x0C00,  9,   15 },
   { 0x05C0, 10,   16 },   { 0x0600, 10,   17 },
   { 0x0200, 10,   18 },   { 0x0CE0, 11,   19 },
   { 0x0D00, 11,   20 },   { 0x0D80, 11,   21 },
   { 0x06E0, 11,   22 },   { 0x0500, 11,   23 },
   { 0x02E0, 11,   24 },   { 0x0300, 11,   25 },
   { 0x0CA0, 12,   26 },   { 0x0CB0, 12,   27 },
   { 0x0CC0, 12,   28 },   { 0x0CD0, 12,   29 },
   { 0x0680, 12,   30 },   { 0x0690, 12,   31 },
   { 0x06A0, 12,   32 },   { 0x06B0, 12,   33 },
   { 0x0D20, 12,   34 },   { 0x0D30, 12,   35 },
   { 0x0D40, 12,   36 },   { 0x0D50, 12,   37 },
   { 0x0D60, 12,   38 },   { 0x0D70, 12,   39 },
   { 0x06C0, 12,   40 },   { 0x06D0, 12,   41 },
   { 0x0DA0, 12,   42 },   { 0x0DB0, 12,   43 },
   { 0x0540, 12,   44 },   { 0x0550, 12,   45 },
   { 0x0560, 12,   46 },   { 0x0570, 12,   47 },
   { 0x0640, 12,   48 },   { 0x0650, 12,   49 },
   { 0x0520, 12,   50 },   { 0x0530, 12,   51 },
   { 0x0240, 12,   52 },   { 0x0370, 12,   53 },
   { 0x0380, 12,   54 },   { 0x0270, 12,   55 },
   { 0x0280, 12,   56 },   { 0x0580, 12,   57 },
   { 0x0590, 12,   58 },   { 0x02B0, 12,   59 },
   { 0x02C0, 12,   60 },   { 0x05A0, 12,   61 },
   { 0x0660, 12,   62 },   { 0x0670, 12,   63 },
   { 0x03C0, 10,   64 },   { 0x0C80, 12,  128 },
   { 0x0C90, 12,  192 },   { 0x05B0, 12,  256 },
   { 0x0330, 12,  320 },   { 0x0340, 12,  384 },
   { 0x0350, 12,  448 },   { 0x0360, 13,  512 },
   { 0x0368, 13,  576 },   { 0x0250, 13,  640 },
   { 0x0258, 13,  704 },   { 0x0260, 13,  768 },
   { 0x0268, 13,  832 },   { 0x0390, 13,  896 },
   { 0x0398, 13,  960 },   { 0x03A0, 13, 1024 },
   { 0x03A8, 13, 1088 },   { 0x03B0, 13, 1152 },
   { 0x03B8, 13, 1216 },   { 0x0290, 13, 1280 },
   { 0x0298, 13, 1344 },   { 0x02A0, 13, 1408 },
   { 0x02A8, 13, 1472 },   { 0x02D0, 13, 1536 },
   { 0x02D8, 13, 1600 },   { 0x0320, 13, 1664 },
   { 0x0328, 13, 1728 },   { 0x0100, 11, 1792 },
   { 0x0180, 11, 1856 },   { 0x01A0, 11, 1920 },
   { 0x0120, 12, 1984 },   { 0x0130, 12, 2048 },
   { 0x0140, 12, 2112 },   { 0x0150, 12, 2176 },
   { 0x0160, 12, 2240 },   { 0x0170, 12, 2304 },
   { 0x01C0, 12, 2368 },   { 0x01D0, 12, 2432 },
   { 0x01E0, 12, 2496 },   { 0x01F0, 12, 2560 },
};

// code table for white runs, ordered by code length

static codedef white_bits[] =
{
   { 0x7000,  4,    2 },   { 0x8000,  4,    3 },
   { 0xB000,  4,    4 },   { 0xC000,  4,    5 },
   { 0xE000,  4,    6 },   { 0xF000,  4,    7 },
   { 0x3800,  5,   10 },   { 0x4000,  5,   11 },
   { 0xA000,  5,    9 },   { 0x9800,  5,    8 },
   { 0xD800,  5,   64 },   { 0x9000,  5,  128 },
   { 0x0C00,  6,   13 },   { 0x1C00,  6,    1 },
   { 0x2000,  6,   12 },   { 0xA800,  6,   16 },
   { 0xAC00,  6,   17 },   { 0xD000,  6,   14 },
   { 0xD400,  6,   15 },   { 0x5C00,  6,  192 },
   { 0x6000,  6, 1664 },   { 0x4E00,  7,   18 },
   { 0x1800,  7,   19 },   { 0x1000,  7,   20 },
   { 0x2E00,  7,   21 },   { 0x0600,  7,   22 },
   { 0x0800,  7,   23 },   { 0x5000,  7,   24 },
   { 0x5600,  7,   25 },   { 0x2600,  7,   26 },
   { 0x4800,  7,   27 },   { 0x3000,  7,   28 },
   { 0x6E00,  7,  256 },   { 0x3500,  8,    0 },
   { 0x0200,  8,   29 },   { 0x0300,  8,   30 },
   { 0x1A00,  8,   31 },   { 0x1B00,  8,   32 },
   { 0x1200,  8,   33 },   { 0x1300,  8,   34 },
   { 0x1400,  8,   35 },   { 0x1500,  8,   36 },
   { 0x1600,  8,   37 },   { 0x1700,  8,   38 },
   { 0x2800,  8,   39 },   { 0x2900,  8,   40 },
   { 0x2A00,  8,   41 },   { 0x2B00,  8,   42 },
   { 0x2C00,  8,   43 },   { 0x2D00,  8,   44 },
   { 0x0400,  8,   45 },   { 0x0500,  8,   46 },
   { 0x0A00,  8,   47 },   { 0x0B00,  8,   48 },
   { 0x5200,  8,   49 },   { 0x5300,  8,   50 },
   { 0x5400,  8,   51 },   { 0x5500,  8,   52 },
   { 0x2400,  8,   53 },   { 0x2500,  8,   54 },
   { 0x5800,  8,   55 },   { 0x5900,  8,   56 },
   { 0x5A00,  8,   57 },   { 0x5B00,  8,   58 },
   { 0x4A00,  8,   59 },   { 0x4B00,  8,   60 },
   { 0x3200,  8,   61 },   { 0x3300,  8,   62 },
   { 0x3400,  8,   63 },   { 0x3600,  8,  320 },
   { 0x3700,  8,  384 },   { 0x6400,  8,  448 },
   { 0x6500,  8,  512 },   { 0x6800,  8,  576 },
   { 0x6700,  8,  640 },   { 0x6600,  9,  704 },
   { 0x6680,  9,  768 },   { 0x6900,  9,  832 },
   { 0x6980,  9,  896 },   { 0x6A00,  9,  960 },
   { 0x6A80,  9, 1024 },   { 0x6B00,  9, 1088 },
   { 0x6B80,  9, 1152 },   { 0x6C00,  9, 1216 },
   { 0x6C80,  9, 1280 },   { 0x6D00,  9, 1344 },
   { 0x6D80,  9, 1408 },   { 0x4C00,  9, 1472 },
   { 0x4C80,  9, 1536 },   { 0x4D00,  9, 1600 },
   { 0x4D80,  9, 1728 },   { 0x0100, 11, 1792 },
   { 0x0180, 11, 1856 },   { 0x01A0, 11, 1920 },
   { 0x0120, 12, 1984 },   { 0x0130, 12, 2048 },
   { 0x0140, 12, 2112 },   { 0x0150, 12, 2176 },
   { 0x0160, 12, 2240 },   { 0x0170, 12, 2304 },
   { 0x01C0, 12, 2368 },   { 0x01D0, 12, 2432 },
   { 0x01E0, 12, 2496 },   { 0x01F0, 12, 2560 },
};

// code table for white runs, ordered by run length

static codedef white_runs[] =
{
   { 0x3500,  8,    0 },   { 0x1C00,  6,    1 },
   { 0x7000,  4,    2 },   { 0x8000,  4,    3 },
   { 0xB000,  4,    4 },   { 0xC000,  4,    5 },
   { 0xE000,  4,    6 },   { 0xF000,  4,    7 },
   { 0x9800,  5,    8 },   { 0xA000,  5,    9 },
   { 0x3800,  5,   10 },   { 0x4000,  5,   11 },
   { 0x2000,  6,   12 },   { 0x0C00,  6,   13 },
   { 0xD000,  6,   14 },   { 0xD400,  6,   15 },
   { 0xA800,  6,   16 },   { 0xAC00,  6,   17 },
   { 0x4E00,  7,   18 },   { 0x1800,  7,   19 },
   { 0x1000,  7,   20 },   { 0x2E00,  7,   21 },
   { 0x0600,  7,   22 },   { 0x0800,  7,   23 },
   { 0x5000,  7,   24 },   { 0x5600,  7,   25 },
   { 0x2600,  7,   26 },   { 0x4800,  7,   27 },
   { 0x3000,  7,   28 },   { 0x0200,  8,   29 },
   { 0x0300,  8,   30 },   { 0x1A00,  8,   31 },
   { 0x1B00,  8,   32 },   { 0x1200,  8,   33 },
   { 0x1300,  8,   34 },   { 0x1400,  8,   35 },
   { 0x1500,  8,   36 },   { 0x1600,  8,   37 },
   { 0x1700,  8,   38 },   { 0x2800,  8,   39 },
   { 0x2900,  8,   40 },   { 0x2A00,  8,   41 },
   { 0x2B00,  8,   42 },   { 0x2C00,  8,   43 },
   { 0x2D00,  8,   44 },   { 0x0400,  8,   45 },
   { 0x0500,  8,   46 },   { 0x0A00,  8,   47 },
   { 0x0B00,  8,   48 },   { 0x5200,  8,   49 },
   { 0x5300,  8,   50 },   { 0x5400,  8,   51 },
   { 0x5500,  8,   52 },   { 0x2400,  8,   53 },
   { 0x2500,  8,   54 },   { 0x5800,  8,   55 },
   { 0x5900,  8,   56 },   { 0x5A00,  8,   57 },
   { 0x5B00,  8,   58 },   { 0x4A00,  8,   59 },
   { 0x4B00,  8,   60 },   { 0x3200,  8,   61 },
   { 0x3300,  8,   62 },   { 0x3400,  8,   63 },
   { 0xD800,  5,   64 },   { 0x9000,  5,  128 },
   { 0x5C00,  6,  192 },   { 0x6E00,  7,  256 },
   { 0x3600,  8,  320 },   { 0x3700,  8,  384 },
   { 0x6400,  8,  448 },   { 0x6500,  8,  512 },
   { 0x6800,  8,  576 },   { 0x6700,  8,  640 },
   { 0x6600,  9,  704 },   { 0x6680,  9,  768 },
   { 0x6900,  9,  832 },   { 0x6980,  9,  896 },
   { 0x6A00,  9,  960 },   { 0x6A80,  9, 1024 },
   { 0x6B00,  9, 1088 },   { 0x6B80,  9, 1152 },
   { 0x6C00,  9, 1216 },   { 0x6C80,  9, 1280 },
   { 0x6D00,  9, 1344 },   { 0x6D80,  9, 1408 },
   { 0x4C00,  9, 1472 },   { 0x4C80,  9, 1536 },
   { 0x4D00,  9, 1600 },   { 0x6000,  6, 1664 },
   { 0x4D80,  9, 1728 },   { 0x0100, 11, 1792 },
   { 0x0180, 11, 1856 },   { 0x01A0, 11, 1920 },
   { 0x0120, 12, 1984 },   { 0x0130, 12, 2048 },
   { 0x0140, 12, 2112 },   { 0x0150, 12, 2176 },
   { 0x0160, 12, 2240 },   { 0x0170, 12, 2304 },
   { 0x01C0, 12, 2368 },   { 0x01D0, 12, 2432 },
   { 0x01E0, 12, 2496 },   { 0x01F0, 12, 2560 },
};

//..................class Group3Encoder

int Group3Encoder::init( void )
{
   return status( );
}

int Group3Encoder::term( void )
{
   return status( );
}

int Group3Encoder::status( void )
{
   if( ferror( outfile ) ) return xIOERROR;
   return xOKAY;
}

int Group3Encoder::runlength( int pxval, int maxcnt,
                              unsigned char *pxls )
{
   int cnt = 0;
   while( (pxls[cnt]==pxval) && (cnt < maxcnt) )
      cnt++;
   return cnt;
}

int Group3Encoder::wrtbitcode( int code, int len )
{
   unsigned short mask = 0x8000;
   while( len-- )
   {
      if( code & mask )
         codebyte |= codemask;
      mask >>= 1;
      if( (codemask >>= 1) == 0 )
      {
         if( fputc( codebyte, outfile ) < 0 )
            break;
         codebyte = 0;
         codemask = 0x80;
      }
   }
   return status( );
}

int Group3Encoder::wrtrun( int pxval, int cnt )
{
   codedef *tbl = pxval ? black_runs : white_runs;
   while( cnt >= 2624 )
   {
      if( wrtbitcode( tbl[TBLSIZE-1].bitcode,
                      tbl[TBLSIZE-1].codelen ) != xOKAY )
         return status( );
      cnt -= 2560;
   }
   if( cnt > 63 )
   {
      int n = cnt >> 6;   // n=pxcnt/64
      int i = n + 63;
      if( wrtbitcode( tbl[i].bitcode,
                      tbl[i].codelen ) != xOKAY )
         return status( );
      n <<= 6;              // n=n*64
      cnt -= n;
   }
   return wrtbitcode( tbl[cnt].bitcode,
                      tbl[cnt].codelen );
}

int Group3Encoder::encode( unsigned char *line, int size )
{
   // scan line initialization
   codebyte = 0;
   codemask = 0x80;

   // start with 0 run
   int pxval = 0;

   // encode the scan line
   while( (size > 0) && (status( ) == xOKAY) )
   {
      int cnt = runlength( pxval, size, line );
      wrtrun( pxval, cnt );
      line += cnt;
      size -= cnt;
      pxval = 1 - pxval;
   }

   // flush a partial code byte
   if( (codebyte != 0x80) && (status( ) == xOKAY) )
      fputc( codebyte, outfile );

   return status( );
}

//..................class Group3Decoder

int Group3Decoder::init( void )
{
   cond = xOKAY;
   return status( );
}

int Group3Decoder::term( void )
{
   return status( );
}

int Group3Decoder::status( void )
{
   if( feof( infile ) )   return xENDOFFILE;
   if( ferror( infile ) ) return xIOERROR;
   return cond;
}

int Group3Decoder::rdbit( void )
{
   if( (codemask>>=1) == 0 )
   {
      codebyte = fgetc( infile );
      codemask = 0x80;
   }
   return (codebyte & codemask) ? 1 : 0;
}

int Group3Decoder::rdcode( int pxval )
{
   codedef *tbl = pxval ? black_bits : white_bits;
   short code = 0;
   unsigned short mask = 0x8000;
   int len = 0;
   int n = 0;

   while( n < TBLSIZE )
   {
      while( len < tbl[n].codelen )
      {
         if( rdbit() ) code |= mask;
         len++;
         mask >>= 1;
      }
      while( tbl[n].codelen == len )
      {
         if( tbl[n].bitcode == code )
            return tbl[n].runlen;
         n++;
      }
   }

   // getting here is an error - no match found!
   cond = xOUTOFSYNC;
   return -1;
}

int Group3Decoder::decode( unsigned char *line, int size )
{
   // scan line initialization
   codebyte = 0;
   codemask = 0;
   int cnt = 0;
   int pxval = 0;

   while( (size > 0) && (status( ) == xOKAY) )
   {
      // get next code
      if( (cnt = rdcode( pxval )) < 0 )
         break;

      // fill in scan line
      int n = cnt;
      while( (n--) && (size > 0) )
      {
         *line++ = pxval;
         size--;
      }

      // switch pixel values if terminating code
      if( cnt < 64 )
         pxval = 1 - pxval;

   }

   // if we ended on a makeup code, read what
   // should be a terminating code of runlength 0
   if( cnt > 63 )
   {
      cnt = rdcode( pxval );
      if( cnt != 0 ) return xOUTOFSYNC;
   }

   return status( );
}
