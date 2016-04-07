LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY lcd_avalon_slave IS
   PORT (  -- Here the internal interface is defined
          Clk50_CI : IN std_logic;
          Reset_RI : IN std_logic;

          -- Here the avalon slave interface is defined
          AVSlave_addr_DI  : IN  std_logic_vector(1 DOWNTO 0);
          AVSlave_cs_SI    : IN  std_logic;
          AVSlave_we_SI    : IN  std_logic;
          AVSlave_rd_SI    : IN  std_logic;
          AVSlave_we_DI    : IN  std_logic_vector(31 DOWNTO 0);
          AVSlave_rd_DO    : OUT std_logic_vector(31 DOWNTO 0);
          AVSlave_wtReq_SO : OUT std_logic;


          -- Here the external LCD-panel signals are defined
          LCD_cs_SBO    : OUT   std_logic;
          LCD_DaCmd_SBO : OUT   std_logic;
          LCD_we_SBO    : OUT   std_logic;
          LCD_rd_SBO    : OUT   std_logic;
          LCD_Reset_RBO : OUT   std_logic;
          LCD_IM0_SO    : OUT   std_logic;
          LCD_data_IO   : INOUT std_logic_vector(15 DOWNTO 0));
END lcd_avalon_slave;

     -------- register model -----------
     -- 00  write: Write a command to LCD
     --     read :  Read a command from LCD
     -- 01  write: Write data to LCD
     --     read : Read data from LCD
     -- 10  r/w  : Control register
     --            bit 0  => Select 0 => Sixteen bit transfer
     --                      Select 1 => Eight bit transfer
     --            bit 1  => Busy flag (read only)
     --                      Reset LCD Display (write only)
     --            others => 0
