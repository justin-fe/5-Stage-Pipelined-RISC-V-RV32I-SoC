library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv_core is
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        -- External memory / SoC interfaces can be tied here
        instr_in    : in  STD_LOGIC_VECTOR(31 downto 0);
        pc_out      : out STD_LOGIC_VECTOR(31 downto 0);
        dmem_addr   : out STD_LOGIC_VECTOR(31 downto 0);
        dmem_wdata  : out STD_LOGIC_VECTOR(31 downto 0);
        dmem_we     : out STD_LOGIC;
        dmem_rdata  : in  STD_LOGIC_VECTOR(31 downto 0)
    );
end riscv_core;

architecture rtl of riscv_core is
    -- Internal signals for PC, Fetch, Decode, Execute, Memory, Writeback stages
    signal pc_reg         : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pc_next        : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Register File signals
    signal wb_reg_write   : STD_LOGIC;
    signal wb_rd_addr     : STD_LOGIC_VECTOR(4 downto 0);
    signal wb_rd_data     : STD_LOGIC_VECTOR(31 downto 0);
    signal rs1_data_raw, rs2_data_raw : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Control signals (Decode stage)
    signal c_branch, c_mem_read, c_mem_to_reg, c_mem_write, c_alu_src, c_reg_write : STD_LOGIC;
    signal c_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal imm_ext  : STD_LOGIC_VECTOR(31 downto 0);
    
    -- ID/EX pipeline signals
    signal ex_reg_write, ex_mem_to_reg, ex_mem_write, ex_alu_src : STD_LOGIC;
    signal ex_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal ex_rs1_data, ex_rs2_data, ex_imm : STD_LOGIC_VECTOR(31 downto 0);
    signal ex_rs1_addr, ex_rs2_addr, ex_rd_addr : STD_LOGIC_VECTOR(4 downto 0);
    
    -- Forwarding and ALU signals
    signal fwd_a, fwd_b : STD_LOGIC_VECTOR(1 downto 0);
    signal alu_in_a, alu_in_b : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_result_val : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_zero_flag  : STD_LOGIC;
    signal alu_ctrl_sig   : STD_LOGIC_VECTOR(3 downto 0);
    
    -- EX/MEM pipeline signals
    signal mem_reg_write, mem_mem_to_reg, mem_mem_write : STD_LOGIC;
    signal mem_alu_result, mem_writedata : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_rd_addr : STD_LOGIC_VECTOR(4 downto 0);
    
    -- MEM/WB pipeline signals
    signal wb_mem_to_reg : STD_LOGIC;
    signal wb_alu_result, wb_read_data : STD_LOGIC_VECTOR(31 downto 0);

begin

    pc_out <= pc_reg;

    -- PC Update Process
    process(clk, rst)
    begin
        if rst = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            pc_reg <= std_logic_vector(unsigned(pc_reg) + 4);
        end if;
    end process;

    -- Instantiate Register File
    reg_file_inst: entity work.register_file
        port map (
            clk      => clk,
            we       => wb_reg_write,
            rs1_addr => instr_in(19 downto 15),
            rs2_addr => instr_in(24 downto 20),
            rd_addr  => wb_rd_addr,
            rd_data  => wb_rd_data,
            rs1_data => rs1_data_raw,
            rs2_data => rs2_data_raw
        );

    -- Instantiate Control Unit
    control_inst: entity work.control_unit
        port map (
            opcode     => instr_in(6 downto 0),
            branch     => c_branch,
            mem_read   => c_mem_read,
            mem_to_reg => c_mem_to_reg,
            alu_op     => c_alu_op,
            mem_write  => c_mem_write,
            alu_src    => c_alu_src,
            reg_write  => c_reg_write
        );

    -- Instantiate Immediate Generator
    imm_gen_inst: entity work.imm_gen
        port map (
            instr => instr_in,
            imm   => imm_ext
        );

    -- Instantiate ID/EX Pipeline Register
    id_ex_inst: entity work.id_ex_reg
        port map (
            clk                 => clk,
            rst                 => rst,
            flush               => '0',
            ctrl_reg_write_in   => c_reg_write,
            ctrl_mem_to_reg_in  => c_mem_to_reg,
            ctrl_mem_write_in   => c_mem_write,
            ctrl_alu_src_in     => c_alu_src,
            ctrl_alu_op_in      => c_alu_op,
            rs1_data_in         => rs1_data_raw,
            rs2_data_in         => rs2_data_raw,
            imm_in              => imm_ext,
            rs1_addr_in         => instr_in(19 downto 15),
            rs2_addr_in         => instr_in(24 downto 20),
            rd_addr_in          => instr_in(11 downto 7),
            
            ctrl_reg_write_out  => ex_reg_write,
            ctrl_mem_to_reg_out => ex_mem_to_reg,
            ctrl_mem_write_out  => ex_mem_write,
            ctrl_alu_src_out    => ex_alu_src,
            ctrl_alu_op_out     => ex_alu_op,
            rs1_data_out        => ex_rs1_data,
            rs2_data_out        => ex_rs2_data,
            imm_out             => ex_imm,
            rs1_addr_out        => ex_rs1_addr,
            rs2_addr_out        => ex_rs2_addr,
            rd_addr_out         => ex_rd_addr
        );

    -- Instantiate Forwarding Unit
    forwarding_inst: entity work.forwarding_unit
        port map (
            ex_rs1        => ex_rs1_addr,
            ex_rs2        => ex_rs2_addr,
            mem_rd        => mem_rd_addr,
            mem_reg_write => mem_reg_write,
            wb_rd         => wb_rd_addr,
            wb_reg_write  => wb_reg_write,
            forward_a     => fwd_a,
            forward_b     => fwd_b
        );

    -- ALU Operand A Forwarding Mux
    process(fwd_a, ex_rs1_data, mem_alu_result, wb_rd_data)
    begin
        case fwd_a is
            when "10"   => alu_in_a <= mem_alu_result; -- Forward from EX/MEM
            when "01"   => alu_in_a <= wb_rd_data;     -- Forward from MEM/WB
            when others => alu_in_a <= ex_rs1_data;    -- No forwarding
        end case;
    end process;

    -- ALU Operand B Mux (Forwarding + Immediate source selector)
    process(fwd_b, ex_rs2_data, mem_alu_result, wb_rd_data, ex_alu_src, ex_imm)
        variable forward_b_val : STD_LOGIC_VECTOR(31 downto 0);
    begin
        case fwd_b is
            when "10"   => forward_b_val := mem_alu_result;
            when "01"   => forward_b_val := wb_rd_data;
            when others => forward_b_val := ex_rs2_data;
        end case;

        if ex_alu_src = '1' then
            alu_in_b <= ex_imm;
        else
            alu_in_b <= forward_b_val;
        end if;
    end process;

    -- ALU Control Logic mapper (Simplified for RV32I base arithmetic)
    alu_ctrl_sig <= "0000" when ex_alu_op = "10" else "0000"; -- Default ADD

    -- Instantiate ALU
    alu_inst: entity work.alu
        port map (
            alu_control => alu_ctrl_sig,
            a           => alu_in_a,
            b           => alu_in_b,
            result      => alu_result_val,
            zero        => alu_zero_flag
        );

    -- Instantiate EX/MEM Pipeline Register
    ex_mem_inst: entity work.ex_mem_reg
        port map (
            clk            => clk,
            rst            => rst,
            reg_write_in   => ex_reg_write,
            mem_to_reg_in  => ex_mem_to_reg,
            mem_write_in   => ex_mem_write,
            alu_result_in  => alu_result_val,
            writedata_in   => ex_rs2_data,
            rd_addr_in     => ex_rd_addr,
            
            reg_write_out  => mem_reg_write,
            mem_to_reg_out => mem_mem_to_reg,
            mem_write_out  => dmem_we,
            alu_result_out => mem_alu_result,
            writedata_out  => dmem_wdata,
            rd_addr_out    => mem_rd_addr
        );

    dmem_addr <= mem_alu_result;

    -- Instantiate MEM/WB Pipeline Register
    mem_wb_inst: entity work.mem_wb_reg
        port map (
            clk            => clk,
            rst            => rst,
            reg_write_in   => mem_reg_write,
            mem_to_reg_in  => mem_mem_to_reg,
            alu_result_in  => mem_alu_result,
            read_data_in   => dmem_rdata,
            rd_addr_in     => mem_rd_addr,
            
            reg_write_out  => wb_reg_write,
            mem_to_reg_out => wb_mem_to_reg,
            alu_result_out => wb_alu_result,
            read_data_out  => wb_read_data,
            rd_addr_out    => wb_rd_addr
        );

    -- Writeback Mux (Selects between ALU result and Memory load data)
    process(wb_mem_to_reg, wb_alu_result, wb_read_data)
    begin
        if wb_mem_to_reg = '1' then
            wb_rd_data <= wb_read_data;
        else
            wb_rd_data <= wb_alu_result;
        end if;
    end process;

end rtl;
