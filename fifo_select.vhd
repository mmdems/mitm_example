library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fifo_select is
port(
	Clk            : in std_logic;
	FifoMainBusy   : in std_logic;
    FifoInjectBusy : in std_logic;
	FifoMainEn     : out std_logic;
	FifoInjectEn   : out std_logic
	 );
end fifo_select;

architecture beh of fifo_select is
begin	
	FifoMainEn <= FifoMainBusy and not FifoInjectBusy; -- sel: 1 for master, 0 for slave
	FifoInjectEn <= not (FifoMainBusy and not FifoInjectBusy);
end beh;