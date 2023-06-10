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
** Filename: unblock.c
** Date:     30 March 1998
** Description: 
**      code to unblock the SIM card, by asking the user to enter the PIN
*/

#include <stdio.h>
#include "amc151.h"
#include "sim.h"

/*
** reads a CHV from the input and codes it into an 8 character string
** to be sent to the SIM. The eight characters are to be at least four 
** ascii digits 0-9 padded by 0xff.
*/
void input_chv(uchar chv[8]) {
    int chvgood=0,i;

    while(!chvgood) {
        chvgood=1;
        memset(chv,0xff,8);
        printf("Enter SIM PIN: ");
        scanf("%8s",chv);
        for(i=0; i<8; i++) {
            if( (!isdigit(chv[i])) || (!chvgood)) {
                if(i<3)
                    chvgood=0;
                chv[i]=0xff;
            }
        }
    }
}

/* 
** Interactively unblock CHV1 of a SIM - requires user to enter the
** SIM pin number.
**
** Caution: entering the wrong pin three times causes the SIM
** to become blocked by CHV2 (the PUK).
*/

int unblock_sim(int sp) {
    uchar response[0x100];
    uchar chv[10];
    int blocked,status,x;

    /* select the main file - find the status */
    sim_select(sp,0x3f00,response,sizeof response);

    /* figure out whether the PIN is needed or not */
    blocked = (response[13]&0x80)?0:1;

    if(!blocked)
        return 1;

    while(blocked) {
        input_chv(chv);
        x=sim_verify_chv(sp,response,sizeof response,0x01,chv);
        status = response[x-2]*0x100 + response[x-1];
        switch(status) {
        case 0x9000: printf("OK.\n"); blocked=0; break;
        case 0x9802: printf("No chv initialised.\n"); break;
        case 0x9804: printf("Authentication failed.\n"); break;
        case 0x9808: printf("Contradiction with CHV status!\n"); break;
        case 0x9810: printf("Contradiction with invalidation status!\n"); break;
        case 0x9840: printf("Blocked!\n"); break;
        case 0x9850: printf("Max attempts exceeded.\n"); break;
        default: printf("Unknown return code.\n"); break;
        }
    }
    return 1;
}

