library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port (
        opcode       : in  STD_LOGIC_VECTOR(6 downto 0); -- Instruction opcode from bit [6:0]
        branch       : out STD_LOGIC;                      -- 1 if branch instruction
        mem_read     : out STD_LOGIC;                      -- 1 if reading from memory (load)
        mem_to_reg   : out STD_LOGIC;                      -- 1 if writing memory data to register
        alu_op       : out STD_LOGIC_VECTOR(1 downto 0);   -- ALU operation type selector
        mem_write    : out STD_LOGIC;                      -- 1 if writing to memory (store)
        alu_src      : out STD_LOGIC;                      -- 1 if ALU input B is an immediate value
        reg_write    : out STD_LOGIC                       -- 1 if writing back to a register
    );
end control_unit;

architecture rtl of control_unit is
begin
    process(opcode)
    begin
        -- Default control signal values (safe fallback / NOP)
        branch     <= '0';
        mem_read   <= '0';
        mem_to_reg <= '0';
        alu_op     <= "00";
        mem_write  <= '0';
        alu_src    <= '0';
        reg_write  <= '0';

        case opcode is
            when "0110011" => -- R-type (e.g., add, sub, and, or)
                reg_write  <= '1';
                alu_op     <= "10";

            when "0010011" => -- I-type ALU (e.g., addi, slti)
                alu_src    <= '1';
                reg_write  <= '1';
                alu_op     <= "00";

            when "0000011" => -- Load (e.g., lw)
                alu_src    <= '1';
                mem_read   <= '1';
                mem_to_reg <= '1';
                reg_write  <= '1';
                alu_op     <= "00";

            when "0100011" => -- Store (e.g., sw)
                alu_src    <= '1';
                mem_write  <= '1';
                alu_op     <= "00";

            when "1100011" => -- Branch (e.g., beq, bne)
                branch     <= '1';
                alu_op     <= "01";

            when others =>
                -- Default NOP behavior
                null;
        end case;
    end process;
end rtl;
