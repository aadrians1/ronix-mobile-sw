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
** Filename: phonebook.c
** Description:
**  prints out the phonebook contained on a GSM SIM.
*/

#include <stdio.h>
#include <setjmp.h>
#include <signal.h>
#include "amc151.h"
#include "sim.h"
#include "unblock.h"

void dump_pb_entry(uchar *data, int len) {
    int i=0,ch;

    for(i=0; i<24; i++) {
       ch = (data[len-12+i/2]>>(4*(i%2)))&0x0f;
       if(ch==0x0f)
           printf(" ");
       else
           printf("%X",ch);
    }
    printf(" ");
    for(i=0; (data[i]!=0xff) && (i<(len-14)); i++)
        printf("%c",data[i]);
    printf("\n");
}

void read_phonebook(int sp) {
    uchar result[0x100];
    int len,i,record_length,num_records;

    /* select the main file */
    sim_select(sp,MAINFILE,result,sizeof result);

    /* select the DFtelecom file */
    sim_select(sp,0x7f10,result,sizeof result);

    /* select the EFadn file */
    if(len=sim_select(sp,0x6f3a,result,sizeof result)<0) {
        printf("Select EFadm failed.\n");
        return;
    }
    
    /* figure out how long each record is from the status message */
    record_length=result[14];
    num_records=result[2]*0x100+result[3];
    num_records/=record_length;
    printf("There are %d entries.\n",num_records);

    /* print out the individual records */
    for(i=0; i<num_records; i++) {
        len=sim_read_record(sp,result,0,2,record_length);
        if((len>0)&&(result[0]!=0xff)) {
            printf("%03d: ",i);
            dump_pb_entry(result,len);
        }
    }
}

/* code for catching Control-C and kill signals */
static jmp_buf pb_env;
void catch(int x) {
    longjmp(pb_env,1);
}

/*
** main program:
**  setup
**  unblock the SIM if necessary
**  read the phonebook
**  quit
*/
int main(int argc, char *argv[]) {
    int sp;
    struct termios tios;
    uchar response[100];
    int len;

    sp=open(argv[1]?argv[1]:"/dev/amc151",O_RDWR);
    if(sp<0) {
        printf("Serial port init failed.\n");
        return 1;
    }

    init_port(sp,&tios);

    /* turn off the reader if user breaks from program */
    if(!setjmp(pb_env)) {
        signal(SIGINT,catch);
        signal(SIGQUIT,catch);

        if(amc151_warm_reset(sp)<0)
            printf("Warm reset failed\n");

        amc151_icc_power_on(sp,response,sizeof response);
        amc151_green_led(sp,1);

        unblock_sim(sp);

        /* list_files(sp,fi,sizeof fi/sizeof (fileinfo)); */
        read_phonebook(sp);
    }
    else {
        fprintf(stderr,"Stopped!\n");
    }

    if(0>amc151_green_led(sp,0))
        printf("Green led still on...\n");
    amc151_icc_power_off(sp);
    close(sp);
}

