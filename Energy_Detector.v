module Energy_Detector (
	input clk , rst , FIR_valid ,
	input signed [7:0] FIR_Sample ,
	output reg [11:0] Energy_Out  ,
	output reg Energy_Valid ) ;

parameter E_scalling = 8 ;
parameter WINDOW_SIZE = 32 ;

reg [15:0] square ;
reg [20:0] energy ;
reg [5:0] E_counter ;

wire signed [15:0] sample_extended ;
wire [15:0] current_square ;
wire [20:0] next_energy ;

assign sample_extended = FIR_Sample ;
assign current_square = sample_extended * sample_extended ;
assign next_energy = energy + current_square ;


integer i ;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		Energy_Out   <= 0 ;
		Energy_Valid <= 0 ;
		square       <= 0 ;
		energy       <= 0 ;
		E_counter    <= 0 ;
		
	end
	else if (FIR_valid) begin
		square <= current_square ;

		if (E_counter == WINDOW_SIZE-1) begin
		    Energy_Valid <= 1 ;
		    Energy_Out <= next_energy >> E_scalling ;
		    E_counter <= 0 ;
		    energy  <= 0 ;
		end
		else begin
		    Energy_Valid <= 0 ;
		    energy <= next_energy ;
		    E_counter <= E_counter + 1 ;
		end

		
	end

	else begin
		Energy_Valid <= 0 ;
	end
end
endmodule 
