# Shell for calling turnpoly -- Run with TURTLE
# DO POLYTSH.T
# Other fun values: 100,200,0,60
#                   100,124,45,60
#                   50,90,0,45
#                   50,90,0,20
show off
prompt Welcome to the TURNPOLY demonstration
prompt I will need a size, angle, direction, and delta to create
prompt the drawing. If you don't know what to enter, try the
prompt values I suggest. (You must enter them -- don't just
prompt press Enter.) To return to the turtle prompt, press
prompt Control-Break
prompt Size? (100)
set s %i
prompt Angle? (124)
set a %i
prompt Direction? (0)
set d %i
prompt Delta? (60)
set c %i
do turnpoly.t
goto polytsh.t
