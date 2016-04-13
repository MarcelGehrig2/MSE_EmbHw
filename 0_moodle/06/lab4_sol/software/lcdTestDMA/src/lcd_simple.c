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
 * @author Andreas HABEGGER
 * @date Aug 20, 2015
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#include "lcd_simple.h"

void LCD_Write_Command(int command)
{
	IOWR_16DIRECT(LCD_DMA_BASE,LCD_COMMAND_REG,command);
	usleep(10);
}

void LCD_Write_Data(int data)
{
	IOWR_16DIRECT(LCD_DMA_BASE,LCD_DATA_REG,data);
	usleep(10);
}


void init_lcd(void)
{
	IOWR_16DIRECT(LCD_DMA_BASE,LCD_CONTROL_REG,
			         LCD_Sixteen_Bit|LCD_Reset|
			         LCD_RGB565_Mode|LCD_Color_Image); // Set 16 bit transfer mode and

/*	IOWR_16DIRECT(LCD_CTRL_DMA_BASE,LCD_CONTROL_REG,
			        LCD_Sixteen_Bit|LCD_Reset); // Set 16 bit transfer mode and reset
	usleep(130);

	IOWR_16DIRECT(LCD_CTRL_DMA_BASE,LCD_CONTROL_REG,
					LCD_Sixteen_Bit); // set reset off and 16 bits mode and enable LED_CS
					*/
	usleep(130);

	LCD_Write_Command(0x0028); 	//display OFF
	LCD_Write_Command(0x0011); 	//exit SLEEP mode
	LCD_Write_Data(0x0000);

	LCD_Write_Command(0x00CB); 	//Power Control A
	LCD_Write_Data(0x0039); 	//always 0x39
	LCD_Write_Data(0x002C); 	//always 0x2C
	LCD_Write_Data(0x0000); 	//always 0x00
	LCD_Write_Data(0x0034); 	//Vcore = 1.6V
	LCD_Write_Data(0x0002); 	//DDVDH = 5.6V

	LCD_Write_Command(0x00CF); 	//Power Control B
	LCD_Write_Data(0x0000); 	//always 0x00
	LCD_Write_Data(0x0081); 	//PCEQ off
	LCD_Write_Data(0x0030); 	//ESD protection

	LCD_Write_Command(0x00E8); 	//Driver timing control A
	LCD_Write_Data(0x0085); 	//non - overlap
	LCD_Write_Data(0x0001); 	//EQ timing
	LCD_Write_Data(0x0079); 	//Pre-chargetiming
	LCD_Write_Command(0x00EA); 	//Driver timing control B
	LCD_Write_Data(0x0000);		//Gate driver timing
	LCD_Write_Data(0x0000);		//always 0x00
	LCD_Write_Data(0x0064);		//soft start 
	LCD_Write_Data(0x0003);		//power on sequence 
	LCD_Write_Data(0x0012);		//power on sequence 
	LCD_Write_Data(0x0081);		//DDVDH enhance on 

	LCD_Write_Command(0x00F7); 	//Pump ratio control 
	LCD_Write_Data(0x0020); 	//DDVDH=2xVCI 

	LCD_Write_Command(0x00C0);	//power control 1 
	LCD_Write_Data(0x0026);
	LCD_Write_Data(0x0004); 	//second parameter for ILI9340 (ignored by ILI9341) 

	LCD_Write_Command(0x00C1); 	//power control 2 
	LCD_Write_Data(0x0011);

	LCD_Write_Command(0x00C5); 	//VCOM control 1 
	LCD_Write_Data(0x0035);
	LCD_Write_Data(0x003E);

	LCD_Write_Command(0x00C7); 	//VCOM control 2 
	LCD_Write_Data(0x00BE);

	LCD_Write_Command(0x00B1); 	//frame rate control 
	LCD_Write_Data(0x0000);
	LCD_Write_Data(0x0010);

	LCD_Write_Command(0x003A);	//pixel format = 16 bit per pixel 
	LCD_Write_Data(0x0055);

	LCD_Write_Command(0x00B6); 	//display function control 
	LCD_Write_Data(0x000A);
	LCD_Write_Data(0x00A2);

	LCD_Write_Command(0x00F2); 	//3G Gamma control 
	LCD_Write_Data(0x0002);	 	//off 

	LCD_Write_Command(0x0026); 	//Gamma curve 3 
	LCD_Write_Data(0x0001);

	LCD_Write_Command(0x0036); 	//memory access control = BGR 
	LCD_Write_Data(0x0000);

	LCD_Write_Command(0x002A); 	//column address set 
	LCD_Write_Data(0x0000);
	LCD_Write_Data(0x0000);		//start 0x0000 
	LCD_Write_Data(0x0000);
	LCD_Write_Data(0x00EF);		//end 0x00EF 

	LCD_Write_Command(0x002B);	//page address set 
	LCD_Write_Data(0x0000);
	LCD_Write_Data(0x0000);		//start 0x0000 
	LCD_Write_Data(0x0001);
	LCD_Write_Data(0x003F);		//end 0x013F 
	IOWR_32DIRECT(LCD_DMA_BASE,LCD_NR_PIX_LINE_REG,240);

	LCD_Write_Command(0x0029);
}

void LCD_transfer(void* array, uint16_t width, uint16_t height)
{
	uint16_t *data_array = (uint16_t *)array;
	uint32_t pixels;
	LCD_Write_Command(0x002C); 	//command to begin writing to frame memory
	for (pixels = width*height ; pixels > 0 ; pixels--)
		LCD_Write_Data(data_array[pixels]);
}

void LCD_transfer_dma(void *array, uint16_t width, uint16_t height, bool noGrayConversion)
{
	uint16_t real_height = (height > IMAGE_MAX_HIGHT) ? IMAGE_MAX_HIGHT : height;
	uint16_t real_width = (width > IMAGE_MAX_WIDTH) ? IMAGE_MAX_WIDTH : width;
	IOWR_32DIRECT(LCD_DMA_BASE,LCD_Pict_width_reg,width);
	IOWR_32DIRECT(LCD_DMA_BASE,LCD_IMAGE_POINTER_REG,(uint32_t)array);
	IOWR_32DIRECT(LCD_DMA_BASE,LCD_IMAGE_SIZE_REG,real_width*real_height);
	if(true == noGrayConversion)
		IOWR_16DIRECT(LCD_DMA_BASE,LCD_CONTROL_REG,
				         LCD_Sixteen_Bit|LCD_Start_DMA|
				         LCD_RGB565_Mode|LCD_Color_Image);
	else
		IOWR_16DIRECT(LCD_DMA_BASE,LCD_CONTROL_REG,
				         LCD_Sixteen_Bit|LCD_Start_DMA|
				         LCD_RGB565_Mode|LCD_GrayScale_Image);
}
