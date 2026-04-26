module IN_Buffer (
	input clk , rst , sample_valid , 
	input signed [7:0] new_sample , 
	output reg signed [7:0] sample_out ,
	output reg out_valid) ;

reg [3:0] B_counter ;
reg signed [7:0] B_REG [0:7] ;
integer i ;
always @(posedge clk or posedge rst) begin
  	if (rst) begin
  	  out_valid  <= 0  ;
  		B_counter  <= 0  ;
  		sample_out <= 0 ;
  		for (i=0 ; i<8 ; i=i+1) begin
           B_REG[i] <= 0 ;
  		     
  		end
  		
  	end
  	else if (sample_valid) begin
      for (i=7 ; i>=1 ; i=i-1) begin
           
           B_REG[i] <= B_REG[i-1]  ;
 
  		end
      B_REG[0] <= new_sample  ;
  		B_counter <= B_counter + 1 ;
  		sample_out <= B_REG[0] ;

  		if (B_counter==7) begin
  			out_valid  <= 1 ;
  			B_counter  <= 0 ;
  		end
  		
  	end

  	else begin
  		out_valid <= 0  ;
  		B_counter <= 0  ;
  	end
  end  

  endmodule