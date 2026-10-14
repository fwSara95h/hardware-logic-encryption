// key_register8.v
//
// Supplementary HDL reference model for:
//   "Design and Simulation of a Hardware Logic Encryption Block
//    for Sequential Circuits" (2018/2019).
// This is a later digital reconstruction, not an original Synopsys export.
//
// Report references (printed page numbers):
//   Section 3.4.4.2, p. 35: PIPO key storage and external clock coordination.
//   Appendix A, p. 63: ki_0..ki_7 -> ko_0..ko_7, clocked by wrpulse.
//
// Interface contract:
//   clk_key: positive-edge key-capture clock; maps to the report's wrpulse.
//   key_in[i]: parallel key input; maps to ki_i, for i = 0 through 7.
//   key_out[i]: captured key bit; maps to ko_i, for i = 0 through 7.
//
// All eight bits are captured together on EVERY rising edge of clk_key.
// Between rising edges, key_out retains its last captured value.
// Changes to key_in alone and falling clock edges do not update key_out.
// This is parallel storage: no shifting, bit reversal, or rotation occurs.
//
// Integration with byte_transform.v:
//   Capture the original, unrotated key in BOTH encryption and decryption.
//   Connect key_out to byte_transform's key_in port.
//   byte_transform handles the decryption-key rearrangement internally;
//   do not also rotate the key here or in the connecting wires.
//
// No reset, enable, initial value, clock divider, or key generator is added.
// In ordinary four-state RTL simulation, key_out starts unknown (X).
// One rising edge with all eight input bits known establishes the whole key.
// Even a constant key must be captured before its stored value is used.
// Key-update scheduling and coordination with the SIPO/PISO are external.
//
// Assume a clean 0/1 clock and key_in stable around each rising edge.
// Scope: ideal digital storage only. No transistor delays, setup/hold checks,
// clock skew, metastability modelling, or physical power-up guarantees.

`default_nettype none

module key_register8 (
    input  wire       clk_key,
    input  wire [7:0] key_in,
    output reg  [7:0] key_out
);

    // Nonblocking assignment models all eight flip-flops updating together.
    always @(posedge clk_key) begin
        key_out <= key_in;
    end

endmodule

`default_nettype wire
