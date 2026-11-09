#define MENUPROC_C

#include <string.h>

#include "types.h"
#include "keydef.h"
#include "config.h"
#include "message.h"
#include "formproc.h"
#include "calc.h"
#include "fldproc.h"
#include "formhand.h"
#include "menuproc.h"
#include "actions.h"
#include "function.h"
#include "control.h"
//************************************************************
//F drawmenu
//S draw a menu on the screen
//D 
void drawmenu(void)
{
    INT i,o=6;
	ENTRY(2910);
    sendmsg("OUTPUT1",MESSAGE_R);

    sendmsg("OUTPUT1",MESSAGE_S,3);
	if (G_refson) prformname(&G_form);
    sendmsg("OUTPUT1",MESSAGE_A,G_form.items[0].attrib);
    sendmsg("OUTPUT1",MESSAGE_TEXT,G_form.items[0].pos.x,G_form.items[0].pos.y,G_form.items[0].item);
	runaction(G_form.items[0].func);
    sendmsg("OUTPUT1",MESSAGE_S,2);
	if (G_refson) prformref(&(G_form.items[0]));
	if ((G_form.numitem-2)>10) o=6-((G_form.numitem-12)/2); // Centre
    for (i=1;i<(G_form.numitem-1);i++) {
        sendmsg("OUTPUT1",MESSAGE_A,G_form.items[i].attrib);
		if (i<10) {
			sendmsg("OUTPUT1",MESSAGE_o,0,o+i,"%d",i%10);
		} else {
			sendmsg("OUTPUT1",MESSAGE_o,0,o+i,"%c",'A'+(i-10));
		}
        sendmsg("OUTPUT1",MESSAGE_TEXT,3,o+i,G_form.items[i].item);
        sendmsg("OUTPUT1",MESSAGE_r,3,o+i,74);
		if (G_refson) prformref(&(G_form.items[i]));
    }

   sendmsg("OUTPUT1",MESSAGE_S,1);
   sendmsg("OUTPUT1",MESSAGE_A,G_form.items[i].attrib);
   sendmsg("OUTPUT1",MESSAGE_TEXT,0,24,G_form.items[i].item);
	if (G_refson) prformref(&(G_form.items[i]));
	if (G_refson==2) sendmsg("INPUT1",MESSAGE_i);
	RETURN;
}
//************************************************************
//F menucur
//S menu cursor at G_form.curitem
//D Position menu cursor
void menucur(void)
{
	INT o=7;
	ENTRY(2915);
    if ((!G_exit2top)&&(!G_exit2mrk)) {
    	if ((G_form.numitem-2)>10) o=7-((G_form.numitem-12)/2); // Centre
        sendmsg("OUTPUT1",MESSAGE_C,3,0,G_form.curitem+o,74,1);
    }
   RETURN;
}
//************************************************************
//F runmenu
//S process a menu key presses and actions
//D Draw the menu, position the cursor, print date and then wait
//D for key entry for menu item selection.
INT runmenu(void)
{
   INT k;
	LONG fl;
	ENTRY(2920);
   G_form.curitem=0;
   drawmenu();

	menucur();
	prdate();
	while (G_form.curitem<G_form.numitem) {
       	k=(INT)sendmsg("INPUT1",MESSAGE_i);
		menucur();
		fl=G_formloaded;
        switch (k) {
      	    case UP   : if ((--G_form.curitem)<0)
         	    G_form.curitem=(INT16)(G_form.numitem-3);
                k=0;
                break;
            case DOWN : if ((++G_form.curitem)>G_form.numitem-3) G_form.curitem=0; k=0; break;
            case CR   :	runaction(G_form.items[G_form.curitem+1].func); k=0; break;
            case EXIT_K  : G_form.curitem=G_form.numitem; k=0; break;
            case LANGSWITCH : k=0; break;
			case '1' : case '2' : case '3' : case '4' : case '5' :
			case '6' : case '7' : case '8' : case '9' : k-='0'; break;
			case 'a' : case 'b' : case 'c' : case 'd' : case 'e' : case 'f' : 
			case 'g' : case 'h' : case 'i' : case 'j' : k-=('a'-10); break;
			case 'A' : case 'B' : case 'C' : case 'D' : case 'E' : case 'F' : 
			case 'G' : case 'H' : case 'I' : case 'J' : k-=('A'-10); break;
            case CALC : proccalc(G_calcxpos,G_calcypos); break;
			default : beep();
        }
		if ((k<20)&&(k>0)) {
        	if (k<G_form.numitem-1) {
            	G_form.curitem=(INT16)(k-1);
            	runaction(G_form.items[k].func);
        	}
        	else {
            	beep();
        	}
		}
		if ((G_exit2top)||(G_exit2mrk)) {
			G_exitkey=EXIT_K;
			G_form.curitem=G_form.numitem;
		}
        if ((G_form.curitem!=G_form.numitem)&&(fl==G_formloaded))
			menucur();
    }
    RETURNV(1);
}
//************************************************************
// End of file - menuproc.c 


