LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY tristate IS
	PORT(Enable :IN STD_LOGIC;
			Q		:IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			D		:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END tristate;

ARCHITECTURE Behavior OF tristate IS
	BEGIN
	PROCESS (Enable,Q):
	IF Enable = '1' THEN
		D <= Q;
		ELSIF
		D <= "ZZZZZZZZ";
		END IF;
	END PROCESS;
END Behavior;