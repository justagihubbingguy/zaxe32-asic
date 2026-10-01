module zaxe32_eu #(
    parameter LANES = 32
)(
    input  logic                   clk,
    input  logic                   write_enable,
    input  logic [3:0]             op,
    input  logic [LANES-1:0]       mask,
    
    input  logic [4:0]             src_a,
    input  logic [4:0]             src_b,
    input  logic [4:0]             dest,
    
    output logic [(LANES*32)-1:0]  eu_output,
    output logic [(LANES*3)-1:0]   eu_flags
);

    logic [(LANES*32)-1:0] vrf_to_core_a;
    logic [(LANES*32)-1:0] vrf_to_core_b;

    vrf #(.LANES(LANES)) vrf_inst (
        .clk(clk),
        .write_enable(write_enable),
        .read_reg_a(src_a),
        .read_reg_b(src_b),
        .write_reg(dest),
        .write_mask(mask),
        .vector_data_in(eu_output),
        .vector_out_a(vrf_to_core_a),
        .vector_out_b(vrf_to_core_b)
    );

    zaxe32_core #(.LANES(LANES)) core_inst (
        .mask(mask),
        .vector_a(vrf_to_core_a),
        .vector_b(vrf_to_core_b),
        .op(op),
        .vector_out(eu_output),
        .vector_flags(eu_flags)
    );

endmodule
