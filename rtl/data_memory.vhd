library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    Port (
        clk       : in  STD_LOGIC;
        we        : in  STD_LOGIC;                      -- Write Enable (1 = store)
        addr      : in  STD_LOGIC_VECTOR(31 downto 0);  -- Memory address
        wdata     : in  STD_LOGIC_VECTOR(31 downto 0);  -- Data to write
        rdata     : out STD_LOGIC_VECTOR(31 downto 0)   -- Data read out
    );
end data_memory;

architecture rtl of data_memory is
    type ram_array is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
    signal ram : ram_array := (others => (others => '0'));
begin

    -- Asynchronous Read
    rdata <= ram(to_integer(unsigned(addr(7 downto 2)))) when unsigned(addr(7 downto 2)) < 64 else (others => '0');

    -- Synchronous Write
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and unsigned(addr(7 downto 2)) < 64 then
                ram(to_integer(unsigned(addr(7 downto 2)))) <= wdata;
            end if;
        end if;
    end process;

end rtl;
