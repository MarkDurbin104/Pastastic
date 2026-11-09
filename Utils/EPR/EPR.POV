#include "colors.inc"
#include "textures.inc"

camera {
   location <0,-1,-5.5>
   direction <0,0,2>
   look_at  <0,0,0>
}
light_source { <0.1,0.1,-10> colour White}
//light_source { <0.1,0.1,-10> colour White}
//light_source { <0.1,0.1,-10> colour White}

#declare OTube=difference {
    cylinder { <0,0,0>,<0,0,1>,0.5 }
    cylinder { <0,0,-0.1>,<0,0,1.1>,0.48 }
}
#declare ITube=difference {
    cylinder { <0,0,0>,<0,0,1>,0.5 }
    cylinder { <0,0,-0.1>,<0,0,1.1>,0.45 }
}
#declare OuterTube=union {
     object {OTube texture {pigment {colour Black}} 
         finish {
            phong 1
            phong_size 100
         }
     }
     object {OTube scale <0.9,0.9,1> texture { Silver3 }}
}
#declare InnerTube=union {
     object {ITube texture {pigment {colour LightGrey}}}
     object {OTube scale <0.9,0.9,1> texture {pigment {colour LightGrey}}}
     scale <0.28,0.28,1.1>
}
#declare InnerRTube=union {
     object {ITube texture {pigment {colour Red}}}
     object {OTube scale <0.9,0.9,1> texture {pigment {colour Red}}}
     scale <0.28,0.28,1.1>
}
#declare InnerGTube=union {
     object {ITube texture {pigment {colour DarkGreen}}}
     object {OTube scale <0.9,0.9,1> texture {pigment {colour DarkGreen}}}
     scale <0.28,0.28,1.1>
}
plane {  z,1.001 pigment { colour White } finish {ambient 0.7} }
box { 
    <-0.5,-0.5,-0.5>,<0.5,0.5,0.5> 
    pigment { image_map { gif "epr_back.gif" } translate <0.5,0.5,0> }
    scale<4,2.98,1>
    translate <0,0.1,1>
    finish {ambient 0.7}
}
plane {  z,-15 pigment { colour White } finish {ambient 0.8} }

#declare BFT_7=union {
    object {OuterTube}
    object {InnerTube}
    object {InnerTube  translate <0.28,0,0> }
    object {InnerGTube translate <0.28,0,0> rotate <0,0, 60> }
    object {InnerRTube translate <0.28,0,0> rotate <0,0,120> }
    object {InnerTube  translate <0.28,0,0> rotate <0,0,180> }
    object {InnerTube  translate <0.28,0,0> rotate <0,0,240> }
    object {InnerTube  translate <0.28,0,0> rotate <0,0,300> }
//    no_shadow
}
#declare CTop=difference {
    torus { 0.5,0.15 rotate <0,0,-90>}
    box { <-1,-1,0>,<1,1,1> }
    box { <-1,0,0>,<1,-1,-1> }
    translate <0,-0.5,0>
}
#declare LTop=difference {
    torus { 0.5,0.15 rotate <0,0,-90>}
    box { <-1,-1,0>,<1,1,1> }
    translate <0,0.5,0>
}
#declare MyMetal = 
 finish
  {metallic
   ambient 0.3
   diffuse 0.7
   brilliance 10
   reflection 0.3
   phong 0.9
   phong_size 100
  }
#declare Link=union {
    object {LTop}
    cylinder { <0,0,0>,<0,0,2>,0.15 }
    cylinder { <0,1,0>,<0,1,2>,0.15 }
    rotate <0,0,30>
    scale 0.28
    texture { pigment {colour Blue} } finish { MyMetal }
//    texture { Brass_Metal }
//    no_shadow
}
#declare PLink=union {
    object {CTop}
    cylinder { <0,0,0>,<0,0,2>,0.15 }
    cylinder { <0,-0.5,-0.5>,<0,-2.5,-0.5>,0.15 }
    scale 0.28
    texture { pigment {colour Blue} } finish { MyMetal }
//    texture { Brass_Metal }
//    no_shadow
}
#declare RLink=union {
    object {CTop}
    cylinder { <0,0,0>,<0,0,2>,0.15 }
    cylinder { <0,-0.5,-0.5>,<0,-1.5,-0.5>,0.15 }
    scale 0.28
    texture { pigment {colour Blue} } finish { MyMetal }
//    texture { Brass_Metal }
//    no_shadow
}

object {BFT_7 translate <-1,0,0> } 
object {BFT_7 translate < 0,0,0> } 
object {BFT_7 translate < 1,0,0> } 

#declare LetE=union {
   object {Link  rotate <0,0,-120> } 
   object {Link  rotate <0,0,60> } 
   object {Link  translate < 0.28,0,0> } 
   object {Link  translate < 0.28,0,0> rotate <0,0, 60>} 
   object {Link  translate < 0.28,0,0> rotate <0,0,120>} 
   object {Link  translate < 0.28,0,0> rotate <0,0,180>} 
   object {Link  translate < 0.28,0,0> rotate <0,0,240>} 
}
#declare LetP=union {
   object {Link  translate < 0.28,0,0> } 
   object {Link  translate < 0.28,0,0> rotate <0,0, 60>} 
   object {Link  translate < 0.28,0,0> rotate <0,0,120>} 
   object {Link  translate < 0.28,0,0> rotate <0,0,180>} 
   object {Link  translate < 0.28,0,0> rotate <0,0,240>} 
   object {Link  translate < 0.28,0,0> rotate <0,0,300>} 
   object {PLink  translate < -0.28,0,0> } 
}
#declare LetR=union {
   object {Link  translate < 0.28,0,0> } 
   object {Link  translate < 0.28,0,0> rotate <0,0, 60>} 
   object {Link  translate < 0.28,0,0> rotate <0,0,120>} 
   object {RLink  translate < -0.28,0,0> } 
}
object {LetE translate <-1,0,0> } 
object {LetP translate < 0,0,0> } 
object {LetR translate < 1,0,0> } 
