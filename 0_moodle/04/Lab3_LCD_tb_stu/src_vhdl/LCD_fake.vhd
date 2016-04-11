
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LCD_ctrl_fake is
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
end entity LCD_ctrl_fake;

architecture simulation of LCD_ctrl_fake is

	signal avalon_wr_1 : std_logic;

	type fifo_type is array(0 to FIFOSIZE-1) of std_logic_vector(16 downto 0);
	signal fifo_s : fifo_type;

	type shared_int is protected
		procedure incr;
		procedure decr;
		impure function getvalue return integer;
	end protected shared_int;
	
	
	type shared_int is protected body
	
		variable value : integer := 0;
		procedure incr is
		begin
			value := value +1;
		end incr;
		procedure decr is
		begin
			value := value -1;
		end decr;
		
		impure function getvalue return integer is
		begin
			return value;
		end getvalue;
		
	end protected body shared_int;
	
	shared variable nb_words      : shared_int;
	
	
	signal tWDS80  : time := 5 ns;
	signal tWLW80  : time := 22.5 ns;
	signal tWDH80  : time := 5 ns;
	signal tCYCW80 : time := 65 ns;
	signal tWHW80  : time := 22.5 ns;

	signal wakeup_prod : boolean := false;
	signal wakeup_cons : boolean := false;
begin

	tWDS80  <= 5.1 ns when ERRNO /= 1 else 4 ns;
	tWLW80 <= 22.6 ns when ERRNO /= 2 else 20 ns;
	tWDH80 <= 5.1 ns when ERRNO /= 3 else 4 ns;
	tCYCW80 <= 65.1 ns when ERRNO /= 4 else 60 ns;
	tWHW80 <= 22.6 ns when ERRNO /= 5 else 20 ns;


process

	variable write_pointer : integer := 0;
		
	procedure write_data is
	begin
		while (nb_words.getvalue = FIFOSIZE) loop
			wait on wakeup_prod;
		end loop;
		fifo_s(write_pointer) <= avalon_address(0) & avalon_write_data;
		write_pointer := (write_pointer + 1) mod FIFOSIZE;
		nb_words.incr;
		wakeup_cons <= not wakeup_cons;
		wait until rising_edge(clk);
		if (ERRNO /= 6) then
			avalon_waitreq <= '0';
		end if;
		wait until rising_edge(clk);
		if (ERRNO /= 7) then
			avalon_waitreq <= '1';
		end if;
	end write_data;


	procedure write_wrong is
	begin
		wait until rising_edge(clk);
		if (ERRNO /= 8) then
			avalon_waitreq <= '0';
		end if;
		wait until rising_edge(clk);
		if (ERRNO /= 9) then
			avalon_waitreq <= '1';
		end if;
	end write_wrong;

	procedure write_access is
		variable address : std_logic_vector(1 downto 0);
	begin
		if (ERRNO /= 16) then
			address := avalon_address;
		else
			address := not avalon_address;
		end if;
		case address is
			when "00" | "01" =>
				write_data;
			when others =>
				write_wrong;
				
		end case;
	end write_access;
	
begin
	avalon_waitreq <= '1';
	
	loop
		wait until rising_edge(clk);
		if (avalon_cs='1' and avalon_wr = '1' and avalon_wr_1='0') then
			write_access;
		end if;
	end loop;
end process;

	process
		variable read_pointer : integer := 0;
	begin
		LCD_data <= (others => 'Z');
		LCD_WR_n <= '1';
		LCD_RD_n <= '1';
		LCD_D_C_n <= '0';

		if (ERRNO = 15) then
			while (nb_words.getvalue = 0) loop
				wait on wakeup_cons;
			end loop;
			read_pointer := (read_pointer + 1) mod FIFOSIZE;
			nb_words.decr;
			wakeup_prod <= not wakeup_prod;
		end if;
		
		loop	
			while (nb_words.getvalue = 0) loop
				wait on wakeup_cons;
			end loop;
			if (ERRNO /= 13) then
				LCD_DATA <= fifo_s(read_pointer)(15 downto 0);
			end if;
			if (ERRNO /= 14) then
				LCD_D_C_n <= fifo_s(read_pointer)(16);
			end if;
			wait for tWDS80;
			if (ERRNO /= 10) then
				LCD_WR_n <= '0';
			end if;
			wait for tWLW80;
			if (ERRNO /= 11) then
				LCD_WR_n <= '1';
			end if;
			wait for tWDH80;
			if (ERRNO /= 12) then
				LCD_DATA <= (others => 'Z');
			end if;
			read_pointer := (read_pointer + 1) mod FIFOSIZE;
			nb_words.decr;
			wakeup_prod <= not wakeup_prod;
			wait for tCYCW80 - ( tWLW80 + tWDH80);
			
		end loop;
	end process;


	process(clk)
	begin
		if reset = '1' then
			avalon_wr_1 <= '0';
		elsif rising_edge(clk) then
			avalon_wr_1 <= avalon_wr;
		end if;
	end process;

end architecture simulation;

