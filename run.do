vlib work
vlog Drone_Detect.v Drone_Detect_tb.v
vsim -voptargs=+acc work.Drone_Detect_tb
view wave
add wave -position insertpoint  \
sim:/Drone_Detect_tb/DUT/M1/clk \
sim:/Drone_Detect_tb/DUT/M1/rst \
sim:/Drone_Detect_tb/DUT/M1/sample_valid \
sim:/Drone_Detect_tb/DUT/M1/new_sample \
sim:/Drone_Detect_tb/DUT/M1/sample_out \
sim:/Drone_Detect_tb/DUT/M1/out_valid \
sim:/Drone_Detect_tb/DUT/M1/B_counter \
sim:/Drone_Detect_tb/DUT/M1/B_REG \
sim:/Drone_Detect_tb/DUT/M1/i
add wave -position insertpoint  \
sim:/Drone_Detect_tb/DUT/M2/valid_in \
sim:/Drone_Detect_tb/DUT/M2/sample_in \
sim:/Drone_Detect_tb/DUT/M2/FIR_out \
sim:/Drone_Detect_tb/DUT/M2/FIR_valid \
sim:/Drone_Detect_tb/DUT/M2/F_counter \
sim:/Drone_Detect_tb/DUT/M2/sum \
sim:/Drone_Detect_tb/DUT/M2/F_REG
add wave -position insertpoint  \
sim:/Drone_Detect_tb/DUT/M3/Energy_Out \
sim:/Drone_Detect_tb/DUT/M3/Energy_Valid \
sim:/Drone_Detect_tb/DUT/M3/Energy_REG \
sim:/Drone_Detect_tb/DUT/M3/square \
sim:/Drone_Detect_tb/DUT/M3/energy \
sim:/Drone_Detect_tb/DUT/M3/E_counter
add wave -position insertpoint  \
sim:/Drone_Detect_tb/DUT/M4/E_Valid \
sim:/Drone_Detect_tb/DUT/M4/Energy_Value \
sim:/Drone_Detect_tb/DUT/M4/There_is_a_Drone \
sim:/Drone_Detect_tb/DUT/M4/signal_high \
sim:/Drone_Detect_tb/DUT/M4/counter \
sim:/Drone_Detect_tb/DUT/M4/cs \
sim:/Drone_Detect_tb/DUT/M4/ns
run -all
#quit -sim