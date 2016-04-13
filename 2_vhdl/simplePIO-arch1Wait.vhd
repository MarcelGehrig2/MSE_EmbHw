library ieee;
use ieee.std_logic_1164.all;

entity SimplePIO is
    port(
        -- Avalon interfaces signals
        Clk_CI          : in    std_logic;
        Reset_RLI       : in    std_logic;
        Address_DI      : in    std_logic_vector (2 DOWNTO 0);
        ChipSelect_SI   : in    std_logic;
        Read_SI         : in    std_logic;
        Write_SI        : in    std_logic;
        ReadData_DO     : out   std_logic_vector (7 DOWNTO 0);
        WriteData_DI    : in    std_logic_vector (7 DOWNTO 0);
        -- Parallel Port external interface
        ParPort_DIO     : INOUT std_logic_vector (7 DOWNTO 0)
    );
end entity SimplePIO;



architecture oneWait of simplePIO is
    signal RegDir_D     : std_logic_vector (7 DOWNTO 0);		-- Direction
    signal RegPort_D    : std_logic_vector (7 DOWNTO 0);		-- Output
    signal RegPin_D     : std_logic_vector (7 DOWNTO 0);		-- Input
begin

-- Avalon Stuff
-- ------------

-- Read Process from registers with wait 1
pRegRd : process(Clk_CI)
begin
    if rising_edge(Clk_CI) then
        ReadData_DO <= (others => '0');
        if ChipSelect_SI = '1' and Read_SI = '1' then
            -- Write cycle
            case Address_DI(2 downto 0) is
                when "000" => ReadData_DO <= RegDir_D;
                when "001" => ReadData_DO <= RegPin_D;
                when "010" => ReadData_DO <= RegPort_D;
                when others => null;
            end case;
        end if;
    end if;
end process pRegRd;


-- Write Process to registers with wait 1
pRegWr : process(Clk_CI, Reset_RLI)
	begin
		if (Reset_RLI = '0') then
		-- Input by default
		RegDir_D <= (others => '0');
		RegPort_D <= (others => '0');
	elsif rising_edge(Clk_CI) then
		if ChipSelect_SI = '1' and Write_SI = '1' then
			-- Write cycle
			case Address_DI(2 downto 0) is
				when "000" => RegDir_D <= WriteData_DI;
				when "010" => RegPort_D <= WriteData_DI;
				when "011" => RegPort_D <= RegPort_D OR WriteData_DI;
				when "100" => RegPort_D <= RegPort_D AND NOT WriteData_DI;
				when others => null;
			end case;
		end if;
	end if;
end process pRegWr;



-- Interface to real world
-- -----------------------

-- Parallel Port output value
pPort : process(RegDir_D, RegPort_D)
begin
    for idx in 0 to 7 loop
        if RegDir_D(idx) = '1' then
            ParPort_DIO(idx) <= RegPort_D(idx);
        else
            ParPort_DIO(idx) <= 'Z';
        end if;
    end loop;
end process pPort;

-- Parallel Port Input value
RegPin_D <= ParPort_DIO;

end architecture oneWait;
