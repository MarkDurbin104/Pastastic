/* 
MEMTEST2.CPP
bcc286 memtest2.cpp
*/

#include <stdlib.h>
#include <iostream.h>
#include <new.h>
#include <string.h>

class msg {
public:
    msg()   { cout << "hello from " << __FILE__ << "\n" ; }
    ~msg()  { cout << "bye\n" ; }
    } ;

static msg banner;  // test C++ static constructors, destructors

static unsigned long bytes = 0;
static unsigned long allocs = 0;
static unsigned blk_size = 10240;

#ifdef _MSC_VER
#pragma warning(disable:4100)
int new_fail(size_t size)
{
    if (blk_size)
        blk_size >>= 1;  // try to allocate a smaller block
    else
    {   // memory exhausted
        cout << "Allocated " << bytes << " bytes\n" ;
        exit(1);
    }
    return 1;
}
#pragma warning(default:4100)
#else
#define _set_new_handler set_new_handler
void new_fail(void)
{
    if (blk_size)
        blk_size >>= 1;  // try to allocate a smaller block
    else
    {   // memory exhausted
        cout << "Allocated " << bytes << " bytes\n" ;
        exit(1);
    }
}
#endif

void
main(void)
{
    char *p;

    _set_new_handler(new_fail);   // called when new fails

    for (;;)
    {
       p = new char[blk_size];   // allocate memory
       memset(p, 0, blk_size);   // touch every byte
       *p = 'x';                 // do something, anything with
       p[blk_size-1] = 'y';      //   the allocated memory
           
       bytes += blk_size;
       allocs++;
       if ((allocs % 25) == 0)   // odometer
            cout << "Allocated " << bytes << " bytes\r";
    }
}
