/****************************************************************************
 * Copyright (C) 2016 by Andreas HABEGGER                                   *
 *                                                                          *
 * This file is part of TSM_EmbHardw (MSE) lab2 - simplePIO and Timer       *
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
 * @date Aug 24, 2015
 * @brief Introduction to Embedded Hardware System Engineering
 *
 *  The example shows how to use ISR and Timer. The timer is used with
 *  fixed period.
 *  Caution, there is no read back of ctrl Reg before writing new values.
 *  This can result in wrong behavior.
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo Read control Reg back and mask before write back.
 */

#include <stdio.h>
#include <stdbool.h>

#include "io.h"
#include "system.h"
#include "sys/alt_irq.h"
#include "priv/alt_legacy_irq.h"

// simplify working with the Timer
#define TIMER_EN_IRQ    0x0001
#define TIMER_DIS_IRQ   0x0000
#define TIMER_STOP      0x0008
#define TIMER_START     0x0004
#define TIMER_CLEAR_IRQ 0x0000

#define TIMER_REG_STATUS       0x00
#define TIMER_REG_CTRL         0x01
#define TIMER_REG_PERIOD_LOW   0x02
#define TIMER_REG_PERIOD_HIGH  0x03

// function prototypes
static void timer_interrupt_handler(void *context, alt_u32 id);

static int init_timer(void* context, alt_isr_func handler);

static int init_simplePIO(void);

static int init_led(void);

// counter structure
typedef struct _IRQcounter{
	int count;
	bool irq;
}IRQcounter;


int main(void)
{
	// counter
	IRQcounter counter;
	counter.count = 0;
	counter.irq   = false;

	// initialize the timer
	init_timer(&counter, (alt_isr_func)timer_interrupt_handler);

	// initialize simple PIO
	init_simplePIO();

	// initialize LED interface
	init_led();

	// Start the timer
	puts("Enable Timer IRQ and start Timer ...");

	IOWR_16DIRECT(SYS_TIMER_BASE, TIMER_REG_CTRL,
			TIMER_EN_IRQ | TIMER_START); // Enable IRQ + Start timer

	printf("Timer Started initialize \n");

	while(1)
	{
		if(counter.irq)
		{
			printf("counter value is = %d \n",counter.count);
			// led IF count (lab1)
			IOWR_16DIRECT(LEDS_BASE,0, counter.count);
			// simplePIO IF count (lab2)
			IOWR_8DIRECT(SIMPLEPIO_BASE,2, counter.count);
			counter.irq = false;
		}
	}
}


static void timer_interrupt_handler(void *context, alt_u32 id)
{
	IRQcounter *ctr_ptr = (IRQcounter*) context;
	ctr_ptr->count++; // increase the counter;
	ctr_ptr->irq = true;

	IOWR_16DIRECT(SYS_TIMER_BASE, TIMER_REG_STATUS, TIMER_CLEAR_IRQ);

	return;
}


static int init_timer(void* context, alt_isr_func handler)
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

static int init_simplePIO(void)
{
	puts("initialize simplePIO interface...");
	IOWR_8DIRECT(SIMPLEPIO_BASE, 0, 0xFF);
	IOWR_8DIRECT(SIMPLEPIO_BASE, 2, 0x0);
	return 0;
}

static int init_led(void)
{
	puts("initialize LED interface...");
	IOWR_8DIRECT(LEDS_BASE,0,0);
	return 0;
}

