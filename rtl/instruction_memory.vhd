library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory is
    Port (
        addr : in  STD_LOGIC_VECTOR(31 downto 0); -- Program counter address
        data : out STD_LOGIC_VECTOR(31 downto 0)  -- 32-bit instruction output
    );
end instruction_memory;

architecture rtl of instruction_memory is
    type rom_array is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
    
    -- Pre-loaded with a few test instructions (addi x1, x0, 10; addi x2, x0, 20; add x3, x1, x2)
    constant rom : rom_array := (
        0 => "00000000101000000000000010010011", -- addi x1, x0, 10 (x1 = 10)
        1 => "00000001010000000000000100010011", -- addi x2, x0, 20 (x2 = 20)
        2 => "00000000001000001000000110110011", -- add  x3, x1, x2 (x3 = x1 + x2 = 30)
        others => (others => '0')
    );
begin
    -- Asynchronous read based on word-aligned PC address
    data <= rom(to_integer(unsigned(addr(7 downto 2)))) when unsigned(addr(7 downto 2)) < 64 else (others => '0');
end rtl;
