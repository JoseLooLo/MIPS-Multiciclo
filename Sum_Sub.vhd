LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Sum_Sub is
	generic(DATA : integer := 32);
	port 
	(
		A : in signed(DATA-1 downto 0);
		B : in signed(DATA-1 downto 0);
		sel : in std_logic;
		S : out signed(DATA-1 downto 0)
	);
end Sum_Sub;

architecture behavior of Sum_Sub is

begin

	S <= (A - B) when sel = '1' else
		 (A + B);
		 
end behavior;
