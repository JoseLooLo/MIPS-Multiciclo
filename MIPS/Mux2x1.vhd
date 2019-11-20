LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Mux2x1 is
generic (N : integer := 32);
	port 
	(
		A : in std_logic_vector  (N-1 downto 0);
		B : in std_logic_vector  (N-1 downto 0);
		sel   : in std_logic;
		S : out std_logic_vector (N-1 downto 0)
	);
end Mux2x1;

architecture behavior of Mux2x1 is
begin
	S <= B when sel = '1' else A;
end behavior;
