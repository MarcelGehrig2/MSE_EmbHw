library ieee;
use ieee.std_logic_1164.all;

entity SimplePIO is
  port(
    -- Avalon interfaces signals
    Clk_CI        : in    std_logic;
    Reset_RLI     : in    std_logic;
    Address_DI    : in    std_logic_vector (2 DOWNTO 0);
    ChipSelect_SI : in    std_logic;
    Read_SI       : in    std_logic;
    Write_SI      : in    std_logic;
    ReadData_DO   : out   std_logic_vector (7 DOWNTO 0);
    WriteData_DI  : in    std_logic_vector (7 DOWNTO 0);
    -- Parallel Port external interface
    ParPort_DIO   : INOUT std_logic_vector (7 DOWNTO 0)
  );
end entity SimplePIO;
