##  A custom AXI4-Lite Slave interface utilizing a MicroBlaze soft processor with a configured AXI Interconnect to enable memory-mapped communication for 32-bit operations.

The AXI4-Lite protocol is a simplified subset of the AXI4 (Advanced eXtensible Interface) protocol, part of the AMBA (Advanced Microcontroller Bus Architecture) specification by ARM. AXI4-Lite is designed for low-complexity, low-bandwidth memory-mapped communications, and low-latency interconnects making it ideal for control and configuration registers in hardware IP blocks. It consists of 5 channels, 2 for Reading and 3 for Writing namely:
* READING:
  - Read Data Channel
  - Read Address Channel
* WRITING:
  - Write Data Channel
  - Write Address Channel
  - Write Response Channel 

Handshake on all 5 channels happens using VALID/READY signals. The process completes only if both VALID/READY signals are asserted during a rising clock edge. Some key aspects of AXI4-Lite are as stated below:
* In the Read Operation, a separate Response Channel is not required because both the data and the response status are sent together from the slave to the master within the same read channel.
* Handshake on Write Address Channel and Data Channels need not co-occur but they must occur before the Slave can send the Write Response.
* The AXI Master need not wait for a transaction to be completed before it can initiate another one (Pipelined Transfers), which boosts performance.

For more information on the AXI4-Lite signals and the protocol itself refer to the following links:
* https://www.realdigital.org/doc/a9fee931f7a172423e1ba73f66ca4081
* https://developer.arm.com/documentation/dui0534/b/Parameter-Descriptions/Interface/AXI4-and-AXI4-Lite-interfaces

### Microblaze processor

It is a highly configurable 32-bit RISC softcore processor that follows the Harvard Architecture for data and instructions. It supports AXI, AXI4 Lite and PLB for communication with peripherals. It also comes equipped with its own interrupt controller and memory management modules.

The AXI interfaces are:
* M_AXI_DP (Data Port AXI Interface) which handles data memory access from Microblaze (For reading/writing data to external memory/peripherals).
* M_ACI_IP (Instruction Port AXI Interface) which handles instruction memory (Fetches instructions for execution from external memory/cache).
* LMB (Local Memory Bus) is a high-speed interface used by Microblaze to access on-chip Block RAM (BRAM) for fast and deterministic memory access.
  - DLMB (Data LMB) which provides access to data stored in BRAM (reading/writing data stored in BRAM).
  - ILMB (Instruction LMB) which fetches instructions stored in BRAM for execution by Microblaze.
 
### AXI Interconnect

It facilitates the communication between multiple masters and slaves in an FPGA design. It logically routes transactions in any design.

In the above block diagram/IP design, Microblaze acts as the AXI Master generating read and write transactions and the AXI Interconnect routes these transactions to peripherals. (Microblaze sends memory accesses via AXI Master port, AXI Interconnect decodes addresses and routes the requests to appropriate slaves).
