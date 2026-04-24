# SRAM 6T Full Bitcell (bitcell_6t_full)

## Introduction

The **bitcell_6t_full** is a complete SRAM memory cell including not only the traditional 6T bitcell but also all necessary peripheral circuits for read and write operations:

- **6T Bitcell** (data storage)
- **Precharge / Equalize** (precharge bitlines before read)
- **Write Driver** (force data onto bitlines)
- **Sense Amplifier** (amplify small differential voltage during read)

This full bitcell can be used as a building block for larger SRAM arrays.

<img width="511" height="807" alt="image" src="https://github.com/user-attachments/assets/2b9e5001-3b9f-419a-8b0d-a5bc56115dda" />



## Structure

The block consists of:

| Block | Function |
|-------|----------|
| 6T Bitcell | Stores 1 bit (Q, QB) using cross-coupled inverters |
| Precharge | Pulls BL and BLB to VDD before read |
| Write Driver | Drives BL/BLB to 0 or VDD during write |
| Sense Amplifier | Detects small voltage difference between BL and BLB and outputs digital Data_out |

All blocks share the same BL, BLB, WL, and control signals.

---
## Connection Diagram
Inputs:

WL (Word Line)

Data_in (write data)

Sense (enable sense amplifier)

write (enable write driver)

read (enable read output)

Pre_charge (enable precharge)

Outputs:

Data_out (read data)

BL, BLB (bitlines, internal)

Q, QB (internal storage nodes)

Power:

VDD (1.8V for periphery)

VDD2 (0.9V for bitcell)

GND

---

## Basic Operation

| Mode | WL | Pre_charge | write | read | Sense | Result |
|------|----|-------------|-------|------|-------|--------|
| Hold | 0 | 0 | 0 | 0 | 0 | Data retained in bitcell |
| Write | 1 | 0 | 1 | 0 | 0 | Write Driver forces BL/BLB → bitcell updated |
| Read | 1 | 0 | 0 | 1 | 1 | Bitlines precharged, then sense amp enabled → Data_out valid |

---

## Design Flow (Sky130)

### 1. Schematic (xschem)

Schematic includes:
- 6T bitcell (M1..M6)
- Precharge NMOS (M10, M11)
- Write Driver NMOS (M19)
- Sense Amplifier (M9, M12, M13, M14, M15, M16, M17)
- Read output buffer (M18, M21, M23, M24)

<img width="604" height="753" alt="image" src="https://github.com/user-attachments/assets/d4e86786-f7aa-4e6b-9c35-4a68e7bdbfaf" />


### 2. Testbench Schematic (ngspice)

<img width="819" height="753" alt="image" src="https://github.com/user-attachments/assets/067606cd-87a9-48eb-a0bd-8b522adf9d3a" />


Create `tb_bitcell_6t_full.sch` with:

- Pulse sources for WL, pre_charge, sense, write, read, data_in
- .ic V(BL)=0 V(BLB)=0
- .tran 0.1n 200n

Run simulation and plot all internal nodes.

<img width="975" height="496" alt="image" src="https://github.com/user-attachments/assets/225d23e2-1810-4404-8b6c-d331e0eef870" />


### 3. Create Symbol (xschem)

From schematic → Insert Symbol → `bitcell_6t_full.sym`

Pins:
WL, Data_in, Sense, BL, Q, QB, VDD, GND, VDD2, Pre_charge, Data_out, BLB, write, read

Re-run testbench using symbol to verify functionality.

<img width="915" height="749" alt="image" src="https://github.com/user-attachments/assets/a73ee0c0-6f7c-4799-bbdd-a585551407a8" />


<img width="975" height="496" alt="image" src="https://github.com/user-attachments/assets/340d70ad-92ab-473e-b4c9-7b32ff0503ca" />


### 4. Layout and DRC (magic)

Layout is built from sub-blocks:

### Pre_Charge.mag

<img width="702" height="304" alt="image" src="https://github.com/user-attachments/assets/8261c436-56f0-451c-b406-22931576777f" />


<img width="817" height="681" alt="image" src="https://github.com/user-attachments/assets/384e1089-d998-4f21-b758-36d265d87ca6" />


<img width="975" height="475" alt="image" src="https://github.com/user-attachments/assets/a5749f29-79a4-4826-968f-b1bb8fbe11fb" />

---
### Sense_Amplifier.mag

<img width="831" height="688" alt="image" src="https://github.com/user-attachments/assets/b1ccb6db-1f5f-44ee-ba63-e58f3e97ff23" />


<img width="631" height="914" alt="image" src="https://github.com/user-attachments/assets/612d7571-e1f4-4c88-8c9f-1c3fa2407cfd" />


<img width="975" height="759" alt="image" src="https://github.com/user-attachments/assets/39953fb5-d995-444c-8870-6e3609d925a8" />

---
### Sense_Data_out.mag

<img width="605" height="404" alt="image" src="https://github.com/user-attachments/assets/146376d9-188a-4d01-962c-d508ca118a86" />

<img width="830" height="1223" alt="image" src="https://github.com/user-attachments/assets/c42550d4-f946-45d9-864b-ef31fe77741b" />

<img width="975" height="758" alt="image" src="https://github.com/user-attachments/assets/5f9a6438-b480-440a-9175-9a1576f617f6" />

---
### Bitcell_6t_full.mag (top cell)

<img width="303" height="1090" alt="image" src="https://github.com/user-attachments/assets/91e9719d-cebf-416e-bb9e-6603a1ebfae7" />


DRC must pass with zero violations.

### 5. Layout Simulation (ngspice)

extract do local
extract all
ext2spice lvs
ext2spice

Run testbench with `.include bitcell_6t_full_magic.spice`
Compare with schematic simulation.

<img width="967" height="622" alt="image" src="https://github.com/user-attachments/assets/99e064b0-7144-499a-ac2d-c601826ca302" />


### 6. LVS (netgen) – Layout vs Schematic

Prepare two files:

- `bitcell_6t_full_magic.spice` (from magic)
- `bitcell_6t_full_xschem.spice` (from xschem, edited to match pin order and add VDD/GND globals)

Run:

```bash
netgen -batch lvs \
  "bitcell_6t_full_magic.spice bitcell_6t_full" \
  "bitcell_6t_full_xschem.spice bitcell_6t_full" \
  sky130A_setup.tcl \
  lvs_bitcell_full.log
```

<img width="1846" height="848" alt="image" src="https://github.com/user-attachments/assets/1598314d-7377-4503-972f-992b09bdc3b7" />

### ✅ Expected result: Circuits match uniquely.

<img width="805" height="228" alt="image" src="https://github.com/user-attachments/assets/76744634-aeee-436a-9dba-9adb599530e0" />



### 7. Parasitic Extraction (magic)
Extract parasitics for post-layout simulation:

```bash
extract all
ext2spice hierarchy on
ext2spice scale off
ext2spice cthresh 0
ext2spice rthresh 0
ext2spice -d -o postlayout_bitcell_6t_full.spice -f ngspice
```

### 8. Post-Layout Simulation (ngspice)
Run testbench with:

.lib sky130.lib.spice tt

.include postlayout_bitcell_6t_full.spice
Compare waveforms with pre-layout to evaluate parasitic effects.


<img width="975" height="496" alt="image" src="https://github.com/user-attachments/assets/b4d6a0e5-b788-445f-9c9c-b530ca0e1f22" />

### Simulation Waveforms (Expected):

WL pulses when active

Pre_charge high before read

Sense high during read

Write high during write

Data_in follows write pattern

Data_out valid after sense amp enable

BL/BLB show differential development during read


### 9. Export GDS (magic)
After all checks pass: gds write bitcell_full.gds

<img width="607" height="512" alt="image" src="https://github.com/user-attachments/assets/0457c28c-673c-4a5b-91ae-5f0e6a621d2e" />

## Conclusion
The bitcell_6t_full integrates a full SRAM storage cell with all necessary read/write peripherals. It is fully designed, simulated, and verified in Sky130 technology, ready for use in larger memory arrays.
