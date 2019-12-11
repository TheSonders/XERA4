//////////////////////////////////////////////////////////////////////////////////
//Square Wave Generator with PWM Left Aligned output
//Tone period (125000/frequency) (13 bits)
//Volume 0 - 31 (5 bits)
//REGISTER		MEANING
//	00          Channel A Tone Period LSB
//	01          Channel A Tone Period MSB (only 5 bits)
// 02				Channel A Volume (5 bits)
// ...
// 15				Noise Enable  per channel [4:0], noise period [7:5]
// Antonio Sánchez
//////////////////////////////////////////////////////////////////////////////////
`define	MaskAddress		12'h011
`define	Clk_Max			5'd24			// 50MHz>>2MHz
`define	Clk_Duration	15'd19999	//	2MHz>>100Hz
`define	Clk_Period		4'd15			// 2MHz>>125KHz
`define	Clk_PWM			3'h1			// 50MHz>>25MHz
`define	NumReg			Address[3:0]
`define	TotalChannels	5

module XE4_AudioChip(
	input sysclk,
	input [15:0] Address,
	input [7:0] InData,
	input we,
	output reg [7:0] OutData,
	output reg LeftChannel,
	output reg RightChannel
    );

reg [7:0]   register [0:15];

reg [12:0]	ChPeriod[0:`TotalChannels-1];
reg [4:0]   ChannelOut[0:`TotalChannels-1];

integer channels;
initial begin
	for (channels=0;channels<`TotalChannels;channels=channels+1) begin
		ChPeriod[channels]<=13'h0;
		ChannelOut[channels]<=5'h0;
	end
	for (channels=0;channels<16;channels=channels+1) begin
		register[channels]<=8'h0;
	end
end 

//Clock counters/prescalers
reg [4:0] prescaler=5'h0;
reg [14:0] duration_prescaler=15'h0;
reg [3:0] period_prescaler=4'h0;

//PWM Modulator
reg [2:0] PWM_prescaler=3'h0;
reg [7:0] PWM_Duty=8'h0;
reg PWM_Dir=1'h0;
reg [7:0] Left_Duty=8'h0;
reg [7:0] Right_Duty=8'h0;

//Noise Generator
reg [2:0] NoisePeriod=3'h0;
reg [9:0] Noise=10'h1AA;
reg [4:0] NoiseOut=5'h0;

always @(posedge sysclk) begin
	if (Address[15:4] == `MaskAddress) begin					//50MHz	
		if (we) register[`NumReg]<=InData;						//Registers Read/Write
		else OutData<=register[`NumReg];
	end
	
	prescaler<=prescaler+5'h1;
	if (prescaler==`Clk_Max) begin								//2MHz
		prescaler<=5'h0;
		if (!period_prescaler)begin								//Note tone
			period_prescaler<=`Clk_Period;
			for (channels=0;channels<`TotalChannels;channels=channels+1) begin
				if (!ChPeriod[channels]) begin
					ChPeriod[channels]<={register[channels*3+1],register[channels*3]};
					if (ChannelOut[channels]==5'h0) ChannelOut[channels]<=register[channels*3+2];
					else ChannelOut[channels]<=5'h0;
				end
				else ChPeriod[channels]<=ChPeriod[channels]-13'h1;
			end
		end
		else period_prescaler<=period_prescaler-4'h1;
	end
end

always @(posedge sysclk) begin									//Noise generator
	if (!prescaler) begin
	for (channels=0;channels<(10-1);channels=channels+1) begin
		if (channels==1 || channels==3 || channels==6) Noise[channels]<=~Noise[channels+1]^Noise[1];
		else Noise[channels]<=~Noise[channels+1];
	end
	Noise[9]<=~Noise[0];
	if (!NoisePeriod) begin 
		NoisePeriod<=register[15][7:5];
		NoiseOut<={NoiseOut[3:0],Noise[0]};end
	else NoisePeriod<=NoisePeriod-5'h1;
	end
end

//Left aligned PWM  modulator
//Mixes channels 0,1,2 & noise on Left audio channel
//Mixes channels 2,3,4 & noise on Right audio channel
//Uses a 8 bits output resolution
//Derivated from a 25MHz prescaled clock obtains 97.6KHz of modulated output
always @(posedge sysclk) begin									
	PWM_prescaler<=PWM_prescaler-3'h1;
	if (!PWM_prescaler) begin
		PWM_prescaler<=`Clk_PWM;
			PWM_Duty<=PWM_Duty+8'h1;
			if (PWM_Duty==Left_Duty)LeftChannel<=1'h0;
			if (PWM_Duty==Right_Duty)RightChannel<=1'h0;
			if (PWM_Duty==8'h0) begin
				if (Left_Duty)LeftChannel<=1'h1;
				if (Right_Duty)RightChannel<=1'h1;
			end
			if (PWM_Duty==8'hFF) begin
				Left_Duty<={3'h0,ChannelOut[0]}+(register[15][0])?{3'h0,NoiseOut}:0+
							  {3'h0,ChannelOut[1]}+(register[15][1])?{3'h0,NoiseOut}:0+
							  {3'h0,ChannelOut[2]}+(register[15][2])?{3'h0,NoiseOut}:0;
				Right_Duty<={3'h0,ChannelOut[3]}+(register[15][3])?{3'h0,NoiseOut}:0+
							  {3'h0,ChannelOut[4]}+(register[15][4])?{3'h0,NoiseOut}:0+
							  {3'h0,ChannelOut[2]}+(register[15][2])?{3'h0,NoiseOut}:0;
			end
		end
end

endmodule
