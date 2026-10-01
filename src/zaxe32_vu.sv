module zaxe32_core #(
    parameter LANES = 32
)(
    input  logic [LANES-1:0]        mask,
    input  logic [(LANES*32)-1:0]   vector_a,
    input  logic [(LANES*32)-1:0]   vector_b,
    input  logic [3:0]              op,
    output logic [(LANES*32)-1:0]   vector_out,
    output logic [(LANES*3)-1:0]    vector_flags
);

    generate
        genvar i;
        for (i = 0; i < LANES; i = i + 1) begin : lane_generation
            valu compute_lane (
                .mask (mask[i]),
                .a    (vector_a[(i*32) +: 32]),
                .b    (vector_b[(i*32) +: 32]),
                .op   (op),
                .out  (vector_out[(i*32) +: 32]),
                .flags(vector_flags[(i*3) +: 3])
            );
        end
    endgenerate

endmodule
