/*
 * camera.h
 *
 *  Created on: Dec 4, 2014
 *      Author: theo
 */

#ifndef CAMERA_H_
#define CAMERA_IMAGE_SIZE_BYTES (320*240*3)
#define CAMERA_IMAGE_SIZE_INT (CAMERA_IMAGE_SIZE_BYTES>>2)
void init_camera();
void camera_mode();
void camera_cont_mode_2buf();
void camera_cont_mode_4buf();
void camera_stop_cont_mode();
int get_picture_addr();
#define CAMERA_H_




#endif /* CAMERA_H_ */
