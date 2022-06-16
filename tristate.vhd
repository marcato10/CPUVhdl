LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY somador IS
	PORT(x,y			:IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			AddSub 	:IN  STD_LOGIC;
			f			:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
			
END somador;

ARCHITECTURE LogicFunc OF somador IS
	
BEGIN
	PROCESS(AddSub)
	BEGIN
	IF AddSub ='0'THEN
	f <= x + y;
	ELSE
	f <= x + NOT y + 1; --É FEITO COMPLEMENTO DE 2
	END IF;
	END PROCESS;
END LogicFunc;
