page 55,132
;
;       Program Reset ( Chapter 6 )
;
;               System reload
;               =============
;
;       Voronezh, 03 February
;
;       Comment: no comment
;
.model small
FarSeg  segment at 0F000h
	org     0FFF0h
ReLd    dw      ?
FarSeg  ends
.code
	assume  ds:FarSeg
Begin :
	jmp     Far ptr Farseg:Reld
	end     begin
