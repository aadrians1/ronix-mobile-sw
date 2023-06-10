#include<stdio.h>
#include<dos.h>
#include<conio.h>

#define COM1 1
#define COM2 2
#define COM3 3
#define COM4 4

typedef unsigned char byte;
typedef unsigned int word;

void init_rs(byte port);
void close_rs(byte port);
byte send_rs(char c);
void interrupt far przerw_rs(...);

void interrupt (*old_prz)(...);
int tbr,rbr,ier,lcr,mcr,lsr,msr;

void send_comand(char *komenda);
void set_datamode(void);
void set_commandmode(void);

byte bufor[10000];
byte flznak=0;
word indeks=0;

void main(void)
{ struct REGPACK r;
  unsigned char dana;
  byte i;

  clrscr();
  init_rs(COM1);
  do
  { if(flznak)
    { flznak=0;
      printf("%x ",bufor[indeks-1]);
    }
    if (kbhit())
    { i=getch();
      send_rs(i);
    }
  } while(i!=27);
  close_rs(COM1);
}

void send_comand(char *komenda)
{ byte i=0;

  while(komenda[i]!=0)
  { send_rs(komenda[i]);
    i++;
  }
}

void init_rs(byte port)
{ struct REGPACK r;
  word baza;
  byte i;

  disable();
  if (port==COM1)
  { baza=0x3f8;
    r.r_dx=0;
    old_prz=getvect(0x0c);
    setvect(0x0c,przerw_rs);
    outportb(0x21,(inportb(0x21)&0xef)); //zezwolenie na IRQ 4 w 8259
  }
  if(port==COM2)
  { baza=0x2f8;
    r.r_dx=1;
    old_prz=getvect(0x0b);
    setvect(0x0b,przerw_rs);
    outportb(0x21,(inportb(0x21)&0xf7)); //zezwolenie na IRQ 3 w 8259
  }
  if (port==COM3)
  { baza=0x3e8;
    r.r_dx=2;
    old_prz=getvect(0x0c);
    setvect(0x0c,przerw_rs);
    outportb(0x21,(inportb(0x21)&0xef)); //zezwolenie na IRQ 4 w 8259
  }
  if(port==COM4)
  { baza=0x2e8;
    r.r_dx=3;
    old_prz=getvect(0x0b);
    setvect(0x0b,przerw_rs);
    outportb(0x21,(inportb(0x21)&0xf7)); //zezwolenie na IRQ 3 w 8259
  }
  r.r_ax=0x00f3; // parametry  f3 - 9600 93 - 1200
  intr(0x14,&r);
  tbr=baza;
  rbr=baza;
  ier=baza+1;
  lcr=baza+3;
  mcr=baza+4;
  lsr=baza+5;
  msr=baza+6;
//  outportb(lcr,(inportb(lcr)|0x80));  //dolaczenie dostepu do dzielnika predk.
//  outportb(tbr,0x06); // przelaczenie na 19200 baud
  outportb(lcr,(inportb(lcr)&0x7f));  //odlaczenie dostepu do dzielnika predk.
  inportb(lsr);  //skasowanie ewentualnych bledow
  inportb(rbr);  //skasowanie znacznika LSR0 - dana w buforze
  outportb(ier,1); //odblokowanie przerwania od odbiornika w 8250
  outportb(mcr,9); //uaktywnienie OUT2 oraz RTS->1, DTR->1
  enable();
}

void close_rs(byte port)
{ disable();
  if(port==COM1)
  { outportb(0x21,(inportb(0x21)|0x10)); //zablokowanie IRQ 4 w 8259
    setvect(0x0c,old_prz);
  }
  if(port==COM2)
  { outportb(0x21,(inportb(0x21)|0x08)); //zablokowanie IRQ 3 w 8259
    setvect(0x0c,old_prz);
  }
  if(port==COM3)
  { outportb(0x21,(inportb(0x21)|0x10)); //zablokowanie IRQ 4 w 8259
    setvect(0x0c,old_prz);
  }
  if(port==COM4)
  { outportb(0x21,(inportb(0x21)|0x08)); //zablokowanie IRQ 3 w 8259
    setvect(0x0c,old_prz);
  }
  outportb(lcr,(inportb(lcr)&0x7f)); //odlaczenie dostepu do dzielnika predk.
  outportb(ier,0); //zablokowanie przerwan w 8250
  outportb(mcr,0); //deaktywacja OUT2,DTR,RTS
  enable();
}

byte send_rs(char c)
{ do {} while((inportb(lsr)&0x20)!=0x20);
  disable();
  outportb(tbr,c);
  enable();
  return 1;
}

void interrupt far przerw_rs(...)
{ bufor[indeks]=inportb(rbr);
  indeks++;
  flznak=1;
  outportb(0x20,0x20); //Wyslanie EOI do 8259
}
