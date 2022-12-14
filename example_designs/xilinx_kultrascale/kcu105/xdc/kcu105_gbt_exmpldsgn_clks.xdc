##===================================================================================================##
##========================= Xilinx design constraints (XDC) information =============================##
##===================================================================================================##
##
## Company:               WUT (ISE PERG)
## Engineer:              Adrian Byszuk (a.byszuk@elka.pw.edu.pl)
##
## Project Name:          GBT-FPGA
## XDC File Name:         KC705 - GBT Bank example design clocks
##
## Target Device:         KC705 (Xilinx Kintex 7)
## Tool version:          Vivado 2014.4
##
## Version:               4.0
##
## Description:
##
## Versions history:      DATE         VERSION   AUTHOR              DESCRIPTION
##
##                        17/12/2014   1.0       Julian Mendez       First .xdc definition
##
## Additional Comments:
##
##===================================================================================================##
##===================================================================================================##

##===================================================================================================##
##=========================================  CLOCKS  ================================================##
##===================================================================================================##

##==============##
## FABRIC CLOCK ##
##==============##

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports SYSCLK_N]
set_property PACKAGE_PIN AK17 [get_ports SYSCLK_P]
set_property PACKAGE_PIN AK16 [get_ports SYSCLK_N]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports SYSCLK_P]

create_clock -period 3.33 -name SYSCLK_P [get_ports SYSCLK_P]
set_clock_groups -asynchronous -group SYSCLK_P

##==============##
## FABRIC CLOCK ##
##==============##

# IO_L13P_T2_MRCC_15
set_property IOSTANDARD LVDS [get_ports USER_CLOCK_P]
# IO_L13N_T2_MRCC_15
set_property PACKAGE_PIN G10 [get_ports USER_CLOCK_P]
set_property PACKAGE_PIN F10 [get_ports USER_CLOCK_N]
set_property IOSTANDARD LVDS [get_ports USER_CLOCK_N]

create_clock -period 8.00 -name USER_CLOCK [get_ports USER_CLOCK_P]
set_clock_groups -asynchronous -group USER_CLOCK

##===========##
## MGT CLOCK ##
##===========##

## Comment: * The MGT reference clock MUST be provided by an external clock generator.
##
##          * The MGT reference clock frequency must be 120MHz for the latency-optimized GBT Bank.

# MGTREFCLK1P_117
# MGTREFCLK1N_117
set_property PACKAGE_PIN V6 [get_ports SMA_MGT_REFCLK_P]
set_property PACKAGE_PIN V5 [get_ports SMA_MGT_REFCLK_N]

create_clock -period 8.333 -name SMA_MGT_REFCLK [get_ports SMA_MGT_REFCLK_P]
##===================================================================================================##
##===================================================================================================##

