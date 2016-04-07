onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Global Signals}
add wave -noupdate /lcd_controller_tb/clk_s
add wave -noupdate /lcd_controller_tb/reset_s
add wave -noupdate -divider {Avalon Master}
add wave -noupdate -radix hexadecimal /lcd_controller_tb/avm_address_s
add wave -noupdate /lcd_controller_tb/avm_read_s
add wave -noupdate -radix hexadecimal /lcd_controller_tb/avm_readdata_s
add wave -noupdate /lcd_controller_tb/avm_waitrequest_s
add wave -noupdate -divider IRQ
add wave -noupdate /lcd_controller_tb/end_of_transaction_irq_s
add wave -noupdate -divider {Avalon Slave}
add wave -noupdate -radix hexadecimal /lcd_controller_tb/avs_address_s
add wave -noupdate /lcd_controller_tb/avs_cs_s
add wave -noupdate /lcd_controller_tb/avs_read_s
add wave -noupdate -radix hexadecimal /lcd_controller_tb/avs_readdata_s
add wave -noupdate /lcd_controller_tb/avs_write_s
add wave -noupdate -radix hexadecimal /lcd_controller_tb/avs_writedata_s
add wave -noupdate -divider {LCD Parallel Bus}
add wave -noupdate -radix hexadecimal /lcd_controller_tb/lcd_data_s
add wave -noupdate /lcd_controller_tb/lcd_cs_n_s
add wave -noupdate /lcd_controller_tb/lcd_wr_n_s
add wave -noupdate /lcd_controller_tb/lcd_d_c_n_s
add wave -noupdate -divider {Internal Register}
add wave -noupdate -radix hexadecimal /lcd_controller_tb/lcd_controller_component/LCD_data_reg
add wave -noupdate -radix hexadecimal /lcd_controller_tb/lcd_controller_component/address_reg
add wave -noupdate /lcd_controller_tb/lcd_controller_component/LCD_direct
add wave -noupdate /lcd_controller_tb/lcd_controller_component/base_image_pointer_en
add wave -noupdate -radix hexadecimal /lcd_controller_tb/lcd_controller_component/base_image_pointer
add wave -noupdate -radix hexadecimal /lcd_controller_tb/lcd_controller_component/size_image
add wave -noupdate -radix hexadecimal /lcd_controller_tb/lcd_controller_component/image_pointer
add wave -noupdate /lcd_controller_tb/lcd_controller_component/start
add wave -noupdate /lcd_controller_tb/lcd_controller_component/master_read_s
add wave -noupdate /lcd_controller_tb/lcd_controller_component/IRQ_clr
add wave -noupdate /lcd_controller_tb/lcd_controller_component/size_image_en
add wave -noupdate /lcd_controller_tb/lcd_controller_component/run
add wave -noupdate /lcd_controller_tb/lcd_controller_component/master_read_en
add wave -noupdate /lcd_controller_tb/lcd_controller_component/master_data_valid
add wave -noupdate /lcd_controller_tb/lcd_controller_component/buffer_ready
add wave -noupdate /lcd_controller_tb/lcd_controller_component/buffer_clr
add wave -noupdate -radix hexadecimal /lcd_controller_tb/lcd_controller_component/buffer_reg
add wave -noupdate /lcd_controller_tb/lcd_controller_component/curr_state
add wave -noupdate /lcd_controller_tb/lcd_controller_component/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1535 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 715
configure wave -valuecolwidth 63
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {4992 ns}
