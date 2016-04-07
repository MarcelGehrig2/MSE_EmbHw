/*
 * interrupts.c
 *
 *  Created on: Mar 30, 2013
 *      Author: theo
 */
#include "sys/alt_irq.h"
#include "alt_types.h"
#include "system.h"
#include "io.h"
#include "camera.h"

unsigned int picture_count = 0;


static void DMA_camera_interrupt( void * context, alt_u32 id ) {
	IOWR_8DIRECT(CAMERA_BASE,4,1<<5); //ack camera IRQ
	picture_count++;
}


unsigned int get_picture_count() {
	return picture_count;
}

