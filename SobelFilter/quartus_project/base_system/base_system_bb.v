
module base_system (
	cam_data,
	cam_hsync,
	cam_pxlclk,
	cam_pwrdwn,
	cam_rstb,
	cam_vsync,
	clk_clk,
	dac_clk_clk,
	dipsw_export,
	i2c_scl,
	i2c_sda,
	lcd_csb,
	lcd_db,
	lcd_dcb,
	lcd_im,
	lcd_rb,
	lcd_resb,
	lcd_wb,
	mclk_clk,
	reset_reset_n,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n,
	sdram_clk_clk,
	vga_blue,
	vga_green,
	vga_hsync,
	vga_red,
	vga_vsync);	

	input	[9:0]	cam_data;
	input		cam_hsync;
	input		cam_pxlclk;
	output		cam_pwrdwn;
	output		cam_rstb;
	input		cam_vsync;
	input		clk_clk;
	output		dac_clk_clk;
	input	[7:0]	dipsw_export;
	output		i2c_scl;
	inout		i2c_sda;
	output		lcd_csb;
	inout	[15:0]	lcd_db;
	output		lcd_dcb;
	output		lcd_im;
	output		lcd_rb;
	output		lcd_resb;
	output		lcd_wb;
	output		mclk_clk;
	input		reset_reset_n;
	output	[11:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[15:0]	sdram_dq;
	output	[1:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
	output		sdram_clk_clk;
	output	[9:0]	vga_blue;
	output	[9:0]	vga_green;
	output		vga_hsync;
	output	[9:0]	vga_red;
	output		vga_vsync;
endmodule
