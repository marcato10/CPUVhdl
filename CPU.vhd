LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY CPU IS
	PORT(Clk   :IN  STD_LOGIC;
		  Funct :IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
		  Done  :OUT STD_LOGIC;
		  W	  :IN  STD_LOGIC;
		  Data  :IN  STD_LOGIC_VECTOR(7 DOWNTO 0));
END CPU;

ARCHITECTURE LogicFunc OF CPU IS
	TYPE State_type IS(A,B,C); --Declaração dos estados
	SIGNAL y,x: State_type;
	SIGNAL barramento :STD_LOGIC_VECTOR(7 DOWNTO 0); --BUS (OU BARRAMENTO)
	
	SIGNAL dataOut	   :STD_LOGIC_VECTOR(7 DOWNTO 0); --Sinais de entrada e saída dos registradores
	SIGNAL rin:STD_LOGIC_VECTOR(3 DOWNTO 0); --Sinais de controle de entrada
	SIGNAL rOut:STD_LOGIC_VECTOR(3 DOWNTO 0); --Sinais de controle de saída
	SIGNAL rData0,rData1,rData2,rData3,rDataA,ulaData,rDataG :STD_LOGIC_VECTOR(7 DOWNTO 0);--Saída do registrador para o tristate
	SIGNAL aIn,aOut,gIn,gOut,Sub	:STD_LOGIC;
	
COMPONENT registrador IS
	PORT (Input	:IN  STD_LOGIC;
		   Clock :IN  STD_LOGIC;
			D 		:IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			Q  	:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

COMPONENT tristate IS
	PORT(Enable :IN  STD_LOGIC;
			Q		:IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			D		:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

COMPONENT somador IS
	PORT(x,y			:IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			AddSub 	:IN  STD_LOGIC;
			f			:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

BEGIN

--ULA
ula:somador PORT MAP(x => rDataA,y =>barramento, AddSub =>Sub, f=> rDataA);

--CONTROLE DO DATA
data:tristate PORT MAP(Enable => Extern,Q => Data,D => barramento);

--REGISTRADORES DE PROPÓSITO GERAL
r0:registrador PORT MAP(Input => rin(0), Clock => Clk,D => barramento, Q => rData0);
r1:registrador PORT MAP(Input => rin(1), Clock => Clk,D => barramento, Q => rData1);
r2:registrador PORT MAP(Input => rin(2), Clock => Clk,D => barramento, Q => rData2);
r3:registrador PORT MAP(Input => rin(3), Clock => Clk,D => barramento, Q => rData3);

--REGISTRADORES DE PROPÓSITO ESPECÍFICO
a:registrador PORT MAP(Input => aIn,Clock => Clk, D => barramento, Q => rDataA);
g:registrador PORT MAP(Input => gIn,Clock => Clk, D => barramento, Q => rDataG);

--TRISTATE DOS REGISTRADORES
r0t:tristate PORT MAP(Enable >= rOut(0),Q => rData0, D => barramento);
r1t:tristate PORT MAP(Enable >= rOut(1),Q => rData1, D => barramento);
r2t:tristate PORT MAP(Enable >= rOut(2),Q => rData2, D => barramento);
r3t:tristate PORT MAP(Enable >= rOut(3),Q => rData3, D => barramento);

gt:tristate  PORT MAP(Enable >= gOut,Q => rDataG, D => barramento);

PROCESS (y,x,W,Funct) --Definição dos estados
BEGIN

IF Reset = '1' THEN
	Clk <= '0';
	Funct <= "ZZZZZZZZ";
	
	
CASE y IS
	WHEN A => --O y vai receber sempre o próximo estado (x), e a partir do case, vai ser definido qual vai ser o valor do x, que será atribuído ao y (estado atual) 
	rin(0)  <= '0';
	rin(1)  <= '0';
	rin(2)  <= '0';
	rin(3)  <= '0';
	Done    <= '0';
	aIn	  <= '0';
	aOut 	  <= '0';
	gIn     <= '0';
	rOut(0) <= '0';
	rOut(1) <= '0';
	rOut(2) <= '0';
	rOut(3) <= '0';
	Extern  <= '0';
	
		IF W ='0' THEN --Se em determinado estado o w for zero, o w irá continuar nesse estado		
			x <= A;
		ELSE
		
	IF (Clock'EVENT AND Clk = '1') THEN --Clock é ativado
		
		
		IF Funct(0) = '0' AND Funct(1) = '0' THEN --Função LOAD
			
			IF Funct(2) = '0' AND Funct(3) = '0' THEN --Registrador R0 é representado por 00
			Extern <= '1'; --Extern emite sinal para que o tristate seja ativado
			rin(0) <= '1'; --R0 recebe o conteúdo de data
			Done <= '1'; --A máquina volta ao seu estado inicial
			
			ELSIF Funct(2) = '0' AND Funct(3) = '1' THEN
			Extern <= '1'; --Extern emite sinal para que o tristate seja ativado
			rin(1) <= '1'; --R1 recebe o conteúdo de data
			Done <= '1'; --A máquina volta ao seu estado inicial
			
			ELSIF Funct(2) = '1' AND Funct(3) = '0' THEN
			Extern <= '1'; --Extern emite sinal para que o tristate seja ativado
			rin(2) <= '1'; --R2 recebe o conteúdo de data
			Done <= '1'; --A máquina volta ao seu estado inicial
			
			ELSIF Funct(2) = '1' AND Funct(3) = '1' THEN
			Extern <= '1'; --Extern emite sinal para que o tristate seja ativado
			rin(3) <= '1'; --R3 recebe o conteúdo de data
			Done <= '1'; --A máquina volta ao seu estado inicial
			END IF;
			
			
		ELSIF Funct(0) = '0' AND Funct(1) = '1' THEN --Funcao MOV
		
			IF Funct(2) = '0' AND Funct(3) = '0' THEN --Registrador R0 é selecionado para receber o registrador
				IF Funct(3) = '0' AND Funct(4) = '1' THEN --Registrador R1 tem seu conteúdo transferido
					rOut(1) <= '1';
					rin(0) <= '1';
					Done <= '1';
					
				ELSIF Funct(3) = '1' AND Funct(4) = '0' THEN --Registrador R2
					rOut(2) <= '1'; --Registrador R2 tem seu conteúdo transferido
					rin(0) <= '1';
					Done <= '1';
					
				ELSE --R3
					rOut(3) <= '1'; --Registrador R3 tem seu conteúdo transferido
					rin(0) <= '1';
					Done <= '1';
				END IF;
				-- -------------------------------------------------------------
			ELSIF Funct(2) = '0' AND Funct(3) = '1' THEN --Registrador R1 é selecionado para receber conteúdo de outro registrador
				IF Funct(3) = '0' AND Funct(4) = '0' THEN --Registrador R0 tem seu conteúdo transferido
					rOut(0) <= '1';
					rin(0) <= '1';
					Done <= '1';
					
				ELSIF Funct(3) = '1' AND Funct(4) = '0' THEN
					rOut(1) <= '1'; --Registrador R2 tem seu conteúdo transferido
					rin(0) <= '1';
					Done <= '1';
					
				ELSE
					rOut(3) <= '1'; --Registrador R3 tem seu conteúdo transferido
					rin(0) <= '1';
					Done <= '1';
				END IF;
				---------------------------------------------------------------
			ELSIF Funct(2) = '1' AND Funct(3) = '0' THEN --Registrador R2 é selecionado para receber o registrador
				IF Funct(3) = '0' AND Funct(4) = '0' THEN --Registrador R0 tem seu conteúdo transferido
					rOut(0) <= '1';
					rin(2) <= '1';
					Done <= '1';
					
				ELSIF Funct(3) = '0' AND Funct(4) = '1' THEN --Registrador
					rOut(1) <= '1'; --Registrador R2 tem seu conteúdo transferido
					rin(2) <= '1';
					Done <= '1';
					
				ELSE
					rOut(3) <= '1'; --Registrador R3 tem seu conteúdo transferido
					rin(2) <= '1';
					Done <= '1';
				---------------------------------------------------------------
			ELSIF Funct(2) = '1' AND Funct(3) = '1' THEN --R3
				IF Funct(3) = '0' AND Funct(4) = '0' THEN --MOV R3,R0
					rOut(0) <= '1';
					rin(3) <= '1';
					Done <= '1';
					
				ELSIF Funct(3) = '1' AND Funct(4) = '0' THEN
					rOut(1) <= '1'; --MOV R3,R1
					rin(3) <= '1';
					Done <= '1';
					
				ELSIF Funct(3) = '1' AND Funct(4) = '1' THEN
					Done <= '1';--MOV R3,R3
				ELSE
				
					rOut(2) <= '1'; --MOV R3,R2
					rin(3) <= '1';
					Done <= '1';
				
					
				---------------------------------------------------------------
			 END IF;
		 END IF;
		END IF;
		
		ELSIF Funct(0) = '1' AND Funct(1) = '0' THEN --Função ADD
				IF Funct(2) = '0' AND Funct(3)= '0' THEN --REGISTRADOR 'A' RECEBE R0
					rOut(0) <= '1';
					aIn <= '1';
					x <= B;
				ELSIF Funct(2) = '0' AND Funct(3)= '1' THEN --REGISTRADOR 'A' RECEBE R1
					rOut(1) <= '1';
					aIn <= '1';
					x <= B;
				ELSIF Funct(2) = '1' AND Funct(3) = '0' THEN --REGISTRADOR 'A' RECEBE R2
					rOut(2) <= '1';
					aIn <= '1';
					x <= B;
					ELSE --REGISTRADOR 'A' RECEBE R3
					rOut(3) <= '1';
					aIn <= '1';
					x <= B;
				END IF;
		ELSE
				IF Funct(2) = '0' AND Funct(3) = 
		
				
				
				IF Clock'EVENT AND Clk='1' THEN
				y <= x;
				END IF;
		
		END IF;
	WHEN B =>
		

			x <= B;
			ELSE
			x <= C;
	END IF;
	y <= x;
	
	WHEN C=>
	IF W = '0' THEN
		x<= C;
		ELSE
		x<= A;
	END IF;
	y <= x;
	
	IF Done = '1' THEN
		W = '0';
		END IF;
		y <= x;
	END PROCESS;
END IF;
END PROCESS;
END LogicFunc;
