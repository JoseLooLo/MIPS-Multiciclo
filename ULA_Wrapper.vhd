LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ULA_Wrapper is
generic (DATA : integer := 32);
	port 
	(
		A : in std_logic_vector  (DATA-1 downto 0);
		B : in std_logic_vector  (DATA-1 downto 0);
		ULAOp : in std_logic_vector  (1 downto 0);
		Funct : in std_logic_vector  (5 downto 0);
		Result : out std_logic_vector (DATA-1 downto 0);
		Zero : out std_logic
	);
end entity;


architecture behavior of ULA_Wrapper is

	signal s_ulacontrol : std_logic_vector (2 downto 0);
	
	component ULA_Control is
	port 
	(
		ULAOp : in std_logic_vector  (1 downto 0);
		Funct : in std_logic_vector  (5 downto 0);
		ULAControl : out std_logic_vector (2 downto 0)
	);
	end component;
	
	component ULA is
		generic (DATA : integer := 32);
		port 
		(
			A : in std_logic_vector(DATA-1 downto 0);
			B : in std_logic_vector(DATA-1 downto 0);
			sel : in std_logic_vector(2 downto 0);
			Result : buffer std_logic_vector(DATA-1 downto 0);
			Zero : out std_logic 
		);
	end component;

begin

	ula_1 : ULA generic map (DATA => DATA) port map (A, B, s_ulacontrol, Result, Zero);
	ula_ctrl_1 : ULA_Control port map (ULAOp, Funct, s_ulacontrol);
			
end behavior;
