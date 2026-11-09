#version 3.0
#include "colors.inc"
#include "textures.inc"
#include "glass.inc"
#include "metals.inc"

camera { location <4.5,1,-18> direction <0,0,3> look_at  <4.5,1,0> }

light_source { <4.5,1,-18> colour White}

#declare Black_Metal = texture { pigment { Blue } finish { F_MetalB  } }
#declare Semi=difference {
    torus { 0.5,0.1}
    box { <-1,-1,-1>,<1,1,0> }
}
#declare Bend=difference {
    object {Semi}
    box { <0,-1,-1>,<1,1,1> }
    rotate <-90,0,0>
    translate <0,-0.5,0>
}
#declare EBend=difference {
    object {Semi}
    box { <0,-1,-1>,<1,1,1> rotate <0,45,0>}
    rotate <0,45,0>
    rotate <-90,0,0>
    translate <0,-0.5,0>
}

#declare ESheath=difference {
    cylinder { <0,0,0>,<0.5,0,0>,0.1}
    cylinder { <0,0,0>,<0.501,0,0>,0.09}
    texture {Black_Metal} 
}
#declare RECap=union {
    object {ESheath}
    cylinder { <0.1,0,0>,<0.7,0,0>,0.09 texture { T_Ruby_Glass }}
    light_source { <0.59,0,0> colour Red*2 }
}
#declare GECap=union {
    object {ESheath}
    cylinder { <0.1,0,0>,<0.7,0,0>,0.09 texture { T_Dark_Green_Glass }}
    light_source { <0.59,0,0> colour Green*2 }
}
#declare BECap=union {
    object {ESheath}
    cylinder { <0.1,0,0>,<0.7,0,0>,0.09 texture { T_Vicksbottle_Glass }}
    light_source { <0.59,0,0> colour Blue*3 }
}
#declare WECap=union {
    object {ESheath}
    cylinder { <0.1,0,0>,<0.7,0,0>,0.09 texture { T_Glass2 }}
    light_source { <0.59,0,0> colour White*2 }
}
#declare YECap=union {
    object {ESheath}
    cylinder { <0.1,0,0>,<0.7,0,0>,0.09 texture { T_Yellow_Glass }}
    light_source { <0.59,0,0> colour Yellow*2 }
}
#declare BrECap=union {
    object {ESheath}
    cylinder { <0.1,0,0>,<0.7,0,0>,0.09 texture { T_Beerbottle_Glass }}
    light_source { <0.59,0,0> colour rgbf <0.7, 0.5, 0.1, 0.6> *3 }
}

#declare E1=union {
    cylinder { <0, 0.4  ,0>,<0.5, 0.4  ,0>,0.1}
    object {Bend rotate <0,0,180> translate <0.5,0.4,0> }
    cylinder { <1, 0.9  ,0>,<1, 1.9  ,0>,0.1}
    object {Bend translate <1.5,2.4,0> }
    cylinder { <1.5, 2.4  ,0>,<2.2, 2.4  ,0>,0.1}
    texture {Black_Metal} 
}
#declare E2=union {
    cylinder { <0  , 0.2 ,0>,<0.7, 0.2  ,0>,0.1} 
    object {Bend rotate <0,0,180> translate <0.7,0.2,0> }
    object {Bend translate <1.7,1.2,0> }
    cylinder { <1.7, 1.2 ,0>,<2, 1.2  ,0>,0.1} 
    texture {Black_Metal} 
}
#declare E3=object {
    cylinder { <0  , 0 ,0>,<2.2, 0  ,0>,0.1} 
    texture {Black_Metal} 
}
#declare P1=union {
    cylinder { <0, -0.4  ,0>,<3,-0.4  ,0>,0.1}
    object {Bend rotate <0,0,180> translate <3,-0.4,0> }
    cylinder { <3.5, 0.1  ,0>,<3.5, 1.9  ,0>,0.1}
    object {Bend translate <4,2.4,0> }
    cylinder { <3.9, 2.4  ,0>,<4.6, 2.4  ,0>,0.1}
    object {Bend rotate <0,0,-90> translate <5.1,1.9,0> }
    cylinder { <5.1,1.9  ,0>,<5.1, 1.6  ,0>,0.1}
    object {Bend rotate <0,0,180> translate <4.6,1.2,0> }
    cylinder { <4.36, 1.2  ,0>,<4.6, 1.2  ,0>,0.1}
    texture {Black_Metal} 
}
#declare R1=union {
    cylinder { <-2.6, -0.8  ,0>,<3,-0.8  ,0>,0.1}
    object {Bend rotate <0,0,180> translate <3,-0.8,0> }
    cylinder { <3.5, -0.3  ,0>,<3.5, 1.9  ,0>,0.1}
    object {Bend translate <4,2.4,0> }
    cylinder { <3.9, 2.4  ,0>,<4.6, 2.4  ,0>,0.1}
    object {Bend rotate <0,0,-90> translate <5.1,1.9,0> }
    cylinder { <5.1,1.9  ,0>,<5.1, 1.6  ,0>,0.1}
    object {Bend rotate <0,0,180> translate <4.6,1.2,0> }
    cylinder { <4.36, 1.2  ,0>,<4.6, 1.2  ,0>,0.1}
    translate <2.6,0,0>
    texture {Black_Metal} 
}
#declare R2=union {
    cylinder { <-4.5, -1  ,0>,<2.8,-1  ,0>,0.1}
    object {EBend rotate <0,0,-90> translate <3.3,-0.5,0> }
    union {
       cylinder { <-0.2,0,0>,<1.05,0,0>,0.1 }
       object {WECap rotate <0,0,180> translate <-0.1,0,0>} 
       rotate <0,0,-45> 
       translate <2.5,0.5,0>
    }
    translate <4.5,0,0>
    texture {Black_Metal} 
}
#declare BFTBore=difference {
    cylinder { <-1,-0.3,0>,<0,-0.3,0>,0.9 }
    cylinder { <-1,-0.3,0>,<0.1,-0.3,0>,0.8 }
}
#declare BFT=union {
    cylinder { <-1,-0.3,0>,<-0.1,-0.3,0>,0.95 texture {Black_Metal} }
    object { BFTBore texture {Black_Metal} }
    union { object {E1} object {RECap translate <2.1,2.4,0>} }
    union { object {E2} object {GECap translate <1.9,1.2,0>} }
    union { object {E3} object {BECap translate <2.1,0,0>} }
    union { object {P1} object {YECap rotate <0,0,180> translate <4.4,1.2,0>} }
    union { object {R1} object {BrECap rotate <0,0,180> translate <7  ,1.2,0>} }
    object {R2}
}
#declare Count=0
#while (Count < 3)
    cylinder { <-1,0,0>,<10,0,0>,0.09 translate <0,Count-0.2,0.1> texture {T_Copper_3D}}
    #declare Count=Count+0.4
#end
plane {  z,0.19 pigment { colour White } finish {ambient 0.2}}
//plane {  z,-25 pigment { colour White } finish {ambient 0.2}}
object {BFT}
