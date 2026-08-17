# RV32I 5-Stage Pipelined Processor

A 5 stage pipelined RISCV RV32I processor was built from the single cycle implementation, using SystemVerilog. The design features a dedicated Hazard Unit managing all classes of pipeline hazards, verified using cocotb testbenches with targeted assembly programs, and synthesized to the SkyWater 130nm (sky130) process node using Yosys with static timing analysis performed using OpenSTA.

---

## Supported Instructions

| Type | Instructions | Opcode |
|------|-------------|--------|
| R-type | ADD, SUB, AND, OR, SLT | 0110011 |
| Load | LW | 0000011 |
| Store | SW | 0100011 |
| Branch | BEQ | 1100011 |

---

## Pipeline Architecture

The processor implements a 5-stage pipeline:

```
Fetch → Decode → Execute → Memory → Writeback
```

Pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB) separate each stage. All control signals are registered and flow through the pipeline alongside the datapath signals.

---

## Hazard Unit

The Hazard Unit is implemented entirely in combinational logic (61 cells, 0% sequential) ensuring zero-latency hazard detection within the same clock cycle.

| Hazard Type | Detection | Resolution |
|-------------|-----------|------------|
| RAW data hazard (EX/MEM) | Compares EX/MEM destination with ID/EX source registers | Forward ALU result directly to EX stage input |
| RAW data hazard (MEM/WB) | Compares MEM/WB destination with ID/EX source registers | Forward writeback result to EX stage input |
| Load-use hazard | Detects LW in EX followed by dependent instruction in ID | Stall PC and IF/ID, flush ID/EX (insert bubble) |
| Control hazard | Branch outcome resolved in EX stage | Flush IF/ID and ID/EX on taken branch |

---

## Repository Structure

```
riscv_pipelined/
├── rtl/                                       # SystemVerilog source files
│   ├── top_wrapper.sv                         # Top level integration, pipeline registers, PC mux
│   ├── Program_counter.sv                     # 32-bit PC with stall and flush support
│   ├── Register_file.sv                       # 32x32 register file, write-first forwarding, x0 hardwired to 0
│   ├── Hazard_Unit.sv                         # Combinational hazard detection and forwarding control
│   ├── alu.sv                                 # ALU: ADD, SUB, AND, OR, SLT
│   ├── alu_decoder.sv                         # Decodes ALUOp + funct3 + funct7 to ALU control
│   ├── control_decoder.sv                     # Main control unit, opcode to control signals
│   ├── control_wrapper.sv                     # Wraps control_decoder and alu_decoder
│   ├── sign_extender.sv                       # I-type and S-type immediate sign extension
│   ├── instruction_memory.sv                  # ROM, loads program from sample_instruction.mem
│   ├── branch_alu.sv                          # Branch target: PC + sign-extended immediate
│   ├── data_memory.sv                         # Data memory, synchronous write, combinational read
│   ├── synthesis.tcl                          # Yosys synthesis script (timing optimised)
│   ├── synthesis_area_opt.tcl                 # Yosys synthesis script (area optimised)
│   ├── synth_netlist.v                        # Gate-level netlist (timing optimised)
│   ├── synth_netlist_delay_opt.v              # Gate-level netlist (delay optimised)
│   ├── synth_netlistarea_carry_adder.v        # Gate-level netlist (area optimised)
│   ├── synthesis_report.txt                   # Synthesis report (timing optimised)
│   ├── synthesis_report_delay_opt.txt         # Synthesis report (delay optimised)
│   └── synthesis_report_area_carry_adder.txt  # Synthesis report (area optimised)
│
├── pytb/                                      # cocotb testbenches, one folder per module
│   ├── pc/                                    # Program counter testbench
│   ├── Register_file/                         # Register file testbench
│   ├── alu/                                   # ALU testbench
│   ├── alu_decoder/                           # ALU decoder testbench
│   ├── control_wrapper/                       # Control unit testbench
│   ├── sign_extender/                         # Sign extender testbench
│   └── top_wrapper/                           # Full pipeline integration testbench
│       ├── top_wrapper_tb.py                  # cocotb testbench
│       ├── sample_instruction.mem             # BEQ branch hazard test program
│       ├── wave_config_pipeline_hazard_v2.gtkw # GTKWave signal configuration
│       └── assembly_code.txt                  # Annotated assembly for test program
│
└── ta/                                        # Static timing analysis
    ├── sta.tcl                                # OpenSTA run script
    ├── constraints.sdc                        # Timing constraints (10ns clock period)
    ├── timing_report.txt                      # Timing report (timing optimised netlist)
    ├── timing_report_delay_opt.rpt             # Timing report (delay optimised netlist)
    ├── timing_report_area_carry_adder.rpt      # Timing report (area optimised netlist)
    ├── timing_report_v2.txt                   # Updated timing report
    ├── first_timing_report.txt                # Initial timing report
    └── report_comparev1vsv2.md                # Comparison between synthesis strategies
```

---

## Verification

Each module was verified independently using cocotb before pipeline integration. Full pipeline verification uses a targeted assembly program designed to exercise all hazard classes in a single instruction sequence.

**Toolchain:**
- Simulator: Icarus Verilog 12.0 with `-g2012` flag for SystemVerilog support
- Testbench framework: cocotb 2.0.1
- Waveform viewer: GTKWave

**Running testbenches:**

```bash
source ~/cocotb-env/bin/activate
cd pytb/<module_name>
make
gtkwave sim_build/<module_name>.fst
```

**For the full pipeline integration test:**

```bash
cd pytb/top_wrapper
make
gtkwave sim_build/top_wrapper.fst --script=wave_config_pipeline_hazard_v2.gtkw
```

---

## Test Program

### Branch Hazard Test

```
Address   Instruction        Hex          Hazard Scenario
0x1000    add x7, x5, x6    006283B3     Base arithmetic, generates x7
0x1004    beq x7, x7, L5    00738663     Branch: jumps forward 12 bytes to 0x1010
0x1008    sw  x5, 0(x9)     0054A023     Flushed if branch taken
0x100C    sub x8, x5, x6    40628433     Flushed if branch taken
0x1010    and x7, x7, x8    0083F3B3     Target instruction, executes after branch
```

This program verifies that the two instructions after a taken branch are correctly flushed and execution resumes at the branch target address.

---

## Synthesis Results

Two synthesis strategies were compared on the same RTL: area optimized and delay optimized (`abc -D`). Full timing reports and netlists are in the `rtl/` and `ta/` directories.

| Metric | Area Optimized | Delay Optimized |
|---|---|---|
| Standard cells | 5,344 | 8,064 |
| Core area | 65,517.84 um^2 | 71,080.67 um^2 |
| Worst setup slack | +0.05 ns | +1.29 ns |
| Max frequency | ~100.0 MHz | ~114.8 MHz |
| ALU critical path | 12 cascaded `maj3_1` cells (ripple carry) | 0 `maj3_1` cells (restructured, non-ripple) |

The area optimized netlist has minimal margin for post layout timing closure. The delay optimized netlist trades roughly 8.5% more area for over a nanosecond of setup slack headroom and was carried forward for physical implementation. See `result/synthesis_and_timing_results.md` for the full comparison and discussion.

## Key Design Decisions

**Purely combinational Hazard Unit:** All hazard detection and forwarding control logic is combinational, implemented in 61 standard cells with zero flip flops. Forwarding select signals are stable before the clock edge, allowing the Execute stage muxes to settle correctly within the same cycle.

**Branch resolution in Execute stage:** Branch outcome is determined in the Execute stage after ALU comparison, resulting in a 2-cycle branch penalty. Two instructions fetched after the branch are flushed on a taken branch.

**Combinational data memory read:** Data memory uses `assign read_data = data_register[address]` for zero-latency reads, consistent with the single cycle proecessor model.

**Active low synchronous reset:** All sequential elements use active low synchronous reset.