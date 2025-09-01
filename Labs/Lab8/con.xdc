set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports clk ]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports t]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports reset]
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS33} [get_ports q]


set_property CLOCK DEDICATED ROUTE FALSE [get_nets {clk IBUF}]