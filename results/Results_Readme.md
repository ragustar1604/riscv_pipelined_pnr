# Synthesis and Timing Results

This document summarizes the synthesis exploration and Static Timing Analysis (STA) for the 32I 5 Stage pipelined RISC V processor core, targeted to the SkyWater 130nm (sky130_fd_sc_hd) standard cell library.

Two synthesis strategies were compared: an Area Optimized Netlist (ripple carry ALU architecture) and a Delay Optimized Netlist (parallel lookahead tree architecture).

## Reproduction Steps

### Logical Synthesis (Yosys)

Synthesis scripts live in the `rtl/` directory.

```bash
cd rtl

# Delay Optimized Synthesis (maximizes operating frequency)
yosys -c 1-synthesis.tcl

# Area Optimized Synthesis (minimizes silicon footprint)
yosys -c 2-synthesis_area_opt.tcl
```

`1-synthesis.tcl` runs  delay targeted mapping (abc -D, tree balancing, logic restructuring) and produces a higher cell count.

`2-synthesis_area_opt.tcl` runs area driven standard cell mapping and produces the minimal gate count and cell area.

### Static Timing Analysis (OpenROAD / OpenSTA)

Timing analysis runs through the integrated OpenSTA engine in OpenROAD.

```bash
cd ../ta
/home/ragur/OpenROAD/build/bin/openroad -exit sta.tcl
```

## Comparative Benchmark Results

Target clock period: 10.00 ns (100.0 MHz) | Technology: Sky130 HD

| Metric | Area Optimized Baseline | Delay Optimized Netlist | Delta / Tradeoff Impact |
|---|---|---|---|
| Total Standard Cells | 5,344 | 8,064 | +2,720 cells (+50.9%) |
| Flip Flops (Sequential Elements) | 1,511 (455 dfxtp_1 + 1,056 edfxtp_1) | 1,511 (455 dfxtp_1 + 1,056 edfxtp_1) | 0 (identical architectural state) |
| Combinational Logic Cells | 3,833 | 6,553 | +2,720 gates (+70.9%) |
| Total Standard Cell Area | 65,517.84 um^2 | 71,080.67 um^2 | +5,562.83 um^2 (+8.5%) |
| Sequential Area | 40,819.15 um^2 (62.3%) | 40,819.15 um^2 (57.4%) | 0.00 um^2 (identical) |
| Combinational Area | 24,698.69 um^2 | 30,261.52 um^2 | +5,562.83 um^2 (+22.5%) |
| ALU Carry Architecture | 28 x maj3_1 (ripple carry) | 0 x maj3_1 (parallel tree) | serial ripple vs parallel lookahead |
| Reg to Reg Arrival Time | 9.58 ns | 8.47 ns | 1.11 ns faster |
| Reg to Reg Slack (@ 100 MHz) | +0.05 ns (50 ps) | +1.12 ns (1,120 ps) | +1.07 ns timing margin |
| Max Operating Frequency (Fmax) | 100.50 MHz | 112.61 MHz | +12.11 MHz headroom |

## Engineering and Architectural Discussion

### Critical Path Selection: Reg to Reg vs probe_alu_out

The output port `probe_alu_out` is an artificial top level probe pin, added so Yosys does not eliminate the execution pipeline logic as dead code during synthesis.

The output path group (`clk_v`) includes a virtual board delay constraint (negative 2.00 ns) and does not reflect real internal core timing.

The register to register path (path group `clk`) is the sole ground truth metric that determines the operational clock limit of the processor core.

### Carry Chain Topology: maj3_1 vs Parallel Prefix Trees

**Area Strategy (O(N) serial ripple):** Maps the 32 bit ALU addition directly to 28 cascaded `sky130_fd_sc_hd__maj3_1` majority standard cells. This minimizes silicon area, but the serial carry cascade takes about 6.0 ns of propagation time, pushing arrival time to 9.58 ns and leaves only a  narrow setup slack of only +0.05 ns.

**Delay Strategy (O(log N) tree restructuring):** ABC unrolls the carry recurrence relations into logarithmic carry lookahead structures built from fast primitive NAND, NOR, and AOI gates. This eliminates all `maj3_1` cells entirely and accelerates the critical path by 1.11 ns.

### Physical Implementation (PnR) Feasibility

**Area Netlist Risk:** A pre layout setup slack of +0.05 ns (50 ps) leaves essentially zero margin for physical design. Wire RC parasitics, clock skew, and crosstalk introduced during floorplanning and routing will very likely cause setup timing violations at 100 MHz.

**Delay Netlist Viability:** The +1.12 ns positive slack gives OpenROAD enough budget to absorb post CTS clock skew and detailed routing parasitics, which is why this netlist was selected for physical place and route.

## Summary

The area optimized netlist is smaller and lower power, but its timing margin is too thin to survive real placement and routing. The delay optimized netlist costs about 8.5% more silicon area, but its parallel lookahead carry structure buys back over a nanosecond of slack, which is the difference between a design that closes timing on silicon and one that does not. For this reason, the delay optimized netlist was carried forward into physical implementation.
