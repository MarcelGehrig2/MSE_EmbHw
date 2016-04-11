--Simon Fourquier 09/11/2013

                
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity LCD_tb is
	generic ( FIFOSIZE : integer:= 8;
              ERRNO    : integer := 0 );
end LCD_tb;

architecture testbench of LCD_tb is

-- instantiation of a fake not synthesisable DUT
component LCD_ctrl_fake is
	generic ( FIFOSIZE : integer := 8;
              ERRNO : integer := 0 );
	port (
		clk               : in    std_logic;     
		avalon_address    : in    std_logic_vector(1 downto 0);
		avalon_cs         : in    std_logic;  	
		avalon_wr         : in    std_logic;  
		avalon_waitreq	  : out   std_logic;
		avalon_write_data : in    std_logic_vector(15 downto 0);
		reset             : in    std_logic;      
		LCD_data          : inout std_logic_vector(15 downto 0);
		LCD_WR_n	      : out   std_logic;				
		LCD_RD_n	      : out   std_logic;				
		LCD_D_C_n	      : out   std_logic 
	);
end component;


-- Replace this component by your LCD_controller!!!

component LCD_ctrl is
	port (
		clk               : in    std_logic;     
		avalon_address    : in    std_logic_vector(1 downto 0);
		avalon_cs         : in    std_logic;  	
		avalon_wr         : in    std_logic;  
		avalon_waitreq	  : out   std_logic;
		avalon_write_data : in    std_logic_vector(15 downto 0);
		reset             : in    std_logic;      
		LCD_data          : inout std_logic_vector(15 downto 0);
		LCD_WR_n	      : out   std_logic;				
		LCD_RD_n	      : out   std_logic;				
		LCD_D_C_n	      : out   std_logic 
	);
end component;

signal clk_sti               :   std_logic                    := '0';     
signal avalon_address_sti    :   std_logic_vector(1 downto 0) := (others => '0');
signal avalon_cs_sti         :   std_logic                    := '0';  		
signal avalon_rd_sti         :   std_logic                    := '0';  
signal avalon_wr_sti         :   std_logic                    := '0';  
signal avalon_write_data_sti :   std_logic_vector(15 downto 0) := (others => '0');		
signal reset_sti             :   std_logic                    := '0';  
 
signal LCD_data           : std_logic_vector(15 downto 0) := (others => 'Z');
signal avalon_waitreq_obs :   std_logic; --FIXME to be tested?
signal LCD_WR_n_obs	      :    std_logic ;				
signal LCD_RD_n_obs	      :    std_logic ;				
signal LCD_D_C_n_obs	  :    std_logic ; 


constant CLK_PERIOD : time := 20 ns;
constant TWDS80 : time := 5 ns;
constant TWLW80: time := 22.5 ns;
constant TCYCW80: time := 65 ns;
constant TIME_OUT_WAITREQ : integer :=100;

signal LCD_WR_n_old:std_logic ;
 
signal sim_end_s : boolean := false;

--shared variable fifo: work.my_tlm_pkg.tlm_fifo_type;

begin

	LCD_WR_n_old<=LCD_WR_n_obs'delayed;

	test_proc: process is
		variable temps_down_LCD_WR_n :time:=TCYCW80; --temp que WR a passer a 0 initialiser avec TCYCW80 car aux premier flanc decandant de WR le temp de periode min n'a pas besoin dètre verifier (l'assert passera)
					
		--convertie un std_logic_vector en string represantant la valeur binaire sous la forme "00101100011010"
		function image_std_logic_vector(vector : in std_logic_vector) return string is
			variable image_vector : string(1 to vector'LENGTH);
		begin
			for num_bit in vector'RANGE loop
				--normalement devrait fonctionner avec tous les std_logic_vector meme si vector'low n'est pas 0
				image_vector(image_vector'HIGH-(num_bit-vector'LOW)):=std_logic'image(vector(num_bit))(2);
			end loop;
			return image_vector;
		end image_std_logic_vector;

		procedure test is
		
			variable data_fifo : std_logic_vector(16 downto 0); --fifo ou est stocker les data envoyer et le et LCD_D_C_n_obs (LCD_D_C_n_obs est le bit 0)
			variable ok: boolean;
			variable temps_up_LCD_WR_n :time:=0 ns;
			variable temps_periode_LCD_WR_n :time:=0 ns;
					
			begin
		
			wait until falling_edge(LCD_WR_n_obs) or (sim_end_s); --flanc montant ou fin simulation
			if falling_edge(LCD_WR_n_obs) then --flanc montant
									
				temps_up_LCD_WR_n:=LCD_WR_n_old'LAST_EVENT; --temps que le WR a passer a 1
				
				temps_periode_LCD_WR_n:=temps_down_LCD_WR_n+temps_up_LCD_WR_n;
				
				assert (temps_periode_LCD_WR_n>=TCYCW80) report "LCD_WR_n_obs has had a period of "& 
				time'image(temps_periode_LCD_WR_n) & 
				", the minimal period is " & 
				time'image(TCYCW80) severity ERROR;
				
				assert (LCD_WR_n_old'STABLE(TWLW80)) report "LCD_WR_n_obs is staying "& 
				time'image(LCD_WR_n_old'LAST_EVENT) & 
				" in high state, the minimum number is " & 
				time'image(TWLW80) severity ERROR;
			
				--assert (LCD_data'DELAYED(TWDS80*1.5)=(LCD_data'range=>'Z')) report "la valeur de LCD_data n'estpas  passé par z "& 
				assert (LCD_data'DELAYED(TWDS80*1.5)=(LCD_data)) report "Propagation time not respected "& 
				time'image(TWDS80);
			
				assert (LCD_data'STABLE(TWDS80)) report "LCD_data has changed "& 
				time'image(LCD_data'LAST_EVENT) & 
				" befor the falling edge of LCD_WR_n_obs, the minimal time is " & 
				time'image(TWDS80) severity ERROR;
				
				assert (LCD_D_C_n_obs'STABLE(TWDS80)) report "LCD_D_C_n_obs has changed "& 
				time'image(LCD_D_C_n_obs'LAST_EVENT) & 
				" befor the falling edge of LCD_WR_n_obs, the minimal time is " & 
				time'image(2*TWDS80) severity ERROR;
				
	--			assert (not fifo.is_empty) report "flanc decandant sur LCD_WR_n_obs alor qu'aucune data n'a été envoyé"
--				severity ERROR;
								
--				fifo.get(data_fifo,ok);
--				if(ok) then
--					assert (LCD_data=data_fifo(16 downto 1)) report "Data recu =" & image_std_logic_vector(LCD_data) & 
--					"alor que data envoyé =" & image_std_logic_vector(data_fifo(16 downto 1)) severity ERROR;
--					assert (LCD_D_C_n_obs=data_fifo(0)) report "LCD_D_C_n_obs =" & std_logic'image(LCD_D_C_n_obs) & 
--					"alor qu'il devrait ètre egale à" & std_logic'image(data_fifo(0)) severity ERROR;
--				else
--					report "erreur fifo" severity ERROR;
--				end if;
				
				wait until rising_edge(LCD_WR_n_obs) or (sim_end_s); --flanc decandant ou fin simulation
				if rising_edge(LCD_WR_n_obs) then --flanc decandant
								
					temps_down_LCD_WR_n:=LCD_WR_n_old'LAST_EVENT;
				
					assert (LCD_WR_n_old'STABLE(TWLW80)) report "LCD_WR_n_obs is stucked"& 
					time'image(LCD_WR_n_old'LAST_EVENT) & 
					" to ground, the minimal time is " & 
					time'image(TWLW80) severity ERROR;
				
					wait for TWDS80;
				
					assert (LCD_D_C_n_obs'LAST_EVENT>TWDS80+temps_down_LCD_WR_n) report "The value of LCD_D_C_n_obs has changed between the falling en rising edges of LCD_WR_n_old at least "& 
					time'image(TWDS80) & " after resing edge"  severity ERROR;
					
					assert (LCD_data'LAST_EVENT>TWDS80+temps_down_LCD_WR_n) report "The value of LCD_data has changed between the falling en rising edges of LCD_WR_n_old at least"& 
					time'image(TWDS80) & " after resing edge"  severity ERROR;
					
					
				end if;
			end if;
		end test;
		
	variable ref_LCD_data_s			:std_logic_vector(15 downto 0);
	variable ref_avalon_waitreq_s :std_logic;
	variable ref_LCD_WR_n_s			:std_logic;
	variable ref_LCD_RD_n_s			:std_logic;
	variable ref_LCD_D_C_n_s		:std_logic; 
		
	begin

		while(not sim_end_s) loop
			test;
		end loop;
--		assert (fifo.is_empty) report "certainent donné n'on pas été envoyer "
--					severity ERROR;
		wait;
	end process;
	
	process
		variable ok: boolean;
		variable avalon_wr_old: std_logic;
	begin
		while(not sim_end_s) loop
			wait until rising_edge(clk_sti) or (sim_end_s);
			if rising_edge(clk_sti) then
				if avalon_address_sti(1)='0' and avalon_cs_sti='1' and avalon_wr_sti='1' and avalon_wr_old='0' then
--					fifo.put(avalon_write_data_sti&avalon_address_sti(0),ok);
--					assert (ok) report "erreur TB fifo returne ok='0' (fifo full)" severity ERROR;
				end if;
				avalon_wr_old:=avalon_wr_sti;
			end if;
		end loop;
		wait;
		
	end process;


	process
	
		procedure cycle(nb_cycles: integer := 1) is
		begin
			for i in 1 to nb_cycles loop
				wait until rising_edge(clk_sti);
			end loop;
		end cycle;	
		
		procedure wait_waitreq is
			variable timout: integer;
		begin
			--pas sur que wait requeste doit être a 1 une fois il faudrait verifier le protocole avalon
			assert (avalon_waitreq_obs'DELAYED = '1') report "Please verify your wait_request signal. It is not sur it is working correctly in here."
				severity WARNING;
			timout:=0;
			loop
				timout:=timout+1;
				EXIT WHEN avalon_waitreq_obs = '0';
				if timout>TIME_OUT_WAITREQ then
					report "avalon_waitreq_obs got stuck for more than "&
					integer'image(TIME_OUT_WAITREQ) &" I'm quiting simulation";
					sim_end_s <= true;
					wait;
				end if;
				cycle(1);
			end loop;
		end wait_waitreq;
		
--genere les stimuli
		procedure stimuli(
			avalon_address_s		:   std_logic_vector(1 downto 0);
			avalon_cs_s				:   std_logic;
			avalon_rd_s				:   std_logic; 
			avalon_wr_s				:   std_logic;
			avalon_write_data_s	:   std_logic_vector(15 downto 0)) is
		begin
		
			avalon_address_sti<=avalon_address_s;
			avalon_cs_sti<=avalon_cs_s;
			--avalon_rd_sti<=avalon_rd_s; garder pour un prochain TB sur avalon)
			avalon_rd_sti<='0'; --ne pas tester la lecture
			avalon_wr_sti<=avalon_wr_s;
			avalon_write_data_sti<=avalon_write_data_s;
		
		end stimuli;
		


		variable seed1, seed2: positive;
		variable rand: real;
		variable int_rand: integer;
		variable rand_address_s  : std_logic_vector ( avalon_address_sti'range );
		variable rand_data_s     : std_logic_vector ( avalon_write_data_sti'range );
		variable rand_bit_s : std_logic_vector ( 2 downto 0 );
		begin
	
		stimuli("00",'0','0','0',x"FFAA");
		cycle(5);
		
		--envoit rapidement des donner pour utiliser le fifo
		for i in 1 to 20 loop
			stimuli("00",'1','0','1',std_logic_vector(to_unsigned(i,avalon_write_data_sti'length)));
			cycle(1);
			wait_waitreq;
			stimuli("00",'0','0','0',x"FFAA");
			cycle(1);
		end loop;
			
		for i in 1 to 20 loop
		
			--genere des nombres aleatoire
			uniform(seed1,seed2,rand);
			int_rand:=INTEGER(TRUNC(rand*(2.0**rand_address_s'length )));
			rand_address_s := std_logic_vector(to_unsigned(int_rand,rand_address_s'length));
			
			uniform(seed1,seed2,rand);
			int_rand:=INTEGER(TRUNC(rand*(2.0**rand_data_s'length )));
			rand_data_s := std_logic_vector(to_unsigned(int_rand,rand_data_s'length));
			
			--genere un nombre pour tous les bit
			uniform(seed1,seed2,rand);
			int_rand:=INTEGER(TRUNC(rand*(2.0**rand_bit_s'length )));
			rand_bit_s := std_logic_vector(to_unsigned(int_rand,rand_bit_s'length));
		
			stimuli(rand_address_s,rand_bit_s(2),rand_bit_s(1),rand_bit_s(0),rand_data_s);
			
			cycle(1);
			
			--si on fait une lecture ou ecriture
			if avalon_cs_sti='1' and (avalon_wr_sti='1' or avalon_rd_sti='1') then
				wait_waitreq;
			end if;
			
			stimuli("00",'0','0','0',x"FFAA");

			uniform(seed1,seed2,rand);
			int_rand:=INTEGER(TRUNC(rand*(20.0)));
			
			cycle(int_rand); --attend antre 0 et 20 clk avant le prochaine envoit sur le bus avalon
		end loop;
		
		cycle(100); --atend que tous les data soit envoyer
		sim_end_s <= true; --fin de simulation
		wait;
	end process;

	process
	begin
		reset_sti <= '1';
		wait for CLK_PERIOD*2;
		reset_sti <= '0';
		wait;
	end process;
	
	process
	begin
		clk_sti <= '0';
		wait for CLK_PERIOD/2;
		clk_sti <= '1';
		wait for CLK_PERIOD/2;
		if (sim_end_s) then
			wait;
		end if;
	end process;



----- THE DESIGN UNDER TEST- REPLACE THE FAKE DUT BY YOURS -----

--fake_dut: LCD_ctrl
fake_dut: LCD_ctrl_fake
	generic map( FIFOSIZE => FIFOSIZE,
              ERRNO => ERRNO )
  
	port map(
		clk              => clk_sti,
		avalon_address   => avalon_address_sti,
		avalon_cs        => avalon_cs_sti,
		avalon_wr        => avalon_wr_sti,
		avalon_waitreq	  => avalon_waitreq_obs,
		avalon_write_data => avalon_write_data_sti,
		reset            => reset_sti,
		LCD_data         => LCD_data,
		LCD_WR_n	  => LCD_WR_n_obs,
		LCD_RD_n	  => LCD_RD_n_obs,
		LCD_D_C_n	  => LCD_D_C_n_obs
	);
	
end testbench; 
