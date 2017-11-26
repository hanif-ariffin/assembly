/*--------------------------------------------
File: SegDisp.c
Description:  Segment Display Module
---------------------------------------------*/
#include <stdio.h>
#include <stdtypes.h>
#include "mc9s12dg256.h"

//#include <stdtypes.h>
#include "mc9s12dg256.h"
#include <stddef.h>
#include "SegDisp.h"
#include "Delay.h"


// Prototypes for internal functions
#define ONETENTH_MS  75 
int i =1;
int isrCounter = 10;
char chtr[4]= {0x77, 0x77,0x77,0x77};
  
//}; // array of size 4 for 4 display segments

/*---------------------------------------------
Function: initDisp
Description: initializes hardware for the 
             7-segment displays.
-----------------------------------------------*/
void initDisp(void) 
{
  TIOS_IOS1 = 1; //set CH2 as output 
  TIE_C1I = 0x01; // enable interrupts on ch2
  TC1 = TCNT + ONETENTH_MS;
  isrCounter = 15;
  
  DDRP = 0x0F; // set data direction of PTP for pin 0-3 as output
  DDRB = 0XFF; // Set data display for PORTB  as output for all PINS
  PUCR = 0x01;
  PTP = 0x0F; //0x0F; // Active 1 means segment is not selected
  PORTB = 0x3f;// set Segment value to nothing Through PORTB
  clearDisp();
}

/*---------------------------------------------
Function: clearDisp
Description: Clears all displays.
chtr is the character display array in hexadecimal
-----------------------------------------------*/
void clearDisp(void)
//set segment value array to null for all elements
{
  int i =0;
  while (i<4){
    chtr[i++] = 0X00;
  }
  //SHOW "C" in first seg_display
  PORTB = 0x39;//'portb=C // set port B to null (0000 0000)
  PTP = 0xfB; //reset Port P that no Segment selected

}

/*---------------------------------------------
Function: setCharDisplay
Description: Receives an ASCII character (ch)
             and translates
             it to the corresponding code to 
             display on 7-segment display.  Code
             is stored in appropriate element of
             codes for identified display (dispNum).
       Stores Values in chtr array as a hexadecimal
-----------------------------------------------*/
void setCharDisplay(char ch, byte dispNum) 
{    
  chtr[dispNum] = 0x00; //intialize character space to null
  switch (ch){ //check ch input for code
  case '0'://IF ch == 0
    chtr[(int) dispNum] = 0x3F; // set char to (0011 1111)
    break;
  case '1' : //IF ch = 1
    chtr[(int) dispNum] = 0x06; // set char to (0011 0001)
    break;
  case '2'://IF ch == 2
    chtr[(int) dispNum] = 0x5B; // set char to (0011 0010)
    break;
  case '3'://IF ch == 3
    chtr[(int) dispNum] = 0x4F; // set char to (0011 0011)
    break;
  case '4'://IF ch == 4
    chtr[(int) dispNum] = 0x66; // set char to (0011 0100)
    break;
  case '5'://IF ch == 5
    chtr[(int) dispNum] = 0x6D; // set char to (0011 0101)
    break;
  case '6'://IF ch == 6
    chtr[(int) dispNum] = 0x7D; // set char to (0011 0110)
    break;
  case '7'://IF ch == 7
    chtr[(int) dispNum] = 0x07; // set char to (0011 0111)
    break;
  case '8'://IF ch == 8
    chtr[(int) dispNum] = 0x7F; // set char to (0011 1000)
    break;
  case '9'://IF ch == 9
    chtr[(int) dispNum] = 0x6F; // set char to (0011 1001)
    break;
  case 'a'://IF ch == A
    chtr[(int) dispNum] = 0x77; // set char to (0100 0001)
    break;
  case 'b'://IF ch == B
    chtr[(int) dispNum] = 0x7c; // set char to (0100 0010)
    break;
  case 'c'://IF ch == C
    chtr[(int) dispNum] = 0x39; // set char to (0100 0011)
    break;
  case 'd'://IF ch == D
    chtr[(int) dispNum] = 0x5E; // set char to (0100 0101)
    break;
  case '*'://IF ch == *
    chtr[(int) dispNum] = 0x46; // set char to (0010 1010)
    break;
  case '#'://IF ch == #
    chtr[(int) dispNum] = 0x70; // set char to (0010 0011)
    break;
  case ' ' :// if ch = ' '
    chtr[(int) dispNum] = 0x00;
    break;
    
  }
}   

void interrupt VectorNumber_Vtimch1 tc1_isr(void){
  isrCounter--;
  if(isrCounter == 0){
    isrCounter = 10;
    //PTP = 0xF7;
    //PORTB = chtr[0];
      
    //SEG  = 0      1     2     3     
    // hex = 0xfe  0xfd  0xfb  0xf7
    
    if(/*PTP == 0xFE*/ i == 0){// if first segment is selected
      
      PORTB = chtr[0];
      PTP = 0x0E;
      i = 1;  
    } else if (/*PTP == 0xFD*/ i == 1){
      PORTB = chtr[1];
      PTP = 0x0D;
      i=2;
    }else if(/*PTP ==0xFB*/ i ==2){
      
      PORTB = chtr[2];
      PTP= 0x0B;
       i =3;
    } else  if (/*PTP == 0xF7*/ i==3){
      
      PORTB = chtr[3];
      PTP = 0x07;
      i = 0;
  
    } 
     
      TC1 = TC1+ ONETENTH_MS;
  }

}

