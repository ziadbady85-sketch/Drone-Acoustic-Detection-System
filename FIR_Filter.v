module FIR_Filter (
	input clk , rst , valid_in , 
	input signed [7:0] sample_in  ,
	output reg signed [7:0] FIR_out ,
	output reg FIR_valid ) ;


reg [3:0] F_counter ;
reg [18:0] sum ;
reg signed [7:0] F_REG [0:7] ;

parameter F_scaling = 5 ;

parameter coef_0 = 8'd8 ;
parameter coef_1 = 8'd16 ;
parameter coef_2 = 8'd24 ;
parameter coef_3 = 8'd32 ;
parameter coef_4 = 8'd40 ;
parameter coef_5 = 8'd48 ;
parameter coef_6 = 8'd56 ;
parameter coef_7 = 8'd64 ;


integer i ;
always @(posedge clk or posedge rst) begin
	if (rst) begin
	    F_counter <= 0 ;
		sum       <= 0 ;
		FIR_valid <= 0 ;
        FIR_out   <= 0 ;
		for (i=0 ; i<8 ; i=i+1) begin
		     F_REG[i]   <= 0 ;
		end
		
	end

	else if (valid_in) begin
	    for (i=7 ; i>=1 ; i=i-1) begin
	       	F_REG[i] <= F_REG[i-1] ;

		end

		F_REG[0] <= sample_in ; 

		sum <= (coef_0 * F_REG[0]) + 
		       (coef_1 * F_REG[1]) +
		       (coef_2 * F_REG[2]) +
		       (coef_3 * F_REG[3]) +
		       (coef_4 * F_REG[4]) +
		       (coef_5 * F_REG[5]) +
		       (coef_6 * F_REG[6]) +
		       (coef_7 * F_REG[7]) ;

		      

		FIR_out <= sum >> F_scaling ; 

		FIR_valid <= 1 ;

		      
	end
	else begin
		FIR_valid <= 0 ;
		
	end
end

endmodule