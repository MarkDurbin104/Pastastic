#include <math.h>
#include <stdio.h>
#include <conio.h>
#include <fcntl.h>
#include <io.h>
#include <string.h>
#include "convhpgl.h"

int  readinfile(char *filnam) {
	char currentln[200];
	int  fdes;
	int  counter=0;
	char term1='\n';
	char term2=';';
	seperator=',';
	if ((fdes=open(filnam,O_RDONLY))==(-1)) {
		return(0);
	}
	counter=0;
	while (!(kbhit())) {

		if (read(fdes,&currentln[counter],1)==0) {
			close(fdes);
			return(1);
		}
/*		while (((currentln[counter]=getrx())==(-1))&&(!(kbhit())));*/
		if ((currentln[counter]==term1) || (currentln[counter]==term2)) {
			currentln[counter]=0;
			printf("%s\n",currentln);
			interpln(currentln);
			counter=(-1);
		}
		counter++;
	}
	getch();
	return(1);
}
void interpln(char *currentln) {
	int i;
	double tmpd1,tmpd2;
	union test {
		int val;
		char line[500];
    } current;
	strcpy(current.line,currentln);
	switch(current.val) {
		case 'AA' : {
			getints(currentln);
			if (argus.no>2) {
				if (argus.no<4) {
					arcabs(argus.ag[0],argus.ag[1],argus.ag[2],360/G_chord_tol);
				}
				else {
					arcabs(argus.ag[0],argus.ag[1],argus.ag[2],360/argus.ag[3]);
				}
			}
		} break;
		case 'AF' : {	/* AF advance full page (IGNORED)		*/
		} break;
		case 'AH' : {	/* AH advance half page (IGNORED)		*/
		} break;
		case 'AP' : {	/* AP automatic pen operation n			*/

				/*  TO DO  */

		} break;
		case 'AR' : {	/* AR arc relative x,y,arc ang,chord t	*/
			getints(currentln);
			if (argus.no>2) {
				if (argus.no<4) {
					arcrel(argus.ag[0],argus.ag[1],argus.ag[2],360/G_chord_tol);
				}
				else {
					arcrel(argus.ag[0],argus.ag[1],argus.ag[2],360/argus.ag[3]);
				}
			}
		} break;
		case 'AS' : {	/* AS select pen accel a,(pen no) (IGNORE)	*/
		} break;
		case 'BF' : {	/* BF buffer plot							*/

				/*  TO DO  */

		} break;
		case 'BL' : {	/* BL buffer label c...c					*/
			gettxt(currentln);
			strcpy(G_labbuf,argut);
		} break;
		case 'CA' : {	/* CA designate alt char set (set)			*/
			getints(currentln);
			if (argus.no==1) {
				G_afont=argus.ag[0];
			}
			else {
				G_afont=0;
			}
		} break;
		case 'CC' : {	/* CC chord angle a	(IGNORE) - arc fonts	*/
		} break;
		case 'CI' : {	/* CI circle of R,(chord t)				*/
			getints(currentln);
			if (argus.no>0) {
				if (argus.no<2) {
					dpoly(0,G_xcur,G_ycur,argus.ag[0],argus.ag[0],360/G_chord_tol,0,0,360,G_rotation,0);
				}
				else {
					dpoly(0,G_xcur,G_ycur,argus.ag[0],argus.ag[0],360/argus.ag[1],0,0,360,G_rotation,0);
				}
			}
		} break;
		case 'CM' : {	/* CM Char select mode switch,(mode)	*/

			/*  TO DO  */

		} break;
		case 'CP' : {	/* CP char plot spaces,lines			*/
			getints(currentln);
			if (argus.no==2) {
				G_labwid=argus.ag[0];
				G_labhgt=argus.ag[1];
			}
		} break;
		case 'CS' : {	/* CS designate char set (set)			*/
			getints(currentln);
			if (argus.no>=1) {
				G_font=argus.ag[0];
				G_cfont=argus.ag[0];
			}
			else {
				G_font=0;
				G_cfont=0;
			}
		} break;
		case 'CT' : {	/* CT set chord tol n					*/
			getints(currentln);
			if (argus.no==1) {
				G_chord_tol=argus.ag[0];
			}
			else {
				G_chord_tol=5;
			}
		} break;
		case 'DC' : {	/* DC digitize clear (IGNORED)				*/
		} break;
		case 'DF' : {	/* DF  set default status					*/
			setdefaults();
		} break;
		case 'DI' : {	/* DI set abs label direction   run,rise	*/
			getflts(currentln);
			if (arguf.no==2) {
				tmpd1=arguf.ag[1]-G_ycur;
				tmpd2=arguf.ag[0]-G_xcur;
				if ((tmpd1==0)&&(tmpd2==0)) {
					G_labdir=0;
				}
				else {
					G_labdir=(double)DEGREE*atan2(tmpd1,tmpd2);
				}
			}
		} break;
		case 'DL' : {	/* DL Define download char set (IGNORE)		*/
			/* I'M NOT DOING THAT YET */
		} break;
		case 'DP' : {	/* DP digitize point (IGNORED)				*/
		} break;
		case 'DR' : {	/* DR set rel label direction   run,rise	*/
			getflts(currentln);
			if (arguf.no==2) {
				tmpd1=arguf.ag[1];
				tmpd2=arguf.ag[0];
				if ((tmpd1==0)&&(tmpd2==0)) {
					G_labdir=0;
				}
				else {
					G_labdir=(double)DEGREE*atan2(tmpd1,tmpd2);
				}
			}
		} break;
		case 'DS' : {	/* DS Designate char set into slot slot,set */

			/* TO DO */

		} break;
		case 'DT' : {	/* DT label termintor c						*/
			getchrs(currentln);
			if (argus.no==1) {
				G_lterm=argus.ag[0];
			}
		} break;
		case 'EA' : {	/* EA edge rectangle absolute				*/
			getints(currentln);
			if (argus.no==2) {
				drect(0,G_xcur,G_ycur,argus.ag[0],argus.ag[1]);
			}
		} break;
		case 'EC' : {	/* EC Enable cutter (IGNORED)				*/
		} break;
		case 'EP' : {	/* EP edge polygon							*/

			/*  TO DO  */

		} break;
		case 'ER' : {	/* ER edge rectangle relative				*/
			getints(currentln);
			if (argus.no==2) {
				drect(0,G_xcur,G_ycur,G_xcur+argus.ag[0],G_ycur+argus.ag[1]);
			}
		} break;
		case 'ES' : {	/* ES extra spaces between chars or lines	*/
			getints(currentln);
			if (argus.no>=1) {
				G_lspace=argus.ag[0];
			}
			if (argus.no>=2) {
				G_llines=argus.ag[1];
			}
		} break;
		case 'EW' : {	/* EW Edge wedge of circle */
			getints(currentln);
			if (argus.no>2) {
				if (argus.no<4) {
					dslice(0,G_xcur,G_ycur,argus.ag[0],argus.ag[0],360/G_chord_tol,0,argus.ag[1],argus.ag[1]+argus.ag[2],0,0);
				}
				else {
					dslice(0,G_xcur,G_ycur,argus.ag[0],argus.ag[0],360/argus.ag[3],0,argus.ag[1],argus.ag[1]+argus.ag[2],0,0);
				}
			}
		} break;
		case 'FP' : {	/* FP Fill polygon							*/

			/*  TO DO  */

		} break;
		case 'FR' : {	/* FR Advance frame (IGNORED)				*/
		} break;
		case 'FS' : {	/* FS Pen force (IGNORED)					*/
		} break;
		case 'FT' : {	/* FT Fill type								*/
			getints(currentln);
			if (argus.no==1) {
				G_fill=argus.ag[0];
			}
			if (argus.no==2) {
				G_fill=argus.ag[0]+argus.ag[1];
			}
			if (argus.no>=3) {
				G_fill=argus.ag[0]+argus.ag[1]+argus.ag[2];
			}
		} break;
		case 'GP' : {	/* GP Designate Group						*/

			/*  TO DO  */

		} break;
		case 'IC' : {	/** IC Input a character for sizing (OB)	*/
			getchrs(currentln);
			if (argus.no>0) G_onechar=argus.ag[0];
		} break;
		case 'IM' : {	/* IM Input mask's							*/
			getints(currentln);
			if (argus.no>=3) {
				G_emask=argus.ag[0];
				G_smask=argus.ag[1];
				G_pmask=argus.ag[2];
			}
		} break;
		case 'IN' : {	/* IN Initialize plotter					*/
			setdefaults();
		} break;
		case 'IP' : {	/* IP Input P1 & P2 co-ords					*/
			getints(currentln);
			if (argus.no>=4) {
				G_p1x=argus.ag[0];
				G_p1x=argus.ag[1];
				G_p2x=argus.ag[2];
				G_p2y=argus.ag[3];
			}
		} break;
		case 'IV' : {	/* IV Invoke slot							*/

			/*  TO DO  */

		} break;
		case 'IW' : {	/* IW Input Window							*/
			getints(currentln);
			if (argus.no>=4) {
				G_w1x=argus.ag[0];
				G_w2y=argus.ag[1];
				G_w1x=argus.ag[2];
				G_w2y=argus.ag[3];
			}
		} break;
		case 'LB' : {	/* LB	label ASCII string					*/
			gettxt(currentln);
			if (strlen(argut)>0) {
				if ( ((G_cfont>9)&&(G_cfont<20)) || ((G_cfont>39)&&(G_cfont<50)) || (G_cfont==70) ) {
					putvstr(G_xcur,G_ycur,G_xcur+(G_labwid*G_chawid),
							G_ycur+(G_labhgt*G_chahgt),G_chahgt,G_chawid,
							G_charslnt,argut,G_cfont,G_labdir);
				}
				else {
					putfstr(G_xcur,G_ycur,G_xcur+(G_labwid*G_chawid),
							G_ycur+(G_labhgt*G_chahgt),G_chahgt,G_chawid,
							G_charslnt,argut,G_cfont,G_labdir);
				}
			}
		} break;
		case 'LO' : {	/* LO Set label origin (pos no.)			*/

			/*  TO DO  */

		} break;
		case 'LT' : {	/* LT Line type   type,length	*/
			getints(currentln);
			if (argus.no>=1) {
				G_linetype=argus.ag[0];
            }
		} break;
		case 'NR' : {	/* NR Not ready (view state) (IGNORED)		*/
		} break;
		case 'OA' : {	/* OA Output actual position				*/

			/*  TO DO  */

		} break;
		case 'OB' : {	/* OB Output box dimensions 				*/

			/*  TO DO  */

		} break;
		case 'OC' : {	/* OC Output commanded position				*/

			/*  TO DO  */

		} break;
		case 'OD' : {	/* OD Output digitized point				*/

			/*  TO DO  */

		} break;
		case 'OE' : {	/* OE Output error          				*/

			/*  TO DO  */

		} break;
		case 'OF' : {	/* OF Output factors        				*/

			/*  TO DO  */

		} break;
		case 'OG' : {	/* OG Output count no and escape status		*/

			/*  TO DO  */

		} break;
		case 'OH' : {	/* OH Output hard clip limits				*/
			txint(G_p1x);
			txchr(',');
			txint(G_p1y);
			txchr(',');
			txint(G_p2x);
			txchr(',');
			txint(G_p2y);
			txchr('\r');
		} break;
		case 'OI' : {	/* OI Output identification (c)				*/

			/*  TO DO  */

		} break;
		case 'OK' : {	/* OK Output function key   				*/

			/*  TO DO  */

		} break;
		case 'OL' : {	/* OL Output length of buffered label		*/

			/*  TO DO  */

		} break;
		case 'OO' : {	/* OO Output options        				*/

			/*  TO DO  */

		} break;
		case 'OP' : {	/* OP Output P1 & P2       					*/

			/*  TO DO  */

		} break;
		case 'OS' : {	/* OS Output status							*/

			/*  TO DO  */

		} break;
		case 'OT' : {	/* OT Output carousel status				*/

			/*  TO DO  */

		} break;
		case 'OW' : {	/* OW Output window         				*/

			/*  TO DO  */

		} break;
		case 'PA' : {	/* PA Plot absolute							*/
			getints(currentln);
			if (argus.no>=2) {
               	for (i=0;i<argus.no;i+=2) {
					coords[nocds][0]=argus.ag[i  ];
					coords[nocds][1]=argus.ag[i+1];
					nocds++;
				}
				G_xcur=coords[nocds-1][0];
				G_ycur=coords[nocds-1][1];
			}
		} break;
		case 'PB' : {	/* PB plot lable from buffer				*/
			if (strlen(G_labbuf)>0) {
				if ( ((G_cfont>9)&&(G_cfont<20)) || ((G_cfont>39)&&(G_cfont<50)) || (G_cfont==70) ) {
					putvstr(G_xcur,G_ycur,G_xcur+(G_labwid*G_chawid),
							G_ycur+(G_labhgt*G_chahgt),G_chahgt,G_chawid,
							G_charslnt,G_labbuf,G_cfont,G_labdir);
				}
				else {
					putfstr(G_xcur,G_ycur,G_xcur+(G_labwid*G_chawid),
							G_ycur+(G_labhgt*G_chahgt),G_chahgt,G_chawid,
							G_charslnt,G_labbuf,G_cfont,G_labdir);
				}
			}
		} break;
		case 'PD' : {	/* PD Pen down								*/
			penup=0;
			getints(currentln);
			if (argus.no>=2) {
				if (!(penup)) {
	               	for (i=0;i<argus.no;i+=2) {
						coords[nocds][0]=argus.ag[i  ];
						coords[nocds][1]=argus.ag[i+1];
						nocds++;
					}
					G_xcur=coords[nocds-1][0];
					G_ycur=coords[nocds-1][1];
				}
			}
		} break;
		case 'PG' : {	/* PG Advance page	(IGNORED)				*/
		} break;
		case 'PM' : {	/* PM Enable polygon mode					*/

			/*  TO DO  */

		} break;
		case 'PR' : {	/* PR plot relative 						*/
			getints(currentln);
			if (argus.no>=2) {
				if (!(penup)) {
	               	for (i=0;i<argus.no;i+=2) {
						argus.ag[i  ]+=G_xcur;
						argus.ag[i+1]+=G_ycur;
						coords[nocds][0]=argus.ag[i  ];
						coords[nocds][1]=argus.ag[i+1];
						nocds++;
					}
					G_xcur=coords[nocds-1][0];
					G_ycur=coords[nocds-1][1];
				}
			}
		} break;
		case 'PT' : {	/* PT Pen thickness							*/

			/*  TO DO  */

		} break;
		case 'PU' : {	/* PU Pen up								*/
			penup=1;
			if (nocds>0) {
				rotapoly(origx,origy,nocds,(int *)coords,G_rotation,0);
		        ddrawpoly(0,nocds,(int *)coords);
			}
			nocds=0;
			getints(currentln);
			if (argus.no>=2) {
				G_xcur=argus.ag[argus.no-2];
				G_ycur=argus.ag[argus.no-1];
			}
		} break;
		case 'RA' : {	/* RA Fill rectangle absolute				*/
			getints(currentln);
			if (argus.no>=2) {
				drect(1,G_xcur,G_ycur,argus.ag[0],argus.ag[1]);
			}
		} break;
		case 'RO' : {	/* RO Rotate Co-ordinate system				*/
			getints(currentln);
			if (argus.no>=1) {
				G_rotation=argus.ag[0];
			}
		} break;
		case 'RP' : {	/* RP Replot buffered plot n times			*/

			/*  TO DO  */

		} break;
		case 'RR' : {	/* RR Fill rectangle relative				*/
			getints(currentln);
			if (argus.no>=2) {
				drect(1,G_xcur,G_ycur,G_xcur+argus.ag[0],G_ycur+argus.ag[1]);
			}
	} break;
		case 'SA' : {	/* SA Select alternate character set		*/
			G_font=G_afont;
		} break;
		case 'SC' : {	/* SC User unit scaling						*/

			/*  TO DO  */

		} break;
		case 'SG' : {	/* SG Select pen group						*/

			/*  TO DO  */

		} break;
		case 'SI' : {	/* SI Set absulute character size			*/
			getints(currentln);
			if (argus.no>=2) {
				G_chawid=argus.ag[0]-G_xcur;
            	G_chahgt=argus.ag[1]-G_ycur;
			}
		} break;
		case 'SL' : {	/* SL Set character slant tan(x)			*/
			getflts(currentln);
			if (arguf.no>=1) {
				G_charslnt=(double)DEGREE*atan(arguf.ag[0]);
			}
		} break;
		case 'SM' : {	/* SM Specify character for symbol plotting */

			/*  TO DO  */

		} break;
		case 'SP' : {	/* SP Select pen							*/
			getints(currentln);
			if (argus.no>=1) {
				G_colour=argus.ag[0];
			}
		} break;
		case 'SR' : {	/* SR Set relative character size			*/
			getints(currentln);
			if (argus.no>=2) {
				G_chawid=argus.ag[0];
            	G_chahgt=argus.ag[1];
			}
		} break;
		case 'SS' : {	/* SS Select standard character set			*/
			G_font=G_cfont;
		} break;
		case 'TL' : {	/* TL Set tick length						*/

        	/* TO DO */

		} break;
		case 'UC' : {	/* UC Plot user defined character			*/

        	/* TO DO */

		} break;
		case 'UF' : {	/* UF Create user defined fill type			*/

        	/* TO DO */

		} break;
		case 'VA' : {	/* VA Activate adaptive velocity (IGNORE)	*/
		} break;
		case 'VN' : {	/* VN reactivate normal velocity (IGNORE)	*/
		} break;
		case 'VS' : {	/* VS Set velocity (IGNORE)					*/
		} break;
		case 'WD' : {	/* WD Write to display (IGNORE)				*/
		} break;
		case 'WG' : {	/* WG Fill wedge of a circle				*/
			getints(currentln);
			if (argus.no>2) {
				if (argus.no<4) {
					dslice(1,G_xcur,G_ycur,argus.ag[0],argus.ag[0],360/G_chord_tol,0,argus.ag[1],argus.ag[1]+argus.ag[2],0,0);
				}
				else {
					dslice(1,G_xcur,G_ycur,argus.ag[0],argus.ag[0],360/argus.ag[3],0,argus.ag[1],argus.ag[1]+argus.ag[2],0,0);
				}
			}
		} break;
		case 'XT' : {	/* XT Draw X axis tick						*/

        	/* TO DO */

		} break;
		case 'YT' : {	/* YT Draw Y axis tick						*/

        	/* TO DO */

		} break;
		default  : {
		}
	}
}
