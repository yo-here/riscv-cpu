# RISC-V CPU

A 5-stage pipelined RV32IM processor written in SystemVerilog, verified with Verilator.

## Status

| Block | Status |
|-------|--------|
| Register file | Done, tested |
| Immediate generator | Done, tested |
| ALU | Done, tested |
| Decoder | ALU ops, loads, stores, tested |
| Pipeline | Not started |

## Running the tests

    make lint
    make test
