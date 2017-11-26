#include "mc9s12dg256.h"
#include <stddef.h>
#include "siren.h"

#define PULSE1  2250   // 225 * 1 1/3 = 300 micro-second
#define SEP1    5250   // 525 * 1 1/3 = 700 micro-second	
#define PULSE2  5250	  // 700 micro-second
#define SEP2    2250   // 300 micro-second
int next_delay;
int delay_arry[] = {PULSE1, SEP1, PULSE2, SEP2};



#define ONETENTH_MS  75
int siren_state;
int siren_counter = 525;

void initSiren (void) {
	TIOS_IOS5 = 1; //set CH5 as output-compare
	TIE_C5I = 0x01; //enable interrupts on ch5
	TCTL1 |= 0b00001000; //CH 5 set to toggle 1/2
	TCTL1 &= 0b11110111; //CH 5 set to toggle 2/2
	TC5 = TCNT + ONETENTH_MS; //delay_arry[0];
	next_delay = 1;
	siren_counter = 525;
	turnOffSiren();
}

void turnOnSiren(void)
{
	TCTL1 |= 0b00000100;  // CH 5 set to toggle 1/2
	TCTL1 &= 0b11110111;  // CH 5 set to toggle 2/2
	asm bset TIE, 0b00100000; // Enable channel 5 timer interrupt
	siren_state = 0; //set siren state to on
}

void turnOffSiren(void)
{
	TCTL1 |= 0b00001000;  
	TCTL1 &= 0b11111011;  // CH 5 set to zero
	CFORC = 0b00100000;   // Force the 5V on the pin

	asm bclr TIE, 0b00100000; // Disable CH 5 timer interrupt
	siren_state = 1; //set siren state to off
}

void interrupt VectorNumber_Vtimch5 tc5_isr(void) {
	siren_counter--;
	if (siren_counter == 0) 
	{
		if (siren_state == 1) 
		{
			turnOnSiren();
		} else if (siren_state == 0 ) 
		{
			turnOffSiren();
		}
		siren_counter = delay_arry[next_delay];
		next_delay = (next_delay + 1) % 4;
	}	TC5 = TC5 + ONETENTH_MS;
}