LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ULA_Control is
	port 
	(
		ULAOp : in std_logic_vector  (1 downto 0);
		Funct : in std_logic_vector  (5 downto 0);
		ULAControl : out std_logic_vector (2 downto 0)
	);
end entity;


architecture behavior of ULA_Control is

begin
	process(ULAOp, Funct) begin
		case ULAOp is
			when "00" =>
				ULAControl <= "010";
			when "01" =>
				ULAControl <= "110";
			when "10" =>
				case Funct is
					when "100000" =>
						ULAControl <= "010";
					when "100010" =>
						ULAControl <= "110";
					when "100100" =>
						ULAControl <= "000";
					when "100101" =>
						ULAControl <= "001";
					when "101010" =>
						ULAControl <= "111";
					when others =>
						ULAControl <= "111";
				end case;
			when others =>
				ULAControl <= "111";
		end case;
	end process;
			
end behavior;
