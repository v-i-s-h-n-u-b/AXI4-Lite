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
* The AXI Master need not wait for a transaction to be completed before it can initiate another one, which boosts performance.

For more information on the AXI4-Lite signals and the protocol itself refer to the following links:
* https://www.realdigital.org/doc/a9fee931f7a172423e1ba73f66ca4081
* https://developer.arm.com/documentation/dui0534/b/Parameter-Descriptions/Interface/AXI4-and-AXI4-Lite-interfaces
