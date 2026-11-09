//***************************************************************************
// Return the length of the record for store 'name'
int reclen(char *name)
{
    int s,i,r=0;
    if ((s=snum(name))<0) return(0);                // error invalid store
    for (i=0;i<G_store[s].numitem;i++)              // each field in store
        r+=G_lib[G_store[s].li[i]].len;             // add the length
    return(len);                                    // return total
}
//***************************************************************************
// Return the length of field 'fname' in store 'name'
int fldlen(char *name,char *fname)
{
    int s,f;
    if ((s=snum(name))<0) return(0);                // error invalid store
    if ((f=fnum(name,fname))<0) return(0);          // error invalid field
    return(G_lib[G_store[s].li[f]].len);            // return length
}
//***************************************************************************
// Return the offset of field 'fname' in the record of store 'name' 
int fldoffset(char *name,char *fname)
{
    int s,f,i,r;
    if ((s=snum(name))<0) return(0);                // error invalid store
    if ((f=fnum(name,fname))<0) return(0);          // error invalid field
    for (i=0;i<f;i++)                               // for each item (up to f)
        r+=G_lib[G_store[s].li[i]].len;             // add the length
    return(r);                                      // return total
}
//***************************************************************************

