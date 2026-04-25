#!/usr/bin/openroad
# ==============================================
# OpenROAD Complete Flow - SRAM Tile (V5 - Database API)
# ==============================================

puts "   >>> Starting OpenROAD Full Flow: SRAM Tile <<<"

# --- 1. Load Tech & Design ---
set ciel_version "0fe599b2afb6708d281543108caf8310912f54af"
set ::env(PDK_ROOT) "/openlane/pdks/$ciel_version"
set ::env(PDK) "sky130A"
set pdk_dir "$::env(PDK_ROOT)/$::env(PDK)"

read_lef     "$pdk_dir/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
read_lef     "$pdk_dir/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
read_liberty "$pdk_dir/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

if {[file exists "SRAM_4x8_fixed.lef"]} {
    read_lef SRAM_4x8_fixed.lef
    puts "✓ Loaded SRAM LEF"
}

read_verilog top_sram_tile_synth.v
link_design top_sram_tile

# --- 2. Floorplan ---
create_clock -name clk -period 10 [get_ports clk]
initialize_floorplan -die_area {0 0 65 65} -core_area {5 5 60 60} -site unithd

make_tracks li1  -x_offset 0.17 -x_pitch 0.34 -y_offset 0.17 -y_pitch 0.34
make_tracks met1 -x_offset 0.17 -x_pitch 0.34 -y_offset 0.17 -y_pitch 0.34
make_tracks met2 -x_offset 0.23 -x_pitch 0.46 -y_offset 0.23 -y_pitch 0.46
make_tracks met3 -x_offset 0.34 -x_pitch 0.68 -y_offset 0.34 -y_pitch 0.68
make_tracks met4 -x_offset 0.46 -x_pitch 0.92 -y_offset 0.46 -y_pitch 0.92

# --- 3. Placement & Pins ---
place_cell -inst_name u_sram -origin {8.125 11.25} -orient R0 -status FIRM
place_pins -hor_layers {met3} -ver_layers {met4} -corner_avoidance 15 -min_distance 3

tapcell -distance 14 -tapcell_master sky130_fd_sc_hd__tapvpwrvgnd_1
global_placement -density 0.45
detailed_placement

# --- 4. CTS ---
set_wire_rc -layer met2
clock_tree_synthesis -root_buf sky130_fd_sc_hd__clkbuf_1 -buf_list sky130_fd_sc_hd__clkbuf_1
detailed_placement

# --- 5. FIXING NET TYPE (THE CRITICAL FIX) ---
puts "\n--- Fixing Power Nets for TritonRoute ---"
set db_block [[[ord::get_db] getChip] getBlock]
foreach net_name {one_ zero_} {
    set db_net [$db_block findNet $net_name]
    if {$db_net != "NULL"} {
        $db_net setSigType SIGNAL
        puts "✓ Converted $net_name to SIGNAL"
    }
}

# --- 6. ROUTING ---
puts "\n--- Starting Routing ---"
set_global_routing_layer_adjustment met1 0.5
set_global_routing_layer_adjustment met2 0.5
global_route
detailed_route -output_drc drc_report.rpt -verbose 1

# --- 7. Save ---
write_db  top_sram_tile_final.odb
write_def top_sram_tile_final.def
puts "✓ Design saved. Use 'openroad -gui top_sram_tile_final.def' to view."
exit
