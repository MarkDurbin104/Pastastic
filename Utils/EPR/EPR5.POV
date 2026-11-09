#version 3.0
#include "colors.inc"
#include "textures.inc"
#include "metals.inc"
#include "skies.inc"
#include "golds.inc"

camera { location <1,0.2,-8> direction <0,0,3.3> look_at  <0,0.05,0> }

light_source { <1,1,-2> colour White}
light_source { <2,1,-2> colour White}

#declare BTLOGO=union {
    height_field { gif "btlogobw.gif" water_level 0.1 
        texture {pigment {colour Blue } finish {Glossy}}
    }
    height_field { gif "btlogoco.gif" water_level 0.1 
        texture {pigment {colour Red  } finish {Glossy}}
    }
    translate <-0.5,-0.5,-0.5>
    rotate <-90,0,0>
    scale <3,1.6,0.2>
    translate <0,0.3,0>
}
object {BTLOGO }

plane { y, -0.5
   pigment { Aquamarine }
   normal {
      waves 0.06
      frequency 250.0
      scale 50.0
   }
   finish {
      ambient 0.1
      diffuse 0.1
      reflection 0.8
   }
}

// Put a floor underneath to catch any errant waves from the ripples 
plane { y, -1.5
   pigment { colour CornflowerBlue }
   finish {
      crand 0.05
      ambient 0.8
      diffuse 0.0
   }
}
sky_sphere { S_Cloud4 }
