void initKeyPad()
{
	*PUCR = 1;
}

/**
	Current implementation of readKey does NOT check if the key is consistent.
	It does NOT guarantee that the key press before and after 2ms are the same key,
	only that it is non-zero.
	**/
char readKey()
{
	/**
	Should the be the value of 0 in ASCII.
	Later we will increment this and it will go to 1,2,3.... and proceeds to A,B,C...
	**/
	char a = 0xF0;
	char column_mask = 0xFE;
	for (int column = 0; column < 4; column++)
	{
		char row_mask = 0xEF;
		for (int row = 0; row  < 4 ; row++)
		{
			/**
			Check if the column is correct
			**/
			if (!(*PORTA & column_mask))
			{
				/**
				Check if the row is correct
				**/
				if (!(*PORTA & row_mask))
				{
					delayms(2); //delay for 2ms to make sure we are exceeding possible debouncing
					if (!(*PORTA & column_mask))
					{
						/**
						Check if the row is correct
						**/
						if (!(*PORTA & row_mask))
						{
							/**
							Means that we have hit the correct coordinate
							**/
							return a;
						}
					}
				}
				row_mask = row_mask << 1; //Rotate shift left
			}

			column_mask = column_mask << 1; //Rotate shift left
			a++;
		}
	}
	return 0;
}

char pollReadKey() {
	*DDR = 0xF0;
	int a = 10;
	while (a-- != 0)
	{
		char key_code = readKey();
		if (key_code != 0)
		{
			return key_code;
		}
	}
	return key_code;
}

void delayms(int num)
{
	while (num-- != 0)
	{
		pollDelay();
	}
}