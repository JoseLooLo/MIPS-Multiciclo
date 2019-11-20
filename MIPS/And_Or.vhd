LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity And_Or is
	generic(DATA : integer := 32);
	port 
	(
		A : in std_logic_vector(DATA-1 downto 0);
		B : in std_logic_vector(DATA-1 downto 0);
		sel : in std_logic;
		S : out std_logic_vector(DATA-1 downto 0)
	);
end And_Or;

architecture behavior of And_Or is
begin
	S <= (A or B) when sel = '1' else
		(A and B);
end behavior;