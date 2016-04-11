vlib work
vmap work work

# Compile the DUT and the TB
# uncomment next line for testing your controller
	# vcom -2008 src_vhdl/LCD_ctrl.vhd  	
# comment next line for testing your controller
	vcom -2008 src_vhdl/LCD_fake.vhd	
	vcom -2008 src_tb/LCD_tb.vhd

vsim -t 100ps -novopt -GERRNO=1 -GFIFOSIZE=8 work.LCD_tb
add wave -r *
run -all
