# Copied from Echo_Server example design in Tcl / modif. by EBSM
# LPGBT_SOFT_Server --
#	Open the server listening socket
#	and enter the Tcl event loop
#
# Arguments:
#	port	The server's port number

proc GBTFPGA_SOFT_Server {port} {
    global forever
    set s [socket -server GBTFPGA_SOFTAccept $port]
    vwait forever
}

# LPGBT_SOFT_Accept --
#	Accept a connection from a new client.
#	This is called after a new socket connection
#	has been created by Tcl.
#
# Arguments:
#	sock	The new socket connection to the client
#	addr	The client's IP address
#	port	The client's port number
	
proc GBTFPGA_SOFTAccept {sock addr port} {
    global gbtfpga

    # Record the client's information

    puts "Accept $sock from $addr port $port"
    set gbtfpga(addr,$sock) [list $addr $port]

    # Ensure that each "puts" by the server
    # results in a network transmission

    fconfigure $sock -buffering line

    # Set up a callback for when the client sends data

    fileevent $sock readable [list LPGBT_SOFT $sock]
}

# LPGBT_SOFT --
#	This procedure is called when the server
#	can read data from the client
#
# Arguments:
#	sock	The socket connection to the client

proc LPGBT_SOFT {sock} {
    global gbtfpga
    global forever
    
    set gpio_rt gpio_rt
    set gpio_wt gpio_wt
	
    # Check end of file or abnormal connection drop,
    # then gbtfpga data back to the client.

    if {[eof $sock] || [catch {gets $sock line}]} {
    
        close $sock
        exit 0
        
    } else {
		################################ Process Data #################################
		set rcvd_cmd $line
        set ope [lindex $rcvd_cmd 0]
		set addr [lindex $rcvd_cmd 1]
		set data [lindex $rcvd_cmd 2]
		
        switch $ope {
          "r" {
              puts "Read register command"
			  #Rd
			  set_property CMD.ADDR $addr [get_hw_axi_txns $gpio_rt]
			  run_hw_axi [get_hw_axi_txns $gpio_rt]
			  set data [get_property DATA [get_hw_axi_txns $gpio_rt]]
			  puts $sock $data
		  }
		  
          "w" {
              puts "Write register command"
              #Wr	  
			  set_property CMD.ADDR $addr [get_hw_axi_txns $gpio_wt]
			  set_property DATA $data [get_hw_axi_txns $gpio_wt]
			  run_hw_axi [get_hw_axi_txns $gpio_wt]
			  puts $sock 1
		  }          
		  
          "wvio" {
              puts "Write VIO"
              
              set dataDec [expr $data]
              
              startgroup
              set_property OUTPUT_VALUE $dataDec [get_hw_probes $addr -of_objects [get_hw_vios -of_objects [get_hw_devices xc7vx485t_0] -filter {CELL_NAME=~"vio"}]]
              commit_hw_vio [get_hw_vios -of_objects [get_hw_devices xc7vx485t_0] -filter {CELL_NAME=~"vio"}]
              endgroup
              
			  puts $sock 1
		  }          
		  
          "rvio" {
              puts "Read VIO"
              
              startgroup
              set data [get_property INPUT_VALUE [get_hw_probes $addr]]
              endgroup
              
			  puts $sock $data
		  }
          
          "ping" {
              puts $sock 1
          }
          
          "configure" {
              open_project $addr
              open_hw
              connect_hw_server -url localhost:3121              

              open_hw_target
              
              current_hw_device [lindex [get_hw_devices] 0]
              refresh_hw_device [lindex [get_hw_devices] 0]
              
              set current_hw_device [lindex [get_hw_devices] 0]
              
              set_property PROGRAM.FILE $data $current_hw_device
              program_hw_devices $current_hw_device

              refresh_hw_device [lindex [get_hw_devices] 0]
              
              set gpio_rt gpio_rt
              set gpio_wt gpio_wt
              create_hw_axi_txn $gpio_rt [get_hw_axis hw_axi_1] -type read -address 0x00000000
              create_hw_axi_txn $gpio_wt [get_hw_axis hw_axi_1] -type write -address 0x00000000 -data {00000000}
              
              puts $sock 1
           
          }
          
          "exit" {
            exit 0
          }
          
          default {
            puts "Command not recognizable"
			puts $sock -1
          }
        }
		
		################################# End Process Data #################################
		# puts "Finished data processing"
		# puts $sock $line		
		# puts $line
	}
}
#Create Transactions


puts "############## GTFPGA_SOFT - TEST CONTROL ###############"
puts "# Socket Port: 8555                                     #"
puts "# IP Address (localhost): 127.0.0.1                     #"
puts "#########################################################"

GBTFPGA_SOFT_Server 8555
vwait forever
