module Drone_Detect(
	input clk , rst , sample_valid , 
	input signed [7:0] new_sample ,
	output There_is_a_Drone) ;

wire signed [7:0] sample_out ;
wire out_valid ;

wire signed [7:0] FIR_out ;
wire FIR_valid ;
parameter F_scaling = 4 ;
parameter coef_0 = 8'd8 ;
parameter coef_1 = 8'd16 ;
parameter coef_2 = 8'd24 ;
parameter coef_3 = 8'd32 ;
parameter coef_4 = 8'd40 ;
parameter coef_5 = 8'd48 ;
parameter coef_6 = 8'd56 ;
parameter coef_7 = 8'd64 ;

wire [9:0] Energy_Out  ;
wire Energy_Valid ;
parameter E_scalling = 4 ;

parameter IDLE = 2'b00 ;
parameter COUNTING  = 2'b01 ;
parameter DETECTED = 2'b11 ;
parameter Drone_Energy_min = 50 ;
parameter Drone_Energy_max = 200 ;

IN_Buffer M1 (.clk(clk),.rst(rst),.sample_valid(sample_valid),.new_sample(new_sample),
	          .sample_out(sample_out),.out_valid(out_valid)) ;

FIR_Filter #(.F_scaling(F_scaling),.coef_0(coef_0),.coef_1(coef_1),.coef_2(coef_2),.coef_3(coef_3),
	      .coef_4(coef_4),.coef_5(coef_5),.coef_6(coef_6),.coef_7(coef_7))
	  M2 (.clk(clk),.rst(rst),.sample_in(sample_out),.valid_in(out_valid),
	      .FIR_out(FIR_out),.FIR_valid(FIR_valid)) ;

Energy_Detector #(.E_scalling(E_scalling)) M3 (.clk(clk),.rst(rst),.FIR_Sample(FIR_out),.FIR_valid(FIR_valid),
	                                          .Energy_Out(Energy_Out),.Energy_Valid(Energy_Valid)) ;

Decision #(.IDLE(IDLE),.COUNTING(COUNTING),.DETECTED(DETECTED),
	    .Drone_Energy_min(Drone_Energy_min),.Drone_Energy_max(Drone_Energy_max))
       M4 (.clk(clk),.rst(rst),.Energy_Value(Energy_Out),.E_Valid(Energy_Valid),.There_is_a_Drone(There_is_a_Drone)) ;

endmodule