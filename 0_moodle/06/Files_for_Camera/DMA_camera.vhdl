LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY camera_if IS
   PORT ( clock            : IN  std_logic;
          reset            : IN  std_logic;
          irq              : OUT std_logic;
          -- slave avalon interface
          slave_address    : IN  std_logic_vector( 2 DOWNTO 0 );
          slave_cs         : IN  std_logic;
          slave_we         : IN  std_logic;
          slave_write_data : IN  std_logic_vector(31 DOWNTO 0 );
          slave_read_data  : OUT std_logic_vector(31 DOWNTO 0 );
          -- master avalon interface
          master_address   : OUT std_logic_vector(31 DOWNTO 0 );
          master_cs        : OUT std_logic;
          master_we        : OUT std_logic;
          master_write_data: OUT std_logic_vector(31 DOWNTO 0 );
          master_wait_req  : IN  std_logic;
          -- camera interface
          cam_PX_clock     : IN  std_logic;
          cam_vsync        : IN  std_logic;
          cam_href         : IN  std_logic;
          cam_data         : IN  std_logic_vector( 9 DOWNTO 0 );
          cam_reset        : OUT std_logic;
          cam_pwdn         : OUT std_logic);
END camera_if;

ARCHITECTURE simple OF camera_if IS

   -------- register model -----------
   -- 000 camara FPS (read only)
   -- 001 camera control register
   --        bit 0 => take one picture
   --        bit 1 => start continues mode
   --        bit 2 => stop continues mode
   --        bit 3 => enable irq
   --        bit 4 => disable irq
   --        bit 5 => clear irq
   --     read: 
   --        bit 0 => Busy taking picture
   --        bit 1 => In continues mode
   --        bit 4 => IRQ enabled
   --        bit 5 => IRQ generated
   -- 010 address of buffer containing current image (read only)
   -- 011 camera reset pwrdn control
   --        bit 0 => reset bit (default 0)
   --        bit 1 => power down bit (default 1)
   --        bit 2 => (0 => double buffer, 1 => quad buffer)
   -- 100 buffer 1 address
   -- 101 buffer 2 address
   -- 110 buffer 3 address
   -- 111 buffer 4 address
   
   COMPONENT synchro_flop
      PORT ( clock_in    : IN  std_logic;
             clock_out   : IN  std_logic;
             reset       : IN  std_logic;
             tick_in     : IN  std_logic;
             tick_out    : OUT std_logic);
   END COMPONENT;
   
   COMPONENT ram_dp_1k
      PORT( clock_A    : IN  std_logic;
            we_A       : IN  std_logic;
            addr_A     : IN  std_logic_vector(9 DOWNTO 0);
            Din_A      : IN  std_logic_vector(7 DOWNTO 0);
            Dout_A     : OUT std_logic_vector(7 DOWNTO 0);
            clock_B    : IN  std_logic;
            we_B       : IN  std_logic;
            addr_B     : IN  std_logic_vector(9 DOWNTO 0);
            Din_B      : IN  std_logic_vector(7 DOWNTO 0);
            Dout_B     : OUT std_logic_vector(7 DOWNTO 0));
   END COMPONENT;
   
   COMPONENT ram_sp_1k_32
      PORT( clock   : IN  std_logic;
            we      : IN  std_logic;
            addr    : IN  std_logic_vector( 7 DOWNTO 0 );
            Din     : IN  std_logic_vector( 31 DOWNTO 0 );
            Dout    : OUT std_logic_vector( 31 DOWNTO 0 ));
   END COMPONENT;
   
   TYPE LINE_CONVERSION_TYPE IS (IDLE,READ1,READ2,READ3,
                                 READ4,READ5,READ6,READ7,
                                 READ8,TRANSFER);
   TYPE CAMERA_CONTROL_TYPE IS (NOOP,WAIT_NEW_IMAGE,STORE_IMAGE,
                                INIT_1,STORE_IMAGE_1,INIT_2,STORE_IMAGE_2,
                                INIT_3,STORE_IMAGE_3,INIT_4,STORE_IMAGE_4,
                                GENIRQ);
   TYPE DMA_TYPE IS (NOACTION,WAITONE,WRITE,WAITWRITE);
   
   SIGNAL s_reset_reg           : std_logic;
   SIGNAL s_power_down_reg      : std_logic;
   SIGNAL s_buffer_reg          : std_logic;
   SIGNAL s_addr_1_reg          : std_logic_vector( 32 DOWNTO 0 );
   SIGNAL s_addr_2_reg          : std_logic_vector( 32 DOWNTO 0 );
   SIGNAL s_addr_3_reg          : std_logic_vector( 32 DOWNTO 0 );
   SIGNAL s_addr_4_reg          : std_logic_vector( 32 DOWNTO 0 );
   SIGNAL s_vsync_del_reg       : std_logic_vector(  2 DOWNTO 0 );
   SIGNAL s_hsync_del_reg       : std_logic_vector(  2 DOWNTO 0 );
   SIGNAL s_new_screen          : std_logic;
   SIGNAL s_new_screen_tick     : std_logic;
   SIGNAL s_line_done           : std_logic;
   SIGNAL s_line_done_tick      : std_logic;
   SIGNAL s_second_counter      : std_logic_vector( 25 DOWNTO 0 );
   SIGNAL s_second_tick         : std_logic;
   SIGNAL s_framerate_counter   : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_framerate_reg       : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_line_byte_count     : std_logic_vector(  9 DOWNTO 0 );
   SIGNAL s_buffer_select       : std_logic;
   SIGNAL s_pixel_data          : std_logic_vector(  9 DOWNTO 0 );
   SIGNAL s_we_line_1           : std_logic;
   SIGNAL s_we_line_2           : std_logic;
   SIGNAL s_line_conv_state     : LINE_CONVERSION_TYPE;
   SIGNAL s_line_conv_state_del : LINE_CONVERSION_TYPE;
   SIGNAL s_line_conv_next      : LINE_CONVERSION_TYPE;
   SIGNAL s_pix_read_addr       : std_logic_vector(  9 DOWNTO 0 );
   SIGNAL s_line_data_1         : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_line_data_2         : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_comp_px_data        : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_pixel_1             : std_logic_vector( 23 DOWNTO 0 );
   SIGNAL s_pixel_2             : std_logic_vector( 23 DOWNTO 0 );
   SIGNAL s_pixel_3             : std_logic_vector( 23 DOWNTO 0 );
   SIGNAL s_pixel_4             : std_logic_vector( 23 DOWNTO 0 );
   SIGNAL s_combined_data       : std_logic_vector( 31 DOWNTO 0 );
   SIGNAL s_write_word          : std_logic;
   SIGNAL s_word_addr           : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_dma_addr            : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_rw_addr             : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_start_snapshot      : std_logic;
   SIGNAL s_camera_state        : CAMERA_CONTROL_TYPE;
   SIGNAL s_camera_next         : CAMERA_CONTROL_TYPE;
   SIGNAL s_bus_write_address   : std_logic_vector( 31 DOWNTO 2 );
   SIGNAL s_bus_load_address    : std_logic_vector( 31 DOWNTO 2 );
   SIGNAL s_load_bus_address    : std_logic;
   SIGNAL s_bus_data_next       : std_logic_vector( 31 DOWNTO 0 );
   SIGNAL s_dma_state           : DMA_TYPE;
   SIGNAL s_dma_next            : DMA_TYPE;
   SIGNAL s_start_dma           : std_logic;
   SIGNAL s_dma_we_reg          : std_logic;
   SIGNAL s_red                 : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_green               : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_blue                : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_irq_enable_reg      : std_logic;
   SIGNAL s_irq_reg             : std_logic;
   SIGNAL s_enable_irq          : std_logic;
   SIGNAL s_disable_irq         : std_logic;
   SIGNAL s_clear_irq           : std_logic;
   SIGNAL s_gen_irq             : std_logic;
   SIGNAL s_camera_busy         : std_logic;
   SIGNAL s_continues_mode      : std_logic;
   SIGNAL s_enable_cont_mode    : std_logic;
   SIGNAL s_disable_cont_mode   : std_logic;
   SIGNAL s_current_image_addr  : std_logic_vector(31 DOWNTO 2);
   

BEGIN
   -- Here the irq handling is defined
   irq <= s_irq_reg;
   
   s_gen_irq     <= '1' WHEN s_irq_enable_reg = '1' AND
                             (s_camera_state = GENIRQ OR
                              s_camera_state = INIT_1 OR
                              s_camera_state = INIT_2 OR
                              s_camera_state = INIT_3 OR
                              s_camera_state = INIT_4) ELSE '0';
   s_enable_irq  <= '1' WHEN slave_address = "001" AND
                             slave_cs = '1' AND
                             slave_we = '1' AND
                             slave_write_data(3) = '1' ELSE '0';
   s_disable_irq <= '1' WHEN slave_address = "001" AND
                             slave_cs = '1' AND
                             slave_we = '1' AND
                             slave_write_data(4) = '1' ELSE '0';
   s_clear_irq   <= '1' WHEN slave_address = "001" AND
                             slave_cs = '1' AND
                             slave_we = '1' AND
                             slave_write_data(5) = '1' ELSE '0';
                             
   make_irq_enable_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (s_disable_irq = '1' OR
             reset = '1') THEN s_irq_enable_reg <= '0';
         ELSIF (s_enable_irq = '1') THEN s_irq_enable_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_irq_enable_reg;
   

   make_irq_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (s_clear_irq = '1' OR
             reset = '1') THEN s_irq_reg <= '0';
         ELSIF (s_gen_irq = '1') THEN s_irq_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_irq_reg;
   
   -- Here the continues mode reg is defined
   s_disable_cont_mode <= '1' WHEN slave_address = "001" AND
                                   slave_cs = '1' AND
                                   slave_we = '1' AND
                                   slave_write_data(2) = '1' ELSE '0';
   s_enable_cont_mode  <= '1' WHEN slave_address = "001" AND
                                   slave_cs = '1' AND
                                   slave_we = '1' AND
                                   slave_write_data(1) = '1' AND
                                   ((s_buffer_reg = '0' AND
                                     s_addr_1_reg(32) = '1' AND
                                     s_addr_2_reg(32) = '1') OR
                                    (s_buffer_reg = '1' AND
                                     s_addr_1_reg(32) = '1' AND
                                     s_addr_2_reg(32) = '1' AND
                                     s_addr_3_reg(32) = '1' AND
                                     s_addr_4_reg(32) = '1'))ELSE '0';
   
   make_continues_mode : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (s_disable_cont_mode = '1' OR
             reset = '1') THEN s_continues_mode <= '0';
         ELSIF (s_enable_cont_mode = '1') THEN
            s_continues_mode <= '1';
         END IF;
      END IF;
   END PROCESS make_continues_mode;
   
   -- Here the outputs are defined
   cam_reset <= s_reset_reg;
   cam_pwdn  <= s_power_down_reg;
   
   -- Here the main state machine is defined
   s_camera_busy <= '0' WHEN s_camera_state = NOOP ELSE '1';
   make_camera_next : PROCESS( s_camera_state , s_start_snapshot ,
                               s_new_screen_tick , s_continues_mode ,
                               s_buffer_reg )
   BEGIN
      CASE (s_camera_state) IS
         WHEN NOOP            => IF (s_start_snapshot = '1' OR
                                     s_continues_mode = '1') THEN
                                    s_camera_next <= WAIT_NEW_IMAGE;
                                                             ELSE
                                    s_camera_next <= NOOP;
                                 END IF;
         WHEN WAIT_NEW_IMAGE  => IF (s_new_screen_tick = '1') THEN
                                    IF (s_continues_mode = '1') THEN
                                       s_camera_next <= STORE_IMAGE_1;
                                                                ELSE
                                       s_camera_next <= STORE_IMAGE;
                                    END IF;
                                                              ELSE
                                    s_camera_next <= WAIT_NEW_IMAGE;
                                 END IF;
         WHEN STORE_IMAGE     => IF (s_new_screen_tick = '1') THEN
                                    s_camera_next <= GENIRQ;
                                                              ELSE
                                    s_camera_next <= STORE_IMAGE;
                                 END IF;
         WHEN INIT_1          => s_camera_next <= STORE_IMAGE_1;
         WHEN STORE_IMAGE_1   => IF (s_new_screen_tick = '1') THEN
                                    s_camera_next <= INIT_2;
                                                              ELSE
                                    s_camera_next <= STORE_IMAGE_1;
                                 END IF;
         WHEN INIT_2          => IF (s_continues_mode = '0') THEN
                                    s_camera_next <= NOOP;
                                                             ELSE
                                    s_camera_next <= STORE_IMAGE_2;
                                 END IF;
         WHEN STORE_IMAGE_2   => IF (s_new_screen_tick = '1') THEN
                                    IF (s_buffer_reg = '0') THEN
                                       s_camera_next <= INIT_1;
                                                            ELSE
                                       s_camera_next <= INIT_3;
                                    END IF;
                                                              ELSE
                                    s_camera_next <= STORE_IMAGE_2;
                                 END IF;
         WHEN INIT_3          => s_camera_next <= STORE_IMAGE_3;
         WHEN STORE_IMAGE_3   => IF (s_new_screen_tick = '1') THEN
                                    s_camera_next <= INIT_4;
                                                              ELSE
                                    s_camera_next <= STORE_IMAGE_3;
                                 END IF;
         WHEN INIT_4          => s_camera_next <= STORE_IMAGE_4;
         WHEN STORE_IMAGE_4   => IF (s_new_screen_tick = '1') THEN
                                    s_camera_next <= INIT_1;
                                                              ELSE
                                    s_camera_next <= STORE_IMAGE_4;
                                 END IF;
         WHEN OTHERS          => s_camera_next <= NOOP;
      END CASE;
   END PROCESS make_camera_next;
   
   make_camera_state : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_camera_state <= NOOP;
                          ELSE s_camera_state <= s_camera_next;
         END IF;
      END IF;
   END PROCESS make_camera_state;
   

   -- Here all control signals are defined
   s_start_snapshot <= '1' WHEN slave_address = "001" AND
                                slave_cs = '1' AND
                                slave_we = '1' AND
                                slave_write_data(0) = '1' AND
                                s_addr_1_reg(32) = '1' ELSE '0';
   s_current_image_addr <= s_addr_2_reg(31 DOWNTO 2) 
                              WHEN (s_camera_state = STORE_IMAGE_1 AND
                                    s_buffer_reg = '0') OR
                                   s_camera_state = STORE_IMAGE_3 ELSE
                           s_addr_3_reg(31 DOWNTO 2)
                              WHEN s_camera_state = STORE_IMAGE_4 ELSE
                           s_addr_4_reg(31 DOWNTO 2) 
                              WHEN (s_camera_state = STORE_IMAGE_1 AND
                                    s_buffer_reg = '1') ELSE
                           s_addr_1_reg(31 DOWNTO 2);
   
   make_slave_data : PROCESS( slave_address , s_framerate_reg,
                              s_addr_1_reg , s_addr_2_reg,
                              s_addr_3_reg, s_addr_4_reg ,
                              s_camera_state ,s_camera_busy,
                              s_continues_mode , s_irq_enable_reg ,
                              s_current_image_addr )
   BEGIN
      CASE (slave_address) IS
         WHEN "000"  => slave_read_data <= X"000000"&s_framerate_reg;
         WHEN "001"  => slave_read_data <= X"000000"&
                                           "00"&s_irq_reg&s_irq_enable_reg&
                                           "00"&s_continues_mode&s_camera_busy;
         WHEN "010"  => slave_read_data <= s_current_image_addr&"00";
         WHEN "011"  => slave_read_data <= X"0000000"&"0"&s_buffer_reg&
                                           s_power_down_reg&s_reset_reg;
         WHEN "100"  => slave_read_data <= s_addr_1_reg(31 DOWNTO 0);
         WHEN "101"  => slave_read_data <= s_addr_2_reg(31 DOWNTO 0);
         WHEN "110"  => slave_read_data <= s_addr_3_reg(31 DOWNTO 0);
         WHEN "111"  => slave_read_data <= s_addr_4_reg(31 DOWNTO 0);
         WHEN OTHERS => slave_read_data <= (OTHERS => '0');
      END CASE;
   END PROCESS make_slave_data;

   -- Here all registers are defined
   make_addr_1_reg : PROCESS( clock , reset , slave_address,
                                 slave_cs , slave_we , slave_write_data )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_addr_1_reg <= (OTHERS => '0');
         ELSIF (slave_address = "100" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            s_addr_1_reg <= "1"&slave_write_data;
         END IF;
      END IF;
   END PROCESS make_addr_1_reg;

   make_addr_2_reg : PROCESS( clock , reset , slave_address,
                                 slave_cs , slave_we , slave_write_data )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_addr_2_reg <= (OTHERS => '0');
         ELSIF (slave_address = "101" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            s_addr_2_reg <= "1"&slave_write_data;
         END IF;
      END IF;
   END PROCESS make_addr_2_reg;

   make_addr_3_reg : PROCESS( clock , reset , slave_address,
                                 slave_cs , slave_we , slave_write_data )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_addr_3_reg <= (OTHERS => '0');
         ELSIF (slave_address = "110" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            s_addr_3_reg <= "1"&slave_write_data;
         END IF;
      END IF;
   END PROCESS make_addr_3_reg;

   make_addr_4_reg : PROCESS( clock , reset , slave_address,
                                 slave_cs , slave_we , slave_write_data )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_addr_4_reg <= (OTHERS => '0');
         ELSIF (slave_address = "111" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            s_addr_4_reg <= "1"&slave_write_data;
         END IF;
      END IF;
   END PROCESS make_addr_4_reg;

   make_buffer_reg : PROCESS( clock , reset , slave_address,
                             slave_cs , slave_we , slave_write_data )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_buffer_reg <= '0';
         ELSIF (slave_address = "011" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            s_buffer_reg <= slave_write_data( 2 );
         END IF;
      END IF;
   END PROCESS make_buffer_reg;

   make_reset_reg : PROCESS( clock , reset , slave_address,
                             slave_cs , slave_we , slave_write_data )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_reset_reg <= '0';
         ELSIF (slave_address = "011" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            s_reset_reg <= slave_write_data( 0 );
         END IF;
      END IF;
   END PROCESS make_reset_reg;

   make_pwdn_reg : PROCESS( clock , reset , slave_address,
                             slave_cs , slave_we , slave_write_data )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_power_down_reg <= '1';
         ELSIF (slave_address = "011" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            s_power_down_reg <= slave_write_data( 1 );
         END IF;
      END IF;
   END PROCESS make_pwdn_reg;
   
   -- Here we define some detection registers for profiling
   s_new_screen  <= s_vsync_del_reg(2) AND NOT(s_vsync_del_reg(1));
   s_line_done   <= NOT(s_vsync_del_reg(1)) AND
                    s_hsync_del_reg(2) AND
                    NOT(s_hsync_del_reg(1));
   s_second_tick <= '1' WHEN s_second_counter = "00"&X"000000" ELSE '0';
   
   make_vsyn_del_reg : PROCESS( cam_PX_clock , cam_vsync , reset )
   BEGIN
      IF (reset = '1') THEN s_vsync_del_reg <= (OTHERS => '0');
      ELSIF (rising_edge(cam_PX_clock)) THEN
         s_vsync_del_reg <= s_vsync_del_reg( 1 DOWNTO 0 )&cam_vsync;
      END IF;
   END PROCESS make_vsyn_del_reg;
   
   make_hsync_del_reg : PROCESS( cam_PX_clock , reset , cam_href )
   BEGIN
      IF (reset = '1') THEN s_hsync_del_reg <= (OTHERS => '0');
      ELSIF (rising_edge(cam_PX_clock)) THEN
         s_hsync_del_reg <= s_hsync_del_reg( 1 DOWNTO 0 )&cam_href;
      END IF;
   END PROCESS make_hsync_del_reg;
   
   make_second_counter : PROCESS( clock , reset , s_second_tick )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (s_second_tick = '1' OR
             reset = '1') THEN
            s_second_counter <= std_logic_vector(to_unsigned(49999999,26));
                          ELSE
            s_second_counter <= std_logic_vector(unsigned(s_second_counter)-1);
         END IF;
      END IF;
   END PROCESS make_second_counter;
   
   make_framerate_counter : PROCESS( clock , reset , s_new_screen_tick ,
                                     s_second_tick )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1' OR
             s_second_tick = '1') THEN s_framerate_counter <= (OTHERS => '0');
         ELSIF (s_new_screen_tick = '1') THEN
            s_framerate_counter <= std_logic_vector(unsigned(s_framerate_counter)+1);
         END IF;
      END IF;
   END PROCESS make_framerate_counter;
   
   make_framerate_reg : PROCESS( clock , reset , s_second_tick,
                                 s_framerate_counter )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_framerate_reg <= (OTHERS => '0');
         ELSIF (s_second_tick = '1') THEN
            s_framerate_reg <= s_framerate_counter;
         END IF;
      END IF;
   END PROCESS make_framerate_reg;
   
   make_line_byte_count : PROCESS( cam_PX_clock , s_line_done ,
                                   s_new_screen , s_hsync_del_reg ,
                                   s_vsync_del_reg )
   BEGIN
      IF (falling_edge(cam_PX_clock)) THEN
         IF (s_new_screen = '1' OR
             s_line_done = '1') THEN s_line_byte_count <= (OTHERS => '0');
         ELSIF (s_hsync_del_reg(0) = '1' AND
                s_vsync_del_reg(0) = '0') THEN
            s_line_byte_count <= std_logic_vector(unsigned(s_line_byte_count)+1);
         END IF;
      END IF;
   END PROCESS make_line_byte_count;
   
   screen_tick_sync : synchro_flop
      PORT MAP ( clock_in    => cam_PX_clock,
                 clock_out   => clock,
                 reset       => reset,
                 tick_in     => s_new_screen,
                 tick_out    => s_new_screen_tick );
                 
   line_done_tick : synchro_flop
      PORT MAP ( clock_in    => cam_PX_clock,
                 clock_out   => clock,
                 reset       => reset,
                 tick_in     => s_line_done,
                 tick_out    => s_line_done_tick );

   -- Here the line-write buffers are defined
   s_we_line_1 <= '1' WHEN s_buffer_select = '0' AND
                           s_hsync_del_reg(0) = '1' AND
                           s_vsync_del_reg(0) = '0' ELSE '0';
   s_we_line_2 <= '1' WHEN s_buffer_select = '1' AND
                           s_hsync_del_reg(0) = '1' AND
                           s_vsync_del_reg(0) = '0' ELSE '0';
   s_combined_data <= s_pixel_2(7 DOWNTO 0)&s_pixel_1
                         WHEN s_line_conv_state_del = READ5 ELSE
                      s_pixel_3(15 DOWNTO 0)&s_pixel_2(23 DOWNTO 8)
                         WHEN s_line_conv_state_del = READ7 ELSE
                      s_pixel_4&s_pixel_3(23 DOWNTO 16);
   
   make_buffer_select : PROCESS( cam_PX_clock , s_line_done , reset )
   BEGIN
      IF (reset = '1') THEN s_buffer_select <= '0';
      ELSIF (rising_edge(cam_PX_clock)) THEN
         IF (s_line_done = '1') THEN
            s_buffer_select <= NOT(s_buffer_select);
         END IF;
      END IF;
   END PROCESS make_buffer_select;
   
   make_pixel_data : PROCESS( cam_PX_clock )
   BEGIN
      IF (falling_edge(cam_PX_clock)) THEN
         s_pixel_data <= cam_data;
      END IF;
   END PROCESS make_pixel_data;
   
   line_1 : ram_dp_1k
      PORT MAP ( clock_A    => NOT(cam_PX_clock),
                 we_A       => s_we_line_1,
                 addr_A     => s_line_byte_count,
                 Din_A      => s_pixel_data(9 DOWNTO 2),
                 Dout_A     => OPEN,
                 clock_B    => clock,
                 we_B       => '0',
                 addr_B     => s_pix_read_addr,
                 Din_B      => X"00",
                 Dout_B     => s_line_data_1);

   line_2 : ram_dp_1k
      PORT MAP ( clock_A    => NOT(cam_PX_clock),
                 we_A       => s_we_line_2,
                 addr_A     => s_line_byte_count,
                 Din_A      => s_pixel_data(9 DOWNTO 2),
                 Dout_A     => OPEN,
                 clock_B    => clock,
                 we_B       => '0',
                 addr_B     => s_pix_read_addr,
                 Din_B      => X"00",
                 Dout_B     => s_line_data_2);

   -- here the line-data conversion is defined
   s_comp_px_data <= s_line_data_2 WHEN s_buffer_select = '0' ELSE
                     s_line_data_1;
   
   make_line_conv_next : PROCESS( s_line_conv_state, s_line_done_tick,
                                  s_pix_read_addr )
   BEGIN
      CASE (s_line_conv_state) IS
         WHEN IDLE      => IF (s_line_done_tick = '1') THEN
                              s_line_conv_next <= READ1;
                                                      ELSE
                              s_line_conv_next <= IDLE;
                           END IF;
         WHEN READ1     => s_line_conv_next <= READ2;
         WHEN READ2     => s_line_conv_next <= READ3;
         WHEN READ3     => s_line_conv_next <= READ4;
         WHEN READ4     => s_line_conv_next <= READ5;
         WHEN READ5     => s_line_conv_next <= READ6;
         WHEN READ6     => s_line_conv_next <= READ7;
         WHEN READ7     => s_line_conv_next <= READ8;
         WHEN READ8     => IF (unsigned(s_pix_read_addr) <
                               to_unsigned(639,10)) THEN
                              s_line_conv_next <= READ1;
                                                   ELSE
                              s_line_conv_next <= TRANSFER;
                           END IF;
         WHEN OTHERS    => s_line_conv_next <= IDLE;
      END CASE;
   END PROCESS make_line_conv_next;
   
   make_line_conv_state : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_line_conv_state     <= IDLE;
                               s_line_conv_state_del <= IDLE;
                          ELSE s_line_conv_state     <= s_line_conv_next;
                               s_line_conv_state_del <= s_line_conv_state;
         END IF;
      END IF;
   END PROCESS make_line_conv_state;
   
   make_pix_read_addr : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1' OR
             s_line_conv_state = IDLE) THEN
            s_pix_read_addr <= (OTHERS => '0');
         ELSIF (s_line_conv_state /= IDLE) THEN
            s_pix_read_addr <= std_logic_vector(unsigned(s_pix_read_addr)+1);
         END IF;
      END IF;
   END PROCESS make_pix_read_addr;
   
   s_red   <= s_comp_px_data(7 DOWNTO 3);
   s_green <= s_comp_px_data(2 DOWNTO 0)&s_comp_px_data(7 DOWNTO 5);
--   s_green <= (OTHERS => '0');
   s_blue  <= s_comp_px_data(4 DOWNTO 0);

   make_pixel_1 : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_pixel_1 <= (OTHERS => '0');
                          ELSE
            IF (s_line_conv_state_del = READ1) THEN
               s_pixel_1( 7 DOWNTO  0) <= s_red&"000";
               s_pixel_1(15 DOWNTO 13) <= s_green(5 DOWNTO 3);
            END IF;
            IF (s_line_conv_state_del = READ2) THEN
               s_pixel_1(12 DOWNTO  8) <= s_green(2 DOWNTO 0)&"00";
               s_pixel_1(23 DOWNTO 16) <= s_blue&"000";
            END IF;
         END IF;
      END IF;
   END PROCESS make_pixel_1;

   make_pixel_2 : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_pixel_2 <= (OTHERS => '0');
                          ELSE
            IF (s_line_conv_state_del = READ3) THEN
               s_pixel_2( 7 DOWNTO  0) <= s_red&"000";
               s_pixel_2(15 DOWNTO 13) <= s_green(5 DOWNTO 3);
            END IF;
            IF (s_line_conv_state_del = READ4) THEN
               s_pixel_2(12 DOWNTO  8) <= s_green(2 DOWNTO 0)&"00";
               s_pixel_2(23 DOWNTO 16) <= s_blue&"000";
            END IF;
         END IF;
      END IF;
   END PROCESS make_pixel_2;

   make_pixel_3 : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_pixel_3 <= (OTHERS => '0');
                          ELSE
            IF (s_line_conv_state_del = READ5) THEN
               s_pixel_3( 7 DOWNTO  0) <= s_red&"000";
               s_pixel_3(15 DOWNTO 13) <= s_green(5 DOWNTO 3);
            END IF;
            IF (s_line_conv_state_del = READ6) THEN
               s_pixel_3(12 DOWNTO  8) <= s_green(2 DOWNTO 0)&"00";
               s_pixel_3(23 DOWNTO 16) <= s_blue&"000";
            END IF;
         END IF;
      END IF;
   END PROCESS make_pixel_3;

   make_pixel_4 : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_pixel_4 <= (OTHERS => '0');
                          ELSE
            IF (s_line_conv_state_del = READ7) THEN
               s_pixel_4( 7 DOWNTO  0) <= s_red&"000";
               s_pixel_4(15 DOWNTO 13) <= s_green(5 DOWNTO 3);
            END IF;
            IF (s_line_conv_state_del = READ8) THEN
               s_pixel_4(12 DOWNTO  8) <= s_green(2 DOWNTO 0)&"00";
               s_pixel_4(23 DOWNTO 16) <= s_blue&"000";
            END IF;
         END IF;
      END IF;
   END PROCESS make_pixel_4;
   
   make_write_word : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (s_line_conv_state_del = READ4 OR
             s_line_conv_state_del = READ6 OR
             s_line_conv_state_del = READ8) THEN
            s_write_word <= '1';
                                            ELSE
            s_write_word <= '0';
         END IF;
      END IF;
   END PROCESS make_write_word;
   
   make_word_addr : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (s_line_conv_state_del = IDLE) THEN
            s_word_addr <= (OTHERS => '0');
         ELSIF (s_write_word = '1') THEN
            s_word_addr <= std_logic_vector(unsigned(s_word_addr)+1);
         END IF;
      END IF;
   END PROCESS make_word_addr;
   
   word_buffer : ram_sp_1k_32
      PORT MAP ( clock   => clock,
                 we      => s_write_word,
                 addr    => s_rw_addr,
                 Din     => s_combined_data,
                 Dout    => s_bus_data_next);

   -- Here the master control is defined
   s_rw_addr <= s_word_addr WHEN s_write_word = '1' ELSE
                s_dma_addr;
   s_start_dma <= '1' WHEN (s_camera_state = STORE_IMAGE OR
                            s_camera_state = STORE_IMAGE_1 OR 
                            s_camera_state = STORE_IMAGE_2 OR
                            s_camera_state = STORE_IMAGE_3 OR
                            s_camera_state = STORE_IMAGE_4) AND
                           s_line_conv_state_del = TRANSFER ELSE '0';
   master_cs   <= s_dma_we_reg;
   master_we   <= s_dma_we_reg;
             
   make_dma_next : PROCESS( s_dma_state , s_start_dma ,
                            master_wait_req , s_dma_addr )
   BEGIN
      CASE (s_dma_state) IS
         WHEN NOACTION     => IF (s_start_dma = '1') THEN
                                 s_dma_next <= WAITONE;
                                                     ELSE
                                 s_dma_next <= NOACTION;
                              END IF;
         WHEN WAITONE      => s_dma_next <= WRITE;
         WHEN WRITE        => s_dma_next <= WAITWRITE;
         WHEN WAITWRITE    => IF (master_wait_req = '1') THEN
                                 s_dma_next <= WAITWRITE;
                              ELSIF (unsigned(s_dma_addr) <
                                     to_unsigned(240,8)) THEN
                                 s_dma_next <= WRITE;
                                                         ELSE
                                 s_dma_next <= NOACTION;
                              END IF;
         WHEN OTHERS       => s_dma_next <= NOACTION;
      END CASE;
   END PROCESS make_dma_next;
   
   make_dma_state : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_dma_state <= NOACTION;
                          ELSE s_dma_state <= s_dma_next;
         END IF;
      END IF;
   END PROCESS make_dma_state;
                 
   make_dma_addr : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1' OR s_start_dma = '1') THEN
            s_dma_addr <= (OTHERS => '0');
         ELSIF (s_dma_state = WRITE) THEN
            s_dma_addr <= std_logic_vector(unsigned(s_dma_addr)+1);
         END IF;
      END IF;
   END PROCESS make_dma_addr;
   
   s_load_bus_address <= '1' WHEN s_camera_state = WAIT_NEW_IMAGE OR
                                  s_camera_state = INIT_1 OR
                                  s_camera_state = INIT_2 OR
                                  s_camera_state = INIT_3 OR
                                  s_camera_state = INIT_4 ELSE '0';
   make_bus_load_address : PROCESS( s_camera_state , s_addr_1_reg , 
                                    s_addr_2_reg , s_addr_3_reg , s_addr_4_reg )
   BEGIN
      CASE (s_camera_state) IS
         WHEN INIT_2 => s_bus_load_address <= s_addr_2_reg(31 DOWNTO 2);
         WHEN INIT_3 => s_bus_load_address <= s_addr_3_reg(31 DOWNTO 2);
         WHEN INIT_4 => s_bus_load_address <= s_addr_4_reg(31 DOWNTO 2);
         WHEN OTHERS => s_bus_load_address <= s_addr_1_reg(31 DOWNTO 2);
      END CASE;
   END PROCESS make_bus_load_address;
   
   make_master_address_data : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN master_address    <= (OTHERS => '0');
                               master_write_data <= (OTHERS => '0');
         ELSIF (s_dma_state = WRITE) THEN
            master_address    <= s_bus_write_address&"00";
            master_write_data <= s_bus_data_next;
         END IF;
      END IF;
   END PROCESS make_master_address_data;
   
   make_bus_write_address : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_bus_write_address <= (OTHERS => '0');
         ELSIF (s_load_bus_address = '1') THEN 
            s_bus_write_address <= s_bus_load_address;
         ELSIF (s_dma_state = WRITE) THEN
            s_bus_write_address <= std_logic_vector(unsigned(s_bus_write_address)+1);
         END IF;
      END IF;
   END PROCESS make_bus_write_address;
   
   make_dma_we_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF ((s_dma_state=WRITE) OR
             (s_dma_state=WAITWRITE AND
              s_dma_we_reg = '1' AND
              master_wait_req = '1')) THEN s_dma_we_reg <= '1';
                                      ELSE s_dma_we_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_dma_we_reg;
   
END simple;

--------------------------------------------------------------------------------
--- New component                                                            ---
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY synchro_flop IS
   PORT ( clock_in    : IN  std_logic;
          clock_out   : IN  std_logic;
          reset       : IN  std_logic;
          tick_in     : IN  std_logic;
          tick_out    : OUT std_logic);
END synchro_flop;

ARCHITECTURE behave OF synchro_flop IS

   SIGNAL s_delay_line : std_logic_vector( 2 DOWNTO 0 );

BEGIN
   tick_out <= s_delay_line(2);

   del1 : PROCESS( clock_in , s_delay_line , tick_in ,
                   reset )
   BEGIN
      IF (s_delay_line(2) = '1' OR
          reset = '1') THEN s_delay_line(0) <= '0';
      ELSIF (rising_edge(clock_in)) THEN
         s_delay_line(0) <= s_delay_line(0) OR tick_in;
      END IF;
   END PROCESS del1;
   
   del2 : PROCESS( clock_out , s_delay_line , reset )
   BEGIN
      IF (s_delay_line(2) = '1' OR
          reset = '1') THEN s_delay_line(1) <= '0';
      ELSIF (rising_edge(clock_out)) THEN
         s_delay_line(1) <= s_delay_line(0);
      END IF;
   END PROCESS del2;
   
   del3 : PROCESS( clock_out , reset , s_delay_line )
   BEGIN
      IF (reset = '1') THEN s_delay_line(2) <= '0';
      ELSIF (rising_edge(clock_out)) THEN
         s_delay_line(2) <= s_delay_line(1);
      END IF;
   END PROCESS del3;
   
END behave;

--------------------------------------------------------------------------------
--- New component                                                            ---
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ram_sp_1k_32 IS
   PORT( clock   : IN  std_logic;
         we      : IN  std_logic;
         addr    : IN  std_logic_vector( 7 DOWNTO 0 );
         Din     : IN  std_logic_vector( 31 DOWNTO 0 );
         Dout    : OUT std_logic_vector( 31 DOWNTO 0 ));
END ram_sp_1k_32;

ARCHITECTURE fpga OF ram_sp_1k_32 IS

   TYPE MEM_TYPE IS ARRAY( 255 DOWNTO 0 ) OF std_logic_vector( 31 DOWNTO 0 );
   SIGNAL memory : MEM_TYPE;
   
BEGIN
   make_mem : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (we = '1') THEN 
            memory(to_integer(unsigned(addr))) <= Din;
         END IF;
         Dout <= memory(to_integer(unsigned(addr)));
      END IF;
   END PROCESS make_mem;
END fpga;

--------------------------------------------------------------------------------
--- New component                                                            ---
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ram_dp_1k IS
   PORT( clock_A    : IN  std_logic;
         we_A       : IN  std_logic;
         addr_A     : IN  std_logic_vector(9 DOWNTO 0);
         Din_A      : IN  std_logic_vector(7 DOWNTO 0);
         Dout_A     : OUT std_logic_vector(7 DOWNTO 0);
         
         clock_B    : IN  std_logic;
         we_B       : IN  std_logic;
         addr_B     : IN  std_logic_vector(9 DOWNTO 0);
         Din_B      : IN  std_logic_vector(7 DOWNTO 0);
         Dout_B     : OUT std_logic_vector(7 DOWNTO 0));
END ram_dp_1k;

ARCHITECTURE fpga OF ram_dp_1k IS

   TYPE MEM_TYPE IS ARRAY( 1023 DOWNTO 0 ) OF std_logic_vector( 7 DOWNTO 0 );
   SIGNAL memory : MEM_TYPE;
   
BEGIN
   portA : PROCESS( clock_A )
   BEGIN
      IF (rising_edge(clock_A)) THEN
         IF (we_A = '1') THEN
            memory(to_integer(unsigned(addr_A))) <= Din_A;
         END IF;
         Dout_A <= memory(to_integer(unsigned(addr_A)));
      END IF;
   END PROCESS portA;
   
   portB : PROCESS( clock_B )
   BEGIN
      IF (rising_edge(clock_B)) THEN
         IF (we_B = '1') THEN
            memory(to_integer(unsigned(addr_B))) <= Din_B;
         END IF;
         Dout_B <= memory(to_integer(unsigned(addr_B)));
      END IF;
   END PROCESS portB;
END fpga;
