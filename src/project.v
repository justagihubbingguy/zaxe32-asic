`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs: Your Assembly Control Dashboard
    output wire [7:0] uo_out,   // Dedicated outputs: Real-time Silicon Status Flags
    input  wire [7:0] uio_in,   // IO pads: Input path (Unused, held safe)
    output wire [7:0] uio_out,  // IO pads: Output path (Unused, held safe)
    output wire [7:0] uio_oe,   // IO pads: Output Enable control (Set to 0 for input)
    input  wire       ena,      // Will be 1 when the chip is powered and active
    input  wire       clk,      // Master Silicon Clock pulse
    input  wire       rst_n     // Global hardware reset (Active Low)
);

    // 1. SAFETY RIGGING: Safely disable bidirectional pins so they don't short-circuit
    assign uio_oe  = 8'b00000000;
    assign uio_out = 8'b00000000;

    // 2. MAPPING THE ASSEMBLY CONTROL DASHBOARD PINS
    // We map your 8 input pins to control your proprietary ISA execution dynamically!
    wire        cfg_write_enable = ui_in[0];  // Pin 0: Enable saving ALU results to VRF
    wire [3:0]  cfg_op           = ui_in[4:1];// Pins 1-4: Your 4-bit Custom Zaxe32 Opcode Matrix
    wire [2:0]  cfg_reg_select   = ui_in[7:5];// Pins 5-7: Select vector registers v0-v7 dynamically

    // 3. THE INTERFACE ADAPTER FLAGS BUNDLE
    wire [(32*3)-1:0] all_lane_flags; // Captures the 3-bit flags from all 32 lanes (96 bits total)

    // 4. INSTANTIATE YOUR PROPRIETARY ZAXE32 GPU ENGINE
    // This physically connects your custom ISA to the SkyWater 130nm silicon pads!
    zaxe32_eu #(.LANES(32)) my_gpu_core (
        .clk           (clk),
        .write_enable  (cfg_write_enable),
        .op            (cfg_op),
        
        // Active Lane Masking: Keep all 32 parallel lanes turned ON for this execution run
        .mask          ({32{1'b1}}), 
        
        // Register Selection: Map your dashboard pins to select register targets dynamically
        .src_a         ({2'b00, cfg_reg_select}),     // Maps to selected register
        .src_b         ({2'b00, cfg_reg_select + 1'b1}), // Automatically reads adjacent register
        .dest          ({2'b00, cfg_reg_select + 2'b10}),// Automatically targets calculation dest
        
        // Data Highway Loopback: ALU outputs loop directly back into the VRF memory grid
        .eu_output     (), 
        .eu_flags      (all_lane_flags) // Streams out the 96-bit bundled status flags matrix
    );

    // 5. ROUTING FLAGS TO THE OUTPUT PINS
    // Since we only have 8 output pins, we route the real-time execution flags of Lane 0
    // straight out to the physical chip legs so you can monitor calculations with LEDs!
    assign uo_out[0] = all_lane_flags[0]; // Lane 0: Carry Flag
    assign uo_out[1] = all_lane_flags[1]; // Lane 0: Negative Flag
    assign uo_out[2] = all_lane_flags[2]; // Lane 0: Zero Flag
    
    // Hold remaining output pins cleanly at zero
    assign uo_out[7:3] = 5'b00000;

endmodule
