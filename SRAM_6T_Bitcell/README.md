
# SRAM 6T Bitcell

# Introduction

The **SRAM 6T bitcell** is a fundamental static memory cell widely used in the design of cache memory, register files, and systems requiring high speed and low power consumption.

**Structure**

The memory cell consists of **6 transistors**:

| Transistor | Type | Model in Sky130 | Role |
|------------|------|-------------------|-------|
| M1 | NMOS | `sky130_fd_pr__pfet_01v8` | Pull-up (pulls Q low) |
| M2 | PMOS | `sky130_fd_pr__pfet_01v8` | Pull-up (pulls QB high) |
| M3 | PMOS | `sky130_fd_pr__nfet_01v8` | Pull-down (pulls Q high) |
| M4 | NMOS | `sky130_fd_pr__nfet_01v8` | Pull-down (pulls QB low) |
| M5 | NMOS | `sky130_fd_pr__nfet_01v8` | Access (BL → Q), gate = WL |
| M6 | NMOS | `sky130_fd_pr__nfet_01v8` | Access (BLB → QB), gate = WL |

Two cross-coupled inverters form a **latch** that stores one bit of data on two nodes **Q** and **QB** (always opposite: Q=1 then QB=0 and vice versa).

### Connection Diagram

- **M1 + M3** form the left inverter: input is QB, output is Q
- **M2 + M4** form the right inverter: input is Q, output is QB
- **M5**: connects BL to Q, controlled by WL
- **M6**: connects BLB to QB, controlled by WL

### Basic Operation

| Mode | WL | BL / BLB | Result |
|------|----|-----------|--------|
| **Hold** | 0 | Don't care | Retains data via latch, no clock needed |
| **Write** | 1 | BL = data, BLB = not data | Forces data into Q/QB |
| **Read** | 1 | Precharge BL = BLB = 0.9 | Creates small differential, sense amplifier reads |

- **Write "1"**: BL=1, BLB=0 → Q=1, QB=0
- **Write "0"**: BL=0, BLB=1 → Q=0, QB=1
- **Read**: The "0" node slightly discharges its corresponding bitline → sense amp compares BL and BLB

### Strengths

- Static, no refresh required
- Fast read/write
- Low power consumption in hold mode
- Noise immunity due to differential structure (BL/BLB)

# Design Flow

Complete design flow from schematic to GDS for the SRAM 6T bitcell using **Sky130** technology.

### 1. Schematic (xschem)

Draw the schematic in xschem with 6 transistors according to the netlist:

```
XM1 Q QB GND GND sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1     (M1 - NMOS)
XM2 QB Q VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1     (M2 - PMOS)
XM3 Q QB VDD VDD sky130_fd_pr__nfet_01v8 L=0.15 W=0.5 nf=1   (M3 - PMOS)
XM4 QB Q GND GND sky130_fd_pr__nfet_01v8 L=0.15 W=0.5 nf=1   (M4 - NMOS)
XM5 BL WL Q GND sky130_fd_pr__nfet_01v8 L=0.15 W=0.5 nf=1    (M5 - NMOS access)
XM6 BLB WL QB GND sky130_fd_pr__nfet_01v8 L=0.15 W=0.5 nf=1  (M6 - NMOS access)
```

### 2. Testbench Schematic (ngspice)

Create a testbench with stimuli:

```spice
Vin1 WL GND DC 0 pulse(0 1.8 0n 100p 100p 10n 20n)
Vin2 BL GND DC 0 pulse(0 1.8 0n 100p 100p 4.5n 10n)
Vin3 BLB GND DC 0 pulse(0 1.8 5n 100p 100p 4.5n 10n)
CBL BL 0 20f
CBLB BLB 0 20f
```

Set initial condition: `.ic V(Q)=1.8 V(QB)=0`

Run simulation `.tran 10p 100n` and plot waveforms.

### 3. Create Symbol (xschem)

From the drawn schematic, create a symbol to reuse in larger designs (e.g., SRAM 4x8). Then re-run the testbench with the symbol to verify correct operation.

### 4. Layout and DRC (magic)

Draw the layout in magic using layers:

- **n/p diffusion**, **poly**, **metal1**, **contacts**, **wells**

Strictly follow Sky130 design rules. Run DRC to check for violations.

### 5. Layout Simulation (ngspice)

Extract netlist from layout:

```tcl
extract all
ext2spice hierarchy on
ext2spice scale off
ext2spice cthresh 0
ext2spice rthresh 0
ext2spice -d -o Sram_6T_bitcell_magic.spice -f ngspice
```

Run the testbench with the extracted `.spice` file and compare results with the schematic.

### 6. LVS (netgen) - Layout vs Schematic

Create two files:

- `Sram_6T_bitcell_magic.spice` (from magic)
- `Sram_6T_bitcell_xschem.spice` (from xschem, only the `.subckt` part)

Run LVS:

```bash
netgen -batch lvs \
  "Sram_6T_bitcell_magic.spice Sram_6T_bitcell" \
  "Sram_6T_bitcell_xschem.spice Sram_6T_bitcell" \
  sky130A_setup.tcl \
  lvs_buffer.log
```

The result must report `Netlists match successfully`.

### 7. Parasitic Extraction (magic)

Extract parasitic capacitances and resistances:

```tcl
extract all
ext2spice hierarchy on
ext2spice scale off
ext2spice cthresh 0
ext2spice rthresh 0
ext2spice -d -o postlayout_bitcell.spice -f ngspice
```

The file `postlayout_bitcell.spice` contains parasitic values (C0..C20).

### 8. Post-Layout Simulation (ngspice)

Re-run the testbench with the `postlayout_bitcell.spice` file:

```spice
.lib sky130.lib.spice tt
.include postlayout_bitcell.spice
```

Compare results with pre-layout to evaluate the impact of parasitics.

### 9. Export GDS (magic)

After all steps are correct, export the GDS file for fabrication or storage:

```tcl
gds write Sram_6T_bitcell.gds
```

---

## Summary

| Step | Tool | Output |
|------|---------|--------|
| Schematic | xschem | `.sch` |
| Testbench schematic | ngspice | Waveforms |
| Symbol | xschem | `.sym` |
| Layout | magic | `.mag` |
| DRC | magic | Error report |
| Extract layout spice | magic | `.spice` |
| LVS | netgen | `lvs_buffer.log` |
| Parasitic extraction | magic | `postlayout_bitcell.spice` |
| Post-layout simulation | ngspice | Waveforms (with parasitics) |
| GDS | magic | `.gds` |

---
