/*-------------------------------------
File: lcdDisp.c  (LCD Diplay Module)

Description: C Module that provides
             display functions on the
             LCD. It makes use of the LCD ASM 
             Module developed in assembler.
-------------------------------------*/
#include <mc9s12dg256.h>
/* Notes on mc9s12dg256.h:
   1) the type "byte" is defined as "unsigned char"
*/
#include "lcd_asm.h"

// Prototypes of local functions

/*--------------------------
Function: initLCD
Parameters: None.
Returns: nothing
Description: Initialised the LCD hardware by
             calling the assembler subroutine.
---------------------------*/

void initLCD(void)
{
  // complete this function
}

/*--------------------------
Function: printStr

Parameters: str - pointer to string to be printed 
                  (only 16 chars are printed)
            lineno - 0 first line
                     1 second line
Returns: nothing

Description: Prints a string on the display on one of the
             two lines.  String is padded with spaces to
             erase any existing characters.
---------------------------*/
void printLCDStr(char *str, byte lineno)
{
  // complete this function
}


