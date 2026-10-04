module Drone_Detect(
	input clk , rst , sample_valid , 
	input signed [7:0] new_sample ,
	output There_is_a_Drone) ;

wire signed [7:0] sample_out ;
wire out_valid ;

wire signed [7:0] FIR_out ;
wire FIR_valid ;
parameter F_scaling = 9 ;
parameter signed [7:0] coef_0 = 8'sd8 ;
parameter signed [7:0] coef_1 = 8'sd16 ;
parameter signed [7:0] coef_2 = 8'sd24 ;
parameter signed [7:0] coef_3 = 8'sd32 ;
parameter signed [7:0] coef_4 = 8'sd40 ;
parameter signed [7:0] coef_5 = 8'sd48 ;
parameter signed [7:0] coef_6 = 8'sd56 ;
parameter signed [7:0] coef_7 = 8'sd64 ;

wire [11:0] Energy_Out  ;
wire Energy_Valid ;
parameter E_scalling = 8 ;
parameter WINDOW_SIZE = 32 ;

wire [5:0] ZCR_Value ;
wire ZCR_Valid ;

wire [31:0] FFT_Value ;
wire FFT_Valid ;

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

IN_Buffer M1 (.clk(clk),.rst(rst),.sample_valid(sample_valid),.new_sample(new_sample),
	          .sample_out(sample_out),.out_valid(out_valid)) ;

FIR_Filter #(.F_scaling(F_scaling),.coef_0(coef_0),.coef_1(coef_1),.coef_2(coef_2),.coef_3(coef_3),
	      .coef_4(coef_4),.coef_5(coef_5),.coef_6(coef_6),.coef_7(coef_7))
	  M2 (.clk(clk),.rst(rst),.sample_in(sample_out),.valid_in(out_valid),
	      .FIR_out(FIR_out),.FIR_valid(FIR_valid)) ;

Energy_Detector #(.E_scalling(E_scalling),.WINDOW_SIZE(WINDOW_SIZE)) M3 (.clk(clk),.rst(rst),.FIR_Sample(FIR_out),.FIR_valid(FIR_valid),
	                                          .Energy_Out(Energy_Out),.Energy_Valid(Energy_Valid)) ;

ZCR #(.WINDOW_SIZE(WINDOW_SIZE)) M4 (.clk(clk),.rst(rst),.FIR_IN(FIR_out),.FIR_Valid(FIR_valid),
	                                .ZCR_Value(ZCR_Value),.ZCR_Valid(ZCR_Valid)) ;

FFT_Detector #(.WINDOW_SIZE(WINDOW_SIZE)) M5 (.clk(clk),.rst(rst),.FIR_IN(FIR_out),.FIR_Valid(FIR_valid),
	                                         .FFT_Value(FFT_Value),.FFT_Valid(FFT_Valid)) ;

Decision #(.IDLE(IDLE),.COUNTING(COUNTING),.DETECTED(DETECTED),
	    .Drone_Energy_min(Drone_Energy_min),.Drone_Energy_max(Drone_Energy_max),
	    .Drone_ZCR_min(Drone_ZCR_min),.Drone_ZCR_max(Drone_ZCR_max),.Drone_FFT_min(Drone_FFT_min),
	    .CONFIRM_WINDOWS(CONFIRM_WINDOWS),.CLEAR_WINDOWS(CLEAR_WINDOWS))
       M6 (.clk(clk),.rst(rst),.Energy_Value(Energy_Out),.E_Valid(Energy_Valid),
           .ZCR_Value(ZCR_Value),.ZCR_Valid(ZCR_Valid),.FFT_Value(FFT_Value),.FFT_Valid(FFT_Valid),
           .There_is_a_Drone(There_is_a_Drone)) ;

endmodule
