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
 * @file dipswitch.h
 * @author Theo KLUTER
 * @author Andreas HABEGGER
 * @date Aug 24, 2015
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#ifndef DIPSWITCH_H_
#define DIPSWITCH_H_

#include <system.h>
#include <io.h>

#define DIPSW_SW8_MASK 128
#define DIPSW_SW7_MASK  64
#define DIPSW_SW6_MASK  32
#define DIPSW_SW5_MASK  16
#define DIPSW_SW4_MASK   8
#define DIPSW_SW3_MASK   4
#define DIPSW_SW2_MASK   2
#define DIPSW_SW1_MASK   1

unsigned char DIPSW_get_value();


#endif /* DIPSWITCH_H_ */
