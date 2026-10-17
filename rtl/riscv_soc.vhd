library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity riscv_soc is
    Port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC
    );
end riscv_soc;

architecture rtl of riscv_soc is
    signal pc_val      : STD_LOGIC_VECTOR(31 downto 0);
    signal instr_val   : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_addr   : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_wdata  : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_we     : STD_LOGIC;
    signal dmem_rdata  : STD_LOGIC_VECTOR(31 downto 0);
begin

    -- Instantiate RISC-V Core
    core_inst: entity work.riscv_core
        port map (
            clk        => clk,
            rst        => rst,
            instr_in   => instr_val,
            pc_out     => pc_val,
            dmem_addr  => dmem_addr,
            dmem_wdata => dmem_wdata,
            dmem_we    => dmem_we,
            dmem_rdata => dmem_rdata
        );

    -- Instantiate Instruction Memory ROM
    imem_inst: entity work.instruction_memory
        port map (
            addr => pc_val,
            data => instr_val
        );

    -- Instantiate Data Memory RAM
    dmem_inst: entity work.data_memory
        port map (
            clk   => clk,
            we    => dmem_we,
            addr  => dmem_addr,
            wdata => dmem_wdata,
            rdata => dmem_rdata
        );

end rtl;
