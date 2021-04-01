`timescale 1ns / 1ps
`default_nettype none

`include "davos_config.svh"
`include "davos_types.svh"

module snic_tcp_top #(
    parameter AXI_ID_WIDTH = 1,
    parameter NUM_DDR_CHANNELS = 1,
    parameter ENABLE_DDR = 1,
    parameter NUM_TCP_CHANNELS = 1
)(
    input wire    mem_clk,
    input wire    mem_aresetn,
    input wire    net_clk,
    input wire    net_aresetn,

    // Data to/from TCP module
    axi_stream.slave    s_axis_net_rx,
    axi_stream.master   m_axis_net_tx,

    // snic_handler Network
    // Data to/from Endpoint
    axi_stream.slave    s_axis_net_rx_from_endpoint,
    axi_stream.master   m_axis_net_tx_to_endpoint,

    output logic [AXI_ID_WIDTH-1:0]                 m_axi_awid  [NUM_DDR_CHANNELS-1:0],
    output logic [31:0]                             m_axi_awaddr    [NUM_DDR_CHANNELS-1:0],
    output logic [7:0]                              m_axi_awlen [NUM_DDR_CHANNELS-1:0],
    output logic [2:0]                              m_axi_awsize    [NUM_DDR_CHANNELS-1:0],
    output logic [1:0]                              m_axi_awburst   [NUM_DDR_CHANNELS-1:0],
    output logic [0:0]                              m_axi_awlock    [NUM_DDR_CHANNELS-1:0],
    output logic [3:0]                              m_axi_awcache   [NUM_DDR_CHANNELS-1:0],
    output logic [2:0]                              m_axi_awprot    [NUM_DDR_CHANNELS-1:0],
    output logic[NUM_DDR_CHANNELS-1:0]              m_axi_awvalid,
    input wire[NUM_DDR_CHANNELS-1:0]                m_axi_awready,
    output logic [511:0]                            m_axi_wdata [NUM_DDR_CHANNELS-1:0],
    output logic [63:0]                             m_axi_wstrb [NUM_DDR_CHANNELS-1:0],
    output logic[NUM_DDR_CHANNELS-1:0]              m_axi_wlast,
    output logic[NUM_DDR_CHANNELS-1:0]              m_axi_wvalid,
    input wire[NUM_DDR_CHANNELS-1:0]                m_axi_wready,
    output logic[NUM_DDR_CHANNELS-1:0]              m_axi_bready,
    input wire [AXI_ID_WIDTH-1:0]                   m_axi_bid   [NUM_DDR_CHANNELS-1:0],
    input wire [1:0]                                m_axi_bresp [NUM_DDR_CHANNELS-1:0],
    input wire[NUM_DDR_CHANNELS-1:0]                m_axi_bvalid,
    output logic [AXI_ID_WIDTH-1:0]                 m_axi_arid  [NUM_DDR_CHANNELS-1:0],
    output logic [31:0]                             m_axi_araddr    [NUM_DDR_CHANNELS-1:0],
    output logic [7:0]                              m_axi_arlen [NUM_DDR_CHANNELS-1:0],
    output logic [2:0]                              m_axi_arsize    [NUM_DDR_CHANNELS-1:0],
    output logic [1:0]                              m_axi_arburst   [NUM_DDR_CHANNELS-1:0],
    output logic [0:0]                              m_axi_arlock    [NUM_DDR_CHANNELS-1:0],
    output logic [3:0]                              m_axi_arcache   [NUM_DDR_CHANNELS-1:0],
    output logic [2:0]                              m_axi_arprot    [NUM_DDR_CHANNELS-1:0],
    output logic[NUM_DDR_CHANNELS-1:0]              m_axi_arvalid,
    input wire[NUM_DDR_CHANNELS-1:0]                m_axi_arready,
    output logic[NUM_DDR_CHANNELS-1:0]              m_axi_rready,
    input wire [AXI_ID_WIDTH-1:0]                   m_axi_rid   [NUM_DDR_CHANNELS-1:0],
    input wire [511:0]                              m_axi_rdata [NUM_DDR_CHANNELS-1:0],
    input wire [1:0]                                m_axi_rresp [NUM_DDR_CHANNELS-1:0],
    input wire[NUM_DDR_CHANNELS-1:0]                m_axi_rlast,
    input wire[NUM_DDR_CHANNELS-1:0]                m_axi_rvalid
);

// Memory Signals
axis_mem_cmd    axis_mem_read_cmd[NUM_DDR_CHANNELS]();
axi_stream      axis_mem_read_data[NUM_DDR_CHANNELS]();
axis_mem_status axis_mem_read_status[NUM_DDR_CHANNELS](); 
axis_mem_cmd    axis_mem_write_cmd[NUM_DDR_CHANNELS]();
axi_stream      axis_mem_write_data[NUM_DDR_CHANNELS]();
axis_mem_status axis_mem_write_status[NUM_DDR_CHANNELS]();

//TCP/IP DDR interface
axis_mem_cmd    axis_tcp_mem_read_cmd[NUM_TCP_CHANNELS]();
axi_stream      axis_tcp_mem_read_data[NUM_TCP_CHANNELS]();
axis_mem_status axis_tcp_mem_read_status[NUM_TCP_CHANNELS](); 
axis_mem_cmd    axis_tcp_mem_write_cmd[NUM_TCP_CHANNELS]();
axi_stream      axis_tcp_mem_write_data[NUM_TCP_CHANNELS]();
axis_mem_status axis_tcp_mem_write_status[NUM_TCP_CHANNELS]();

axis_meta #(.WIDTH(16))     axis_tcp_listen_port();
axis_meta #(.WIDTH(8))      axis_tcp_listen_port_status();
axis_meta #(.WIDTH(48))     axis_tcp_open_connection();
axis_meta #(.WIDTH(24))     axis_tcp_open_status();
axis_meta #(.WIDTH(16))     axis_tcp_close_connection();
axis_meta #(.WIDTH(88))     axis_tcp_notification();
axis_meta #(.WIDTH(32))     axis_tcp_read_package();
axis_meta #(.WIDTH(16))     axis_tcp_rx_metadata();
axi_stream #(.WIDTH(NETWORK_STACK_WIDTH))    axis_tcp_rx_data();
axis_meta #(.WIDTH(32))     axis_tcp_tx_metadata();
axi_stream #(.WIDTH(NETWORK_STACK_WIDTH))    axis_tcp_tx_data();
axis_meta #(.WIDTH(64))     axis_tcp_tx_status();

// This is our snic_handler
// Accepting data from endpoint then talk to tcp module
role_wrapper user_role_wrapper (
    .net_clk(net_clk),
    .net_aresetn(net_aresetn),

    .s_axis_net_rx_from_endpoint(s_axis_net_rx_from_endpoint),
    .m_axis_net_tx_to_endpoint(m_axis_net_tx_to_endpoint),

    // There is a certain protocol
    // check README.md
    .m_axis_listen_port(axis_tcp_listen_port),
    .s_axis_listen_port_status(axis_tcp_listen_port_status),
    .m_axis_open_connection(axis_tcp_open_connection),
    .s_axis_open_status(axis_tcp_open_status),
    .m_axis_close_connection(axis_tcp_close_connection),
    .s_axis_notifications(axis_tcp_notification),
    .m_axis_read_package(axis_tcp_read_package),
    .s_axis_rx_metadata(axis_tcp_rx_metadata),
    .s_axis_rx_data(axis_tcp_rx_data),
    .m_axis_tx_metadata(axis_tcp_tx_metadata),
    .m_axis_tx_data(axis_tcp_tx_data),
    .s_axis_tx_status(axis_tcp_tx_status)
);

// This is the TCP stack
network_stack #(
    .WIDTH(NETWORK_STACK_WIDTH),
    .TCP_EN(TCP_STACK_EN),
    .RX_DDR_BYPASS_EN(1),
    .UDP_EN(0),
    .ROCE_EN(0)
) tcp_stack_inst (
    .net_clk(net_clk),
    .net_aresetn(net_aresetn),

    // TCP data channels
    // data coming out from TCP has <IP, TCP, payload>
    .m_axis_net(m_axis_net_tx),
    .s_axis_net(s_axis_net_rx),

    // TCP access DRAM
    .m_axis_read_cmd(axis_tcp_mem_read_cmd),
    .m_axis_write_cmd(axis_tcp_mem_write_cmd),
    .s_axis_read_sts(axis_tcp_mem_read_status),
    .s_axis_write_sts(axis_tcp_mem_write_status),
    .s_axis_read_data(axis_tcp_mem_read_data),
    .m_axis_write_data(axis_tcp_mem_write_data),
   
    // TCP control signals
    .s_axis_listen_port(axis_tcp_listen_port),
    .m_axis_listen_port_status(axis_tcp_listen_port_status),

    .s_axis_open_connection(axis_tcp_open_connection),
    .m_axis_open_status(axis_tcp_open_status),
    .s_axis_close_connection(axis_tcp_close_connection),

    .m_axis_notifications(axis_tcp_notification),
    .s_axis_read_package(axis_tcp_read_package),

    .m_axis_rx_metadata(axis_tcp_rx_metadata),
    .m_axis_rx_data(axis_tcp_rx_data),

    .s_axis_tx_metadata(axis_tcp_tx_metadata),
    .s_axis_tx_data(axis_tcp_tx_data),
    .m_axis_tx_status(axis_tcp_tx_status)
);

/*
 * NOTE: With out modified version, the NUM_DDR_CHANNELS is always 1.
 * Only TCP needs to acccess DRAM. The snic_handler does not.
 *
 * Old comment:
 * Switch DRAM access between TCP stack and User Role
 * NUM_DDR_CHANNELS = 1
 * NUM_TCP_CHANNELS = 1
 */
generate for (genvar i=0; i < NUM_DDR_CHANNELS; i++) begin
    //command
    assign axis_mem_read_cmd[i].valid = axis_tcp_mem_read_cmd[i].valid;
    assign axis_tcp_mem_read_cmd[i].ready = axis_mem_read_cmd[i].ready;
    assign axis_mem_read_cmd[i].address = axis_tcp_mem_read_cmd[i].address;
    assign axis_mem_read_cmd[i].length = axis_tcp_mem_read_cmd[i].length;
    assign axis_mem_write_cmd[i].valid = axis_tcp_mem_write_cmd[i].valid;
    assign axis_tcp_mem_write_cmd[i].ready = axis_mem_write_cmd[i].ready;
    assign axis_mem_write_cmd[i].address = axis_tcp_mem_write_cmd[i].address;
    assign axis_mem_write_cmd[i].length = axis_tcp_mem_write_cmd[i].length;

    //data
    assign axis_tcp_mem_read_data[i].valid = axis_mem_read_data[i].valid;
    assign axis_mem_read_data[i].ready = axis_tcp_mem_read_data[i].ready;
    assign axis_tcp_mem_read_data[i].data = axis_mem_read_data[i].data;
    assign axis_tcp_mem_read_data[i].keep = axis_mem_read_data[i].keep;
    assign axis_tcp_mem_read_data[i].last = axis_mem_read_data[i].last;

    assign axis_mem_write_data[i].valid = axis_tcp_mem_write_data[i].valid;
    assign axis_tcp_mem_write_data[i].ready = axis_mem_write_data[i].ready;
    assign axis_mem_write_data[i].data = axis_tcp_mem_write_data[i].data;
    assign axis_mem_write_data[i].keep = axis_tcp_mem_write_data[i].keep;
    assign axis_mem_write_data[i].last = axis_tcp_mem_write_data[i].last;

    //status
    assign axis_tcp_mem_read_status[i].valid = axis_mem_read_status[i].valid;
    assign axis_mem_read_status[i].ready = axis_tcp_mem_read_status[i].ready;
    assign axis_tcp_mem_read_status[i].data = axis_mem_read_status[i].data;

    assign axis_tcp_mem_write_status[i].valid = axis_mem_write_status[i].valid;
    assign axis_mem_write_status[i].ready = axis_tcp_mem_write_status[i].ready;
    assign axis_tcp_mem_write_status[i].data = axis_mem_write_status[i].data;
end endgenerate

localparam DDR_CHANNEL0 = 0;
/* localparam DDR_CHANNEL1 = 1; */

mem_single_inf #(
    .ENABLE(ENABLE_DDR),
    .UNALIGNED(0 < NUM_TCP_CHANNELS)
) mem_inf_inst0 (
    .user_clk(net_clk),
    .user_aresetn(net_aresetn),
    .mem_clk(mem_clk),
    .mem_aresetn(mem_aresetn),

    //memory read commands
    .s_axis_mem_read_cmd(axis_mem_read_cmd[DDR_CHANNEL0]),
    .m_axis_mem_read_status(axis_mem_read_status[DDR_CHANNEL0]),
    .m_axis_mem_read_data(axis_mem_read_data[DDR_CHANNEL0]),
    .s_axis_mem_write_cmd(axis_mem_write_cmd[DDR_CHANNEL0]),
    .m_axis_mem_write_status(axis_mem_write_status[DDR_CHANNEL0]),
    .s_axis_mem_write_data(axis_mem_write_data[DDR_CHANNEL0]),
    
    /* CONTROL INTERFACE */
    // LITE interface
    //.s_axil(axil_to_modules[AxilPortDDR0]),
    
    /* DRIVER INTERFACE */
    .m_axi_awid(m_axi_awid[DDR_CHANNEL0]),
    .m_axi_awaddr(m_axi_awaddr[DDR_CHANNEL0]),
    .m_axi_awlen(m_axi_awlen[DDR_CHANNEL0]),
    .m_axi_awsize(m_axi_awsize[DDR_CHANNEL0]),
    .m_axi_awburst(m_axi_awburst[DDR_CHANNEL0]),
    .m_axi_awlock(m_axi_awlock[DDR_CHANNEL0]),
    .m_axi_awcache(m_axi_awcache[DDR_CHANNEL0]),
    .m_axi_awprot(m_axi_awprot[DDR_CHANNEL0]),
    .m_axi_awvalid(m_axi_awvalid[DDR_CHANNEL0]),
    .m_axi_awready(m_axi_awready[DDR_CHANNEL0]),
    
    .m_axi_wdata(m_axi_wdata[DDR_CHANNEL0]),
    .m_axi_wstrb(m_axi_wstrb[DDR_CHANNEL0]),
    .m_axi_wlast(m_axi_wlast[DDR_CHANNEL0]),
    .m_axi_wvalid(m_axi_wvalid[DDR_CHANNEL0]),
    .m_axi_wready(m_axi_wready[DDR_CHANNEL0]),
    
    .m_axi_bready(m_axi_bready[DDR_CHANNEL0]),
    .m_axi_bid(m_axi_bid[DDR_CHANNEL0]),
    .m_axi_bresp(m_axi_bresp[DDR_CHANNEL0]),
    .m_axi_bvalid(m_axi_bvalid[DDR_CHANNEL0]),
    
    .m_axi_arid(m_axi_arid[DDR_CHANNEL0]),
    .m_axi_araddr(m_axi_araddr[DDR_CHANNEL0]),
    .m_axi_arlen(m_axi_arlen[DDR_CHANNEL0]),
    .m_axi_arsize(m_axi_arsize[DDR_CHANNEL0]),
    .m_axi_arburst(m_axi_arburst[DDR_CHANNEL0]),
    .m_axi_arlock(m_axi_arlock[DDR_CHANNEL0]),
    .m_axi_arcache(m_axi_arcache[DDR_CHANNEL0]),
    .m_axi_arprot(m_axi_arprot[DDR_CHANNEL0]),
    .m_axi_arvalid(m_axi_arvalid[DDR_CHANNEL0]),
    .m_axi_arready(m_axi_arready[DDR_CHANNEL0]),
    
    .m_axi_rready(m_axi_rready[DDR_CHANNEL0]),
    .m_axi_rid(m_axi_rid[DDR_CHANNEL0]),
    .m_axi_rdata(m_axi_rdata[DDR_CHANNEL0]),
    .m_axi_rresp(m_axi_rresp[DDR_CHANNEL0]),
    .m_axi_rlast(m_axi_rlast[DDR_CHANNEL0]),
    .m_axi_rvalid(m_axi_rvalid[DDR_CHANNEL0])
);

endmodule

`default_nettype wire
