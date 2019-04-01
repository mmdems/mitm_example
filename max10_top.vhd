library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity max10_top is
	port(
		fpga_resetn			: in std_logic;
		clk_ddr3_100_p		: in std_logic;
		clk_50_max10		: in std_logic;
		clk_25_max10		: in std_logic;
		clk_lvds_125_p		: in std_logic;
		clk_10_adc			: in std_logic;

		enet_mdc			: out std_logic;
		enet_mdio			: inout std_logic;

		eneta_rx_clk_in	: in std_logic;
		eneta_rx_d			: in std_logic_vector(3 downto 0);
		eneta_rx_dv			: in std_logic;
		eneta_gtx_clk		: out std_logic;
		eneta_tx_d			: out std_logic_vector(3 downto 0);
		eneta_tx_en			: out std_logic;
		eneta_resetn		: out std_logic;
		eneta_led_link100	: in std_logic;

		enetb_rx_clk		: in std_logic;
		enetb_rx_d			: in std_logic_vector(3 downto 0);
		enetb_rx_dv			: in std_logic;
		enetb_gtx_clk		: out std_logic;
		enetb_tx_d			: out std_logic_vector(3 downto 0);
		enetb_tx_en			: out std_logic;
		enetb_resetn		: out std_logic;
		enetb_led_link100	: in std_logic
		  );
end max10_top;

architecture beh of max10_top is
	signal cnt_A       : std_logic_vector(15 downto 0);
	signal cnt_B       : std_logic_vector(15 downto 0);
	signal DataEthIn_A : std_logic_vector(7 downto 0);
	signal DvErr_A     : std_logic_vector(1 downto 0);
	
--component ddr4_in is
--	port(inclock : in  std_logic;                    
--		  dout    : out std_logic_vector(7 downto 0);
--		  pad_in  : in  std_logic_vector(3 downto 0) 
--		  );
--end component;
--
--component ddr1_in is
--	port(inclock : in  std_logic;                    
--		  dout    : out std_logic_vector(1 downto 0);
--		  pad_in  : in  std_logic 
--		  );
--end component;

begin
	process(clk_25_max10)
	begin
		if cnt_A(15) = '0' then
			cnt_A <= cnt_A + '1';
		end if;
	end process;
	eneta_resetn <= cnt_A(15);
	
	process(clk_25_max10)
	begin
		if cnt_B(15) = '0' then
			cnt_B <= cnt_B + '1';
		end if;
	end process;
	enetb_resetn <= cnt_B(15);
	
	
--	-- data rx
--	rx_ddr4: ddr4_in
--	port map(inclock => not eneta_rx_clk_in,
--				dout => DataEthIn_A,
--				pad_in => eneta_rx_d
--				);
--				
--	-- data valid/err
--	rx_ddr1: ddr1_in
--	port map(inclock => not eneta_rx_clk_in,
--				dout => DvErr_A,
--				pad_in => eneta_rx_dv
--				);
	
end beh;