//////////////////////////////////////////////////////////////////////////////////
//Square Wave Generator with PWM Center Aligned output
//Tone period (125000/frequency) (13 bits)
//Volume 0 - 31 (5 bits)
//REGISTER		MEANING
//	00          Channel A Tone Period LSB
//	01          Channel A Tone Period MSB (only 5 bits)
//	02          Channel A Duration LSB
//	03          Channel A Duration MSB
// 04				Channel A Volume (5 bits)
//
// Antonio Sánchez
//////////////////////////////////////////////////////////////////////////////////
`define	MaskAddress		12'h011
`define	Clk_Max			5'd24			// 50MHz>>2MHz
`define	Clk_Duration	15'd19999	//	2MHz>>100Hz
`define	Clk_Period		4'd15			// 2MHz>>125KHz
`define	Clk_PWM			3'h1			// 50MHz>>10MHz
`define	NumReg			Address[3:0]
`define	TotalChannels	3

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
reg [15:0]	ChDuration[0:`TotalChannels-1];
reg [4:0]	ChVolume[0:`TotalChannels-1];
reg [12:0]  ChPeriodCopy[0:`TotalChannels-1];
reg [4:0]   ChannelOut[0:`TotalChannels-1];
reg ChBusy[0:`TotalChannels-1];

integer channels;
initial begin
	for (channels=0;channels<`TotalChannels;channels=channels+1) begin
		ChPeriod[channels]<=13'h0;
		ChDuration[channels]<=16'h0;
		ChVolume[channels]<=5'h0;
		ChPeriodCopy[channels]<=13'h0;
		ChannelOut[channels]<=5'h0;
		ChBusy[channels]<=1'h0;
	end
end 

 
reg [4:0] prescaler=5'h0;
reg [14:0] duration_prescaler=15'h0;
reg [3:0] period_prescaler=4'h0;

reg [2:0] PWM_prescaler=3'h0;
reg [5:0] PWM_Duty=6'h63;
reg PWM_Dir=1'h0;
reg [5:0] Left_Duty=6'h0;
reg [5:0] Right_Duty=6'h0;

always @(posedge sysclk) begin
	if (Address[15:4] == `MaskAddress) begin					//50MHz	
		if (we) begin													//Registers Copy
			register[`NumReg]<=InData;
			case (`NumReg)
				0,1,2,3,4		:	ChBusy[0]<=1'h1;
				5,6,7,8,9		:	ChBusy[1]<=1'h1;
				10,11,12,13,14	:	ChBusy[2]<=1'h1;
			endcase
		end
		else OutData<=register[`NumReg];
	end
	
	prescaler<=prescaler+5'h1;
	if (prescaler==`Clk_Max) begin								//2MHz
		prescaler<=5'h0;
		if (!duration_prescaler)begin								//Note Duration
			duration_prescaler<=`Clk_Duration;
			for (channels=0;channels<`TotalChannels;channels=channels+1) begin
				if (ChDuration[channels]) ChDuration[channels]<=ChDuration[channels]-16'h1;
				else begin
					ChBusy[channels]<=1'h0;
					if (ChBusy[channels])begin
						ChPeriod[channels]<={register[channels*5+1][4:0],register[channels*5]};
						ChDuration[channels]<={register[channels*5+3],register[channels*5+2]};
						ChVolume[channels]<=register[channels*5+4];
						ChPeriodCopy[channels]<={register[channels*5+1][4:0],register[channels*5]};
					end
					else begin
						ChVolume[channels]<=5'h0;
						ChDuration[channels]<=16'h0;
					end
				end
			end
		end
		else duration_prescaler<=duration_prescaler-15'h1;
	
		if (!period_prescaler)begin								//Note tone
			period_prescaler<=`Clk_Period;
			for (channels=0;channels<`TotalChannels;channels=channels+1) begin
				if (!ChPeriod[channels]) begin
					ChPeriod[channels]<=ChPeriodCopy[channels];
					if (ChannelOut[channels]==5'h0) ChannelOut[channels]<=ChVolume[channels];
					else ChannelOut[channels]<=5'h0;
				end
				else ChPeriod[channels]<=ChPeriod[channels]-13'h1;
			end
		end
		else period_prescaler<=period_prescaler-4'h1;
	end
end

always @(posedge sysclk) begin									//PWM-CA Out
	if (!PWM_prescaler) begin
		PWM_prescaler<=`Clk_PWM;
		if (PWM_Dir) begin
			if (PWM_Duty==Left_Duty)LeftChannel<=1'h0;
			if (PWM_Duty==Right_Duty)RightChannel<=1'h0;
			if (PWM_Duty==6'd63) begin
				PWM_Dir<=1'h0;
				Left_Duty=ChannelOut[0]+ChannelOut[1];
				Right_Duty=ChannelOut[1]+ChannelOut[2];
			end
			else PWM_Duty=PWM_Duty+6'h1;
		end
		else begin
			if ((PWM_Duty==Left_Duty)&(Left_Duty))LeftChannel<=1'h1;
			if ((PWM_Duty==Right_Duty)&(Right_Duty))RightChannel<=1'h1;
			if (!PWM_Duty) PWM_Dir<=1'h1;
			else PWM_Duty=PWM_Duty-6'h1;
		end
	end
	else PWM_prescaler<=PWM_prescaler-3'h1;
end

endmodule
