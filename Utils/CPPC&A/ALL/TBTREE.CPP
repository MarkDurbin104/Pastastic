#include "btree.h"
#include "iostream.h"
#include "iomanip.h"
#include "stdlib.h"
#include "string.h"

#define B_ORDER   7
#define B_KEYSIZE 16
#define BASENAME  "btreetst"

String ErrLead("PAGETEST");

DosErrReporter ErrExit(&ErrLead);
const Signature InputSig = 666999666L;

void TestBtreeFile(void);
void TestPageFile(void);
void ShowThem(const PageKey &str,const DataBlock &bd);

struct NameCity {
    char *name;
    char *city;
    Boolean Allocated;
    ~NameCity();
    NameCity(char *n,char *c);
    NameCity(const DataBlock &db);
    virtual operator DataBlock () const;
};
NameCity::~NameCity()
{
    if (Allocated) {
        delete name;
        delete city;
    }
}
NameCity::NameCity(char *n,char *c)
{
    name=n;
    city=c;
    Allocated=BOOL_FALSE;
}
NameCity::NameCity(const DataBlock &db)
{
    if (db.GetSignature()!=InputSig) {
        cout << "\a\ainvalud input object signature !!!\n";
        exit(EXIT_FAILURE);
    }
    char *buffer=(char *)db.GetBufferPtr();
    name=strdup(buffer);
    buffer+=strlen(name)+1;
    city=strdup(buffer);
    Allocated=BOOL_TRUE;
}
NameCity::operator DataBlock () const
{
    size_t bufsize=strlen(name)+strlen(city)+2;
    char *buffer=new char[bufsize];
    strcpy(buffer,name);
    strcpy(buffer+strlen(name)+1,city);
    DataBlock db(InputSig,bufsize,buffer);
    delete [] buffer;
    return db;
}
int main(void)
{
    TestBtreeFile();
    return 1;
}
void TestBtreeFile(void)
{
    char tmp[10];
    BTreeFile btfile(BASENAME,B_ORDER,B_KEYSIZE);
    Boolean result;
    for (int i=0;i<2000;i++) {
        sprintf(tmp,"Name%04d",i);
        NameCity *nc=new NameCity(tmp, "The Road, London SE1 9HB");
        cout << i << ' ';
        result=btfile.Write(PageKey(B_KEYSIZE,nc->name),*nc);
        delete nc;
        if (result==BOOL_FALSE) {
            cout << " \a\aError!";
            exit(EXIT_FAILURE);
        }
    }
    cout << "Done!" << endl;
    btfile.InOrder(ShowThem);
//    PageKey pk(B_KEYSIZE,"Mark0");
//    DataBlock db=btfile.Read(pk);
//    NameCity nc(db);
//    cout << "found " << nc.name << " at " << nc.city << endl;
}
void ShowThem(const PageKey &str,const DataBlock &db)
{
    NameCity nc(db);
    cout << "key " << setw(B_KEYSIZE) << str
         << " Name " << nc.name << " at "
         << nc.city << endl;
}

