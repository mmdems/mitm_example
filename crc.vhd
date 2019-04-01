library IEEE;
use IEEE.std_logic_1164.all;
use work.pck_crc32_d8.all;

entity crc is
port(RxClk         : in std_logic;
	  RxData        : in std_logic_vector(7 downto 0); -- data in
	  RxDv          : in std_logic;                    -- data valid
	  RxErr         : in std_logic;                    -- data error
	  EnOut         : out std_logic;                   -- enable out
	  StartFrameOut : out std_logic;                   -- start of frame
	  EndFrameOut   : out std_logic;                   -- end of frame
	  CrcValid      : out std_logic;
	  DataOut       : out std_logic_vector(7 downto 0);
	  PacketEnOut   : out std_logic;
	  FrameEnOut    : out std_logic
	);
end crc;

architecture beh of crc is
	signal dRxData        : std_logic_vector(7 downto 0);
	signal dRxDv          : std_logic;
	signal dRxErr         : std_logic;
	signal FrameStart     : std_logic;
	signal EndFrameInt    : std_logic;
	signal StartFrameFlag : std_logic;
	signal FrameEnOutInt  : std_logic;
	signal dPacketEnOut   : std_logic;
	signal dStartFrameOut : std_logic;
begin
	process(RxClk)
		variable crc : std_logic_vector(31 downto 0) := (others => '0');
		variable tmp : std_logic_vector(7 downto 0);
	begin
		if rising_edge(RxClk) then
		
			-- FrameStart && CRC32 (init/exec)
			if RxDv = '1' then	
				if dRxData = x"55" and RxData = x"D5" and StartFrameFlag = '0' then
					FrameStart <= '1';
					StartFrameFlag <= '1';
					crc := x"FFFFFFFF";
				else
					FrameStart <= '0';
					for j in 0 to 7 loop
						tmp(j) := RxData(7 - j);
					end loop;
					crc := nextCRC32_D8(tmp, crc);
				end if;
			else
				if EndFrameInt = '1' then
					StartFrameFlag <= '0';
				end if;
			end if;
			
			--FrameEnOut
			if FrameStart = '1' then
				FrameEnOutInt <= '1';
			end if;
			if EndFrameInt = '1' then
				FrameEnOutInt <= '0';
			end if;
			
			-- CRC Valid
			if RxDv = '0' and FrameEnOutInt = '1' and crc = x"C704DD7B" then
				CrcValid <= '1';
			else
				CrcValid <= '0';
			end if;
			
		end if;
	end process;
dRxData <= RxData when rising_edge(RxClk);
DataOut <= dRxData when rising_edge(RxClk);

dRxDv <= RxDv when rising_edge(RxClk);
dRxErr <= RxErr when rising_edge(RxClk);

dStartFrameOut <= FrameStart when rising_edge(RxClk);
StartFrameOut <= dStartFrameOut when rising_edge(RxClk);

EndFrameInt <= dRxDv and not RxDv;
EndFrameOut <= EndFrameInt when rising_edge(RxClk);

dPacketEnOut <= RxDv when rising_edge(RxClk);
PacketEnOut <= dPacketEnOut when rising_edge(RxClk);

FrameEnOut <= FrameEnOutInt when rising_edge(RxClk);
end beh;

