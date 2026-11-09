#version 3.0
#include "colors.inc"
#include "textures.inc"

camera { location <0.5,0,-5.1> direction <0,0,3.3> look_at  <0,-0.1,0> }  

light_source { <60,100,-500>  colour Gray75 }
light_source { <60,100,-500>  colour Gray25 }

#declare BTLOGO=union {
    height_field { gif "btlogobw.gif" water_level 0.1 
        texture {pigment {colour Blue } }
    }
    height_field { gif "btlogoco.gif" water_level 0.1 
        texture {pigment {colour Red  } }
    }
    translate <-0.5,-0.5,-0.5>
    rotate <-90,0,0>
    scale <2,1.1,0.2>
    finish {ambient 0.6}
}
box {
    <0,0,0>,<1,1,1>
    pigment { image_map { gif "osmap.gif" once } } // rotate <90,0,0>
    translate <-0.5,-0.5,-0.5>
    scale <2.2,1.64,0.1>
    translate <0,-0.12,0.1>
    finish {ambient 0.55}
}

object {BTLOGO}
