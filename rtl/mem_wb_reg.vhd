library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mem_wb_reg is
    Port (
        clk            : in  STD_LOGIC;
        rst            : in  STD_LOGIC;
        reg_write_in   : in  STD_LOGIC;
        mem_to_reg_in  : in  STD_LOGIC;
        alu_result_in  : in  STD_LOGIC_VECTOR(31 downto 0);
        read_data_in   : in  STD_LOGIC_VECTOR(31 downto 0);
        rd_addr_in     : in  STD_LOGIC_VECTOR(4 downto 0);
        
        reg_write_out  : out STD_LOGIC;
        mem_to_reg_out : out STD_LOGIC;
        alu_result_out : out STD_LOGIC_VECTOR(31 downto 0);
        read_data_out  : out STD_LOGIC_VECTOR(31 downto 0);
        rd_addr_out    : out STD_LOGIC_VECTOR(4 downto 0)
    );
end mem_wb_reg;

architecture rtl of mem_wb_reg is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg_write_out  <= '0';
            mem_to_reg_out <= '0';
            alu_result_out <= (others => '0');
            read_data_out  <= (others => '0');
            rd_addr_out    <= (others => '0');
        elsif rising_edge(clk) then
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_result_out <= alu_result_in;
            read_data_out  <= read_data_in;
            rd_addr_out    <= rd_addr_in;
        end if;
    end process;
end rtl;
