/* genstops --- generate the table of 1/3 stops             30/08/2010 */
/* Copyright (c) 2010 John Honniball, Dorkbot Bristol                  */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define NMIDINOTES   (128)
#define TWOPI (2.0 * 3.1415926536)

int main (void)
{
   int n;
   double freq;
   unsigned int midiTable[NMIDINOTES];
   
   for (n = 0; n < NMIDINOTES; n++)
      midiTable[n] = 0;
         
   for (n = 0; n < NMIDINOTES; n++) {
      freq = pow (2.0, (n - 69) / 12.0) * 440.0;
      midiTable[n] = (int)((65536.0 * freq) / 31250.0) + 0.5;
   }
   
   printf ("PROGMEM prog_uint16_t midiTable[%d] = {\n", NMIDINOTES);
   printf ("/*  C,   C#,    D,   D#,    E,    F,   F#,    G,   G#,    A,   A#,    B */\n");
   
   for (n = 0; n < NMIDINOTES; n++) {
      printf ("%5d", midiTable[n]);
      if (n < (NMIDINOTES - 1)) {
         if ((n % 12) == 11) 
            printf (",\n");
         else
            printf (",");
      }
   }
   
   printf ("\n};\n");
   
   return (0);
}
