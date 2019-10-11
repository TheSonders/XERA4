//XERA4 Experimental CPU
//Antonio Sánchez


`include "opcodes.v"

//F Register FLAGS
`define	Cf		3'h0 	//Carry flag
`define	Zf		3'h1	//Zero flag


module XERA4_CPU(
	input clk,
	output reg [14:0] RAM_Add=0,
	output reg [7:0] RAM_Out=0,
	input [7:0] RAM_In,
	output reg we=0,
	output reg [14:0] Video_Add=0,
	input [7:0] Video_In,
	output reg [7:0] Video_Out=0,
	output reg Video_we=0);
	
	
// INTERNAL REGISTERS
reg [14:0] PC=0;	//Program Counter
reg [14:0] SP=0;	//Stack Pointer
reg [14:0] VP=0;	//Video Pointer
reg [14:0] UP=0;	//User Pointer
reg [7:0] F=0;		//Flags Register
reg [7:0] A=0;		//Accumulator
reg [7:0] B=0;		//User Register
reg [7:0] C=0;		//User Register

//Non user accessible
reg [7:0] IR=8'h0;		//Instruction register
reg [2:0] QC=3'h0;		//Internal instruction counter
reg [14:0] PCt=0;			//Program Counter temporary

always @(negedge clk) begin
	case (QC)
	3'h0:
		begin RAM_Add<=PC;we<=0;Video_we<=0;QC<=3'h1;end
	3'h1:
		begin IR<=RAM_In;QC<=3'h2;PC<=PC+15'h1;end
	3'h2:
		case (IR)
			`LD_A_B:				begin A<=B;QC<=3'h0;end
			`LD_A_8,
			`LD_B_8,	
			`LD_UP_15,	
			`LD_VP_15,	
			`GOTO_15,	
			`RJMP_8,	
			`SUB_A_8,
			`CMP_A_8,
			`LD_UP_8,		
			`LD_VP_8,
			`LD_BC_16,	
			`JMPZ_8,	
			`LDINC_$VP$_8:		begin RAM_Add<=PC;we<=0;QC<=3'h3;end
			`LD_A_$UP$:			begin RAM_Add<=UP;we<=0;QC<=3'h3;end
			`LD_A_$VP$:			begin Video_Add<=VP;Video_we<=0;QC<=3'h3;end
			`DEC_A:				begin	A<=A-8'b1;F[`Zf]<=(A==8'h1);QC<=3'h0;end
			`INC_A:				begin	A<=A+8'b1;F[`Zf]<=(A==8'hFF);QC<=3'h0;end
			`DEC_BC:				begin	{B,C}<={B,C}-16'b1;F[`Zf]<=({B,C}==16'h1);QC<=3'h0;end
			`LDINC_$VP$_A:		begin	Video_Add<=VP;Video_Out<=A;Video_we<=1;QC<=3'h3;end
			`LDINC_$VP$_B:		begin	Video_Add<=VP;Video_Out<=B;Video_we<=1;QC<=3'h3;end
			default:				QC<=3'h0; //`NOP:
		endcase
	3'h3:
		case (IR)
			`LD_A_8:				begin A<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`LD_B_8:				begin B<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`LD_UP_15:			begin UP[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`LD_VP_15:			begin VP[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`GOTO_15:			begin PCt[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`JMPZ_8:				begin PC<=(F[`Zf])?PC+{{7{RAM_In[7]}},RAM_In}:PC+15'h1;QC<=3'h0;end
			`RJMP_8:				begin	PC<=PC+{{7{RAM_In[7]}},RAM_In};QC<=3'h0;end
			`SUB_A_8:			begin {F[`Cf],A}<=A-RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`CMP_A_8:			begin	{F[`Cf],PCt[7:0]}<=A-RAM_In;F[`Zf]<=(A==RAM_In);PC<=PC+15'h1;QC<=3'h0;end
			`LD_UP_8:			begin	PCt[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`LD_VP_8,	
			`LDINC_$VP$_8:		begin	PCt[7:0]<=RAM_In;PC<=PC+15'h1;Video_Add<=VP;QC<=3'h4;end
			`LD_BC_16:			begin C<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`LD_A_$UP$:			begin A<=RAM_In;QC<=3'h0;end
			`LD_A_$VP$:			begin A<=Video_In;QC<=3'h0;end
			`LDINC_$VP$_A,
			`LDINC_$VP$_B:		begin	VP<=VP+15'h1;Video_we<=0;QC<=3'h0;end
			default:				QC<=3'h0; //`NOP:
		endcase
	3'h4:
		case (IR)
			`LD_UP_15,	
			`LD_VP_15,	
			`GOTO_15,	
			`LD_BC_16:			begin RAM_Add<=PC;we<=0;QC<=3'h5;end
			`LD_UP_8:			begin	RAM_Out<=PCt[7:0];RAM_Add<=UP;we<=1;QC<=3'h0;end
			`LD_VP_8:			begin	Video_Out<=PCt[7:0];Video_we<=1;QC<=3'h0;end
			`LDINC_$VP$_8:		begin	Video_Out<=PCt[7:0];Video_we<=1;VP<=VP+15'h1;QC<=3'h0;end
			default:				QC<=3'h0; //`NOP:
		endcase
	3'h5:
		case (IR)
			`LD_UP_15:			begin UP[14:8]<=RAM_In[6:0];PC<=PC+15'h1;QC<=3'h0;end
			`LD_VP_15:			begin VP[14:8]<=RAM_In[6:0];PC<=PC+15'h1;QC<=3'h0;end
			`GOTO_15:			begin PCt[14:8]<=RAM_In[6:0];QC<=3'h6;end
			`LD_BC_16:			begin B<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			default:				QC<=3'h0; //`NOP:
		endcase
	3'h6:
		case (IR)
			`GOTO_15:		begin PC<=PCt;QC<=3'h0;end
			default:			QC<=3'h0; //`NOP:
		endcase
	default:		QC<=3'h0; //`NOP:
	endcase
end

endmodule
