`timescale 1ps/1ps

module test_snic_tcp_top;

parameter CLK_PERIOD = 4000;
parameter AXIS_ETH_DATA_WIDTH = 512;
parameter AXIS_ETH_KEEP_WIDTH = AXIS_ETH_DATA_WIDTH/8;

reg clk_250mhz;
reg clk_250mhz_rst;

wire [31:0]m_axi_araddr;
wire [1:0]m_axi_arburst;
wire [3:0]m_axi_arcache;
wire [0:0]m_axi_arid;
wire [7:0]m_axi_arlen;
wire [0:0]m_axi_arlock;
wire [2:0]m_axi_arprot;
reg [0:0]m_axi_arready;
wire [2:0]m_axi_arsize;
wire [0:0]m_axi_arvalid;
wire [31:0]m_axi_awaddr;
wire [1:0]m_axi_awburst;
wire [3:0]m_axi_awcache;
wire [0:0]m_axi_awid;
wire [7:0]m_axi_awlen;
wire [0:0]m_axi_awlock;
wire [2:0]m_axi_awprot;
wire [0:0]m_axi_awready;
wire [2:0]m_axi_awsize;
wire [0:0]m_axi_awvalid;
wire [0:0]m_axi_bid;
wire [0:0]m_axi_bready;
wire [1:0]m_axi_bresp;
wire [0:0]m_axi_bvalid;
wire [511:0]m_axi_rdata;
wire [0:0]m_axi_rid;
wire [0:0]m_axi_rlast;
wire [0:0]m_axi_rready;
wire [1:0]m_axi_rresp;
wire [0:0]m_axi_rvalid;
wire [511:0]m_axi_wdata;
wire [0:0]m_axi_wlast;
wire [0:0]m_axi_wready;
wire [63:0]m_axi_wstrb;
wire [0:0]m_axi_wvalid;

wire [511:0]m_axis_net_tx_data;
wire m_axis_net_tx_dest;
wire [63:0]m_axis_net_tx_keep;
wire m_axis_net_tx_last;
reg m_axis_net_tx_ready;
wire m_axis_net_tx_valid;

wire [511:0]m_axis_net_tx_to_endpoint_data;
wire m_axis_net_tx_to_endpoint_dest;
wire [63:0]m_axis_net_tx_to_endpoint_keep;
wire m_axis_net_tx_to_endpoint_last;
reg m_axis_net_tx_to_endpoint_ready;
wire m_axis_net_tx_to_endpoint_valid;

reg [511:0]s_axis_net_rx_from_endpoint_data;
reg [63:0]s_axis_net_rx_from_endpoint_keep;
reg s_axis_net_rx_from_endpoint_last;
wire s_axis_net_rx_from_endpoint_ready;
reg s_axis_net_rx_from_endpoint_valid;

reg [63:0]s_axis_net_rx_keep;
reg [511:0]s_axis_net_rx_data;
reg s_axis_net_rx_last;
wire s_axis_net_rx_ready;
reg s_axis_net_rx_valid;

snic_tcp_top_final DUT (
    .mem_clk_0(clk_250mhz),
    .net_clk_0(clk_250mhz),
    .mem_aresetn_0(~clk_250mhz_rst),
    .net_aresetn_0(~clk_250mhz_rst),

    .m_axi_0_araddr(m_axi_araddr),
    .m_axi_0_arburst(m_axi_arburst),
    .m_axi_0_arcache(m_axi_arcache),
    .m_axi_0_arid(m_axi_arid),
    .m_axi_0_arlen(m_axi_arlen),
    .m_axi_0_arlock(m_axi_arlock),
    .m_axi_0_arprot(m_axi_arprot),
    .m_axi_0_arready(m_axi_arready),
    .m_axi_0_arsize(m_axi_arsize),
    .m_axi_0_arvalid(m_axi_arvalid),
    .m_axi_0_awaddr(m_axi_awaddr),
    .m_axi_0_awburst(m_axi_awburst),
    .m_axi_0_awcache(m_axi_awcache),
    .m_axi_0_awid(m_axi_awid),
    .m_axi_0_awlen(m_axi_awlen),
    .m_axi_0_awlock(m_axi_awlock),
    .m_axi_0_awprot(m_axi_awprot),
    .m_axi_0_awready(m_axi_awready),
    .m_axi_0_awsize(m_axi_awsize),
    .m_axi_0_awvalid(m_axi_awvalid),
    .m_axi_0_bid(m_axi_bid),
    .m_axi_0_bready(m_axi_bready),
    .m_axi_0_bresp(m_axi_bresp),
    .m_axi_0_bvalid(m_axi_bvalid),
    .m_axi_0_rdata(m_axi_rdata),
    .m_axi_0_rid(m_axi_rid),
    .m_axi_0_rlast(m_axi_rlast),
    .m_axi_0_rready(m_axi_rready),
    .m_axi_0_rresp(m_axi_rresp),
    .m_axi_0_rvalid(m_axi_rvalid),
    .m_axi_0_wdata(m_axi_wdata),
    .m_axi_0_wlast(m_axi_wlast),
    .m_axi_0_wready(m_axi_wready),
    .m_axi_0_wstrb(m_axi_wstrb),
    .m_axi_0_wvalid(m_axi_wvalid),

    .m_axis_tx_tcp_0_tdata(m_axis_net_tx_data),
    .m_axis_tx_tcp_0_tdest(m_axis_net_tx_dest),
    .m_axis_tx_tcp_0_tkeep(m_axis_net_tx_keep),
    .m_axis_tx_tcp_0_tlast(m_axis_net_tx_last),
    .m_axis_tx_tcp_0_tready(m_axis_net_tx_ready),
    .m_axis_tx_tcp_0_tvalid(m_axis_net_tx_valid),

    .s_axis_rx_tcp_0_tdata(s_axis_net_rx_data),
    .s_axis_rx_tcp_0_tkeep(s_axis_net_rx_keep),
    .s_axis_rx_tcp_0_tlast(s_axis_net_rx_last),
    .s_axis_rx_tcp_0_tready(s_axis_net_rx_ready),
    .s_axis_rx_tcp_0_tvalid(s_axis_net_rx_valid),

    .m_axis_net_tx_to_endpoint_0_tdata(m_axis_net_tx_to_endpoint_data),
    .m_axis_net_tx_to_endpoint_0_tdest(m_axis_net_tx_to_endpoint_dest),
    .m_axis_net_tx_to_endpoint_0_tkeep(m_axis_net_tx_to_endpoint_keep),
    .m_axis_net_tx_to_endpoint_0_tlast(m_axis_net_tx_to_endpoint_last),
    .m_axis_net_tx_to_endpoint_0_tready(m_axis_net_tx_to_endpoint_ready),
    .m_axis_net_tx_to_endpoint_0_tvalid(m_axis_net_tx_to_endpoint_valid),
    .m_axis_net_tx_to_endpoint_0_tuser(),

    .s_axis_net_rx_from_endpoint_0_tdata(s_axis_net_rx_from_endpoint_data),
    .s_axis_net_rx_from_endpoint_0_tkeep(s_axis_net_rx_from_endpoint_keep),
    .s_axis_net_rx_from_endpoint_0_tlast(s_axis_net_rx_from_endpoint_last),
    .s_axis_net_rx_from_endpoint_0_tready(s_axis_net_rx_from_endpoint_ready),
    .s_axis_net_rx_from_endpoint_0_tvalid(s_axis_net_rx_from_endpoint_valid),
    .s_axis_net_rx_from_endpoint_0_tuser()
);

reg [63:0] send_start, send_end, receive_start, receive_end;
reg [63:0] nr_requests_send, nr_requests_received, nr_rx_units;
reg enable_send;

integer infd, outfd, nr_flits, finished_send, stop_simulation;

reg [63:0] this_packet_start, this_packet_end;

parameter IN_FILEPATH="/home/ys/Github/SuperNIC/fpga/spinalhdl/generated_pkts/snic_tcp_input_packets.txt";
parameter OUT_FILEPATH="/home/ys/Github/SuperNIC/fpga/third_party/davos/build/output.txt";

initial begin
    clk_250mhz = 0;
    clk_250mhz_rst = 0;
    enable_send = 0;
    
    #100000;

    // Send reset signal
    @(posedge clk_250mhz);
    clk_250mhz_rst = 1;
    #100000;
    @(posedge clk_250mhz);
    clk_250mhz_rst = 0;

    #100000
    enable_send = 1;
end

always
    #(CLK_PERIOD/2) clk_250mhz = ~clk_250mhz;

initial begin

  finished_send = 0;
  nr_flits = 1;
  nr_requests_send = 0;
  nr_requests_received = 0;

  s_axis_net_rx_data = 0;
  s_axis_net_rx_valid = 0;
  s_axis_net_rx_from_endpoint_data = 0;
  s_axis_net_rx_from_endpoint_valid = 0;

  infd = $fopen(IN_FILEPATH,"r");
  $display("Input file fd %d", infd);
  if (infd == 0) begin
    $display("ERROR, input file not found\n");
    $display("Please run sbt \"runMain apps.VerilogSimPktGen\"");
    $finish;
  end

  /*
   * Wait until sending is enabled
   */
  wait(enable_send == 1'b1);
  @(posedge clk_250mhz);

  send_start = $time;
  $display("INFO: %t: Start sending packets.", send_start);

  while (!finished_send) begin
    /*
     * Read how many flits this packet has
     */
    $fscanf(infd, "%d\n", nr_flits);
    if (nr_flits == 0) begin
      wait(nr_requests_send == nr_requests_received);
    end else begin
      nr_requests_send = nr_requests_send + 1;
      this_packet_start = $time;
      $display("Send packet [%d] nr_flits=%d %d", nr_requests_send, nr_flits, $time);
    end

    /*
     * Read following flits of this packet
     */
    while (nr_flits != 0) begin
      $fscanf(infd, "%h\n", s_axis_net_rx_from_endpoint_data);
      s_axis_net_rx_from_endpoint_keep = 64'h0xffffffffffffffff;
      nr_flits = nr_flits - 1;

      if (nr_flits == 0) begin
        s_axis_net_rx_from_endpoint_last = 1;
      end else begin
        s_axis_net_rx_from_endpoint_last = 0;
      end
      s_axis_net_rx_from_endpoint_valid = 1;

      /*
       * Check if we have finished testing
       */
      if ($feof(infd)) begin
        finished_send = 1;
        send_end = $time;
        $display("INFO: %t: Finish sending packets.", send_end);
      end

      if (!finished_send && (nr_flits != 0)) begin
         # CLK_PERIOD;
      end
    end

    # CLK_PERIOD;
    s_axis_net_rx_from_endpoint_valid = 0;

  end
end

initial begin

  outfd = $fopen(OUT_FILEPATH, "w");
  $display("Output file fd %d", outfd);
  $display("Output file path: %s", OUT_FILEPATH);
  $fdisplay(outfd, "#Packets sent out by TCP module:");

  m_axis_net_tx_to_endpoint_ready = 1;
  m_axis_net_tx_ready = 1;

  // TODO
  // Save tha packet to a file
  // and then i can inspect the content, then hook with us.
  while (1) begin
      # CLK_PERIOD;
      
      if (m_axis_net_tx_valid == 1 && m_axis_net_tx_ready == 1) begin
        $display("INFO: %t: TCP module sends out packet: %d %x %h",
            $time, m_axis_net_tx_last, m_axis_net_tx_keep, m_axis_net_tx_data);
        
        $fdisplay(outfd, "%d %x %h", m_axis_net_tx_last, m_axis_net_tx_keep, m_axis_net_tx_data);
      end
      
      if (m_axis_net_tx_to_endpoint_valid == 1 && m_axis_net_tx_to_endpoint_ready == 1) begin
        $display("INFO: %t: handler module sends out packet to endhost.", $time);
      end
  end
end

initial begin
    stop_simulation = 0;
    # 10000000;
    stop_simulation = 1;
    
    $fclose(outfd);
    $fclose(infd);
    $display("Time is up, stop simulation.");
    $finish;
end


endmodule
