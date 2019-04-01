library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity packet_gen is
	port(
		Clk       : in std_logic;
		EnIn      : in std_logic; -- сигнал разрешения на формирование нового пакета. переходим из idle в generating
		Reset     : in std_logic;
		DataOut   : out std_logic_vector(7 downto 0);
		DataDvOut : out std_logic
	);
end packet_gen;
	
architecture beh of packet_gen is
	constant ip_header_bytes   : integer := 20; -- total = max - [optional] = 24 - 4 = 20
    constant udp_header_bytes  : integer := 8;
    constant data_bytes        : integer := 16 + 1024;
    constant ip_total_bytes    : integer := ip_header_bytes + udp_header_bytes + data_bytes;
    constant udp_total_bytes   : integer := udp_header_bytes + data_bytes;
    signal counter             : std_logic_vector(11 downto 0);
    
    -- ethernet frame header
    signal eth_src_mac       : std_logic_vector(47 downto 0) := x"0123456789AB"; -- source mac
    signal eth_dst_mac       : std_logic_vector(47 downto 0) := x"3C970E87D240"; -- destination mac
    signal eth_type          : std_logic_vector(15 downto 0) := x"0800";

    -- IP header
    signal ip_version        : std_logic_vector( 3 downto 0) := x"4";    -- IPv4
    signal ip_header_len     : std_logic_vector( 3 downto 0) := x"5";    -- no [options] => len is 5
    signal ip_dscp_ecn       : std_logic_vector( 7 downto 0) := x"00";   -- type of service
    signal ip_identification : std_logic_vector(15 downto 0) := x"0000";
    signal ip_length         : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(ip_total_bytes, 16));
    signal ip_flags_and_frag : std_logic_vector(15 downto 0) := x"0000";     -- no flags 48 bytes
    signal ip_ttl            : std_logic_vector( 7 downto 0) := x"80";
    signal ip_protocol       : std_logic_vector( 7 downto 0) := x"11";       -- 17 for udp. 17 = x"11"
    signal ip_checksum       : std_logic_vector(15 downto 0) := x"0000";     -- Calcuated later on
    signal ip_src_addr       : std_logic_vector(31 downto 0) := x"C0A40140"; -- 192.168.1.64
    signal ip_dst_addr       : std_logic_vector(31 downto 0) := x"C0A80101"; -- 255.255.255.255
	
    -- for calculating the checksum
    signal ip_checksum1     : unsigned(31 downto 0) := (others => '0');
    signal ip_checksum2     : unsigned(15 downto 0) := (others => '0');
    
    -- UDP header
    signal udp_src_port      : std_logic_vector(15 downto 0) := x"1000";     -- port 4096
    signal udp_dst_port      : std_logic_vector(15 downto 0) := x"1000";     -- port 4096
    signal udp_length        : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(udp_total_bytes, 16)); 
    signal udp_checksum      : std_logic_vector(15 downto 0) := x"0000";     -- Checksum is optional, and if presentincludes the data
	
	-- MAC preamble
	constant mac_preamble : std_logic_vector(55 downto 0) := x"55555555555555";
	constant mac_sfd      : std_logic_vector(7 downto 0)  := x"D5";
	
	-- idle/generating machine
	type GenMachine is (Idle, Generating);
	signal State : GenMachine;
	
	-- counter
	signal cnt : std_logic_vector(7 downto 0) := x"00";
begin
	ip_checksum1 <= to_unsigned(0, 32) 
                 + unsigned(ip_version & ip_header_len & ip_dscp_ecn)
                 + unsigned(ip_identification)
                 + unsigned(ip_length)
                 + unsigned(ip_flags_and_frag)
                 + unsigned(ip_ttl & ip_protocol)
                 + unsigned(ip_src_addr(31 downto 16))
                 + unsigned(ip_src_addr(15 downto  0))
                 + unsigned(ip_dst_addr(31 downto 16))
                 + unsigned(ip_dst_addr(15 downto  0));
	ip_checksum2 <= ip_checksum1(31 downto 16) + ip_checksum1(15 downto 0);
	ip_checksum  <= NOT std_logic_vector(ip_checksum2);
   
	process(Clk, Reset, EnIn)
	begin
		if rising_edge(Clk) then
			if Reset = '1' then
				State <= Idle;
				DataDvOut <= '0';
				DataOut <= x"00";
				counter <= (others => '0');
				cnt <= x"00";
			else
				case State is
					when Idle =>
						if EnIn = '1' then
							DataOut <= mac_preamble(55 downto 48);
							DataDvOut <= '1';
							counter <= x"001";
							State <= Generating;
						else
							State <= Idle;
						end if;
					
					when Generating =>
						counter <= counter + '1';
						case counter is
							-- preamble
							when x"001" => DataOut <= mac_preamble(47 downto 40);
							when x"002" => DataOut <= mac_preamble(39 downto 32);
							when x"003" => DataOut <= mac_preamble(31 downto 24);
							when x"004" => DataOut <= mac_preamble(23 downto 16);
							when x"005" => DataOut <= mac_preamble(15 downto 8);
							when x"006" => DataOut <= mac_preamble(7 downto 0);
							-- sfd
							when x"007" => DataOut <= mac_sfd;
							-- destination mac
						   when x"008" => DataOut <= eth_dst_mac(47 downto 40);
						   when x"009" => DataOut <= eth_dst_mac(39 downto 32);
						   when x"00A" => DataOut <= eth_dst_mac(31 downto 24);
						   when x"00B" => DataOut <= eth_dst_mac(23 downto 16);
							when x"00C" => DataOut <= eth_dst_mac(15 downto  8);
						   when x"00D" => DataOut <= eth_dst_mac( 7 downto  0);
							-- source mac
							when x"00E" => DataOut <= eth_src_mac(47 downto 40);
							when x"00F" => DataOut <= eth_src_mac(39 downto 32);
							when x"010" => DataOut <= eth_src_mac(31 downto 24);
							when x"011" => DataOut <= eth_src_mac(23 downto 16);
							when x"012" => DataOut <= eth_src_mac(15 downto  8);
							when x"013" => DataOut <= eth_src_mac( 7 downto  0);
							-- length/type
							when x"014" => DataOut <= eth_type(15 downto  8);
							when x"015" => DataOut <= eth_type( 7 downto  0);
														
							-- user data
							-- IPv4 header
							when x"016" => DataOut <= ip_version & ip_header_len;              
							when x"017" => DataOut <= ip_dscp_ecn( 7 downto  0);
							-- length of total packet (excludes etherent header and ethernet FCS) = 0x0030
							when x"018" => DataOut <= ip_length(15 downto  8);
							when x"019" => DataOut <= ip_length( 7 downto  0);
							-- all zeros
							when x"01A" => DataOut <= ip_identification(15 downto  8);
							when x"01B" => DataOut <= ip_identification( 7 downto  0);
							-- no flags, no frament offset.
							when x"01C" => DataOut <= ip_flags_and_frag(15 downto  8);
							when x"01D" => DataOut <= ip_flags_and_frag( 7 downto  0);
							-- time to live
							when x"01E" => DataOut <= ip_ttl( 7 downto  0);
							-- protocol (UDP)
							when x"01F" => DataOut <= ip_protocol( 7 downto  0);
							-- header checksum
							when x"020" => DataOut <= ip_checksum(15 downto  8);
							when x"021" => DataOut <= ip_checksum( 7 downto  0);
							-- source address
							when x"022" => DataOut <= ip_src_addr(31 downto 24);
							when x"023" => DataOut <= ip_src_addr(23 downto 16);
							when x"024" => DataOut <= ip_src_addr(15 downto  8);
							when x"025" => DataOut <= ip_src_addr( 7 downto  0);
							-- dest address
							when x"026" => DataOut <= ip_dst_addr(31 downto 24);
							when x"027" => DataOut <= ip_dst_addr(23 downto 16);
							when x"028" => DataOut <= ip_dst_addr(15 downto  8);
							when x"029" => DataOut <= ip_dst_addr( 7 downto  0);
							
							-- UDP/IP Header - from port 4096 to port 4096
							-- source port 4096
							when x"02A" => DataOut <= udp_src_port(15 downto  8);
							when x"02B" => DataOut <= udp_src_port( 7 downto  0);
							-- target port 4096
							when x"02C" => DataOut <= udp_dst_port(15 downto  8);
							when x"02D" => DataOut <= udp_dst_port( 7 downto  0);
							-- UDP length (header + data) 24 octets
							when x"02E" => DataOut <= udp_length(15 downto  8);
							when x"02F" => DataOut <= udp_length( 7 downto  0);
							-- UDP checksum not suppled
							when x"030" => DataOut <= udp_checksum(15 downto  8);
							when x"031" => DataOut <= udp_checksum( 7 downto  0);
							
							-- 16 bytes of userdata
							when x"032" => DataOut <= x"FF";
							when x"033" => DataOut <= x"FF";
							when x"034" => DataOut <= x"FF";
							when x"035" => DataOut <= x"FF";
							when x"036" => DataOut <= x"FF";
							when x"037" => DataOut <= x"FF";
							when x"038" => DataOut <= x"FF";
							when x"039" => DataOut <= x"FF";
							when x"03A" => DataOut <= x"FF";
							when x"03B" => DataOut <= x"FF";
							when x"03C" => DataOut <= x"FF";
							when x"03D" => DataOut <= x"FF";
							when x"03E" => DataOut <= x"FF";
							when x"03F" => DataOut <= x"FF";
							when x"040" => DataOut <= x"FF";
							when x"041" => DataOut <= x"FF";
							when x"042" => DataOut <= x"FF";
							when x"043" => DataOut <= x"FF";
							when x"044" => DataOut <= x"FF";
							when x"045" => DataOut <= x"FF";
							when x"046" => DataOut <= x"FF";
							when x"047" => DataOut <= x"FF";
							when x"048" => DataOut <= x"FF";
							when x"049" => DataOut <= x"FF";
							when x"04A" => DataOut <= x"FF";
							when x"04B" => DataOut <= x"FF";
							when x"04C" => DataOut <= x"FF";
							when x"04D" => DataOut <= x"FF";
							when x"04E" => DataOut <= cnt;
							when x"04F" => DataOut <= x"BA";
							when x"050" => DataOut <= x"AD";
							when x"051" => DataOut <= x"BA";
							when x"052" => DataOut <= x"AD";
							
							-- end of generating
							when x"054" =>
								cnt <= cnt + '1';
								DataOut <= x"00";
								DataDvOut <= '0';
								State <= Idle;
								
							-- others
							when others =>
								DataOut <= x"00";
						end case;
				end case;
			end if;
		end if;

	end process;
end beh;
































