# RISC-V CPU

A 5-stage pipelined RV32IM processor written in SystemVerilog, verified with Verilator.

## Status

| Block | Status |
|-------|--------|
| Register file | Done, tested |
| Immediate generator | Done, tested |
| ALU | Done, tested |
| Decoder | R-type and I-type ALU, tested |
| Pipeline | Not started |

## Running the tests

    make lint
    make test
