/*

    xtide.c
 
    version     description
    --------------------------------------------------------------
    0.00.01     initial release
 
    Copyright (c) 1997 Scott A. Christensen
    All Rights Reserved
 
    Email:   scottchristensen@hotmail.com
    Smail:   19009 Preston Road, Suite 215-233, Dallas, TX 75252
 
    This file is part of the XTIDE project.
 
    XTIDE is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version
    2, or (at your option) any later version.
 
    XTIDE is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
    the GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public
    License along with XTIDE; see the file COPYING.  If not,
    write to the Free Software Foundation, 675 Mass Ave,
    Cambridge, MA 02139, USA.


                           +----------------------------+
     XT BUS         U1     |     U2             U3      |     IDE
    --------      -------  |   -------        -------   |   ---------
    | D0-D7|<---->|A   B|<-+-->|D   Q|<-+---->|D   Q|<--+-->|D0-D7  |
    |  *IOR|----->|DIR  |   2->|*OC  |  |  4->|*OC  |       |       |
    |      |   1->|*G   |   3->|C    |  |  5->|C    |       |       |
    |      |      -------      -------  |     -------       |       |
    |      |                    |\ |    +------------------>|D8-D15 |
    |      |    VCC---/\/\/\/---| >|----------------------->|*DASP  |
    |      |          151 OHM   |/ |            U4          |       |
    |      |                    LED           -------       |       |
    |      |                               6->|1D 1Q|------>|*CS3FX |
    |      |                               7->|2D 2Q|------>|*CS1FX |
    |    A2|--------------------------------->|3D 3Q|------>|A2     |
    |    A0|--------------------------------->|4D 4Q|------>|A0     |
    |    A1|--------------------------------->|5D 5Q|------>|A1     |
    |  *IOR|--------------------------------->|6D 6Q|------>|*IOR   |
    |  *IOW|--------------------------------->|7D 7Q|------>|*IOW   |
    |      |       U5:B     +---------------->|8D 8Q|------>|*RESET |
    |      |        |\      |            GND->|*OC  |       |       |
    |RESDRV|--------| >O----+            VCC->|C    |       |       |
    |      |        |/                        -------       |       |
    |  IRQ5|<-----------------------------------------------|INTRQ  |
    |      |                  U6                            ---------
    |      |                --------
    |   AEN|--------------->|*G    |    +-->1         U5:A     U8:A
    | A4-A9|--------------->|P0-P5 |    |              |\     ------
    |      |           GND->|P6    |    |         +----| >O---|    |
    |      |           GND->|P7    |    |         |    |/     | OR |-->6
    |      |   GND->8DIPSW->|Q0-Q7 |    +---------|-----------|    |
    |      |                |      |    |         |           ------
    |      |                |  *P=Q|----+         |            U8:B
    |      |                --------    |         |           ------
    |    A3|----------------------------|---------+-----------|    |
    |      |                            |                     | OR |-->7
    |      |                            +---------------------|    |
    |      |                            |        U7           ------
    |      |                            |    ----------    U5:C
    |  *IOW|----------------------------|--->|A       |     |\
    |  *IOR|----------------------------|--->|B     Y1|-----| >O------>5
    |    A3|----------------------------|--->|C       |     |/
    |      |                            |    |      Y2|--------------->2
    |      |     U8:C                   |    |      Y5|--------------->4
    |      |    ------  U5:E   +--------|--->|G1      |    U5:D
    |    A2|--->|    |   |\    |        +--->|*G2A    |     |\
    |      |    | OR |---| >O--+    +------->|*G2B  Y6|-----| >O------>3
    |    A1|--->|    |   |/         |        ----------     |/
    |      |    ------              |
    |    A0|------------------------+
    |      |
    --------

    IDE CONNECTOR                        ICs Used
    -------------------------            ------------------
     1   *RESET       2   GND            U1           74245
     3   D7           4   D8             U2, U3, U4   74573
     5   D6           6   D9             U5           7404
     7   D5           8   D10            U6           74520
     9   D4          10   D11            U7           74138
    11   D3          12   D12            U8           7432
    13   D2          14   D13
    15   D1          16   D14
    17   D0          18   D15            10K PULLDOWN:   3, 21, 27
    19   GND         20   (keypin)       10K PULLUP:     28
    21   DMARQ       22   GND            NO CONNECTION:  20, 29, 32, 34
    23   *IOW        24   GND
    25   *IOR        26   GND
    27   IORDY       28   CSEL
    29   DMACK       30   GND
    31   INTRQ       32   IOCS16
    33   A1          34   PDIAG
    35   A0          36   A2
    37   *CS1FX      38   *CS3FX
    39   *DASP       40   GND

*/

#include <conio.h>
#include <stdio.h>
#include <dos.h>
#include <bios.h>
#include <time.h>


/*--------------------------------------------------------------*/
#define CS1FX           0x300
#define CS3FX           0x308
#define VECTOR          0x0D
#define MASKREG         0x21
#define EOIREG          0x20
#define EOI             0x20


/*--------------------------------------------------------------*/
typedef struct
{
    unsigned int  config;
    unsigned int  cylinders;
    unsigned int  reserved1;
    unsigned int  heads;
    unsigned int  bytesPerTrack; 
    unsigned int  bytesPerSector; 
    unsigned int  sectorsPerTrack; 
    unsigned int  vendor1 [ 3 ];
    unsigned int  serialNumber [ 10 ];
    unsigned int  bufferType;
    unsigned int  bufferSize;
    unsigned int  ECCbytes;
    unsigned int  firmwareRev [ 4 ];
    unsigned int  modelNumber [ 20 ];
    unsigned int  vendor2_and_sectorsPerInterrupt;
    unsigned int  doubleWordFlag;
    unsigned int  capabilities;
    unsigned int  reserved2;
    unsigned int  PIOmode_and_vendor3;
    unsigned int  DMAmode_and_vendor4;
    unsigned int  nextFourFieldsAreValidFlag;
    unsigned int  currentCylinders;
    unsigned int  currentHeads;
    unsigned int  currentSectorsPerTrack;
    unsigned int  currentCapacityInSectors [ 2 ];
    unsigned int  multipleSectorInfo;
    unsigned int  numberOfUserAddressableSectors [ 2 ];
    unsigned int  singleDMAmode;
    unsigned int  multiDMAmode;
    unsigned int  reserved3 [ 64 ];
    unsigned int  vendor5 [ 32 ];
    unsigned int  reserved4 [ 96 ];
} EC_DATA, *PEC_DATA;


/*--------------------------------------------------------------*/
void                    ( far interrupt *oldISR ) ( void );
int                     stat;
int                     hdint = 0;
EC_DATA                 ecData;
char                    buf1 [ 512 ];
char                    buf2 [ 512 ];


/*--------------------------------------------------------------*/
void far interrupt      hdISR ( void );
void                    readSector ( void * );
void                    writeSector ( void * );
void                    dumpInfo ( void * );
char *                  getStr ( void *, int, char * );


/*--------------------------------------------------------------*/
void main ( )
{
  int             i;

  /* install interrupt & unmask */
  oldISR = getvect ( VECTOR );
  setvect ( VECTOR, hdISR );
  outportb ( MASKREG, ( inportb ( MASKREG ) & 0xDF ) );  /* unmask IRQ 5 */

  /* reset */
  outportb ( CS3FX + 6, 4 );
  delay ( 1 );
  outportb ( CS3FX + 6, 0 );
  delay ( 200 );
  hdint = 0;
  puts ( "...reset" );

  /* recal */
  while ( ( inportb ( CS1FX + 7 ) & 0x80 ) );        /* loop until not busy */
  outportb ( CS1FX + 1, 0x00 );
  outportb ( CS1FX + 2, 0x00 );                      /* number of sectors */
  outportb ( CS1FX + 3, 0x00 );                      /* start sector */
  outportb ( CS1FX + 4, 0x00 );                      /* start track lo */
  outportb ( CS1FX + 5, 0x00 );                      /* start track hi */
  outportb ( CS1FX + 6, 0xA0 );                      /* head & drive */
  outportb ( CS1FX + 7, 0x10 );                      /* recal command */
  while ( !hdint );                                  /* wait for int */
  hdint--;
  if ( stat & 1 )
    puts ( "-->recal failed" );
  else
    puts ( "...recal" );

  /* identify drive */
  while ( ( inportb ( CS1FX + 7 ) & 0x80 ) );        /* loop until not busy */
  outportb ( CS1FX + 1, 0x00 );
  outportb ( CS1FX + 2, 0x01 );                      /* number of sectors */
  outportb ( CS1FX + 3, 0x01 );                      /* start sector */
  outportb ( CS1FX + 4, 0x00 );                      /* start track lo */
  outportb ( CS1FX + 5, 0x00 );                      /* start track hi */
  outportb ( CS1FX + 6, 0xA0 );                      /* head & drive */
  outportb ( CS1FX + 7, 0xEC );                      /* id drive command */
  while ( !hdint );                                  /* wait for int */
  hdint--;
  if ( stat & 1 )
    puts ( "-->identify drive failed" );
  else
  {
    puts ( "...identify drive" );
    readSector ( &ecData );
    dumpInfo ( &ecData );
  }

  /* set parameters */
  while ( ( inportb ( CS1FX + 7 ) & 0x80 ) );        /* loop until not busy */
  outportb ( CS1FX + 1, 0x00 );
  outportb ( CS1FX + 2, ecData.sectorsPerTrack );    /* number of sectors */
  outportb ( CS1FX + 3, 0x00 );                      /* start sector */
  outportb ( CS1FX + 4, 0x00 );                      /* start track lo */
  outportb ( CS1FX + 5, 0x00 );                      /* start track hi */
  outportb ( CS1FX + 6, (ecData.heads - 1) | 0xA0 ); /* head & drive */
  outportb ( CS1FX + 7, 0x91 );                      /* set parms command */
  while ( !hdint );                                  /* wait for int */
  hdint--;
  if ( stat & 1 )
    puts ( "-->set parameters failed" );
  else
    puts ( "...set parameters" );

  for ( i = 0; i < 512; i++ )
    buf1 [ i ] = i % 61;

  /* write sector */
  while ( ( inportb ( CS1FX + 7 ) & 0x80 ) );        /* loop until not busy */
  outportb ( CS1FX + 1, 0x00 );
  outportb ( CS1FX + 2, 0x01 );                      /* number of sectors */
  outportb ( CS1FX + 3, 0x02 );                      /* start sector */
  outportb ( CS1FX + 4, 0x00 );                      /* start track lo */
  outportb ( CS1FX + 5, 0x00 );                      /* start track hi */
  outportb ( CS1FX + 6, 0xA0 );                      /* head & drive */
  outportb ( CS1FX + 7, 0x30 );                      /* write command */
  while ( ( inportb ( CS1FX + 7 ) & 0x80 ) );        /* loop until not busy */
  writeSector ( buf1 );
  while ( !hdint );                                  /* wait for int */
  hdint--;
  if ( stat & 1 )
    puts ( "-->write sector failed" );
  else
    puts ( "...write" );

  /* read sector */
  while ( ( inportb ( CS1FX + 7 ) & 0x80 ) );        /* loop until not busy */
  outportb ( CS1FX + 1, 0x00 );
  outportb ( CS1FX + 2, 0x01 );                      /* number of sectors */
  outportb ( CS1FX + 3, 0x02 );                      /* start sector */
  outportb ( CS1FX + 4, 0x00 );                      /* start track lo */
  outportb ( CS1FX + 5, 0x00 );                      /* start track hi */
  outportb ( CS1FX + 6, 0xA0 );                      /* head & drive */
  outportb ( CS1FX + 7, 0x20 );                      /* read command */
  while ( !hdint );                                  /* wait for int */
  hdint--;
  if ( stat & 1 )
    puts ( "-->read sector failed" );
  else
  {
    puts ( "...read" );
    readSector ( buf2 );
  }

  if ( memcmp ( buf1, buf2, 512 ) )
    puts ( "-->memcmp failed" );
  else
    puts ( "...memcmp" );

  /* mask & uninstall interrupt */
  outportb ( MASKREG, ( inportb ( MASKREG ) | 0x20 ) );  /* mask IRQ 5 */
  setvect ( VECTOR, oldISR );
}


/*--------------------------------------------------------------*/
void far interrupt hdISR ( )
{

  stat = inportb ( CS1FX + 7 );

  hdint++;

  outportb ( EOIREG, EOI );
}


/*--------------------------------------------------------------*/
void readSector ( void *x )
{
  int             i;
  char *          sector = x;

  for ( i = 0; i < 256; i++ )
  {
    *sector++ = inportb ( CS1FX );  /* read lo & trigger hi latch */
    *sector++ = inportb ( CS3FX );  /* now get contents of latch  */
  }
}


/*--------------------------------------------------------------*/
void writeSector ( void *x )
{
  int             i;
  char *          sector = x;

  for ( i = 0; i < 256; i++ )
  {
    outportb ( CS3FX, *( sector + 1 ) );  /* write hi byte to latch */
    outportb ( CS1FX, *sector++ );        /* write lo byte & trigger hi */
    sector++;
  }
}


/*--------------------------------------------------------------*/
void dumpInfo ( void *x )
{
  PEC_DATA     p = (PEC_DATA) x;
  char         buf [ 80 ];

  puts ( "" );
  printf ( "Drive Model_____: %s\n", getStr ( p->modelNumber, 20, buf ) );
  printf ( "Cylinders_______: %6u\n", p->cylinders );
  printf ( "Heads___________: %6u\n", p->heads );
  printf ( "Sectors/Track___: %6u\n\n", p->sectorsPerTrack );
}


/*--------------------------------------------------------------*/
char *getStr (
     void *       wdata,
     int          words,
     char *       buf
     )
{
  char *          p = buf;
  char *          data = wdata;

  while ( words-- )
  {
    *p++ = *( data + 1 );
    *p++ = *data++;
    data++;
  }

  *p = 0;

  return buf;
}

