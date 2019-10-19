//This file is also used by the XERA4 compiler,
//ensures there's a copy of this file on the compliler path
//OPCODES						//Cycles	//Description
`define	NOP				8'H00	//  3
`define	LD_A_B			8'H01	//  3		Register B to Register A
`define	LD_A_8			8'H02	//	4		8 bits literal to Register A
`define	LD_B_8			8'H03	//	4		8 bits literal to Register B
`define	LD_UP_15		8'H04	//	6		15bits literal to User Pointer
`define	LD_WP_15		8'H05	//	6		15bits literal to User Pointer 2
`define	LD_VP_15		8'H06	//	6		15bits literal to Video Pointer
`define	GOTO_15			8'H07	//	7		15bits absolute Jump
`define	RJMP_8			8'H08	//	4		8bits signed Jump
`define	SUB_A_8			8'H09	//	4		2comp' substract literal-A
`define	LD_UP_8			8'H0A	//	5		8bits literal to address pointed by UP
`define	LD_VP_8			8'H0B	//	5		8bits literal to address pointed by VP
`define	LD_BC_16		8'H0C	//	6		16bits literal to BC
`define	LD_A_$UP$		8'H0D	//	4		Contents of UP to A
`define	LD_A_$VP$		8'H0E	//	4		Contents of VP to A
`define	DEC_A			8'H0F	//	3		Decrements register A
`define	INC_A			8'H10	//	3		Increments register A
`define	DEC_BC			8'H11	//	3		Decrements pair BC
`define	CMP_A_8			8'H12	//	4		Update flags with A-8bits literal
`define	JMPZ_8			8'H13	//	4		8bits signed Jump if Flag Z
`define	LDINC_$VP$_8	8'H14	//	5		8bits literal to address pointed by VP and increments VP
`define	LDINC_$VP$_A	8'H15	//	4		Register A to address pointed by VP and increments VP
`define	LDINC_$VP$_B	8'H16	//	4		Register B to address pointed by VP and increments VP
`define	LDINC_A_$UP$	8'H17	//	4		Contents of UP to A and increments UP
`define	LDINC_A_$WP$	8'H18	//	4		Contents of WP to A and increments WP
`define	LD_B_A			8'H19	//  3		Register A to Register B
`define	LD_C_A			8'H1A	//  3		Register A to Register C
`define CLR_C			8'H1B	//	3		Clear Register C
`define CLR_B			8'H1C	//	3		Clear Register B
`define LLSHIFT_BC		8'H1D	//	3		Logical Left Shift pair BC
`define ADD_C_8			8'H1E	//	4		Add C + 8 bits literal
`define ADDC_B_8		8'H1F	//	4		Add B + 8 bits literal + carry flag
`define LLSHIFT_A		8'H20	//	3		Logical Left register A
`define	DEC_C			8'H21	//	3		Decrements register C
`define	LD_D_8			8'H22	//	4		8 bits literal to Register D
`define	LDINC_$VP$_D	8'H23	//	4		Register D to address pointed by VP and increments VP
`define	LD_UP_BC		8'H24	//	3		15bits of pair BC to User Pointer
`define	LD_E_8			8'H25	//	4		8 bits literal to Register D
`define	JMPC_8			8'H26	//	4		8bits signed Jump if Flag C
`define CLR_D			8'H27	//	3		Clear Register D
`define ADD_D_8			8'H28	//	4		Add D + 8 bits literal
`define	DEC_E			8'H29	//	3		Decrements register E
`define	LD_BC_VP		8'H2A	//	3		Pointer VP to pair BC
`define	LD_VP_BC		8'H2B	//	3		15bits of pair BC to Video Pointer
`define	LD_G_8			8'H2C	//	4		8 bits literal to Register G
`define	DEC_G			8'H2D	//	3		Decrements register G
`define ADD_B_8			8'H2E	//	4		Add B + 8 bits literal
`define LDBC_$VP_$WP	8'H2F	//	3/5		Contents of WP++ to contents of VP++ and decrements BC
`define	CALL_15			8'H30	//	10
`define	RETURN			8'H31	//	8

// Pendientes de implementar
//Carga de un registro a otro
//Carga de un literal de 8 bits a un registro
//Carga de un literal de 16 bits a un par de registros
//Carga de un registro a la posición apuntada por un par de registros //incremento
//Carga de un literal de 8 bits a la posición apuntada por un par de registros //incremento
//Carga de la posición apuntada por un par de registros a un registro //incremento
//Intercambio de 2 registros

//Futuros OPCODE
//LD	rd,rs		//11dddsss // If ddd=sss LD rd,literal8
//CMP	rd,rs		//10dddsss // If ddd=sss CMP rd,literal8




