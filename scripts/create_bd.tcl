
################################################################
# This is a generated script based on design: snic_tcp_top_final
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source snic_tcp_top_final_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvu9p-flga2104-2L-e
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name snic_tcp_top_final

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
user.org:user:TcpWrapper:1.0\
wuklab.io:user:snic_tcp_top:1.0\
wuklab.io:hls:snic_tcp_wrapper:1.0\
xilinx.com:ip:util_vector_logic:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set m_axi_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {512} \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI4} \
   ] $m_axi_0

  set m_axis_net_tx_to_endpoint_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_net_tx_to_endpoint_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $m_axis_net_tx_to_endpoint_0

  set m_axis_tx_tcp_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_tx_tcp_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $m_axis_tx_tcp_0

  set s_axi_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {16} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $s_axi_0

  set s_axis_net_rx_from_endpoint_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_net_rx_from_endpoint_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {64} \
   CONFIG.TDEST_WIDTH {8} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {192} \
   ] $s_axis_net_rx_from_endpoint_0

  set s_axis_rx_tcp_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_rx_tcp_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {64} \
   CONFIG.TDEST_WIDTH {1} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $s_axis_rx_tcp_0


  # Create ports
  set mem_aresetn_0 [ create_bd_port -dir I -type rst mem_aresetn_0 ]
  set mem_clk_0 [ create_bd_port -dir I -type clk -freq_hz 250000000 mem_clk_0 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {m_axi_0} \
   CONFIG.ASSOCIATED_RESET {mem_aresetn_0} \
 ] $mem_clk_0
  set net_aresetn_0 [ create_bd_port -dir I -type rst net_aresetn_0 ]
  set net_clk_0 [ create_bd_port -dir I -type clk -freq_hz 250000000 net_clk_0 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {s_axis_rx_tcp_0:m_axis_tx_tcp_0:s_axi_0:s_axis_net_rx_from_endpoint_0:m_axis_net_tx_to_endpoint_0} \
   CONFIG.ASSOCIATED_RESET {net_aresetn_0} \
 ] $net_clk_0

  # Create instance: TcpWrapper_0, and set properties
  set TcpWrapper_0 [ create_bd_cell -type ip -vlnv user.org:user:TcpWrapper:1.0 TcpWrapper_0 ]

  # Create instance: snic_tcp_top_0, and set properties
  set snic_tcp_top_0 [ create_bd_cell -type ip -vlnv wuklab.io:user:snic_tcp_top:1.0 snic_tcp_top_0 ]

  # Create instance: snic_tcp_wrapper_0, and set properties
  set snic_tcp_wrapper_0 [ create_bd_cell -type ip -vlnv wuklab.io:hls:snic_tcp_wrapper:1.0 snic_tcp_wrapper_0 ]

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  set_property -dict [list CONFIG.FREQ_HZ {250000000}] [get_bd_intf_pins snic_tcp_top_0/m_axi]

  # Create interface connections
  connect_bd_intf_net -intf_net TcpWrapper_0_fromTCP_out [get_bd_intf_ports m_axis_tx_tcp_0] [get_bd_intf_pins TcpWrapper_0/fromTCP_out]
  connect_bd_intf_net -intf_net TcpWrapper_0_toTCP_out [get_bd_intf_pins TcpWrapper_0/toTCP_out] [get_bd_intf_pins snic_tcp_wrapper_0/s_axis_totcp_in]
  connect_bd_intf_net -intf_net TcpWrapper_0_txToEndpoint_out [get_bd_intf_ports m_axis_net_tx_to_endpoint_0] [get_bd_intf_pins TcpWrapper_0/txToEndpoint_out]
  connect_bd_intf_net -intf_net axi_0_1 [get_bd_intf_ports s_axi_0] [get_bd_intf_pins TcpWrapper_0/axi]
  connect_bd_intf_net -intf_net rxFromEndpoint_in_0_1 [get_bd_intf_ports s_axis_net_rx_from_endpoint_0] [get_bd_intf_pins TcpWrapper_0/rxFromEndpoint_in]
  connect_bd_intf_net -intf_net s_axis_net_rx_0_1 [get_bd_intf_ports s_axis_rx_tcp_0] [get_bd_intf_pins TcpWrapper_0/toTCP_in]
  connect_bd_intf_net -intf_net snic_tcp_top_0_m_axi [get_bd_intf_ports m_axi_0] [get_bd_intf_pins snic_tcp_top_0/m_axi]
  connect_bd_intf_net -intf_net snic_tcp_wrapper_0_m_axis_fromtcp_out [get_bd_intf_pins TcpWrapper_0/fromTCP_in] [get_bd_intf_pins snic_tcp_wrapper_0/m_axis_fromtcp_out]

  # Create port connections
  connect_bd_net -net TcpWrapper_0_rxFromEndpoint_out_tdata [get_bd_pins TcpWrapper_0/rxFromEndpoint_out_tdata] [get_bd_pins snic_tcp_top_0/s_axis_net_rx_from_endpoint_data]
  connect_bd_net -net TcpWrapper_0_rxFromEndpoint_out_tkeep [get_bd_pins TcpWrapper_0/rxFromEndpoint_out_tkeep] [get_bd_pins snic_tcp_top_0/s_axis_net_rx_from_endpoint_keep]
  connect_bd_net -net TcpWrapper_0_rxFromEndpoint_out_tlast [get_bd_pins TcpWrapper_0/rxFromEndpoint_out_tlast] [get_bd_pins snic_tcp_top_0/s_axis_net_rx_from_endpoint_last]
  connect_bd_net -net TcpWrapper_0_rxFromEndpoint_out_tvalid [get_bd_pins TcpWrapper_0/rxFromEndpoint_out_tvalid] [get_bd_pins snic_tcp_top_0/s_axis_net_rx_from_endpoint_valid]
  connect_bd_net -net TcpWrapper_0_txToEndpoint_in_tready [get_bd_pins TcpWrapper_0/txToEndpoint_in_tready] [get_bd_pins snic_tcp_top_0/m_axis_net_tx_to_endpoint_ready]
  connect_bd_net -net mem_aresetn_0_1 [get_bd_ports mem_aresetn_0] [get_bd_pins snic_tcp_top_0/mem_aresetn]
  connect_bd_net -net mem_clk_0_1 [get_bd_ports mem_clk_0] [get_bd_pins snic_tcp_top_0/mem_clk]
  connect_bd_net -net net_aresetn_0_1 [get_bd_ports net_aresetn_0] [get_bd_pins snic_tcp_top_0/net_aresetn] [get_bd_pins snic_tcp_wrapper_0/ap_rst_n] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net net_clk_0_1 [get_bd_ports net_clk_0] [get_bd_pins TcpWrapper_0/clk] [get_bd_pins snic_tcp_top_0/net_clk] [get_bd_pins snic_tcp_wrapper_0/ap_clk]
  connect_bd_net -net snic_tcp_top_0_m_axis_net_tx_data [get_bd_pins snic_tcp_top_0/m_axis_net_tx_data] [get_bd_pins snic_tcp_wrapper_0/s_axis_fromtcp_in_TDATA]
  connect_bd_net -net snic_tcp_top_0_m_axis_net_tx_dest [get_bd_pins snic_tcp_top_0/m_axis_net_tx_dest] [get_bd_pins snic_tcp_wrapper_0/s_axis_fromtcp_in_TDEST]
  connect_bd_net -net snic_tcp_top_0_m_axis_net_tx_keep [get_bd_pins snic_tcp_top_0/m_axis_net_tx_keep] [get_bd_pins snic_tcp_wrapper_0/s_axis_fromtcp_in_TKEEP]
  connect_bd_net -net snic_tcp_top_0_m_axis_net_tx_last [get_bd_pins snic_tcp_top_0/m_axis_net_tx_last] [get_bd_pins snic_tcp_wrapper_0/s_axis_fromtcp_in_TLAST]
  connect_bd_net -net snic_tcp_top_0_m_axis_net_tx_to_endpoint_data [get_bd_pins TcpWrapper_0/txToEndpoint_in_tdata] [get_bd_pins snic_tcp_top_0/m_axis_net_tx_to_endpoint_data]
  connect_bd_net -net snic_tcp_top_0_m_axis_net_tx_to_endpoint_dest [get_bd_pins TcpWrapper_0/txToEndpoint_in_tdest] [get_bd_pins snic_tcp_top_0/m_axis_net_tx_to_endpoint_dest]
  connect_bd_net -net snic_tcp_top_0_m_axis_net_tx_to_endpoint_keep [get_bd_pins TcpWrapper_0/txToEndpoint_in_tkeep] [get_bd_pins snic_tcp_top_0/m_axis_net_tx_to_endpoint_keep]
  connect_bd_net -net snic_tcp_top_0_m_axis_net_tx_to_endpoint_last [get_bd_pins TcpWrapper_0/txToEndpoint_in_tlast] [get_bd_pins snic_tcp_top_0/m_axis_net_tx_to_endpoint_last]
  connect_bd_net -net snic_tcp_top_0_m_axis_net_tx_to_endpoint_valid [get_bd_pins TcpWrapper_0/txToEndpoint_in_tvalid] [get_bd_pins snic_tcp_top_0/m_axis_net_tx_to_endpoint_valid]
  connect_bd_net -net snic_tcp_top_0_m_axis_net_tx_valid [get_bd_pins snic_tcp_top_0/m_axis_net_tx_valid] [get_bd_pins snic_tcp_wrapper_0/s_axis_fromtcp_in_TVALID]
  connect_bd_net -net snic_tcp_top_0_s_axis_net_rx_from_endpoint_ready [get_bd_pins TcpWrapper_0/rxFromEndpoint_out_tready] [get_bd_pins snic_tcp_top_0/s_axis_net_rx_from_endpoint_ready]
  connect_bd_net -net snic_tcp_top_0_s_axis_net_rx_ready [get_bd_pins snic_tcp_top_0/s_axis_net_rx_ready] [get_bd_pins snic_tcp_wrapper_0/m_axis_totcp_out_TREADY]
  connect_bd_net -net snic_tcp_wrapper_0_m_axis_totcp_out_TDATA [get_bd_pins snic_tcp_top_0/s_axis_net_rx_data] [get_bd_pins snic_tcp_wrapper_0/m_axis_totcp_out_TDATA]
  connect_bd_net -net snic_tcp_wrapper_0_m_axis_totcp_out_TKEEP [get_bd_pins snic_tcp_top_0/s_axis_net_rx_keep] [get_bd_pins snic_tcp_wrapper_0/m_axis_totcp_out_TKEEP]
  connect_bd_net -net snic_tcp_wrapper_0_m_axis_totcp_out_TLAST [get_bd_pins snic_tcp_top_0/s_axis_net_rx_last] [get_bd_pins snic_tcp_wrapper_0/m_axis_totcp_out_TLAST]
  connect_bd_net -net snic_tcp_wrapper_0_m_axis_totcp_out_TVALID [get_bd_pins snic_tcp_top_0/s_axis_net_rx_valid] [get_bd_pins snic_tcp_wrapper_0/m_axis_totcp_out_TVALID]
  connect_bd_net -net snic_tcp_wrapper_0_s_axis_fromtcp_in_TREADY [get_bd_pins snic_tcp_top_0/m_axis_net_tx_ready] [get_bd_pins snic_tcp_wrapper_0/s_axis_fromtcp_in_TREADY]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins TcpWrapper_0/reset] [get_bd_pins util_vector_logic_0/Res]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces snic_tcp_top_0/m_axi] [get_bd_addr_segs m_axi_0/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces s_axi_0] [get_bd_addr_segs TcpWrapper_0/axi/reg0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


