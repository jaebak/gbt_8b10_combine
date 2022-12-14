##===================================================================================================##
##========================= Xilinx design constraints (XDC) information =============================##
##===================================================================================================##
##
## Company:               WUT (ISE PERG)
## Engineer:              Adrian Byszuk (a.byszuk@elka.pw.edu.pl)
##
## Project Name:          GBT-FPGA
## XDC File Name:         KC705 - GBT Bank example design floorplanning
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
set_property RXSLIDE_MODE "PMA" [get_cells -hier -filter {NAME =~ *gbt_inst*GTHE3_CHANNEL_PRIM_INST}]

##===================================================================================================##
##======================================  FLOORPLANNING  ============================================##
##===================================================================================================##

##==========##
## P BLOCKS ##
##==========##

#create_pblock sfpQuad_area
#add_cells_to_pblock [get_pblocks sfpQuad_area] [get_cells -quiet [list genRst]]
#resize_pblock [get_pblocks sfpQuad_area] -add {CLOCKREGION_X1Y5:CLOCKREGION_X1Y5}

##============##
## PRIMITIVES ##
##============##

## TX_FRAMECLK PLL:
##-----------------

#set_property LOC PLLE2_ADV_X3Y2 [get_cells txPll/inst/plle2_adv_inst]

## RX_FRAMECLK PHASE ALIGNER (Lat Opt only):
##------------------------------------------

#set_property LOC MMCME2_ADV_X0Y6 [get_cells gbtExmplDsgn/*/latOpt_phalgnr_gen.mmcm_inst/pll/inst/mmcm_adv_inst]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets gbtExmplDsgn/rxFrmClkPhAlgnr/latOpt_phalgnr_gen.mmcm_inst/pll/inst/clk_out1_xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm]

##===================================================================================================##
##===================================================================================================##

