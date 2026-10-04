module FFT_Detector (
	input clk ,
	input rst ,
	input FIR_Valid ,
	input signed [7:0] FIR_IN ,

	output reg [31:0] FFT_Value ,
	output reg FFT_Valid
);

parameter WINDOW_SIZE = 32 ;
parameter signed [15:0] COEF = 16'sd251 ;
parameter Q_SHIFT = 7 ;

reg signed [17:0] s0 ;
reg signed [17:0] s1 ;
reg signed [17:0] s2 ;

reg [5:0] sample_counter ;

reg signed [47:0] power ;

wire signed [35:0] coef_mult_s1 ;
wire signed [17:0] next_s0 ;
wire signed [17:0] next_s1 ;
wire signed [17:0] next_s2 ;
wire signed [47:0] final_power ;
wire signed [47:0] next_s1_power ;
wire signed [47:0] next_s2_power ;
wire signed [35:0] coef_mult_next_s1 ;
wire signed [35:0] coef_next_s1_scaled ;
wire signed [35:0] next_s2_extended ;
wire signed [47:0] cross_power ;

assign coef_mult_s1 = COEF * s1 ;
assign next_s0 = FIR_IN + (coef_mult_s1 >>> Q_SHIFT) - s2 ;
assign next_s1 = next_s0 ;
assign next_s2 = s1 ;
assign next_s1_power = next_s1 * next_s1 ;
assign next_s2_power = next_s2 * next_s2 ;
assign coef_mult_next_s1 = COEF * next_s1 ;
assign coef_next_s1_scaled = coef_mult_next_s1 >>> Q_SHIFT ;
assign next_s2_extended = next_s2 ;
assign cross_power = coef_next_s1_scaled * next_s2_extended ;
assign final_power = next_s1_power + next_s2_power - cross_power ;

always @(posedge clk or posedge rst) begin

	if (rst) begin

		s0 <= 0 ;
		s1 <= 0 ;
		s2 <= 0 ;

		sample_counter <= 0 ;

		FFT_Value <= 0 ;
		FFT_Valid <= 0 ;

		power <= 0 ;

	end

	else if (FIR_Valid) begin

		s0 <= next_s0 ;
		s2 <= s1 ;
		s1 <= next_s0 ;

		if (sample_counter == WINDOW_SIZE-1) begin

			power <= final_power ;

			if (final_power < 0)
				FFT_Value <= 0 ;
			else if (final_power > 32'hFFFFFFFF)
				FFT_Value <= 32'hFFFFFFFF ;
			else
				FFT_Value <= final_power[31:0] ;

			FFT_Valid <= 1 ;

			sample_counter <= 0 ;

			s0 <= 0 ;
			s1 <= 0 ;
			s2 <= 0 ;

		end

		else begin
			FFT_Valid <= 0 ;
			sample_counter <= sample_counter + 1 ;
		end

	end

	else begin
		FFT_Valid <= 0 ;
	end

end

endmodule
