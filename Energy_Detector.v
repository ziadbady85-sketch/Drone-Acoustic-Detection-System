module Energy_Detector (
	input clk , rst , FIR_valid ,
	input signed [7:0] FIR_Sample ,
	output reg [9:0] Energy_Out  ,
	output reg Energy_Valid ) ;

parameter E_scalling = 5 ;

reg signed [7:0] Energy_REG ;
reg [15:0] square ;
reg [19:0] energy ;
reg [3:0] E_counter ;


integer i ;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		Energy_Out   <= 0 ;
		Energy_Valid <= 0 ;
		Energy_REG   <= 0 ;
		square       <= 0 ;
		energy       <= 0 ;
		E_counter    <= 0 ;
		
	end
	else if (FIR_valid) begin
        
        
		Energy_REG <= FIR_Sample ;
		square <= Energy_REG * Energy_REG  ;
		energy <= energy + square ;
		E_counter <= E_counter + 1 ;

        

		if (E_counter == 7) begin
		    Energy_Valid <= 1 ;
		    Energy_Out <= energy >> E_scalling ;
		    E_counter <= 0 ;
		    energy  <= 0 ;
		end

		
	end

	else begin
		Energy_Valid <= 0 ;
	end
end
endmodule 