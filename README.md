**# 32-Bit RISC-V CPU with Dynamic Branch Prediction and Instruction Cache

A Verilog-based, five-stage pipelined RISC-V processor core implementing the RV32I instruction set. The design features dynamic branch prediction using a Branch History Table (BHT) and Branch Target Buffer (BTB), as well as a single-level, set-associative instruction cache. Developed and simulated using AMD Vivado 2024.2.

---

## Table of Contents
- [Architecture](#architecture)
  - [Pipeline Design](#pipeline-design)
  - [Hazard Resolution](#hazard-resolution)
  - [Branch Prediction](#branch-prediction)
  - [Instruction Cache](#instruction-cache)
- [Simulation and Testing](#simulation-and-testing)
- [Future Work](#future-work)

---

## Architecture

### Pipeline Design

The processor datapath follows the classic five-stage RISC pipeline:
1. **Instruction Fetch (IF)**
2. **Instruction Decode (ID)**
3. **Execute (EX)**
4. **Memory Access (MEM)**
5. **Write Back (WB)**

### Hazard Resolution

- **Data hazards** are mitigated using data forwarding units.
- Forwarding logic identifies dependencies and supplies results from later pipeline stages (EX, MEM, WB) directly to the ALU inputs, minimizing stalls.

### Branch Prediction

- **Branch execution** occurs during the **ID stage**, which reduces pipeline delay associated with branches.
- A dedicated branch condition checker and forwarding unit handle operand dependencies specific to branch instructions.

Dynamic branch prediction is achieved using:
- **Branch History Table (BHT)**:
  - Indexed by the lower bits of the Program Counter (PC)
  - Contains 2-bit saturating counters indicating the probability of a branch being taken
- **Branch Target Buffer (BTB)**:
  - 4-way set associative structure
  - Stores predicted target addresses of recent branches
  - If both BHT and BTB indicate a taken branch, the PC is updated with the predicted PC (PPC)

### Instruction Cache

- 4-way set associative design with 32-byte blocks
- Cache access occurs in the IF stage
- On a cache **hit**, the instruction is fetched in a single cycle
- On a **miss**, a cache miss signal is raised, and the appropriate block is requested from instruction memory
- Once updated, instruction fetch proceeds from the cache

---

## Simulation and Testing

Testing is conducted by manually inserting RISC-V assembly instructions into the instruction memory. Test cases are crafted to:
- Introduce data and control hazards
- Implement loops to test prediction accuracy
- Stress the forwarding and hazard detection mechanisms

Simulation is carried out using AMD Vivado’s simulation environment. Functional verification is done through waveform analysis to confirm pipeline correctness, proper hazard resolution, and cache behavior.

---

## Future Work

### Short-Term Goals
- Implementation of a **data cache**
- Integration of a **UART peripheral** for serial I/O

### Long-Term Goals
- Transition to a **superscalar architecture**
- Support for **Out-of-Order execution**
- Expansion of supported instruction sets:
  - **RV32M** (Multiplication and Division)
  - **RV32A** (Atomic operations)
  - **RV32F/D** (Floating-point and Double-Precision)
  - **RV32C** (Compressed instructions)

---

## Acknowledgments

- RISC-V ISA Specifications: [riscv.org](https://riscv.org/specifications/)
- Vivado Design Suite by AMD/Xilinx

