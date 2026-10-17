library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imm_gen is
    Port (
        instr : in  STD_LOGIC_VECTOR(31 downto 0); -- 32-bit instruction
        imm   : out STD_LOGIC_VECTOR(31 downto 0)  -- Extracted 32-bit immediate value
    );
end imm_gen;

architecture rtl of imm_gen is
    signal opcode : STD_LOGIC_VECTOR(6 downto 0);
begin
    opcode <= instr(6 downto 0);
    
    process(instr, opcode)
    begin
        imm <= (others => '0');
        case opcode is
            when "0010011" | "0000011" | "1100111" => -- I-type (addi, lw, jalr)
                imm <= std_logic_vector(resize(signed(instr(31 downto 20)), 32));
                
            when "0100011" => -- S-type (sw - store word)
                imm <= std_logic_vector(resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32));
                
            when "1100011" => -- B-type (branch)
                imm <= std_logic_vector(resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), 32));
                
            when others =>
                imm <= (others => '0');
        end case;
    end process;
end rtl;
