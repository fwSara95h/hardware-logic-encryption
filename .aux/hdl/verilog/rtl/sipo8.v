// sipo8.v
//
// Supplementary HDL reference model for:
//   "Design and Simulation of a Hardware Logic Encryption Block
//    for Sequential Circuits" (2018/2019).
// This is a later digital reconstruction, not an original Synopsys export.
//
// Report references (printed page numbers):
//   Section 3.4.4.1, p. 35: eight D flip-flops forming the SIPO register.
//   Section 3.4.4.3, p. 35: SIPO sampling uses positive clock edges.
//   Appendix A, p. 61: serialdatain -> po_7 -> po_6 -> ... -> po_0.
//
// Interface contract:
//   clk_sipo: positive-edge sampling clock.
//   serial_in: single-ended logic input at the receiver's digital boundary.
//   parallel_out[i]: the report's po_i signal, for i = 0 through 7.
//
// At each rising edge:
//   parallel_out[7]   takes serial_in.
//   parallel_out[6:0] takes the PREVIOUS value of parallel_out[7:1].
//   The previous parallel_out[0] is discarded.
//
// Byte convention derived from that wiring:
//   Feed b[0], b[1], ... b[7] on eight consecutive rising edges (LSB first).
//   After the eighth register update, parallel_out equals b[7:0].
//   Output is the live shift-register state, not a separately latched byte.
//   Shifting continues on EVERY rising edge; byte framing is external.
//
// No reset, enable, byte counter, valid flag, or initial value is added.
// In ordinary four-state RTL simulation the register starts unknown (X).
// Eight known input samples replace all startup state; no extra flush is
// required before those first eight samples. Later samples keep shifting in.
//
// Assume a clean 0/1 clock and serial data stable around each rising edge.
// Scope: ideal digital register behaviour only. No pseudo-LVDS circuitry,
// transistor delays, setup/hold checks, clock skew, or metastability modelling.

`default_nettype none

module sipo8 (
    input  wire       clk_sipo,
    input  wire       serial_in,
    output reg  [7:0] parallel_out
);

    // Nonblocking assignment models all eight stages updating together.
    // New data enters bit 7; existing data moves toward bit 0.
    always @(posedge clk_sipo) begin
        parallel_out <= {serial_in, parallel_out[7:1]};
    end

endmodule

`default_nettype wire
