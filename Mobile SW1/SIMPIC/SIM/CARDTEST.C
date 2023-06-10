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
** Filename: cardtest.c
** Description:
**   prints out the reader version string, the atr and reader status.
*/

#include"amc151.h"

int main(int argc, char *argv[]) {
    int sp,status,i,len;
    struct termios tios;
    uchar buffer[100];

    sp=open(argv[1]?argv[1]:"/dev/amc151",O_RDWR);
    if(sp<0) {
        printf("Unable to open serial port.\n");
        return 1;
    }

    init_port(sp,&tios);

    if(amc151_warm_reset(sp)<0) {
        printf("Warm reset failed\n");
        return 1;
    }

    printf("Reader version string: %s\n",amc151_version(sp));

    len=amc151_icc_power_on(sp,buffer,sizeof buffer);
    amc151_green_led(sp,1);
    printf("ATR: ");
    for(i=0; i<len; i++)
        printf("%02X ",buffer[i]);
    printf("\n");

    status=amc151_reader_status(sp);
    amc151_print_status(status);

    amc151_green_led(sp,0);
    if(amc151_icc_power_off(sp)<0)
        printf("Power off failed.\n");
    else
        printf("Power off OK.\n");
    close(sp);
}

