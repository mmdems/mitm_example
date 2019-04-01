library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity enable_div is
port(
	Clk   : in std_logic;
	Reset : in std_logic;
	EnIn  : in std_logic;
	EnOut : out std_logic
	 );
end enable_div;

architecture beh of enable_div is
	signal Cnt : std_logic_vector(20 downto 0) := (others => '0');
begin	
	process(Clk, Reset)
	begin
		if rising_edge(Clk) then
			if Reset = '1' then
				Cnt <= (others => '0');
			else
				Cnt <= Cnt + '1';
			end if;
			
			if Cnt = conv_std_logic_vector(1, 21) then
				EnOut <= EnIn;
			else
				EnOut <= '0';
			end if;
		end if;
	end process;
end beh;