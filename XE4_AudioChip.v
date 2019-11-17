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
`define	Clk_PWM			3'h4			// 50MHz>>10MHz

//`define	ChAPeriod		intregister[12:0]
//`define	ChADuration		intregister[28:13]
//`define	ChAVolume		intregister[33:29]
//`define	ChAPeriodCopy	PeriodCopy[0]
`define	ChAOut			ChannelOut[0]
`define	NumReg			Address[3:0]

module XE4_AudioChip(
	input sysclk,
	input [15:0] Address,
	input [7:0] InData,
	input we,
	output reg [7:0] OutData,
	output reg LeftChannel,
	output reg RightChannel
    );

reg [7:0] register [0:15];
//reg [33:0] intregister=34'h0;
reg[12:0]	ChAPeriod=13'h0;
reg[15:0]	ChADuration=16'h0;
reg[4:0]		ChAVolume=5'h0;
	 
reg [4:0] prescaler=5'h0;
wire clk=(prescaler==5'h0);
reg [14:0] duration_prescaler=15'h0;
reg [3:0] period_prescaler=4'h0;

reg [2:0] PWM_prescaler=3'h0;
reg [5:0] PWM_Duty=6'h63;
reg PWM_Dir=1'h0;
reg [5:0] Left_Duty=6'h0;
reg [5:0] Right_Duty=6'h0;


reg ChABusy=0;
reg [12:0]ChAPeriodCopy=0;
reg [4:0]ChannelOut [0:2];

always @ (posedge sysclk) begin

end

always @(posedge sysclk) begin
	if (Address[15:4] == `MaskAddress) begin					//50MHz	
		if (we) begin													//Registers Copy
			register[`NumReg]<=InData;
			case (`NumReg)
				0,1,2,3,4	:	ChABusy<=1'h1;
			endcase
		end
		else OutData<=register[`NumReg];
	end
	
	prescaler<=prescaler+5'h1;
	if (prescaler==`Clk_Max) begin								//2MHz
		prescaler<=5'h0;
		if (!duration_prescaler)begin								//Note Duration
			duration_prescaler<=`Clk_Duration;
			if (ChADuration) ChADuration<=ChADuration-16'h1;
			else begin
				ChABusy<=1'h0;
				if (ChABusy)begin
					ChAPeriod<={register[1][4:0],register[0]};
					ChADuration<={register[3],register[2]};
					ChAVolume<=register[4];
					ChAPeriodCopy<={register[1][4:0],register[0]};
				end
				else begin
					ChAVolume<=5'h0;
					ChADuration<=16'h0;
				end
			end
		end
		else duration_prescaler<=duration_prescaler-15'h1;
	
		if (!period_prescaler)begin								//Note tone
			period_prescaler<=`Clk_Period;
			if (!ChAPeriod) begin
				ChAPeriod<=ChAPeriodCopy;
				if (`ChAOut==5'h0) `ChAOut<=ChAVolume;
				else `ChAOut<=5'h0;
			end
			else ChAPeriod<=ChAPeriod-13'h1;
		end
		else period_prescaler<=period_prescaler-4'h1;
	end
end

always @(posedge sysclk) begin									//PWM-CA Out
	if (!PWM_prescaler) begin
		PWM_prescaler<=`Clk_PWM;
		RightChannel<=LeftChannel;									//Sustituir!!!!!
		if (PWM_Dir) begin
			if (PWM_Duty==Left_Duty)LeftChannel<=1'h0;
			if (PWM_Duty==6'd63) begin
				PWM_Dir<=1'h0;
				Left_Duty={1'h0,`ChAOut};
			end
			else PWM_Duty=PWM_Duty+6'h1;
		end
		else begin
			if ((PWM_Duty==Left_Duty)&(Left_Duty))LeftChannel<=1'h1;
			if (!PWM_Duty) PWM_Dir<=1'h1;
			else PWM_Duty=PWM_Duty-6'h1;
		end
	end
	else PWM_prescaler<=PWM_prescaler-3'h1;
end

endmodule
