module ZCR (
	input clk , rst , FIR_Valid ,
	input signed [7:0] FIR_IN ,
	output reg [5:0] ZCR_Value ,
	output reg ZCR_Valid );

parameter WINDOW_SIZE = 32 ;

reg signed [7:0] previous_sample;
reg [5:0] crossing_counter;
reg [5:0] sample_counter;

wire crossing_detected ;
wire [5:0] next_crossing_counter ;

assign crossing_detected = (FIR_IN[7] != previous_sample[7] &&
	                        FIR_IN != 0 && previous_sample != 0) ;
assign next_crossing_counter = crossing_counter + crossing_detected ;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		ZCR_Valid <= 0 ;
		ZCR_Value <= 0 ;
		previous_sample <= 0 ;
		crossing_counter <= 0 ;
		sample_counter <= 0 ;
	end
	else if (FIR_Valid) begin
		previous_sample <= FIR_IN ;

		if (sample_counter == WINDOW_SIZE-1) begin
			ZCR_Valid <= 1 ;
			ZCR_Value <= next_crossing_counter ;
			crossing_counter <= 0 ;
			sample_counter <= 0   ;
		end

		else begin
			ZCR_Valid <= 0 ;
			crossing_counter <= next_crossing_counter ;
			sample_counter <= sample_counter + 1 ;
		end
	end

	else begin
		ZCR_Valid <= 0 ;
	end
end


endmodule
