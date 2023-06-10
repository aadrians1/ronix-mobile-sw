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
** Filename: unblock.h
** Description:
**  Header for unblocking functions.
*/

#include <stdio.h>
#include "amc151.h"
#include "sim.h"

void input_chv(uchar chv[8]);
int unblock_sim(int sp);

