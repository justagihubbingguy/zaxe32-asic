module valu ( // vector alu gpu lane
    input  logic        mask,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  op,
    output logic [31:0] out,
    output logic [2:0]  flags
);
    logic [32:0] add_out;
    assign add_out = a + b;

    logic [4:0] shift_amt;
    assign shift_amt = b[4:0];

    logic [31:0] alu_calc;
    logic        carry_bit;

    assign out       = mask ? alu_calc : 32'b0;
    assign carry_bit = (mask && (op == 4'b0000)) ? add_out[32] : 1'b0;
    assign flags     = mask ? { carry_bit, alu_calc[31], (alu_calc == 32'b0) } : 3'b000;

    always_comb begin
        case (op)
            4'b0000: alu_calc = add_out[31:0];
            4'b0001: alu_calc = a - b;
            4'b0010: alu_calc = a * b;
            4'b0011: alu_calc = 32'b0; // reserved
            4'b0100: alu_calc = a ^ b;
            4'b0101: alu_calc = a & b;
            4'b0110: alu_calc = a | b;
            4'b0111: alu_calc = a << shift_amt;
            4'b1001: alu_calc = a >> shift_amt;
            4'b1010: alu_calc = a <<< shift_amt;
            4'b1011: alu_calc = 32'($signed(a) >>> shift_amt);
            4'b1111: alu_calc = (a > b) ? a : b;
            default: alu_calc = 32'b0;
        endcase
    end
endmodule
