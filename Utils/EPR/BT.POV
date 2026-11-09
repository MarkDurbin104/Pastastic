#include "colors.inc"
//#include "shapes.inc"
//#include "textures.inc"
//#include "stones.inc"

camera { location <0,0,-2.5>  look_at <0,0,0> }
light_source { <0,1,-2> color White }

#declare cerk=union {
    superellipsoid { <1,0.3> }
    translate <-0.5,-0.5,-0.5>
}
#declare flat=union {
    superellipsoid { <0.3,0.3> }
    translate <-0.5,-0.5,-0.5>
}



#declare LetT=union {
object {cerk scale 0.2 translate <-0.5,1,0> pigment {color Blue }}
object {cerk scale 0.2 translate < 0.5,1,0> pigment {color Blue }}
object {flat scale <0.6,0.2,0.2> translate < 0.2,1,0> pigment {color Blue }}
object {flat scale <0.3,0.6,0.2> translate < 0,0.6,0> pigment {color Blue }}
object {cerk scale 0.3 translate < 0,0,0> pigment {color Blue }}
}
object {LetT pigment {color Blue }}
