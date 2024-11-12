`timescale 1ns / 1ps

module tb_axi4_lite_slave;
    logic ACLK;
    logic ARESETN;

    // AXI4-Lite Slave Interface Signals
    logic [31:0] S_ARADDR;
    logic S_ARVALID;
    logic S_ARREADY;
    logic [31:0] S_RDATA;
    logic [1:0] S_RRESP;
    logic S_RVALID;
    logic S_RREADY;
    
    logic [31:0] S_AWADDR;
    logic S_AWVALID;
    logic S_AWREADY;
    
    logic [31:0] S_WDATA;
    logic [3:0] S_WSTRB;
    logic S_WVALID;
    logic S_WREADY;
    
    logic [1:0] S_BRESP;
    logic S_BVALID;
    logic S_BREADY;

    // Instantiate DUT (Design Under Test)
    axi4_lite_slave_top uut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_ARADDR(S_ARADDR),
        .S_ARVALID(S_ARVALID),
        .S_ARREADY(S_ARREADY),
        .S_RDATA(S_RDATA),
        .S_RRESP(S_RRESP),
        .S_RVALID(S_RVALID),
        .S_RREADY(S_RREADY),
        .S_AWADDR(S_AWADDR),
        .S_AWVALID(S_AWVALID),
        .S_AWREADY(S_AWREADY),
        .S_WDATA(S_WDATA),
        .S_WSTRB(S_WSTRB),
        .S_WVALID(S_WVALID),
        .S_WREADY(S_WREADY),
        .S_BRESP(S_BRESP),
        .S_BVALID(S_BVALID),
        .S_BREADY(S_BREADY)
    );

    // Clock generation: 10ns clock period (100MHz)
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK;  
    end

    // Reset generation
    initial begin
        ARESETN = 0;
        #20;
        ARESETN = 1;  
    end
    
    initial begin
        // Initializing signals
        S_ARADDR = 32'h0;
        S_ARVALID = 0;
        S_RREADY = 0;
        S_AWADDR = 32'h0;
        S_AWVALID = 0;
        S_WDATA = 32'h0;
        S_WVALID = 0;
        S_WSTRB = 4'b1111;  // Full word write enable
        S_BREADY = 0;

        // Waiting for reset deassertion
        wait(ARESETN == 1);

        // AXI Write transaction
        #20;
        write_axi(32'h00000004, 32'hDEADBEEF);  // Write data to address 0x00000004

        // AXI Read transaction
        #20;
        read_axi(32'h00000004);  // Read data from address 0x00000004

        #100;
        $finish;
    end

    // AXI Write Task
    task write_axi(input [31:0] addr, input [31:0] data);
        begin
            // Write Address Phase
            @(posedge ACLK);
            S_AWADDR = addr;
            S_AWVALID = 1;
            @(posedge ACLK);
            while (!S_AWREADY) @(posedge ACLK);  // Wait for AWREADY
            S_AWVALID = 0;

            // Write Data Phase
            @(posedge ACLK);
            S_WDATA = data;
            S_WVALID = 1;
            @(posedge ACLK);
            while (!S_WREADY) @(posedge ACLK);  // Wait for WREADY
            S_WVALID = 0;

            // Write Response Phase
            @(posedge ACLK);
            S_BREADY = 1;
            @(posedge ACLK);
            while (!S_BVALID) @(posedge ACLK);  // Wait for BVALID
            S_BREADY = 0;
        end
    endtask

    // AXI Read Task
    task read_axi(input [31:0] addr);
        begin
            // Read Address Phase
            @(posedge ACLK);
            S_ARADDR = addr;
            S_ARVALID = 1;
            @(posedge ACLK);
            while (!S_ARREADY) @(posedge ACLK);  // Wait for ARREADY
            S_ARVALID = 0;

            // Read Data Phase
            @(posedge ACLK);
            S_RREADY = 1;
            @(posedge ACLK);
            while (!S_RVALID) @(posedge ACLK);  // Wait for RVALID
            $display("Read data from address %h: %h ", addr, S_RDATA);
            S_RREADY = 0;
        end
    endtask

endmodule
