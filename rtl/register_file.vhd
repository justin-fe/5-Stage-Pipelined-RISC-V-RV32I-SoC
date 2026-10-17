library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    Port (
        clk      : in  STD_LOGIC;                      -- System clock
        we       : in  STD_LOGIC;                      -- Write Enable (1 = save data)
        rs1_addr : in  STD_LOGIC_VECTOR(4 downto 0);   -- Address of first source register
        rs2_addr : in  STD_LOGIC_VECTOR(4 downto 0);   -- Address of second source register
        rd_addr  : in  STD_LOGIC_VECTOR(4 downto 0);   -- Address of destination register to write
        rd_data  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Data to write into destination
        rs1_data : out STD_LOGIC_VECTOR(31 downto 0);  -- Output data from rs1
        rs2_data : out STD_LOGIC_VECTOR(31 downto 0)   -- Output data from rs2
    );
end register_file;

architecture rtl of register_file is
    -- Define 32 registers, each 32 bits wide
    type reg_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));
begin

    -- Asynchronous Read for Source Register 1 (x0 is always 0)
    process(rs1_addr, regs)
    begin
        if rs1_addr = "00000" then
            rs1_data <= (others => '0');
        else
            rs1_data <= regs(to_integer(unsigned(rs1_addr)));
        end if;
    end process;

    -- Asynchronous Read for Source Register 2 (x0 is always 0)
    process(rs2_addr, regs)
    begin
        if rs2_addr = "00000" then
            rs2_data <= (others => '0');
        else
            rs2_data <= regs(to_integer(unsigned(rs2_addr)));
        end if;
    end process;

    -- Synchronous Write to Destination Register on Clock Edge
    process(clk)
    begin
        if rising_edge(clk) then
            -- Only write if Write Enable is high AND we aren't trying to overwrite x0
            if (we = '1') and (rd_addr /= "00000") then
                regs(to_integer(unsigned(rd_addr))) <= rd_data;
            end if;
        end if;
    end process;

end rtl;
