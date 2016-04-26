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
 * @file vga.h
 * @author Theo KLUTER
 * @author Andreas HABEGGER
 * @date Aug 25, 2015
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#ifndef VGA_H_
#define VGA_H_

#include <system.h>
#include <io.h>

#define VGA_RED_BLUE_SWAP 1
#define VGA_TEST_SCREEN 2
#define VGA_FLIP_X 4
#define VGA_QuarterScreen 8
#define VGA_Grayscale 16

void vga_set_pointer( void* image );

void vga_set_swap(char swap);

#endif /* VGA_H_ */
