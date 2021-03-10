`timescale 1ns / 1ps
`default_nettype none

module role_wrapper #(
    parameter NUM_ROLE_DDR_CHANNELS = 0,
    parameter NUM_DDR_CHANNELS = 1
) (
    input wire      net_clk,
    input wire      net_aresetn,
    
    output logic    user_clk,
    output logic    user_aresetn,

    /* NETWORK  - TCP/IP INTERFACE */
    // open port for listening
    axis_meta.master    m_axis_listen_port,
    axis_meta.slave     s_axis_listen_port_status,
   
    axis_meta.master    m_axis_open_connection,
    axis_meta.slave     s_axis_open_status,
    axis_meta.master    m_axis_close_connection,

    axis_meta.slave     s_axis_notifications,
    axis_meta.master    m_axis_read_package,
    
    axis_meta.slave     s_axis_rx_metadata,
    axi_stream.slave    s_axis_rx_data,
    
    axis_meta.master    m_axis_tx_metadata,
    axi_stream.master   m_axis_tx_data,
    axis_meta.slave     s_axis_tx_status
);

//Chose user clock
assign user_clk = net_clk;
assign user_aresetn = net_aresetn;

benchmark_role #(
    .NUM_ROLE_DDR_CHANNELS(NUM_DDR_CHANNELS - NUM_TCP_CHANNELS)
) user_role (
    .user_clk(user_clk),
    .user_aresetn(user_aresetn),

    /* NETWORK - TCP/IP INTERFACWE */
    .m_axis_listen_port(m_axis_listen_port),
    .s_axis_listen_port_status(s_axis_listen_port_status),
    .m_axis_open_connection(m_axis_open_connection),
    .s_axis_open_status(s_axis_open_status),
    .m_axis_close_connection(m_axis_close_connection),
    .s_axis_notifications(s_axis_notifications),
    .m_axis_read_package(m_axis_read_package),
    .s_axis_rx_metadata(s_axis_rx_metadata),
    .s_axis_rx_data(s_axis_rx_data),
    .m_axis_tx_metadata(m_axis_tx_metadata),
    .m_axis_tx_data(m_axis_tx_data),
    .s_axis_tx_status(s_axis_tx_status)
);
endmodule
`default_nettype wire
