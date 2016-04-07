LIBRARY IEEE;
USE ieee.std_logic_1164.all;

ENTITY i2c_core IS
   PORT ( clock              : IN    std_logic;
          reset              : IN    std_logic;
          irq                : OUT   std_logic;
          -- slave avalon interface
          slave_address      : IN    std_logic_vector( 1 DOWNTO 0 );
          slave_cs           : IN    std_logic;
          slave_we           : IN    std_logic;
          slave_write_data   : IN    std_logic_vector(31 DOWNTO 0 );
          slave_byte_enables : IN    std_logic_vector( 3 DOWNTO 0 );
          slave_read_data    : OUT   std_logic_vector(31 DOWNTO 0 );
          -- i2c buses
          SDA                : INOUT std_logic;
          SCL                : OUT   std_logic;
          Motion_IRQ         : IN    std_logic);
END i2c_core;

ARCHITECTURE simple OF i2c_core IS

   -------- register model -----------
   -- 00 Write: I2c Device Identifyer (used also for autodetection index)
   --    Read:  Detected device Identifyer indexed by I2c Device Identifyer
   -- 01 Write: I2c Device Address Read: Nr. of devices detected
   -- 10 Write: I2c Data to send Read: I2C Data received from device
   -- 11 Write: Control register
   --           Bit 0 => Two-phase bit (0 -> 3 byte transfer, 1 -> two byte
   --                                   transfer)
   --           Bit 1 => Start I2C transfer
   --           Bit 2 => Start I2C autodetect
   --           Bit 3 => Clear I2C IRQ
   --           Bit 4 => Clear Motion IRQ
   --           Bit 15..8 => prescale value (0 = 400Khz, 255=1562.5Hz)
   --           Bit 16 => Enable(1)/Disable(0) I2C IRQ generation
   --           Bit 17 => Enable(1)/Disable(0) Motion IRQ generation
   --    Read:  Status register
   --           Bit 0  => I2C transfer in progress
   --           Bit 1  => I2C autodetection in progress
   --           Bit 2  => I2C device ID ack-error
   --           Bit 3  => I2C address ack-error
   --           Bit 4  => I2C data ack-error
   --           Bit 8  => I2C irq generated
   --           Bit 9  => Motion Sensor irq generated 
   --           Bit 10 => I2C IRQ enabled(1)/disabled(0)
   --           Bit 11 => Motion IRQ enabled(1)/disabled(0)
   
   COMPONENT i2c_autodetect
      PORT ( clock         : IN  std_logic;
             reset         : IN  std_logic;
             start         : IN  std_logic;
             ack_errors    : IN  std_logic_vector( 2 DOWNTO 0 );
             i2c_busy      : IN  std_logic;
             start_i2cc    : OUT std_logic;
             i2c_did       : OUT std_logic_vector( 7 DOWNTO 0 );
             nr_of_devices : OUT std_logic_vector( 7 DOWNTO 0 );
             device_addr   : IN  std_logic_vector( 7 DOWNTO 0 );
             device_id     : OUT std_logic_vector( 7 DOWNTO 0 );
             busy          : OUT std_logic);
   END COMPONENT;
   
   COMPONENT i2c_cntrl
      PORT ( clock      : IN  std_logic;
             reset      : IN  std_logic;
             start      : IN  std_logic;
             device_id  : IN  std_logic_vector( 7 DOWNTO 0 );
             address    : IN  std_logic_vector( 7 DOWNTO 0 );
             data       : IN  std_logic_vector( 7 DOWNTO 0 );
             prescale   : IN  std_logic_vector( 7 DOWNTO 0 );
             data_out   : OUT std_logic_vector( 7 DOWNTO 0 );
             two_phase  : IN  std_logic;
             SDA_out    : OUT std_logic;
             SDA_in     : IN  std_logic;
             SCL        : OUT std_logic;
             busy       : OUT std_logic;
             ACK_ERRORs : OUT std_logic_vector( 2 DOWNTO 0 ));
   END COMPONENT;
   
   SIGNAL s_start_auto_detection       : std_logic;
   SIGNAL s_ack_errors                 : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_i2c_core_busy              : std_logic;
   SIGNAL s_start_i2c_core             : std_logic;
   SIGNAL s_start_auto_i2c_core        : std_logic;
   SIGNAL s_auto_did                   : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_did_reg                    : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_i2c_did                    : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_auto_busy                  : std_logic;
   SIGNAL s_i2c_addr                   : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_addr_reg                   : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_data_reg                   : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_control_reg                : std_logic_vector(15 DOWNTO 0 );
   SIGNAL s_i2c_data_out               : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_i2c_2_phase                : std_logic;
   SIGNAL s_sda_in                     : std_logic;
   SIGNAL s_sda_out                    : std_logic;
   SIGNAL s_scl_out                    : std_logic;
   SIGNAL s_auto_did_out               : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_auto_nr_devices            : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_i2c_irq_reg                : std_logic;
   SIGNAL s_i2c_irq_enable_reg         : std_logic;
   SIGNAL s_motion_irq_reg             : std_logic;
   SIGNAL s_motion_irq_enable_reg      : std_logic;
   SIGNAL s_i2c_core_busy_reg          : std_logic;
   SIGNAL s_motion_delay_reg           : std_logic_vector( 2 DOWNTO 0 );

BEGIN
   -- Here the outputs are defined
   SDA  <= '0' WHEN s_sda_out = '0' ELSE 'Z';
   SCL  <= '0' WHEN s_scl_out = '0' ELSE 'Z';
   IRQ  <= s_motion_irq_reg OR s_i2c_irq_reg;
   
   make_slave_read_data : PROCESS( slave_address , s_auto_did_out ,
                                   s_auto_nr_devices, s_ack_errors,
                                   s_i2c_data_out,s_auto_busy,s_i2c_core_busy,
                                   s_i2c_irq_reg,s_motion_irq_reg,
                                   s_i2c_irq_enable_reg,s_motion_irq_enable_reg)
   BEGIN
      CASE (slave_address) IS
          WHEN  "00"  => slave_read_data <= X"000000"&s_auto_did_out;
          WHEN  "01"  => slave_read_data <= X"000000"&s_auto_nr_devices;
          WHEN  "10"  => slave_read_data <= X"000000"&s_i2c_data_out;
          WHEN OTHERS => slave_read_data <= X"00000"&
                                            s_motion_irq_enable_reg&
                                            s_i2c_irq_enable_reg&
                                            s_motion_irq_reg&
                                            s_i2c_irq_reg&
                                            "000"&
                                            s_ack_errors&s_auto_busy&s_i2c_core_busy;
      END CASE;
   END PROCESS make_slave_read_data;
   
   -- Here the irq handling is defined
   make_motion_irq_enable_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_motion_irq_enable_reg <= '0';
         ELSIF (slave_address = "11" AND
                slave_cs = '1' AND
                slave_we = '1' AND
                slave_byte_enables(2) = '1') THEN
            s_motion_irq_enable_reg <= slave_write_data(17);
         END IF;
      END IF;
   END PROCESS make_motion_irq_enable_reg;

   make_i2c_irq_enable_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_i2c_irq_enable_reg <= '0';
         ELSIF (slave_address = "11" AND
                slave_cs = '1' AND
                slave_we = '1' AND
                slave_byte_enables(2) = '1') THEN
            s_i2c_irq_enable_reg <= slave_write_data(16);
         END IF;
      END IF;
   END PROCESS make_i2c_irq_enable_reg;
   
   make_i2c_irq_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1' OR
             (slave_address = "11" AND
              slave_cs = '1' AND
              slave_we = '1' AND
              slave_byte_enables(0) = '1' AND
              slave_write_data(3) = '1')) THEN s_i2c_irq_reg <= '0';
         ELSIF (s_i2c_core_busy_reg = '1' AND
                s_i2c_core_busy = '0' AND
                s_i2c_irq_enable_reg = '1') THEN s_i2c_irq_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_i2c_irq_reg;
   
   make_motion_irq_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1' OR
             (slave_address = "11" AND
              slave_cs = '1' AND
              slave_we = '1' AND
              slave_byte_enables(0) = '1' AND
              slave_write_data(4) = '1')) THEN s_motion_irq_reg <= '0';
         ELSIF (s_motion_delay_reg(2) = '1' AND
                s_motion_delay_reg(1) = '0' AND
                s_motion_irq_enable_reg = '1') THEN s_motion_irq_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_motion_irq_reg;
   
   make_i2c_core_busy_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         s_i2c_core_busy_reg <= s_i2c_core_busy;
      END IF;
   END PROCESS make_i2c_core_busy_reg;
   
   make_motion_delay_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_motion_delay_reg <= (OTHERS => '0');
                          ELSE
            s_motion_delay_reg <= s_motion_delay_reg(1 DOWNTO 0)&Motion_IRQ;
         END IF;
      END IF;
   END PROCESS make_motion_delay_reg;

   -- Here the control signals are defined
   s_start_auto_detection <= '1' WHEN slave_address = "11" AND
                                      slave_cs = '1' AND
                                      slave_we = '1' AND
                                      slave_byte_enables(0) = '1' AND
                                      slave_write_data(2) = '1' ELSE '0';
   s_start_i2c_core       <= '1' WHEN s_start_auto_i2c_core = '1' OR
                                      (slave_address = "11" AND
                                       slave_cs = '1' AND
                                       slave_we = '1' AND
                                       slave_byte_enables(0) = '1' AND
                                       slave_write_data(1) = '1') ELSE '0';
   s_i2c_did              <= s_auto_did WHEN s_auto_busy = '1' ELSE s_did_reg;
   s_i2c_addr             <= s_addr_reg WHEN s_auto_busy = '0' ELSE X"00";
   s_i2c_2_phase          <= s_auto_busy OR s_control_reg(0);
   s_sda_in               <= SDA;
   
   -- Here all internal registers are defined
   make_did_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_did_reg <= (OTHERS => '0');
         ELSIF (slave_address = "00" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            s_did_reg <= slave_write_data( 7 DOWNTO 0 );
         END IF;
      END IF;
   END PROCESS make_did_reg;

   make_addr_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_addr_reg <= (OTHERS => '0');
         ELSIF (slave_address = "01" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            s_addr_reg <= slave_write_data( 7 DOWNTO 0 );
         END IF;
      END IF;
   END PROCESS make_addr_reg;

   make_data_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_data_reg <= (OTHERS => '0');
         ELSIF (slave_address = "10" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            s_data_reg <= slave_write_data( 7 DOWNTO 0 );
         END IF;
      END IF;
   END PROCESS make_data_reg;

   make_control_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_control_reg <= (OTHERS => '0');
         ELSIF (slave_address = "11" AND
                slave_cs = '1' AND
                slave_we = '1') THEN
            IF (slave_byte_enables(0) = '1') THEN
                s_control_reg( 7 DOWNTO 0 ) <= slave_write_data( 7 DOWNTO 0 );
            END IF;
            IF (slave_byte_enables(1) = '1') THEN
                s_control_reg(15 DOWNTO 8 ) <= slave_write_data(15 DOWNTO 8 );
            END IF;
         END IF;
      END IF;
   END PROCESS make_control_reg;

   -- Here the components are mapped
   autodetection : i2c_autodetect
      PORT MAP ( clock         => clock,
                 reset         => reset,
                 start         => s_start_auto_detection,
                 ack_errors    => s_ack_errors,
                 i2c_busy      => s_i2c_core_busy,
                 start_i2cc    => s_start_auto_i2c_core,
                 i2c_did       => s_auto_did,
                 nr_of_devices => s_auto_nr_devices,
                 device_addr   => s_did_reg,
                 device_id     => s_auto_did_out,
                 busy          => s_auto_busy);
   core : i2c_cntrl
      PORT MAP ( clock      => clock,
                 reset      => reset,
                 start      => s_start_i2c_core,
                 device_id  => s_i2c_did,
                 address    => s_i2c_addr,
                 data       => s_data_reg,
                 prescale   => s_control_reg( 15 DOWNTO 8 ),
                 data_out   => s_i2c_data_out,
                 two_phase  => s_i2c_2_phase,
                 SDA_out    => s_sda_out,
                 SDA_in     => s_sda_in,
                 SCL        => s_scl_out,
                 busy       => s_i2c_core_busy,
                 ACK_ERRORs => s_ack_errors);


END simple;
--------------------------------------------------------------------------------
--                                                                            --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY i2c_data IS
PORT ( clock      : IN  std_logic;
       reset      : IN  std_logic;
       tick       : IN  std_logic;
       data_in    : IN  std_logic_vector( 7 DOWNTO 0 );
       start      : IN  std_logic;
       data_out   : OUT std_logic_vector( 7 DOWNTO 0 );
       idle       : OUT std_logic;
       SDA_out    : OUT std_logic;
       SDA_in     : IN  std_logic;
       SCL        : OUT std_logic;
       ACK_ERROR  : OUT std_logic );
END i2c_data;

ARCHITECTURE simple OF i2c_data IS

SIGNAL s_current_state , s_next_state : std_logic_vector( 5 DOWNTO 0 );
SIGNAL s_shift_reg                    : std_logic_vector( 9 DOWNTO 0 );
SIGNAL s_sample_SDA_in                : std_logic;
SIGNAL s_data_in_reg                  : std_logic_vector( 8 DOWNTO 0 );

BEGIN
   idle      <= '1' WHEN s_current_state = "111101" ELSE '0';
   SCL       <= s_current_state(1);
   SDA_out   <= s_shift_reg(9);
   data_out  <= s_data_in_reg(8 DOWNTO 1);
   ACK_ERROR <= s_data_in_reg(0);
   
-- Here the control signals are defined
   s_sample_SDA_in <= tick WHEN s_current_state(1 DOWNTO 0) = "10" ELSE '0';
   
-- Here the data shift register is defined
   make_shift_reg : PROCESS( clock , reset , tick , data_in , start )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_shift_reg <= (OTHERS => '0');
         ELSIF (start = '1') THEN s_shift_reg <= "0"&data_in&"1";
         ELSIF (tick = '1' AND s_current_state(1 DOWNTO 0) = "00") THEN
            s_shift_reg <= s_shift_reg( 8 DOWNTO 0)&"0";
         END IF;
      END IF;
   END PROCESS make_shift_reg;
   
   make_data_in_reg : PROCESS( clock , SDA_in , s_sample_SDA_in , reset )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_data_in_reg <= (OTHERS => '0');
         ELSIF (s_sample_SDA_in = '1') THEN
            s_data_in_reg <= s_data_in_reg( 7 DOWNTO 0 )&SDA_in;
         END IF;
      END IF;
   END PROCESS make_data_in_reg;

-- Here the state machine is defined
   s_next_state <= "000000" WHEN start = '1' ELSE
                   "111101" WHEN reset = '1' OR
                                 (s_current_state = "100100" AND tick = '1') OR
                                 s_current_state = "111101" ELSE
                   s_current_state WHEN tick = '0' ELSE
                   std_logic_vector(unsigned(s_current_state)+1);
                   
   make_dffs : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         s_current_state <= s_next_state;
      END IF;
   END PROCESS make_dffs;
   
END simple;

--------------------------------------------------------------------------------
--                                                                            --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY i2c_start_stop IS
   PORT ( clock        : IN  std_logic;
          reset        : IN  std_logic;
          tick         : IN  std_logic;
          activate     : IN  std_logic;
          idle_state   : OUT std_logic;
          active_state : OUT std_logic;
          SDA          : OUT std_logic;
          SCL          : OUT std_logic);
END i2c_start_stop;

ARCHITECTURE simple OF i2c_start_stop IS

TYPE STATE_TYPE IS (IDLE,START1,START2,START3,START4,
                    ACTIVE,STOP1,STOP2,STOP3,STOP4,
                    STOP5,STOP6);

SIGNAL s_current_state , s_next_state : STATE_TYPE;

BEGIN
   idle_state   <= '1' WHEN s_current_state = IDLE ELSE '0';
   active_state <= '1' WHEN s_current_state = ACTIVE ELSE '0';
   SCL    <= '0' WHEN s_current_state = ACTIVE OR
                      s_current_state = STOP1 OR
                      s_current_state = STOP2 ELSE '1';
   SDA    <= '0' WHEN s_current_state = START3 OR
                      s_current_state = START4 OR
                      s_current_state = ACTIVE OR
                      s_current_state = STOP1 OR
                      s_current_state = STOP2 OR
                      s_current_state = STOP3 OR
                      s_current_state = STOP4 ELSE '1';
   
   -- make state machine
   make_next_state : PROCESS( s_current_state , tick , activate , 
                              reset )
   BEGIN
      IF (reset = '1') THEN s_next_state <= IDLE;
      ELSIF (activate = '1' AND s_current_state = ACTIVE) THEN
         s_next_state <= STOP1;
      ELSIF (activate = '1' AND s_current_state = IDLE) THEN
         s_next_state <= START1;
      ELSIF (tick = '0') THEN s_next_state <= s_current_state;
                         ELSE
         CASE (s_current_state) IS
            WHEN STOP1  => s_next_state <= STOP2;
            WHEN STOP2  => s_next_state <= STOP3;
            WHEN STOP3  => s_next_state <= STOP4;
            WHEN STOP4  => s_next_state <= STOP5;
            WHEN STOP5  => s_next_state <= STOP6;
            WHEN STOP6  => s_next_state <= IDLE;
            WHEN START1 => s_next_state <= START2;
            WHEN START2 => s_next_state <= START3;
            WHEN START3 => s_next_state <= START4;
            WHEN START4 => s_next_state <= ACTIVE;
            WHEN OTHERS => s_next_state <= s_current_state;
         END CASE;
      END IF;
   END PROCESS make_next_state;
   
   make_state_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         s_current_state <= s_next_state;
      END IF;
   END PROCESS make_state_reg;
END simple;


--------------------------------------------------------------------------------
--                                                                            --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY i2c_cntrl IS
   PORT ( clock      : IN  std_logic; -- Assumed a 50MHz clock
          reset      : IN  std_logic;
          start      : IN  std_logic;
          device_id  : IN  std_logic_vector( 7 DOWNTO 0 );
          address    : IN  std_logic_vector( 7 DOWNTO 0 );
          data       : IN  std_logic_vector( 7 DOWNTO 0 );
          prescale   : IN  std_logic_vector( 7 DOWNTO 0 );
          data_out   : OUT std_logic_vector( 7 DOWNTO 0 );
          two_phase  : IN  std_logic;
          SDA_out    : OUT std_logic;
          SDA_in     : IN  std_logic;
          SCL        : OUT std_logic;
          busy       : OUT std_logic;
          ACK_ERRORs : OUT std_logic_vector( 2 DOWNTO 0 ));
END i2c_cntrl;

--------------------------------------------------------------------------------

ARCHITECTURE simple OF i2c_cntrl IS

COMPONENT i2c_start_stop
   PORT ( clock        : IN  std_logic;
          reset        : IN  std_logic;
          tick         : IN  std_logic;
          activate     : IN  std_logic;
          idle_state   : OUT std_logic;
          active_state : OUT std_logic;
          SDA          : OUT std_logic;
          SCL          : OUT std_logic);
END COMPONENT;

COMPONENT i2c_data
   PORT ( clock      : IN  std_logic;
          reset      : IN  std_logic;
          tick       : IN  std_logic;
          data_in    : IN  std_logic_vector( 7 DOWNTO 0 );
          start      : IN  std_logic;
          data_out   : OUT std_logic_vector( 7 DOWNTO 0 );
          idle       : OUT std_logic;
          SDA_out    : OUT std_logic;
          SDA_in     : IN  std_logic;
          SCL        : OUT std_logic;
          ACK_ERROR  : OUT std_logic );
END COMPONENT;

TYPE STATE_TYPE IS ( IDLE,SCND,WSCND,DID,WDID,ADR,WADR,DAT,WDAT,SSCND,WSSCND );

SIGNAL s_current_state , s_next_state : STATE_TYPE;
SIGNAL s_tick_counter                 : std_logic_vector( 4 DOWNTO 0 );
SIGNAL s_prescale_counter             : std_logic_vector( 7 DOWNTO 0 );
SIGNAL s_tick_pulse                   : std_logic;
SIGNAL s_activate                     : std_logic;
SIGNAL s_idle_state                   : std_logic;
SIGNAL s_active_state                 : std_logic;
SIGNAL s_sda1,s_sda2,s_scl1,s_scl2    : std_logic;
SIGNAL s_data                         : std_logic_vector( 7 DOWNTO 0 );
SIGNAL s_start_dat                    : std_logic;
SIGNAL s_dat_idle                     : std_logic;
SIGNAL s_sda_reg,s_scl_reg            : std_logic;
SIGNAL s_ack_error                    : std_logic;
SIGNAL s_ack_errors_reg               : std_logic_vector( 2 DOWNTO 0 );

BEGIN

-- make sda and scl
   make_reg : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         s_sda_reg <= s_sda1 OR s_sda2;
         s_scl_reg <= s_scl1 OR s_scl2;
      END IF;
   END PROCESS make_reg;
   
   SDA_out    <= s_sda_reg;
   SCL        <= s_scl_reg;
   ACK_ERRORs <= s_ack_errors_reg;

-- Make tick counter
   make_counter : PROCESS( clock , reset )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_tick_counter <= (OTHERS => '1');
         ELSIF (s_prescale_counter = X"00") THEN
            s_tick_counter <= std_logic_vector(unsigned(s_tick_counter)-1);
         END IF;
      END IF;
   END PROCESS make_counter;
   
   make_prescale_counter : PROCESS( clock , reset , prescale )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_prescale_counter <= (OTHERS => '0');
         ELSIF (s_prescale_counter = X"00") THEN
            s_prescale_counter <= prescale;
                                            ELSE
            s_prescale_counter <= std_logic_vector(unsigned(s_prescale_counter)- 1);
         END IF;
      END IF;
   END PROCESS make_prescale_counter;
   
   s_tick_pulse <= '1' WHEN s_tick_counter = "00000" AND
                            s_prescale_counter = X"00" ELSE '0';
   
-- Make state machine
   make_next_state : PROCESS( s_current_state , start , s_active_state,
                              s_idle_state , s_dat_idle )
   BEGIN
      CASE (s_current_state) IS
         WHEN IDLE      => IF (start = '1') THEN s_next_state <= SCND;
                                            ELSE s_next_state <= IDLE;
                           END IF;
         WHEN SCND      => s_next_state <= WSCND;
         WHEN WSCND     => IF (s_active_state = '1') THEN s_next_state <= DID;
                                                     ELSE s_next_state <= WSCND;
                           END IF;
         WHEN DID       => s_next_state <= WDID;
         WHEN WDID      => IF (s_dat_idle = '1') THEN s_next_state <= ADR;
                                                 ELSE s_next_state <= WDID;
                           END IF;
         WHEN ADR       => s_next_state <= WADR;
         WHEN WADR      => IF (s_dat_idle = '1') THEN 
                              IF (two_phase = '1' OR
                                  device_id(0) = '1') THEN s_next_state <= SSCND;
                                                      ELSE s_next_state <= DAT;
                              END IF;
                                                 ELSE s_next_state <= WADR;
                           END IF;
         WHEN DAT       => s_next_state <= WDAT;
         WHEN WDAT      => IF (s_dat_idle = '1') THEN s_next_state <= SSCND;
                                                 ELSE s_next_state <= WDAT;
                           END IF;
         WHEN SSCND     => s_next_state <= WSSCND;
         WHEN WSSCND    => IF (s_idle_state = '1') THEN s_next_state <= IDLE;
                                                   ELSE s_next_state <= WSSCND;
                           END IF;
         WHEN OTHERS    => s_next_state <= IDLE;
      END CASE;
   END PROCESS make_next_state;
   
   make_state_reg : PROCESS( clock , reset )
   BEGIN
      IF (rising_edge(clock)) THEN 
         IF (reset = '1') THEN s_current_state <= IDLE;
                          ELSE s_current_state <= s_next_state;
         END IF;
      END IF;
   END PROCESS make_state_reg;

-- Map signals
   s_activate <= '1' WHEN s_current_state = SCND OR
                          s_current_state = SSCND ELSE '0';
   s_data     <= X"FF"   WHEN s_current_state = ADR AND
                              device_id(0) = '1' ELSE
                 address WHEN s_current_state = ADR ELSE
                 data    WHEN s_current_state = DAT ELSE
                 device_id;
   s_start_dat<= '1' WHEN s_current_state = DID OR
                          s_current_state = ADR OR
                          s_current_state = DAT ELSE '0';
   busy       <= '0' WHEN s_current_state = IDLE ELSE '1';
   
-- Define Ack errors
   make_ack_errors : PROCESS( clock , reset , start ,
                              s_current_state , s_ack_error )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (start = '1' OR
             reset = '1') THEN s_ack_errors_reg <= "000";
                          ELSE
            IF (s_current_state = ADR) THEN s_ack_errors_reg(0) <= s_ack_error;
            END IF;
            IF (s_current_state = DAT OR
                (s_current_state = SSCND AND 
                 (two_phase = '1' OR device_id(0) = '1'))) THEN
               s_ack_errors_reg(1) <= s_ack_error;
            END IF;
            IF (s_current_state = SSCND AND 
                two_phase = '0' AND device_id(0) = '0') THEN
               s_ack_errors_reg(2) <= s_ack_error;
            END IF;
         END IF;
      END IF;
   END PROCESS make_ack_errors;
   
-- Map components
   start_stop_gen : i2c_start_stop
      PORT MAP ( clock        => clock,
                 reset        => reset,
                 tick         => s_tick_pulse,
                 activate     => s_activate,
                 idle_state   => s_idle_state,
                 active_state => s_active_state,
                 SDA          => s_sda1,
                 SCL          => s_scl1);

   data_gen : i2c_data
      PORT MAP ( clock      => clock,
                 reset      => reset,
                 tick       => s_tick_pulse,
                 data_in    => s_data,
                 start      => s_start_dat,
                 data_out   => data_out,
                 idle       => s_dat_idle,
                 SDA_out    => s_sda2,
                 SDA_in     => SDA_in,
                 SCL        => s_scl2,
                 ACK_error  => s_ack_error );
END simple;

--------------------------------------------------------------------------------
--                                                                            --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY i2c_autodetect IS
   PORT ( clock         : IN  std_logic;
          reset         : IN  std_logic;
          start         : IN  std_logic;
          
          ack_errors    : IN  std_logic_vector( 2 DOWNTO 0 );
          i2c_busy      : IN  std_logic;
          start_i2cc    : OUT std_logic;
          i2c_did       : OUT std_logic_vector( 7 DOWNTO 0 );
          
          nr_of_devices : OUT std_logic_vector( 7 DOWNTO 0 );
          device_addr   : IN  std_logic_vector( 7 DOWNTO 0 );
          device_id     : OUT std_logic_vector( 7 DOWNTO 0 );
          
          busy          : OUT std_logic);
END i2c_autodetect;

--------------------------------------------------------------------------------

ARCHITECTURE simple OF i2c_autodetect IS

   TYPE STATE_TYPE IS (IDLE,START_I2C,WAIT_I2C,UPDATE,NEXT_DID);
   TYPE RAM_TYPE IS ARRAY(255 DOWNTO 0) OF std_logic_vector(6 DOWNTO 0);
   
   SIGNAL s_did_counter_reg            : std_logic_vector( 6 DOWNTO 0 );
   SIGNAL s_current_state,s_next_state : STATE_TYPE;
   SIGNAL s_device_count_reg           : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_device_found               : std_logic;
   SIGNAL ram                          : RAM_TYPE;
   SIGNAL s_ram_address                : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_ram_read_address           : std_logic_vector( 7 DOWNTO 0 );
   
BEGIN
   -- Here the outputs are defined
   busy          <= '0' WHEN s_current_state = IDLE ELSE '1';
   i2c_did       <= s_did_counter_reg&"0";
   start_i2cc    <= '1' WHEN s_current_state = START_I2C ELSE '0';
   nr_of_devices <= s_device_count_reg;
   
   -- Assign control signals
   s_device_found <= '1' WHEN s_current_state = UPDATE AND
                              ack_errors = "000" ELSE '0';
   s_ram_address  <= device_addr WHEN s_current_state = IDLE ELSE
                     s_device_count_reg;
   
   -- Make device counter
   make_dev_count : PROCESS( clock , reset , start ,s_device_found )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1' OR start = '1') THEN
            s_device_count_reg <= (OTHERS => '0');
         ELSIF (s_device_found = '1') THEN
            s_device_count_reg <= std_logic_vector(unsigned(s_device_count_reg)+1);
         END IF;
      END IF;
   END PROCESS make_dev_count;
                             
   
   -- Make the did counter
   make_did : PROCESS( reset , start , clock , s_current_state )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1' OR start = '1') THEN
            s_did_counter_reg <= (OTHERS => '0');
         ELSIF (s_current_state = NEXT_DID) THEN
            s_did_counter_reg <= std_logic_vector(unsigned(s_did_counter_reg)+1);
         END IF;
      END IF;
   END PROCESS make_did;
   
   -- Here the memory is defined
   ramproc : PROCESS( clock )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (s_device_found = '1') THEN
            ram(to_integer(unsigned(s_ram_address))) <= s_did_counter_reg;
         END IF;
         s_ram_read_address <= s_ram_address;
      END IF;
   END PROCESS ramproc;
   
   device_id(7 DOWNTO 1) <= ram(to_integer(unsigned(s_ram_read_address)));
   device_id(0)          <= '0';
   
   -- Here the state machine is defined
   make_next_state : PROCESS( s_current_state , i2c_busy , s_did_counter_reg ,
                              start )
   BEGIN
      CASE (s_current_state) IS
         WHEN IDLE      => IF (start = '1') THEN s_next_state <= START_I2C;
                                            ELSE s_next_state <= IDLE;
                           END IF;
         WHEN START_I2C => s_next_state <= WAIT_I2C;
         WHEN WAIT_I2C  => IF (i2c_busy = '1') THEN s_next_state <= WAIT_I2C;
                                               ELSE s_next_state <= UPDATE;
                           END IF;
         WHEN UPDATE    => s_next_state <= NEXT_DID;
         WHEN NEXT_DID  => IF (s_did_counter_reg = "1111111") THEN 
                              s_next_state <= IDLE;
                                                              ELSE
                              s_next_state <= START_I2C;
                           END IF;
         WHEN OTHERS    => s_next_state <= IDLE;
      END CASE;
   END PROCESS make_next_state;
   
   make_state_reg : PROCESS( clock , reset , s_next_state )
   BEGIN
      IF (rising_edge(clock)) THEN
         IF (reset = '1') THEN s_current_state <= IDLE;
                          ELSE s_current_state <= s_next_state;
         END IF;
      END IF;
   END PROCESS make_state_reg;
END simple;
