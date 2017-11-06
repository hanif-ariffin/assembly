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

/*---------------------------------------------
Function: initDisp
Description: initializes hardware for the 
             7-segment displays.
-----------------------------------------------*/
void initDisp(void) 
{
   // Complete this function
      DDRB = 0xFF;
      DDRP = 0xFF;
      clearDisp();
      segDisp();
}

/*---------------------------------------------
Function: clearDisp
Description: Clears all displays.
-----------------------------------------------*/
void clearDisp(void) 
{
	// Complete this function
      setCharDisplay(0x00,0);
      setCharDisplay(0x00,1);
      setCharDisplay(0x00,2);
      setCharDisplay(0x00,3);

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
Byte PB00,PB01,PB02,PB03;


void setCharDisplay(char ch, byte dispNum) 
{
	// Complete this function

      //TAK CONFIRM PASAL CHAR TYPE !!
      if(dispNum == 0){
            PB00 = ch;
      }
      else if (dispNum == 1){
            PB01 = ch;
      }
      else if (dispNum == 2){
            PB02 = ch;
      }
      else if (dispNum == 3){
            PB03 = ch;
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
	// Complete this function
            PORTB = PB00;
            //PORTP = 0xFE;
            delayms(1);
            PORTB = PB01;
            //PORTP = 0xFD;
            delayms(1);
            PORTB = PB02;
            //PORTP = 0xFB;
            delayms(1);
            PORTB = PB03;
            //PORTP = 0xF7;
            delayms(1);
            //PORTP = 0xFF;
}
