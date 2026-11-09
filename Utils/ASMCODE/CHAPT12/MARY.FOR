C       Program Mary ( Chapter 12 )        
C
	interface to subroutine fsound ( fr , dur )
	integer*2 fr,dur
	end
	
	program MARY  
	integer*2 freq(26)
     *            / 330 , 294 , 262 , 294 , 3*330 , 3*294,
     *              330 , 2*392 , 330 , 294 , 262 , 294 , 4*330 ,
     *              2* 294 , 330 , 294 , 262 / ,
     *     durat(26)
     *            / 6*250 , 500 , 2*250 , 500 , 2*250 , 500 ,
     *               12*250 , 1000 /
	do 10 I = 1 , 26
	   call fsound ( freq(i) , durat(i) )
10      continue
	stop
	end
