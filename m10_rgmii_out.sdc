## rx: A
## tx: B
#
## Создаем такт 125 МГц и применяем сгенерированные такты к выходам PLL
## pll|clk[0]: сигнал тактирования шины TXD
## pll|clk[1]: сигнал TX_CLK сдвинутый на 90 градусов
#create_clock -name input_clock -period 8 [get_ports eneta_rx_clk]
#
## Ниже используются наследованные тактовые сигналы PLL, которые также можно получить
## командой derive_pll_clocks в консоли TCL
#create_generated_clock -name tx_data_clock -source [get_pins {tx_pll|altpll_component|pll|inclk[0]}] [get_pins {tx_pll|altpll_component|pll|clk[0]}]
#create_generated_clock -name pll_output -phase 90 -source [get_pins {tx_pll|altpll_component|pll|inclk[0]}] [get_pins {tx_pll|altpll_component|pll|clk[1]}]
#
## Применяем сгенерированный тактовый сигнал к порту clk_out
#create_generated_clock -name tx_output_clock -source [get_pins {tx_pll|altpll_component|pll|clk[1]}] [get_ports {enetb_tx_clk}]
#
## Устанавливаем выходную задержку на основе выведенных ранее требований
#set_output_delay -clock tx_output_clock -max 1.0 [get_ports enetb_tx_d*]
#set_output_delay -clock tx_output_clock -min -0.8 [get_ports enetb_tx_d*] -add_delay
#set_output_delay -clock tx_output_clock -clock_fall -max 1.0 [get_ports enetb_tx_d*] -add_delay
#set_output_delay -clock tx_output_clock -clock_fall -min -0.8 [get_ports enetb_tx_d*] -add_delay
#
#set_output_delay -clock tx_output_clock -max 1.0 [get_ports {enetb_tx_en}]
#set_output_delay -clock tx_output_clock -min -0.8 [get_ports {enetb_tx_en}] -add_delay
#set_output_delay -clock tx_output_clock -clock_fall -max 1.0 [get_ports {enetb_tx_en}]
#set_output_delay -clock tx_output_clock -clock_fall -min -0.8 [get_ports {enetb_tx_en}]
#
## Исключаем не имеющие значения пути из временного анализа
#set_false_path -fall_from [get_clocks tx_data_clock] -rise_to [get_clocks tx_output_clock] -setup
#set_false_path -rise_from [get_clocks tx_data_clock] -fall_to [get_clocks tx_output_clock] -setup
#set_false_path -fall_from [get_clocks tx_data_clock] -fall_to [get_clocks tx_output_clock] -hold
#set_false_path -rise_from [get_clocks tx_data_clock] -rise_to [get_clocks tx_output_clock] -hold





# rx: B
# tx: A
# Создаем такт 125 МГц и применяем сгенерированные такты к выходам PLL
# pll|clk[0]: сигнал тактирования шины TXD
# pll|clk[1]: сигнал TX_CLK сдвинутый на 90 градусов
create_clock -name input_clock -period 8 [get_ports enetb_rx_clk]

# Ниже используются наследованные тактовые сигналы PLL, которые также можно получить
# командой derive_pll_clocks в консоли TCL
create_generated_clock -name tx_data_clock -source [get_pins {tx_pll|altpll_component|pll|inclk[0]}] [get_pins {tx_pll|altpll_component|pll|clk[0]}]
create_generated_clock -name pll_output -phase 90 -source [get_pins {tx_pll|altpll_component|pll|inclk[0]}] [get_pins {tx_pll|altpll_component|pll|clk[1]}]

# Применяем сгенерированный тактовый сигнал к порту clk_out
create_generated_clock -name tx_output_clock -source [get_pins {tx_pll|altpll_component|pll|clk[1]}] [get_ports {eneta_tx_clk}]

# Устанавливаем выходную задержку на основе выведенных ранее требований
set_output_delay -clock tx_output_clock -max 1.0 [get_ports eneta_tx_d*]
set_output_delay -clock tx_output_clock -min -0.8 [get_ports eneta_tx_d*] -add_delay
set_output_delay -clock tx_output_clock -clock_fall -max 1.0 [get_ports eneta_tx_d*] -add_delay
set_output_delay -clock tx_output_clock -clock_fall -min -0.8 [get_ports eneta_tx_d*] -add_delay

set_output_delay -clock tx_output_clock -max 1.0 [get_ports {eneta_tx_en}]
set_output_delay -clock tx_output_clock -min -0.8 [get_ports {eneta_tx_en}] -add_delay
set_output_delay -clock tx_output_clock -clock_fall -max 1.0 [get_ports {eneta_tx_en}]
set_output_delay -clock tx_output_clock -clock_fall -min -0.8 [get_ports {eneta_tx_en}]

# Исключаем не имеющие значения пути из временного анализа
set_false_path -fall_from [get_clocks tx_data_clock] -rise_to [get_clocks tx_output_clock] -setup
set_false_path -rise_from [get_clocks tx_data_clock] -fall_to [get_clocks tx_output_clock] -setup
set_false_path -fall_from [get_clocks tx_data_clock] -fall_to [get_clocks tx_output_clock] -hold
set_false_path -rise_from [get_clocks tx_data_clock] -rise_to [get_clocks tx_output_clock] -hold