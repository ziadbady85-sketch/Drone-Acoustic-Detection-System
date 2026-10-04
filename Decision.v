module Decision (
	input clk , rst , E_Valid , ZCR_Valid , FFT_Valid ,
	input [11:0] Energy_Value ,
	input [5:0] ZCR_Value ,
	input [31:0] FFT_Value ,
	output There_is_a_Drone) ;


wire  feature_valid ;
wire  energy_condition ;
wire  zcr_condition ;
wire  fft_condition ;
wire  signal_high ;
reg [3:0] counter ;
reg [1:0] cs , ns ;

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

assign feature_valid = E_Valid && ZCR_Valid && FFT_Valid ;
assign energy_condition = (Energy_Value >= Drone_Energy_min && Energy_Value <= Drone_Energy_max) ;
assign zcr_condition = (ZCR_Value >= Drone_ZCR_min && ZCR_Value <= Drone_ZCR_max) ;
assign fft_condition = (FFT_Value >= Drone_FFT_min) ;
assign signal_high = (feature_valid && energy_condition && zcr_condition && fft_condition) ? 1 : 0 ;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		cs <= IDLE ;
		
	end
	else  begin
		cs <= ns ;
	end
end

always @(*) begin
	case (cs) 
	  IDLE     : ns = (signal_high)? COUNTING : IDLE ;
	  COUNTING : ns = (signal_high && counter == CONFIRM_WINDOWS-1)? DETECTED : 
	                  (feature_valid && !signal_high)? IDLE : COUNTING ;
	  DETECTED : ns = (feature_valid && !signal_high && counter == CLEAR_WINDOWS-1)? IDLE : DETECTED ;
	  default  : ns = IDLE ; 
	endcase                
end

always @(posedge clk or posedge rst) begin
	if (rst) 	
		counter     <= 0 ;
	
	else if (feature_valid)  begin
		case (cs)
		  IDLE :
		    if (signal_high)
		    	counter <= 1 ;
		    else
		    	counter <= 0 ;

		  COUNTING :
		    if (signal_high) begin
          	counter <= counter + 1 ;
          end

          else begin
          	counter <= 0 ;
          end

          DETECTED :

          if (!signal_high) begin
          	counter <= counter + 1 ;
          end

          else begin
          	counter <= 0 ;
          end
            
		  default : 
		    counter <= 0 ;
		endcase    

	end

	else if (cs != ns)  
        counter <= 0 ;

end

assign There_is_a_Drone = (cs == DETECTED) ;

endmodule 
