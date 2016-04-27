--------------------------------------------------------------------------------
--- Entity definitions                                                       ---
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY custom_instr_template IS
   PORT ( -- Combinational
          dataa       : IN  std_logic_vector( 31 DOWNTO 0 );
          datab       : IN  std_logic_vector( 31 DOWNTO 0 );
          result      : OUT std_logic_vector( 31 DOWNTO 0 );
          -- Multi-cycle
          clk         : IN  std_logic;
          clk_en      : IN  std_logic;
          reset       : IN  std_logic;
          start       : IN  std_logic;
          done        : OUT std_logic;
          -- Extended
          opcode_n    : IN  std_logic_vector(  7 DOWNTO 0 ) );
END custom_instr_template;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY counter IS
   GENERIC ( nr_of_bits : INTEGER := 16);
   PORT ( clock           : IN  std_logic;
          reset           : IN  std_logic;
          start_and_reset : IN  std_logic;
          stop            : IN  std_logic;
          pause_resume    : IN  std_logic;
          counter_value   : OUT std_logic_vector( (nr_of_bits - 1) DOWNTO 0 ));
END counter;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY grayscale_ciu IS
   PORT ( rgb_in    : IN  std_logic_vector( 31 DOWNTO 0 );
          grayscale : OUT std_logic_vector( 31 DOWNTO 0 ) );
END grayscale_ciu;
--------------------------------------------------------------------------------
--- Functionality                                                            ---
--------------------------------------------------------------------------------

ARCHITECTURE template OF custom_instr_template IS

   -- This template implements 3 custom instrunctions:
   -- n=0 => Start counter(s). This custom instruction takes from register
   --        A a bitmask which counter to reset/start (bits 3..0)
   -- n=1 => Stop counter(s). This custom instruction takes from register
   --        A a bitmask which counter to stop (bits 3..0)
   -- n=2 => Pause/resume counter(s). This custom instruction takes from register
   --        A a bitmask which counter to pause/resume (bits 3..0)
   -- n=3 => Read counter. This custom instruction takes the binairy index
   --        from register A and returns the value of the selected counter
   --        (bits 1..0)
   -- n=4 => Grayscale custom instruction. This instruction takes the rgb-value
   --        from register B and returns the grayscale value

   COMPONENT counter
      GENERIC ( nr_of_bits : INTEGER );
      PORT ( clock           : IN  std_logic;
             reset           : IN  std_logic;
             start_and_reset : IN  std_logic;
             stop            : IN  std_logic;
             pause_resume    : IN  std_logic;
             counter_value   : OUT std_logic_vector( (nr_of_bits - 1) DOWNTO 0 ));
   END COMPONENT;
   
   COMPONENT grayscale_ciu
      PORT ( rgb_in    : IN  std_logic_vector( 31 DOWNTO 0 );
             grayscale : OUT std_logic_vector( 31 DOWNTO 0 ) );
   END COMPONENT;
   
   SIGNAL s_counter_1_value : std_logic_vector( 31 DOWNTO 0 );
   SIGNAL s_counter_2_value : std_logic_vector( 31 DOWNTO 0 );
   SIGNAL s_counter_3_value : std_logic_vector( 31 DOWNTO 0 );
   SIGNAL s_counter_4_value : std_logic_vector( 31 DOWNTO 0 );
   SIGNAL s_counter_starts  : std_logic_vector(  3 DOWNTO 0 );
   SIGNAL s_counter_stops   : std_logic_vector(  3 DOWNTO 0 );
   SIGNAL s_counter_pa_re   : std_logic_vector(  3 DOWNTO 0 );
   
   SIGNAL s_grayscale_value : std_logic_vector( 31 DOWNTO 0 );
   
BEGIN
   --Do the result multiplexing
   make_result : PROCESS( opcode_n , s_counter_1_value , s_counter_2_value ,
                          s_counter_3_value , s_counter_4_value ,
                          s_grayscale_value )
   BEGIN
      CASE (opcode_n) IS
         WHEN  X"03"    => CASE (dataa( 1 DOWNTO 0)) IS
                              WHEN  "00"  => result <= s_counter_1_value;
                              WHEN  "01"  => result <= s_counter_2_value;
                              WHEN  "10"  => result <= s_counter_3_value;
                              WHEN OTHERS => result <= s_counter_4_value;
                           END CASE;
         WHEN X"04"     => result <= s_grayscale_value;
         WHEN OTHERS    => result <= (OTHERS => '0');
      END CASE;
   END PROCESS make_result;


   -- Make sure that the CPU does get always a done during start
   done              <= start;

   -- define the control signals
   s_counter_starts  <= dataa(3 DOWNTO 0) WHEN clk_en = '1' AND
                                               start = '1' AND
                                               opcode_n = X"00" ELSE X"0";
   s_counter_stops   <= dataa(3 DOWNTO 0) WHEN clk_en = '1' AND
                                               start = '1' AND
                                               opcode_n = X"01" ELSE X"0";
   s_counter_pa_re   <= dataa(3 DOWNTO 0) WHEN clk_en = '1' AND
                                               start = '1' AND
                                               opcode_n = X"02" ELSE X"0";
                                               
   -- Map the components
   counter1 : counter
      GENERIC MAP ( nr_of_bits => 32 )
      PORT MAP ( clock           => clk,
                 reset           => reset,
                 start_and_reset => s_counter_starts(0),
                 stop            => s_counter_stops(0),
                 pause_resume    => s_counter_pa_re(0),
                 counter_value   => s_counter_1_value);

   counter2 : counter
      GENERIC MAP ( nr_of_bits => 32 )
      PORT MAP ( clock           => clk,
                 reset           => reset,
                 start_and_reset => s_counter_starts(1),
                 stop            => s_counter_stops(1),
                 pause_resume    => s_counter_pa_re(1),
                 counter_value   => s_counter_2_value);

   counter3 : counter
      GENERIC MAP ( nr_of_bits => 32 )
      PORT MAP ( clock           => clk,
                 reset           => reset,
                 start_and_reset => s_counter_starts(2),
                 stop            => s_counter_stops(2),
                 pause_resume    => s_counter_pa_re(2),
                 counter_value   => s_counter_3_value);

   counter4 : counter
      GENERIC MAP ( nr_of_bits => 32 )
      PORT MAP ( clock           => clk,
                 reset           => reset,
                 start_and_reset => s_counter_starts(3),
                 stop            => s_counter_stops(3),
                 pause_resume    => s_counter_pa_re(3),
                 counter_value   => s_counter_4_value);

   slides_example : grayscale_ciu
      PORT MAP ( rgb_in    => dataa,
                 grayscale => s_grayscale_value );


END template;


ARCHITECTURE no_platform_specific OF counter IS

   SIGNAL s_current_count_value : std_logic_vector((nr_of_bits - 1) DOWNTO 0 );
   SIGNAL s_next_count_value    : std_logic_vector((nr_of_bits - 1) DOWNTO 0 );
   SIGNAL s_count_enable_reg    : std_logic;

BEGIN
   -- Here we define the output
   counter_value <= s_current_count_value;

   -- First we define the enable register
   make_enable_reg : PROCESS( clock , reset , start_and_reset , stop , 
                              pause_resume , s_count_enable_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             (pause_resume = '1' AND s_count_enable_reg = '1') OR
             stop = '1') THEN s_count_enable_reg <= '0';
         ELSIF ((pause_resume = '1' AND s_count_enable_reg = '0') OR
                start_and_reset = '1') THEN s_count_enable_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_enable_reg;
   
   -- Here we define the update logic for the counter FSM
   s_next_count_value <= (OTHERS => '0') WHEN reset = '1' OR
                                              start_and_reset = '1' ELSE
                         unsigned(s_current_count_value) + 1 WHEN s_count_enable_reg = '1' ELSE
                         s_current_count_value;
   
   -- Here we define the dffs of the counter FSM
   make_ffs : PROCESS( clock , s_next_count_value )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         s_current_count_value <= s_next_count_value;
      END IF;
   END PROCESS make_ffs;
   
END no_platform_specific;



ARCHITECTURE MSE OF grayscale_ciu IS

   SIGNAL s_red_value  : std_logic_vector(  5 DOWNTO 0 );
   SIGNAL s_red_pp1    : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_red_pp2    : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_red_pp3    : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_red_sum1   : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_red_sum2   : std_logic_vector( 13 DOWNTO 0 );
   
   SIGNAL s_blue_value : std_logic_vector(  5 DOWNTO 0 );
   SIGNAL s_blue_pp1   : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_blue_pp2   : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_blue_pp3   : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_blue_sum1  : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_blue_sum2  : std_logic_vector( 13 DOWNTO 0 );

   SIGNAL s_green_value : std_logic_vector(  5 DOWNTO 0 );
   SIGNAL s_green_pp1   : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_green_pp2   : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_green_pp3   : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_green_pp4   : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_green_pp5   : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_green_sum1a : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_green_sum1b : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_green_sum2  : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_green_sum3  : std_logic_vector( 13 DOWNTO 0 );
   
   SIGNAL s_gray_add_1  : std_logic_vector( 13 DOWNTO 0 );
   SIGNAL s_gray_add_2  : std_logic_vector( 13 DOWNTO 0 );

BEGIN

   -- Constant multipliction of red*00100110b
   s_red_value <= rgb_in( 5 DOWNTO 0 );
   s_red_pp1   <= "0000000"&s_red_value&"0"; -- red*00000010b
   s_red_pp2   <= "000000"&s_red_value&"00"; -- red*00000100b
   s_red_pp3   <= "000"&s_red_value&"00000"; -- red*00100000b
   s_red_sum1  <= unsigned(s_red_pp1)+unsigned(s_red_pp2);
   s_red_sum2  <= unsigned(s_red_sum1)+unsigned(s_red_pp3);
   
   -- Constant multiplication of blue*00011100b
   s_blue_value <= rgb_in(21 DOWNTO 16);
   s_blue_pp1   <= "000000"&s_blue_value&"00"; -- blue*00000100b
   s_blue_pp2   <= "00000"&s_blue_value&"000"; -- blue*00001000b
   s_blue_pp3   <= "0000"&s_blue_value&"0000"; -- blue*00010000b
   s_blue_sum1  <= unsigned(s_blue_pp1)+unsigned(s_blue_pp2);
   s_blue_sum2  <= unsigned(s_blue_sum1)+unsigned(s_blue_pp3);
   
   -- Constant multiplication of green*10010111
   s_green_value <= rgb_in(13 DOWNTO 8);
   s_green_pp1   <= "00000000"&s_green_value; -- green*00000001b
   s_green_pp2   <= "0000000"&s_green_value&"0"; -- green*00000010b
   s_green_pp3   <= "000000"&s_green_value&"00"; -- green*00000100b
   s_green_pp4   <= "0000"&s_green_value&"0000"; -- green*00010000b
   s_green_pp5   <= "0"&s_green_value&"0000000"; -- green*10000000b
   s_green_sum1a <= unsigned(s_green_pp1)+unsigned(s_green_pp2);
   s_green_sum1b <= unsigned(s_green_pp3)+unsigned(s_green_pp4);
   s_green_sum2  <= unsigned(s_green_sum1a)+unsigned(s_green_sum1b);
   s_green_sum3  <= unsigned(s_green_sum2)+unsigned(s_green_pp5);
   
   -- Do final addition
   s_gray_add_1 <= unsigned(s_red_sum2)+unsigned(s_blue_sum2);
   s_gray_add_2 <= unsigned(s_gray_add_1)+unsigned(s_green_sum3);
   
   -- set output
   grayscale <= X"00"&"00"&s_gray_add_2(13 DOWNTO 8)&"00"&s_gray_add_2(13 DOWNTO 8)&"00"&s_gray_add_2(13 DOWNTO 8);
END MSE;
