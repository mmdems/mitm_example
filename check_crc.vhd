library IEEE;
use IEEE.std_logic_1164.all;
use work.pck_crc32_d8.all;

entity check_crc is
port(Clk           : in std_logic;
	  DataIn        : in std_logic_vector(7 downto 0);
	  DataDvIn      : in std_logic;
	  StartFrameOut : out std_logic;
	  FrameEnOut    : out std_logic;
	  CrcValid      : out std_logic;
	  DataOut       : out std_logic_vector(7 downto 0);
	  DataDvOut     : out std_logic;
	  SoP           : out std_logic;
	  EoP           : out std_logic
	);
end check_crc;

architecture beh of check_crc is
	signal dDataIn        : std_logic_vector(7 downto 0) := x"00";
	signal dDataDvIn      : std_logic := '0';
	signal FrameStart     : std_logic := '0';
	signal dEoP    : std_logic := '0';
	signal StartFrameFlag : std_logic := '0';
	signal FrameEnOutInt  : std_logic := '0';
	signal dPacketEnOut   : std_logic := '0';
	signal dStartFrameOut : std_logic := '0';
	signal dSoP   : std_logic := '0';
begin
	process(Clk)
		variable crc : std_logic_vector(31 downto 0) := (others => '0');
		variable tmp : std_logic_vector(7 downto 0);
	begin
		if rising_edge(Clk) then
		
			-- FrameStart && CRC32 (init/exec)
			if DataDvIn = '1' then	
				if dDataIn = x"55" and DataIn = x"D5" and StartFrameFlag = '0' then
					FrameStart <= '1';
					StartFrameFlag <= '1';
					crc := x"FFFFFFFF";
				else
					FrameStart <= '0';
					for j in 0 to 7 loop
						tmp(j) := DataIn(7 - j);
					end loop;
					crc := nextCRC32_D8(tmp, crc);
				end if;
			else
				if dEoP = '1' then
					StartFrameFlag <= '0';
				end if;
			end if;
			
			--FrameEnOut
			if FrameStart = '1' then
				FrameEnOutInt <= '1';
			end if;
			if dEoP = '1' then
				FrameEnOutInt <= '0';
			end if;
			
			-- CRC Valid
			if DataDvIn = '0' and FrameEnOutInt = '1' and crc = x"C704DD7B" then
				CrcValid <= '1';
			else
				CrcValid <= '0';
			end if;
			
			-- SoP
			if DataDvIn = '1' and dDataDvIn = '0' then
				dSoP <= '1';
			else
				dSoP <= '0';
			end if;
			
		end if;
	end process;
dDataIn <= DataIn when rising_edge(Clk);
DataOut <= dDataIn when rising_edge(Clk);

dDataDvIn <= DataDvIn when rising_edge(Clk);

dStartFrameOut <= FrameStart when rising_edge(Clk);
StartFrameOut <= dStartFrameOut when rising_edge(Clk);

dEoP <= dDataDvIn and not DataDvIn;
EoP <= dEoP when rising_edge(Clk);


DataDvOut <= dDataDvIn when rising_edge(Clk);

FrameEnOut <= FrameEnOutInt when rising_edge(Clk);

SoP <= dSoP when rising_edge(Clk);
end beh;


