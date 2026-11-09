//--------------------------------------------------------//
//                                                        //
//   File:    COLORMAP.HPP                                //
//                                                        //
//   Desc:    Palette modification and color mapping      //
//            functions.                                  //
//                                                        //
//--------------------------------------------------------//

#ifndef _COLORMAP_HPP_
#define _COLORMAP_HPP_

#include "color.hpp"

void xchg_rgb( rgb *pal, int m, int n );

int  closest_rgb( rgb x, rgb *pal, int npal );

int  maximal_rgb( rgb *pal, int mid, int max );

void reduce_palette( rgb *pal, int npal, int nsub );

void color_map( rgb *img, int nimg, rgb *dev, int ndev,
                int *cmap, int smooth_wt );

#endif
