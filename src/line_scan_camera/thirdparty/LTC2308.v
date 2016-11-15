// Code shamelessly stolen from the Terasic line following
// Car project

module LTC2308(
	input 				clk, // max 40mhz
	input 				reset_n,
	
	//
	input					data_capture, // rise edge to trigger
	output	reg		data_ready,
	output	reg	[11:0] 	data0,
	output	reg	[11:0] 	data1,
	output	reg	[11:0] 	data2,
	output	reg	[11:0] 	data3,
	output	reg	[11:0] 	data4,
	output	reg	[11:0] 	data5,
	output	reg	[11:0] 	data6,
	output	reg	[11:0] 	data7,
	
	// spi 
	output	reg		ADC_CONVST,
	output	      	ADC_SCK,
	output	reg      ADC_SDI,
	input 		      ADC_SDO

);


parameter CLOCK_DUR = 25; // 25ns = 40MHz
parameter CONVST_WAIT_CLOCK_NUM = ((1600+CLOCK_DUR-1)/CLOCK_DUR);  //  1.6 us = 1600 ns, 1600/25=64

`define DATA_BIT_LENGTH	12
`define CHANNEL_NUM		8


/////////////////////////////////////////////
// trigger

reg	pre_data_capture;
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		pre_data_capture <= 1'b0;
	else
		pre_data_capture <= data_capture;
end

wire data_capture_trigger;
assign data_capture_trigger = (~pre_data_capture & data_capture)?1'b1:1'b0;

//////////////////////////////////////////////
// state control



`define ST_READY					3'd0
`define ST_CONVST_TRIGGER		3'd1
`define ST_CONVST_WAIT			3'd2
`define ST_DATA_XFER				3'd3		
`define ST_DATA_XVER_ENDING	3'd4		


// state
reg	[2:0] state;

always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		state <= `ST_READY;
	else if (data_capture_trigger)
		state <= `ST_CONVST_TRIGGER;
	else if (state == `ST_CONVST_TRIGGER)
		state <= `ST_CONVST_WAIT;
	else if (state == `ST_CONVST_WAIT) 
		state <= (wait_tick_cnt >= CONVST_WAIT_CLOCK_NUM)?`ST_DATA_XFER:`ST_CONVST_WAIT;
	else if (state == `ST_DATA_XFER)
		state <= last_data_bits?`ST_DATA_XVER_ENDING:`ST_DATA_XFER;
	else if (state == `ST_DATA_XVER_ENDING)
		state <= (last_channel)?`ST_READY:`ST_CONVST_TRIGGER;
end

// CONVT wait
reg	[7:0] wait_tick_cnt;  // max 64
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		wait_tick_cnt <= 0;
	else if (state == `ST_CONVST_WAIT) 
			wait_tick_cnt <= wait_tick_cnt + 1;
	else
		wait_tick_cnt <= 0;

end


// data bit index
wire last_data_bits;
reg	[3:0] data_bit_index;

assign last_data_bits = ((data_bit_index+1) >= `DATA_BIT_LENGTH)?1'b1:1'b0;

always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		data_bit_index <= 0;
	else if (state == `ST_DATA_XFER)  
			data_bit_index <= data_bit_index + 1;
	else
		data_bit_index <= 0;

end

// adc channel
wire last_channel;
reg	[3:0] channel;

assign last_channel = (channel == `CHANNEL_NUM)?1'b1:1'b0;

always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		channel <= 0;
	else if (state == `ST_READY)  
		channel <= 0;
	else if (state == `ST_DATA_XVER_ENDING)  
			channel <= channel + 1;
end


// data_ready
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		data_ready <= 1'b0;
	else if (state == `ST_CONVST_TRIGGER)
		data_ready <= 1'b0;
	else if ((state == `ST_DATA_XVER_ENDING) && last_channel) 
			data_ready <= 1'b1;

end


//////////////////////////
// generate CONVST

always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		ADC_CONVST <= 1'b0;
	else if (ADC_CONVST)
		ADC_CONVST <= 1'b0;
	else if (state == `ST_CONVST_TRIGGER)
		ADC_CONVST <= 1'b1;
	
end



//////////////////////////
// generate SCK
reg spi_clk_enable;

always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		spi_clk_enable <= 1'b0;
	else if (state == `ST_DATA_XFER)
		spi_clk_enable <= 1'b1;
	else
		spi_clk_enable <= 1'b0;
	
end


assign ADC_SCK = spi_clk_enable?~clk:1'b0; // note. clock is invert 

//////////////////////////
// generate SDI,  unipolar, not sleep
reg [5:0] channel_config;
always @(*)
begin
	case(channel)
	   4'd8: channel_config <= 6'b100010; // ch0
		4'd0: channel_config <= 6'b100010; // ch0
		4'd1: channel_config <= 6'b110010;
		4'd2: channel_config <= 6'b100110;
		4'd3: channel_config <= 6'b110110;
		4'd4: channel_config <= 6'b101010;
		4'd5: channel_config <= 6'b111010;
		4'd6: channel_config <= 6'b101110;
		4'd7: channel_config <= 6'b111110;
	
	endcase
end



// note, SDI ready at posedge clk (negtive ADC_SCK)
wire [3:0] sdi_data_bit_index;
assign sdi_data_bit_index = 5 - data_bit_index;
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		ADC_SDI <= 1'b0;
	else if ((state == `ST_DATA_XFER) && data_bit_index < 6)
		ADC_SDI <= channel_config[sdi_data_bit_index];
	else
		ADC_SDI <= 1'b0;
end


//////////////////////////
// receive data from SDO
wire [3:0] rx_data_bit_index;
assign rx_data_bit_index = 12 - data_bit_index; // data valid when data_bit_index = 1~12

// read data at posedge of ADC_SCK
always @ (posedge ADC_SCK)
begin
	case(channel)
		4'd1: data0[rx_data_bit_index] <= ADC_SDO;
		4'd2: data1[rx_data_bit_index] <= ADC_SDO;
		4'd3: data2[rx_data_bit_index] <= ADC_SDO;
		4'd4: data3[rx_data_bit_index] <= ADC_SDO;
		4'd5: data4[rx_data_bit_index] <= ADC_SDO;
		4'd6: data5[rx_data_bit_index] <= ADC_SDO;
		4'd7: data6[rx_data_bit_index] <= ADC_SDO;
		4'd8: data7[rx_data_bit_index] <= ADC_SDO;
	endcase
end














endmodule
