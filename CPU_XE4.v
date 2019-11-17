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
	output reg [15:0] Port_Add=0,
	output reg [7:0] Port_Out=0,
	input [7:0] Port_In,
	output reg Port_we=0,
	output reg [14:0] Video_Add=0,
	input [7:0] Video_In,
	output reg [7:0] Video_Out=0,
	output reg Video_we=0);
	
	
// INTERNAL REGISTERS
reg [14:0] PC=0;			//Program Counter
reg [14:0] SP=15'h7FFF;	//Stack Pointer
reg [14:0] VP=0;			//Video Pointer
reg [14:0] UP=0;			//User Pointer
reg [14:0] WP=0;			//User Pointer 2
reg [7:0] F=0;				//Flags Register
reg [7:0] A=0;				//Accumulator
reg [7:0] B=0;				//User Register
reg [7:0] C=0;				//User Register
reg [7:0] D=0;				//User Register
reg [7:0] E=0;				//User Register
reg [7:0] G=0;				//User Register
reg [7:0] H=0;				//User Register

//Non user accessible
reg [7:0] IR=8'h0;		//Instruction register
reg [3:0] QC=4'h0;		//Internal instruction counter
reg [15:0] PCt=16'h0;			//Program Counter temporary

always begin
if (PC==15'H0000)
	$display($time);
end

always @(negedge clk) begin
	case (QC)
	4'h0:
		begin RAM_Add<=PC;we<=0;Video_we<=0;QC<=4'h1;end
	4'h1:
		begin IR<=RAM_In;QC<=4'h2;PC<=PC+15'h1;end
	4'h2:
		case (IR)
			`LD_rA_rB:				begin A<=B;QC<=4'h0;end
			`LD_rA_rG:				begin A<=G;QC<=4'h0;end
			`LD_rA_rH:				begin A<=H;QC<=4'h0;end
			`LD_rB_rA:				begin B<=A;QC<=4'h0;end
			`LD_rC_rA:				begin C<=A;QC<=4'h0;end
			`LD_rG_rA:				begin G<=A;QC<=4'h0;end
			`LD_rG_rF:				begin	G<=F;QC<=4'h0;end
			`LD_rF_rG:				begin	F<=G;QC<=4'h0;end
			`LD_rH_rA:				begin	H<=A;QC<=4'h0;end
			`CLR_rA:					begin A<=8'h0;QC<=4'h0;end
			`CLR_rB:					begin B<=8'h0;QC<=4'h0;end
			`CLR_rC:					begin C<=8'h0;QC<=4'h0;end
			`CLR_rD:					begin D<=8'h0;QC<=4'h0;end
			`LLSHIFT_rBC:			begin {F[`Cf],B,C}<={B,C,1'h0};QC<=4'h0;end
			`LRSHIFT_rBC:			begin {B,C,F[`Cf]}<={1'h0,B,C};QC<=4'h0;end
			`LLSHIFT_rA:			begin {F[`Cf],A}<={A,1'h0};QC<=4'h0;end
			`LD_rUP_rBC:			begin	UP<={B[6:0],C};QC<=4'h0;end
			`LD_rVP_rBC:			begin	VP<={B[6:0],C};QC<=4'h0;end
			`LD_rBC_rVP:			begin	{B,C}<={1'h0,VP};QC<=4'h0;end
			`LD_rBC_rDE:			begin	{B,C}<={D,E};QC<=4'h0;end
			`LD_rDE_rBC:			begin	{D,E}<={B,C};QC<=4'h0;end
			`ADD_rA_rC:				begin	{F[`Cf],A}<=A+C;QC<=4'h0;end
			`OUTABC:					begin	Port_Add<={B,C};Port_Out<=A;Port_we<=1'h1;QC<=4'h0;end
			`LD_rA_l8,
			`LD_rB_l8,
			`LD_rD_l8,
			`LD_rE_l8,
			`LD_rG_l8,
			`LD_rUP_l15,	
			`LD_rWP_l15,	
			`LD_rVP_l15,	
			`GOTO_l15,	
			`RJMP_o8,	
			`SUB_rA_l8,
			`CMP_rA_l8,
			`LD_$UP_l8,		
			`LD_$VP_l8,
			`LD_rBC_l16,	
			`RJMPZ_o8,
			`RJMPC_o8,
			`ADD_rA_l8,
			`ADD_rB_l8,
			`ADD_rC_l8,
			`ADD_rD_l8,
			`ADDC_rB_l8,
			`CALL_l15,
			`LDI_rBC_l15,
			`LDI_l15_rBC,
			`XOR_rBC_l16,
			`AND_rBC_l16,
			`LDI_rA_l15,
			`LDI_l15_rA,
			`AND_rA_l8,
			`LDINC_$VP_l8:		begin RAM_Add<=PC;we<=0;QC<=4'h3;end
			`LDINC_rA_$UP,
			`LD_rA_$UP:			begin RAM_Add<=UP;we<=0;QC<=4'h3;end
			`LDINC_rBC_$WP,
			`LDINC_rA_$WP:		begin RAM_Add<=WP;we<=0;QC<=4'h3;end
			`LD_rA_$VP:			begin Video_Add<=VP;Video_we<=0;QC<=4'h3;end
			`DEC_rA:				begin	A<=A-8'b1;F[`Zf]<=(A==8'h1);QC<=4'h0;end
			`DEC_rC:				begin	C<=C-8'b1;F[`Zf]<=(C==8'h1);QC<=4'h0;end
			`DEC_rE:				begin	E<=E-8'b1;F[`Zf]<=(E==8'h1);QC<=4'h0;end
			`DEC_rG:				begin	G<=G-8'b1;F[`Zf]<=(G==8'h1);QC<=4'h0;end
			`INC_rA:				begin	A<=A+8'b1;F[`Zf]<=(A==8'hFF);QC<=4'h0;end
			`INC_rBC:			begin {B,C}<={B,C}+16'h1;F[`Zf]<=({B,C}==16'hFFFF);QC<=4'h0;end
			`DEC_rBC:			begin	{B,C}<={B,C}-16'b1;F[`Zf]<=({B,C}==16'h1);QC<=4'h0;end
			`LDINC_$VP_rA:		begin	Video_Add<=VP;Video_Out<=A;Video_we<=1;QC<=4'h3;end
			`LDINC_$VP_rB:		begin	Video_Add<=VP;Video_Out<=B;Video_we<=1;QC<=4'h3;end
			`LDINC_$VP_rD:		begin	Video_Add<=VP;Video_Out<=D;Video_we<=1;QC<=4'h3;end
			`LDBC_$VP_$WP:		begin if ({B,C})begin RAM_Add<=WP;QC<=4'h3;end else QC<=4'h0;end
			`LDINC_$WP_rBC:	begin RAM_Add<=WP;we<=1;RAM_Out<=C;QC<=4'h3;end
			`LDINC_$WP_rA:		begin RAM_Add<=WP;we<=1;RAM_Out<=A;QC<=4'h3;end
			`RETURN:				begin	SP<=SP+15'h1;QC<=4'h3;end
			`ADD_rBC_rDE:		begin {F[`Cf],B,C}<={B,C}+{D,E};QC<=4'h0;end
			`SUB_rBC_rDE:		begin {F[`Cf],B,C}<={B,C}+~({D,E})+16'h1;F[`Zf]<=({B,C}=={D,E});QC<=4'h0;end
			`SUB_rBC_rGH:		begin {F[`Cf],B,C}<={B,C}+~({G,H})+16'h1;F[`Zf]<=({B,C}=={G,H});QC<=4'h0;end
			`MULT_rBC_rDE:		begin {B,C,D,E}<={B,C}*{D,E};QC<=4'h0;end
			`PUSH_rBC:			begin RAM_Add<=SP;we<=1;RAM_Out<=B;QC<=4'h3;end
			`POP_rDE,
			`POP_rBC:			begin RAM_Add<=(SP+15'h1);we<=0;QC<=4'h3;end
			default:				QC<=4'h0; //`NOP:
		endcase
	4'h3:
		case (IR)
			`LDI_rA_l15,
			`LDI_l15_rA,
			`LDI_l15_rBC,
			`LDI_rBC_l15:		begin PCt[7:0]<=RAM_In;RAM_Add<=RAM_Add+15'h1;QC<=4'h4;end
			`LD_rA_l8:			begin A<=RAM_In;PC<=PC+15'h1;QC<=4'h0;end
			`LD_rB_l8:			begin B<=RAM_In;PC<=PC+15'h1;QC<=4'h0;end
			`LD_rD_l8:			begin D<=RAM_In;PC<=PC+15'h1;QC<=4'h0;end
			`LD_rE_l8:			begin E<=RAM_In;PC<=PC+15'h1;QC<=4'h0;end
			`LD_rG_l8:			begin G<=RAM_In;PC<=PC+15'h1;QC<=4'h0;end
			`ADD_rA_l8:			begin {F[`Cf],A}<=A+RAM_In;PC<=PC+15'h1;QC<=4'h0;end
			`ADD_rB_l8:			begin {F[`Cf],B}<=B+RAM_In;PC<=PC+15'h1;QC<=4'h0;end
			`ADD_rC_l8:			begin {F[`Cf],C}<=C+RAM_In;PC<=PC+15'h1;QC<=4'h0;end
			`ADD_rD_l8:			begin {F[`Cf],D}<=D+RAM_In;PC<=PC+15'h1;QC<=4'h0;end
			`ADDC_rB_l8:		begin {F[`Cf],B}<=B+RAM_In+F[`Cf];PC<=PC+15'h1;QC<=4'h0;end
			`LD_rUP_l15:		begin UP[7:0]<=RAM_In;PC<=PC+15'h1;QC<=4'h4;end
			`LD_rWP_l15:		begin WP[7:0]<=RAM_In;PC<=PC+15'h1;QC<=4'h4;end
			`LD_rVP_l15:		begin VP[7:0]<=RAM_In;PC<=PC+15'h1;QC<=4'h4;end
			`AND_rA_l8,
			`CALL_l15,
			`GOTO_l15:			begin PCt[7:0]<=RAM_In;PC<=PC+15'h1;QC<=4'h4;end
			`RJMPZ_o8:			begin PC<=(F[`Zf])?PC+{{7{RAM_In[7]}},RAM_In}:PC+15'h1;QC<=4'h0;end
			`RJMPC_o8:			begin PC<=(F[`Cf])?PC+{{7{RAM_In[7]}},RAM_In}:PC+15'h1;QC<=4'h0;end
			`RJMP_o8:			begin	PC<=PC+{{7{RAM_In[7]}},RAM_In};QC<=4'h0;end
			`SUB_rA_l8:			begin {F[`Cf],A}<=A+~(RAM_In)+8'h1;PC<=PC+15'h1;QC<=4'h0;end
			`CMP_rA_l8:			begin	{F[`Cf],PCt[7:0]}<=A+~(RAM_In)+8'h1;F[`Zf]<=(A==RAM_In);PC<=PC+15'h1;QC<=4'h0;end
			`LD_$UP_l8:			begin	PCt[7:0]<=RAM_In;PC<=PC+15'h1;QC<=4'h4;end
			`LD_$VP_l8,	
			`LDINC_$VP_l8:		begin	PCt[7:0]<=RAM_In;PC<=PC+15'h1;Video_Add<=VP;QC<=4'h4;end
			`LD_rBC_l16:		begin C<=RAM_In;PC<=PC+15'h1;QC<=4'h4;end
			`LD_rA_$UP:			begin A<=RAM_In;F[`Zf]<=(RAM_In==8'h0);QC<=4'h0;end
			`LDINC_rA_$UP:		begin A<=RAM_In;F[`Zf]<=(RAM_In==8'h0);UP<=UP+15'h1;QC<=4'h0;end
			`LDINC_rA_$WP:		begin A<=RAM_In;F[`Zf]<=(RAM_In==8'h0);WP<=WP+15'h1;QC<=4'h0;end
			`LDINC_rBC_$WP:	begin C<=RAM_In;RAM_Add<=(WP+15'h1);QC<=4'h4;end
			`LD_rA_$VP:			begin A<=Video_In;QC<=4'h0;end
			`LDINC_$VP_rA,
			`LDINC_$VP_rB,
			`LDINC_$VP_rD:		begin	VP<=VP+15'h1;Video_we<=0;QC<=4'h0;end
			`LDBC_$VP_$WP:		begin Video_Add<=VP;Video_Out<=RAM_In;Video_we<=1;QC<=4'h4;end
			`RETURN:				begin	RAM_Add<=SP;QC<=4'h4;end
			`LDINC_$WP_rBC:	begin RAM_Add<=(WP+15'h1);we<=1;RAM_Out<=B;QC<=4'h4;end
			`LDINC_$WP_rA:		begin WP<=(WP+15'h1);we<=0;QC<=4'h0;end
			`PUSH_rBC:			begin RAM_Add<=(SP-15'h1);we<=1;RAM_Out<=C;QC<=4'h4;end
			`POP_rDE:			begin E<=RAM_In;RAM_Add<=(SP+15'h2);we<=0;QC<=4'h4;end
			`POP_rBC:			begin C<=RAM_In;RAM_Add<=(SP+15'h2);we<=0;QC<=4'h4;end
			`AND_rBC_l16,
			`XOR_rBC_l16:		begin	PCt[7:0]<=RAM_In;RAM_Add<=(PC+15'h1);QC<=4'h4;end
			default:				QC<=4'h0; //`NOP:
		endcase
	4'h4:
		case (IR)
			`LD_rUP_l15,
			`LD_rWP_l15,	
			`LD_rVP_l15,
			`CALL_l15,
			`GOTO_l15,	
			`LD_rBC_l16:		begin RAM_Add<=PC;we<=0;QC<=4'h5;end
			`LDI_rA_l15,
			`LDI_l15_rA,
			`LDI_l15_rBC,
			`LDI_rBC_l15:		begin PCt[15:8]<=RAM_In;PC<=PC+15'h1;QC<=4'h5;end
			`AND_rA_l8:			begin A<=A & PCt[7:0];QC<=4'h0;end
			`LD_$UP_l8:			begin	RAM_Out<=PCt[7:0];RAM_Add<=UP;we<=1;QC<=4'h0;end
			`LD_$VP_l8:			begin	Video_Out<=PCt[7:0];Video_we<=1;QC<=4'h0;end
			`LDINC_$VP_l8:		begin	Video_Out<=PCt[7:0];Video_we<=1;VP<=VP+15'h1;QC<=4'h0;end
			`LDBC_$VP_$WP:		begin Video_we<=0;WP<=WP+15'h1;VP<=VP+15'h1;{B,C}<={B,C}-15'h1;PC<=PC-15'h1;QC<=4'h0;end
			`RETURN:				begin	PCt[7:0]<=RAM_In;SP<=SP+15'h1;QC<=4'h5;end
			`LDINC_$WP_rBC:	begin WP<=(WP+15'h2);we<=0;QC<=4'h0;end
			`LDINC_rBC_$WP:	begin B<=RAM_In;WP<=(WP+15'h2);QC<=4'h0;end
			`PUSH_rBC:			begin we<=0;SP<=(SP-15'h2);QC<=4'h0;end
			`POP_rDE:			begin D<=RAM_In;SP<=(SP+15'h2);QC<=4'h0;end
			`POP_rBC:			begin B<=RAM_In;SP<=(SP+15'h2);QC<=4'h0;end
			`AND_rBC_l16,
			`XOR_rBC_l16:		begin	PCt[15:8]<=RAM_In;PC<=PC+15'h1;QC<=4'h5;end
			default:				QC<=4'h0; //`NOP:
		endcase
	4'h5:
		case (IR)
			`LDI_rA_l15,
			`LDI_rBC_l15:		begin RAM_Add<=PCt;PC<=PC+15'h1;QC<=4'h6;end
			`LDI_l15_rBC:		begin RAM_Add<=PCt;RAM_Out<=C;we<=1;PC<=PC+15'h1;QC<=4'h6;end
			`LDI_l15_rA:		begin RAM_Add<=PCt;RAM_Out<=A;we<=1;PC<=PC+15'h1;QC<=4'h0;end
			`LD_rUP_l15:		begin UP[14:8]<=RAM_In[6:0];PC<=PC+15'h1;QC<=4'h0;end
			`LD_rWP_l15:		begin WP[14:8]<=RAM_In[6:0];PC<=PC+15'h1;QC<=4'h0;end
			`LD_rVP_l15:		begin VP[14:8]<=RAM_In[6:0];PC<=PC+15'h1;QC<=4'h0;end
			`CALL_l15:			begin PCt[15:8]<=RAM_In;PC<=PC+15'h1;QC<=4'h6;end
			`GOTO_l15:			begin PCt[15:8]<=RAM_In;QC<=4'h6;end
			`LD_rBC_l16:			begin B<=RAM_In;PC<=PC+15'h1;QC<=4'h0;end
			`RETURN:				begin	RAM_Add<=SP;QC<=4'h6;end
			`AND_rBC_l16:		begin	{B,C}<=({B,C} & PCt);F[`Zf]<=(({B,C} & PCt)==16'h0);PC<=PC+15'h1;QC<=4'h0;end
			`XOR_rBC_l16:		begin	{B,C}<=({B,C} ^ PCt);F[`Zf]<=(({B,C} ^ PCt)==16'h0);PC<=PC+15'h1;QC<=4'h0;end
			default:				QC<=4'h0; //`NOP:
		endcase
	4'h6:
		case (IR)
			`LDI_l15_rBC:		begin RAM_Add<=RAM_Add+15'h1;RAM_Out<=B;QC<=4'h0;end
			`LDI_rBC_l15:		begin C<=RAM_In;RAM_Add<=RAM_Add+15'h1;QC<=4'h7;end
			`LDI_rA_l15:		begin A<=RAM_In;QC<=4'h0;end
			`GOTO_l15:			begin PC<=PCt;QC<=4'h0;end
			`CALL_l15:			begin	RAM_Add<=SP;RAM_Out<={1'h0,PC[14:8]};we<=1;QC<=4'h7;end
			`RETURN:				begin PCt[15:8]<=RAM_In;QC<=4'h7;end
			default:				QC<=4'h0; //`NOP:
		endcase
	4'h7:
		case (IR)
			`LDI_rBC_l15:		begin B<=RAM_In;QC<=4'h0;end
			`CALL_l15:			begin	SP<=SP-15'h1;QC<=4'h8;end		
			`RETURN:				begin	PC<=PCt;QC<=4'h0;end
			default:				QC<=4'h0; //`NOP:
		endcase
	4'h8:
		case (IR)
			`CALL_l15:			begin	RAM_Add<=SP;RAM_Out<=PC[7:0];we<=1;QC<=4'h9;end		
			default:				QC<=4'h0; //`NOP:
		endcase
	4'h9:
		case (IR)
			`CALL_l15:			begin	SP<=SP-15'h1;PC<=PCt;QC<=4'h0;end
			default:				QC<=4'h0; //`NOP:
		endcase
	default:		QC<=4'h0; //`NOP:
	endcase
end

endmodule
