vsim work.my_dds_v1_0_S00_AXI_tb
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/a_rst_n
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/ampls_reg
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/clk
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/clkdiv_reg
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/ctrl_reg
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/deltas_reg
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/i_addrs
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/i_write
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/lngth_reg
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/stat_reg
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/thetas_reg
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/signal
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/valid
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/accmltor

add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/ampls_en
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/ampls_in
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/i_write

add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/THETAS

add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/thetas_en
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/thetas_in
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/i_write

add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/o_dds_signal
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/mult_out

add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/lut/addr
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/deltas_in
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/deltas_en
add wave -noupdate /my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/i_write

add wave -position insertpoint  \
sim:/my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/ampls_reg \
sim:/my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/ampls_reg_dly\
sim:/my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/sin_index \
sim:/my_dds_v1_0_S00_AXI_tb/dut/dds_top_u/u_dds/sin_index_temp


