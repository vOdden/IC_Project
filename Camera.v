							   						
/*
		TFE4152 - Four pixel camera design
  	   		- Sigurd Odden
*/

// 

	// timescale
	`timescale 1 ms / 100 us 		 
		
		
module RE_camera(init, reset, clk, exp_incr, exp_decr, NRE1, NRE2, expose, erase, adc);
	//	Input list
	input init, reset, clk;
	input exp_incr, exp_decr;
	
	// 	Output list
	output NRE1, NRE2;
	output adc, expose, erase;
	
	//	Wire list
	wire init, reset, clk;						//
	wire exp_incr, exp_decr;					//
	
	//	Register list
	
	reg NRE1, NRE2, expose, erase, adc;			//
	reg exp_f, adc_f, adc_state;				//
	
	//	Parameter list
	parameter STATE_SIZE 	= 2;				//	Total number of states [2:0]
	parameter EXP_SIZE  	= 5;				//	Size of exposure time is 5 bit.
	parameter ADC_READ_CYC	= 5;				// 	Random assumed number of clock cycles for the ADC
	parameter ADC_SIZE	 	= 2;				//	size of ADC counter
	
	//	Defining states
	parameter IDLE = 2'b00, CAPTURE = 2'b01, READOUT = 2'b10;
	
	reg [STATE_SIZE-1:0] state;					//	Register for the states	
	reg [EXP_SIZE-1:0]	exp_time;				//	Register for the exposure time
	reg [EXP_SIZE-1:0]	exp_counter;			//	Register for the exposure time counter
	reg [ADC_SIZE-1:0]	adc_read;				//	Register for the adc read counter
	    		
	always @(posedge clk)
		begin: FSM
			if(reset == 1'b1)
				begin
				$display("Reset");
				state 		<= IDLE;
				NRE1 		<= 1;
				NRE2		<= 1;
				adc 		<= 0;
				expose 	<= 0;
				erase 		<= 1;
				exp_time 	<= 14;
				end
			else
				
				case(state)
					IDLE:
					if(init == 1'b1 && reset == 1'b0)
						begin
							$display("Init");
							exp_f 		<= 0;
							exp_counter <= 0;
							adc_f 		<= 0;	
							adc_state 	<= 0;	
							adc_read 	<= 0;
							state 		<= CAPTURE;	
						end
					else if (exp_incr == 1'b1 && exp_decr == 1'b0 && init == 1'b0)		//Increase the exposure time with 1ms every clock cycle the button is pressed	 
						begin				
							if (exp_time < 30) 
								begin
										$display ("Exposure time increased by 1");
										exp_time <= exp_time + 1;						   
									end
						end
					else if (exp_decr == 1'b1 && exp_incr == 1'b0 && init == 1'b0)		//Increase the exposure time with 1ms every clock cycle the button is pressed	 
						begin				
							if (exp_time < 2) 
								begin
										$display ("Exposure time decreased by 1");
										exp_time <= exp_time -1;						   
									end
						end
					else
						begin
							$display("IDLE state");
							erase <= 1;
						end
						
					CAPTURE:
					if(exp_f == 0)
						begin
							$display("CAPTURE state");
							expose 	<= 1;
							erase 	<= 0;
							if(exp_counter < exp_time)
								begin  
									$display("Exposing:");
									exp_counter <= exp_counter +1;
								end
							else if (exp_counter >= exp_time)
								begin
									expose 		<= 0;
									exp_f 		<= 1;
									$display("Exposure done");
									state 		<= READOUT;
								end
						end	
						
					READOUT: 
					if(adc_f == 0)
						begin
							if (adc_state == 0) 
								begin						
										$display("Row 1");
										if (adc_read< ADC_READ_CYC) 
											begin	  																			
												if (adc_read == 1) 
													begin 							
														adc <= 1;											
													end
												else 
													begin
														adc <= 0;
													end
												NRE1 <= 0;												 
												adc_read <= adc_read + 1;					
										end 
								else if (adc_read >= ADC_READ_CYC) 
										begin	 																	
											NRE1 <= 1;												
											adc_state <= 1;
											adc_read<= 0;	   
										end
								end
							if(adc_state == 1)
								begin	
									$display("Row 2");
									if (adc_read < ADC_READ_CYC) 
										begin	  
											if (adc_read == 1) 
												begin 
													adc <= 1;
											end 
											else 
												begin
													adc <= 0;
												end
											NRE2 <= 0;		
											adc_read<= adc_read + 1;  	
										end 
									else if (adc_read>= ADC_READ_CYC) 
										begin	 
											NRE2 <= 1;
											adc_f <= 1;  
											end
							end
									
									
									
						end
					else if(adc_f == 1)
						begin
							$display("Readout done");
							state <= IDLE;
							erase <= 1;
						end
						
				endcase	
				
			end		
				
		
		
			 	
				
		
	endmodule
	

