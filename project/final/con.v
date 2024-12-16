# Constraints for cal_top module on Xilinx Artix-7 Board (e.g., Basys-3)
 
# Define clock
set_property CLOCK DEDICATED ROUTE FALSE [get_nets {clk  IBUF}]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports clk]
 
# Define reset
set_property PACKAGE_PIN P15 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
 
# Define confirm
set_property PACKAGE_PIN R15 [get_ports confirm]
set_property IOSTANDARD LVCMOS33 [get_ports confirm]

# Define exit
set_property PACKAGE_PIN R17 [get_ports exit]
set_property IOSTANDARD LVCMOS33 [get_ports exit]

# Define change
set_property PACKAGE_PIN R11 [get_ports change]
set_property IOSTANDARD LVCMOS33 [get_ports change]

# Define power
set_property PACKAGE_PIN V1 [get_ports power_button]
set_property IOSTANDARD LVCMOS33 [get_ports power_button]
 
# Define select
set_property PACKAGE_PIN U4 [get_ports select]
set_property IOSTANDARD LVCMOS33 [get_ports select]
 
# Define input [7:0] (from DIP switches)
set_property PACKAGE_PIN R1  [get_ports {in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in[0]}]
set_property PACKAGE_PIN N4  [get_ports {in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in[1]}]
set_property PACKAGE_PIN M4  [get_ports {in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in[2]}]
set_property PACKAGE_PIN R2  [get_ports {in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in[3]}]
set_property PACKAGE_PIN P2  [get_ports {in[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in[4]}]
set_property PACKAGE_PIN P3 [get_ports {in[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in[5]}]
set_property PACKAGE_PIN P4 [get_ports {in[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in[6]}]
set_property PACKAGE_PIN P5 [get_ports {in[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports Seg1]
set_property PACKAGE_PIN B4 [get_ports {Seg1[7]}]
set_property PACKAGE_PIN A4 [get_ports {Seg1[6]}]
set_property PACKAGE_PIN A3 [get_ports {Seg1[5]}]
set_property PACKAGE_PIN B1 [get_ports {Seg1[4]}]
set_property PACKAGE_PIN A1 [get_ports {Seg1[3]}]
set_property PACKAGE_PIN B3 [get_ports {Seg1[2]}]
set_property PACKAGE_PIN B2 [get_ports {Seg1[1]}]
set_property PACKAGE_PIN D5 [get_ports {Seg1[0]}]


set_property IOSTANDARD LVCMOS33 [get_ports Seg2]
set_property PACKAGE_PIN D4 [get_ports {Seg2[7]}]
set_property PACKAGE_PIN E3 [get_ports {Seg2[6]}]
set_property PACKAGE_PIN D3 [get_ports {Seg2[5]}]
set_property PACKAGE_PIN F4 [get_ports {Seg2[4]}]
set_property PACKAGE_PIN F3 [get_ports {Seg2[3]}]
set_property PACKAGE_PIN E2 [get_ports {Seg2[2]}]
set_property PACKAGE_PIN D2 [get_ports {Seg2[1]}]
set_property PACKAGE_PIN H2 [get_ports {Seg2[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports anode]
set_property PACKAGE_PIN G2 [get_ports {anode[0]}]
set_property PACKAGE_PIN C2 [get_ports {anode[1]}]
set_property PACKAGE_PIN C1 [get_ports {anode[2]}]
set_property PACKAGE_PIN H1 [get_ports {anode[3]}]
set_property PACKAGE_PIN G1 [get_ports {anode[4]}]
set_property PACKAGE_PIN F1 [get_ports {anode[5]}]
set_property PACKAGE_PIN E1 [get_ports {anode[6]}]
set_property PACKAGE_PIN G6 [get_ports {anode[7]}]
 
 
# Define leds[7:0] (to LEDs)
set_property IOSTANDARD LVCMOS33 [get_ports led1]
set_property PACKAGE_PIN K2  [get_ports {led1[0]}]
set_property PACKAGE_PIN J2  [get_ports {led1[1]}]
set_property PACKAGE_PIN J3  [get_ports {led1[2]}]
set_property PACKAGE_PIN H4  [get_ports {led1[3]}]
set_property PACKAGE_PIN J4  [get_ports {led1[4]}]
set_property PACKAGE_PIN G3  [get_ports {led1[5]}]
set_property PACKAGE_PIN G4  [get_ports {led1[6]}]
set_property PACKAGE_PIN F6  [get_ports {led1[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports led2]
set_property PACKAGE_PIN K3  [get_ports {led2[0]}]
set_property PACKAGE_PIN M1  [get_ports {led2[1]}]
set_property PACKAGE_PIN L1  [get_ports {led2[2]}]
set_property PACKAGE_PIN K6  [get_ports {led2[3]}]
set_property PACKAGE_PIN J5  [get_ports {led2[4]}]
set_property PACKAGE_PIN H5  [get_ports {led2[5]}]
set_property PACKAGE_PIN H6  [get_ports {led2[6]}]
set_property PACKAGE_PIN K1  [get_ports {led2[7]}]

set_property PACKAGE_PIN T1 [get_ports pwm_out]
set_property IOSTANDARD LVCMOS33 [get_ports pwm_out]

set_property IOSTANDARD LVCMOS33 [get_ports {dip_switch[*]}]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {dip_switch[0]}]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports {dip_switch[1]}]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {dip_switch[2]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {dip_switch[3]}]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {dip_switch[4]}]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports {dip_switch[5]}]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports {dip_switch[6]}]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {dip_switch[7]}]