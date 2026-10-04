module Drone_Detect_tb() ;
	reg clk , rst , sample_valid  ; 
	reg signed [7:0] new_sample  ;
	wire There_is_a_Drone ;

parameter E_scalling = 8 ;
parameter F_scaling = 9 ;
parameter WINDOW_SIZE = 32 ;
parameter signed [7:0] coef_0 = 8'sd8 ;
parameter signed [7:0] coef_1 = 8'sd16 ;
parameter signed [7:0] coef_2 = 8'sd24 ;
parameter signed [7:0] coef_3 = 8'sd32 ;
parameter signed [7:0] coef_4 = 8'sd40 ;
parameter signed [7:0] coef_5 = 8'sd48 ;
parameter signed [7:0] coef_6 = 8'sd56 ;
parameter signed [7:0] coef_7 = 8'sd64 ;
parameter IDLE = 2'b00 ;
parameter COUNTING  = 2'b01 ;
parameter DETECTED = 2'b11 ;
parameter Drone_Energy_min = 20 ;
parameter Drone_Energy_max = 2000 ;
parameter Drone_ZCR_min = 1 ;
parameter Drone_ZCR_max = 24 ;
parameter Drone_FFT_min = 32'd20000 ;
parameter CONFIRM_WINDOWS = 2 ;
parameter CLEAR_WINDOWS = 2 ;

integer sample_file ;
integer read_status ;
integer sample_index ;
integer generated_index ;
reg [7:0] sample_word ;
reg previous_detection ;

Drone_Detect #(.E_scalling(E_scalling),.F_scaling(F_scaling),.Drone_Energy_min(Drone_Energy_min),
	           .Drone_Energy_max(Drone_Energy_max),.IDLE(IDLE),.COUNTING(COUNTING),.DETECTED(DETECTED),
	           .coef_0(coef_0),.coef_1(coef_1),.coef_2(coef_2),.coef_3(coef_3),.coef_4(coef_4),
	           .coef_5(coef_5),.coef_6(coef_6),.coef_7(coef_7),.WINDOW_SIZE(WINDOW_SIZE),
	           .Drone_ZCR_min(Drone_ZCR_min),.Drone_ZCR_max(Drone_ZCR_max),.Drone_FFT_min(Drone_FFT_min),
	           .CONFIRM_WINDOWS(CONFIRM_WINDOWS),.CLEAR_WINDOWS(CLEAR_WINDOWS))
	      DUT (.clk(clk),.rst(rst),.new_sample(new_sample),.sample_valid(sample_valid),
	      	   .There_is_a_Drone(There_is_a_Drone)) ;

initial begin
	clk = 0 ;
	forever #1 clk = ~clk ;
end

initial begin
	rst = 1 ;
	new_sample = 0 ;
	sample_valid = 0 ;
	previous_detection = 0 ;
	repeat (5) @(negedge clk) ;


	rst = 0 ;
	repeat (2) @(negedge clk) ;

	sample_index = 0 ;
	sample_file = $fopen("samples_bin.txt" , "r") ;

	if (sample_file != 0) begin
		$display("Reading samples_bin.txt") ;
		while (!$feof(sample_file)) begin
			read_status = $fscanf(sample_file , "%b\n" , sample_word) ;
			if (read_status == 1) begin
				sample_valid = 1 ;
				new_sample = sample_word ;
				sample_index = sample_index + 1 ;
				@(negedge clk) ;
			end
		end
		$fclose(sample_file) ;
		$display("Finished driving %0d samples from samples_bin.txt", sample_index) ;
	end
	else begin
		$display("samples_bin.txt was not found. Driving deterministic fallback stimulus.") ;

		sample_valid = 1 ;
		for (generated_index=0 ; generated_index<128 ; generated_index=generated_index+1) begin
			new_sample = 0 ;
			@(negedge clk) ;
		end

		for (generated_index=0 ; generated_index<384 ; generated_index=generated_index+1) begin
			case (generated_index[4:0])
				0,1,2,3,4,5,6,7      : new_sample = 8'sd45 ;
				8,9,10,11,12,13,14,15 : new_sample = 8'sd20 ;
				16,17,18,19,20,21,22,23 : new_sample = -8'sd45 ;
				default : new_sample = -8'sd20 ;
			endcase
			@(negedge clk) ;
		end

		for (generated_index=0 ; generated_index<160 ; generated_index=generated_index+1) begin
			new_sample = 0 ;
			@(negedge clk) ;
		end
	end

	sample_valid = 0 ;
	new_sample = 0 ;
	repeat (100) @(negedge clk) ;

	$display("Simulation complete") ;
	$stop ;
end

always @(posedge clk) begin
	if (DUT.M3.Energy_Valid) begin
		$display("time=%0t Energy_Valid Energy_Value=%0d", $time, DUT.M3.Energy_Out) ;
	end

	if (DUT.M4.ZCR_Valid) begin
		$display("time=%0t ZCR_Valid ZCR_Value=%0d", $time, DUT.M4.ZCR_Value) ;
	end

	if (DUT.M5.FFT_Valid) begin
		$display("time=%0t FFT_Valid FFT_Value=%0d", $time, DUT.M5.FFT_Value) ;
	end

	if (There_is_a_Drone && !previous_detection) begin
		$display("time=%0t Drone detected", $time) ;
	end

	if (!There_is_a_Drone && previous_detection) begin
		$display("time=%0t Detection cleared", $time) ;
	end

	previous_detection <= There_is_a_Drone ;
end

endmodule
