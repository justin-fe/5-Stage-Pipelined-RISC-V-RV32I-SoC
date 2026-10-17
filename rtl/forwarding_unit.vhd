library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity forwarding_unit is
    Port (
        ex_rs1        : in  STD_LOGIC_VECTOR(4 downto 0);
        ex_rs2        : in  STD_LOGIC_VECTOR(4 downto 0);
        mem_rd        : in  STD_LOGIC_VECTOR(4 downto 0);
        mem_reg_write : in  STD_LOGIC;
        wb_rd         : in  STD_LOGIC_VECTOR(4 downto 0);
        wb_reg_write  : in  STD_LOGIC;
        forward_a     : out STD_LOGIC_VECTOR(1 downto 0);
        forward_b     : out STD_LOGIC_VECTOR(1 downto 0)
    );
end forwarding_unit;

architecture rtl of forwarding_unit is
begin
    process(ex_rs1, ex_rs2, mem_rd, mem_reg_write, wb_rd, wb_reg_write)
    begin
        -- Default: No forwarding (use register file values)
        forward_a <= "00";
        forward_b <= "00";

        -- EX Hazard (Forward from EX/MEM stage)
        if (mem_reg_write = '1') and (mem_rd /= "00000") and (mem_rd = ex_rs1) then
            forward_a <= "10";
        -- MEM Hazard (Forward from MEM/WB stage)
        elsif (wb_reg_write = '1') and (wb_rd /= "00000") and (wb_rd = ex_rs1) then
            forward_a <= "01";
        end if;

        if (mem_reg_write = '1') and (mem_rd /= "00000") and (mem_rd = ex_rs2) then
            forward_b <= "10";
        elsif (wb_reg_write = '1') and (wb_rd /= "00000") and (wb_rd = ex_rs2) then
            forward_b <= "01";
        end if;
    end process;
end rtl;
