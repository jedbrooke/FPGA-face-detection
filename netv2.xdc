## Clock Signal
set_property -dict {PACKAGE_PIN J19     IOSTANDARD LVCMOS33 } [get_ports {clk}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

## Leds
set_property -dict { PACKAGE_PIN M21    IOSTANDARD LVCMOS33 } [get_ports { user_led[0] }];
set_property -dict { PACKAGE_PIN N20    IOSTANDARD LVCMOS33 } [get_ports { user_led[1] }];
set_property -dict { PACKAGE_PIN L21    IOSTANDARD LVCMOS33 } [get_ports { user_led[2] }];
set_property -dict { PACKAGE_PIN AA21   IOSTANDARD LVCMOS33 } [get_ports { user_led[3] }];
set_property -dict { PACKAGE_PIN R19    IOSTANDARD LVCMOS33 } [get_ports { user_led[4] }];
set_property -dict { PACKAGE_PIN M16    IOSTANDARD LVCMOS33 } [get_ports { user_led[5] }];

# SPI Flash
set_property -dict { PACKAGE_PIN T19    IOSTANDARD LVCMOS33 } [get_ports { cs_n }];
set_property -dict { PACKAGE_PIN P22    IOSTANDARD LVCMOS33 } [get_ports { mosi }];
set_property -dict { PACKAGE_PIN R22    IOSTANDARD LVCMOS33 } [get_ports { miso }];
set_property -dict { PACKAGE_PIN P21    IOSTANDARD LVCMOS33 } [get_ports { vpp  }];
set_property -dict { PACKAGE_PIN R21    IOSTANDARD LVCMOS33 } [get_ports { hold }];

# Quad SPI Flash
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { cs_n }];
set_property -dict { PACKAGE_PIN P22   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[0] }];
set_property -dict { PACKAGE_PIN R22   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[1] }];
set_property -dict { PACKAGE_PIN P21   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[2] }];
set_property -dict { PACKAGE_PIN R21   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[3] }];

# Serial
set_property -dict { PACKAGE_PIN E14    IOSTANDARD LVCMOS33 } [get_ports { tx }];
set_property -dict { PACKAGE_PIN T13    IOSTANDARD LVCMOS33 } [get_ports { rx }];

# DDR3 SDRAM
set_property -dict { PACKAGE_PIN U6     IOSTANDARD SSTL15_R } [get_ports { a[0] }];
set_property -dict { PACKAGE_PIN V4     IOSTANDARD SSTL15_R } [get_ports { a[1] }];
set_property -dict { PACKAGE_PIN W5     IOSTANDARD SSTL15_R } [get_ports { a[2] }];
set_property -dict { PACKAGE_PIN V5     IOSTANDARD SSTL15_R } [get_ports { a[3] }];
set_property -dict { PACKAGE_PIN AA1    IOSTANDARD SSTL15_R } [get_ports { a[4] }];
set_property -dict { PACKAGE_PIN Y2     IOSTANDARD SSTL15_R } [get_ports { a[5] }];
set_property -dict { PACKAGE_PIN AB1    IOSTANDARD SSTL15_R } [get_ports { a[6] }];
set_property -dict { PACKAGE_PIN AB3    IOSTANDARD SSTL15_R } [get_ports { a[7] }];
