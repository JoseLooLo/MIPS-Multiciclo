library ieee;
      use ieee.std_logic_1164.all;
      use ieee.std_logic_unsigned.all;
      use ieee.std_logic_arith.all;
      
entity datapathDBG is
	port (
		clock, reset : in std_logic;
		i_instrucao : in std_logic_vector(31 downto 0);
		i_endpc : in std_logic_vector(31 downto 0);
		i_data1 : in std_logic_vector(31 downto 0);
		i_data2 : in std_logic_vector(31 downto 0);
		dbg_ULAFonteA, dbg_EscReg, dbg_RegDst, dbg_PCEscCond, dbg_PCEsc, dbg_IouD, dbg_LerMem, dbg_EscMem, dbg_MemParaReg, dbg_IREsc : out std_logic;
		dbg_FontePC, dbg_ULAOp, dbg_ULAFonteB : out std_logic_vector(1 downto 0);
	
		dbg_dataEntradaMemInstrucao: out std_logic_vector(31 downto 0);
		dbg_entradaPC: out std_logic_vector(31 downto 0);
		dbg_Result, dbg_addressIn  : out std_logic_vector (31 downto 0);
		dbg_opCode, dbg_funcCode : out std_logic_vector(5 downto 0);
		dbg_regRs, dbg_regRt, dbg_regRd, dbg_regRd_Mux : out std_logic_vector(4 downto 0);
		dbg_imm : out std_logic_vector(15 downto 0);
		dbg_jumpAddr : out std_logic_vector(25 downto 0);
		dbg_data_1_SaidaMemDados, dbg_data_2_SaidaMemDados, dbg_data_3_EntradaMemDados : out std_logic_vector(31 downto 0)
	--Sinal desvio incondicional
		--dbg_desvioJ : out std_logic_vector(31 downto 0)
	);
  end datapathDBG;
  
architecture behavioral of datapathDBG is

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
	
	component memoria is generic ( DATA_WIDTH :integer := 32; ADDR_WIDTH :integer := 10 );
		port(
			  addressIn : in std_logic_vector(31 downto 0); --address Input 
			  data1 : out std_logic_vector(DATA_WIDTH-1 downto 0); --data Output rs
			  data3 : in std_logic_vector(DATA_WIDTH-1 downto 0); --data Input 
			  MemRead : in std_logic;
			  MemWrite : in std_logic
			  ); 
	end component;
	
	
	component bancoRegs is generic ( DATA_WIDTH :integer := 32; ADDR_WIDTH :integer := 5 );
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
	
	component deslocador1 is 
		 port(
			 dataIn  :in  std_logic_vector(31 downto 0);
			  dataOut :out std_logic_vector(31 downto 0)
		 );
	end component;
	
	component deslocador2 is 
		 port(
				 dataIn :in std_logic_vector(25 downto 0);
				 dataOut :out std_logic_vector(27 downto 0)
		  );
	end component;
	
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
	
	signal ULAFonteA, EscReg, RegDst, PCEscCond, PCEsc, IouD, LerMem, EscMem, MemParaReg, IREsc : std_logic;
	signal FontePC, ULAOp, ULAFonteB : std_logic_vector(1 downto 0);
	
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
	
	signal temp, temppc, temp_dt1, temp_dt2 : std_logic_vector (31 downto 0);
	
	begin
	
		dbg_ULAFonteA <= ULAFonteA;
		dbg_EscReg <= EscReg;
		dbg_RegDst <= RegDst;
		dbg_PCEscCond <= PCEscCond;
		dbg_PCEsc <= PCEsc;
		dbg_IouD <= IouD;
		dbg_LerMem <= LerMem;
		dbg_EscMem <= EscMem;
		dbg_MemParaReg <= MemParaReg;
		dbg_IREsc <= IREsc;
		dbg_FontePC <= FontePC;
		dbg_ULAOp <= ULAOp;
		dbg_ULAFonteB <= ULAFonteB;
		dbg_dataEntradaMemInstrucao <= saidaRegB;
		dbg_entradaPC <= entradaPC;
		dbg_Result <= Result;
		dbg_addressIn <= addressIn;
		dbg_opCode <= opCode;
		dbg_funcCode <= funcCode;
		dbg_regRs <= regRs;
		dbg_regRt <= regRt;
		dbg_regRd <= regRd;
		dbg_regRd_Mux <= regRd_Mux;
		dbg_imm <= imm;
		dbg_jumpAddr <= jumpAddr;
		dbg_data_1_SaidaMemDados <= data_1_SaidaMemDados;
		dbg_data_2_SaidaMemDados <= data_2_SaidaMemDados;
		dbg_data_3_EntradaMemDados <= data_3_EntradaMemDados;
	--Sinal desvio incondicional
		--dbg_desvioJ <= desvioJ;
	
		writeEnablePC <= (PCEscCond and Zero) or PCEsc;
		desvioJ(27 downto 0) <= saidaDeslocador2;
		desvioJ(31 downto 28) <= saidaPC(31 downto 28);
		
		saidaPC <= i_endpc;
		dataSaidaMemInstrucao <= i_instrucao;
		--entrada_dbg_dados <= i_md;
		--dataSaidaMemInstrucao <= temp;
		saidaRegA <= i_data1;
		saidaRegB <= i_data2;
		
		
		control : Controle port map (clock, reset, opCode, FontePC, ULAOp, ULAFonteB, ULAFonteA, EscReg, RegDst, PCEscCond, PCEsc, IouD, LerMem, EscMem, MemParaReg, IREsc);
	
		ALUUnit : ULA_Wrapper generic map (DATA => 32) port map (RegAULA, RegBULA, ULAOp, funcCode, Result, Zero);
		RegIns : regInstrucao port map (IREsc, dataSaidaMemInstrucao, opCode, regRs, regRt, regRd, imm, jumpAddr, funcCode);
		MemIns : memoria generic map (DATA_WIDTH => 32, ADDR_WIDTH => 10 ) port map (addressIn, temp , saidaRegB, LerMem, EscMem);
		Banco : bancoRegs generic map (DATA_WIDTH => 32, ADDR_WIDTH => 5) port map (regRs, regRt, regRd_Mux, data_1_SaidaMemDados, data_2_SaidaMemDados, data_3_EntradaMemDados, EscReg);
		--Regs genericos
		RegA : bitsReg port map (data_1_SaidaMemDados, clock, temp_dt1);
		RegB : bitsReg port map (data_2_SaidaMemDados, clock, temp_dt2);
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
		Desloca1 : deslocador1 port map (saidaExtender, saidaDeslocador1);
		Desloca2 : deslocador2 port map (jumpAddr, saidaDeslocador2);
		
		PC1 : pc port map (writeEnablePC, entradaPC, temppc);
  
end behavioral;