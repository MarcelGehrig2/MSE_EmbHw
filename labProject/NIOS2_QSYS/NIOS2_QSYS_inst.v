	NIOS2_QSYS u0 (
		.clk_clk              (<connected-to-clk_clk>),              //            clk.clk
		.leds_export          (<connected-to-leds_export>),          //           leds.export
		.reset_reset_n        (<connected-to-reset_reset_n>),        //          reset.reset_n
		.sdram_clk_clk        (<connected-to-sdram_clk_clk>),        //      sdram_clk.clk
		.sdram_ctl_wire_addr  (<connected-to-sdram_ctl_wire_addr>),  // sdram_ctl_wire.addr
		.sdram_ctl_wire_ba    (<connected-to-sdram_ctl_wire_ba>),    //               .ba
		.sdram_ctl_wire_cas_n (<connected-to-sdram_ctl_wire_cas_n>), //               .cas_n
		.sdram_ctl_wire_cke   (<connected-to-sdram_ctl_wire_cke>),   //               .cke
		.sdram_ctl_wire_cs_n  (<connected-to-sdram_ctl_wire_cs_n>),  //               .cs_n
		.sdram_ctl_wire_dq    (<connected-to-sdram_ctl_wire_dq>),    //               .dq
		.sdram_ctl_wire_dqm   (<connected-to-sdram_ctl_wire_dqm>),   //               .dqm
		.sdram_ctl_wire_ras_n (<connected-to-sdram_ctl_wire_ras_n>), //               .ras_n
		.sdram_ctl_wire_we_n  (<connected-to-sdram_ctl_wire_we_n>)   //               .we_n
	);

