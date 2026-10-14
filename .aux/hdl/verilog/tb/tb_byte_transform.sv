// tb_byte_transform.sv
//
// Later supplementary tests for byte_transform.v; not original Synopsys tests.
// Compile as SystemVerilog. No other testbench or vector file is required.
//
// Coverage:
//   - Eight fixed plaintext/key/ciphertext vectors and one fixed wrong-key case.
//   - All 65,536 data/key pairs, with separate encryption/decryption checks.
//   - Correct-key round trips for all 65,536 plaintext/key pairs.
//   - A one-bit-wrong decryption key for every plaintext/key pair.
//   - All 255 wrong decryption keys for plaintext 8'h8E and key 8'h36.
//
// Reference functions use per-bit indexing, not the DUT's concatenations.
// Decryption is checked independently as inverse permutation followed by XOR.
// Unexpected X/Z outputs fail comparisons against the known expected values.
//
// Scope: ideal combinational byte behaviour only, not serial or analog timing,
// physical implementation equivalence, or cryptographic security.
// Every #1 is a testbench settling interval, NOT a measured gate delay.
// Optional waveform output: pass +vcd=<existing-directory>/<filename>.vcd.

`timescale 1ns/1ps
`default_nettype none

module tb_byte_transform;

    logic [7:0] plaintext;
    logic [7:0] ciphertext_in;
    logic [7:0] key_in;
    logic [7:0] roundtrip_key;

    wire [7:0] encrypted;
    wire [7:0] decrypted;
    wire [7:0] roundtrip_out;

    integer comparisons = 0;
    integer known_vectors = 0;
    integer exhaustive_pairs = 0;
    integer wrong_key_cases = 0;
    integer data_value;
    integer key_value;
    integer candidate_key;
    string vcd_path;

    byte_transform #(.DECRYPT(1'b0)) dut_encrypt (
        .data_in(plaintext),
        .key_in(key_in),
        .data_out(encrypted)
    );

    // Independent ciphertext stimulus: not connected to the encryptor.
    byte_transform #(.DECRYPT(1'b1)) dut_decrypt (
        .data_in(ciphertext_in),
        .key_in(key_in),
        .data_out(decrypted)
    );

    // Also exercise an actual encrypt -> decrypt connection.
    byte_transform #(.DECRYPT(1'b1)) dut_roundtrip (
        .data_in(encrypted),
        .key_in(roundtrip_key),
        .data_out(roundtrip_out)
    );

    function automatic logic [7:0] reference_encrypt (
        input logic [7:0] data,
        input logic [7:0] key
    );
        integer i;
        begin
            for (i = 0; i < 8; i = i + 1)
                reference_encrypt[(i + 4) % 8] = data[i] ^ key[i];
        end
    endfunction

    function automatic logic [7:0] reference_decrypt (
        input logic [7:0] data,
        input logic [7:0] key
    );
        integer i;
        begin
            for (i = 0; i < 8; i = i + 1)
                reference_decrypt[i] = data[(i + 4) % 8] ^ key[i];
        end
    endfunction

    task automatic check_byte (
        input string label_text,
        input logic [7:0] actual,
        input logic [7:0] expected
    );
        begin
            comparisons = comparisons + 1;
            if (actual !== expected) begin
                $display("FAIL [%s] at t=%0t: actual=%02h expected=%02h",
                         label_text, $time, actual, expected);
                $display("  plaintext=%02h ciphertext_in=%02h key=%02h roundtrip_key=%02h",
                         plaintext, ciphertext_in, key_in, roundtrip_key);
                $fatal(1, "tb_byte_transform failed.");
            end
        end
    endtask

    task automatic check_known_vector (
        input logic [7:0] plain,
        input logic [7:0] key,
        input logic [7:0] cipher
    );
        begin
            plaintext = plain;
            ciphertext_in = cipher;
            key_in = key;
            roundtrip_key = key;
            #1;
            check_byte("known encryption", encrypted, cipher);
            check_byte("known decryption", decrypted, plain);
            check_byte("known round trip", roundtrip_out, plain);
            known_vectors = known_vectors + 1;
        end
    endtask

    // Simulation-time guard; it is not a wall-clock timeout.
    initial begin : watchdog
        #1_000_000;
        $fatal(1, "tb_byte_transform exceeded its simulation-time limit.");
    end

    initial begin : optional_waveforms
        if ($value$plusargs("vcd=%s", vcd_path)) begin
            $dumpfile(vcd_path);
            $dumpvars(0, tb_byte_transform);
        end
    end

    initial begin : tests
        plaintext = 8'h00;
        ciphertext_in = 8'h00;
        key_in = 8'h00;
        roundtrip_key = 8'h00;

        // First vector reproduces the report's zero-key example (p. 49).
        // Remaining vectors are fixed checks of this companion's equations;
        // they are not claimed to be separate original circuit simulations.
        check_known_vector(8'h8E, 8'h00, 8'hE8);
        check_known_vector(8'h8E, 8'h36, 8'h8B);
        check_known_vector(8'h00, 8'h00, 8'h00);
        check_known_vector(8'hFF, 8'h00, 8'hFF);
        check_known_vector(8'h00, 8'hFF, 8'hFF);
        check_known_vector(8'hFF, 8'hFF, 8'h00);
        check_known_vector(8'hA5, 8'h5A, 8'hFF);
        check_known_vector(8'h12, 8'h34, 8'h62);

        plaintext = 8'h8E;
        key_in = 8'h36;
        roundtrip_key = 8'h24;
        #1;
        check_byte("fixed wrong-key result", roundtrip_out, 8'h9C);
        $display("PASS: %0d known-answer vectors + 1 fixed wrong-key case.",
                 known_vectors);

        for (key_value = 0; key_value < 256; key_value = key_value + 1) begin
            for (data_value = 0; data_value < 256; data_value = data_value + 1) begin
                plaintext = data_value[7:0];
                ciphertext_in = data_value[7:0];
                key_in = key_value[7:0];
                roundtrip_key = key_in;
                #1;

                check_byte("exhaustive encryption", encrypted,
                           reference_encrypt(plaintext, key_in));
                check_byte("exhaustive decryption", decrypted,
                           reference_decrypt(ciphertext_in, key_in));
                check_byte("exhaustive round trip", roundtrip_out, plaintext);

                // Algebraic consequence of the byte-model specification:
                // D(E(P, K), K_wrong) = P XOR K XOR K_wrong.
                // Here only bit 0 differs, so only plaintext bit 0 must flip.
                roundtrip_key = key_in ^ 8'h01;
                #1;
                check_byte("one-bit wrong key", roundtrip_out,
                           plaintext ^ 8'h01);
                exhaustive_pairs = exhaustive_pairs + 1;
            end
        end
        $display("PASS: %0d exhaustive byte/key pairs (4 checks per pair).",
                 exhaustive_pairs);

        // Sweep every wrong decryption key for one fixed plaintext/key pair.
        // This is NOT an exhaustive sweep of all plaintext/key/wrong-key triples.
        plaintext = 8'h8E;
        ciphertext_in = 8'h8B;
        key_in = 8'h36;
        for (candidate_key = 0; candidate_key < 256; candidate_key = candidate_key + 1) begin
            if (candidate_key[7:0] != key_in) begin
                roundtrip_key = candidate_key[7:0];
                #1;
                check_byte("wrong-key sweep", roundtrip_out,
                           plaintext ^ key_in ^ roundtrip_key);
                wrong_key_cases = wrong_key_cases + 1;
            end
        end
        $display("PASS: %0d wrong keys for plaintext=8e, key=36.", wrong_key_cases);

        if ((known_vectors != 8) || (exhaustive_pairs != 65536) ||
            (wrong_key_cases != 255) || (comparisons != 262424))
            $fatal(1, "Unexpected test count; not all planned checks ran.");

        $display("PASS: tb_byte_transform (%0d comparisons).", comparisons);
        $finish;
    end

endmodule

`default_nettype wire
