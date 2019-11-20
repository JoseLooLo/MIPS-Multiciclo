library ieee;
      use ieee.std_logic_1164.all;
      use ieee.std_logic_unsigned.all;
      use ieee.std_logic_arith.all;
		
entity datapath is
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
	end datapath;
  
architecture behavioral of datapath is

	component ULA_Wrapper is
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
	end component;
	
	component regInstrucao is 
    port(
        IRWrite     : in  std_logic;
        instrucInput : in  std_logic_vector(31 downto 0);
	     	opCode      : out std_logic_vector(5 downto 0);
			regRs	    : out std_logic_vector(4 downto 0);
		    regRt   	: out std_logic_vector(4 downto 0);
		    regRd   	: out std_logic_vector(4 downto 0);
		    imm         : out std_logic_vector(15 downto 0);
		    jumpAddr    : out std_logic_vector(25 downto 0);
		    funcCode    : out std_logic_vector(5 downto 0)
          );
	end component;
	
	component memInstrucao is generic ( DATA_WIDTH :integer := 32; ADDR_WIDTH :integer := 10 );
		port(
			  addressIn : in std_logic_vector(31 downto 0); --address Input 
			  data1 : out std_logic_vector(DATA_WIDTH-1 downto 0); --data Output rs
			  data3 : in std_logic_vector(DATA_WIDTH-1 downto 0); --data Input 
			  MemRead : in std_logic;
			  MemWrite : in std_logic
			  ); 
	end component;
	
	
	component memDados is generic ( DATA_WIDTH :integer := 32; ADDR_WIDTH :integer := 5 );
		port(
        address1 : in std_logic_vector(ADDR_WIDTH-1 downto 0); --address Input read register rs
        address2 : in std_logic_vector(ADDR_WIDTH-1 downto 0); --address Input read register rt
        address3 : in std_logic_vector(ADDR_WIDTH-1 downto 0); --address Input write resister rd
        data1    : out std_logic_vector(DATA_WIDTH-1 downto 0); --data Output rs
        data2    : out std_logic_vector(DATA_WIDTH-1 downto 0); --data output rt
        data3    : in std_logic_vector(DATA_WIDTH-1 downto 0); --data Input 
        RegWrite       : in std_logic
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
	
	component Mux4x1 is
		generic (N : integer := 32);
		port 
		(
			A : in std_logic_vector  (N-1 downto 0);
			B : in std_logic_vector  (N-1 downto 0);
			C : in std_logic_vector  (N-1 downto 0);
			D : in std_logic_vector  (N-1 downto 0);
			sel : in std_logic_vector (1 downto 0);
			S : out std_logic_vector (N-1 downto 0)
		);
	end component;
	
	component bitsReg is 
		port (
			data  :in  std_logic_vector(31 downto 0);
			clk   :in  std_logic;
			q     :out std_logic_vector(31 downto 0)
		);
	end component;
	
	component pc is 
		 port(
			  writeEnable : in  std_logic;
			  addrInput   : in  std_logic_vector(31 downto 0);
			  addrOutput	: out std_logic_vector(31 downto 0)
		 );
	end component;
	
	component Signal_extender is 
		 port(
			 dataIn  :in  std_logic_vector(15 downto 0);
			dataOut :out std_logic_vector(31 downto 0)
		 );
	end component;
	
	component shiftLeft2 is 
		 port(
			 dataIn  :in  std_logic_vector(31 downto 0);
			  dataOut :out std_logic_vector(31 downto 0)
		 );
	end component;
	
	component shiftleft22 is 
		 port(
				 dataIn :in std_logic_vector(25 downto 0);
				 dataOut :out std_logic_vector(27 downto 0)
		  );
	end component;

	
	signal Zero: std_logic;
	signal RegAULA, RegBULA, Result, addressIn, dataEntradaMemInstrucao, dataSaidaMemInstrucao : std_logic_vector (31 downto 0);
	--RegInstrucao
	signal opCode, funcCode : std_logic_vector(5 downto 0);
	signal regRs, regRt, regRd, regRd_Mux : std_logic_vector(4 downto 0);
	signal imm : std_logic_vector(15 downto 0);
	signal jumpAddr : std_logic_vector(25 downto 0);
	--PC
	signal entradaPC : std_logic_vector(31 downto 0);
	--Mem dados
	signal data_1_SaidaMemDados, data_2_SaidaMemDados, data_3_EntradaMemDados : std_logic_vector(31 downto 0);
	--Regs genericos
	signal saidaRegDadosGenerico, saidaRegA, saidaRegB, saidaRegULA : std_logic_vector(31 downto 0);
	--PC
	signal writeEnablePC : std_logic;
	signal saidaPC : std_logic_vector(31 downto 0);
	--Extender
	signal saidaExtender : std_logic_vector(31 downto 0);
	--Deslocador
	signal saidaDeslocador1 : std_logic_vector(31 downto 0);
	signal saidaDeslocador2 : std_logic_vector(27 downto 0);
	--Sinal desvio incondicional
	signal desvioJ : std_logic_vector(31 downto 0);
	
	begin
		writeEnablePC <= (PCEscCond and Zero) or PCEsc;
		desvioJ(27 downto 0) <= saidaDeslocador2;
		desvioJ(31 downto 28) <= saidaPC(31 downto 28);
		OpCode_Saida <= opCode;
		
		ALUUnit : ULA_Wrapper generic map (DATA => 32) port map (RegAULA, RegBULA, ULAOp, funcCode, Result, Zero);
		RegIns : regInstrucao port map (IREsc, dataSaidaMemInstrucao, opCode, regRs, regRt, regRd, imm, jumpAddr, funcCode);
		MemIns : memInstrucao generic map (DATA_WIDTH => 32, ADDR_WIDTH => 10 ) port map (addressIn, dataSaidaMemInstrucao , saidaRegB, LerMem, EscMem);
		MemDad : memDados generic map (DATA_WIDTH => 32, ADDR_WIDTH => 5) port map (regRs, regRt, regRd_Mux, data_1_SaidaMemDados, data_2_SaidaMemDados, data_3_EntradaMemDados, EscReg);
		--Regs genericos
		RegA : bitsReg port map (data_1_SaidaMemDados, clock, saidaRegA);
		RegB : bitsReg port map (data_2_SaidaMemDados, clock, saidaRegB);
		RegDados : bitsReg port map(dataSaidaMemInstrucao, clock, saidaRegDadosGenerico);
		RegULASaida : bitsReg port map (Result, clock, saidaRegULA);
		--Mux
		Mux1 : Mux2x1 generic map (N => 32) port map (saidaPC, saidaRegULA, IouD, addressIn); -- Mux PC MemInstrucao
		Mux2 : Mux2x1 generic map (N => 5) port map (regRt, regRd, RegDst, regRd_Mux); -- Mux Reg Instrucao Mem Dados
		Mux3 : Mux2x1 generic map (N => 32) port map (saidaRegULA, saidaRegDadosGenerico, MemParaReg, data_3_EntradaMemDados); -- Mux regDadosGenericos Mem Dados
		Mux4 : Mux2x1 generic map (N => 32) port map (saidaPC, saidaRegA, ULAFonteA, RegAULA); -- Mux entrada A ULA
		Mux5 : Mux4x1 generic map (N => 32) port map (saidaRegB, "00000000000000000000000000000100", saidaExtender, saidaDeslocador1, ULAFonteB, regBULA); -- Mux entrada B ULA
		Mux6 : Mux4x1 generic map (N => 32) port map (Result, saidaRegULA, desvioJ, "00000000000000000000000000000000", FontePC, entradaPC);
		
		--Deslocamento e extenção de sinal
		Extender1 : Signal_extender port map (imm, saidaExtender);
		Desloca1 : shiftLeft2 port map (saidaExtender, saidaDeslocador1);
		Desloca2 : shiftleft22 port map (jumpAddr, saidaDeslocador2);
		
		PC1 : pc port map (writeEnablePC, entradaPC, saidaPC);
  
end behavioral;