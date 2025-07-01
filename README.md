![Project Poster](./Poster.png)

---

# Design and Simulation of a Hardware Logic Encryption Block for Sequential Circuits

[![University](https://img.shields.io/badge/University-PSUT-blue)](https://www.psut.edu.jo/en)
[![Year](https://img.shields.io/badge/Year-2019-green)](https://github.com/shirazb/hardware-logic-encryption)

## Overview

This project presents the design and simulation of a hardware-based encryption block for sequential circuits, developed as a senior design project at Princess Sumaya University for Technology. The encryption block is designed to be integrated between components of existing architectures with minimal additional cost, providing a security layer for modern communication systems.

The encryption system consists of two complementary blocks: one for encryption and one for decryption. Each block is compact (less than 500μm² in a 28nm CMOS technology) and can process serial data at speeds up to 1Gb/s according to pseudo-LVDS standards. The power consumption for each block is less than 15mW.

The design uses a symmetric encryption approach where the key is fixed by wiring. Data is processed byte-by-byte through XOR operations and hardwired shifts, with the encryption/decryption blocks operating on three different clocks. The system was simulated on Synopsys Custom Designer and tested for functionality across various process corners.

Performance analysis demonstrated that the LVDS interface (which includes the receiver, transmitter, and driving inverters) consumes most of the area (93%) and power (77%), while the actual encryption components require only a small fraction of resources. This highlights the efficiency of the encryption scheme, which adds significant security benefits with minimal overhead.

## Design

Each encryption/decryption block requires:
- 1V supply voltage
- Two inputs for receiving serial differential data
- Eight parallel inputs for the encryption key
- Sub-blocks operating on three different clocks

The design flow follows these key steps:

1. Differential data is first converted to single-ended data by the receiver (a single-stage differential amplifier)
2. A serial-in-parallel-out (SIPO) shift register converts the serial data to 8 bits of parallel data
3. The parallel data undergoes XOR operations with the encryption key
4. A hardwired 4-bit shift rotation is applied before conversion back to serial format
5. The parallel-in-serial-out (PISO) shift register converts the encrypted data back to serial format
6. The data is transmitted through pseudo-LVDS transmitters

The decryption scheme mirrors the encryption process, with the key difference being that the key undergoes a 4-bit shift-rotation before entering the parallel-in-parallel-out (PIPO) register. Data can only be recovered if the same key is used for both encryption and decryption.

## Results

The encryption and decryption blocks were tested individually and together using testbenches with 16-bit test patterns. Key findings include:

- Successful encryption and decryption with matching keys (001101101)
- Corrupted data when using mismatched encryption/decryption keys
- Consistent performance across different process corners (TT, SS, FF)
- Area distribution: LVDS interface (93%), Registers (49%), Encryption logic (7%)
- Power distribution: LVDS interface (77%), Registers (21%), Encryption logic (2%)

The design successfully demonstrates that hardware-based encryption can be readily integrated into existing systems with minimal overhead, providing an efficient security layer for sequential circuits.

## Poster & Report

For more detailed information about this project:

- [View the Final Report (PDF)](./Final_Report.pdf)
- [View the Project Poster](./Poster.png)

## Limitations

- The Synopsys Custom Designer simulation files are not available in this repository due to them being accessible only through a remote VM at the university
- The current implementation uses a fixed key approach; a more robust implementation would allow for dynamic key changes
- The design has been simulated but not physically implemented on silicon
