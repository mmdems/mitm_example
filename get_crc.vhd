library IEEE;
use IEEE.std_logic_1164.all;
use work.pck_crc32_d8.all;

entity get_crc is
port(
	 Clk       : in std_logic;
	 Reset     : in std_logic;
	 DataIn    : in std_logic_vector(7 downto 0);
	 DataDvIn  : in std_logic;
	 DataOut   : out std_logic_vector(7 downto 0);
	 DataDvOut : out std_logic
	);
end get_crc;

architecture beh of get_crc is
	signal dDataIn        : std_logic_vector(7 downto 0);
	signal dDataDvIn      : std_logic;
	signal TrailerLeft    : std_logic_vector(2 downto 0);
	signal CrcBuffer      : std_logic_vector(23 downto 0);
	
	type CrcMachine is (Idle, Exec, Reading);
	signal State : CrcMachine;
begin
dDataIn <= DataIn when rising_edge(Clk);
dDataDvIn <= DataDvIn when rising_edge(Clk);
	process(Clk)
		variable crc : std_logic_vector(31 downto 0);
		variable tmp : std_logic_vector(7 downto 0);
		variable tmp_out_1 : std_logic_vector(7 downto 0);
		variable tmp_out_2 : std_logic_vector(7 downto 0);
	begin
		if rising_edge(Clk) then
			if Reset = '1' then
				State <= Idle;
				DataOut <= x"00";
				DataDvOut <= '0';
				CrcBuffer <= (others => '0');
				crc := (others => '0');
				TrailerLeft <= "000";
			else
				case State is
					when Idle =>
						if DataDvIn = '1' then
							DataOut <= DataIn;
							DataDvOut <= '1';
							State <= Idle;
							if dDataIn = x"55" and DataIn = x"D5" then
								crc := x"FFFFFFFF";
								State <= Exec;
							end if;
						else
							DataOut <= x"00";
							DataDvOut <= '0';
							State <= Idle;
						end if;
						
					when Exec =>
						DataOut <= DataIn;
						DataDvOut <= '1';
						if DataDvIn = '1' then
							for j in 0 to 7 loop
								tmp(j) := DataIn(7 - j);
							end loop;
							crc := nextCRC32_D8(tmp, crc);
							State <= Exec;
						else
							DataOut <= not (crc(24) & crc(25) & crc(26) & crc(27) & crc(28) & crc(29) & crc(30) & crc(31));
							TrailerLeft <= "111";
							CrcBuffer <= crc(23 downto 0);
							State <= Reading;
						end if;
						
					when Reading =>
						if TrailerLeft(2) = '1' then
							DataOut <= not (CrcBuffer(16) & CrcBuffer(17) & CrcBuffer(18) & CrcBuffer(19) & CrcBuffer(20) & CrcBuffer(21) & CrcBuffer(22) & CrcBuffer(23));
							CrcBuffer <= CrcBuffer(15 downto 0) & x"00";
							DataDvOut <= '1';
							TrailerLeft <= TrailerLeft(1 downto 0) & '0';
						else
							DataOut <= x"00";
							DataDvOut <= '0';
							State <= Idle;
						end if;	
				end case;
			end if;
		end if;
	end process;

end beh;


