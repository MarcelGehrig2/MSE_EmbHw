	base_system u0 (
		.cam_data      (<connected-to-cam_data>),      //       cam.data
		.cam_hsync     (<connected-to-cam_hsync>),     //          .hsync
		.cam_pxlclk    (<connected-to-cam_pxlclk>),    //          .pxlclk
		.cam_pwrdwn    (<connected-to-cam_pwrdwn>),    //          .pwrdwn
		.cam_rstb      (<connected-to-cam_rstb>),      //          .rstb
		.cam_vsync     (<connected-to-cam_vsync>),     //          .vsync
		.clk_clk       (<connected-to-clk_clk>),       //       clk.clk
		.dac_clk_clk   (<connected-to-dac_clk_clk>),   //   dac_clk.clk
		.dipsw_export  (<connected-to-dipsw_export>),  //     dipsw.export
		.i2c_scl       (<connected-to-i2c_scl>),       //       i2c.scl
		.i2c_sda       (<connected-to-i2c_sda>),       //          .sda
		.lcd_csb       (<connected-to-lcd_csb>),       //       lcd.csb
		.lcd_db        (<connected-to-lcd_db>),        //          .db
		.lcd_dcb       (<connected-to-lcd_dcb>),       //          .dcb
		.lcd_im        (<connected-to-lcd_im>),        //          .im
		.lcd_rb        (<connected-to-lcd_rb>),        //          .rb
		.lcd_resb      (<connected-to-lcd_resb>),      //          .resb
		.lcd_wb        (<connected-to-lcd_wb>),        //          .wb
		.mclk_clk      (<connected-to-mclk_clk>),      //      mclk.clk
		.reset_reset_n (<connected-to-reset_reset_n>), //     reset.reset_n
		.sdram_addr    (<connected-to-sdram_addr>),    //     sdram.addr
		.sdram_ba      (<connected-to-sdram_ba>),      //          .ba
		.sdram_cas_n   (<connected-to-sdram_cas_n>),   //          .cas_n
		.sdram_cke     (<connected-to-sdram_cke>),     //          .cke
		.sdram_cs_n    (<connected-to-sdram_cs_n>),    //          .cs_n
		.sdram_dq      (<connected-to-sdram_dq>),      //          .dq
		.sdram_dqm     (<connected-to-sdram_dqm>),     //          .dqm
		.sdram_ras_n   (<connected-to-sdram_ras_n>),   //          .ras_n
		.sdram_we_n    (<connected-to-sdram_we_n>),    //          .we_n
		.sdram_clk_clk (<connected-to-sdram_clk_clk>), // sdram_clk.clk
		.vga_blue      (<connected-to-vga_blue>),      //       vga.blue
		.vga_green     (<connected-to-vga_green>),     //          .green
		.vga_hsync     (<connected-to-vga_hsync>),     //          .hsync
		.vga_red       (<connected-to-vga_red>),       //          .red
		.vga_vsync     (<connected-to-vga_vsync>)      //          .vsync
	);

