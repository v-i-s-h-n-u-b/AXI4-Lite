`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2024 03:28:46
// Design Name: 
// Module Name: axi4_lite_slave
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2024 03:00:07
// Design Name: 
// Module Name: axi4_lite_slave_top
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


module axi4_lite_slave #(parameter ADDRESS = 32, parameter DATA_WIDTH = 32)(
    // Global Signals
    input ACLK,
    input ARESETN,

    // Read Address Channel Inputs
    input [ADDRESS-1:0] S_ARADDR,
    input S_ARVALID,

    // Read Data Channel Inputs
    input S_RREADY,
 
    // Write Address Channel Inputs
    input [ADDRESS-1:0] S_AWADDR,
    input S_AWVALID,

    // Write Data Channel Inputs
    input [DATA_WIDTH-1:0] S_WDATA,
    input [3:0] S_WSTRB,
    input S_WVALID,
  
    // Write Response Channel Inputs
    input S_BREADY,
    
    //Read Address Channel Outputs
    output logic S_ARREADY,
    
    //Read Data Channel Outputs
    output logic [DATA_WIDTH-1:0] S_RDATA,
    output logic [1:0] S_RRESP,
    output logic S_RVALID,
    
    //Write Address Channel Outputs
    output logic S_AWREADY,
    
    //Write Data Channel Outputs
    output logic S_WREADY,

    //Write Response Channel Outputs
    output logic [1:0] S_BRESP,
    output logic S_BVALID
);

    // Register definition
    localparam no_of_registers = 32;
    logic [DATA_WIDTH-1:0] register [no_of_registers-1:0];
    logic [ADDRESS-1:0] addr;

    // AXI Write and Read Handshake Signals
    logic write_addr_handshake = S_AWVALID && S_AWREADY;
    logic write_data_handshake = S_WVALID && S_WREADY;
    logic read_addr_handshake = S_ARVALID && S_ARREADY;

    typedef enum logic [2:0] {
        IDLE, WRITE_ADDR_CHANNEL, WRITE_DATA_CHANNEL, WRESP_CHANNEL, RADDR_CHANNEL, RDATA_CHANNEL
    } state_type;

    state_type state, next_state;

    // Address alignment logic
    logic [ADDRESS-1:2] aligned_awaddr = S_AWADDR[ADDRESS-1:2];
    logic [ADDRESS-1:2] aligned_araddr = S_ARADDR[ADDRESS-1:2];

    // AXI4-Lite Slave State Machine
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            state <= IDLE;
            S_ARREADY <= 1'b0;
            S_AWREADY <= 1'b0;
            S_WREADY <= 1'b0;
            S_RVALID <= 1'b0;
            S_BVALID <= 1'b0;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                S_ARREADY = 1'b0;
                S_AWREADY = 1'b0;
                S_WREADY = 1'b0;
                S_RVALID = 1'b0;
                S_BVALID = 1'b0;
                if (S_AWVALID) begin
                    next_state = WRITE_ADDR_CHANNEL;
                end else if (S_ARVALID) begin
                    next_state = RADDR_CHANNEL;
                end
            end

            WRITE_ADDR_CHANNEL: begin
                S_AWREADY = 1'b1;
                if (write_addr_handshake) begin
                    next_state = WRITE_DATA_CHANNEL;
                end
            end

            WRITE_DATA_CHANNEL: begin
                S_AWREADY = 1'b0;
                S_WREADY = 1'b1;
                if (write_data_handshake) begin
                    next_state = WRESP_CHANNEL;
                end
            end

            WRESP_CHANNEL: begin
                S_WREADY = 1'b0;
                S_BVALID = 1'b1;
                if (S_BVALID && S_BREADY) begin
                    next_state = IDLE;
                end
            end

            RADDR_CHANNEL: begin
                S_ARREADY = 1'b1;
                if (read_addr_handshake) begin
                    next_state = RDATA_CHANNEL;
                end
            end

            RDATA_CHANNEL: begin
                S_ARREADY = 1'b0;
                S_RVALID = 1'b1;
                if (S_RVALID && S_RREADY) begin
                    next_state = IDLE;
                end
            end

            default: next_state = IDLE;
        endcase
    end

    // Write data to register
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            for (int i = 0; i < no_of_registers; i++) begin
                register[i] <= 32'b0;
            end
        end else if (write_addr_handshake && write_data_handshake) begin
            register[aligned_awaddr] <= S_WDATA;
        end
    end

    // Read data from register
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_RDATA <= 32'b0;
        end else if (read_addr_handshake) begin
            S_RDATA <= register[aligned_araddr];
        end
    end
endmodule