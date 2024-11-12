module axi4_lite_slave #(
    parameter ADDRESS = 32,
    parameter DATA_WIDTH = 32
)(
    // Global Signals
    input wire ACLK,
    input wire ARESETN,

    // Read Address Channel INPUTS
    input wire [ADDRESS-1:0] S_ARADDR,
    input wire S_ARVALID,
    output reg S_ARREADY,

    // Read Data Channel INPUTS
    input wire S_RREADY,
    output reg [DATA_WIDTH-1:0] S_RDATA,
    output reg [1:0] S_RRESP,
    output reg S_RVALID,

    // Write Address Channel INPUTS
    input wire [ADDRESS-1:0] S_AWADDR,
    input wire S_AWVALID,
    output reg S_AWREADY,

    // Write Data Channel INPUTS
    input wire [DATA_WIDTH-1:0] S_WDATA,
    input wire [3:0] S_WSTRB,
    input wire S_WVALID,
    output reg S_WREADY,

    // Write Response Channel INPUTS
    input wire S_BREADY,
    output reg [1:0] S_BRESP,
    output reg S_BVALID
);

    // Register definition
    localparam no_of_registers = 32;
    reg [DATA_WIDTH-1:0] register [no_of_registers-1:0];
    reg [ADDRESS-1:0] addr;

    // AXI Write and Read Handshake Signals
    wire write_addr_handshake = S_AWVALID && S_AWREADY;
    wire write_data_handshake = S_WVALID && S_WREADY;
    wire read_addr_handshake = S_ARVALID && S_ARREADY;

    typedef enum logic [2:0] {
        IDLE, WRITE_ADDR_CHANNEL, WRITE_DATA_CHANNEL, WRESP_CHANNEL, RADDR_CHANNEL, RDATA_CHANNEL
    } state_type;

    state_type state, next_state;

    // Address alignment logic
    wire [ADDRESS-1:2] aligned_awaddr = S_AWADDR[ADDRESS-1:2];
    wire [ADDRESS-1:2] aligned_araddr = S_ARADDR[ADDRESS-1:2];

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

module axi4_lite_slave_top (
    input wire ACLK,
    input wire ARESETN,

    // AXI4-Lite Slave I/O signals
    input wire [31:0] S_ARADDR,
    input wire S_ARVALID,
    output wire S_ARREADY,
    output wire [31:0] S_RDATA,
    output wire [1:0] S_RRESP,
    output wire S_RVALID,
    input wire S_RREADY,

    input wire [31:0] S_AWADDR,
    input wire S_AWVALID,
    output wire S_AWREADY,
    input wire [31:0] S_WDATA,
    input wire [3:0] S_WSTRB,
    input wire S_WVALID,
    output wire S_WREADY,

    output wire [1:0] S_BRESP,
    output wire S_BVALID,
    input wire S_BREADY
);

    axi4_lite_slave #(
        .ADDRESS(32),
        .DATA_WIDTH(32)
    ) axi_slave_inst (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // Read Address Channel
        .S_ARADDR(S_ARADDR),
        .S_ARVALID(S_ARVALID),
        .S_ARREADY(S_ARREADY),
        
        // Read Data Channel
        .S_RDATA(S_RDATA),
        .S_RRESP(S_RRESP),
        .S_RVALID(S_RVALID),
        .S_RREADY(S_RREADY),
        
        // Write Address Channel
        .S_AWADDR(S_AWADDR),
        .S_AWVALID(S_AWVALID),
        .S_AWREADY(S_AWREADY),
        
        // Write Data Channel
        .S_WDATA(S_WDATA),
        .S_WSTRB(S_WSTRB),
        .S_WVALID(S_WVALID),
        .S_WREADY(S_WREADY),
        
        // Write Response Channel
        .S_BRESP(S_BRESP),
        .S_BVALID(S_BVALID),
        .S_BREADY(S_BREADY)
    );
endmodule

      