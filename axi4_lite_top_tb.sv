`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2024 04:26:46
// Design Name: 
// Module Name: axi4_lite_top_tb
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

module axi4_lite_master_slave_tb;
    parameter ADDRESS = 32;
    parameter DATA_WIDTH = 32;

    logic ACLK;
    logic ARESETN;

    // Instantiate the DUT
    axi4_lite_master_slave_top #(
        .ADDRESS(ADDRESS),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN)
    );

    // Clock generation
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK; // 10 ns clock period (100 MHz)
    end

    // Reset generation
    initial begin
        ARESETN = 0;
        #20 ARESETN = 1; 
    end
    
    logic [DATA_WIDTH-1:0] read_data;

    // Stimulus
    initial begin
        $display("Applying Reset");
        #25; // Wait for reset de-assertion
        
        // Writing
        $display("Starting write transaction");
        write_transaction(32'h00000010, 32'hABCD1234);
        #50; // Wait for some time after the write
        
        // Reading 
        $display("Starting read transaction");
        read_transaction(32'h00000010);
        #50; // Wait for some time after the read
        
        $display("Simulation complete.");
        $finish;
    end

    // Task for write transaction
    // Task for write transaction
// Task for write transaction
// Task for write transaction
task write_transaction(input logic [ADDRESS-1:0] addr, input logic [DATA_WIDTH-1:0] data);
begin
    // Prepare to write address, data, and strobe signals
    dut.axi_master_inst.M_AWADDR <= addr;
    dut.axi_master_inst.M_WDATA <= data;
    dut.axi_master_inst.M_WSTRB <= 4'b1111; 

    // Initialize valid signals
    dut.axi_master_inst.M_AWVALID <= 1'b1;
    dut.axi_master_inst.M_WVALID <= 1'b1;

    // Print current values
    $display("Attempting to write: Addr = %h, Data = %h", addr, data);
    
    // Wait for slave to be ready (with timeout)
    @(posedge ACLK); // Synchronize with clock
    wait (dut.axi_slave_inst.S_AWREADY); // Wait for slave to be ready
    $display("Slave ready for address write.");
    
    // De-assert AWVALID signal after acknowledging readiness
    @(posedge ACLK);
    dut.axi_master_inst.M_AWVALID <= 1'b0; // De-assert after addressing
    $display("Address write acknowledged.");

    // Now assert write valid signal and wait for write ready signal
    @(posedge ACLK); // Move to the next clock cycle
    dut.axi_master_inst.M_WVALID <= 1'b1; // Assert WVALID for write data
    
    // Wait for slave to be ready for write data
    wait (dut.axi_slave_inst.S_WREADY); // Wait for slave to be ready for write
    $display("Slave ready for data write.");
    
    // De-assert WVALID after data write
    @(posedge ACLK);
    dut.axi_master_inst.M_WVALID <= 1'b0; // De-assert WVALID after writing data

    // Wait for the write response
    @(posedge ACLK);
    wait (dut.axi_master_inst.M_BVALID); // Wait for the response
    $display("Write transaction complete: Addr = %h, Data = %h", addr, data);
    
    // Acknowledge the response from the slave
    @(posedge ACLK);
    dut.axi_master_inst.M_BREADY <= 1'b1; // Acknowledge the response
    $display("Write response acknowledged.");
end
endtask

    // Task for read transaction
    task read_transaction(input logic [ADDRESS-1:0] addr);
    begin
        // Prepare to read address signal
        dut.axi_master_inst.M_ARADDR <= addr;

        // Assert read valid signal
        dut.axi_master_inst.M_ARVALID <= 1'b1;

        // Wait for slave to be ready
        @(posedge ACLK);
        wait (dut.axi_slave_inst.S_ARREADY);

        // De-asserting read valid signal
        dut.axi_master_inst.M_ARVALID <= 1'b0;

        // Wait for read data
        @(posedge dut.axi_slave_inst.S_RVALID);

        // Reading the data
        read_data = dut.axi_slave_inst.S_RDATA;
        $display("Read transaction complete: Addr = %h, Data = %h", addr, read_data);
    end
    endtask

endmodule
