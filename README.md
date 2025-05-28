# UVM-Based-Verification-Sync_FIFO

UVM-based functional verification project for a **Synchronous FIFO** design using Universal Verification Methodology (UVM) and industry best practices. This project demonstrates constrained-random stimulus generation, assertion-based verification, and functional + code coverage closure.

## Overview

This verification environment validates a parameterized synchronous FIFO design using:
- Constrained random stimulus via UVM sequences
- Reference (golden) model comparison through a scoreboard
- SystemVerilog Assertions (SVA)
- Functional and code coverage
- UVM reporting and configuration management
- Functional coverage points tied to a defined verification plan

## Verification Features

- **Verification Methodology**: UVM-based architecture (SystemVerilog)
- **Testbench Components**: 
  - `uvm_env`, `uvm_agent`, `uvm_driver`, `uvm_monitor`, `uvm_scoreboard`, `uvm_sequencer`, `uvm_test`
- **Stimulus Generation**: Constrained Random Sequences
- **Checker**: Scoreboard with golden reference model
- **Assertions**: Inline & interface-bound SystemVerilog Assertions (SVA)
- **Coverage**:
  - Code Coverage (Statement, Branch, Toggle)
  - Functional Coverage
- **Corner Case Scenarios**: Underflow, Overflow, Simultaneous read/write

## Project Structure
```text
UVM_Based_Verification_Sync_FIFO/
├── docs/                 # Coverage and Assertion reports (images)
├── rtl/                  # FIFO RTL design files
├── tb/
│   ├── env/              # UVM environment components
│   ├── agent/            # Driver, sequencer, monitor
│   ├── sequences/        # Sequence items and test sequences
│   ├── tests/            # UVM test classes
│   ├── interfaces/       # Virtual interfaces and assertions
│   ├── packages/         # UVM type definitions and config
│   └── tb_top.sv         # Top-level testbench module
├── sim/                  # Do files, logs, waveforms
├── scripts/              # Compilation and run scripts
├── Makefile              # Build and simulation flow
├── README.md
```

## Coverage Results

### Excutive Summary

![Excutive Summary](./Docs/Executive%20Summary.png)

### Code Coverage

![Code Coverage](./Docs/Code%20Coverage%20Analysis.png)

### Functional Coverage

![Functional Coverage](./Docs/Functional%20Coverage%20Analysis.png)

## Assertions

![Assertions Coverage](./Docs/Assertion%20Coverage.png)

### Verification Conclusion

![Verification Conclusion](./Docs/Verification%20Conclusion.png)

