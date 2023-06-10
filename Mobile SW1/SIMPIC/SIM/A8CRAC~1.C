/* 
** (C) Copyright on the following code is reserved by 
**     Michael J. McCormack 1998
** Postal address:    PO BOX 1542
**                    Lane Cove 2066
**                    Australia
** email address:     McCormack@ozemail.com.au
** You may use, modify and distribute it freely for non commercial 
** purposes only, provided this header is left intact.
**
** Filename: a8cracktest.c
** Date:     22 March 1998
** Description: 
**      Dumps off RAND / SRES / Kc values from a software COMP128 algorithm.
**      Determines the key value kc indirectly, as though it were on a SIM.
**
**      The algorithm used in this code was derived from information
**      supplied by Marc Briceno and Ian Goldberg at URL:
**         http://www.isaac.cs.berkeley.edu/isaac/gsm.html
*/

#include <stdio.h>
#include <sys/time.h>
#include <setjmp.h>
#include <signal.h>
#include <unistd.h>
#include "a3a8.h"

typedef unsigned char uchar;

uchar kc[16]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};

uchar key_mask[16]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
uchar key_val[16];

typedef struct a8pair_s {
    uchar input[16];
    uchar output[12];
} a8pair;

/* 
** print out an a3a8 input/hash value pair 
*/
void printa8pair(const a8pair *x) {
    int i;

    for(i=0; i<sizeof x->input; i++)
        printf("%02X",x->input[i]);
    printf(",");
    for(i=0; i<sizeof x->output; i++)
        printf("%02X",x->output[i]);
    printf("\n");
}

/*
** perform a binary search on existing pairs
*/
int bsrch(uchar *response,a8pair *all, int size) {
    int halfway=size/2,r;

    if(size<=0)
        return 0;
    r=memcmp(response,all[halfway].output,sizeof all[halfway].output);
    if(size==1)
        if(0>=r)
            return 0;
        else
            return 1;
    if(0>=r)
        return bsrch(response,&all[0],halfway);
    else
        return bsrch(response,&all[halfway],size-halfway)+halfway;
}

/*
** add_pair()
** Maintains an array of a3a8 inputs and outputs sorted by output
*/
int add_pair(uchar *rand, uchar *response, a8pair* all, int size) {
    int x,i;

    x=bsrch(response,all,size);
    for(i=size; i>x; i--)
        memcpy(&all[i],&all[i-1],sizeof(a8pair));
    memcpy(&all[x].input,rand,sizeof all[x].input);
    memcpy(&all[x].output,response,sizeof all[x].output);

    if(size && (!memcmp(all[x+1].output,all[x].output,sizeof all[x].output))) {
        printf("Pairs identical!\n");
        printa8pair(&all[x]);
        printa8pair(&all[x+1]);
        return x;
    }
    return -1;
}

void verify_pairs(a8pair *all,int size) {
    int i;

    for(i=0; i<size; i++) {
        /* printa8pair(&all[i]); */
        if((i<size-1)&&
           (0<=memcmp(all[i].output,all[i+1].output,sizeof all[i].output))) {
            printf("Anomoly!\n");
        }
    }
}

/*
** calc_key
** calculates two bytes of the key from a collission
*/
int calc_key(a8pair *x, a8pair *y, int i) {
    int k;
    uchar key[16];
    uchar output1[32], output2[32];

    memset(key,0,sizeof key);
    for(k=0; k<0x10000; k++) {
        key[i]=k&0xff;
        key[i+8]=(k>>8)&0xff;
        A3A8_tworounds(x->input,key,output1);
        A3A8_tworounds(y->input,key,output2);
        if ( (output1[i]==output2[i]) &&
             (output1[i+8]==output2[i+8]) &&
             (output1[i+16]==output2[i+16]) &&
             (output1[i+24]==output2[i+24]) ) {
             return k;
        }
    }
    return -1;
}

/*
** challenges an a3a8 hash function with a chosen plaintext attack
*/
int find_collision(void) {
    uchar rand[28],response[12];
    int i,j,x,k;
    a8pair *all;

    /* allocate a buffer */
    all = (a8pair*)malloc(sizeof(a8pair)*0x10000);
    if(!all) {
        printf("Unable to malloc memory for pairs.\n");
        return 1;
    }

    /* gather data */
    for(i=0; i<8; i++) {
        /* randomise with time of day */
        memset(rand,0x00,sizeof rand);
        gettimeofday((struct timeval *)&rand[0],(struct timezone *)&rand[8]);

        for(j=0; j<0x10000; j++) {
            rand[i+0]=j%0x100;
            rand[i+8]=(j>>8)%0x100;
    
            A3A8(rand,kc,response);

            x=add_pair(rand,response,all,j);
            if(!(j%1000)) {
                fprintf(stderr,".",j);
                verify_pairs(all,j+1);
            }
            if(x>=0)
                break;
        }

        if(x>=0) {
            printf("Found collision.\n");
            k = calc_key(&all[x],&all[x+1],i);
            if(k>=0) {
                key_mask[i]=0xff;
                key_mask[i+8]=0xff;
                key_val[i]=k&0xff;
                key_val[i+8]=(k>>8)&0xff;
                for(j=0; j<sizeof key_val; j++) {
                    if(key_mask[j])
                        printf("%02X",key_val[j]);
                    else
                        printf("XX");
                }
                printf("\n");
            }
            else
                printf("Could not resolve key!\n");
        }
        else {
            printf("Exhausted key space.\n");
        }
    }
    free(all);
    return 0;
}

main(int argc, char *argv[]) {
    find_collision();

    return 0;
}

