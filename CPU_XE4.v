//XERA4 Experimental CPU
//Antonio S�nchez


`include "opcodes.v"

//F Register FLAGS
`define	Cf		3'h0 	//Carry flag
`define	Zf		3'h1	//Zero flag

//Interrupt Vector
`define  IntVector 16'h4


module XERA4_CPU(
	input clk,MI,
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

reg [7:0] F_=0;				//Alternative Flags Register
reg [7:0] A_=0;				//Alternative Accumulator
reg [7:0] B_=0;				//Alternative User Register
reg [7:0] C_=0;				//Alternative User Register
reg [7:0] D_=0;				//Alternative User Register
reg [7:0] E_=0;				//Alternative User Register
reg [7:0] G_=0;				//Alternative User Register
reg [7:0] H_=0;				//Alternative User Register

//Non user accessible
reg [7:0] IR=8'h0;		//Instruction register
reg [2:0] QC=3'h0;		//Internal instruction counter
reg [15:0] PCt=16'h0;			//Program Counter temporary
reg MILatch=1'h0;
reg MIEdge=1'h0;
reg MIEnable=1'h0;
reg MIDetected=1'h0;

always @(negedge clk) begin
	if (~MI) MIEdge<=1'h1;
	if (MI & MIEdge) begin MILatch<=1'h1;MIEdge<=1'h0;end
	case (QC)
	3'h0:begin
		QC<=3'h1;
		if (MILatch && MIEnable && ~MIDetected) begin
			F_<=F;
			A_<=A;
			B_<=B;
			C_<=C;
			D_<=D;
			E_<=E;
			G_<=G;
			H_<=H;
			RAM_Add<=SP;
			SP<=SP-15'h1; 
			RAM_Out<={1'h0,PC[14:8]};
			we<=1'h1;
			MIDetected<=1'h1;
		end
		else begin RAM_Add<=PC;we<=0;Video_we<=0;end
		end
	3'h1:begin
		if (MILatch && MIEnable && MIDetected) begin
			RAM_Add<=SP;
			SP<=SP-15'h1; 
			RAM_Out<=PC[7:0];
			PC<=`IntVector;
			MIEnable<=1'h0;
			MIDetected<=1'h0;
			MILatch<=1'h0;
			QC<=3'h0;
		end
		else begin IR<=RAM_In;PC<=PC+15'h1;QC<=3'h2;end
		end
	3'h2:
		case (IR)
			`EI:						begin MIEnable<=1'h1;QC<=3'h0;end
			`DI:						begin MIEnable<=1'h0;QC<=3'h0;end
			`LD_rA_rB:				begin A<=B;QC<=3'h0;end
			`LD_rA_rC:				begin A<=C;QC<=3'h0;end
			`LD_rA_rD:				begin A<=D;QC<=3'h0;end
			`LD_rA_rE:				begin A<=E;QC<=3'h0;end
			`LD_rA_rG:				begin A<=G;QC<=3'h0;end
			`LD_rA_rH:				begin A<=H;QC<=3'h0;end
			`LD_rB_rA:				begin B<=A;QC<=3'h0;end
			`LD_rC_rA:				begin C<=A;QC<=3'h0;end
			`LD_rD_rA:				begin D<=A;QC<=3'h0;end
			`LD_rG_rA:				begin G<=A;QC<=3'h0;end
			`LD_rG_rF:				begin	G<=F;QC<=3'h0;end
			`LD_rF_rG:				begin	F<=G;QC<=3'h0;end
			`LD_rH_rA:				begin	H<=A;QC<=3'h0;end
			`CLR_rA:					begin A<=8'h0;QC<=3'h0;end
			`CLR_rB:					begin B<=8'h0;QC<=3'h0;end
			`CLR_rC:					begin C<=8'h0;QC<=3'h0;end
			`CLR_rD:					begin D<=8'h0;QC<=3'h0;end
			`LLSHIFT_rBC:			begin {F[`Cf],B,C}<={B,C,1'h0};QC<=3'h0;end
			`LRSHIFT_rBC:			begin {B,C,F[`Cf]}<={1'h0,B,C};QC<=3'h0;end
			`LLSHIFT_rA:			begin {F[`Cf],A}<={A,1'h0};QC<=3'h0;end
			`LRSHIFT_rA:			begin {A,F[`Cf]}<={1'h0,A};QC<=3'h0;end
			`LD_rUP_rBC:			begin	UP<={B[6:0],C};QC<=3'h0;end
			`LD_rVP_rBC:			begin	VP<={B[6:0],C};QC<=3'h0;end
			`LD_rWP_rBC:			begin	WP<={B[6:0],C};QC<=3'h0;end
			`LD_rBC_rVP:			begin	{B,C}<={1'h0,VP};QC<=3'h0;end
			`LD_rBC_rDE:			begin	{B,C}<={D,E};QC<=3'h0;end
			`LD_rDE_rBC:			begin	{D,E}<={B,C};QC<=3'h0;end
			`LD_rGH_rBC:			begin	{G,H}<={B,C};QC<=3'h0;end
			`LD_rBC_rGH:			begin	{B,C}<={G,H};QC<=3'h0;end
			`ADD_rA_rC:				begin	{F[`Cf],A}<=A+C;QC<=3'h0;end
			`ADD_rA_rD:				begin	{F[`Cf],A}<=A+D;QC<=3'h0;end
			`OUTABC:					begin	Port_Add<={B,C};Port_Out<=A;Port_we<=1'h1;QC<=3'h0;end
			`INABC:					begin	Port_Add<={B,C};Port_we<=1'h0;QC<=3'h3;end
			`LD_rA_l8,
			`LD_rB_l8,
			`LD_rD_l8,
			`LD_rE_l8,
			`LD_rG_l8,
			`LD_rUP_l15,	
			`LD_rWP_l15,	
			`LD_rVP_l15,	
			`RJMP_o8,	
			`SUB_rA_l8,
			`CMP_rA_l8,
			`LD_$UP_l8,		
			`LD_$VP_l8,
			`LD_rBC_l16,	
			`RJMPZ_o8,
			`RJMPNZ_o8,
			`RJMPC_o8,
			`ADD_rA_l8,
			`ADD_rB_l8,
			`ADD_rC_l8,
			`ADD_rD_l8,
			`ADDC_rB_l8,
			`ADDC_rC_l8,
			`LDI_rBC_l15,
			`LDI_l15_rBC,
			`LDI_rA_l15,
			`LDI_l15_rA,
			`AND_rA_l8,
			`LDINC_$VP_l8:		begin RAM_Add<=PC;we<=0;QC<=3'h3;end
			`LDUP_rA_l8,
			`LDUP_rBC_l8,
			`AND_rBC_l16,
			`XOR_rBC_l16,
			`ADD_rBC_l16,
			`GOTO_l15,	
			`CALL_l15:			begin	RAM_Add<=PC;we<=0;PC<=PC+15'h1;QC<=3'h3;end
			`LDINC_rA_$UP,
			`LD_rA_$UP:			begin RAM_Add<=UP;we<=0;QC<=3'h3;end
			`LDINC_rBC_$WP:	begin RAM_Add<=WP;WP<=(WP+15'h1);we<=0;QC<=3'h3;end
			`LDINC_rBC_$UP:	begin RAM_Add<=UP;UP<=(UP+15'h1);we<=0;QC<=3'h3;end
			`LDINC_rA_$WP:		begin RAM_Add<=WP;we<=0;QC<=3'h3;end
			`LD_rA_$VP:			begin Video_Add<=VP;Video_we<=0;QC<=3'h3;end
			`DEC_rA:				begin	A<=A-8'b1;F[`Zf]<=(A==8'h1);QC<=3'h0;end
			`DEC_rC:				begin	C<=C-8'b1;F[`Zf]<=(C==8'h1);QC<=3'h0;end
			`DEC_rE:				begin	E<=E-8'b1;F[`Zf]<=(E==8'h1);QC<=3'h0;end
			`DEC_rG:				begin	G<=G-8'b1;F[`Zf]<=(G==8'h1);QC<=3'h0;end
			`INC_rA:				begin	A<=A+8'b1;F[`Zf]<=(A==8'hFF);QC<=3'h0;end
			`INC_rBC:			begin {B,C}<={B,C}+16'h1;F[`Zf]<=({B,C}==16'hFFFF);QC<=3'h0;end
			`DEC_rBC:			begin	{B,C}<={B,C}-16'b1;F[`Zf]<=({B,C}==16'h1);QC<=3'h0;end
			`LDINC_$VP_rA:		begin	Video_Add<=VP;Video_Out<=A;Video_we<=1;QC<=3'h3;end
			`LDINC_$VP_rB:		begin	Video_Add<=VP;Video_Out<=B;Video_we<=1;QC<=3'h3;end
			`LDINC_$VP_rD:		begin	Video_Add<=VP;Video_Out<=D;Video_we<=1;QC<=3'h3;end
			`LDBC_$WP_$UP:		begin if ({B,C})begin RAM_Add<=UP;QC<=3'h3;end else QC<=3'h0;end
			`LDBC_$VP_$WP:		begin if ({B,C})begin RAM_Add<=WP;QC<=3'h3;end else QC<=3'h0;end
			`LDINC_$UP_rBC:	begin RAM_Add<=UP;UP<=(UP+15'h1);we<=1;RAM_Out<=C;QC<=3'h3;end
			`LDINC_$WP_rBC:	begin RAM_Add<=WP;WP<=(WP+15'h1);we<=1;RAM_Out<=C;QC<=3'h3;end
			`LDINC_$WP_rA:		begin RAM_Add<=WP;we<=1;RAM_Out<=A;QC<=3'h3;end
			`RETZ:				begin if (F[`Zf]) begin SP<=SP+15'h1;QC<=3'h3;end else QC<=3'h0;end
			`RETI,
			`RETURN:				begin	SP<=SP+15'h1;QC<=3'h3;end
			`ADD_rBC_rDE:		begin {F[`Cf],B,C}<={B,C}+{D,E};QC<=3'h0;end
			`SUB_rBC_rDE:		begin {F[`Cf],B,C}<={B,C}+~({D,E})+16'h1;F[`Zf]<=({B,C}=={D,E});QC<=3'h0;end
			`SUB_rBC_rGH:		begin {F[`Cf],B,C}<={B,C}+~({G,H})+16'h1;F[`Zf]<=({B,C}=={G,H});QC<=3'h0;end
			`MULT_rBC_rDE:		begin {B,C,D,E}<={B,C}*{D,E};QC<=3'h0;end
			`PUSH_rBC:			begin PCt<={B,C};QC<=3'h3;end
			`PUSH_rUP:			begin PCt<=UP;QC<=3'h3;end
			`PUSH_rWP:			begin PCt<=WP;QC<=3'h3;end
			`POP_rUP,
			`POP_rWP,
			`POP_rDE,
			`POP_rBC:			begin SP<=(SP+15'h1);we<=0;QC<=3'h3;end
			default:				QC<=3'h0; //`NOP:
		endcase
	3'h3:
		case (IR)
			`LDI_rA_l15,
			`LDI_l15_rA,
			`LDI_l15_rBC,
			`LDI_rBC_l15:		begin PCt[7:0]<=RAM_In;RAM_Add<=RAM_Add+15'h1;QC<=3'h4;end
			`LD_rA_l8:			begin A<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`LD_rB_l8:			begin B<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`LD_rD_l8:			begin D<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`LD_rE_l8:			begin E<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`LD_rG_l8:			begin G<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`LDUP_rBC_l8,
			`LDUP_rA_l8:		begin PCt<={{7{RAM_In[7]}},RAM_In}+UP;QC<=3'h4;end
			`ADD_rA_l8:			begin {F[`Cf],A}<=A+RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`ADD_rB_l8:			begin {F[`Cf],B}<=B+RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`ADD_rC_l8:			begin {F[`Cf],C}<=C+RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`ADD_rD_l8:			begin {F[`Cf],D}<=D+RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`ADDC_rC_l8:		begin {F[`Cf],C}<=C+RAM_In+F[`Cf];PC<=PC+15'h1;QC<=3'h0;end
			`ADDC_rB_l8:		begin {F[`Cf],B}<=B+RAM_In+F[`Cf];PC<=PC+15'h1;QC<=3'h0;end
			`LD_rUP_l15:		begin UP[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`LD_rWP_l15:		begin WP[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`LD_rVP_l15:		begin VP[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`AND_rA_l8:			begin PCt[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`AND_rBC_l16,
			`XOR_rBC_l16,
			`ADD_rBC_l16,
			`GOTO_l15,						
			`CALL_l15:			begin PCt[7:0]<=RAM_In;RAM_Add<=PC;QC<=3'h4;end
			`INABC:				begin A<=Port_In;QC<=3'h0;end
			`RJMPZ_o8:			begin PC<=(F[`Zf])?PC+{{7{RAM_In[7]}},RAM_In}:PC+15'h1;QC<=3'h0;end
			`RJMPNZ_o8:			begin PC<=(~F[`Zf])?PC+{{7{RAM_In[7]}},RAM_In}:PC+15'h1;QC<=3'h0;end
			`RJMPC_o8:			begin PC<=(F[`Cf])?PC+{{7{RAM_In[7]}},RAM_In}:PC+15'h1;QC<=3'h0;end
			`RJMP_o8:			begin	PC<=PC+{{7{RAM_In[7]}},RAM_In};QC<=3'h0;end
			`SUB_rA_l8:			begin {F[`Cf],A}<=A+~(RAM_In)+8'h1;F[`Zf]<=(A==RAM_In);PC<=PC+15'h1;QC<=3'h0;end
			`CMP_rA_l8:			begin	{F[`Cf],PCt[7:0]}<=A+~(RAM_In)+8'h1;F[`Zf]<=(A==RAM_In);PC<=PC+15'h1;QC<=3'h0;end
			`LD_$UP_l8:			begin	PCt[7:0]<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`LD_$VP_l8,	
			`LDINC_$VP_l8:		begin	PCt[7:0]<=RAM_In;PC<=PC+15'h1;Video_Add<=VP;QC<=3'h4;end
			`LD_rBC_l16:		begin C<=RAM_In;PC<=PC+15'h1;QC<=3'h4;end
			`LD_rA_$UP:			begin A<=RAM_In;F[`Zf]<=(RAM_In==8'h0);QC<=3'h0;end
			`LDINC_rA_$UP:		begin A<=RAM_In;F[`Zf]<=(RAM_In==8'h0);UP<=UP+15'h1;QC<=3'h0;end
			`LDINC_rA_$WP:		begin A<=RAM_In;F[`Zf]<=(RAM_In==8'h0);WP<=WP+15'h1;QC<=3'h0;end
			`LDINC_rBC_$WP:	begin C<=RAM_In;RAM_Add<=WP;WP<=(WP+15'h1);QC<=3'h4;end
			`LDINC_rBC_$UP:	begin C<=RAM_In;RAM_Add<=UP;UP<=(UP+15'h1);QC<=3'h4;end
			`LD_rA_$VP:			begin A<=Video_In;QC<=3'h0;end
			`LDINC_$VP_rA,
			`LDINC_$VP_rB,
			`LDINC_$VP_rD:		begin	VP<=VP+15'h1;Video_we<=0;QC<=3'h0;end
			`LDBC_$WP_$UP:		begin RAM_Add<=WP;RAM_Out<=RAM_In;we<=1;WP<=WP+15'h1;UP<=UP+15'h1;{B,C}<={B,C}-15'h1;PC<=PC-15'h1;QC<=3'h0;end	
			`LDBC_$VP_$WP:		begin Video_Add<=VP;Video_Out<=RAM_In;Video_we<=1;QC<=3'h4;end
			`RETZ,
			`RETI,
			`RETURN:				begin	RAM_Add<=SP;SP<=SP+15'h1;QC<=3'h4;end
			`LDINC_$UP_rBC:	begin RAM_Add<=UP;UP<=(UP+15'h1);RAM_Out<=B;QC<=3'h0;end
			`LDINC_$WP_rBC:	begin RAM_Add<=WP;WP<=(WP+15'h1);RAM_Out<=B;QC<=3'h0;end
			`LDINC_$WP_rA:		begin WP<=(WP+15'h1);we<=0;QC<=3'h0;end
			`PUSH_rBC,
			`PUSH_rUP,
			`PUSH_rWP:			begin	RAM_Add<=SP;SP<=(SP-15'h1);we<=1;RAM_Out<=PCt[15:8];QC<=3'h4;end
			`POP_rUP,
			`POP_rWP,			
			`POP_rDE,			
			`POP_rBC:			begin RAM_Add<=SP;SP<=(SP+15'h1);QC<=3'h4;end
			default:				QC<=3'h0; //`NOP:
		endcase
	3'h4:
		case (IR)
			`LD_rUP_l15,
			`LD_rWP_l15,	
			`LD_rVP_l15,
			`LD_rBC_l16:		begin RAM_Add<=PC;we<=0;QC<=3'h5;end
			`GOTO_l15:			begin PCt[15:8]<=RAM_In;QC<=3'h5;end
			`LDUP_rA_l8:		begin RAM_Add<=PCt;QC<=3'h5;end
			`AND_rBC_l16,
			`XOR_rBC_l16,
			`ADD_rBC_l16,
			`CALL_l15:			begin PCt[15:8]<=RAM_In;PC<=PC+15'h1;QC<=3'h5;end
			`LDI_rA_l15,
			`LDI_l15_rA,
			`LDI_l15_rBC,
			`LDI_rBC_l15:		begin PCt[15:8]<=RAM_In;PC<=PC+15'h1;QC<=3'h5;end
			`AND_rA_l8:			begin A<=A & PCt[7:0];F[`Zf]<=((A & PCt[7:0])==8'h0);QC<=3'h0;end
			`LD_$UP_l8:			begin	RAM_Out<=PCt[7:0];RAM_Add<=UP;we<=1;QC<=3'h0;end
			`LD_$VP_l8:			begin	Video_Out<=PCt[7:0];Video_we<=1;QC<=3'h0;end
			`LDINC_$VP_l8:		begin	Video_Out<=PCt[7:0];Video_we<=1;VP<=VP+15'h1;QC<=3'h0;end
			`LDBC_$VP_$WP:		begin Video_we<=0;WP<=WP+15'h1;VP<=VP+15'h1;{B,C}<={B,C}-15'h1;PC<=PC-15'h1;QC<=3'h0;end
			`RETZ,
			`RETI,
			`RETURN:				begin	PCt[7:0]<=RAM_In;RAM_Add<=SP;QC<=3'h5;end
			`LDINC_rBC_$UP,
			`LDINC_rBC_$WP:	begin B<=RAM_In;QC<=3'h0;end
			`POP_rUP,
			`POP_rWP,			
			`POP_rDE,			
			`POP_rBC:			begin PCt[7:0]<=RAM_In;RAM_Add<=SP;QC<=3'h5;end
			`PUSH_rBC,
			`PUSH_rUP,
			`PUSH_rWP:			begin RAM_Add<=SP;SP<=(SP-15'h1);RAM_Out<=PCt[7:0];QC<=3'h0;end
			`LDUP_rA_l8,
			`LDUP_rBC_l8:		begin RAM_Add<=PCt;QC<=3'h5;end
			default:				QC<=3'h0; //`NOP:
		endcase
	3'h5:
		case (IR)
			`LDI_rA_l15,
			`LDI_rBC_l15:		begin RAM_Add<=PCt;PC<=PC+15'h1;QC<=3'h6;end
			`LDI_l15_rBC:		begin RAM_Add<=PCt;RAM_Out<=C;we<=1;PC<=PC+15'h1;QC<=3'h6;end
			`LDI_l15_rA:		begin RAM_Add<=PCt;RAM_Out<=A;we<=1;PC<=PC+15'h1;QC<=3'h0;end
			`LD_rUP_l15:		begin UP[14:8]<=RAM_In[6:0];PC<=PC+15'h1;QC<=3'h0;end
			`LD_rWP_l15:		begin WP[14:8]<=RAM_In[6:0];PC<=PC+15'h1;QC<=3'h0;end
			`LD_rVP_l15:		begin VP[14:8]<=RAM_In[6:0];PC<=PC+15'h1;QC<=3'h0;end
			`CALL_l15:			begin	RAM_Add<=SP;SP<=SP-15'h1;RAM_Out<={1'h0,PC[14:8]};we<=1;QC<=3'h6;end
			`GOTO_l15:			begin PC<=PCt;QC<=3'h0;end
			`LD_rBC_l16:		begin B<=RAM_In;PC<=PC+15'h1;QC<=3'h0;end
			`LDUP_rA_l8:		begin F[`Zf]<=(RAM_In==8'h0);A<=RAM_In;QC<=3'h0;end
			`LDUP_rBC_l8:		begin C<=RAM_In;RAM_Add<=RAM_Add+15'h1;QC<=3'h6;end
			`RETZ,
			`RETI,
			`RETURN:				begin	PCt[15:8]<=RAM_In;QC<=3'h6;end
			`AND_rBC_l16:		begin	{B,C}<=({B,C} & PCt);F[`Zf]<=(({B,C} & PCt)==16'h0);QC<=3'h0;end
			`XOR_rBC_l16:		begin	{B,C}<=({B,C} ^ PCt);F[`Zf]<=(({B,C} ^ PCt)==16'h0);QC<=3'h0;end
			`ADD_rBC_l16:		begin	{F[`Cf],B,C}<=({B,C} + PCt);F[`Zf]<=(({B,C} + PCt)==16'h0);QC<=3'h0;end
			`POP_rUP,
			`POP_rWP,			
			`POP_rDE,			
			`POP_rBC:			begin PCt[15:8]<=RAM_In;QC<=3'h6;end
			default:				QC<=3'h0; //`NOP:
		endcase
	3'h6:
		case (IR)
			`LDI_l15_rBC:		begin RAM_Add<=RAM_Add+15'h1;RAM_Out<=B;QC<=3'h0;end
			`LDI_rBC_l15:		begin C<=RAM_In;RAM_Add<=RAM_Add+15'h1;QC<=3'h7;end
			`LDI_rA_l15:		begin A<=RAM_In;F[`Zf]<=(RAM_In==8'h0);QC<=3'h0;end
			`LDUP_rBC_l8:		begin B<=RAM_In;QC<=3'h0;end
			`CALL_l15:			begin	RAM_Add<=SP;RAM_Out<=PC[7:0];SP<=SP-15'h1;PC<=PCt;QC<=3'h0;end
			`RETI:				begin F<=F_;A<=A_;B<=B_;C<=C_;D<=D_;E<=E_;G<=G_;H<=H_;PC<=PCt;QC<=3'h0;end
			`RETZ,
			`RETURN:				begin PC<=PCt;QC<=3'h0;end
			`POP_rUP:			begin UP<=PCt;QC<=3'h0;end
			`POP_rWP:			begin WP<=PCt;QC<=3'h0;end
			`POP_rDE:			begin {D,E}<=PCt;QC<=3'h0;end
			`POP_rBC:			begin {B,C}<=PCt;QC<=3'h0;end
			default:				QC<=3'h0; //`NOP:
		endcase
	3'h7:
		case (IR)
			`LDI_rBC_l15:		begin B<=RAM_In;QC<=3'h0;end
			default:				QC<=3'h0; //`NOP:
		endcase
	default:		QC<=3'h0; //`NOP:
	endcase
end

endmodule
