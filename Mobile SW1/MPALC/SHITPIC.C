/*
 * pp.c : A serial mode PIC16C84 programmer
 *
 * Usage:
 *
 *      pp  [ -lxhrwpc238! ]  objfile1  [ objfile2 ]
 *
 * Where objfile1 is the program data in Intel hex format 
 * and the optional objfile2 is EEPROM data in the same format.
 * Various things, including the fuse details, can be set on the 
 * command line using the switches described below.  If no fuse 
 * details are given, the program asks for them before proceeding.  
 * Superfluous command line arguments are silently ignored and later
 * switches take precedence, even if contradictory.  
 *
 * Switches (options) are introduced by - (or /) and are encoded as
 * a sequence of one or more characters from the set {lxhrwpc238!}.
 * Switches can be given individually (like -r /2 -p) or in groups
 * (like -r2p or /rp2 or /2/r/p which are all synonyms).  Switches are 
 * recognized anywhere in the command line (but don't use the DOS-like  
 * pp/r/p/2  form - this should be written  pp /r/p/2;  space around 
 * switch groups is important).
 *
 * There are four logical groups of switches: fuses, ports, hex-types
 * and misc.  They can be mixed freely.
 *
 * Fuses:
 *    o    l, x, h, r  -  LP, XT, HS or RC oscillator (default LP).
 *    o    w           -  enable watchdog timer.
 *    o    p           -  enable power-up timer.
 *    o    c           -  enable code protection.
 * Ports:
 *    o   2, 3         -  hardware on LPT2 or LPT3 (default is LPT1).
 * Hex-types:
 *    o   8            -  objfiles are Intel Hex-8, i.e. INHX8M
 *                        (default is Intel Hex-16, i.e. INHX16) 
 * Misc:
 *    o   !            -  start programming immediately (default is 
 *                        to wait for a key press)
 *
 * E.g., -rp28 means set the fuses to use the RC oscillator, no watchdog, 
 * use power-up timer, and don't protect code; assume the hardware is on 
 * LPT2; and the objfiles are in INHX8M format.
 *
 *
 * Notes/restrictions/bugs: 
 *
 *      o  This program needs external hardware to be attached
 *         to a parallel port (see pp.asc for an ASCII schematic).
 *      o  Don't use from Windows; another program could grab the LPT port.
 *      o  Run pp, pp -2 or pp -3 to initialise the LPT port.
 *      o  The ID locations are left unprogrammed.
 *      o  No support for imbedded fuse and ID information in hex file.
 *      o  EEPROM data is assumed to be word-sized even if INHX8M is used.
 *      o  This is NOT a production quality programmer. (No surprise!).
 *
 *
 * Revision history:
 *
 * ??-Feb-1994: V-0.0; started as a few routines to debug hardware.
 * 07-Mar-1994: V-0.1; first code to successfully program a 16C84.
 * 09-Mar-1994: V-0.2; fuse switches; 7407 support; H/W test.
 * 10-Mar-1994: V-0.3b; LPT2, LPT3 and INHX8M support; cosmetic changes.
 *
 * V-0.1 uploaded to bode.ee.ualberta.edu:pub/cookbook/comp/ibm.
 *
 * This version (V-0.3b) is a beta release.  If you receive this program
 * consider yourself a beta tester (of course, you are under no
 * obligation).  I will remove beta status when 10 (arbitrary
 * I know) testers tell me they have used it to successfully program a
 * PIC using the hardware in pp.asc.
 * 
 *
 * To do:
 *
 *      o Specify ID locations (use Microchip algo?).
 *      o Support combined program, fuses and EEPROM objfiles.
 *      o Verify PIC against a file (trivial, next release).
 *      o Save PIC to file(s) in Intel Hex format (easy I guess).
 *      o Add a GUI (waste of time?).
 *      o Lots of other stuff I just don't have time for.
 *
 *
 * Acknowledgements:
 *
 * The programming algorithms used are taken from the data sheet
 * DS30189A (C) 1992 Microchip Technology Incorporated.  Thanks
 * to Arizona Microchip Technology Ltd for making this information
 * available without restriction.
 *
 * The PC printer port FAQ by Zhahai Stewart for useful info on
 * PC parallel ports.
 *
 *
 * Legal stuff:
 *
 * This is copyright software, but I do not seek to profit from
 * it.  I wrote it in the hope that it will prove useful.  Feel
 * free to modify the program, but please DO NOT distribute
 * modified versions.  Instead, send me your modifications and
 * improvements so that they may, at my discretion, be included in a
 * future release.
 *
 * Although I cannot undertake to support this software, I would
 * welcome bug reports, suggestions or comments which should be
 * sent to:
 *
 *    David Tait,
 *    Electrical Engineering Dept, 
 *    The University, 
 *    Manchester M13 9PL, 
 *    UK.     
 *
 *    david.tait@man.ac.uk
 *
 *
 * Copyright (C) 1994 David Tait.
 * This program is free software.  Permission is granted to use,
 * copy, or redistribute this program so long as it is not sold
 * for profit.
 *
 * THIS PROGRAM IS PROVIDED AS IS AND WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <conio.h>

/* #define U7407 */   /* define U7407 if H/W uses non-inverting buffers */

#define IN      64
#define VPP     8
#define VDD     4
#define CLK     2
#define OUT     1

#define LDCONF  0
#define LDPROG  2
#define RDPROG  4
#define INCADD  6
#define BEGPRG  8
#define LDDATA  3
#define RDDATA  5

#define VPPDLY  100    /* these are in milliseconds */
#define PRGDLY  12

#define TSET    2      /* the units for these are CPU dependent */
#define THLD    2      /* I doubt if they are necessary even    */
#define TDLY    6      /* on the fastest PC, but ...            */

#define PROGRAM 0
#define DATA    1
#define PSIZE   1024
#define DSIZE   64

#define CP      16
#define PWRTE   8
#define WDTE    4
#define RC      3
#define HS      2
#define XT      1
#define LP      0

#define INHX16  16
#define INHX8M  8

#ifdef U7407
#define inbit           (inportb(s_reg)&IN)
#define vppon           (d_bits |= VPP)
#define vppoff          (d_bits &= ~VPP)
#define vddon           (d_bits |= VDD)
#define vddoff          (d_bits &= ~VDD)
#define clkhi           (d_bits |= CLK)
#define clklo           (d_bits &= ~CLK)
#define outhi           (d_bits |= OUT)
#define outlo           (d_bits &= ~OUT)
#else
#define inbit           (~inportb(s_reg)&IN)
#define vppon           (d_bits &= ~VPP)
#define vppoff          (d_bits |= VPP)
#define vddon           (d_bits &= ~VDD)
#define vddoff          (d_bits |= VDD)
#define clkhi           (d_bits &= ~CLK)
#define clklo           (d_bits |= CLK)
#define outhi           (d_bits &= ~OUT)
#define outlo           (d_bits |= OUT)
#endif /* U7407 */
#define assert          (outportb(d_reg,d_bits))


int progbuf[PSIZE];
int databuf[DSIZE];
int fuses = CP+LP;

int d_bits = 0;
int d_reg;
int s_reg;
int check;
int iport = 0;
int hextype = INHX16;
int set_fuses = 0;
int wait = 1;

char *progname = "PIC16C84 Programmer";
char *version = "Version 0.3";
char *copyright = "Copyright (C) 1994 David Tait.";
char *email = "david.tait@man.ac.uk";

void idle_mode()
{
   vppoff, clklo, outlo, assert;
   delay(VPPDLY);
   vddoff, assert;
}

void prog_mode()
{
   vppoff, vddon, clklo, outlo, assert;
   delay(VPPDLY);
   vppon, assert;
}

void quit(s)
char *s;
{
   fprintf(stderr,"pp: %s\n",s);
   idle_mode();
   exit(1);
}
      
void usage()
{
   printf("%s  %s  %s\n\n",progname,version,copyright);
   printf("Usage: pp  [ -lxhrwpc238! ]  objfile1  [ objfile2 ]\n\n");
   printf("       objfile1 = Program data, objfile2 = EEPROM data\n\n");
   printf("       Fuses:    l = LP,   x = XT,    h = HS,  r = RC\n");
   printf("                 w = WDTE, p = PWRTE, c = !CP (i.e. protect)\n");
   printf("       Port:     2 = LPT2, 3 = LPT3\n");
   printf("       Hex:      8 = INHX8M\n");
   printf("       Misc:     ! = no wait\n\n");
   printf("       Defaults: LP, !WDTE, !PWRTE, CP, LPT1, INHX16, wait\n\n");
   printf("Bug reports to %s\n",email);
   idle_mode();
   exit(1);
}

void test_hw()
{
    int b;

    vddon, outhi, assert;   /* better have VDD on in case PIC is there */
    delay(VPPDLY);
    b = inbit;
    outlo, assert;
    if ( b != IN || inbit != 0 ) {
       fprintf(stderr,"pp: Using LPT at 0x%04X\n",d_reg);
       quit("Hardware fault.  Check power, connections and port used.");
    }
    idle_mode();
}

void setup()
{
   int i, b;

   vppoff, vddoff, clklo, outlo, assert;
   d_reg = peek(0,0x408+iport);  /* find the base address of LPT port */
   s_reg = d_reg+1;

   switch ( d_reg ) {  /* I don't want to blow anything up, so check port */
       case 0x3BC:
       case 0x378:
       case 0x278: break;
       default:  fprintf(stderr,"pp: LPT at 0x%04X\n",d_reg);
		 quit("Unlikely LPT address");
   }

   test_hw();

   for ( i=0; i<PSIZE; ++i )
      progbuf[i] = 0x3FFF;
   for ( i=0; i<DSIZE; ++i )
      databuf[i] = 0xFF;
}

void tiny_delay(ticks)
int ticks;
{
   while ( ticks-- )
      ;
}

void clock_out(bit)
int bit;
{
   bit? outhi: outlo, clkhi, assert;
   tiny_delay(TSET);
   clklo, assert;
   tiny_delay(THLD);
   outlo, assert;
}

int clock_in()
{
   int b;

   outhi, clkhi, assert;
   tiny_delay(TSET);
   clklo, assert;
   b = inbit? 1: 0;
   tiny_delay(THLD);
   return b;
}

void out_word(w)
int w;
{
   int b;

   clock_out(0);
   for ( b=0; b<14; ++b )
     clock_out(w&(1<<b));
   clock_out(0);
}

int in_word()
{
   int b, w;

   (void) clock_in();
   for ( w=0, b=0; b<14; ++b )
     w += clock_in()<<b;
   (void) clock_in();
   return w;
}

void command(cmd)
int cmd;
{
   int b;

   outlo, assert;
   tiny_delay(TDLY);
   for ( b=0; b<6; ++b )
      clock_out(cmd&(1<<b));
   outhi, assert;
   tiny_delay(TDLY);
}

void get_option(s)
char *s;
{
   char *sp;

   for ( sp=s; *sp; ++sp )
      switch ( *sp ) {
	 case 'l':
	 case 'L': fuses = (fuses&0x1C) + LP; set_fuses = 1; break;
	 case 'x': 
	 case 'X': fuses = (fuses&0x1C) + XT; set_fuses = 1; break;
	 case 'h':
	 case 'H': fuses = (fuses&0x1C) + HS; set_fuses = 1; break;
	 case 'r':
	 case 'R': fuses = (fuses&0x1C) + RC; set_fuses = 1; break;
	 case 'w':
	 case 'W': fuses |= WDTE; set_fuses = 1; break;
	 case 'p':
	 case 'P': fuses |= PWRTE; set_fuses = 1; break;
	 case 'c':
	 case 'C': fuses &= ~CP; set_fuses = 1; break;
	 case '2': iport = 2; break;
	 case '3': iport = 4; break;
	 case '8': hextype = INHX8M; break;
	 case '!': wait = 0; break;
	 case '-':
	 case '/': break;
	 default: usage();
      }
}

#define yes     (c=getche(), c == 'y' || c == 'Y')

void ask_fuses()
{
   int c, osc, wdte, pwrte, cp;

   do {
      printf("\nOscillator type:\n 0)-LP  1)-XT  2)-HS  3)-RC ? ");
      osc = getche() - '0';
   } while ( osc < 0 || osc > 3 );

   printf("\nEnable watchdog timer (y/n) ? ");
   wdte = yes? WDTE: 0;
   printf("\nEnable power-up timer (y/n) ? ");
   pwrte = yes? PWRTE: 0;
   printf("\n         Protect code (y/n) ? ");
   cp = yes?  0: CP;
   printf("\n");
   fuses = osc + wdte + pwrte + cp;
}

void erase()
{
   int i;

   prog_mode();
   command(LDCONF);
   out_word(0x3FFF);
   for ( i=0; i<7; ++i )
      command(INCADD);
   command(1);
   command(7);
   command(BEGPRG);
   delay(PRGDLY);
   command(1);
   command(7);
}

void program(which)
int which;
{
   int i, n, w, mask, ldcmd, rdcmd, *buf;

   if ( which == PROGRAM ) {
      buf = progbuf;
      n = PSIZE;
      mask = 0x3FFF;
      ldcmd = LDPROG;
      rdcmd = RDPROG;
   } else {
      buf = databuf;
      n = DSIZE;
      mask = 0xFF;
      ldcmd = LDDATA;
      rdcmd = RDDATA;
   }

   prog_mode();
   for ( i=0; i<n; ++i ) {
      command(ldcmd);
      out_word(buf[i]);
      command(BEGPRG);
      delay(PRGDLY);
      command(rdcmd);
      w = in_word() & mask;
      if ( buf[i] != w ) {
	 fprintf(stderr,"pp: %04x: %04x != %04x\n",i,w,buf[i]);
	 quit("Verify failed during programming");
      }
      command(INCADD);
   }
}

void verify(which)
int which;
{
   int i, n, w, mask, rdcmd, *buf;

   if ( which == PROGRAM ) {
      buf = progbuf;
      n = PSIZE;
      mask = 0x3FFF;
      rdcmd = RDPROG;
   } else {
      buf = databuf;
      n = DSIZE;
      mask = 0xFF;
      rdcmd = RDDATA;
   }

   prog_mode();
   for ( i=0; i<n; ++i ) {
      command(rdcmd);
      w = in_word() & mask;
      if ( buf[i] != w ) {
	 fprintf(stderr,"pp: %04x: %04x != %04x\n",i,w,buf[i]);
	 quit("Verify failed");
      }
      command(INCADD);
   }
}

void config()
{
   int i;

   prog_mode();
   command(LDCONF);
   out_word(fuses);
   for ( i=0; i<7; ++i )
     command(INCADD);
   command(LDPROG);
   out_word(fuses);
   command(BEGPRG);
   delay(PRGDLY);
   command(RDPROG);
   if ( fuses != (in_word()&0x1F) )
     quit("Fuse failure");
}

int hexdigit(fp)
FILE *fp;
{
   int c;

   if ( (c=getc(fp)) == EOF )
      quit("Unexpected EOF");

   c -= c>'9'? 'A'-10: '0';
   if ( c<0 || c>0xF )
      quit("Hex digit expected");
   return c;
}

int hexbyte(fp)
FILE *fp;
{
   int b;

   b = hexdigit(fp);
   b = (b<<4) + hexdigit(fp);
   check += b;               /* nasty side-effect, but useful trick */
   return b;
}

unsigned hexword(fp)
FILE *fp;
{
   unsigned w;

   w = hexbyte(fp);
   w = (w<<8) + hexbyte(fp);
   return w;
}

#define swab(w) (((w)>>8)+(((w)&0xFF)<<8))   /* swap bytes */

void loadhex(fp, buf, bufsize)
FILE *fp;
int buf[], bufsize;
{
   int type, nwords, i;
   unsigned address, w;

   type = 0;
   while ( type != 1 ) {
      if ( getc(fp) != ':' )
	 quit("Expected ':'");
      check = 0;
      w = hexbyte(fp);
      nwords = (hextype == INHX8M)? w/2: w;
      w = hexword(fp);
      address = (hextype == INHX8M)? w/2: w;
      type = hexbyte(fp);
      for ( i=0; i<nwords; ++i, ++address ) {
	 if ( address >= bufsize )
	    quit("Impossible address");
	 w = hexword(fp);
	 buf[address] = (hextype == INHX8M)? swab(w): w;
      }
      (void) hexbyte(fp);
      (void) getc(fp);
      if ( check&0xFF )
	 quit("Checksum error");
   }
}

void main(argc, argv)
int argc;
char *argv[];
{
   FILE *objfp[2];
   int i, c, obj_cnt = 0;
   
   for ( i=1; i<argc; ++i ) {
      if ( (c = *argv[i]) == '-' || c == '/' )
	 get_option(++argv[i]);
      else if ( obj_cnt < 2 )
	 if ( (objfp[obj_cnt++] = fopen(argv[i],"r")) == NULL )
	    quit("Can't open objfile");
   }

   setup();

   if ( obj_cnt < 1 )
      usage();

   loadhex(objfp[0], progbuf, PSIZE);
   if ( obj_cnt > 1 )
      loadhex(objfp[1], databuf, DSIZE);
   
   printf("%s  %s  %s\n",progname,version,copyright);
   if ( !set_fuses )
      ask_fuses();
   if ( wait ) {
      printf("\nInsert PIC and press a key to start (^C to abort) ...\n");
      if ( getch() == 3 )
	 quit("Aborted");
   }
   printf("\nProgramming ...\n");
   erase();
   program(PROGRAM);
   if ( obj_cnt > 1 )
      program(DATA);
   printf("Verifying ...\n");
   verify(PROGRAM);
   if ( obj_cnt > 1 )
      verify(DATA);
   printf("Blowing fuses to 0x%02X ...\n",fuses);
   config();
   printf("Finished\n\n");
   idle_mode();
}
