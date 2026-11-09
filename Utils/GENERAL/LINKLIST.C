//=============================== LINKLIST.C =================================
#define LINKLIST_C

#include "linklist.h"

// #define TESTING_LINKED_LIST

BOOL link_setup(LINK **l,void *e)
{
    if (l==NULL) return FALSE;

    if (*l==NULL) (*l)=MALLOC(sizeof(LINK));

    if ((*l)!=NULL) {
        (*l)->elem=e;
        (*l)->next=NULL;
#ifdef DOUBLELINK
        (*l)->prev=NULL;
#endif
        return TRUE;
    }
    return FALSE;
}
BOOL link_reset(LINK **l,BOOL freeelems)
{
    LINK *last;
    LINK *curr;
    if ((l==NULL)||((*l)==NULL)) return FALSE;
    curr=(*l);
#ifdef DOUBLELINK
    while (curr->prev!=NULL) curr=(LINK *)curr->prev;
#endif
    while (curr!=NULL) {
        last=curr;
        if ((freeelems)&&IALLOCED(curr->elem)) FREE(curr->elem);
        curr=(LINK *)curr->next;
        last->next=NULL;
        last->elem=NULL;
#ifdef DOUBLELINK
        last->prev=NULL;
#endif
        FREE(last);
    }
    free(*l);
    *l=NULL;
    return TRUE;
}
BOOL link_append(LINK *l,void *e)
{
    LINK *new=NULL;
    if (l==NULL) return FALSE;
    if (!link_setup(&new,e)) return FALSE;

    while (l->next!=NULL) l=(LINK *)l->next;
    l->next=new;
#ifdef DOUBLELINK
    new->prev=l;
#endif
    return TRUE;
}
BOOL link_delete(LINK **l,void *e,BOOL freeelem)
{
    LINK *last;
    LINK *curr;
    if ((l==NULL)||(*l==NULL)) return FALSE;

    curr=last=*l;
    while (curr!=NULL) {
        if (curr->elem==e) {
            if ((freeelem)&&IALLOCED(curr->elem)) FREE(curr->elem);
            if (curr==last) {
                if (curr->next!=NULL) {
                    (*l)=curr->next;
#ifdef DOUBLELINK
                    ((LINK *)(curr->next))->prev=NULL;
#endif
                }
                FREE(curr);
            } else {
                last->next=curr->next;    
#ifdef DOUBLELINK
                ((LINK *)(curr->next))->prev=last;
#endif
                FREE(curr);
            }
            return TRUE;
        }
        last=curr;
        curr=curr->next;
    }
    return FALSE;
}
BOOL link_insert(LINK *l,void *e)
{
    LINK *curr=NULL;
    if (l==NULL) return FALSE;
    if (!link_setup(&curr,e)) return FALSE;
    curr->elem=e;
    if (l->next==NULL) {
        l->next=curr;
#ifdef DOUBLELINK
        curr->prev=l;
#endif
    } else {
#ifdef DOUBLELINK
        curr->prev=l;
        ((LINK *)(l->next))->prev=curr;
#endif
        curr->next=l->next;
        l->next=curr;
    }
    return TRUE;
}
LINK *link_getnext(LINK *l)
{
    if (l==NULL) return NULL;
    return (LINK *)l->next;
}
#ifdef DOUBLELINK
LINK *link_getprev(LINK *l)
{
    if (l==NULL) return NULL;
    return (LINK *)l->prev;
}
#endif
void *link_getelem(LINK *l)
{
    if (l==NULL) return NULL;
    return l->elem;
}
BOOL link_setelem(LINK *l,void *e,BOOL freeelem)
{
    if (l==NULL) return FALSE;
    if ((freeelem)&&IALLOCED(l->elem)) FREE(l->elem);
    l->elem=e;
    return TRUE;
}
int link_count(LINK *l)
{
    int count=0;
    if (l==NULL) return count;
#ifdef DOUBLELINK
    while (l->prev!=NULL) l=(LINK *)l->prev;
#endif
    while (l!=NULL) {
        l=(LINK *)l->next;
        count++;
    }
    return count;
}

#ifdef TESTING_LINKED_LIST
int main(int argc,char *argv[])
{
    LINK *a=NULL;
    LINK *b;
    char *str="Hello4";
    BOOL res;
    res=link_setup(&a,str);
    printf("link_setup %s\n",(res?"TRUE":"FALSE"));
    res=link_append(a,"Hello1");
    printf("link_append %s\n",(res?"TRUE":"FALSE"));
    res=link_append(a,"Hello2");
    printf("link_append %s\n",(res?"TRUE":"FALSE"));
    res=link_append(a,"Hello3");
    printf("link_append %s\n",(res?"TRUE":"FALSE"));
    res=link_append(a,str);
    printf("link_append %s\n",(res?"TRUE":"FALSE"));
    res=link_append(a,"Hello5");
    printf("link_append %s\n",(res?"TRUE":"FALSE"));
    res=link_append(a,"Hello6");
    printf("link_append %s\n",(res?"TRUE":"FALSE"));
    b=a;
    while (b!=NULL) {
        if (link_getelem(b)) printf("%s\n",link_getelem(b));
        b=link_getnext(b);
    }
    b=a;
    b=link_getnext(b);
    b=link_getnext(b);
    res=link_append(b,"At End");
    printf("link_append %s\n",(res?"TRUE":"FALSE"));
    res=link_insert(b,"In Middle");
    printf("link_insert %s\n",(res?"TRUE":"FALSE"));
    res=link_delete(&a,str,FALSE);
    printf("link_delete %s\n",(res?"TRUE":"FALSE"));
    res=link_delete(&a,"1234",FALSE);
    printf("link_delete %s\n",(res?"TRUE":"FALSE"));
    b=a;
    printf("Link Count %d\n",link_count(a));
    while (b!=NULL) {
        if (link_getelem(b)) printf("%s\n",link_getelem(b));
        b=link_getnext(b);
    }
    res=link_reset(&a,FALSE);
    printf("link_reset %s\n",(res?"TRUE":"FALSE"));
    printf("Link Count %d\n",link_count(a));
    b=a;
    while (b!=NULL) {
        if (link_getelem(b)) printf("%s\n",link_getelem(b));
        b=link_getnext(b);
    }
	return 0;
}
#endif // TESTING_LINKED_LIST

//===============================END OF FILE=================================
