
# SRAM Array 4x8

## Introduction

The 4x8 SRAM Array is a static memory matrix with 4 rows (wordlines) and 8 columns (bitlines). This structure is built from the basic memory cells **bitcell_6t** and **bitcell_6t_full** previously designed. Each memory cell stores 1 bit of data. The 4x8 SRAM array allows sequential write and read operations on each data column.



## SRAM Array Structure

The 4x8 SRAM array consists of:

- **4 wordlines (WL1, WL2, WL3, WL4)**: control access to each row of memory cells.
- **8 bitline pairs (BL/BLB)**: transmit read/write data for each column.
- **8 Precharge circuits**: precharge bitlines before reading.
- **8 Sense Amplifiers**: amplify differential signals from bitlines.
- **8 Write Drivers**: control writing data onto bitlines.


## Operating Principle of the SRAM Array 4x8

The 4x8 SRAM array operates based on the coordination of the following control signals:

- **Wordlines (WL1..WL4)**: Each wordline selects one row of memory cells. When WL is high, the access transistors in the memory cells of that row are turned on, connecting the bitlines to the storage nodes Q/QB.

- **Precharge**: Before each read cycle, all bitline pairs are precharged to VDD2 (0.9V) during the first 10ns of each cycle. This ensures that the bitlines are ready for the read operation.

- **Sense Amplifier**: After precharge ends, the sense amplifier is activated to amplify the very small voltage difference between the bitline pair (BL and BLB) into a logic 0 or 1 level.

- **Write Driver**: During the write phase (first 640ns), the write driver writes data from Data_in onto the bitlines, thereby writing into the memory cell selected by WL.

- **Read**: After the write phase (from 640ns onward), read is activated to output data from the bitlines to Data_out through the sense amplifier.

- **Data_in (Input Data)**: This is a digital signal (0V or 1.8V) that provides the data to be written into the SRAM array. Each column has its own Data_in signal (Data_in1..Data_in8). Data is only written into the memory cell when the corresponding Write signal is high. 

The entire operation is synchronized with a cycle time of `T_cycle = 20ns`. Each column operates independently with its own set of Pre_Charge, Sense, Write, and Read signals.


## Design Flow (Sky130)

### 1. Schematic (xschem)

The user draws the schematic `array_4x8.sch` in the xschem software, using the two symbols `bitcell_6t.sym` and `bitcell_6t_full.sym` created in the previous exercise. Refer to the `array_4x8.pdf` file for connection details between blocks.




### Creating the Testbench Symbol (code_show.sym)

Create the `code_show.sym` symbol with testbench content including:

- sky130 library declaration.
- Pulse-type stimulus sources for WL, Pre_Charge, Sense, Write, Read, Data_in.
- Time parameters: `T_cycle = 20n`, `T_row = 160n`, `T_data = 20n`.
- Initial conditions for Q nodes (initial logic 0).
- Simulation configuration: `.tran 0.1n 900n`.




### Schematic Simulation Waveforms

The simulation waveforms include the following signals:

- Write1 Write2 Write3 Write4 Write5 Write6 Write7 Write8
- Read1 Read2 Read3 Read4 Read5 Read6 Read7 Read8
- WL1 WL2 WL3 WL4
- Data_out1 Data_out2 Data_out3 Data_out4 Data_out5 Data_out6 Data_out7 Data_out8

Results show that the SRAM array functions correctly:

- During the first 640ns (write phase): Data from Data_in is written to the corresponding memory cells.
- After 640ns (read phase): Data is read out on Data_out.




### 2. Layout and DRC (magic)

Use the `getcell` command in magic to reuse the two previously designed layout files:

- `bitcell_6t.mag`
- `bitcell_6t_full.mag`

Arrange the memory cells into a 4x8 array. Connect the WL, BL, BLB, VDD, GND, VDD2 lines and the control signals Pre_Charge, Sense, Write, Read.

### List of Layout Ports

A total of 87 ports, including:

- Power supplies: VDD, GND, VDD2
- Wordlines: WL1 WL2 WL3 WL4
- Pre_Charge: 8 signals
- Sense: 8 signals
- Write: 8 signals
- Read: 8 signals
- Data_in: 8 signals
- Data_out: 8 signals
- Q nodes of each memory cell (Q1_1..Q4_8)

## Extracting Netlist from Layout (magic)

Execute the following commands in magic:

```tcl
extract do local
extract all
ext2spice lvs
ext2spice
```

The result creates the file `Array_4x8_non_hiera.spice` containing all layout connection information.

## Testbench for Layout

Create the file `tb_Array_4x8_non_hiera.spice` with the following content:

- `.lib` sky130
- `.include array_4x8.spice`
- VDD1 = 1.8V, VDD2 = 0.9V sources
- Stimulus sources B_wl1..B_wl4, B_charge1..B_charge8, B_sen1..B_sen8, B_write1..B_write8, B_read1..B_read8, B_data1..B_data8 (same as schematic testbench)
- Initial conditions for Q nodes
- Simulation: `.tran 0.1n 900n`

The layout simulation results match the schematic simulation results, confirming correct layout operation.

### 3. LVS (netgen) – Layout vs Schematic

### Preparation

Create the `LVS array_4x8` directory. Copy 2 files into the directory:

- `array_4x8_magic.spice` (from magic)
- `array_4x8_xschem.spice` (from xschem)

### Run LVS

```bash
netgen -batch lvs \
  "Array_4x8_non_hiera_magic.spice Array_4x8_non_hiera" \
  "Array_4x8_non_hiera_xschem.spice Array_4x8_non_hiera" \
  sky130A_setup.tcl \
  lvs_Array_4x8_non_hiera.log
```

### Result

### ✅ Expected result: Circuits match uniquely.

This result confirms that the layout and schematic are completely equivalent in terms of connectivity.

### 4. Parasitic Extraction (magic)
Extract parasitics for post-layout simulation:

```bash
extract all
ext2spice hierarchy on
ext2spice scale off
ext2spice cthresh 0
ext2spice rthresh 0
ext2spice -d -o postlayout_Array_4x8_non_hiera.spice -f ngspice
```

### 8. Post-Layout Simulation (ngspice)
Run testbench with:

.lib sky130.lib.spice tt

.include postlayout_Array_4x8_non_hiera.spice
Compare waveforms with pre-layout to evaluate parasitic effects.

### 9. Export GDS (magic)
After all checks pass: gds write bitcell_full.gds

## Conclusion

The 4x8 SRAM array has been completely designed from schematic to layout, passed LVS verification, and correctly simulated for read/write functionality. This serves as a foundational step for building larger memory blocks in the Sky130 technology.
