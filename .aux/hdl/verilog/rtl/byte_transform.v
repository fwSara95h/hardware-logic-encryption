// byte_transform.v
//
// Supplementary HDL reference model for:
//   "Design and Simulation of a Hardware Logic Encryption Block
//    for Sequential Circuits" (2018/2019).
// This is a later digital reconstruction, not an original Synopsys export.
//
// Report references (printed page numbers):
//   Section 3.4,   p. 25: XOR and four-bit rearrangement; decryption key wiring.
//   Section 3.4.5, p. 35: rearrangement implemented by wire placement.
//   Section 3.4.6, p. 37: same datapath, with different key wiring.
//
// Interface contract:
//   DECRYPT = 1'b0: data_in is plaintext;  data_out is ciphertext.
//   DECRYPT = 1'b1: data_in is ciphertext; data_out is recovered data.
//   DECRYPT is a one-bit configuration parameter, not a runtime input.
//   key_in is the original, unrotated key in BOTH configurations.
//   Vectors use aligned parallel bit indices; serial bit order is out of scope.
//
// Let R4(x) = {x[3:0], x[7:4]} (swap the two four-bit halves).
//   Encryption: data_out = R4(data_in XOR key_in).
//   Decryption: data_out = R4(data_in XOR R4(key_in)).
// The report's hardwired "shift" preserves all eight bits; it is not >> 4.
//
// Scope: combinational logic only. No clocks, registers, reset, serialization,
// key generation, pseudo-LVDS circuitry, or physical delay modelling.
// Educational reference model; no claim of cryptographic security.

`default_nettype none

module byte_transform #(
    parameter [0:0] DECRYPT = 1'b0
) (
    input  wire [7:0] data_in,
    input  wire [7:0] key_in,
    output wire [7:0] data_out
);

    wire [7:0] effective_key;
    wire [7:0] xor_result;

    // Reproduce the different key wiring of the decryption block.
    assign effective_key = DECRYPT
                         ? {key_in[3:0], key_in[7:4]}
                         : key_in;

    // Both configurations use the same XOR-then-rearrange datapath.
    assign xor_result = data_in ^ effective_key;
    assign data_out   = {xor_result[3:0], xor_result[7:4]};

endmodule

`default_nettype wire
