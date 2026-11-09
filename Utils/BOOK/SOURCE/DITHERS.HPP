//--------------------------------------------------------//
//                                                        //
//   File:    DITHERS.HPP                                 //
//                                                        //
//   Desc:    Predefine dither matrices                   //
//                                                        //
//--------------------------------------------------------//

#ifndef _DITHERS_HPP_
#define _DITHERS_HPP_

//..................a clustered-dot ordered matrix

static unsigned char cd44[] =
{
   13,  5,  9, 16,
   10,  1,  4,  8,
    6,  2,  3, 12,
   14, 11,  7, 15,
};

DitherMatrix ClustMat( 4, 4, cd44 );

//..................a dispersed-dot ordered matrix

static unsigned char dd44[] =
{
    8, 15,  4, 10,
    1, 12,  6, 14,
    5,  9, 16,  3,
   13,  2, 11,  7,
};

DitherMatrix DispMat( 4, 4, dd44 );

#endif
