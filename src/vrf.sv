module vrf #(
    parameter LANES = 32,
    parameter REGS = 32
) (
    input  logic                   clk,
    input  logic                   write_enable,
    input  logic [4:0]             read_reg_a,
    input  logic [4:0]             read_reg_b,
    input  logic [4:0]             write_reg,
    input  logic [LANES-1:0]       write_mask,
    input  logic [(LANES*32)-1:0]  vector_data_in,
    output logic [(LANES*32)-1:0]  vector_out_a,
    output logic [(LANES*32)-1:0]  vector_out_b
);
    logic [31:0] lane_regfile [LANES-1:0] [REGS-1:0];

    always_ff @(posedge clk) begin
        if (write_enable) begin
            for (int i = 0; i < LANES; i = i + 1) begin
                if (write_mask[i]) begin
                    lane_regfile[i][write_reg] <= vector_data_in[(i*32) +: 32];
                end
            end
        end
    end

    generate
        genvar i;
        for (i = 0; i < LANES; i = i + 1) begin : vrf_read_lanes
            assign vector_out_a[(i*32) +: 32] = lane_regfile[i][read_reg_a];
            assign vector_out_b[(i*32) +: 32] = lane_regfile[i][read_reg_b];
        end
    endgenerate

endmodule
