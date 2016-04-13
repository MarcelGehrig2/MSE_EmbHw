ARCHITECTURE MSE OF lcd_avalon_slave IS

   TYPE LCD_READ_TYPE IS (IDLE, WAITBUSY, INITREAD, WAITREAD, RELEASE);

   COMPONENT SendReceiveInterface IS
      PORT (  -- Here the internal interface is defined
             Clock                 : IN    std_logic;
             Reset                 : IN    std_logic;
             ResetDisplay          : IN    std_logic;
             StartSendReceive      : IN    std_logic;
             CommandBarData        : IN    std_logic;
             EightBitSixteenBitBar : IN    std_logic;
             WriteReadBar          : IN    std_logic;
             DataToSend            : IN    std_logic_vector(15 DOWNTO 0);
             DataReceived          : OUT   std_logic_vector(15 DOWNTO 0);
             busy                  : OUT   std_logic;
             -- Here the external LCD-panel signals are defined
             ChipSelectBar         : OUT   std_logic;
             DataCommandBar        : OUT   std_logic;
             WriteBar              : OUT   std_logic;
             ReadBar               : OUT   std_logic;
             ResetBar              : OUT   std_logic;
             IM0                   : OUT   std_logic;
             DataBus               : INOUT std_logic_vector(15 DOWNTO 0));
   END COMPONENT;

   SIGNAL s_WriteReadBar     : std_logic;
   SIGNAL s_StartSendReceive : std_logic;
   SIGNAL s_CommandBarData   : std_logic;
   SIGNAL s_busy             : std_logic;
   SIGNAL s_control_reg      : std_logic_vector(31 DOWNTO 0);
   SIGNAL s_control_next     : std_logic_vector(31 DOWNTO 0);
   SIGNAL s_LCD_data_out     : std_logic_vector(15 DOWNTO 0);
   SIGNAL s_current_state    : LCD_READ_TYPE;
   SIGNAL s_next_state       : LCD_READ_TYPE;
   SIGNAL s_reset_display    : std_logic;

BEGIN
--------------------------------------------------------------------------------
---                                                                          ---
--- In this section the avalon slave signals are defined                     ---
---                                                                          ---
--------------------------------------------------------------------------------
    AVSlave_rd_DO <= s_control_reg WHEN AVSlave_addr_DI = "10" ELSE
                       X"0000"&s_LCD_data_out
                          WHEN AVSlave_addr_DI(1) = '0' ELSE
                       (OTHERS => '0');
    
    AVSlave_wtReq_SO <= '1' WHEN AVSlave_cs_SI = '1' AND
                                   AVSlave_addr_DI(1) = '0' AND
                                   ((AVSlave_we_SI = '1' AND
                                     s_busy = '1') OR
                                    (AVSlave_rd_SI = '1' AND
                                     s_current_state /= RELEASE)) ELSE '0';


--------------------------------------------------------------------------------
---                                                                          ---
--- In this section the LCD-read state machine is defined                    ---
---                                                                          ---
--------------------------------------------------------------------------------

   make_next_state : PROCESS(s_current_state, AVSlave_cs_SI, AVSlave_addr_DI,
                              AVSlave_rd_SI, s_busy)
   BEGIN
      CASE (s_current_state) IS
         WHEN IDLE => IF (AVSlave_cs_SI = '1' AND
                                  AVSlave_addr_DI(1) = '0' AND
                                  AVSlave_rd_SI = '1') THEN
                                 s_next_state <= WAITBUSY;
                                                  ELSE
                                 s_next_state <= IDLE;
                              END IF;
         WHEN WAITBUSY => IF (s_busy = '1') THEN
                                 s_next_state <= WAITBUSY;
                                                ELSE
                                 s_next_state <= INITREAD;
                              END IF;
         WHEN INITREAD => s_next_state <= WAITREAD;
         WHEN WAITREAD => IF (s_busy = '1') THEN
                                 s_next_state <= WAITREAD;
                                                ELSE
                                 s_next_state <= RELEASE;
                              END IF;
         WHEN OTHERS => s_next_state <= IDLE;
      END CASE;
   END PROCESS make_next_state;

   make_current_state : PROCESS(Clk50_CI)
   BEGIN
      IF (rising_edge(Clk50_CI)) THEN
         IF (Reset_RI = '1') THEN s_current_state <= IDLE;
                          ELSE s_current_state <= s_next_state;
         END IF;
      END IF;
   END PROCESS make_current_state;

--------------------------------------------------------------------------------
---                                                                          ---
--- In this section the control register is defined                          ---
---                                                                          ---
--------------------------------------------------------------------------------
   s_control_next <= AVSlave_we_DI WHEN AVSlave_we_SI = '1' AND
                                           AVSlave_cs_SI = '1' AND
                                           AVSlave_addr_DI = "10" ELSE
                     s_control_reg;
   
   make_control_reg : PROCESS(Clk50_CI)
   BEGIN
      IF (rising_edge(Clk50_CI)) THEN
         IF (Reset_RI = '1') THEN s_control_reg <= (OTHERS => '0');
                          ELSE s_control_reg <= s_control_next;
         END IF;
      END IF;
   END PROCESS make_control_reg;

--------------------------------------------------------------------------------
---                                                                          ---
--- In this section all control signals are defined                          ---
---                                                                          ---
--------------------------------------------------------------------------------

   s_WriteReadBar <= AVSlave_we_SI;

   s_CommandBarData <= AVSlave_addr_DI(0);
   
   s_StartSendReceive <= '1' WHEN (AVSlave_we_SI = '1' AND
                                   AVSlave_cs_SI = '1' AND
                                   AVSlave_addr_DI(1) = '0' AND
                                   s_busy = '0') OR
                                  (s_current_state = INITREAD) ELSE '0';
   s_reset_display <= '1' WHEN AVSlave_we_SI = '1' AND
                                  AVSlave_cs_SI = '1' AND
                                  AVSlave_addr_DI = "10" AND
                                  AVSlave_we_DI(1) = '1' ELSE '0';

--------------------------------------------------------------------------------
---                                                                          ---
--- In this section all components are connected                             ---
---                                                                          ---
--------------------------------------------------------------------------------

   interface : SendReceiveInterface
      PORT MAP (Clock                  => Clk50_CI,
                 Reset                 => Reset_RI,
                 ResetDisplay          => s_reset_display,
                 StartSendReceive      => s_StartSendReceive,
                 CommandBarData        => s_CommandBarData,
                 EightBitSixteenBitBar => s_control_reg(0),
                 WriteReadBar          => s_WriteReadBar,
                 DataToSend            => AVSlave_we_DI(15 downto 0),
                 DataReceived          => s_LCD_data_out,
                 busy                  => s_busy,
                 -- Here the external LCD-panel signals are defined
                 ChipSelectBar         => LCD_cs_SBO,
                 DataCommandBar        => LCD_DaCmd_SBO,
                 WriteBar              => LCD_we_SBO,
                 ReadBar               => LCD_rd_SBO,
                 ResetBar              => LCD_Reset_RBO,
                 IM0                   => LCD_IM0_SO,
                 DataBus               => LCD_data_IO);

END MSE;
