library ieee;
use ieee.std_logic_1164.all;

entity Controle is
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
end entity;

architecture FSM of Controle is
	type State is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9);
	signal currentState, nextState: State;
	
begin

	process(currentState, Op) is
	begin
		nextState <= currentState;
		case currentState is
			when S0 =>
				--Próximo estado
				nextState <= S1;
				--Saidas
				FontePC <= "00";
				ULAOp <= "00";
				ULAFonteB <= "01";
				ULAFonteA <= '0';
				EscReg <= '0';
				PCEscCond <= '0';
				PCEsc <= '1';
				IouD <= '0';
				LerMem <= '1';
				EscMem <= '0';
				IREsc <= '1';
				
			when S1 =>
				--Próximo estado
				if (Op = "000000") then
					nextState <= S6;
				elsif (Op = "100011") then
					nextState <= S2;
				elsif (Op = "101011") then
					nextState <= S2;
				elsif (Op = "000100") then
					nextState <= S8;
				elsif (Op = "000010") then
					nextState <= S9;
				end if;
				--Saidas
				ULAOp <= "00";
				ULAFonteB <= "11";
				ULAFonteA <= '0';
				EscReg <= '0';
				PCEscCond <= '0';
				PCEsc <= '0';
				LerMem <= '0';
				EscMem <= '0';
				IREsc <= '0';
				
			when S2 =>
				--Próximo estado
				if (Op = "100011") then
					nextState <= S3;
				elsif (Op = "101011") then
					nextState <= S5;
				end if;
				--Saidas
				ULAOp <= "00";
				ULAFonteB <= "10";
				ULAFonteA <= '1';
				EscReg <= '0';
				PCEscCond <= '0';
				PCEsc <= '0';
				LerMem <= '0';
				EscMem <= '0';
				IREsc <= '0';
				
			when S3 =>
				--Próximo estado
				nextState <= S4;
				--Saidas
				IouD <= '1';
				EscReg <= '0';
				PCEscCond <= '0';
				PCEsc <= '0';
				LerMem <= '1';
				EscMem <= '0';
				IREsc <= '0';
				
			when S4 =>
				--Próximo estado
				nextState <= S0;
				--Saidas
				MemParaReg <= '1';
				RegDst <= '0';
				EscReg <= '1';
				PCEscCond <= '0';
				PCEsc <= '0';
				LerMem <= '0';
				EscMem <= '0';
				IREsc <= '0';
				
			when S5 =>
				--Próximo estado
				nextState <= S0;
				--Saidas
				IouD <= '1';
				EscReg <= '0';
				PCEscCond <= '0';
				PCEsc <= '0';
				LerMem <= '0';
				EscMem <= '1';
				IREsc <= '0';
				
			when S6 =>
				--Próximo estado
				nextState <= S7;
				--Saidas
				ULAOp <= "10";
				ULAFonteB <= "00";
				ULAFonteA <= '1';
				EscReg <= '0';
				PCEscCond <= '0';
				PCEsc <= '0';
				LerMem <= '0';
				EscMem <= '0';
				IREsc <= '0';
				
			when S7 =>
				--Próximo estado
				nextState <= S0;
				--Saidas
				RegDst <= '1';
				MemParaReg <= '0';
				EscReg <= '1';
				PCEscCond <= '0';
				PCEsc <= '0';
				LerMem <= '0';
				EscMem <= '0';
				IREsc <= '0';
				
			when S8 =>
				--Próximo estado
				nextState <= S0;
				--Saidas
				FontePC <= "01";
				ULAOp <= "01";
				ULAFonteB <= "00";
				ULAFonteA <= '1';
				EscReg <= '0';
				PCEscCond <= '1';
				PCEsc <= '0';
				LerMem <= '0';
				EscMem <= '0';
				IREsc <= '0';
				
			when S9 =>
				--Próximo estado
				nextState <= S0;
				--Saidas
				FontePC <= "10";
				EscReg <= '0';
				PCEscCond <= '0';
				PCEsc <= '1';
				LerMem <= '0';
				EscMem <= '0';
				IREsc <= '0';
		end case;
	end process;
	
	process(clock, reset) is
	begin
		if reset='1' then
			currentState <= S0;
		elsif rising_edge(clock) then
			currentState <= nextState;
		end if;
	end process;
	
end architecture;
