
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
#include <stdint.h>

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
	uint32_t count;
	bool newCount;
}IRQcounter;

// lcd structure
typedef struct _IRQlcd{
	void* picture;
	bool newPicture;
}IRQlcd;

// function prototypes
static void timer_interrupt_handler(void *context, alt_u32 id);

static void lcd_interrupt_handler(void *context, alt_u32 id);

static void init_lcd_irq(void* context, alt_isr_func handler);

static int init_timer(void* context, alt_isr_func handler);

static int init_simplePIO(void);

static int init_led(void);

static void task1(IRQcounter *counter);

static void task2(IRQlcd *lcd);

static void task3(void);

static void task4(void);


int main(void)
{
	// img reference ring
	void* pictureRef[] = {&picture_array_tuxAnimation_1, &picture_array_tuxAnimation_2, &picture_array_tuxAnimation_3};

	// counter
	IRQcounter counter;
	counter.count = 0;
	counter.newCount   = false;

	IRQlcd lcd;
	lcd.picture    = NULL;
	lcd.newPicture = false;

	alt_irq_context statusISR;

	statusISR = alt_irq_disable_all();
	// initialize simple PIO
	init_simplePIO();

	// initialize LED interface
	init_led();

	// initialize the LCD display
	init_lcd();

	alt_irq_enable_all(statusISR);

	// initialize the timer
	init_timer(&counter, (alt_isr_func)timer_interrupt_handler);

	// add lcd dma ctrl irq
//	init_lcd_irq(&lcd, (alt_isr_func)lcd_interrupt_handler);

	// Start the timer
	puts("Enable Timer IRQ and start Timer ...");

	IOWR_16DIRECT(SYS_TIMER_BASE, TIMER_REG_CTRL,
			TIMER_EN_IRQ | TIMER_START); // Enable IRQ + Start timer

//	puts("Enable LCD CTRL IRQ ...");
//	IOWR_16DIRECT(LCD_CTRL_DMA_BASE, LCD_CONTROL_REG, LCD_IRQ_Enabled);

	lcd.newPicture = true;


	while(1)
	{

		if(counter.newCount)
			task1(&counter);

		if(lcd.newPicture){
			lcd.newPicture = false;
			LCD_transfer_dma(&picture_array_tuxAnimation_2, picture_width_tuxAnimation_2, picture_height_tuxAnimation_2, true);
//			lcd.picture = pictureRef[0];
//			task2(&lcd);
//			pictureRef[0] = pictureRef[1];
//			pictureRef[1] = pictureRef[2];
//			pictureRef[2] = lcd.picture;

		}

//		if(counter.newCount)
//			task1(&counter);

//		task3();
//		if(counter.newCount)
//			task1(&counter);

//		task4();

	}
}

static void task1(IRQcounter *counter)
{
	puts("Enter Task 1");
	if(counter->newCount)
	{
		printf("counter value is = %u \n",(unsigned int)counter->count);
		// led IF count (lab1)
		IOWR_16DIRECT(LEDS_BASE,0, counter->count);

		counter->newCount = false;
	}
}

static void task2(IRQlcd *lcd)
{
	puts("Enter Task 2");
	if(lcd->newPicture)
	{
		LCD_transfer(&lcd->picture, 320, 240);
		lcd->newPicture = false;
	}
	puts("Img Tux 1 transfered");
}


static void task3(void)
{
	puts("Enter Task 3");
	LCD_transfer_dma(&picture_array_tuxAnimation_2, picture_height_tuxAnimation_2, picture_width_tuxAnimation_2, true);
	puts("Img Tux 2 transfered");
}

static void task4(void)
{
	puts("Enter Task 4");
	LCD_transfer_dma(&picture_array_tuxAnimation_3, picture_height_tuxAnimation_3, picture_width_tuxAnimation_3, true);
	puts("Img Tux 3 transfered");
}

static void timer_interrupt_handler(void *context, alt_u32 id)
{
	IRQcounter *ctr_ptr = (IRQcounter*) context;
	ctr_ptr->count++; // increase the counter;
	ctr_ptr->newCount = true;

	// simplePIO IF count (lab2)
	IOWR_8DIRECT(SIMPLEPIO_BASE,2, ctr_ptr->count);

	IOWR_16DIRECT(SYS_TIMER_BASE, TIMER_REG_STATUS, TIMER_CLEAR_IRQ);

	return;
}

static void lcd_interrupt_handler(void *context, alt_u32 id)
{
	IRQlcd *lcd_ptr = (IRQlcd*) context;
	lcd_ptr->picture = NULL; // increase the counter;
	lcd_ptr->newPicture = true;

	IOWR_16DIRECT(LCD_DMA_BASE, LCD_CONTROL_REG, LCD_Clear_IRQ);

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

static void init_lcd_irq(void* context, alt_isr_func handler)
{
	puts("initialize LCD IRQ interface...");
	alt_irq_context statusISR;

	statusISR = alt_irq_disable_all();

	IOWR_16DIRECT(LCD_DMA_BASE, LCD_CONTROL_REG, LCD_IRQ_Disabled);

	puts("Register IRQ handler ...");
	alt_irq_register(LCD_DMA_IRQ, context, handler);

	alt_irq_enable_all(statusISR);
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
