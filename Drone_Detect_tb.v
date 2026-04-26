module Drone_Detect_tb() ;
	reg clk , rst , sample_valid  ; 
	reg signed [7:0] new_sample  ;
	wire There_is_a_Drone ;

parameter E_scalling = 4 ;
parameter F_scaling = 4 ;
parameter coef_0 = 8'd8 ;
parameter coef_1 = 8'd16 ;
parameter coef_2 = 8'd24 ;
parameter coef_3 = 8'd32 ;
parameter coef_4 = 8'd40 ;
parameter coef_5 = 8'd48 ;
parameter coef_6 = 8'd56 ;
parameter coef_7 = 8'd64 ;
parameter IDLE = 2'b00 ;
parameter COUNTING  = 2'b01 ;
parameter DETECTED = 2'b11 ;
parameter Drone_Energy_min = 50 ;
parameter Drone_Energy_max = 200 ;

Drone_Detect #(.E_scalling(E_scalling),.F_scaling(F_scaling),.Drone_Energy_min(Drone_Energy_min),
	           .Drone_Energy_max(Drone_Energy_max),.IDLE(IDLE),.COUNTING(COUNTING),.DETECTED(DETECTED),
	           .coef_0(coef_0),.coef_1(coef_1),.coef_2(coef_2),.coef_3(coef_3),.coef_4(coef_4),
	           .coef_5(coef_5),.coef_6(coef_6),.coef_7(coef_7))
	      DUT (.clk(clk),.rst(rst),.new_sample(new_sample),.sample_valid(sample_valid),
	      	   .There_is_a_Drone(There_is_a_Drone)) ;

initial begin
	clk = 0 ;
	forever #1 clk = ~clk ;
end

initial begin
    
    $readmemb ("samples_bin.txt" , DUT.M1.B_REG) ;
    

	rst = 1 ;
	new_sample = $random ;
	sample_valid = 0 ;
	@(negedge clk) ;


	rst = 0 ;
	repeat (10) begin
		new_sample = $random ;
		@(negedge clk) ;
	end

    sample_valid = 1 ;
    repeat (300) begin
		new_sample = $random ;
		@(negedge clk) ;
	end

	sample_valid = 0 ;
    repeat (10) begin
		new_sample = $random ;
		@(negedge clk) ;
	end

	sample_valid = 1 ;
    repeat (260) begin
		new_sample = $random ;
		@(negedge clk) ;
	end

	$stop ;
end

endmodule