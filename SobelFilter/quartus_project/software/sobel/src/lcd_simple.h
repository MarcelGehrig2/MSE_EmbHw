/****************************************************************************
 * Copyright (C) 2016 by Theo Kluter                                        *
 *                                                                          *
 * This file is part of TSM_EmbHardw (MSE) sobel exercise                   *
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
 *   License along with MSE-SE. If not, see <http://www.gnu.org/licenses/>. *
 ****************************************************************************/
/**
 * @file lcd_simple.c
 * @author Theo KLUTER
 * @author Andreas HABEGGER
 * @date Aug 20, 2015
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#ifndef LCD_SIMPLE_H_
#define LCD_SIMPLE_H_


#include "system.h"
#include "io.h"
#include "time.h"
#include "unistd.h"

#define LCD_COMMAND_REG 0
#define LCD_DATA_REG 4
#define LCD_CONTROL_REG 8
#define LCD_IMAGE_POINTER_REG 12
#define LCD_IMAGE_SIZE_REG 16
#define LCD_NR_PIX_LINE_REG 20
#define LCD_Pict_width_reg 24

#define LCD_Sixteen_Bit 0
#define LCD_Eight_Bit 1
#define LCD_Reset 2
#define LCD_RGB565_Mode 0
#define LCD_RGB888_Mode (1<<3)
#define LCD_Color_Image 0
#define LCD_GrayScale_Image (1<<4)
#define LCD_IRQ_Disabled 0
#define LCD_IRQ_Enabled (1<<5)
#define LCD_Start_DMA (1<<8)
#define LCD_Clear_IRQ (1<<9)

void init_LCD();

void LCD_Write_Command(int command);

void LCD_Write_Data(int data);

void transfer_LCD_no_dma( void* array,
		                  int width,
		                  int height);

void transfer_LCD_with_dma(void *array,
		                   int width,
		                   int height,
		                   char grayscale);



#endif /* LCD_SIMPLE_H_ */
