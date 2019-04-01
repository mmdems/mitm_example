library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

entity fifo_main is
port(
	Clk       : in std_logic;
	Reset     : in std_logic;
	DataIn    : in std_logic_vector(7 downto 0);
	DataDvIn  : in std_logic;
	SoP       : in std_logic;
	EoP       : in std_logic;
	DataOut   : out std_logic_vector(7 downto 0);
	DataDvOut : out std_logic;
	EoPOut    : out std_logic;
	BusyOut   : out std_logic;
	EnIn      : in std_logic
	);
end fifo_main;

architecture beh of fifo_main is
	signal dDataIn    : std_logic_vector(7 downto 0);
	signal dEoP       : std_logic;
	signal RdReqData  : std_logic;
	signal DataOutInt : std_logic_vector(7 downto 0);

	type ReadingMachine is (Reading, Pause, Idle);
	signal ReadingState   : ReadingMachine;
	signal EmptyLength    : std_logic;
	signal RdReqLength    : std_logic;
	signal TxFrameLen     : std_logic_vector(12 downto 0);
	signal FrameLengthOut : std_logic_vector(12 downto 0);
	signal PauseCnt       : std_logic_vector(2 downto 0);
	signal BusyOutInt     : std_logic;

	signal dDataDvIn : std_logic;
	
	signal MaxLen         : std_logic; -- кадр, длина которого превышает 8к
	signal WrReqLen       : std_logic;
begin
	dDataIn <= DataIn when rising_edge(Clk);
	dEoP <= EoP when rising_edge(Clk);
	dDataDvIn <= DataDvIn when rising_edge(Clk);
	DataOut <= DataOutInt;	
	WrReqLen <= MaxLen or EoP;
		
	BusyOut <= BusyOutInt or not EmptyLength;
	
	-- cnt of lengths
	process(Clk, Reset)
		variable LenCnt : std_logic_vector(12 downto 0);
	begin
		if rising_edge(Clk) then
			if Reset = '1' then
				TxFrameLen <= (others => '0');
				MaxLen <= '0';
			elsif DataDvIn = '1' then
				if SoP = '1' then
					LenCnt := conv_std_logic_vector(1, 13);
				else
					LenCnt := TxFrameLen;
				end if;
				TxFrameLen <= LenCnt + '1';
			----------------------	
				if TxFrameLen = conv_std_logic_vector(8191, 13) then
					MaxLen <= '1';
				else
					MaxLen <= '0';
				end if;
			end if;
		end if;
	end process;
	
	-- reading
	process(Clk, Reset)
		variable CurrentLength : std_logic_vector(12 downto 0);
	begin
		if rising_edge(Clk) then
			if Reset = '1' then
				ReadingState <= Idle;
				DataDvOut <= '0';
				EoPOut <= '0';
				BusyOutInt <= '0';
				PauseCnt <= "000";
				RdReqLength <= '0';
				RdReqData <= '0';
			else
				case ReadingState is
					when Idle =>
						if EmptyLength = '0' and EnIn = '1' then
							CurrentLength := FrameLengthOut;
							RdReqLength <= '1';
							RdReqData <= '1';
							BusyOutInt <= '1';
							ReadingState <= Reading;
						else
							ReadingState <= Idle;
						end if;
					
					when Reading =>
						DataDvOut <= '1';
						RdReqLength <= '0';
						if CurrentLength = conv_std_logic_vector(1, 13) then -- (1, 13)
							RdReqData <= '0';
							EoPOut <= '1';
						else		
							CurrentLength := CurrentLength - 1;
							ReadingState <= Reading;
						end if;
						
						if RdReqData = '0' then
							PauseCnt <= "000";
							DataDvOut <= '0';
							EoPOut <= '0';
							ReadingState <= Pause;
						end if;
					
					when Pause =>
						if PauseCnt = "111" then
							if EmptyLength = '0' then
								CurrentLength := FrameLengthOut;
								RdReqLength <= '1';
								RdReqData <= '1';
								ReadingState <= Reading;
							else
								DataDvOut <= '0';
								EoPOut <= '0';
								BusyOutInt <= '0';
								ReadingState <= Idle;
							end if;
						else
							RdReqData <= '0';
							PauseCnt <= PauseCnt + '1';
							ReadingState <= Pause;
						end if;
				end case;
			end if;
		end if;
	end process;
	
	fifo_packet_data : scfifo
	generic map(
		lpm_width => 8,
		lpm_widthu => 16,
		lpm_numwords => 65536,
		lpm_showahead => "OFF",
		lpm_type => "SCFIFO",
		overflow_checking => "OFF",
		underflow_checking => "OFF"
		)
	port map(
		clock => Clk,
		data => dDataIn,
		wrreq => dDataDvIn,
		rdreq => RdReqData,
		q => DataOutInt
	);

	fifo_of_packet_lengths : scfifo
	generic map(
		lpm_width => 13,
		lpm_widthu => 3,
		lpm_numwords => 8,
		lpm_showahead => "ON",
		lpm_type => "SCFIFO",
		overflow_checking => "OFF",
		underflow_checking => "OFF"
		)
	port map(
		clock => Clk,
		data => TxFrameLen,
		wrreq => WrReqLen,
		rdreq => RdReqLength,
		empty => EmptyLength,
		q => FrameLengthOut
	);

end beh;
