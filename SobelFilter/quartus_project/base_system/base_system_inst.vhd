	component base_system is
		port (
			cam_data      : in    std_logic_vector(9 downto 0)  := (others => 'X'); -- data
			cam_hsync     : in    std_logic                     := 'X';             -- hsync
			cam_pxlclk    : in    std_logic                     := 'X';             -- pxlclk
			cam_pwrdwn    : out   std_logic;                                        -- pwrdwn
			cam_rstb      : out   std_logic;                                        -- rstb
			cam_vsync     : in    std_logic                     := 'X';             -- vsync
			clk_clk       : in    std_logic                     := 'X';             -- clk
			dac_clk_clk   : out   std_logic;                                        -- clk
			dipsw_export  : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
			i2c_scl       : out   std_logic;                                        -- scl
			i2c_sda       : inout std_logic                     := 'X';             -- sda
			lcd_csb       : out   std_logic;                                        -- csb
			lcd_db        : inout std_logic_vector(15 downto 0) := (others => 'X'); -- db
			lcd_dcb       : out   std_logic;                                        -- dcb
			lcd_im        : out   std_logic;                                        -- im
			lcd_rb        : out   std_logic;                                        -- rb
			lcd_resb      : out   std_logic;                                        -- resb
			lcd_wb        : out   std_logic;                                        -- wb
			mclk_clk      : out   std_logic;                                        -- clk
			reset_reset_n : in    std_logic                     := 'X';             -- reset_n
			sdram_addr    : out   std_logic_vector(11 downto 0);                    -- addr
			sdram_ba      : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_cas_n   : out   std_logic;                                        -- cas_n
			sdram_cke     : out   std_logic;                                        -- cke
			sdram_cs_n    : out   std_logic;                                        -- cs_n
			sdram_dq      : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_dqm     : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_ras_n   : out   std_logic;                                        -- ras_n
			sdram_we_n    : out   std_logic;                                        -- we_n
			sdram_clk_clk : out   std_logic;                                        -- clk
			vga_blue      : out   std_logic_vector(9 downto 0);                     -- blue
			vga_green     : out   std_logic_vector(9 downto 0);                     -- green
			vga_hsync     : out   std_logic;                                        -- hsync
			vga_red       : out   std_logic_vector(9 downto 0);                     -- red
			vga_vsync     : out   std_logic                                         -- vsync
		);
	end component base_system;

	u0 : component base_system
		port map (
			cam_data      => CONNECTED_TO_cam_data,      --       cam.data
			cam_hsync     => CONNECTED_TO_cam_hsync,     --          .hsync
			cam_pxlclk    => CONNECTED_TO_cam_pxlclk,    --          .pxlclk
			cam_pwrdwn    => CONNECTED_TO_cam_pwrdwn,    --          .pwrdwn
			cam_rstb      => CONNECTED_TO_cam_rstb,      --          .rstb
			cam_vsync     => CONNECTED_TO_cam_vsync,     --          .vsync
			clk_clk       => CONNECTED_TO_clk_clk,       --       clk.clk
			dac_clk_clk   => CONNECTED_TO_dac_clk_clk,   --   dac_clk.clk
			dipsw_export  => CONNECTED_TO_dipsw_export,  --     dipsw.export
			i2c_scl       => CONNECTED_TO_i2c_scl,       --       i2c.scl
			i2c_sda       => CONNECTED_TO_i2c_sda,       --          .sda
			lcd_csb       => CONNECTED_TO_lcd_csb,       --       lcd.csb
			lcd_db        => CONNECTED_TO_lcd_db,        --          .db
			lcd_dcb       => CONNECTED_TO_lcd_dcb,       --          .dcb
			lcd_im        => CONNECTED_TO_lcd_im,        --          .im
			lcd_rb        => CONNECTED_TO_lcd_rb,        --          .rb
			lcd_resb      => CONNECTED_TO_lcd_resb,      --          .resb
			lcd_wb        => CONNECTED_TO_lcd_wb,        --          .wb
			mclk_clk      => CONNECTED_TO_mclk_clk,      --      mclk.clk
			reset_reset_n => CONNECTED_TO_reset_reset_n, --     reset.reset_n
			sdram_addr    => CONNECTED_TO_sdram_addr,    --     sdram.addr
			sdram_ba      => CONNECTED_TO_sdram_ba,      --          .ba
			sdram_cas_n   => CONNECTED_TO_sdram_cas_n,   --          .cas_n
			sdram_cke     => CONNECTED_TO_sdram_cke,     --          .cke
			sdram_cs_n    => CONNECTED_TO_sdram_cs_n,    --          .cs_n
			sdram_dq      => CONNECTED_TO_sdram_dq,      --          .dq
			sdram_dqm     => CONNECTED_TO_sdram_dqm,     --          .dqm
			sdram_ras_n   => CONNECTED_TO_sdram_ras_n,   --          .ras_n
			sdram_we_n    => CONNECTED_TO_sdram_we_n,    --          .we_n
			sdram_clk_clk => CONNECTED_TO_sdram_clk_clk, -- sdram_clk.clk
			vga_blue      => CONNECTED_TO_vga_blue,      --       vga.blue
			vga_green     => CONNECTED_TO_vga_green,     --          .green
			vga_hsync     => CONNECTED_TO_vga_hsync,     --          .hsync
			vga_red       => CONNECTED_TO_vga_red,       --          .red
			vga_vsync     => CONNECTED_TO_vga_vsync      --          .vsync
		);

