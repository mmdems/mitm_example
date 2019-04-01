
create_clock -name {clk_25_max10} -period 40.000 {clk_25_max10} 

create_clock \
    -name rx_clk_a \
    -period 8 \
    [get_ports {eneta_rx_clk}]
	 
create_clock \
    -name rx_clk_b \
    -period 8 \
    [get_ports {enetb_rx_clk}]	
	 
create_clock \
    -name virtual_phy_clk_a \
    -period 8	
	 
create_clock \
    -name virtual_phy_clk_b \
    -period 8		
		 

set_clock_groups -exclusive -group {rx_clk_a virtual_phy_clk_a}	
set_clock_groups -exclusive -group {rx_clk_b virtual_phy_clk_b}	
set_clock_groups -exclusive -group {clk_25_max10}		 



#set_multicycle_path 0 -setup -end -rise_from [get_clocks virtual_phy_clk_a] -rise_to [get_clocks {rx_clk_a}]
#set_multicycle_path 0 -setup -end -fall_from [get_clocks virtual_phy_clk_a] -fall_to [get_clocks {rx_clk_a}]
#
#set_multicycle_path 0 -setup -end -rise_from [get_clocks virtual_phy_clk_b] -rise_to [get_clocks {rx_clk_b}]
#set_multicycle_path 0 -setup -end -fall_from [get_clocks virtual_phy_clk_b] -fall_to [get_clocks {rx_clk_b}]	



set_input_delay -add_delay -clock virtual_phy_clk_a -max 1.5 [get_ports {eneta_rx_dv}]
set_input_delay -add_delay -clock virtual_phy_clk_a -min 0.5 [get_ports {eneta_rx_dv}]

set_input_delay -add_delay -clock virtual_phy_clk_b -max 1.5 [get_ports {enetb_rx_dv}]
set_input_delay -add_delay -clock virtual_phy_clk_b -min 0.5 [get_ports {enetb_rx_dv}]

set_input_delay -add_delay -clock virtual_phy_clk_a -max -clock_fall 1.5 [get_ports {eneta_rx_dv}]
set_input_delay -add_delay -clock virtual_phy_clk_a -min -clock_fall 0.5 [get_ports {eneta_rx_dv}]

set_input_delay -add_delay -clock virtual_phy_clk_b -max -clock_fall 1.5 [get_ports {enetb_rx_dv}]
set_input_delay -add_delay -clock virtual_phy_clk_b -min -clock_fall 0.5 [get_ports {enetb_rx_dv}]



set_input_delay -add_delay -clock virtual_phy_clk_a -max 0.5 [get_ports {eneta_rx_d*}]
set_input_delay -add_delay -clock virtual_phy_clk_a -min -0.5 [get_ports {eneta_rx_d*}]

set_input_delay -add_delay -clock virtual_phy_clk_b -max 0.5 [get_ports {enetb_rx_d*}]
set_input_delay -add_delay -clock virtual_phy_clk_b -min -0.5 [get_ports {enetb_rx_d*}]

set_input_delay -add_delay -clock virtual_phy_clk_a -max -clock_fall 0.5 [get_ports {eneta_rx_d*}]
set_input_delay -add_delay -clock virtual_phy_clk_a -min -clock_fall -0.5 [get_ports {eneta_rx_d*}]

set_input_delay -add_delay -clock virtual_phy_clk_b -max -clock_fall 0.5 [get_ports {enetb_rx_d*}]
set_input_delay -add_delay -clock virtual_phy_clk_b -min -clock_fall -0.5 [get_ports {enetb_rx_d*}]



derive_clock_uncertainty



set_false_path -from [get_ports {fpga_resetn}] 
set_false_path -from [get_ports {user_dipsw[*]}] 
set_false_path -from [get_ports {user_pb[*]}] 
set_false_path -to [get_ports {user_led[*]}]
set_false_path -to [get_ports {eneta_resetn}]
set_false_path -to [get_ports {enetb_resetn}]

set_false_path -from * -to {sld_signaltap:auto_signaltap_0|*}
set_false_path -from {sld_signaltap:auto_signaltap_0|*} -to *
set_false_path -from * -to {sld_signaltap:auto_signaltap_1|*}
set_false_path -from {sld_signaltap:auto_signaltap_1|*} -to *



