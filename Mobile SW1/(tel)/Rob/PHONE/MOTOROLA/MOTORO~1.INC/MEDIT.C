/*********************************************************************
 * This is Version 3.03 of my "Mot Menu Editor" now with full
 * bitmap-support AND editable phonebook!
 *
 * It's pure ANSI C and should be compileable with almost all C-Compilers.
 *
 * See MEDIT.TXT for more information and how to use.
 *
 * Thanks to Janus, because he's doing it!
 * Thanks to ANDROID for his wonderfull work with ASIM!
 *
 * I WILL NOT claim ANY responsibility if you damage your phone with this
 * programme! Be carefull!
 *
 * See usage() for info on cmdline options.
 *
 * (c) tst 1997,1998
 * tst@iname.com
 *
 *********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PRGVERSION "MEDIT v3.03   (c) 1997,1998 TST\n"

typedef  unsigned int   UINT;
typedef  unsigned long  DWORD;
typedef  long           LONG;
typedef  unsigned int   WORD;
typedef  unsigned char  BYTE;

/* Name of menu-description file: */
#define MENUFILE "medit.mnu"

/* Max. size of framefile, should be 4096, but just to be on the safe side: */
#define MAXFRAMESIZE 8192

/* The number of the frame is at: */
#define FRAMENUMBER 0x40


/* Graphic: */
#define WIDTH 96
#define HEIGHT 32

/* Graphic-position in frame 1 or 4: */
#define GRSTART 0x1AB
#define GRSTEP  0x84

/* Struct for windows-bitmap: */
typedef struct
{
   UINT    biType;
   DWORD   biFileSize;
   UINT    biReserved1;
   UINT    biReserved2;
   DWORD   biOffBits;
   DWORD   biSizeHeader;
   LONG    biWidth;
   LONG    biHeight;
   WORD    biPlanes;
   WORD    biBitCount;
   DWORD   biCompression;
   DWORD   biSizeImage;
   LONG    biXPelsPerMeter;
   LONG    biYPelsPerMeter;
   DWORD   biClrUsed;
   DWORD   biClrImportant;
   BYTE    biBlue1;
   BYTE    biGreen1;
   BYTE    biRed1;
   BYTE    biColorReserved1;
   BYTE    biBlue2;
   BYTE    biGreen2;
   BYTE    biRed2;
   BYTE    biColorReserved2;
   BYTE    biData[WIDTH*HEIGHT/8];
   DWORD   biReserved3;
} BITMAP;

BITMAP *bitmap;


/* defines for the address of the menu-"binary array" in frame 1 or 4*/
/* first and last byte: */
#define MSTART  0x176
#define MEND    0x18F


/* Map from ASCII to Mot-chars. "@" == 0x00 */
char *charmap[2] =
 { " 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
   "+-*/=><#.?!,&:()'¨­%œ$Ž…’á‡„†‘Šè‚â¥™0•ê¤”š—@",

   " 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
   "+-*/=><#.?!,&:()'\x60\x40%\x01\x02\x5B\x0E\x7F\x1C\x1E\x09\x7B\x0F\x1D"
   "\x10\x1F\x04\x12\x05\x13\x07\x5D\x5C\x0B\x08\x15\x7D\x7C\x5E\x06\x7E\x00" };


/* Phonebook position in frame 2 and 4: */
#define PBSTART ((framedata[FRAMENUMBER] == 2)? 0x60 : 0x297)
#define PBENTRYSTART ((framedata[FRAMENUMBER] == 2)? 1 : 75)
#define PBENTRIES ((framedata[FRAMENUMBER] == 2)? 74 : 26)

/* Number of chars the phone can store: */
#define MAXPBNUMBER 32
#define MAXPBTEXT   16

/* Struct for phonebook-entry in frame 2 and 3: */
typedef struct
{
   WORD  pbQualifier;
   BYTE  pbLocation;
   char  pbText[MAXPBTEXT];
   BYTE  pbNumberLen;
   BYTE  pbNumberQualif;
   BYTE  pbNumber[MAXPBNUMBER / 2];
   WORD  pbUnused;
} PBENTRY;

/* This define can be replaced by a "sizeof(PBENTRY)", but ONLY
   if your compiler makes no "word-alignment" or whatsoever: */
#define PBENTRYSIZE (7+MAXPBTEXT+MAXPBNUMBER/2)


char *progname;

char *framedata;
int   framesize;

int verbose;

/*********************************************************************/

void usage(void)
{
   fputs(PRGVERSION
   "Usage:\n"
   " MEDIT [-v] <frame.bin> [<textfile> [<outframe.bin>]]\n\n"
   " -v:           Display verbose status messages.\n"
   " frame.bin:    Binary file from which the data is read.Either frame 1,2,3 or 4.\n"
   " textfile:     Textfile with menudefinitions or phonebook.\n"
   " outframe.bin: Changed outputfile. If omitted frame.bin is overwritten.\n"
   "\n\nor:\n"
   " MEDIT [-v] <frame.bin> <-b<r|w> bitmap.bmp> [<outframe.bin>]\n\n"
   " -v:             Display verbose status messages.\n"
   " frame.bin:      Binary file from which the data is read. Must be frame 1 or 4.\n"
   " -br bitmap.bmp: Bitmap 96x32 to be used as startup-graphic in frame.bin.\n"
   " -bw bitmap.bmp: Startup-graphic of frame.bin is written to bitmap.bmp\n"
   " outframe.bin:   Changed outputfile. If omitted frame.bin is overwritten.\n",
   stderr );
}

void usagebmp(void)
{
   fprintf( stderr, "Unsupported bitmap type. Valid bitmaps are width=%d height=%d\n"
      "uncompressed with 1-bit black and white color.\n", WIDTH, HEIGHT);
}

void printmsg(char *msg)
{
   if( verbose )
      puts( msg );
}


FILE *fopenfile(char *filename, char *mode)
{
   FILE *afile;

   if( (afile = fopen( filename, mode )) == NULL )
      if( *mode == 'r' )
       {
         fprintf( stderr, "%s: cannot open file %s for reading: %s\n",
                  progname, filename, strerror( errno ) );
         exit( -2 );
       }
      else
       {
         fprintf( stderr, "%s: cannot open file %s for writing: %s\n",
                  progname, filename, strerror( errno ) );
         exit( -3 );
       }

   return( afile );
}

void fcheckerr(FILE *afile, char *doingwhat, char *filename)
{
   if( ferror( afile ) )
    {
      fprintf( stderr, "%s: error %s %s: %s\n",
               progname, doingwhat, filename, strerror( errno ) );
      exit( -1 );
    }
}

/*********************************************************************/

void parsemenufile(char *filename)
{
   int dest, line;
   char c, linebuffer[80];
   FILE *in;

   in = fopenfile( filename, "rb" );

   while( !ferror(in) && !feof(in) )
    {
      if( fgets(linebuffer, sizeof(linebuffer), in) != NULL)
       {
         if( sscanf(linebuffer, "%d %c", &line, &c) != EOF)
          {
            dest = line / 8 + MSTART;
            if( (dest < MSTART) || (dest > MEND) )
               fprintf( stderr, "Menu number %d out of range.\n", line );
            else
             {
               if( c == '0' )
                {
                  framedata[dest] &= (0xFF - (1 << (line % 8)));
                  if( verbose )
                     printf("Set menu %d OFF.\n", line );
                }
               if( c == '1' )
                {
                  framedata[dest] |= 1 << (line % 8);
                  if( verbose )
                     printf("Set menu %d ON.\n", line );
                }
             }
          }
       }
    }

   fcheckerr( in, "reading", filename );
   fclose( in );
}

void outputmenudata(void)
{
   int i, count, line = 0, fileline;
   char linebuffer[255], descr[100], c;
   FILE *in;

   if( (in = fopen( MENUFILE, "r" )) == NULL )
    {
      fprintf( stderr, "Menu description file %s not available, descriptions are omitted.\n",
         MENUFILE);
    }

   for(count=MSTART; count <= MEND; count++)
    {
      c = framedata[count];
      for(i=0; i<8; i++)
       {
         if( in != NULL )
          {
            if( fgets(linebuffer, sizeof(linebuffer), in) == NULL)
             {
               in = NULL;
               *descr = 0;
             }
            else
             {
               sscanf(linebuffer, "%d %*c %100c", &fileline, descr);
               if(fileline != line || (strlen(linebuffer) < 10))
                  *descr = 0;
               else
                  *strchr(descr, '\n') = 0;
             }
            printf("%03d  %1d  %s\n", line, c&1, descr);
          }
         else
          {
            printf("%03d  %1d  \n", line, c&1);
          }

         line++;
         c >>= 1;
       }
    }

   fcheckerr( in, "reading", MENUFILE );
   fclose( in );
}

/*********************************************************************/

void readfilebin(char *framefile)
{
   FILE *in;

   in = fopenfile( framefile, "rb" );

   framesize = fread(framedata, 1, MAXFRAMESIZE, in);

   fcheckerr( in, "reading", framefile );

   if( framesize >= MAXFRAMESIZE )
    {
      fprintf( stderr, "%s: error reading %s: Framefile too long.\n",
               progname, framefile );
      exit( 13 );
    }

   if( framesize < MEND )
    {
      fprintf( stderr, "%s: error reading %s: Framefile too short\n",
               progname, framefile );
      exit( 12 );
    }

   switch( framedata[FRAMENUMBER] )
    {
      case 1: printmsg("This is a frame #1"); break;
      case 2: printmsg("This is a frame #2"); break;
      case 3: printmsg("This is a frame #3"); break;
      case 4: printmsg("This is a frame #4"); break;
    }

   fclose(in);
}

void writefilebin(char *framefile)
{
   FILE *out;

   out = fopenfile( framefile, "wb" );

   if( fwrite(framedata, 1, framesize, out) != framesize )
      fprintf( stderr, "%s: error writing %s: Amount of data written differs datasize.\n",
               progname, framefile );

   fcheckerr( out, "writing", framefile );
   fclose(out);
}

/*********************************************************************/

void readbitmap(char *filename)
{
   FILE *in;
   size_t bytesread;
   int error = 0;

   in = fopenfile( filename, "rb" );

   bytesread = fread(bitmap, 1, sizeof(BITMAP), in);

   fcheckerr( in, "reading", filename );

   if( bytesread >= sizeof(BITMAP) )
    {
      fprintf( stderr, "%s: error reading %s: Bitmapfile too long.\n",
               progname, filename );
      usagebmp();
      exit( 53 );
    }

   if( bytesread < (sizeof(BITMAP)-WIDTH*HEIGHT/8) )
    {
      fprintf( stderr, "%s: error reading %s: Bitmapfile too short\n",
               progname, filename );
      usagebmp();
      exit( 52 );
    }


   fclose(in);

   error = bitmap->biWidth != WIDTH;
   error |= bitmap->biHeight != HEIGHT;
   error |= bitmap->biCompression != 0;
   error |= bitmap->biBitCount != 1;
   error |= bitmap->biType != *(UINT*) "BM";
   error |= bitmap->biSizeHeader != 40;

   if( error )
    {
      usagebmp();
      exit(55);
    }

}

void writebitmap(char *filename)
{
   FILE *out;

   bitmap->biType = *(UINT*) "BM";
   bitmap->biFileSize = sizeof(BITMAP);
   bitmap->biReserved1 = 0;
   bitmap->biReserved2 = 0;
   bitmap->biOffBits = 62;
   bitmap->biSizeHeader = 40;
   bitmap->biWidth = WIDTH;
   bitmap->biHeight = HEIGHT;
   bitmap->biPlanes = 1;
   bitmap->biBitCount = 1;
   bitmap->biCompression = 0;
   bitmap->biSizeImage = (HEIGHT*WIDTH)/8;
   bitmap->biXPelsPerMeter = 4740;
   bitmap->biYPelsPerMeter = 4740;
   bitmap->biClrUsed = 0;
   bitmap->biClrImportant = 0;
   bitmap->biBlue1 = 0;
   bitmap->biGreen1 = 0;
   bitmap->biRed1 = 0;
   bitmap->biColorReserved1 = 0;
   bitmap->biBlue2 = 0xFF;
   bitmap->biGreen2 = 0xFF;
   bitmap->biRed2 = 0xFF;
   bitmap->biColorReserved2 = 0;
   bitmap->biReserved3 = 0;


   out = fopenfile( filename, "wb" );

   if( fwrite(bitmap, 1, sizeof(BITMAP)-sizeof(bitmap->biReserved3), out) != (sizeof(BITMAP)-sizeof(bitmap->biReserved3)) )
      fprintf( stderr, "%s: error writing %s: Amount of data written differs datasize.\n",
               progname, filename );

   fcheckerr( out, "writing", filename );
   fclose(out);
}

void checkframegraphic(void)
{
   int i;
   for(i=0; i<4; i++)
      if( (*(WORD *)(framedata + GRSTART-3 + GRSTEP*i) != 0x1081)
            || (framedata[GRSTART-1+GRSTEP*i] != i+1) )
         fprintf( stderr, "WARNING! Framedata at %X does not match 81 10 0%d. Proceeding anyway.\n",
               GRSTART-3 + GRSTEP*i, i+1);
}

int getpixelbmp(int x, int y)
{
   return( (bitmap->biData[(HEIGHT-y-1)*(WIDTH/8) + x/8] & 1<<(7-(x % 8))) );
}

int getpixelframe(int x, int y)
{
   return(framedata[GRSTART+GRSTEP*(y/8)+x] & 1<<(y%8));
}

void setpixelbmp(int x, int y, int value)
{
   if( value )
      bitmap->biData[(HEIGHT-y-1)*(WIDTH/8) + x/8] |= 1<<(7-(x % 8));
   else
      bitmap->biData[(HEIGHT-y-1)*(WIDTH/8) + x/8] &= (BYTE) 0xFF - (BYTE) (1<<(7-(x % 8)));
}

void setpixelframe(int x, int y, int value)
{
   if( value )
      framedata[GRSTART+GRSTEP*(y/8)+x] |= 1<<(y%8);
   else
      framedata[GRSTART+GRSTEP*(y/8)+x] &= (BYTE) 0xFF - (BYTE) (1<<(y%8));
}

void copybmp2frame(void)
{
   int x, y;

   for( y=0; y<HEIGHT; y++ )
      for( x=0; x < WIDTH; x++ )
         setpixelframe( x,y, getpixelbmp(x,y) );
}

void copyframe2bmp(void)
{
   int x, y;

   for( y=0; y<HEIGHT; y++ )
      for( x=0; x < WIDTH; x++ )
         setpixelbmp( x,y, getpixelframe(x,y) );
}

/*********************************************************************/

void parsepbdata(char *filename)
{
   int dest, converted, i, j;
   char linebuffer[80], scanstring[16], number[MAXPBNUMBER+30], text[MAXPBTEXT+1];
   char *p, *tp;
   FILE *in;
   PBENTRY *entry;
   BYTE num;

   in = fopenfile( filename, "rb" );

   sprintf( scanstring, "%%d %%s %%%dc", MAXPBTEXT );
   while( !ferror(in) && !feof(in) )
    {
      if( fgets(linebuffer, sizeof(linebuffer), in) != NULL)
       {
         if( (converted = sscanf(linebuffer, scanstring, &dest, number, text)) != EOF)
          {
            if( dest >= PBENTRYSTART && dest < PBENTRYSTART + PBENTRIES )
             {
               entry = (PBENTRY *)(framedata+PBSTART+(dest-PBENTRYSTART)*PBENTRYSIZE);
               if( entry->pbQualifier != 0x4B24 || entry->pbLocation != dest )
                {
                  fprintf( stderr, "%s: Don't know how to handle frame data, canceled for safety.\n",
                         progname);
                  exit( 73 );
                }

               memset( entry->pbText, 0xFF, sizeof(entry->pbText) );
               memset( entry->pbNumber, 0xFF, sizeof(entry->pbNumber) );

               if( converted > 1 )
                {
                  text[MAXPBTEXT] = 0;
                  if( (p = strchr( text, '\r' )) != NULL )
                     *p = 0;
                  if( (p = strchr( text, '\n' )) != NULL )
                     *p = 0;

                  for( i = 0; (i < MAXPBTEXT && text[i] != 0); i++)
                     if( (p = strchr(charmap[0], text[i])) != NULL )
                        entry->pbText[i] = *(p - charmap[0] + charmap[1]);
                     else
                        entry->pbText[i] = ' ';

                  entry->pbNumberQualif = 0x81;

                  i = j = 0;
                  while( i < MAXPBNUMBER && number[j] != 0 )
                     if( number[j] == '+' )
                      {
                        entry->pbNumberQualif = 0x91;
                        j++;
                      }
                     else
                      {
                        if( number[j] >= '0' && number[j] <= '9' )
                           num = number[j] - '0';
                        else
                           switch( number[j] )
                            {
                              case '*': num = 0x0A; break;
                              case '#': num = 0x0B; break;
                              case 'p':
                              case 'P': num = 0x0C; break;
                              default:
                                 fprintf( stderr, "%s: Invalid character in number: %c\n", progname, number[j] );
                            }

                        if( (i & 1) )
                           entry->pbNumber[i/2] = ((BYTE)entry->pbNumber[i/2] & 0x0F) | (num<<4);
                        else
                           entry->pbNumber[i/2] = ((BYTE)entry->pbNumber[i/2] & 0xF0) | num;
                        j++;
                        i++;
                      }
                  entry->pbNumberLen = i/2 + 1;
                  number[j] = 0;
                  if( verbose )
                     printf( "PB-entry %d set to '%s'  '%s'\n", entry->pbLocation, number, text );
                }
               else
                {
                  entry->pbText[0] = 0xFE;
                  entry->pbNumberLen = entry->pbNumberQualif = 0xFF;
                  if( verbose )
                     printf( "PB-entry %d removed.\n", entry->pbLocation );
                }
             }
          }
       }
    }

   fcheckerr( in, "reading", filename );
   fclose( in );
}

void outputpbdata(void)
{
   int count, i;
   PBENTRY *entry;
   char number[MAXPBNUMBER+2], text[MAXPBTEXT+1], *np, *tp, *p;
   BYTE num;

   for(count = 0; count < PBENTRIES; count++)
    {
      entry = (PBENTRY *)(framedata+PBSTART+count*PBENTRYSIZE);

      if( entry->pbQualifier != 0x4B24 )
       {
         fprintf( stderr, "%s: Don't know how to handle frame data, canceled for safety.\n",
                progname);
         exit( 61 );
       }

      if( (BYTE)*entry->pbText != 0xFE )
       {
         np = number;
         if( (entry->pbNumberQualif & 0x10) )
            *(np++) = '+';
         for( i = 0; i < entry->pbNumberLen; i++ )
          {
            num = entry->pbNumber[i] & 0x0F;
            if( num <= 0x0c )
               if( num == 0x0a )
                  *(np++) = '*';
               else
                  if( num == 0x0b )
                     *(np++) = '#';
                  else
                     if( num == 0x0c )
                        *(np++) = 'p';
                     else
                        *(np++) = num + '0';

            num = entry->pbNumber[i] >> 4;
            if( num <= 0x0c )
               if( num == 0x0a )
                  *(np++) = '*';
               else
                  if( num == 0x0b )
                     *(np++) = '#';
                  else
                     if( num == 0x0c )
                        *(np++) = 'p';
                     else
                        *(np++) = num + '0';
          }

         *np = 0;
         i = 0;
         tp = text;
         while( i < MAXPBTEXT && (BYTE)entry->pbText[i] != 0xFF )
          {
            if( (p = strchr(charmap[1], entry->pbText[i])) != NULL )
               *(tp++) = *(p - charmap[1] + charmap[0]);
            else
               *(tp++) = ' ';

            i++;
          }
         *tp = 0;

         printf("%d %s %s\n", entry->pbLocation, number, text);
       }
    }

}


/*********************************************************************/


void main(int argc, char **argv)
{
   int args = argc, nextarg = 1, framearg = 1, dontsave = 0;

   progname = argv[0];

   if( args >= 2 && *(UINT*) argv[nextarg] == *(UINT*) "-v" )
    {
      verbose = 1;
      args--;
      nextarg++;
      framearg = nextarg;
    }
   else
      verbose = 0;

   printmsg("Allocating memory for frame/bitmap.");
   framedata = malloc(MAXFRAMESIZE);
   bitmap = malloc(sizeof(BITMAP));

   if( bitmap == NULL || framedata == NULL )
    {
      fprintf( stderr, "%s: Cannot allocate memory.\n", progname );
      exit( 1 );
    }


   if( args == 2 )
    {
      printmsg("Reading frame file.");

      readfilebin(argv[nextarg]);

      if( (framedata[FRAMENUMBER] == 1) || (framedata[FRAMENUMBER] == 4) )
       {
         printmsg( "Printing menu list:" );
         outputmenudata();
       }
      else
         if( (framedata[FRAMENUMBER] == 2) || (framedata[FRAMENUMBER] == 3) )
          {
            printmsg("Printing phonebook entries:");
            outputpbdata();
          }
         else
          {
            fprintf( stderr, "%s: Only frames #1, #2, #3 or #4 are supported.\n", progname );
            exit( 100 );
          }
      printmsg("Done.");
    }
   else
      if( (args >= 3) && (args <= 5) )
       {
         printmsg("Reading frame file.");
         readfilebin(argv[nextarg]);

         if( (framedata[FRAMENUMBER] == 1) || (framedata[FRAMENUMBER] == 4) )
          {
            if( *(UINT*) argv[nextarg+1] == *(UINT*) "-b" )
             {
               if( argv[nextarg+1][2] == 'r' )
                {
                  printmsg("Checking frame graphics data.");
                  checkframegraphic();
                  printmsg("Loading bitmap file.");
                  readbitmap(argv[nextarg+2]);
                  printmsg("Storing bitmap to frame.");
                  copybmp2frame();
                  nextarg += 3;
                }
               else
                  if( (argv[nextarg+1][2] == 'w') && (nextarg+3 == argc) )
                   {
                     dontsave = 1;
                     printmsg("Checking frame graphics data.");
                     checkframegraphic();
                     printmsg("Creating bitmap from frame.");
                     copyframe2bmp();
                     printmsg("Saving bitmapfile.");
                     writebitmap(argv[nextarg+2]);
                     nextarg += 3;
                   }
                  else
                   {
                     usage();
                     exit( 103 );
                   }
             }
            else
               if( args <= 4 )
                {
                  printmsg("Setting menus from file to frame.");
                  parsemenufile(argv[nextarg+1]);
                  nextarg += 2;
                }
               else
                {
                  usage();
                  exit( 102 );
                }
          }
         else
            if( (framedata[FRAMENUMBER] == 2) || (framedata[FRAMENUMBER] == 3) )
             {
               printmsg("Storing phonebook entries from file to frame.");
               parsepbdata(argv[nextarg+1]);
               nextarg += 2;
             }
            else
             {
               fprintf( stderr, "%s: Only frames #1, #2, #3 or #4 are supported.\n", progname );
               exit( 101 );
             }

         if( !dontsave )
          {
            if( nextarg < argc )
             {
               printmsg("Saving frame data to new file.");
               writefilebin(argv[nextarg]);
             }
            else
             {
               printmsg("Saving frame data to original file.");
               writefilebin(argv[framearg]);
             }
          }
         printmsg("Done.");
       }
      else
         usage();

   free(bitmap);
   free(framedata);
}
