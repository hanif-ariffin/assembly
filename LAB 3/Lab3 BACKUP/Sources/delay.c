/*-------------------------------------------------------------
 * File:  delay.c  - Alarm System Module
 * Description: 


-----------------------------------------------------------------*/
/*
Global variables
*/
short delayCount;

/*------------------------------------
 * Function: setDelay
 * Return : nothing
 * Description: Intialises the delayCount 
 *              variable.
 *
 * --------------------------------*/

void setDelay(short delay){
   delayCount = delay;
}


/*------------------------------------
 * Function: pollDelay
 * Return : TRUE when delay counter reaches 0 - in accumulator A
 * Description: Create 1ms based on delayCount
 *
 * --------------------------------*/

bool pollDelay(){

   bool retVal = FALSE;

   short cntr = 3000;
   short delay = delayCount;

   do{
      (void)0;
      (void)0;
      (void)0;
      (void)0;
      cntr--;
   } while(cntr != 0);

   delay--;

   if(delayCount == 0){
      retVal = TRUE;
   }

   delayCount = delay;
   return(retVal);

}

/*------------------------------------
 * Function: delayms
 * Return : nothing
 * Description: Intialises the delayCount 
 *              variable provided by the keypad
 *
 * --------------------------------*/

void delayms(short value){
   delayCount = value;

   while(pollDelay() != TRUE){}

}