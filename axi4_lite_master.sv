`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2024 03:29:09
// Design Name: 
// Module Name: axi4_lite_master
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


module axi4_lite_master #(parameter ADDRESS = 32, parameter DATA_WIDTH = 32)(
    input ACLK,
    input ARESETN,

    // Read Address Channel Inputs
    input M_ARREADY,
    
    // Read Data Channel Inputs
    input [DATA_WIDTH-1:0] M_RDATA,
    input [1:0] M_RRESP,
    input M_RVALID,

    // Write Address Channel Inputs
    input M_AWREADY,

    // Write Data Channel Inputs
    input M_WREADY,

    // Write Response Channel Inputs
    input [1:0] M_BRESP,
    input M_BVALID,
    
    // Read Address Channel Outputs
    output logic [ADDRESS-1:0] M_ARADDR,
    output logic M_ARVALID,
    
    // Read Data Channel Outputs
     output logic M_RREADY,
     
    // Write Address Channel Outputs
    output logic [ADDRESS-1:0] M_AWADDR,
    output logic M_AWVALID,
    
    // Write Data Channel Outputs
    output logic [DATA_WIDTH-1:0] M_WDATA,
    output logic [3:0] M_WSTRB,
    output logic M_WVALID,
    
    // Write Response Channel Outputs
    output logic M_BREADY
);

    // Internal signals
    typedef enum logic [2:0] {IDLE, WRITE_ADDR, WRITE_DATA, READ_ADDR, READ_DATA} state_type;
    
    state_type state, next_state;
    
    logic [DATA_WIDTH-1:0] write_data;
    logic [ADDRESS-1:0] address;
    logic read_enable, write_enable;

    // Master operation
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always_comb begin
        next_state = state;
        M_ARVALID = 1'b0;
        M_AWVALID = 1'b0;
        M_WVALID = 1'b0;
        M_RREADY = 1'b0;
        M_BREADY = 1'b0;

        case (state)
            IDLE: begin
                if (write_enable) begin
                    next_state = WRITE_ADDR;
                end else if (read_enable) begin
                    next_state = READ_ADDR;
                end
            end

            WRITE_ADDR: begin
                M_AWVALID = 1'b1;
                if (M_AWREADY) begin
                    next_state = WRITE_DATA;
                end
            end

            WRITE_DATA: begin
                M_WVALID = 1'b1;
                if (M_WREADY) begin
                    next_state = IDLE;
                    M_BREADY = 1'b1;
                end
            end

            READ_ADDR: begin
                M_ARVALID = 1'b1;
                if (M_ARREADY) begin
                    next_state = READ_DATA;
                end
            end

            READ_DATA: begin
                M_RREADY = 1'b1;
                if (M_RVALID) begin
                    next_state = IDLE;
                end
            end

            default: next_state = IDLE;
        endcase
    end

    // read and write transactions
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            write_data <= 32'h0;
            address <= 32'h0;
            read_enable <= 1'b0;
            write_enable <= 1'b0;
        end else begin
            // write transaction
            if (state == IDLE && write_enable) begin
                M_AWADDR <= address;
                M_WDATA <= write_data;
                M_WSTRB <= 4'b1111; 
            end

            // read transaction
            if (state == IDLE && read_enable) begin
                M_ARADDR <= address;
            end
        end
    end

endmodule
