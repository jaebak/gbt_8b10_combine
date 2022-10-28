#===================================================================================================#
#===================================   Srcipt Information   ========================================#
#===================================================================================================#
#                                                                                         
# Company:               CERN (EP-ESE-BE)                                                         
# Engineer:              Julian Mendez (julian.mendez@cern.ch)
#                                                                                                 
# Project Name:          GBT-FPGA                                                                
# Script Name:           Xilinx Kintex Ultrascale - GBT Bank                                        
#                                                                                                 
# Language:              TCL (Xilinx version)                                                              
#                                                                                                   
# Target Device:         Xilinx Kintex Ultrascale                                                
#                                                                                                   
# Version:               4.1                                                                      
#
# Description:            
#
# Versions history:      DATE         VERSION   AUTHOR            DESCRIPTION
#
#                        19/07/2016   4.1       J. Mendez         First .tcl script definition
#
# Additional Comments:   TCL script for adding the source files of the Xilinx Kintex Ultrascale
#                        GBT Bank to Vivado
#
#===================================================================================================#
#===================================================================================================#
#===================================================================================================#

#===================================================================================================#
#============================ Absolute Data Path Set By The User ===================================#
#===================================================================================================#

# Comment: The user has to provide the absolute data path to the root folder of the GBT-FPGA Core
#          source files.

set SCRIPT_PATH [file dirname [info script]]
set SOURCE_PATH $SCRIPT_PATH/..

#===================================================================================================#
#=================== Commands for Adding the Source Files of the GBT-FPGA Core =====================#
#===================================================================================================#
      
# Comment: Adding Common files: 

puts "->"
puts "-> Adding common files of the GBT-FPGA Core to the VIVADO project..."
puts "->" 

puts "->"
puts "-> Adding common files of the GBT-FPGA Core to the VIVADO project..."
puts "->" 

add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_decoder.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_decoder_gbtframe_chnsrch.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_decoder_gbtframe_deintlver.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_decoder_gbtframe_elpeval.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_decoder_gbtframe_errlcpoly.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_decoder_gbtframe_lmbddet.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_decoder_gbtframe_rs2errcor.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_decoder_gbtframe_rsdec.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_decoder_gbtframe_syndrom.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_descrambler.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_descrambler_16bit.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_descrambler_21bit.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_gearbox.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_gearbox_latopt.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_gearbox_std.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_rx/gbt_rx_gearbox_std_rdctrl.vhd

add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_encoder.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_encoder_gbtframe_intlver.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_encoder_gbtframe_polydiv.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_encoder_gbtframe_rsencode.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_gearbox.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_gearbox_latopt.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_gearbox_phasemon.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_gearbox_std.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_gearbox_std_rdwrctrl.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_scrambler.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_scrambler_16bit.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_tx/gbt_tx_scrambler_21bit.vhd

add_files $SOURCE_PATH/gbt_bank/core_sources/mgt/mgt_bitslipctrl.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/mgt/mgt_framealigner_pattsearch.vhd

add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_bank.vhd
add_files $SOURCE_PATH/gbt_bank/core_sources/gbt_bank_package.vhd

# Comment: Adding Xilinx Kintex 7 & Virtex 7 specific files:

puts "-> Adding Xilinx Kintex 7 & Virtex 7 specific files of the GBT-FPGA Core to the VIVADO project..."
puts "->" 


add_files $SOURCE_PATH/gbt_bank/xilinx_ku/xlx_ku_gbt_bank_package.vhd

add_files $SOURCE_PATH/gbt_bank/xilinx_ku/gbt_rx/xlx_ku_gbt_rx_gearbox_std_dpram.vhd
add_files $SOURCE_PATH/gbt_bank/xilinx_ku/gbt_tx/xlx_ku_gbt_tx_gearbox_std_dpram.vhd
add_files $SOURCE_PATH/gbt_bank/xilinx_ku/mgt/xlx_ku_mgt.vhd
add_files $SOURCE_PATH/gbt_bank/xilinx_ku/mgt/xlx_ku_mgt_ip_reset_synchronizer.vhd

import_ip $SOURCE_PATH/gbt_bank/xilinx_k7v7/gbt_rx/gbt_rx.xcix -name xlx_ku_rx_dpram
import_ip $SOURCE_PATH/gbt_bank/xilinx_k7v7/gbt_tx/gbt_tx.xcix -name xlx_ku_tx_dpram
import_ip $SOURCE_PATH/gbt_bank/xilinx_k7v7/mgt/mgt_ip_vhd/xlx_ku_mgt_ip.xcix -name xlx_ku_mgt_ip

#####################################################################################################
#####################################################################################################