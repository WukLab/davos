cmake .. -DDEVICE_NAME=vcu118 -DTCP_STACK_EN=1 -DVIVADO_ROOT_DIR=/tools/Xilinx/Vivado/2019.1/bin -DVIVADO_HLS_ROOT_DIR=/tools/Xilinx/Vivado/2019.1/bin

rm dump_verilog.packet.o
ln -s ../../../../host/example/dump_verilog_packet.o dump_verilog.packet.o
