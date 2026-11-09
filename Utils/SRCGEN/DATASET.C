//============================================================================
// Module        | DATASET.C
// Description   | Structure definitions and access functions
//               | for a data schema mantenance program
//               | 
// Author        | Automatically generated from dataset.cdf by CGEN
// Copyright (c) | Unisys Limited
//               | 22 Southwark Bridge Road
//               | London SE1 9HB
//============================================================================
// Mod History   | By  | Modifications Made
//============================================================================
// 14/02/1996    | MJD | Initial Version
//============================================================================
#define DATASET_C

#include <stdio.h>  // FILE printf fread fwrite etc.
#include <string.h> // strlen
#include <malloc.h> // malloc free

#include "dataset.h"

//============================================================================
//                                DEFINITIONS                                
//============================================================================
//============================================================================
//F write_fixed
//S write a fixed length block to a file
//D write a fixed length block to a file
//P the file pointer
//P the block pointer
//P the length of the block
//R TRUE if ok, otherwise FALSE
BOOL write_fixed(FILE *fp,void *buf,INT len)
{
    if (fwrite(buf,1,len,fp)!=len) return(FALSE);
    return(TRUE);
}
//============================================================================
//F write_varib
//S write a variable length string to a file
//D write a variable length string to a file
//P the file pointer
//P the string pointer
//R TRUE if ok, otherwise FALSE
BOOL write_varib(FILE *fp,CHAR *s)
{
    INT len=strlen(s);
    if (fwrite(&len,1,sizeof(INT),fp)!=sizeof(INT)) return(FALSE);
    if (len==0) return(TRUE);
    return(write_fixed(fp,s,len));
}
//============================================================================
//F read_fixed
//S read a fixed length block from a file
//D read a fixed length block from a file
//P the file pointer
//P the block pointer
//P the length of the block
//R TRUE if ok, otherwise FALSE
BOOL read_fixed(FILE *fp,void *buf,INT len)
{
    if (fread(buf,1,len,fp)!=len) return(FALSE);
    return(TRUE);
}
//============================================================================
//F read_varib
//S read a variable length string from a file
//D read a variable length string from a file
//P the file pointer
//P the pointer to the string pointer
//R TRUE if ok, otherwise FALSE
BOOL read_varib(FILE *fp,CHAR **s)
{
    INT len;
    if (fread(&len,1,sizeof(INT),fp)!=sizeof(INT)) return(FALSE);
    if (len==0) {
        *s=NULL;
        return(TRUE);
    }
    if ((*s=MALLOC(len+1))==NULL) return(FALSE);
    if (!read_fixed(fp,*s,len)) return(FALSE);
    *((*s)+len)=0;
    return(TRUE);
}
//============================================================================
//F save_column
//S save a COLUMN structure
//D save a COLUMN structure
//P the file pointer
//P the COLUMN structure to save
//R TRUE if saved, otherwise FALSE
BOOL save_column(FILE *fp,COLUMN *cs)
{
    if ((fp==NULL)||(cs==NULL)) return FALSE;
    if (!write_varib(fp,cs->name)) return(FALSE);
    if (!write_varib(fp,cs->version)) return(FALSE);
    if (!write_varib(fp,cs->inbase)) return(FALSE);
    if (!write_varib(fp,cs->type)) return(FALSE);
    if (!write_varib(fp,cs->datatype)) return(FALSE);
    if (!write_varib(fp,cs->size)) return(FALSE);
    if (!write_varib(fp,cs->descript)) return(FALSE);
    if (!write_varib(fp,cs->comment)) return(FALSE);
    return(TRUE);
}
//============================================================================
//F save_index
//S save an INDEX structure
//D save an INDEX structure
//P the file pointer
//P the INDEX structure to save
//R TRUE if saved, otherwise FALSE
BOOL save_index(FILE *fp,INDEX *is)
{
    if ((fp==NULL)||(is==NULL)) return FALSE;
    if (!write_varib(fp,is->name)) return(FALSE);
    if (!write_varib(fp,is->version)) return(FALSE);
    if (!write_varib(fp,is->inbase)) return(FALSE);
    if (!write_fixed(fp,&(is->numcol),sizeof(UINT))) return(FALSE);
    if (!write_varib(fp,is->colname)) return(FALSE);
    if (!write_varib(fp,is->descript)) return(FALSE);
    if (!write_varib(fp,is->comment)) return(FALSE);
    return(TRUE);
}
//============================================================================
//F save_dataset
//S save a DATASET structure
//D save a DATASET structure
//P the file pointer
//P the DATASET structure to save
//R TRUE if saved, otherwise FALSE
BOOL save_dataset(FILE *fp,DATASET *ds)
{
    COUNTER count;
    if ((fp==NULL)||(ds==NULL)) return FALSE;
    if (!write_varib(fp,ds->name)) return(FALSE);
    if (!write_varib(fp,ds->version)) return(FALSE);
    if (!write_varib(fp,ds->inbase)) return(FALSE);
    if (!write_fixed(fp,&(ds->active),sizeof(BOOL))) return(FALSE);
    if (!write_fixed(fp,&(ds->numcol),sizeof(UINT))) return(FALSE);
    for (count=0;count<ds->numcol;count++) {
        if (!save_column(fp,&(ds->column[count]))) return(FALSE);
    }
    if (!write_fixed(fp,&(ds->numidx),sizeof(UINT))) return(FALSE);
    for (count=0;count<ds->numidx;count++) {
        if (!save_index(fp,&(ds->index[count]))) return(FALSE);
    }
    if (!write_varib(fp,ds->descript)) return(FALSE);
    if (!write_varib(fp,ds->comment)) return(FALSE);
    return(TRUE);
}
//============================================================================
//F save_database
//S save a DATABASE structure
//D save a DATABASE structure
//P the file pointer
//P the DATABASE structure to save
//R TRUE if saved, otherwise FALSE
BOOL save_database(FILE *fp,DATABASE *ds)
{
    COUNTER count;
    if ((fp==NULL)||(ds==NULL)) return FALSE;
    if (!write_varib(fp,ds->name)) return(FALSE);
    if (!write_varib(fp,ds->password)) return(FALSE);
    if (!write_varib(fp,ds->currver)) return(FALSE);
    if (!write_varib(fp,ds->currbase)) return(FALSE);
    if (!write_fixed(fp,&(ds->numdataset),sizeof(UINT))) return(FALSE);
    for (count=0;count<ds->numdataset;count++) {
        if (!save_dataset(fp,&(ds->dataset[count]))) return(FALSE);
    }
    if (!write_varib(fp,ds->descript)) return(FALSE);
    return(TRUE);
}
//============================================================================
//F load_column
//S load a COLUMN structure
//D load a COLUMN structure
//P the file pointer
//P the COLUMN structure to load into
//R TRUE if loaded, otherwise FALSE
BOOL load_column(FILE *fp,COLUMN *cs)
{
    if ((fp==NULL)||(cs==NULL)) return FALSE;
    if (!read_varib(fp,&(cs->name))) return(FALSE);
    if (!read_varib(fp,&(cs->version))) return(FALSE);
    if (!read_varib(fp,&(cs->inbase))) return(FALSE);
    if (!read_varib(fp,&(cs->type))) return(FALSE);
    if (!read_varib(fp,&(cs->datatype))) return(FALSE);
    if (!read_varib(fp,&(cs->size))) return(FALSE);
    if (!read_varib(fp,&(cs->descript))) return(FALSE);
    if (!read_varib(fp,&(cs->comment))) return(FALSE);
    return(TRUE);
}
//============================================================================
//F load_index
//S load an INDEX structure
//D load an INDEX structure
//P the file pointer
//P the INDEX structure to load into
//R TRUE if loaded, otherwise FALSE
BOOL load_index(FILE *fp,INDEX *is)
{
    if ((fp==NULL)||(is==NULL)) return FALSE;
    if (!read_varib(fp,&(is->name))) return(FALSE);
    if (!read_varib(fp,&(is->version))) return(FALSE);
    if (!read_varib(fp,&(is->inbase))) return(FALSE);
    if (!read_fixed(fp,&(is->numcol),sizeof(UINT))) return(FALSE);
    if (!read_varib(fp,&(is->colname))) return(FALSE);
    if (!read_varib(fp,&(is->descript))) return(FALSE);
    if (!read_varib(fp,&(is->comment))) return(FALSE);
    return(TRUE);
}
//============================================================================
//F load_dataset
//S load a DATASET structure
//D load a DATASET structure
//P the file pointer
//P the DATASET structure to load into
//R TRUE if loaded, otherwise FALSE
BOOL load_dataset(FILE *fp,DATASET *ds)
{
    COUNTER count;
    if ((fp==NULL)||(ds==NULL)) return FALSE;
    if (!read_varib(fp,&(ds->name))) return(FALSE);
    if (!read_varib(fp,&(ds->version))) return(FALSE);
    if (!read_varib(fp,&(ds->inbase))) return(FALSE);
    if (!read_fixed(fp,&(ds->active),sizeof(BOOL))) return(FALSE);
    if (!read_fixed(fp,&(ds->numcol),sizeof(UINT))) return(FALSE);
    ds->column=MALLOC(ds->numcol*sizeof(COLUMN));
    if (ds->column==NULL) return(FALSE);
    for (count=0;count<ds->numcol;count++) {
        if (!load_column(fp,&(ds->column[count]))) return(FALSE);
    }
    ds->primidx=NULL;
    if (!read_fixed(fp,&(ds->numidx),sizeof(UINT))) return(FALSE);
    ds->index=MALLOC(ds->numidx*sizeof(INDEX));
    if (ds->index==NULL) return(FALSE);
    for (count=0;count<ds->numidx;count++) {
        if (!load_index(fp,&(ds->index[count]))) return(FALSE);
    }
    if (!read_varib(fp,&(ds->descript))) return(FALSE);
    if (!read_varib(fp,&(ds->comment))) return(FALSE);
    return(TRUE);
}
//============================================================================
//F load_database
//S load a DATABASE structure
//D load a DATABASE structure
//P the file pointer
//P the DATABASE structure to load into
//R TRUE if loaded, otherwise FALSE
BOOL load_database(FILE *fp,DATABASE *ds)
{
    COUNTER count;
    if ((fp==NULL)||(ds==NULL)) return FALSE;
    if (!read_varib(fp,&(ds->name))) return(FALSE);
    if (!read_varib(fp,&(ds->password))) return(FALSE);
    if (!read_varib(fp,&(ds->currver))) return(FALSE);
    if (!read_varib(fp,&(ds->currbase))) return(FALSE);
    if (!read_fixed(fp,&(ds->numdataset),sizeof(UINT))) return(FALSE);
    ds->dataset=MALLOC(ds->numdataset*sizeof(DATASET));
    if (ds->dataset==NULL) return(FALSE);
    for (count=0;count<ds->numdataset;count++) {
        if (!load_dataset(fp,&(ds->dataset[count]))) return(FALSE);
    }
    if (!read_varib(fp,&(ds->descript))) return(FALSE);
    return(TRUE);
}
//============================================================================
//F prnt_column
//S print a COLUMN structure
//D print a COLUMN structure on stdout
//P the COLUMN structure to print
//P the indent depth
void prnt_column(COLUMN *cs,INT depth)
{
    if (cs==NULL) return;
    printf("%*.*sCOLUMN structure\n",depth,depth,"");
    if (PTRCHECK(cs->name))
        printf("%*.*sname  %s\n",depth,depth,"",cs->name);
    if (PTRCHECK(cs->version))
        printf("%*.*sversion  %s\n",depth,depth,"",cs->version);
    if (PTRCHECK(cs->inbase))
        printf("%*.*sinbase  %s\n",depth,depth,"",cs->inbase);
    if (PTRCHECK(cs->type))
        printf("%*.*stype  %s\n",depth,depth,"",cs->type);
    if (PTRCHECK(cs->datatype))
        printf("%*.*sdatatype  %s\n",depth,depth,"",cs->datatype);
    if (PTRCHECK(cs->size))
        printf("%*.*ssize  %s\n",depth,depth,"",cs->size);
    if (PTRCHECK(cs->descript))
        printf("%*.*sdescript  %s\n",depth,depth,"",cs->descript);
    if (PTRCHECK(cs->comment))
        printf("%*.*scomment  %s\n",depth,depth,"",cs->comment);
}
//============================================================================
//F prnt_index
//S print an INDEX structure
//D print an INDEX structure on stdout
//P the INDEX structure to print
//P the indent depth
void prnt_index(INDEX *is,INT depth)
{
    if (is==NULL) return;
    printf("%*.*sINDEX structure\n",depth,depth,"");
    if (PTRCHECK(is->name))
        printf("%*.*sname  %s\n",depth,depth,"",is->name);
    if (PTRCHECK(is->version))
        printf("%*.*sversion  %s\n",depth,depth,"",is->version);
    if (PTRCHECK(is->inbase))
        printf("%*.*sinbase  %s\n",depth,depth,"",is->inbase);
    printf("%*.*snumcol  %d\n",depth,depth,"",is->numcol);
    if (PTRCHECK(is->colname))
        printf("%*.*scolname  %s\n",depth,depth,"",is->colname);
    if (PTRCHECK(is->descript))
        printf("%*.*sdescript  %s\n",depth,depth,"",is->descript);
    if (PTRCHECK(is->comment))
        printf("%*.*scomment  %s\n",depth,depth,"",is->comment);
}
//============================================================================
//F prnt_dataset
//S print a DATASET structure
//D print a DATASET structure on stdout
//P the DATASET structure to print
//P the indent depth
void prnt_dataset(DATASET *ds,INT depth)
{
    COUNTER count;
    if (ds==NULL) return;
    printf("%*.*sDATASET structure\n",depth,depth,"");
    if (PTRCHECK(ds->name))
        printf("%*.*sname  %s\n",depth,depth,"",ds->name);
    if (PTRCHECK(ds->version))
        printf("%*.*sversion  %s\n",depth,depth,"",ds->version);
    if (PTRCHECK(ds->inbase))
        printf("%*.*sinbase  %s\n",depth,depth,"",ds->inbase);
    printf("%*.*sactive  %d\n",depth,depth,"",ds->active);
    printf("%*.*snumcol  %d\n",depth,depth,"",ds->numcol);
    for (count=0;count<ds->numcol;count++) {
        prnt_column(&(ds->column[count]),depth+4);
    }
    // ds->primidx Length Unknown assumed to be 1
    prnt_index(ds->primidx,depth+4);
    printf("%*.*snumidx  %d\n",depth,depth,"",ds->numidx);
    for (count=0;count<ds->numidx;count++) {
        prnt_index(&(ds->index[count]),depth+4);
    }
    if (PTRCHECK(ds->descript))
        printf("%*.*sdescript  %s\n",depth,depth,"",ds->descript);
    if (PTRCHECK(ds->comment))
        printf("%*.*scomment  %s\n",depth,depth,"",ds->comment);
}
//============================================================================
//F prnt_database
//S print a DATABASE structure
//D print a DATABASE structure on stdout
//P the DATABASE structure to print
//P the indent depth
void prnt_database(DATABASE *ds,INT depth)
{
    COUNTER count;
    if (ds==NULL) return;
    printf("%*.*sDATABASE structure\n",depth,depth,"");
    if (PTRCHECK(ds->name))
        printf("%*.*sname  %s\n",depth,depth,"",ds->name);
    if (PTRCHECK(ds->password))
        printf("%*.*spassword  %s\n",depth,depth,"",ds->password);
    if (PTRCHECK(ds->currver))
        printf("%*.*scurrver  %s\n",depth,depth,"",ds->currver);
    if (PTRCHECK(ds->currbase))
        printf("%*.*scurrbase  %s\n",depth,depth,"",ds->currbase);
    printf("%*.*snumdataset  %d\n",depth,depth,"",ds->numdataset);
    for (count=0;count<ds->numdataset;count++) {
        prnt_dataset(&(ds->dataset[count]),depth+4);
    }
    if (PTRCHECK(ds->descript))
        printf("%*.*sdescript  %s\n",depth,depth,"",ds->descript);
}
//============================================================================
//F free_column
//S free a COLUMN structure
//D free a COLUMN structure and all it's sub-structures
//P the COLUMN structure to free
void free_column(COLUMN *cs)
{
    if (cs==NULL) return;
    if (PTRCHECK(cs->name)) { FREE(cs->name); cs->name=NULL; }
    if (PTRCHECK(cs->version)) { FREE(cs->version); cs->version=NULL; }
    if (PTRCHECK(cs->inbase)) { FREE(cs->inbase); cs->inbase=NULL; }
    if (PTRCHECK(cs->type)) { FREE(cs->type); cs->type=NULL; }
    if (PTRCHECK(cs->datatype)) { FREE(cs->datatype); cs->datatype=NULL; }
    if (PTRCHECK(cs->size)) { FREE(cs->size); cs->size=NULL; }
    if (PTRCHECK(cs->descript)) { FREE(cs->descript); cs->descript=NULL; }
    if (PTRCHECK(cs->comment)) { FREE(cs->comment); cs->comment=NULL; }
}
//============================================================================
//F free_index
//S free an INDEX structure
//D free an INDEX structure and all it's sub-structures
//P the INDEX structure to free
void free_index(INDEX *is)
{
    if (is==NULL) return;
    if (PTRCHECK(is->name)) { FREE(is->name); is->name=NULL; }
    if (PTRCHECK(is->version)) { FREE(is->version); is->version=NULL; }
    if (PTRCHECK(is->inbase)) { FREE(is->inbase); is->inbase=NULL; }
    if (PTRCHECK(is->colname)) { FREE(is->colname); is->colname=NULL; }
    if (PTRCHECK(is->descript)) { FREE(is->descript); is->descript=NULL; }
    if (PTRCHECK(is->comment)) { FREE(is->comment); is->comment=NULL; }
}
//============================================================================
//F free_dataset
//S free a DATASET structure
//D free a DATASET structure and all it's sub-structures
//P the DATASET structure to free
void free_dataset(DATASET *ds)
{
    COUNTER count;
    if (ds==NULL) return;
    if (PTRCHECK(ds->name)) { FREE(ds->name); ds->name=NULL; }
    if (PTRCHECK(ds->version)) { FREE(ds->version); ds->version=NULL; }
    if (PTRCHECK(ds->inbase)) { FREE(ds->inbase); ds->inbase=NULL; }
    for (count=0;count<ds->numcol;count++) {
        free_column(&(ds->column[count]));
    }
    ds->numcol=0;
    if (PTRCHECK(ds->column)) { FREE(ds->column); ds->column=NULL; }
    ds->primidx=NULL;     for (count=0;count<ds->numidx;count++) {
        free_index(&(ds->index[count]));
    }
    ds->numidx=0;
    if (PTRCHECK(ds->index)) { FREE(ds->index); ds->index=NULL; }
    if (PTRCHECK(ds->descript)) { FREE(ds->descript); ds->descript=NULL; }
    if (PTRCHECK(ds->comment)) { FREE(ds->comment); ds->comment=NULL; }
}
//============================================================================
//F free_database
//S free a DATABASE structure
//D free a DATABASE structure and all it's sub-structures
//P the DATABASE structure to free
void free_database(DATABASE *ds)
{
    COUNTER count;
    if (ds==NULL) return;
    if (PTRCHECK(ds->name)) { FREE(ds->name); ds->name=NULL; }
    if (PTRCHECK(ds->password)) { FREE(ds->password); ds->password=NULL; }
    if (PTRCHECK(ds->currver)) { FREE(ds->currver); ds->currver=NULL; }
    if (PTRCHECK(ds->currbase)) { FREE(ds->currbase); ds->currbase=NULL; }
    for (count=0;count<ds->numdataset;count++) {
        free_dataset(&(ds->dataset[count]));
    }
    ds->numdataset=0;
    if (PTRCHECK(ds->dataset)) { FREE(ds->dataset); ds->dataset=NULL; }
    if (PTRCHECK(ds->descript)) { FREE(ds->descript); ds->descript=NULL; }
}
//============================================================================
//F apnd_column
//S append a COLUMN structure
//D append a COLUMN structure to an array of structures
//P the base COLUMN structure
//P the number of elements in the base COLUMN structure array
//P the new COLUMN structure to add
//R TRUE if the new structure appended, otherwise FALSE
BOOL apnd_column(COLUMN **c_base,UINT *numelem,COLUMN *new_c)
{
    if ((c_base==NULL)||(new_c==NULL)) return FALSE;
    if (*c_base==NULL) {
        *c_base=MALLOC(sizeof(COLUMN));
    } else {
        *c_base=REALLOC(*c_base,(*numelem+1)*sizeof(COLUMN));
    }
    if (*c_base==NULL) return FALSE;
    memcpy((*c_base)+*numelem,new_c,sizeof(COLUMN));
    (*numelem)++;
    return TRUE;
}
//============================================================================
//F apnd_index
//S append an INDEX structure
//D append an INDEX structure to an array of structures
//P the base INDEX structure
//P the number of elements in the base INDEX structure array
//P the new INDEX structure to add
//R TRUE if the new structure appended, otherwise FALSE
BOOL apnd_index(INDEX **i_base,UINT *numelem,INDEX *new_i)
{
    if ((i_base==NULL)||(new_i==NULL)) return FALSE;
    if (*i_base==NULL) {
        *i_base=MALLOC(sizeof(INDEX));
    } else {
        *i_base=REALLOC(*i_base,(*numelem+1)*sizeof(INDEX));
    }
    if (*i_base==NULL) return FALSE;
    memcpy((*i_base)+*numelem,new_i,sizeof(INDEX));
    (*numelem)++;
    return TRUE;
}
//============================================================================
//F apnd_dataset
//S append a DATASET structure
//D append a DATASET structure to an array of structures
//P the base DATASET structure
//P the number of elements in the base DATASET structure array
//P the new DATASET structure to add
//R TRUE if the new structure appended, otherwise FALSE
BOOL apnd_dataset(DATASET **d_base,UINT *numelem,DATASET *new_d)
{
    if ((d_base==NULL)||(new_d==NULL)) return FALSE;
    if (*d_base==NULL) {
        *d_base=MALLOC(sizeof(DATASET));
    } else {
        *d_base=REALLOC(*d_base,(*numelem+1)*sizeof(DATASET));
    }
    if (*d_base==NULL) return FALSE;
    memcpy((*d_base)+*numelem,new_d,sizeof(DATASET));
    (*numelem)++;
    return TRUE;
}
//============================================================================
//F apnd_database
//S append a DATABASE structure
//D append a DATABASE structure to an array of structures
//P the base DATABASE structure
//P the number of elements in the base DATABASE structure array
//P the new DATABASE structure to add
//R TRUE if the new structure appended, otherwise FALSE
BOOL apnd_database(DATABASE **d_base,UINT *numelem,DATABASE *new_d)
{
    if ((d_base==NULL)||(new_d==NULL)) return FALSE;
    if (*d_base==NULL) {
        *d_base=MALLOC(sizeof(DATABASE));
    } else {
        *d_base=REALLOC(*d_base,(*numelem+1)*sizeof(DATABASE));
    }
    if (*d_base==NULL) return FALSE;
    memcpy((*d_base)+*numelem,new_d,sizeof(DATABASE));
    (*numelem)++;
    return TRUE;
}
//============================================================================
//F inst_column
//S insert a COLUMN structure
//D insert a COLUMN structure to an array of structures
//P the pointer to the base COLUMN structure
//P the number of elements in the base COLUMN structure array
//P the new COLUMN structure to insert
//P the insertion offset
//R TRUE if the new structure inserted, otherwise FALSE
BOOL inst_column(COLUMN **c_base,UINT *numelem,COLUMN *new_c,UINT offset)
{
    COUNTER count;
    if ((c_base==NULL)||(new_c==NULL)||(offset>=*numelem)) return FALSE;
    if (*c_base==NULL) {
        *c_base=MALLOC(sizeof(COLUMN));
    } else {
        *c_base=REALLOC(*c_base,(*numelem+1)*sizeof(COLUMN));
    }
    if (*c_base==NULL) return FALSE;
    for (count=*numelem;count>offset;count--) {
        memcpy((*c_base)+count,(*c_base)+count-1,sizeof(COLUMN));
    }
    memcpy((*c_base)+offset,new_c,sizeof(COLUMN));
    (*numelem)++;
    return TRUE;
}
//============================================================================
//F inst_index
//S insert an INDEX structure
//D insert an INDEX structure to an array of structures
//P the pointer to the base INDEX structure
//P the number of elements in the base INDEX structure array
//P the new INDEX structure to insert
//P the insertion offset
//R TRUE if the new structure inserted, otherwise FALSE
BOOL inst_index(INDEX **i_base,UINT *numelem,INDEX *new_i,UINT offset)
{
    COUNTER count;
    if ((i_base==NULL)||(new_i==NULL)||(offset>=*numelem)) return FALSE;
    if (*i_base==NULL) {
        *i_base=MALLOC(sizeof(INDEX));
    } else {
        *i_base=REALLOC(*i_base,(*numelem+1)*sizeof(INDEX));
    }
    if (*i_base==NULL) return FALSE;
    for (count=*numelem;count>offset;count--) {
        memcpy((*i_base)+count,(*i_base)+count-1,sizeof(INDEX));
    }
    memcpy((*i_base)+offset,new_i,sizeof(INDEX));
    (*numelem)++;
    return TRUE;
}
//============================================================================
//F inst_dataset
//S insert a DATASET structure
//D insert a DATASET structure to an array of structures
//P the pointer to the base DATASET structure
//P the number of elements in the base DATASET structure array
//P the new DATASET structure to insert
//P the insertion offset
//R TRUE if the new structure inserted, otherwise FALSE
BOOL inst_dataset(DATASET **d_base,UINT *numelem,DATASET *new_d,UINT offset)
{
    COUNTER count;
    if ((d_base==NULL)||(new_d==NULL)||(offset>=*numelem)) return FALSE;
    if (*d_base==NULL) {
        *d_base=MALLOC(sizeof(DATASET));
    } else {
        *d_base=REALLOC(*d_base,(*numelem+1)*sizeof(DATASET));
    }
    if (*d_base==NULL) return FALSE;
    for (count=*numelem;count>offset;count--) {
        memcpy((*d_base)+count,(*d_base)+count-1,sizeof(DATASET));
    }
    memcpy((*d_base)+offset,new_d,sizeof(DATASET));
    (*numelem)++;
    return TRUE;
}
//============================================================================
//F inst_database
//S insert a DATABASE structure
//D insert a DATABASE structure to an array of structures
//P the pointer to the base DATABASE structure
//P the number of elements in the base DATABASE structure array
//P the new DATABASE structure to insert
//P the insertion offset
//R TRUE if the new structure inserted, otherwise FALSE
BOOL inst_database(DATABASE **d_base,UINT *numelem,DATABASE *new_d,UINT offset)
{
    COUNTER count;
    if ((d_base==NULL)||(new_d==NULL)||(offset>=*numelem)) return FALSE;
    if (*d_base==NULL) {
        *d_base=MALLOC(sizeof(DATABASE));
    } else {
        *d_base=REALLOC(*d_base,(*numelem+1)*sizeof(DATABASE));
    }
    if (*d_base==NULL) return FALSE;
    for (count=*numelem;count>offset;count--) {
        memcpy((*d_base)+count,(*d_base)+count-1,sizeof(DATABASE));
    }
    memcpy((*d_base)+offset,new_d,sizeof(DATABASE));
    (*numelem)++;
    return TRUE;
}
//============================================================================
//F delt_column
//S delete a COLUMN structure
//D delete a COLUMN structure from an array of structures
//P the base COLUMN structure
//P the number of elements in the base COLUMN structure array
//P the deletion offset
//R TRUE if the new structure deleted, otherwise FALSE
BOOL delt_column(COLUMN **c_base,UINT *numelem,UINT offset)
{
    COUNTER count;
    if ((c_base==NULL)||(offset>=*numelem)) return FALSE;
    if (*c_base==NULL) return FALSE;
    free_column((*c_base)+offset);
    for (count=offset;count<((*numelem)-1);count++) {
        memcpy((*c_base)+count,(*c_base)+count+1,sizeof(COLUMN));
    }
    if (*numelem==1) {
        FREE(*c_base);
        *c_base=NULL;
    }
    (*numelem)--;
    return TRUE;
}
//============================================================================
//F delt_index
//S delete an INDEX structure
//D delete an INDEX structure from an array of structures
//P the base INDEX structure
//P the number of elements in the base INDEX structure array
//P the deletion offset
//R TRUE if the new structure deleted, otherwise FALSE
BOOL delt_index(INDEX **i_base,UINT *numelem,UINT offset)
{
    COUNTER count;
    if ((i_base==NULL)||(offset>=*numelem)) return FALSE;
    if (*i_base==NULL) return FALSE;
    free_index((*i_base)+offset);
    for (count=offset;count<((*numelem)-1);count++) {
        memcpy((*i_base)+count,(*i_base)+count+1,sizeof(INDEX));
    }
    if (*numelem==1) {
        FREE(*i_base);
        *i_base=NULL;
    }
    (*numelem)--;
    return TRUE;
}
//============================================================================
//F delt_dataset
//S delete a DATASET structure
//D delete a DATASET structure from an array of structures
//P the base DATASET structure
//P the number of elements in the base DATASET structure array
//P the deletion offset
//R TRUE if the new structure deleted, otherwise FALSE
BOOL delt_dataset(DATASET **d_base,UINT *numelem,UINT offset)
{
    COUNTER count;
    if ((d_base==NULL)||(offset>=*numelem)) return FALSE;
    if (*d_base==NULL) return FALSE;
    free_dataset((*d_base)+offset);
    for (count=offset;count<((*numelem)-1);count++) {
        memcpy((*d_base)+count,(*d_base)+count+1,sizeof(DATASET));
    }
    if (*numelem==1) {
        FREE(*d_base);
        *d_base=NULL;
    }
    (*numelem)--;
    return TRUE;
}
//============================================================================
//F delt_database
//S delete a DATABASE structure
//D delete a DATABASE structure from an array of structures
//P the base DATABASE structure
//P the number of elements in the base DATABASE structure array
//P the deletion offset
//R TRUE if the new structure deleted, otherwise FALSE
BOOL delt_database(DATABASE **d_base,UINT *numelem,UINT offset)
{
    COUNTER count;
    if ((d_base==NULL)||(offset>=*numelem)) return FALSE;
    if (*d_base==NULL) return FALSE;
    free_database((*d_base)+offset);
    for (count=offset;count<((*numelem)-1);count++) {
        memcpy((*d_base)+count,(*d_base)+count+1,sizeof(DATABASE));
    }
    if (*numelem==1) {
        FREE(*d_base);
        *d_base=NULL;
    }
    (*numelem)--;
    return TRUE;
}
//============================================================================
//F new_column
//S creat a new COLUMN structure
//D creat a new COLUMN structure
//P the column name
//P the column version
//P the base version in which this column resides
//P the column type
//P the column data type
//P the column size
//P description of this column
//P comment for this version-base
//R the new structure or NULL on error
COLUMN *new_column(SPTR new_name,SPTR new_version,SPTR new_inbase,SPTR new_type,SPTR new_datatype,SPTR new_size,SPTR new_descript,SPTR new_comment)
{
    static COLUMN *ret_cs;
    ret_cs=MALLOC(sizeof(COLUMN));
    if (ret_cs!=NULL) {
        if ((ret_cs->name=STRDUP(new_name))==NULL) return(NULL);
        if ((ret_cs->version=STRDUP(new_version))==NULL) return(NULL);
        if ((ret_cs->inbase=STRDUP(new_inbase))==NULL) return(NULL);
        if ((ret_cs->type=STRDUP(new_type))==NULL) return(NULL);
        if ((ret_cs->datatype=STRDUP(new_datatype))==NULL) return(NULL);
        if ((ret_cs->size=STRDUP(new_size))==NULL) return(NULL);
        if ((ret_cs->descript=STRDUP(new_descript))==NULL) return(NULL);
        if ((ret_cs->comment=STRDUP(new_comment))==NULL) return(NULL);
    }
    return ret_cs;
}
//============================================================================
//F new_index
//S creat a new INDEX structure
//D creat a new INDEX structure
//P the index name
//P the index version
//P the base version in which this index resides
//P the number of columns in the index
//P the column names in the index
//P description of this index
//P comment for this version-base
//R the new structure or NULL on error
INDEX *new_index(SPTR new_name,SPTR new_version,SPTR new_inbase,UINT new_numcol,SPTR new_colname,SPTR new_descript,SPTR new_comment)
{
    static INDEX *ret_is;
    ret_is=MALLOC(sizeof(INDEX));
    if (ret_is!=NULL) {
        if ((ret_is->name=STRDUP(new_name))==NULL) return(NULL);
        if ((ret_is->version=STRDUP(new_version))==NULL) return(NULL);
        if ((ret_is->inbase=STRDUP(new_inbase))==NULL) return(NULL);
        ret_is->numcol=new_numcol;
        if ((ret_is->colname=STRDUP(new_colname))==NULL) return(NULL);
        if ((ret_is->descript=STRDUP(new_descript))==NULL) return(NULL);
        if ((ret_is->comment=STRDUP(new_comment))==NULL) return(NULL);
    }
    return ret_is;
}
//============================================================================
//F new_dataset
//S creat a new DATASET structure
//D creat a new DATASET structure
//P the dataset name
//P the dataset version
//P the base version in which this dataset resides
//P TRUE if dataset is currently active
//P the number of columns in the dataset
//P the columns in the dataset
//P the primary index
//P the number of indexes
//P the indexs in this dataset (one is the primary)
//P description of this dataset
//P comment for this version-base
//R the new structure or NULL on error
DATASET *new_dataset(SPTR new_name,SPTR new_version,SPTR new_inbase,BOOL new_active,UINT new_numcol,COLUMNPTR new_column,INDEXPTR new_primidx,UINT new_numidx,INDEXPTR new_index,SPTR new_descript,SPTR new_comment)
{
    static DATASET *ret_ds;
    ret_ds=MALLOC(sizeof(DATASET));
    if (ret_ds!=NULL) {
        if ((ret_ds->name=STRDUP(new_name))==NULL) return(NULL);
        if ((ret_ds->version=STRDUP(new_version))==NULL) return(NULL);
        if ((ret_ds->inbase=STRDUP(new_inbase))==NULL) return(NULL);
        ret_ds->active=new_active;
        ret_ds->numcol=new_numcol;
        ret_ds->column=new_column;
        ret_ds->primidx=new_primidx;
        ret_ds->numidx=new_numidx;
        ret_ds->index=new_index;
        if ((ret_ds->descript=STRDUP(new_descript))==NULL) return(NULL);
        if ((ret_ds->comment=STRDUP(new_comment))==NULL) return(NULL);
    }
    return ret_ds;
}
//============================================================================
//F new_database
//S creat a new DATABASE structure
//D creat a new DATABASE structure
//P the database name
//P the database password
//P the current database version
//P the current database base version
//P the number of datasets in the database
//P the datasets in the database
//P description of this database
//R the new structure or NULL on error
DATABASE *new_database(SPTR new_name,SPTR new_password,SPTR new_currver,SPTR new_currbase,UINT new_numdataset,DATASETPTR new_dataset,SPTR new_descript)
{
    static DATABASE *ret_ds;
    ret_ds=MALLOC(sizeof(DATABASE));
    if (ret_ds!=NULL) {
        if ((ret_ds->name=STRDUP(new_name))==NULL) return(NULL);
        if ((ret_ds->password=STRDUP(new_password))==NULL) return(NULL);
        if ((ret_ds->currver=STRDUP(new_currver))==NULL) return(NULL);
        if ((ret_ds->currbase=STRDUP(new_currbase))==NULL) return(NULL);
        ret_ds->numdataset=new_numdataset;
        ret_ds->dataset=new_dataset;
        if ((ret_ds->descript=STRDUP(new_descript))==NULL) return(NULL);
    }
    return ret_ds;
}
//============================================================================
//F dataset_column_idx
//S Find a COLUMN in the DATASET structure
//D Find a COLUMN in the DATASET structure using the column name
//P the DATASET structure to search
//P the name element to use as a key
//R the index of the COLUMN structure found or -1 on error
INT dataset_column_idx(DATASET *ds,SPTR name)
{
    COUNTER count;
    for (count=0;count<ds->numcol;count++) {
        if (!strcmp(ds->column[count].name,name)) {
            return count;
        }
    }
    return -1;
}
//============================================================================
//F dataset_column
//S Find a COLUMN in the DATASET structure
//D Find a COLUMN in the DATASET structure using the column name
//P the DATASET structure to search
//P the name element to use as a key
//R a pointer to the COLUMN structure found or NULL on error
COLUMNPTR dataset_column(DATASET *ds,SPTR name)
{
    COUNTER count;
    count=dataset_column_idx(ds,name);
    if (count!=(-1)) {
        return (ds->column)+count;
    }
    return NULL;
}
//============================================================================
//F dataset_index_idx
//S Find an INDEX in the DATASET structure
//D Find an INDEX in the DATASET structure using the index name
//P the DATASET structure to search
//P the name element to use as a key
//R the index of the INDEX structure found or -1 on error
INT dataset_index_idx(DATASET *ds,SPTR name)
{
    COUNTER count;
    for (count=0;count<ds->numidx;count++) {
        if (!strcmp(ds->index[count].name,name)) {
            return count;
        }
    }
    return -1;
}
//============================================================================
//F dataset_index
//S Find an INDEX in the DATASET structure
//D Find an INDEX in the DATASET structure using the index name
//P the DATASET structure to search
//P the name element to use as a key
//R a pointer to the INDEX structure found or NULL on error
INDEXPTR dataset_index(DATASET *ds,SPTR name)
{
    COUNTER count;
    count=dataset_index_idx(ds,name);
    if (count!=(-1)) {
        return (ds->index)+count;
    }
    return NULL;
}
//============================================================================
//F database_dataset_idx
//S Find a DATASET in the DATABASE structure
//D Find a DATASET in the DATABASE structure using the dataset name
//P the DATABASE structure to search
//P the name element to use as a key
//R the index of the DATASET structure found or -1 on error
INT database_dataset_idx(DATABASE *ds,SPTR name)
{
    COUNTER count;
    for (count=0;count<ds->numdataset;count++) {
        if (!strcmp(ds->dataset[count].name,name)) {
            return count;
        }
    }
    return -1;
}
//============================================================================
//F database_dataset
//S Find a DATASET in the DATABASE structure
//D Find a DATASET in the DATABASE structure using the dataset name
//P the DATABASE structure to search
//P the name element to use as a key
//R a pointer to the DATASET structure found or NULL on error
DATASETPTR database_dataset(DATABASE *ds,SPTR name)
{
    COUNTER count;
    count=database_dataset_idx(ds,name);
    if (count!=(-1)) {
        return (ds->dataset)+count;
    }
    return NULL;
}
//============================================================================

int main(void)
{
    INT offset;
    COLUMN *c;
    INDEX *i;
    DATASET *ds;
    DATABASE *db;
    FILE *fp;
    if ((db=new_database("DATABASE1","TEST","1.00a","1.00",0,NULL,"The First Database"))==NULL) {
        printf("error new first database");
        return 0;
    }
    if ((ds=new_dataset("DATASET1","1.00a","1.00",TRUE,0,NULL,NULL,0,NULL,"The First Dataset","Initial Entry"))==NULL) {
        printf("error new first dataset");
        return 0;
    }
    if (!apnd_dataset(&(db->dataset),&(db->numdataset),ds)) {
        printf("error append second col");
        return 0;
    }
    FREE(ds);
    if ((ds=database_dataset(db,"DATASET1"))==NULL) {
        printf("Can't find dataset %s in database %s\n","DATASET1",db->name);
    }
    if ((c=new_column("FIELD1","1.00a","1.00","NOT NULL","VARCHAR","20","The First Field","Initial Entry"))==NULL) {
        printf("error new fisrt col");
        return 0;
    }
    if (!apnd_column(&(ds->column),&(ds->numcol),c)) {
        printf("error append second col");
        return 0;
    }
    FREE(c);
    prnt_database(db,0);
    if ((i=new_index("Index1","1.00a","1.00",2,"FIELD1,FIELD2","The First Index","Initial Entry"))==NULL) {
        printf("error new first index");
        return 0;
    }
    if (!apnd_index(&(ds->index),&(ds->numidx),i)) {
        printf("error append index");
        return 0;
    }
    FREE(i);
    prnt_database(db,0);
    if ((c=new_column("FIELD2","1.00a","1.00"," ","NUMBER","4,1","The Second Field","Initial Entry"))==NULL) {
        printf("error new second col");
        return 0;
    }
    if (!apnd_column(&(ds->column),&(ds->numcol),c)) {
        printf("error append second col");
        return 0;
    }
    FREE(c);
    prnt_database(db,0);
    if ((c=new_column("FIELD0","1.00a","1.00","NOT NULL","NUMBER","2","The Zero Field","Initial Entry"))==NULL) {
        printf("error new zero col");
        return 0;
    }
    if (!inst_column(&(ds->column),&(ds->numcol),c,0)) {
        printf("error insert zero col");
        return 0;
    }
    FREE(c);
    prnt_database(db,0);
    if ((fp=fopen("TESTDST.DAT","wb"))!=NULL) {
        if (!save_database(fp,db)) {
            printf("Can't save database\n");
        } else {
            printf("Saved database\n");
        }
        fclose(fp);
    } else {
       printf("Can't open TESTDST.DAT for write\n");
    }
    free_database(db);
    FREE(db);
    if ((fp=fopen("TESTDST.DAT","rb"))!=NULL) {
        db=MALLOC(sizeof(DATABASE));
        if (!load_database(fp,db)) {
            printf("Can't load database\n");
        } else {
            printf("Loaded database\n");
            prnt_database(db,0);
            if ((ds=database_dataset(db,"DATASET1"))==NULL) {
                printf("Can't find dataset %s in database %s\n","DATASET1",db->name);
            }
            delt_index(&(ds->index),&(ds->numidx),dataset_index_idx(ds,"Index1"));
            prnt_database(db,0);
            delt_column(&(ds->column),&(ds->numcol),dataset_column_idx(ds,"FIELD0"));
            prnt_database(db,0);
            delt_column(&(ds->column),&(ds->numcol),dataset_column_idx(ds,"FIELD1"));
            prnt_database(db,0);
            delt_column(&(ds->column),&(ds->numcol),dataset_column_idx(ds,"FIELD2"));
            prnt_database(db,0);
            delt_dataset(&(db->dataset),&(db->numdataset),database_dataset_idx(db,"DATASET1"));
            prnt_database(db,0);
            free_database(db);
        }
        fclose(fp);
        FREE(db);
    } else {
       printf("Can't open TESTDST.DAT for read\n");
    }
    return 1;
}
//============================================================================
//                                END OF FILE                                
//============================================================================
