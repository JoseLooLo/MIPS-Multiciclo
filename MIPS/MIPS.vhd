LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity MIPS is
	port 
	(
		clock, reset :in  std_logic
	);
end MIPS;


architecture estrutura of MIPS is

	signal ULAFonteA, EscReg, RegDst, PCEscCond, PCEsc, IouD, LerMem, EscMem, MemParaReg, IREsc : std_logic;
	signal FontePC, ULAOp, ULAFonteB : std_logic_vector(1 downto 0);
	signal Op : std_logic_vector(5 downto 0);

	component Controle is
		port(
			clock, reset: in std_logic;
			-- data inputs
			Op: in std_logic_vector(5 downto 0);
			-- data outputs
			FontePC: out std_logic_vector(1 downto 0);
			ULAOp: out std_logic_vector(1 downto 0);
			ULAFonteB: out std_logic_vector(1 downto 0);
			ULAFonteA: out std_logic;
			EscReg: out std_logic;
			RegDst: out std_logic;
			PCEscCond: out std_logic;
			PCEsc: out std_logic;
			IouD: out std_logic;
			LerMem: out std_logic;
			EscMem: out std_logic;
			MemParaReg: out std_logic;
			IREsc: out std_logic
		);
	end component;

	component datapath is
		port (
			FontePC: in std_logic_vector(1 downto 0);
			ULAOp: in std_logic_vector(1 downto 0);
			ULAFonteB: in std_logic_vector(1 downto 0);
			ULAFonteA: in std_logic;
			EscReg: in std_logic;
			RegDst: in std_logic;
			PCEscCond: in std_logic;
			PCEsc: in std_logic;
			IouD: in std_logic;
			LerMem: in std_logic;
			EscMem: in std_logic;
			MemParaReg: in std_logic;
			IREsc: in std_logic;
			clock : in std_logic;
			OpCode_Saida : out std_logic_vector(5 downto 0)
		);
	end component;

begin
	control : Controle port map (clock, reset, Op, FontePC, ULAOp, ULAFonteB, ULAFonteA, EscReg, RegDst, PCEscCond, PCEsc, IouD, LerMem, EscMem, MemParaReg, IREsc);
	path1 : datapath port map (FontePC, ULAOp, ULAFonteB, ULAFonteA, EscReg, RegDst, PCEscCond, PCEsc, IouD, LerMem, EscMem, MemParaReg, IREsc, clock, Op);
			
end estrutura;
