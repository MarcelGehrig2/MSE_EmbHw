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
 *   SMS is distributed in the hope that it will be useful, to students     *
 *   following the course BTF1230 at Bern University but WITHOUT ANY        *
 *   WARRANTY. See the GNU Lesser General Public License for more details.  *
 *                                                                          *
 *   You should have received a copy of the GNU Lesser General Public       *
 *   License along with MSE-SE. If not, see <http://www.gnu.org/licenses/>. *
 ****************************************************************************/
/**
 * @file lcd_simple.c
 * @author Andreas HABEGGER
 * @date Apr 5, 2016
 * @brief Introduction to Embedded Hardware System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo
 */

#ifndef LCD_SIMPLE_H_
#define LCD_SIMPLE_H_

#include <stdint.h>

#include "time.h"
#include "unistd.h"
#include "system.h"
#include "io.h"

#define LCD_COMMAND_REG 0
#define LCD_DATA_REG 4
#define LCD_CONTROL_REG 8

#define LCD_Sixteen_Bit 0
#define LCD_Eight_Bit 1
#define LCD_Reset 2

void LCD_init(void);

void LCD_Write_Command(uint16_t command);

void LCD_Write_Data(uint16_t data);

void LCD_transfer( void* array, uint16_t width, uint16_t height);

#endif /* LCD_SIMPLE_H_ */
