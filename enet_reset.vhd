library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity enet_reset is
	port(clk_25_max10 : in std_logic;
		  eneta_resetn : out std_logic;
		  enetb_resetn : out std_logic
		  );
end enet_reset;

architecture beh of enet_reset is
	signal cnt_A : std_logic_vector(19 downto 0) := (others => '0');
begin
	-- eneta_resetn
	process(clk_25_max10)
	begin
		if rising_edge(clk_25_max10) then
			if cnt_A(19) = '0' then
				cnt_A <= cnt_A + '1';
			end if;
		end if;
	end process;
	eneta_resetn <= cnt_A(19);
	enetb_resetn <= cnt_A(19);
end beh;