
/****************************************************************************
 * Copyright (C) 2016 by Andreas HABEGGER                                   *
 *                                                                          *
 * This file is part of TSM_EmbHardw (MSE) lab3 - lcd as avalon slave       *
 *                                                                          *
 *   lab1 ex is free software: you can redistribute it and/or modify it     *
 *   under the terms of the GNU Lesser General Public License as published  *
 *   by the Free Software Foundation, either version 3 of the License, or   *
 *   (at your option) any later version.                                    *
 *                                                                          *
 *                                                                          *
 *   You should have received a copy of the GNU Lesser General Public       *
 *   License along with MSE-SE. If not, see <http://www.gnu.org/licenses/>. *
 ****************************************************************************/
/**
 * @file pioTest.c
 * @author Andreas HABEGGER
 * @date Apr 5, 2016
 * @brief Introduction to Embedded Hardware System Engineering
 *
 *  The example shows how to use ISR and Timer. The timer is used with
 *  fixed period.
 *  Caution, there is no read back of ctrl Reg before writing new values.
 *  This can result in wrong behavior.
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo
 */

#include <stdio.h>
#include <stdbool.h>

#include "io.h"
#include "system.h"
#include "sys/alt_irq.h"
#include "priv/alt_legacy_irq.h"

#include "lcd_simple.h"
#include "tuxAnimation_1.h"
#include "tuxAnimation_2.h"
#include "tuxAnimation_3.h"

// simplify working with the Timer
#define TIMER_EN_IRQ    0x0001
#define TIMER_DIS_IRQ   0x0000
#define TIMER_STOP      0x0008
#define TIMER_START     0x0004
#define TIMER_CLEAR_IRQ 0x0000

#define TIMER_REG_STATUS       0
#define TIMER_REG_CTRL         1
#define TIMER_REG_PERIOD_LOW   2
#define TIMER_REG_PERIOD_HIGH  3

// counter structure
typedef struct _IRQcounter{
	int count;
	bool irq;
}IRQcounter;

// function prototypes

static int TIMER_init(void* context, alt_isr_func handler);

static void timer_interrupt_handler(void *context, alt_u32 id);

static int PIO_init(void);

static int LED_init(void);

static void task1(IRQcounter *counter);

static void task2(void);

static void task3(void);

static void task4(void);


int main(void)
{
	// counter
	IRQcounter counter;
	counter.count = 0;
	counter.irq   = false;

	// initialize the timer
	TIMER_init(&counter, (alt_isr_func)timer_interrupt_handler);

	// initialize simple PIO
	PIO_init();

	// initialize LED interface
	LED_init();
	// initialize the LCD display
	LCD_init();

	// Start the timer
	puts("Enable Timer IRQ and start Timer ...");

	IOWR_16DIRECT(SYS_TIMER_BASE, TIMER_REG_CTRL,
			TIMER_EN_IRQ | TIMER_START); // Enable IRQ + Start timer

	printf("Timer Started initialize \n");

	while(1)
	{

		task1(&counter);

		task2();

		task3();

		task4();
	}
}

static void task1(IRQcounter *counter)
{
	puts("Enter Task 1");
	if(counter->irq)
	{
		printf("counter value is = %d \n",counter->count);
		// led IF count (lab1)
		IOWR_16DIRECT(LEDS_BASE,0, counter->count);

		counter->irq = false;
	}
}

static void task2(void)
{
	puts("Enter Task 2");
	LCD_transfer(&picture_array_tuxAnimation_1, picture_height_tuxAnimation_1, picture_width_tuxAnimation_1);
	puts("Img Tux 1 transfered");
}


static void task3(void)
{
	puts("Enter Task 3");
	LCD_transfer(&picture_array_tuxAnimation_2, picture_height_tuxAnimation_2, picture_width_tuxAnimation_2);
	puts("Img Tux 2 transfered");
}

static void task4(void)
{
	puts("Enter Task 4");
	LCD_transfer(&picture_array_tuxAnimation_3, picture_height_tuxAnimation_3, picture_width_tuxAnimation_3);
	puts("Img Tux 3 transfered");
}

static void timer_interrupt_handler(void *context, alt_u32 id)
{
	IRQcounter *ctr_ptr = (IRQcounter*) context;
	ctr_ptr->count++; // increase the counter;
	ctr_ptr->irq = true;

	// simplePIO IF count (lab2)
	IOWR_8DIRECT(SIMPLEPIO_BASE,2, ctr_ptr->count);

	IOWR_16DIRECT(SYS_TIMER_BASE, TIMER_REG_STATUS, TIMER_CLEAR_IRQ);

	return;
}


static int TIMER_init(void* context, alt_isr_func handler)
{
	puts("initialize Timer interface...");
	alt_irq_context statusISR;

	statusISR = alt_irq_disable_all();

	IOWR_16DIRECT(SYS_TIMER_BASE, TIMER_REG_CTRL,
			TIMER_DIS_IRQ | TIMER_STOP); // activate IRQ + Stop timer

	puts("Register IRQ handler ...");
	alt_irq_register(SYS_TIMER_IRQ, context, handler);

	alt_irq_enable_all(statusISR);

	return 0;
}

static int PIO_init(void)
{
	puts("initialize simplePIO interface...");
	IOWR_8DIRECT(SIMPLEPIO_BASE, 0, 0xFF);
	IOWR_8DIRECT(SIMPLEPIO_BASE, 2, 0x0);
	return 0;
}

static int LED_init(void)
{
	puts("initialize LED interface...");
	IOWR_8DIRECT(LEDS_BASE,0,0);
	return 0;
}
