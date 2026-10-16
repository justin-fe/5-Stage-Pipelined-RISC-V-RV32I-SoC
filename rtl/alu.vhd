library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port (
        alu_control : in  STD_LOGIC_VECTOR(3 downto 0); -- Tells ALU what operation to perform
        a           : in  STD_LOGIC_VECTOR(31 downto 0); -- Input Operand A (32-bit)
        b           : in  STD_LOGIC_VECTOR(31 downto 0); -- Input Operand B (32-bit)
        result      : out STD_LOGIC_VECTOR(31 downto 0); -- Computed Result
        zero        : out STD_LOGIC                      -- High if result is zero (for branches)
    );
end alu;

architecture rtl of alu is
begin
    process(alu_control, a, b)
        variable v_result : std_logic_vector(31 downto 0);
    begin
        v_result := (others => '0');
        zero     <= '0';
        
        case alu_control is
            when "0000" => -- ADD
                v_result := std_logic_vector(unsigned(a) + unsigned(b));
            when "0001" => -- SUB
                v_result := std_logic_vector(unsigned(a) - unsigned(b));
            when "0010" => -- AND
                v_result := a and b;
            when "0011" => -- OR
                v_result := a or b;
            when "0100" => -- XOR
                v_result := a xor b;
            when "0101" => -- SLL (Shift Left Logical)
                v_result := std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
            when "0110" => -- SRL (Shift Right Logical)
                v_result := std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
            when "0111" => -- SRA (Shift Right Arithmetic)
                v_result := std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));
            when "1000" => -- SLT (Set Less Than - Signed)
                if signed(a) < signed(b) then
                    v_result := x"00000001";
                else
                    v_result := x"00000000";
                end if;
            when others =>
                v_result := (others => '0');
        end case;

        -- Set Zero flag if result is zero
        if v_result = x"00000000" then
            zero <= '1';
        end if;

        -- Assign local variable to output port
        result <= v_result;
    end process;
end rtl;
