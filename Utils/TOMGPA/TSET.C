void test(void)
{
    switch (a) {
        case RUNDUMMY   :
            G_runningdummy=1;
            l=popl(); 
            getstr(); 
            strcpy(G_s0,G_s1);
            getstr(); 
            G_depth++;
            varspace=MALLOC(10*sizeof(LONG));
            if (varspace!=NULL) {
                memcpy(varspace,G_vars,10*sizeof(LONG));
                memset(G_vars,0,10*sizeof(LONG));
                k=(INT)l;
                (CHAR *)t=MALLOC(16);
                filespec=MALLOC(16);
                sprintf(filespec,"%s.*",G_store[k].name);
                sprintf((CHAR *)t,"%s.*",G_s0);
                sendmsg("DISK",MESSAGE_D,t,G_database);
                l=snum((CHAR *)G_s0);
                sendmsg("DBM",MESSAGE_qg,(UCHAR)k,(UCHAR)0,G_s2);
                if (sendmsg("DISK",MESSAGE_r,G_database,filespec,G_s0))  {
                    sendmsg("DBM",MESSAGE_qp,(UCHAR)l,(UCHAR)0,G_s2);
                    memcpy(G_sstat[(INT)l].buf,G_sstat[k].buf,G_sstat[(INT)l].len);
                    sendmsg("DBM",MESSAGE_qp,(UCHAR)l,(UCHAR)0,G_s2);           
                    runaction(G_s1);
                    if (!sendmsg("DISK",MESSAGE_r,G_database,t,G_store[k].name)) {
                        printf("Error renaming %s to %s\n",t,G_store[k].name);
                        *G_shutdown=1;       // Force an exit
                    }
                } else {
                    printf("Error renaming %s to %s\n",G_store[k].name,t);
                    *G_shutdown=1;       // Force an exit
                }
                FREE(t);
                FREE(filespec);
                memcpy(G_vars,varspace,10*sizeof(LONG));
                FREE(varspace);
            } else {
                sendmsg("OSSDEV",MESSAGE_s,5000); 
                sendmsg("OSSDEV",MESSAGE_d,200); 
                sendmsg("OSSDEV",MESSAGE_s,1000); 
                sendmsg("OSSDEV",MESSAGE_d,100);
                sendmsg("OSSDEV",MESSAGE_s,5000); 
                sendmsg("OSSDEV",MESSAGE_d,200); 
                sendmsg("OSSDEV",MESSAGE_s,1000); 
                sendmsg("OSSDEV",MESSAGE_d,100);
                sendmsg("OSSDEV",MESSAGE_s,5000); 
                sendmsg("OSSDEV",MESSAGE_d,200); 
                sendmsg("OSSDEV",MESSAGE_s,1000); 
                sendmsg("OSSDEV",MESSAGE_d,100);
                sendmsg("OSSDEV",MESSAGE_ns);
            }
            G_runningdummy=0;
            break;
    }
}
