/* 
** (C) Copyright on the following code is reserved by 
**     Michael J. McCormack 1998
** Postal address:    PO BOX 1542
**                    Lane Cove 2066
**                    Australia
** email address:     McCormack@ozemail.com.au
** You may use, modify and distribute it freely for non commercial 
** purposes only, provided this header is left intact.
*/

#ifndef __INC_AMC151__
#define __INC_AMC151__

#include<stdio.h>
#include<sys/stat.h>
#include<sys/types.h>
#include<fcntl.h>
#include<unistd.h>
#include<termios.h>

#define SOH 0x01
#define EOT 0x04

/* AMC151 return codes */
#define ACKNOWLEDGE 0x5e
#define ERROR 0x2a
#define COMMS_ERROR 0x3f
#define INVALID_COMMAND 0x21
#define POWER_ON 0x3a

#define AMC151_TIMEOUT 1       /* command timeout in seconds before giving up */
#define P2USI_TIMEOUT 100000   /* Protocol 2/USI Timeout in microseconds */

typedef unsigned char uchar;

int amc151_send_usi_mesg(int sp,uchar *mes, int len);
int amc151_recv_usi_mesg(int sp, uchar *buf, int maxlen);
char *amc151_version(int sp);
int amc151_warm_reset(int sp);
int amc151_icc_power_on(int sp, char *buf, int maxlen);
int amc151_icc_power_off(int sp);
int amc151_send_data(int sp, uchar *data, int len, 
                             uchar *response, int resp_maxlen);
int amc151_recv_data(int sp, uchar *data, int len, 
                             uchar *response, int resp_maxlen);
int amc151_green_led(int sp, int power);
int amc151_red_led(int sp, int power);
int amc151_reader_status(int sp);
void amc151_print_status(int status);

#endif /* __INC_AMC151__ */

