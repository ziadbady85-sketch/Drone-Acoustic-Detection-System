module Decision (
	input clk , rst , E_Valid ,
	input [9:0] Energy_Value ,
	output There_is_a_Drone) ;


wire  signal_high ;
reg [3:0] counter ;
reg [1:0] cs , ns ;

parameter IDLE = 2'b00 ;
parameter COUNTING  = 2'b01 ;
parameter DETECTED = 2'b11 ;

parameter Drone_Energy_min = 50 ;
parameter Drone_Energy_max = 200 ;

assign signal_high = (E_Valid && (Energy_Value > Drone_Energy_min && Energy_Value < Drone_Energy_max) )? 1 : 0 ;

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
	  COUNTING : ns = (signal_high && counter == 4)? DETECTED : 
	                  (!signal_high)? IDLE : COUNTING ;
	  DETECTED : ns = (!signal_high && counter == 2)? IDLE : DETECTED ;
	  default  : ns = IDLE ; 
	endcase                
end

always @(posedge clk or posedge rst) begin
	if (rst) 	
		counter     <= 0 ;
	
	else if (E_Valid)  begin
		case (cs)
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