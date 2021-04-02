`timescale 1ns / 1ps
`default_nettype none

module snic_handler_wrapper (
    input wire      net_clk,
    input wire      net_aresetn,
    
    axi_stream.slave    s_axis_net_rx_from_endpoint,
    axi_stream.master   m_axis_net_tx_to_endpoint,

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

snic_handler_ip snic_handler(
   .ap_clk(net_clk),                                                          // input wire aclk
   .ap_rst_n(net_aresetn),                                                    // input wire aresetn

   .s_axis_dataFromEndpoint_TDATA(s_axis_net_rx_from_endpoint.data),
   .s_axis_dataFromEndpoint_TKEEP(s_axis_net_rx_from_endpoint.keep),
   .s_axis_dataFromEndpoint_TLAST(s_axis_net_rx_from_endpoint.last),
   .s_axis_dataFromEndpoint_TVALID(s_axis_net_rx_from_endpoint.valid),
   .s_axis_dataFromEndpoint_TREADY(s_axis_net_rx_from_endpoint.ready),

   .m_axis_dataToEndpoint_TDATA(m_axis_net_tx_to_endpoint.data),
   .m_axis_dataToEndpoint_TKEEP(m_axis_net_tx_to_endpoint.keep),
   .m_axis_dataToEndpoint_TLAST(m_axis_net_tx_to_endpoint.last),
   .m_axis_dataToEndpoint_TVALID(m_axis_net_tx_to_endpoint.valid),
   .m_axis_dataToEndpoint_TREADY(m_axis_net_tx_to_endpoint.ready),

   .m_axis_close_connection_V_V_TVALID(m_axis_close_connection.valid),      // output wire m_axis_close_connection_TVALID
   .m_axis_close_connection_V_V_TREADY(m_axis_close_connection.ready),      // input wire m_axis_close_connection_TREADY
   .m_axis_close_connection_V_V_TDATA(m_axis_close_connection.data),        // output wire [15 : 0] m_axis_close_connection_TDATA

   .m_axis_listen_port_V_V_TVALID(m_axis_listen_port.valid),                // output wire m_axis_listen_port_TVALID
   .m_axis_listen_port_V_V_TREADY(m_axis_listen_port.ready),                // input wire m_axis_listen_port_TREADY
   .m_axis_listen_port_V_V_TDATA(m_axis_listen_port.data),                  // output wire [15 : 0] m_axis_listen_port_TDATA
   .s_axis_listen_port_status_V_TVALID(s_axis_listen_port_status.valid),  // input wire s_axis_listen_port_status_TVALID
   .s_axis_listen_port_status_V_TREADY(s_axis_listen_port_status.ready),  // output wire s_axis_listen_port_status_TREADY
   .s_axis_listen_port_status_V_TDATA(s_axis_listen_port_status.data),    // input wire [7 : 0] s_axis_listen_port_status_TDATA

   .m_axis_open_connection_V_TVALID(m_axis_open_connection.valid),        // output wire m_axis_open_connection_TVALID
   .m_axis_open_connection_V_TREADY(m_axis_open_connection.ready),        // input wire m_axis_open_connection_TREADY
   .m_axis_open_connection_V_TDATA(m_axis_open_connection.data),          // output wire [47 : 0] m_axis_open_connection_TDATA
   .s_axis_open_status_V_TVALID(s_axis_open_status.valid),                // input wire s_axis_open_status_TVALID
   .s_axis_open_status_V_TREADY(s_axis_open_status.ready),                // output wire s_axis_open_status_TREADY
   .s_axis_open_status_V_TDATA(s_axis_open_status.data),                  // input wire [23 : 0] s_axis_open_status_TDATA

   // 1. recv notifiaction, new data is available
   // 2. send read_package request
   // 3. wait for meta and data to arrive
   .s_axis_notifications_V_TVALID(s_axis_notifications.valid),            // input wire s_axis_notifications_TVALID
   .s_axis_notifications_V_TREADY(s_axis_notifications.ready),            // output wire s_axis_notifications_TREADY
   .s_axis_notifications_V_TDATA(s_axis_notifications.data),              // input wire [87 : 0] s_axis_notifications_TDATA

   .m_axis_read_package_V_TVALID(m_axis_read_package.valid),              // output wire m_axis_read_package_TVALID
   .m_axis_read_package_V_TREADY(m_axis_read_package.ready),              // input wire m_axis_read_package_TREADY
   .m_axis_read_package_V_TDATA(m_axis_read_package.data),                // output wire [31 : 0] m_axis_read_package_TDATA
   .s_axis_rx_data_TVALID(s_axis_rx_data.valid),                        // input wire s_axis_rx_data_TVALID
   .s_axis_rx_data_TREADY(s_axis_rx_data.ready),                        // output wire s_axis_rx_data_TREADY
   .s_axis_rx_data_TDATA(s_axis_rx_data.data),                          // input wire [63 : 0] s_axis_rx_data_TDATA
   .s_axis_rx_data_TKEEP(s_axis_rx_data.keep),                          // input wire [7 : 0] s_axis_rx_data_TKEEP
   .s_axis_rx_data_TLAST(s_axis_rx_data.last),                          // input wire [0 : 0] s_axis_rx_data_TLAST
   .s_axis_rx_metadata_V_V_TVALID(s_axis_rx_metadata.valid),                // input wire s_axis_rx_metadata_TVALID
   .s_axis_rx_metadata_V_V_TREADY(s_axis_rx_metadata.ready),                // output wire s_axis_rx_metadata_TREADY
   .s_axis_rx_metadata_V_V_TDATA(s_axis_rx_metadata.data),                  // input wire [15 : 0] s_axis_rx_metadata_TDATA

   // Send tx_metadata first asking whether we can send data
   // then wait for tx_status reply
   // finally send data via tx_data
   .m_axis_tx_metadata_V_TVALID(m_axis_tx_metadata.valid),                // output wire m_axis_tx_metadata_TVALID
   .m_axis_tx_metadata_V_TREADY(m_axis_tx_metadata.ready),                // input wire m_axis_tx_metadata_TREADY
   .m_axis_tx_metadata_V_TDATA(m_axis_tx_metadata.data),                  // output wire [15 : 0] m_axis_tx_metadata_TDATA
   .s_axis_tx_status_V_TVALID(s_axis_tx_status.valid),                    // input wire s_axis_tx_status_TVALID
   .s_axis_tx_status_V_TREADY(s_axis_tx_status.ready),                    // output wire s_axis_tx_status_TREADY
   .s_axis_tx_status_V_TDATA(s_axis_tx_status.data),                      // input wire [23 : 0] s_axis_tx_status_TDATA
   .m_axis_tx_data_TVALID(m_axis_tx_data.valid),                        // output wire m_axis_tx_data_TVALID
   .m_axis_tx_data_TREADY(m_axis_tx_data.ready),                        // input wire m_axis_tx_data_TREADY
   .m_axis_tx_data_TDATA(m_axis_tx_data.data),                          // output wire [63 : 0] m_axis_tx_data_TDATA
   .m_axis_tx_data_TKEEP(m_axis_tx_data.keep),                          // output wire [7 : 0] m_axis_tx_data_TKEEP
   .m_axis_tx_data_TLAST(m_axis_tx_data.last)                          // output wire [0 : 0] m_axis_tx_data_TLAST
);

endmodule
`default_nettype wire
