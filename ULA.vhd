LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ULA is
	generic (DATA : integer := 32);
	port 
	(
		A : in std_logic_vector(DATA-1 downto 0);
		B : in std_logic_vector(DATA-1 downto 0);
		sel : in std_logic_vector(2 downto 0);
		Result : buffer std_logic_vector(DATA-1 downto 0);
		Zero : out std_logic 
	);
end ULA;


architecture estrutura of ULA is

	signal s_sum_sub, s_and_or, s_mux, s_less: std_logic_vector(DATA-1 downto 0);
	signal s_sum_sub_signed : signed(DATA-1 downto 0);
	constant c_zeros : std_logic_vector(DATA-1 downto 0) := (others => '0');
	
	component Sum_Sub is
		generic(DATA : integer := 32);
		port 
		(
			A : in signed(DATA-1 downto 0);
			B : in signed(DATA-1 downto 0);
			sel : in std_logic;
			S : out signed(DATA-1 downto 0)
		);
	end component;
	
	component And_Or is
		generic(DATA : integer := 32);
		port 
		(
			A : in std_logic_vector(DATA-1 downto 0);
			B : in std_logic_vector(DATA-1 downto 0);
			sel : in std_logic;
			S : out std_logic_vector(DATA-1 downto 0)
		);
	end component;
	
	component Mux2x1 is
		generic (N : integer := 32);
		port 
		(
			A : in std_logic_vector  (N-1 downto 0);
			B : in std_logic_vector  (N-1 downto 0);
			sel   : in std_logic;
			S : out std_logic_vector (N-1 downto 0)
		);
	end component;

begin

	ss0: Sum_Sub generic map (DATA => DATA) port map (signed(A), signed(B), sel(2), s_sum_sub_signed);
	s_sum_sub <= std_logic_vector(s_sum_sub_signed);
	ao0: And_Or generic map (DATA => DATA) port map (A, B, sel(0), s_and_or);
	mu0: Mux2x1 generic map (N => DATA )port map (s_and_or, s_sum_sub, sel(1), s_mux);
	
	s_less(31 downto 1) <= (others => '0');
	s_less(0) <= s_mux(31);
	
	Result <= s_less when sel = "111" else s_mux;
	Zero <= '1' when result = c_zeros else '0';
			
end estrutura;
