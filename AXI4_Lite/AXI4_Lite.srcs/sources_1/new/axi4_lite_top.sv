`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2024 03:29:36
// Design Name: 
// Module Name: axi4_lite_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2024
// Design Name: 
// Module Name: axi4_lite_master_slave_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top module integrating AXI4-Lite Master and Slave
// 
// Dependencies: axi4_lite_master, axi4_lite_slave
// 
//////////////////////////////////////////////////////////////////////////////////

module axi4_lite_master_slave_top #(parameter ADDRESS = 32, parameter DATA_WIDTH = 32)(
    input logic ACLK,      
    input logic ARESETN    
);

    // Master to Slave signals
    logic [ADDRESS-1:0] M_ARADDR;   // Master Read Address
    logic [ADDRESS-1:0] M_AWADDR;   // Master Write Address
    logic [DATA_WIDTH-1:0] M_WDATA; // Master Write Data
    logic [3:0] M_WSTRB;            // Master Write Strobe
    logic M_ARVALID, M_AWVALID, M_WVALID, M_RREADY, M_BREADY;
    
    // Slave outputs
    logic [DATA_WIDTH-1:0] S_RDATA; // Slave Read Data
    logic [1:0] S_RRESP, S_BRESP;   // Slave Response signals
    logic S_ARREADY, S_AWREADY, S_WREADY, S_RVALID, S_BVALID;

    //AXI4-Lite Master
    axi4_lite_master #(
        .ADDRESS(ADDRESS),
        .DATA_WIDTH(DATA_WIDTH)
    ) axi_master_inst (
        .ACLK(ACLK),
        .ARESETN(ARESETN),

        // Master Read Address Channel
        .M_ARADDR(M_ARADDR),
        .M_ARVALID(M_ARVALID),
        .M_ARREADY(S_ARREADY),
        
        // Master Read Data Channel
        .M_RDATA(S_RDATA),
        .M_RRESP(S_RRESP),
        .M_RREADY(M_RREADY),
        .M_RVALID(S_RVALID),
        
        // Master Write Address Channel
        .M_AWADDR(M_AWADDR),
        .M_AWVALID(M_AWVALID),
        .M_AWREADY(S_AWREADY),
        
        // Master Write Data Channel
        .M_WDATA(M_WDATA),
        .M_WSTRB(M_WSTRB),
        .M_WVALID(M_WVALID),
        .M_WREADY(S_WREADY),
        
        // Master Write Response Channel
        .M_BRESP(S_BRESP),
        .M_BVALID(S_BVALID),
        .M_BREADY(M_BREADY)
    );

    // AXI4-Lite Slave
    axi4_lite_slave #(
        .ADDRESS(ADDRESS),
        .DATA_WIDTH(DATA_WIDTH)
    ) axi_slave_inst (
        .ACLK(ACLK),
        .ARESETN(ARESETN),

        // Slave Read Address Channel
        .S_ARADDR(M_ARADDR),
        .S_ARVALID(M_ARVALID),
        .S_ARREADY(S_ARREADY),

        // Slave Read Data Channel
        .S_RDATA(S_RDATA),
        .S_RRESP(S_RRESP),
        .S_RVALID(S_RVALID),
        .S_RREADY(M_RREADY),
        
        // Slave Write Address Channel
        .S_AWADDR(M_AWADDR),
        .S_AWVALID(M_AWVALID),
        .S_AWREADY(S_AWREADY),

        // Slave Write Data Channel
        .S_WDATA(M_WDATA),
        .S_WSTRB(M_WSTRB),
        .S_WVALID(M_WVALID),
        .S_WREADY(S_WREADY),

        // Slave Write Response Channel
        .S_BRESP(S_BRESP),
        .S_BVALID(S_BVALID),
        .S_BREADY(M_BREADY)
    );

endmodule


