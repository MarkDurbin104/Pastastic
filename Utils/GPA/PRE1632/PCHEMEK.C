
#define NR_CHAR_IN_DIGI  4
#define NR_LINE          3
#define NR_DIGI_IN_NUMX  3
#define NR_CHAR_IN_LINE  71 
#define LENG             13
#define COM              1
#define DATA_READY       0x100
#define SETTINGS         (0x02 | 0x00 | 0x18 | 0xE0)

int p4566(int ix,int nr)
{
   char *numb[11]={"*ZER","*JED","*DWA",
                   "*TRZ","*CZT","*PIE",
                   "*SZE","*SIE","*OSI",
                   "*DZI","****"};

   char *numx[NR_LINE] = {"*123*234*345*","*123*234*345*","*123*234*345*"};
   char pdate[7],tm[3],am[LENG + 1],bi[LENG + 1];

   char st[]= {'\x1B',';','0','1','$','\x1B','j','0','$',
               '\x1E',
               '\x1B', 'F','3','9',',','5','1',',','1','2','8',',','2','4','4',
               ',',
               '4','4','0','$',
               '\x1B','@','6','0',',','2','5','2',',','2','6','6','$',
               '\x1B', 'E','3','5',',','6','3',',','9','1',',','1','1','9',',',
               '1','4','7',',','1','7','5',',','2','0','3',',','2','3','1','$',
               '\x1B','_','\x1B','?','\x1B','[','\x1B','?','\0'};
     
   char cr[]  = {'\x0D','\x0A','\0'};
   char en[]  = {'\x1B',']','\x1B','?','\0'};
   char vt[]  = {'\x0B','\0'};
   char ht[]  = {'\x09','\0'};
   
   int i,j,k,x,y,len;

   ENTRY(1280);
   strcpy(pdate,datestr(MINDATE));

   len = strlen(G_formvars[G_form.curitem-2]);
   for(i = 0; i < LENG; i++)
   {
      y = i - (LENG - len);
      if(y < 0) am[i] = '*'; else am[i] = G_formvars[G_form.curitem-2][y];
   } 
   am[LENG] = 0;

   len = strlen(G_formvars[G_form.curitem-1]);
   for(i = 0; i < LENG; i++)
   {
      y = i - (LENG - len);
      if(y < 0) bi[i] = '*'; else bi[i] = G_formvars[G_form.curitem-1][y];
   }
   bi[LENG] = 0; 

   i = 0;
   for(k = 0; k < NR_LINE; k++)
   { 
      for(j = 0; j < NR_DIGI_IN_NUMX; j++)
      {     
         y = i - (NR_LINE * NR_DIGI_IN_NUMX - len);
         if(y < 0) strcpy(&numx[k][j*NR_CHAR_IN_DIGI],numb[10]);
         else
         {
            x = G_formvars[G_form.curitem-1][y] - 48;               
            strcpy(&numx[k][j*NR_CHAR_IN_DIGI],numb[x]); 
         }
         i++;
      }
      numx[k][NR_DIGI_IN_NUMX*NR_CHAR_IN_DIGI] = '*';
      numx[k][NR_DIGI_IN_NUMX*NR_CHAR_IN_DIGI + 1] = 0;
   }

   bioscom(0, SETTINGS, COM);

   len = strlen(st);
   for(i = 0; i < len; i++)  bioscom(1,st[i],COM); 

   for(i = 0; i < nr; i++)   bioscom(1,vt[0],COM); 
                             bioscom(1,ht[0],COM); 

   for(i = 0; i < 6; i++)    bioscom(1,pdate[i],COM);                       
   for(i = 0; i < 4; i++)    bioscom(1,ht[0],COM); 
                         
   for(i=0;i<(NR_CHAR_IN_DIGI*NR_DIGI_IN_NUMX+1);i++)bioscom(1,numx[0][i],COM);

   for(i = 0; i < 2; i++)    bioscom(1,cr[i],COM); 
   for(i = 0; i < 2; i++)    bioscom(1,ht[0],COM);
                   
if(!ix) 
{
                             bioscom(1,ht[0],COM); 
   for(i = 0; i < LENG; i++) bioscom(1,am[i],COM);
                             bioscom(1,ht[0],COM); 
}
else
{
   for(i = 0; i < LENG; i++) bioscom(1,am[i],COM);
                             bioscom(1,ht[0],COM);
}                        
   for(i = 0; i < LENG; i++) bioscom(1,bi[i],COM);
                             bioscom(1,ht[0],COM);

   for(i=0;i<(NR_CHAR_IN_DIGI*NR_DIGI_IN_NUMX+1);i++)bioscom(1,numx[1][i],COM);

   for(i = 0; i < 2; i++)    bioscom(1,cr[i],COM); 

   for(i = 0; i < 5; i++)    bioscom(1,ht[0],COM);
                   
   for(i=0;i<(NR_CHAR_IN_DIGI*NR_DIGI_IN_NUMX+1);i++)bioscom(1,numx[2][i],COM);

   for(i = 0; i < 4; i++)    bioscom(1,en[i],COM);  
 
   RETURNV(0);
}
//--------------------------------------------------------------------------

