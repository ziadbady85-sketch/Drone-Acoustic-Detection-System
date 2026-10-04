module FIR_Filter (
	input clk , rst , valid_in , 
	input signed [7:0] sample_in  ,
	output reg signed [7:0] FIR_out ,
	output reg FIR_valid ) ;


reg [3:0] F_counter ;
reg signed [18:0] sum ;
reg signed [7:0] F_REG [0:7] ;

parameter F_scaling = 9 ;

parameter signed [7:0] coef_0 = 8'sd8 ;
parameter signed [7:0] coef_1 = 8'sd16 ;
parameter signed [7:0] coef_2 = 8'sd24 ;
parameter signed [7:0] coef_3 = 8'sd32 ;
parameter signed [7:0] coef_4 = 8'sd40 ;
parameter signed [7:0] coef_5 = 8'sd48 ;
parameter signed [7:0] coef_6 = 8'sd56 ;
parameter signed [7:0] coef_7 = 8'sd64 ;

wire signed [18:0] weighted_sum ;
wire signed [18:0] scaled_sum ;
wire signed [18:0] product_0 ;
wire signed [18:0] product_1 ;
wire signed [18:0] product_2 ;
wire signed [18:0] product_3 ;
wire signed [18:0] product_4 ;
wire signed [18:0] product_5 ;
wire signed [18:0] product_6 ;
wire signed [18:0] product_7 ;

assign product_0 = coef_0 * sample_in ;
assign product_1 = coef_1 * F_REG[0] ;
assign product_2 = coef_2 * F_REG[1] ;
assign product_3 = coef_3 * F_REG[2] ;
assign product_4 = coef_4 * F_REG[3] ;
assign product_5 = coef_5 * F_REG[4] ;
assign product_6 = coef_6 * F_REG[5] ;
assign product_7 = coef_7 * F_REG[6] ;

assign weighted_sum = product_0 + product_1 + product_2 + product_3 +
                      product_4 + product_5 + product_6 + product_7 ;

assign scaled_sum = weighted_sum >>> F_scaling ;

function signed [7:0] saturate_8 ;
	input signed [18:0] value ;
	begin
		if (value > 127)
			saturate_8 = 8'sd127 ;
		else if (value < -128)
			saturate_8 = 8'sh80 ;
		else
			saturate_8 = value[7:0] ;
	end
endfunction


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

		sum <= weighted_sum ;
		FIR_out <= saturate_8(scaled_sum) ; 

		FIR_valid <= 1 ;

		      
	end
	else begin
		FIR_valid <= 0 ;
		
	end
end

endmodule
