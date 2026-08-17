# Synthesis and Timing Results

This document summarizes the synthesis exploration and Static Timing Analysis (STA) for the RV32I 5-stage pipelined RISC-V processor core, targeted to the SkyWater 130nm (sky130_fd_sc_hd) standard cell library.

Two synthesis strategies were compared: an Area-Optimized Netlist (ripple-carry ALU architecture) and a Delay-Optimized Netlist (restructured, non-ripple ALU architecture).

## Reproduction Steps

### Logical Synthesis (Yosys)

Synthesis scripts live in the `rtl/` directory.

```bash
cd rtl

# Delay-Optimized Synthesis (maximizes operating frequency)
yosys -c 1-synthesis.tcl

# Area-Optimized Synthesis (minimizes silicon footprint)
yosys -c 2-synthesis_area_opt.tcl
```

`1-synthesis.tcl` runs delay-targeted mapping (`abc -D`, tree balancing, logic restructuring) and produces a higher cell count.

`2-synthesis_area_opt.tcl` runs area-driven standard cell mapping and produces the minimal gate count and cell area.

### Static Timing Analysis (OpenROAD / OpenSTA)

Timing analysis runs through the integrated OpenSTA engine in OpenROAD.

```bash
cd ../ta
/home/ragur/OpenROAD/build/bin/openroad -exit sta.tcl
```

Worst slack was confirmed directly via:

```tcl
report_worst_slack -max
```

## Comparative Benchmark Results

Target clock period: 10.00 ns (100.0 MHz) | Technology: Sky130 HD

| Metric | Area-Optimized Baseline | Delay-Optimized Netlist | Delta / Tradeoff Impact |
|---|---|---|---|
| Total Standard Cells | 5,344 | 8,064 | +2,720 cells (+50.9%) |
| Total Standard Cell Area | 65,517.84 µm² | 71,080.67 µm² | +5,562.83 µm² (+8.5%) |
| Sequential Area | 40,819.15 µm² (62.3%) | 40,819.15 µm² (57.4%) | 0.00 µm² (identical) |
| Combinational Area | 24,698.69 µm² | 30,261.52 µm² | +5,562.83 µm² (+22.5%) |
| ALU Carry Cells (`maj3_1`) | 28 total, 12 chained serially in the critical path | 0 | ripple chain eliminated from critical path |
| Worst-Case Arrival Time | 9.58 ns | (see worst slack below) | not directly comparable |
| Worst Setup Slack | +0.05 ns (verified via traced critical path) | +1.29 ns (verified via `report_worst_slack -max`) | +1.24 ns timing margin |
| Max Operating Frequency (Fmax) | ~100.0 MHz | ~114.8 MHz | +14.8 MHz headroom |

## Engineering and Architectural Discussion

### Critical Path Selection: Reg-to-Reg vs `probe_alu_out`

The output port `probe_alu_out` is an artificial top-level probe pin, added so Yosys does not eliminate execution-pipeline logic as dead code during synthesis. Its associated timing path (path group `clk_v`) includes a virtual board-delay constraint and does not reflect real internal core timing. It was excluded from analysis for this reason.

The register-to-register path (path group `clk`) is the ground-truth metric that determines the operational clock limit of the processor core. All slack and frequency figures above are drawn from this path group only, cross-checked against `report_worst_slack -max` output for the same run.

### Carry Chain Topology: Verified Observations

**Area-optimized run:** The 32-bit ALU addition maps to 28 `sky130_fd_sc_hd__maj3_1` majority cells. Tracing the actual worst-case timing path shows 12 of these `maj3_1` cells chained back-to-back, each contributing serially to arrival time, consistent with a ripple-carry dependency structure. This path closes at 9.58 ns arrival with only +0.05 ns of setup slack.

**Delay-optimized run:** Under the same RTL with a tightened delay target (`abc -D`), the resulting critical path contains zero `maj3_1` cells and achieves +1.29 ns setup slack, a meaningfully more parallel structure than the baseline. The specific replacement topology was not independently traced, so this document describes it as "restructured, non-ripple" rather than asserting a named adder architecture such as carry-lookahead.

### Physical Implementation (PnR) Feasibility

**Area Netlist Risk:** A pre-layout setup slack of +0.05 ns (50 ps) leaves essentially zero margin for physical design. Wire RC parasitics, clock skew, and crosstalk introduced during floorplanning and routing would very likely cause setup timing violations at 100 MHz.

**Delay Netlist Viability:** The +1.29 ns positive slack gives OpenROAD meaningfully more budget to absorb post-CTS clock skew and detailed routing parasitics, which is the basis for carrying this netlist forward into physical implementation.

## Summary

The area-optimized netlist is smaller and lower-power, but its timing margin (+0.05 ns) is too thin to reliably survive real placement and routing. The delay-optimized netlist costs about 8.5% more silicon area and 50.9% more standard cells, but eliminates the serial `maj3_1` ripple-carry chain from the critical path and recovers +1.24 ns of setup slack, reaching ~114.8 MHz. For this reason, the delay-optimized netlist is the stronger candidate for physical implementation, though the specific replacement carry architecture has not been structurally confirmed beyond "non-ripple, more parallel."