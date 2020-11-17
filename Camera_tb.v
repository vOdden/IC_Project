
// Testbench for the four pixel camera
//	Sigurd Odden

	`timescale 1 ms / 100 us

module camera_tb;
	
	reg init_in, reset_in, clk_in;
	reg exp_incr_in;
	reg exp_decr_in;
	
	wire NRE1_out, NRE2_out, adc_out;
	wire expose_out, erase_out;
	
	parameter size = 2, exp_size = 5;
	
	
	RE_camera uut(
	.init(init_in),
	.reset(reset_in),
	.clk(clk_in),
	.exp_incr(exp_incr_in),
	.exp_decr(exp_decr_in),
	.NRE1(NRE1_out),
	.NRE2(NRE2_out),
	.expose(expose_out),
	.erase(erase_out),
	.adc(adc_out)
	);
	
	always
		#0.5 clk_in = ~clk_in;
	
	initial
		begin	
			clk_in = 1'b0;		   	//Reset clock and define initial values
			reset_in = 1'b0;							  
			init_in = 1'b0;
			exp_incr_in = 1'b0;
			exp_decr_in = 1'b0;
			#1; reset_in = 1'b1;	//Reset is active-high
			#1; reset_in = 1'b0;		
			#1; exp_incr_in = 1'b1;
			#10; exp_incr_in = 1'b0;
			#1; init_in = 1'b1;
			#1; init_in = 1'b0;
			#40;
			$finish;				//$finish to stop the simulation after the 40ms delay
		end
	
	initial
		begin
			  $monitor("time = %2d, clk_in =%b, init_in=%b, reset_in=%b, exp_incr_in=%b, exp_decr_in=%b, NRE1_out=%b, NRE2_out=%b, expose_out=%b, erase_out=%b, adc_out= %b, exp_time= %d, exp_counter = %d, adc_read = %d", $time,clk_in,init_in,reset_in,exp_incr_in,exp_decr_in,NRE1_out,NRE2_out,expose_out,erase_out,adc_out,uut.exp_time, uut.exp_counter, uut.adc_read);
		end
	
		
		
		


endmodule




