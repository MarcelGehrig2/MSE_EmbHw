onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dma_lcd_ctrl/clk
add wave -noupdate /dma_lcd_ctrl/reset
add wave -noupdate -divider {Avalon Master}
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/master_address
add wave -noupdate /dma_lcd_ctrl/master_read
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/master_readdata
add wave -noupdate /dma_lcd_ctrl/master_waitrequest
add wave -noupdate /dma_lcd_ctrl/end_of_transaction_irq
add wave -noupdate -divider {Avalon Slave}
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/avalon_address
add wave -noupdate /dma_lcd_ctrl/avalon_cs
add wave -noupdate /dma_lcd_ctrl/avalon_wr
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/avalon_write_data
add wave -noupdate /dma_lcd_ctrl/avalon_rd
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/avalon_read_data
add wave -noupdate -divider {LCD Parallel Port}
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/LCD_data
add wave -noupdate /dma_lcd_ctrl/LCD_CS_n
add wave -noupdate /dma_lcd_ctrl/LCD_WR_n
add wave -noupdate /dma_lcd_ctrl/LCD_D_C_n
add wave -noupdate -divider {Internal Registers}
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/LCD_data_reg
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/address_reg
add wave -noupdate /dma_lcd_ctrl/LCD_direct
add wave -noupdate /dma_lcd_ctrl/base_image_pointer_en
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/base_image_pointer
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/size_image
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/image_pointer
add wave -noupdate /dma_lcd_ctrl/start
add wave -noupdate /dma_lcd_ctrl/master_read_s
add wave -noupdate /dma_lcd_ctrl/IRQ_clr
add wave -noupdate /dma_lcd_ctrl/size_image_en
add wave -noupdate /dma_lcd_ctrl/run
add wave -noupdate /dma_lcd_ctrl/master_read_en
add wave -noupdate /dma_lcd_ctrl/master_data_valid
add wave -noupdate /dma_lcd_ctrl/buffer_ready
add wave -noupdate /dma_lcd_ctrl/buffer_clr
add wave -noupdate -radix hexadecimal /dma_lcd_ctrl/buffer_reg
add wave -noupdate /dma_lcd_ctrl/curr_state
add wave -noupdate /dma_lcd_ctrl/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {243916 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 458
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {829440 ps}
