//This file is also used by the XERA4 compiler,
//ensures there's a copy of this file on the compliler path
//OPCODES						//Cycles	//Description
`define	NOP				8'H00	// 3
`define	LD_A_B			8'H01	// 3		Register B to Register A
`define	LD_A_8			8'H02	//	4		8 bits literal to Register A
`define	LD_B_8			8'H03	//	4		8 bits literal to Register B
`define	LD_UP_15			8'H04	//	6		15bits literal to User Pointer
`define	LD_VP_15			8'H05	//	6		15bits literal to Video Pointer
`define	GOTO_15			8'H06	//	7		15bits absolute Jump
`define	RJMP_8			8'H07	//	4		8bits signed Jump
`define	SUB_A_8			8'H08	//	4		2comp' substract literal-A
`define	LD_UP_8			8'H09	//	5		8bits literal to address pointed by UP
`define	LD_VP_8			8'H0A	//	5		8bits literal to address pointed by VP
`define	LD_BC_16			8'H0B	//	6		16bits literal to BC
`define	LD_A_$UP$		8'H0C	//	4		Contents of UP to A
`define	LD_A_$VP$		8'H0D	//	4		Contents of VP to A
`define	DEC_A				8'H0E	//	3		Decrements register A
`define	INC_A				8'H0F	//	3		Increments register A
`define	DEC_BC			8'H10	//	3		Decrements pair BC
`define	CMP_A_8			8'H11	//	4		Update flags with A-8bits literal
`define	JMPZ_8			8'H12	//	4		8bits signed Jump if Flag Z
`define	LDINC_$VP$_8	8'H13	//	5		8bits literal to address pointed by VP and increments VP
`define	LDINC_$VP$_A	8'H14	//	4		Register A to address pointed by VP and increments VP
`define	LDINC_$VP$_B	8'H15	//	4		Register B to address pointed by VP and increments VP

