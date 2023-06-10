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
** Filename: amc151.c
** Description:
**  Code specific to the AMC151 reader.
*/

#include<stdio.h>
#include<sys/stat.h>
#include<sys/types.h>
#include<fcntl.h>
#include<unistd.h>
#include<termios.h>
#include<signal.h>
#include<setjmp.h>

#include "amc151.h"

/************* SUPPORT FUNCTIONS **************/

int init_port(int sp,struct termios *tios) {
    tcgetattr(sp,tios);
    tios->c_iflag=0;
    tios->c_oflag=0;
    tios->c_cflag=CS8|CREAD|CLOCAL;
    /* tios->c_cflag=CS8|CREAD|CLOCAL|CSTOPB; */
    tios->c_lflag=0;
    cfsetospeed(tios,B9600);
    
    tcsetattr(sp,TCSANOW,tios);
    tcflush(sp,TCIOFLUSH);
}

/* print the numbers in a buffer to the screen */
void writehex(uchar *buf,int len) {
    int i;

    for(i=0; i<len; i++)
        printf("%02X ",buf[i]);
}

/* calculate the block checksum of a buffer */
uchar calc_bcc(uchar *buf, int len) {
    int i;
    uchar bcc=0;

    for(i=0; i<len; i++)
        bcc^=buf[i];
    return bcc;
}

/*********** PROTOCOL 2/USI MESSAGE SEND AND RECEIVE FUNCTIONS *************/

int protocol_error=0;

int amc151_send_usi_mesg(int sp,uchar *mes, int len) {
    int i,bcc;
    uchar buffer[200];

    if((len>sizeof buffer)||(len>0xffff)) {
        printf("send_amc151_mesg(): Message too long.\n");
        return -1;
    }

    /* assemble the message */
    buffer[0]=SOH;                        /* SOH */
    buffer[1]=0x00;                       /* ADDRESS */
    buffer[2]=(len>>8)&0xff;              /* COUNTH */
    buffer[3]=len&0xff;                   /* COUNTL */
    memcpy(&buffer[4],mes,len);           /* MESSAGE */
    buffer[len+4]=calc_bcc(buffer,len+4); /* BCC */

#ifdef DEBUG
    printf("Sending: "); writehex(buffer,len+5); printf("\n");
#endif

    /*
    ** Flush buffers (get rid of writes)
    ** then wait for the timeout period
    ** Flush buffers (get rid of bytes sent by reader)
    */
    tcflush(sp,TCIOFLUSH);
    if(protocol_error) {
        usleep(P2USI_TIMEOUT);
        protocol_error=0;
    }
    tcflush(sp,TCIOFLUSH);
    return write(sp,buffer,len+5);
}

/* receive timeout */
static jmp_buf amc151_env;

static void amc151_timeout(int x) {
    longjmp(amc151_env,1);
}

int amc151_recv_usi_mesg(int sp, uchar *buf, int maxlen) {
    int len,x;

    /* set up a timer to wake ourselves up after a timeout */
    if(setjmp(amc151_env)) {
        printf("recv_amc151_mesg(): timed out!\n");
        return -1;
    }
    signal(SIGALRM,amc151_timeout);
    alarm(AMC151_TIMEOUT);

    /* start reading */
    read(sp,buf,4);
    if(buf[0]!=SOH) {
        printf("recv_amc151_mesg(): bad first char.\n");
        protocol_error=1;
        alarm(0);
        return -1;
    }
    len = buf[2]*0x100 + buf[3];

    /*
    ** need to wait a few times before we will receive all the data 
    ** Check every 10ms if there is some more data
    */
    for(x=0; x<len+1; ) {
        x+=read(sp,&buf[x+4],len+1-x);
        if(x!=(len+1)) {
            usleep(10000L);
        }
    }

    /* cancel the timeout */
    alarm(0);

#ifdef DEBUG
    printf("Received: "); writehex(buf,len+5); printf("\n");
#endif
    if(0!=calc_bcc(buf,len+5)) {
        protocol_error=1;
        printf("Repsonse bcc failed!\n");
        printf("Received: "); writehex(buf,len+5); printf("\n");
    }
    
    memcpy(buf,buf+4,len);
    buf[len]='\0';
    return len;
}

/********* READER COMMANDS - PROTOCOL 2/USI *********/

/*
** Function:  amc151_version()
** Inputs:    sp - file handle of serial device with reader connected
** Output:    pointer to the reader's version string
*/
char *amc151_version(int sp) {
    char command[1];
    static uchar buffer[100];
    int len;

    command[0]=0x39;
    amc151_send_usi_mesg(sp,command,1);
    len = amc151_recv_usi_mesg(sp,buffer,sizeof buffer);
    if(len>0)
        buffer[len]='\0';
    else
        return NULL;

    return buffer;
}

/*
** Function:     amc151_warm_reset()
** Description:  does a warm boot of the reader
** Inputs:       sp - file handle of serial port with reader connected
** Output:       0  if successful
**               -1 if unsuccessful
**/
int amc151_warm_reset(int sp) {
    uchar command[1];
    uchar buffer[100];

    command[0]=0x7f;
    amc151_send_usi_mesg(sp,command,1);
    amc151_recv_usi_mesg(sp,buffer,sizeof buffer);
    if(buffer[0]==0x3a)
        return 0;
    return -1;
}

int amc151_retransmit(int sp) {
    uchar command[1];

    command[0]=0x25;
    return amc151_send_usi_mesg(sp,command,1);
}

/*
** Name:         amc151_icc_power_on()
** Description:  power up the smart card and receive the ATR
** Inputs:       sp - serial port file handle with reader connected
**               buf - buffer for returning the ATR
**               maxlen - maximum length to be written into buf
** Returns:      number of bytes written to buf
*/
int amc151_icc_power_on(int sp, char *buf, int maxlen) {
    uchar command[1];
    int len;

    command[0]=0x4e;
    amc151_send_usi_mesg(sp,command,1);
    len=amc151_recv_usi_mesg(sp,buf,maxlen);
    if(len<2)
        return -1;

    return len;
}

int amc151_icc_power_off(int sp) {
    uchar command[1];
    uchar buffer[100];

    command[0]=0x6e;
    amc151_send_usi_mesg(sp,command,1);
    amc151_recv_usi_mesg(sp,buffer,sizeof buffer);
    if(buffer[0]==ACKNOWLEDGE)
        return 0;
    return -1;
}

/*
** amc151_send_data()
** Send data from the smart card.
** Input:  sp           Serial port AMC151 is connected to
**         data         request string to the ICC
**         len          length of the request string data
**         response     buffer for the ICC response data
**         resp_maxlen  size of response buffer
** Output: -1 if error
**         the number of bytes written into the response buffer
*/
int amc151_send_data(int sp, uchar *data, int len, 
                             uchar *response, int resp_maxlen) {
    uchar command[70];
    uchar buffer[100];
    int resp_len;

    command[0]=0x41;
    amc151_send_usi_mesg(sp,command,1);
    resp_len=amc151_recv_usi_mesg(sp,buffer,sizeof buffer);
    if(buffer[0]!=ACKNOWLEDGE)
        return -1;
    amc151_send_usi_mesg(sp,data,len);
    return amc151_recv_usi_mesg(sp,response,resp_maxlen);
}

/*
** amc151_recv_data()
** Receive data from the smart card.
** Input:  sp           Serial port AMC151 is connected to
**         data         request string to the ICC
**         len          length of the request string data
**         response     buffer for the ICC response data
**         resp_maxlen  size of response buffer
** Output: -1 if error
**         the number of bytes written into the response buffer
*/
int amc151_recv_data(int sp, uchar *data, int len,
                             uchar *response, int resp_maxlen) {
    uchar command[70],buffer[100];
    int resp_len,retries;

    /* request data from the reader */
    command[0]=0x61;
    amc151_send_usi_mesg(sp,command,1);
    resp_len=amc151_recv_usi_mesg(sp,buffer,sizeof buffer);
    if ((resp_len!=1) || (buffer[0]!=ACKNOWLEDGE))
        return -1;

    /* receive data from the reader */
    amc151_send_usi_mesg(sp,data,len);
    resp_len=amc151_recv_usi_mesg(sp,response,resp_maxlen);

    return resp_len;
}

/*
** amc151_green_len()
** Desc:   Turns on/off the green LED on the reader
** Inputs: sp     File handle of the serial port the reader is connected to.
**         power  Boolean value 0 - LED will be turned off, nozero - LED on.
** Output: 0 success
**         1 failure
*/
int amc151_green_led(int sp, int power) {
    uchar command[1];
    uchar buffer[100];

    command[0]=power?0x4c:0x6c;
    amc151_send_usi_mesg(sp,command,1);
    amc151_recv_usi_mesg(sp,buffer,sizeof buffer);
    if(buffer[0]==ACKNOWLEDGE)
        return 0;
    return -1;
}

/*
** amc151_red_len()
** Desc:   Turns on/off the red LED on the reader
** Inputs: sp     File handle of the serial port the reader is connected to.
**         power  Boolean value 0 - LED will be turned off, nozero - LED on.
** Output: 0 success
**         1 failure
*/
int amc151_red_led(int sp, int power) {
    uchar command[1];
    uchar buffer[100];

    command[0]=(power==1)?0x4d:0x6d;
    amc151_send_usi_mesg(sp,command,1);
    amc151_recv_usi_mesg(sp,buffer,sizeof buffer);
    if(buffer[0]==ACKNOWLEDGE)
        return 0;
    return -1;
}

int amc151_reader_status(int sp) {
    uchar command[1];
    uchar buffer[100];

    command[0]=0x24;
    amc151_send_usi_mesg(sp,command,1);
    amc151_recv_usi_mesg(sp,buffer,sizeof buffer);
    return buffer[0]+buffer[1]*0x100;
}

void amc151_print_status(int status) {
    printf("Card seated: %s\n",(status&0x002)?"yes":"no");
    printf("ICC Power:   %s\n",(status&0x008)?"on":"off");
    printf("Green LED:   %s\n",(status&0x100)?"on":"off");
    printf("Red LED:     %s\n",(status&0x400)?"on":"off");
}

