//XERA4 Experimental CPU
//Antonio Sánchez

//OPCODES						//Cycles	//Description
`define	NOP			8'H00	// 3
`define	LDAB			8'H01	// 3		Register B to Register A
`define	LDAl			8'H02	//	4		8 bits literal to Register A
`define	LDBl			8'H03	//	4		8 bits literal to Register B
`define	LDUPl			8'H04	//	6		15bits literal to User Pointer
`define	LDVPl			8'H05	//	6		15bits literal to Video Pointer
`define	GOTO			8'H06	//	7		15bits absolute Jump
`define	RJMP			8'H07	//	4		8bits signed Jump
`define	SUBAl			8'H08	//	4		2comp' substract literal-A
`define	LD_UPl		8'H09	//	5		8bits literal to address pointed by UP
`define	LD_VPl		8'H0A	//	5		8bits literal to address pointed by VP
`define	LDBCll		8'H0B	//	6		16bits literal to BC
`define	LDA_UP		8'H0C	//	4		Contents of UP to A
`define	LDA_VP		8'H0D	//	4		Contents of VP to A
`define	DECA			8'H0E	//	3		Decrements register A
`define	INCA			8'H0F	//	3		Increments register A
`define	DECBC			8'H10	//	3		Decrements pair BC
`define	CMPAl			8'H11	//	4		Update flags with A-8bits literal
`define	JMPZ			8'H12	//	4		8bits signed Jump if Flag Z
`define	LD_VPlinc	8'H13	//	5		8bits literal to address pointed by VP and increments VP
`define	LD_VPAinc	8'H14	//	4		Register A to address pointed by VP and increments VP
`define	LD_VPBinc	8'H15	//	4		Register B to address pointed by VP and increments VP

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
			`LDAB:		begin A<=B;QC<=3'h0;end
			`LDAl,
			`LDBl,	
			`LDUPl,	
			`LDVPl,	
			`GOTO,	
			`RJMP,	
			`SUBAl,
			`CMPAl,
			`LD_UPl,		
			`LD_VPl,
			`LDBCll,	
			`JMPZ,	
			`LD_VPlinc:	begin RAM_Add<=PC;we<=0;QC<=3'h3;end
			`LDA_UP:		begin RAM_Add<=UP;we<=0;QC<=3'h3;end
			`LDA_VP:		begin Video_Add<=VP;Video_we<=0;QC<=3'h3;end
			`DECA:		begin	A<=A-8'b1;F[`Zf]<=(A==8'h1);QC<=3'h0;end
			`INCA:		begin	A<=A+8'b1;F[`Zf]<=(A==8'hFF);QC<=3'h0;end
			`DECBC:		begin	{B,C}<={B,C}-16'b1;F[`Zf]<=({B,C}==16'h1);QC<=3'h0;end
			`LD_VPAinc:	begin	Video_Add<=VP;Video_Out<=A;Video_we<=1;QC<=3'h3;end
			`LD_VPBinc:	begin	Video_Add<=VP;Video_Out<=B;Video_we<=1;QC<=3'h3;end
			default:		QC<=3'h0; //`NOP:
		endcase
	3'h3:
		case (IR)
			`LDAl:		begin A<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`LDBl:		begin B<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`LDUPl:		begin UP[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`LDVPl:		begin VP[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`GOTO:		begin PCt[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`JMPZ:		begin PC<=(F[`Zf])?PC+{{7{RAM_In[7]}},RAM_In}:PC+15'h1;QC<=3'h0;end
			`RJMP:		begin	PC<=PC+{{7{RAM_In[7]}},RAM_In};QC<=3'h0;end
			`SUBAl:		begin {F[`Cf],A}<=A-RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`CMPAl:		begin	{F[`Cf],PCt[7:0]}<=A-RAM_In;F[`Zf]<=(A==RAM_In);PC<=PC+15'h1;QC<=3'h0;end
			`LD_UPl:		begin	PCt[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`LD_VPl,	
			`LD_VPlinc:	begin	PCt[7:0]<=RAM_In;PC<=PC+15'h1;Video_Add<=VP;QC<=3'h4;end
			`LDBCll:		begin C<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`LDA_UP:		begin A<=RAM_In;QC<=3'h0;end
			`LDA_VP:		begin A<=Video_In;QC<=3'h0;end
			`LD_VPAinc,
			`LD_VPBinc:	begin	VP<=VP+15'h1;Video_we<=0;QC<=3'h0;end
			default:		QC<=3'h0; //`NOP:
		endcase
	3'h4:
		case (IR)
			`LDUPl,	
			`LDVPl,	
			`GOTO,	
			`LDBCll:		begin RAM_Add<=PC;we<=0;QC<=3'h5;end
			`LD_UPl:		begin	RAM_Out<=PCt[7:0];RAM_Add<=UP;we<=1;QC<=3'h0;end
			`LD_VPl:		begin	Video_Out<=PCt[7:0];Video_we<=1;QC<=3'h0;end
			`LD_VPlinc:	begin	Video_Out<=PCt[7:0];Video_we<=1;VP<=VP+15'h1;QC<=3'h0;end
			default:		QC<=3'h0; //`NOP:
		endcase
	3'h5:
		case (IR)
			`LDUPl:		begin UP[14:8]<=RAM_In[6:0];PC<=PC+15'h1;QC<=3'h0;end
			`LDVPl:		begin VP[14:8]<=RAM_In[6:0];PC<=PC+15'h1;QC<=3'h0;end
			`GOTO:		begin PCt[14:8]<=RAM_In[6:0];QC<=3'h6;end
			`LDBCll:		begin B<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			default:		QC<=3'h0; //`NOP:
		endcase
	3'h6:
		case (IR)
			`GOTO:		begin PC<=PCt;QC<=3'h0;end
			default:		QC<=3'h0; //`NOP:
		endcase
	default:		QC<=3'h0; //`NOP:
	endcase
end

endmodule
