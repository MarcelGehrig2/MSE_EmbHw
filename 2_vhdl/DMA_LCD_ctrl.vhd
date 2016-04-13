
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DMA_LCD_ctrl is
	port (
		clk               : in    std_logic                    ;
		reset             : in    std_logic                    ;         
		-- master interface
 		master_address	  : out  std_logic_vector(31 downto 0);
		master_read	  : out std_logic;
		master_readdata	  : in std_logic_vector(7 downto 0) ;
		master_waitrequest : in std_logic;
		-- IRQ generation
		end_of_transaction_irq : out std_logic;		
		-- slave interface 
		avalon_address    : in    std_logic_vector(2 downto 0) ;
		avalon_cs         : in    std_logic                   ;  
		avalon_wr         : in    std_logic                    ;  
		avalon_write_data : in    std_logic_vector(31 downto 0);
		avalon_rd         : in    std_logic                    ;  
		avalon_read_data  : out    std_logic_vector(31 downto 0);
		-- LCD interface
		LCD_data          : out std_logic_vector(7 downto 0) ;
		LCD_CS_n	  : out    std_logic ;		
		LCD_WR_n	  : out    std_logic ;				
		LCD_D_C_n	  : out    std_logic 
	);
end entity DMA_LCD_ctrl;

architecture rtl of DMA_LCD_ctrl is
-- your signals

begin
-------- register model (a proposal) -----------
-- 000 write command to LCD
-- 001 write data to LCD
-- 010 write pointer of the image to copy
-- 011 write size of the image to copy
-- 100 control register 
--	bit 0 => start transfer 
--	bit 1 => reserved 
--	bit 2 => IRQ ack 


-- your code


end architecture rtl; 
