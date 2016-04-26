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
 *   You should have received a copy of the GNU Lesser General Public       *
 *   License along with MSE-SE. If not, see <http://www.gnu.org/licenses/>. *
 ****************************************************************************/
/**
 * @file camera.h
 * @author Andreas HABEGGER
 * @date Apr 13, 2016
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#ifndef CAMERA_H_
#define CAMERA_H_

#include <system.h>
#include <io.h>
#include <stdio.h>
#include "i2c.h"


#define CAM_BYTES_EACH_LINE_REG 0
#define CAM_LINES_EACH_FRAME_REG 4
#define CAM_FRAME_RATE_REG 8
#define CAM_CONTROL_REG 12
#define CAM_ADDR_PNTR_1 16
#define CAM_ADDR_PNTR_2 20
#define CAM_ADDR_PNTR_3 24
#define CAM_ADDR_PNTR_4 28

#define CAM_Reset 1
#define CAM_PWR_DWN 2
#define CAM_Profile_valid 4
#define CAM_Take_Picture 8
#define CAM_Busy 8
#define CAM_Start_Continues 16
#define CAM_In_Continues_mode 16
#define CAM_Stop_Continues 32
#define CAM_Enable_IRQ 64
#define CAM_IRQ_Enabled 64
#define CAM_Disable_IRQ 128
#define CAM_IRQ_Generated 128
#define CAM_Clear_IRQ 256
#define CAM_Current_Image_Valid 512

#define CAM_I2C_ID 0x78

#define REG_MT9D112_MCU_BOOT 0x3386
#define REG_MT9D112_SENSOR_RESET 0x301A
#define REG_MT9D112_STANDBY_CONTROL 0x3202
#define REG_MT9D112_PLL_CLK_IN_CONTROL 0x341E
#define REG_MT9D112_PLL_DIVIDERS_1 0x341C


void init_camera();

void cam_get_profiling();

void cam_set_image_pointer(char pointer_id,
		                   void *memory_pointer);
short current_image_valid();

void *current_image_pointer();

void take_picture_blocking();

void enable_continues_mode();

char new_image_available();

unsigned short cam_get_xsize();

unsigned short cam_get_ysize();

#endif /* CAMERA_H_ */
