# NOTE BY YIZHOU

It only works with Vivado HLS 2019.1. Otherwise the generated signal names mismatch.

Run this script
```bash
mkdir build
cd build
../run.sh                          # generate Makefile etc
make installip                     # build tcp and snic_handle HLS IPs
make project_standalone_tcp        # build the combined vivado IP
```

- To open Vivado GUI, run `make g` inside `build/`.
- To open Vivado HLS GUI, go to `build/fpga-network-stack/hls/`.

```
write_bd_tcl  -force -bd_name snic_tcp_top_final ../scripts/create_bd.tcl
set_property -dict [list CONFIG.FREQ_HZ {250000000}] [get_bd_pins snic_tcp_top_0/mem_clk]
set_property -dict [list CONFIG.FREQ_HZ {250000000}] [get_bd_ports mem_clk_0]
```

## About Vivado project

The top HDL code is in `hdl/standalone_tcp`, which was a copy from `hdl/common`.
The top file is `hdl/standalone_tcp/os.sv`, in which the top module is `snic_tcp_top`.
This module connects both `snic_handler` and `tcp`.


## About fpga-network-systems

So the original `ip_handler`, which sits right before tcp module,
will rip off the ethernet headers, and look at ip opcode,
then distribute packets to icmp, udp, or tcp.

So the TCP module will get packets with `<IP, TCP>` headers.

TCP modules also sends out packets with `<IP, TCP>` headers, too.
Those packets will then go into `mac_ip_encode`, which will look
up ARP and attach ethernet headers in the beginning.


In all, the `tcp_stack`, or `toe`, deal with packets with `<IP, TCP>` headers.

The next question is how much we can leave it blank there.




# DavOS (Distributed Accelerator OS)

### Prerequisites
- Xilinx Vivado 2019.1
- cmake 3.0 or higher
- Linux OS
- Xilinx licenses for board/chip and Ethernet cores

Supported boards (out of the box)
- Xilinx VC709
- Xilinx VCU118
- Alpha Data ADM-PCIE-7V3


## Build project

1. Initialize submodules
```
$ git clone git@github.com:fpgasystems/davos.git
$ git submodule update --init --recursive
```

2. Create build directory
```
$ mkdir build
$ cd build
```

3. Configure build
```
$ cmake .. -DDEVICE_NAME=vcu118 -DTCP_STACK_EN=1 -DVIVADO_ROOT_DIR=/opt/Xilinx/Vivado/2019.1/bin -DVIVADO_HLS_ROOT_DIR=/opt/Xilinx/Vivado/2019.1/bin

```
All options:

| Name                  | Values                | Desription                                                              |
| --------------------- | --------------------- | ----------------------------------------------------------------------- |
| DEVICE_NAME           | <vc709,vcu118,adm7v3> | Supported devices                                                       |
| NETWORK_BANDWIDTH     | <10,100>              | Bandwidth of the Ethernet interface in Gbit/s, default depends on board |
| ROLE_NAME             | <name>                | Name of the role, default:. benchmark_role                              |
| ROLE_CLK              | <net,pcie>            | Main clock used for the role, default: net                              |
| TCP_STACK_EN          | <0,1>                 | default: 0                                                              |
| UDP_STACK_EN          | <0,1>                 | default: 0                                                              |
| ROCE_STACK_EN         | <0,1>                 | default: 0                                                              |
| VIVADO_ROOT_DIR       | <path>                | Path to Vivado HLS directory, e.g. /opt/Xilinx/Vivado/2019.1            |
| VIVADO_HLS_ROOT_DIR   | <path>                | Path to Vivado HLS directory, e.g. /opt/Xilinx/Vivado/2019.1            |


4. Build HLS IP cores and install them into IP repository
```
$ make installip
```

5. Create vivado project
```
$ make project
```

6. Run synthesis
```
$ make synthesize
```

7. Run implementation
```
$ make implementation
```

8. Generate bitstream
```
$ make bitstream
```



## Handling HLS IP cores

1. Setup build directory, e.g. for the dma_bench module

```
$ cd hls/dma_bench
$ mkdir build
$ cd build
$ cmake .. -DFPGA_PART=xcvu9p-flga2104-2L-e -DCLOCK_PERIOD=3.2
```

2. Run c-simulation
```
$ make csim
```

3. Run c-synthesis
```
$ make synthesis
```

4. Generate HLS IP core
```
$ make ip
```

5. Instal HLS IP core in ip repository
```
$ make installip
```
