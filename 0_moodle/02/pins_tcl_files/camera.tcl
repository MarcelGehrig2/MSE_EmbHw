# You have to replace <ENTITY_PORT_NAME_xxx> with the name of the Output port
# of your top entity
set_location_assignment PIN_T4  -to <ENTITY_PORT_NAME_CONNECTED_TO_SCL_CAM>
set_location_assignment PIN_P4  -to <ENTITY_PORT_NAME_CONNECTED_TO_SDATA_CAM>
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to <ENTITY_PORT_NAME_CONNECTED_TO_SCL_CAM>
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to <ENTITY_PORT_NAME_CONNECTED_TO_SDATA_CAM>

set_location_assignment PIN_V1  -to <ENTITY_PORT_NAME_CONNECTED_TO_MCLK>
set_location_assignment PIN_AA1  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_PWRDWN>
set_location_assignment PIN_P2  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_RSTB>
set_location_assignment PIN_Y2  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_D[0]>
set_location_assignment PIN_Y1  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_D[1]>
set_location_assignment PIN_P3  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_D[2]>
set_location_assignment PIN_V3  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_D[3]>
set_location_assignment PIN_M4  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_D[4]>
set_location_assignment PIN_V4  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_D[5]>
set_location_assignment PIN_R1  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_D[6]>
set_location_assignment PIN_U1  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_D[7]>
set_location_assignment PIN_R2  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_D[8]>
set_location_assignment PIN_U2  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_D[9]>
set_location_assignment PIN_T2  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_PCLK>
set_location_assignment PIN_W2  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_VSYNC>
set_location_assignment PIN_W1  -to <ENTITY_PORT_NAME_CONNECTED_TO_CAM_HSYNC>
