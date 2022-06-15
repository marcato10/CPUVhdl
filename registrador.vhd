LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY registrador IS
	PORT (D 		:IN   STD_LOGIC_VECTOR(7 DOWNTO 0) ;
			Clock :IN   STD_LOGIC;
			Input	:IN   STD_LOGIC; --Controla entrada do registrador, junto com o Clock
			Q  	:OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) ) ;
END registrador;

ARCHITECTURE Behavior OF registrador IS
BEGIN
PROCESS (Clock)
BEGIN

	IF Clock'EVENT AND Clock = '1' AND Input = '1' THEN
		Q <= D;
		
END IF;
END PROCESS ;
END Behavior;