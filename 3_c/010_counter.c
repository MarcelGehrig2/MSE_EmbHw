/****************************************************************************
 * Copyright (C) 2016 by Andreas Habegger                                   *
 *                                                                          *
 * This file is part of TSM_EmbHardw (MSE) lab exercise 1                   *
 *                                                                          *
 *   lab1 ex is free software: you can redistribute it and/or modify it     *
 *   under the terms of the GNU Lesser General Public License as published  *
 *   by the Free Software Foundation, either version 3 of the License, or   *
 *   (at your option) any later version.                                    *
 *                                                                          *
 *   SMS is distributed in the hope that it will be useful, to students     *
 *   following the course BTF1230 at Bern University but WITHOUT ANY        *
 *   WARRANTY. See the GNU Lesser General Public License for more details.  *
 *                                                                          *
 *   You should have received a copy of the GNU Lesser General Public       *
 *   License along with lab1 ex. If not, see <http://www.gnu.org/licenses/>.*
 ****************************************************************************/
/**
 * @file counter.c
 * @author Andreas HABEGGER
 * @date 26 Jan 2016
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#include <stdio.h>
#include "io.h"
#include "system.h"

#define DELAY 1000000

int main(void)
{
	int counter = 0;
	unsigned int wait;

	printf("Lets start counting \n");
	IOWR_8DIRECT(LEDS_BASE,0,0);

	while(1)
	{ counter ++;
	  printf("counter = %d \n",counter);
	  IOWR_8DIRECT(LEDS_BASE,0,counter);
	  // silly busy wait
	  for(wait = 0; wait < DELAY; wait++)
              asm volatile ("nop");
	}

}
