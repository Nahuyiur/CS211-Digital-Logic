set_property CLOCK DEDICATED ROUTE FALSE [get_nets {clk  IBUF}]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports clk]


set_property IOSTANDARD LVCMOS33 [get_ports anode]//从左到右的八个数码管，使能信号控制
set_property PACKAGE_PIN G2 [get_ports {anode[0]}]
set_property PACKAGE_PIN C2 [get_ports {anode[1]}]
set_property PACKAGE_PIN C1 [get_ports {anode[2]}]
set_property PACKAGE_PIN H1 [get_ports {anode[3]}]
set_property PACKAGE_PIN G1 [get_ports {anode[4]}]
set_property PACKAGE_PIN F1 [get_ports {anode[5]}]
set_property PACKAGE_PIN E1 [get_ports {anode[6]}]
set_property PACKAGE_PIN G6 [get_ports {anode[7]}]
 

set_property IOSTANDARD LVCMOS33 [get_ports seg1]//左边四个数码管
set_property PACKAGE_PIN B4 [get_ports {seg1[7]}]
set_property PACKAGE_PIN A4 [get_ports {seg1[6]}]
set_property PACKAGE_PIN A3 [get_ports {seg1[5]}]
set_property PACKAGE_PIN B1 [get_ports {seg1[4]}]
set_property PACKAGE_PIN A1 [get_ports {seg1[3]}]
set_property PACKAGE_PIN B3 [get_ports {seg1[2]}]
set_property PACKAGE_PIN B2 [get_ports {seg1[1]}]
set_property PACKAGE_PIN D5 [get_ports {seg1[0]}]


set_property IOSTANDARD LVCMOS33 [get_ports seg2]//右边四个数码管
set_property PACKAGE_PIN D4 [get_ports {seg2[7]}]
set_property PACKAGE_PIN E3 [get_ports {seg2[6]}]
set_property PACKAGE_PIN D3 [get_ports {seg2[5]}]
set_property PACKAGE_PIN F4 [get_ports {seg2[4]}]
set_property PACKAGE_PIN F3 [get_ports {seg2[3]}]
set_property PACKAGE_PIN E2 [get_ports {seg2[2]}]
set_property PACKAGE_PIN D2 [get_ports {seg2[1]}]
set_property PACKAGE_PIN H2 [get_ports {seg2[0]}]