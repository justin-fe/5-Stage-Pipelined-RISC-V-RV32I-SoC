library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hazard_detection_unit is
    Port (
        id_rs1          : in  STD_LOGIC_VECTOR(4 downto 0);
        id_rs2          : in  STD_LOGIC_VECTOR(4 downto 0);
        ex_rd           : in  STD_LOGIC_VECTOR(4 downto 0);
        ex_mem_read     : in  STD_LOGIC;
        branch_taken    : in  STD_LOGIC;
        pc_write        : out STD_LOGIC;
        if_id_write     : out STD_LOGIC;
        control_mux_sel : out STD_LOGIC -- '1' inserts a bubble (NOP)
    );
end hazard_detection_unit;

architecture rtl of hazard_detection_unit is
begin
    process(id_rs1, id_rs2, ex_rd, ex_mem_read, branch_taken)
    begin
        -- Default values: normal operation, no stalls, no bubbles
        pc_write        <= '1';
        if_id_write     <= '1';
        control_mux_sel <= '0';

        -- Load-Use Hazard Detection
        if (ex_mem_read = '1') and ((ex_rd = id_rs1) or (ex_rd = id_rs2)) then
            pc_write        <= '0'; -- Freeze Program Counter
            if_id_write     <= '0'; -- Freeze IF/ID pipeline register
            control_mux_sel <= '1'; -- Inject bubble into ID/EX control
        end if;

        -- Control Hazard: Branch Taken Flush
        if branch_taken = '1' then
            -- Logic to flush speculative instructions fetched during branch
            -- (Will be integrated with branch target controller)
        end if;
    end process;
end rtl;
