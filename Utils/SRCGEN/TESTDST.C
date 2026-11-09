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
