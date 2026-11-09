#version 3.0
#include "colors.inc"
#include "textures.inc"
#include "glass.inc"

//camera { location <0,1,0.4> direction <0,0,2.7> look_at  <0,0,-1.25> }
camera { location <0,2.5,-4.5> direction <0,0,3> look_at  <0,0,0> }

light_source { <0,2,0.2> colour LightGrey}

#declare Bore=union {
    cylinder {<0,0,0>,<1,0,0>,0.1 texture {Silver1}}
    bounded_by {cylinder {<-0.01,0,0>,<0.9,0,0>,0.11  }}
    clipped_by {bounded_by}
}
#declare RFibre=union {
    object {Bore}
    cylinder {<0.05,0,0>,<0.95,0,0>,0.09 texture { T_Ruby_Glass }}
    light_source { <0.1,0.05,0> colour Red*4}
    translate <-0.5,0.055,0>
    rotate <0,-90,0>
}
#declare GFibre=union {
    object {Bore}
    cylinder {<0.05,0,0>,<0.95,0,0>,0.09 texture { T_Green_Glass }}
    light_source { <0.1,0.05,0> colour Green*4}
    translate <-0.5,0.07,0>
    rotate <0,-90,0>
}
#declare BFibre=union {
    object {Bore}
    cylinder {<0.05,0,0>,<0.95,0,0>,0.09 texture { T_Vicksbottle_Glass }}
    light_source { <0.1,0.05,0> colour Blue*4}
    translate <-0.5,0.055,0>
    rotate <0,-90,0>
}

plane {  y,0 pigment { colour White } finish {ambient 0.6 }}
plane {  y,5 pigment { colour White } finish {ambient 0.6 }}
object {RFibre translate <0,0.1,-1.7> rotate <0, 8,0> finish {ambient 0.6 }}
object {GFibre translate <0,0.1,-1.7> rotate <0, 0,0> finish {ambient 0.6 }}
object {BFibre translate <0,0.1,-1.7> rotate <0,-8,0> finish {ambient 0.6 }}
superellipsoid { 
   <0.1,0.1> 
   scale <0.5,0.2,0.25>
   translate <0,0.2,0> 
   texture {Silver1} 
}
