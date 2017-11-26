/*--------------------------------------------
File: SegDisp.c
Description:  Segment Display Module
---------------------------------------------*/

#include <stdtypes.h>
#include "mc9s12dg256.h"
#include "SegDisp.h"
#include "Delay_asm.h"

#define LCD_DISP_ROW 2
#define LCD_DISP_COL 16
#define ASCII_SPACE 32



//The array of the characters to be written on the 4 7-segment display on the board
char char_array[4]  = {0x00, 0x00, 0x00, 0x00};

/*---------------------------------------------
Function: initDisp
Description: initializes hardware for the
             7-segment displays.
-----------------------------------------------*/
void initDisp(void)
{
  // Initialize PORTB and PORTP by setting DDRB and DDRP to output mode
  DDRB = 0xFF;
  DDRP = 0x0F;

  //Clear the display just in case
  clearDisp();
}

/*---------------------------------------------
Function: clearDisp
Description: Clears all displays.
-----------------------------------------------*/
void clearDisp(void)
{
  int char_count = 0;

  // The value to be written is NULL in ASCII
  PORTB = 0x00;

  // Tells the board to write this to all 4 display
  PTP = 0x11;

  // Also clears the value in our character array to zero
  while (char_count < 4)
  {
    char_array[char_count] = 0x00;
    char_count++;
  }

}

/*---------------------------------------------
Function: setCharDisplay
Description: Receives an ASCII character (ch)
             and translates
             it to the corresponding code to
             display on 7-segment display.  Code
             is stored in appropriate element of
             codes for identified display (dispNum).
-----------------------------------------------*/


void setCharDisplay(char ch, byte dispNum)
{
  /*
  The entire switch is a map between value in binary -> binary for 7-segment display
  */
  switch (ch) {
  case '0' :
    char_array[(int)dispNum] = 0x3F;
    break;
  case '1' :
    char_array[(int)dispNum] = 0x06;
    break;
  case '2' :
    char_array[(int)dispNum] = 0x5B;
    break;
  case '3' :
    char_array[(int)dispNum] = 0x4F;
    break;
  case '4' :
    char_array[(int)dispNum] = 0x66;
    break;
  case '5' :
    char_array[(int)dispNum] = 0x6D;
    break;
  case '6' :
    char_array[(int)dispNum] = 0x7D;
    break;
  case '7' :
    char_array[(int)dispNum] = 0x07;
    break;
  case '8' :
    char_array[(int)dispNum] = 0x7F;
    break;
  case '9' :
    char_array[(int)dispNum] = 0x67;
    break;
  default:
    char_array[(int)dispNum] = 0x00;
    break;
  }
}

/*---------------------------------------------
Function: segDisp
Description: Displays the codes in the code display table
             (contains four character codes) on the 4 displays
             for a period of 100 milliseconds by displaying
             the characters on the displays for 5 millisecond
             periods.
-----------------------------------------------*/
void segDisp(void)
{
  int display_delay;
  
  //Loop through the array multiple times while updating the value in the 7-segment display
  for (display_delay = 0; display_delay < 5; display_delay++)
  {
    PORTB = char_array[0];
    PTP = 0xE;
    delayMs(5);

    PORTB = char_array[1];
    PTP = 0xD;
    delayMs(5);

    PORTB = char_array[2];
    PTP = 0xB;
    delayMs(5);

    PORTB = char_array[3];
    PTP = 0x7;
    delayMs(5);
  }
}