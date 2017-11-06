/*-------------------------------------------------------------
 * File:  keypad.c  - Alarm System Module
 * Description: The design of the assembler code is achieved using
 *              a C program.  This program is designed to create a
 *              Alarm System on the Dragon 12 Trainer card (i.e.
 *              the HCS12 Microcontroller).  The main objective of this
 *              program is to explore programming of the HC12 CPU.
-----------------------------------------------------------------*/
//include goes here//

//End of Include //

/*--------------Global Data Structures--------------------------*/
// The following data structures need not be located in RAM - They are 
// readonly


/*----------------------------------------
* Function: initKeyPad
* Parameters: none
* Returns: nothing
* Description: Initialises PORT A
*----------------------------------------*/
void initKeyPad()
{
   DDRA = 240;
   PUCR = 1;
}

/*----------------------------------------
* Function: pollReadKey
* Parameters: none
* Returns: 
         ch : NOKEY when no key pressed
         othersie, ASCII Code
* Description : Loops for a period of 2ms, checking to see if
* key is pressed. Calls readKey to read key if keypress 
* detected (and debounced) on Port A and get ASCII code for
* key pressed.
*----------------------------------------*/

#define NOKEY 0x0;
#define POLLCOUNT 0x1;

char pollReadKey()         // TAK CONFIRM
{
   char ch;
   int count;

   ch = NOKEY;
   count = POLLCOUNT;

   PORTA = 0x0F;
   do{

      if (PORTA != 0x0F)
      {
      delayms(1);

         if(PORTA != 0x0F)
         {
            ch = readKey();
            break
         }
      } 
      count--;
   }while(count != 0);

   return(ch);
}


/*----------------------------------------
* Function: readKey
* Parameters: none
* Returns: 
         ch : NOKEY when no key pressed
         othersie, ASCII Code
*  Description : Main subroutine that reads a code from the
*  keyboard using the subroutine readKeyCode.  The
*  code is then translated with the subroutine
*  translate to get the corresponding ASCII code.
*----------------------------------------*/

char readKey(){

   char ch;             // CHECK BALIK
   int code;

   do{

      PORTA = 0x0F;

      while (PORTA == 0x0F){}

         code = PORTA;
         delayms(10);

   } while(code != PORTA);

   code = keyPress();
   PORTA = 0x0F;

   while (PORTA != 0x0F){}

   delayms(10);

   ch = translate(code);

   return(ch)

}



/*----------------------------------------
* Function: keyPress
* Parameters: none
* Returns: 
         
*  Description : 

*----------------------------------------*/
char keyPress()
{

   char key;

   PORTA = ROW1;          

   if(PORTA == ROW1)
   {
      PORTA = ROW2
      if (PORTA == ROW2)
      {
         PORTA = ROW3;
         if(PORTA == ROW3){
            PORTA = ROW4;
         }
      }

   }

   key = PORTA;

   return(key);
}



/*----------------------------------------
* Function: translate
* Parameters: code
* Returns: 
         ch - ASCII code
*  Description : Translates the code by using the conversion table
*  searching for the code.  If not found, then BADCODE
*  is returned.
*----------------------------------------*/


char translate(int *code){

   int checker[16];
   checker[0] = 11101110;
   checker[1] = 11101101;
   checker[2] = 11101011
   checker[3] = 11100111;
   checker[4] = 11011110;
   checker[5] = 11011101;
   checker[6] = 11011011;
   checker[7] = 11010111;
   checker[8] = 10111110;
   checker[9] = 10111101;
   checker[10] = 10111011;
   checker[11] = 10110111;
   checker[12] = 01111110;
   checker[13] = 01111101;
   checker[14] = 01111011;
   checker[15] = 01110111;

   char value[16];
   value[0] = '1';
   value[1] = '2';
   value[2] = '3';
   value[3] = 'a';
   value[4] = '4';
   value[5] = '5';
   value[6] = '6';
   value[7] = 'b';
   value[8] = '7';
   value[9] = '8';
   value[10] = '9';
   value[11] = 'c';
   value[12] = '*';
   value[13] = '0';
   value[14] = '#';
   value[15] = 'd';


   int counter1;
   int counter2;
   counter1 = 0;
   counter2 = 0;

   char ch;
   ch = BADCODE;

   do{
      if(*code == checker[counter])
      {
         ch = value[counter2];
         break
      }
      else
      {
         counter1++;
         counter2++;
      }
   } while counter1 < 16

   return(ch);
}