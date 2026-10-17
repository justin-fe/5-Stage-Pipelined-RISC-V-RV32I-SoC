library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- =========================================================================
-- ID/EX Pipeline Register (Decode to Execute Stage)
-- =========================================================================
entity id_ex_reg is
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        flush       : in  STD_LOGIC;
        -- Control signals in
        ctrl_reg_write_in : in STD_LOGIC;
        ctrl_mem_to_reg_in: in STD_LOGIC;
        ctrl_mem_write_in : in STD_LOGIC;
        ctrl_alu_src_in   : in STD_LOGIC;
        ctrl_alu_op_in    : in STD_LOGIC_VECTOR(1 downto 0);
        -- Data in
        rs1_data_in : in STD_LOGIC_VECTOR(31 downto 0);
        rs2_data_in : in STD_LOGIC_VECTOR(31 downto 0);
        imm_in      : in STD_LOGIC_VECTOR(31 downto 0);
        rs1_addr_in : in STD_LOGIC_VECTOR(4 downto 0);
        rs2_addr_in : in STD_LOGIC_VECTOR(4 downto 0);
        rd_addr_in  : in STD_LOGIC_VECTOR(4 downto 0);
        
        -- Outputs to Execute stage
        ctrl_reg_write_out : out STD_LOGIC;
        ctrl_mem_to_reg_out: out STD_LOGIC;
        ctrl_mem_write_out : out STD_LOGIC;
        ctrl_alu_src_out   : out STD_LOGIC;
        ctrl_alu_op_out    : out STD_LOGIC_VECTOR(1 downto 0);
        rs1_data_out : out STD_LOGIC_VECTOR(31 downto 0);
        rs2_data_out : out STD_LOGIC_VECTOR(31 downto 0);
        imm_out      : out STD_LOGIC_VECTOR(31 downto 0);
        rs1_addr_out : out STD_LOGIC_VECTOR(4 downto 0);
        rs2_addr_out : out STD_LOGIC_VECTOR(4 downto 0);
        rd_addr_out  : out STD_LOGIC_VECTOR(4 downto 0)
    );
end id_ex_reg;

architecture rtl of id_ex_reg is
begin
    process(clk, rst)
    begin
        if rst = '1' or flush = '1' then
            ctrl_reg_write_out  <= '0';
            ctrl_mem_to_reg_out <= '0';
            ctrl_mem_write_out  <= '0';
            ctrl_alu_src_out    <= '0';
            ctrl_alu_op_out     <= "00";
            rs1_data_out        <= (others => '0');
            rs2_data_out        <= (others => '0');
            imm_out             <= (others => '0');
            rs1_addr_out        <= (others => '0');
            rs2_addr_out        <= (others => '0');
            rd_addr_out         <= (others => '0');
        elsif rising_edge(clk) then
            ctrl_reg_write_out  <= ctrl_reg_write_in;
            ctrl_mem_to_reg_out <= ctrl_mem_to_reg_in;
            ctrl_mem_write_out  <= ctrl_mem_write_in;
            ctrl_alu_src_out    <= ctrl_alu_src_in;
            ctrl_alu_op_out     <= ctrl_alu_op_in;
            rs1_data_out        <= rs1_data_in;
            rs2_data_out        <= rs2_data_in;
            imm_out             <= imm_in;
            rs1_addr_out        <= rs1_addr_in;
            rs2_addr_out        <= rs2_addr_in;
            rd_addr_out         <= rd_addr_in;
        end if;
    end process;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- =========================================================================
-- EX/MEM Pipeline Register (Execute to Memory Stage)
-- =========================================================================
entity ex_mem_reg is
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        -- Control in
        reg_write_in  : in STD_LOGIC;
        mem_to_reg_in : in STD_LOGIC;
        mem_write_in  : in STD_LOGIC;
        -- Data in
        alu_result_in : in STD_LOGIC_VECTOR(31 downto 0);
        writedata_in  : in STD_LOGIC_VECTOR(31 downto 0);
        rd_addr_in    : in STD_LOGIC_VECTOR(4 downto 0);
        
        -- Control out
        reg_write_out  : out STD_LOGIC;
        mem_to_reg_out : out STD_LOGIC;
        mem_write_out  : out STD_LOGIC;
        -- Data out
        alu_result_out : out STD_LOGIC_VECTOR(31 downto 0);
        writedata_out  : out STD_LOGIC_VECTOR(31 downto 0);
        rd_addr_out    : out STD_LOGIC_VECTOR(4 downto 0)
    );
end ex_mem_reg;

architecture rtl of ex_mem_reg is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg_write_out  <= '0';
            mem_to_reg_out <= '0';
            mem_write_out  <= '0';
            alu_result_out <= (others => '0');
            writedata_out  <= (others => '0');
            rd_addr_out    <= (others => '0');
        elsif rising_edge(clk) then
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            mem_write_out  <= mem_write_in;
            alu_result_out <= alu_result_in;
            writedata_out  <= writedata_in;
            rd_addr_out    <= rd_addr_in;
        end if;
    end process;
end rtl;
