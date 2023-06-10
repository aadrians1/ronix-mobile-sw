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

#include "amc151.h"

typedef struct buffer_s {
    int length;
    int maxlength;
    unsigned char *cont;
} buffer;

#define MSG(command,cla,ins,p1,p2,p3) \
    (command)[0]=(cla); \
    (command)[1]=(ins); \
    (command)[2]=(p1); \
    (command)[3]=(p2); \
    (command)[4]=(p3);

/*
** returns the length of the sim response or -1 on error
*/

int sim_status(int sp,uchar *status, int status_len) {
    uchar command[5];

    MSG(command,0xa0,0xf2,0x00,0x00,0x00); /* STATUS */

    amc151_send_data(sp,command,5,status,status_len);

    if(status[0]==0x9f) {
        MSG(command,0xa0,0xc0,0x00,0x00,status[1]); /* GET RESPONSE */
        return amc151_recv_data(sp,command,5,status,status_len);
    }
    return -1;
}

/*
** sim_select():  Selects a file on the SIM to be manipulated by
**                read and update commands.
**
** inputs:    sp          A file handle to a comms device with 
**                        a reader connected to it.
**
**            fileid      The id number of the file to be selected
**                        as defined by GSM 11.11
**
**            status      Buffer for the response from the SIM
**
**            status_len  The size of the response buffer
**
** Returns:   The number of bytes written into the status buffer
**            or -1 on error.
**
** returns the length of the sim response or -1 on error
*/

int sim_select(int sp,int fileid,uchar *status, int status_len) {
    uchar command[7];

    MSG(command,0xa0,0xa4,0x00,0x00,0x02); /* SELECT */
    command[5]=(fileid&0xff00)>>8;
    command[6]=(fileid&0x00ff);

    amc151_send_data(sp,command,7,status,status_len);

    if(status[0]==0x9f) {
        MSG(command,0xa0,0xc0,0x00,0x00,status[1]); /* GET RESPONSE */
        return amc151_recv_data(sp,command,5,status,status_len);
    }
    return -1;
}

int sim_read_binary(int sp, uchar *x, int offset, int len) {
    uchar command[5];
    int outlen,status;

    MSG(command,0xa0, 0xb0, (offset&0xff00)>>8, offset&0xff,len&0xff);
    outlen=amc151_recv_data(sp,command,5,x,len);
    status=x[outlen-2]*0x100+x[outlen-1];
    return outlen-2;
}

/*
** sim_verify_chv(): this function presents the SIM its pin or pin unlock code
** inputs :
**    sp      handle of serial port with reader connected to it
**    result  buffer in which to store the output.
**    reslen  maximium number of characters to put in result buffer
**    chv_no  2 = PIN, 4 = PUK
**    chv     the secret code to be presented to the SIM (in ascii)
** output :
**    the number of characters written to the result buffer
*/

int sim_verify_chv(int sp, uchar *result, int reslen, int chv_no, uchar *chv) {
    uchar command[13];
    int outlen;

    MSG(command,0xa0,0x20,0x00,chv_no&0xff,8);
    memcpy(&command[5],chv,8);
    outlen=amc151_send_data(sp,command,13,result,reslen);
    return (outlen>1)?outlen:-1;
}

int sim_read_record(int sp, uchar *x, int recno, int mode, int len) {
    uchar command[5];
    int outlen,status;

    MSG(command,0xa0,0xb2,recno&0xff,mode,len);
    outlen=amc151_recv_data(sp,command,5,x,len);
    status=x[outlen-2]*0x100+x[outlen-1];
    return outlen-2;
}

int sim_run_algorithm(int sp, uchar *rand, uchar *response) {
    uchar command[21],status[100];
    int len;

    MSG(command,0xa0,0x88,0x00,0x00,0x10);
    memcpy(&command[5],rand,16);
    len = amc151_send_data(sp,command,21,status,sizeof status);

    if((len>1)&&(status[0]==0x9f)) {
        MSG(command,0xa0,0xc0,0x00,0x00,status[1]); /* GET RESPONSE */
        return amc151_recv_data(sp,command,5,response,20);
    }
    return -1;
}

