#version 3.0
#include "colors.inc"
#include "textures.inc"
#include "skies.inc"
#include "metals.inc"
#include "finish.inc"

#declare DRed     = rgb <0.2,0   ,0  >
#declare DGreen   = rgb <0  ,0.15,0  >
#declare DBlue    = rgb <0  ,0   ,0.2>

camera { location <0,0,-30> direction <0,0,3.3> look_at <0,0.5,0> }

light_source { <-2,2,-10> colour White*1.5 }


#declare Button=union {
   plane { y, 1 }
   box { <-0.3,1,0.1>,<0.3,1.05,0.7>  }

}
#declare HexCylinder=intersection {
    object { Button rotate   0.0*z }
    object { Button rotate  60.0*z }
    object { Button rotate 120.0*z }
    object { Button rotate 180.0*z }
    object { Button rotate 240.0*z }
    object { Button rotate 300.0*z }
    
    plane { y, 1 rotate 90.0*x }
    plane { y, 1 rotate 270.0*x }
    texture {pigment {colour White}}
    finish {Shiny}
    scale <1,1,5> rotate <0,90,0>
}

object { HexCylinder rotate <15,0,0> }

// sky_sphere { S_Cloud2 }
