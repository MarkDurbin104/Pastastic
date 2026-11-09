#define CMP_BINARY             0
#define CMP_ASCII              1
#define CMP_NO_ERROR           0
#define CMP_INVALID_DICTSIZE   1
#define CMP_INVALID_MODE       2
#define CMP_BAD_DATA           3
#define CMP_ABORT              4

typedef unsigned int  UINT ;
typedef char          CHAR ;
typedef unsigned char UCHAR;
typedef unsigned long ULONG;
typedef UINT (pascal * PKRPTR)(CHAR *,UINT *);
typedef void (pascal * PKWPTR)(CHAR *,UINT *);

extern UINT  pascal implode (PKRPTR rb,PKWPTR wb,CHAR *wkb,UINT *t,UINT *ds);
extern UINT  pascal explode (PKRPTR rb,PKWPTR wb,CHAR *wkb);
extern ULONG pascal crc32   (UCHAR *buffer,UINT *size,ULONG *old_crc);

