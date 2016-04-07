
module NIOS2_QSYS (
	clk_clk,
	leds_export,
	reset_reset_n,
	sdram_clk_clk,
	sdram_ctl_wire_addr,
	sdram_ctl_wire_ba,
	sdram_ctl_wire_cas_n,
	sdram_ctl_wire_cke,
	sdram_ctl_wire_cs_n,
	sdram_ctl_wire_dq,
	sdram_ctl_wire_dqm,
	sdram_ctl_wire_ras_n,
	sdram_ctl_wire_we_n);	

	input		clk_clk;
	output	[7:0]	leds_export;
	input		reset_reset_n;
	output		sdram_clk_clk;
	output	[11:0]	sdram_ctl_wire_addr;
	output	[1:0]	sdram_ctl_wire_ba;
	output		sdram_ctl_wire_cas_n;
	output		sdram_ctl_wire_cke;
	output		sdram_ctl_wire_cs_n;
	inout	[15:0]	sdram_ctl_wire_dq;
	output	[1:0]	sdram_ctl_wire_dqm;
	output		sdram_ctl_wire_ras_n;
	output		sdram_ctl_wire_we_n;
endmodule
