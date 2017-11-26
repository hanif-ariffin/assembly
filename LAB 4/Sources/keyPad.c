#include "mc9s12dg256.h"
#include <stddef.h>
#include "keyPad.h"

#define ONETENTH_MS 75

int isr_counter = 100;
int key_pressed = 0;

char temp_key;
char key_val;
char asciiVal;

int key_ready = 0;
int poll_key = 0;

char portACodes[16] = {
  0b11101110, 0b11101101, 0b11101011, 0b11100111,
  0b11011110, 0b11011101, 0b11011011, 0b11010111,
  0b10111110, 0b10111101, 0b10111011, 0b10110111,
  0b01111110, 0b01111101, 0b01111011, 0b01110111
};
char asciiCharArr[16] = {
  '1', '2', '3', 'a',
  '4', '5', '6', 'b',
  '7', '8', '9', 'c',
  '*', '0', '#', 'd'
};
int stage = 0;


void initKeyPad(void) {

  TIOS_IOS3 = 1; //set ch3 as output
  TIE_C3I = 0x01; //enable interrupts on ch3
  TC3 = TCNT + ONETENTH_MS; //set ch3 to timer val + 0.1
  isr_counter = 100; // set counter to 100 for (0.1 X 100 = 10ms) delay
  PUCR = 0x01; // pull-up resistors for port A enabled
  DDRA = 0xF0;//ddra to F0 to set most sig bits to outputs

}

char pollReadKey(void) {
  poll_key = 1;
  return readKey();
}

char readKey(void) {
  char asciiVal = 0x00;
  key_pressed = 1;
  do {
    if (key_pressed == 1) {
      asciiVal = key_val;
      key_val = 0;
      key_pressed = 0;
    }
  } while ((key_ready != 1) && (poll_key != 1));

  poll_key = 0;
  key_ready = 0;
  return asciiVal;
}


char translateCode(void) {
  char valFound;
//  int row, col;
  int i = 0;
  for (i = 0; i < 16; i++) {
    PORTA = 0b11111111;
    if ((i / 4) == 0 ) {
      PORTA = 0b11100000;

    }
    else if ((i / 4) == 1) {
      PORTA = 0b11010000;

    }
    else if ((i / 4) == 2) {
      PORTA = 0b10110000;

    }
    else if ((i / 4) == 3) {
      PORTA = 0b01110000;

    }

    valFound = PORTA;
    if (valFound == portACodes[i]) {
      return (asciiCharArr[i]);
    }
  }
  return 0x0f;
}


void interrupt VectorNumber_Vtimch3 tc3_isr(void) {
  isr_counter--;
  if (isr_counter == 0)
  {
    isr_counter = 100;
    if (stage == 0)
    {
      if (translateCode() != 0x0f) {
        stage = 1;//intialy 1
        temp_key = translateCode();

      }
    } else if (stage == 1) {
      if (translateCode() == temp_key) {
        stage = 2;
      } else {
        stage = 0;
      }
    } else if (stage == 2) {
      if (translateCode() == 0x0f) {
        stage = 3;
        key_val = temp_key;
      }
    } else if (stage == 3) {
      stage = 0;
      poll_key = 1;
      key_ready = 1;
      key_pressed = 1;

    }
  }
  TC3 = TC3 + ONETENTH_MS;

}
