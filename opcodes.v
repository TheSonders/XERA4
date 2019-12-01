//This file is also used by the XERA4 compiler,
//ensures there's a copy of this file on the compliler path

//OPCODES						//Cycles	//Description
`define	NOP				8'H00	//  3		No operation

//	LOAD
//		8 bits
//			register to register
`define	LD_rA_rB		8'H01	//  3		Register B to Register A
`define	LD_rB_rA		8'H02	//  3		Register A to Register B
`define	LD_rC_rA		8'H03	//  3		Register A to Register C
`define LD_rG_rF		8'H3D	//	3		rF->rG
`define	LD_rF_rG		8'H3E	//	3		rG->rF
`define LD_rG_rA		8'H4A	//	3		A->G
`define LD_rH_rA		8'H4B	//	3		A->H
`define LD_rA_rH		8'H47	//	3		H->A
`define LD_rA_rG		8'H48	//	3		G->A
//			literal to register
`define	LD_rA_l8		8'H04	//	4		8 bits literal to Register A
`define	LD_rB_l8		8'H05	//	4		8 bits literal to Register B
`define	LD_rD_l8		8'H07	//	4		8 bits literal to Register D
`define	LD_rE_l8		8'H29	//	4		8 bits literal to Register D
`define	LD_rG_l8		8'H06	//	4		8 bits literal to Register G
//			literal to address
`define	LD_$UP_l8		8'H0B	//	5		8bits literal to address pointed by UP
`define	LD_$VP_l8		8'H0C	//	5		8bits literal to address pointed by VP
//			register to address
`define	LD_rA_$UP		8'H0E	//	4		Contents of UP to A
`define	LD_rA_$VP		8'H0F	//	4		Contents of VP to A
// 		16 bits
//			literal to register
`define	LD_rUP_l15		8'H08	//	6		15bits literal to User Pointer
`define	LD_rWP_l15		8'H09	//	6		15bits literal to User Pointer 2
`define	LD_rVP_l15		8'H0A	//	6		15bits literal to Video Pointer
`define	LD_rBC_l16		8'H0D	//	6		16bits literal to BC
//			register to register
`define	LD_rBC_rVP		8'H10	//	3		Pointer VP to pair BC
`define	LD_rVP_rBC		8'H11	//	3		15bits of pair BC to Video Pointer
`define	LD_rUP_rBC		8'H28	//	3		15bits of pair BC to User Pointer
`define LD_rBC_rDE		8'H41	//	3		DE->BC
`define LD_rDE_rBC		8'H42	//	3		BC->DE


//	LOAD AND INCREMENT
//		8bits
//			literal to address
`define	LDINC_$VP_l8	8'H12	//	5		8bits literal to address pointed by VP and increments VP
//			register to address
`define	LDINC_$VP_rA	8'H13	//	4		Register A to address pointed by VP and increments VP
`define	LDINC_$VP_rB	8'H14	//	4		Register B to address pointed by VP and increments VP
`define	LDINC_$VP_rD	8'H17	//	4		Register D to address pointed by VP and increments VP
`define	LDINC_$WP_rA	8'H19	//	4		Register A to WP, increments WP
//			address to register
`define	LDINC_rA_$UP	8'H15	//	4		Contents of UP to A and increments UP
`define	LDINC_rA_$WP	8'H16	//	4		Contents of WP to A and increments WP
//		16bits
`define	LDINC_$WP_rBC	8'H18	//	4		Register C to WP, B to WP+1, WP+2
`define	LDINC_rBC_$WP	8'H1A	//	5		Contents of WP to BC and increments WP+2
`define LDBC_$VP_$WP	8'H1B	//	3/5		Contents of WP++ to contents of VP++ and decrements BC

//	INCREMENT / DECREMENT
`define	INC_rA			8'H1C	//	3		Increments register A
`define	DEC_rA			8'H1D	//	3		Decrements register A
`define	DEC_rC			8'H1E	//	3		Decrements register C
`define	DEC_rE			8'H1F	//	3		Decrements register E
`define	DEC_rG			8'H20	//	3		Decrements register G
`define	DEC_rBC			8'H21	//	3		Decrements pair BC
`define INC_rBC			8'H40	//	3		Increments pair BC

//	COMPARE
`define	CMP_rA_l8		8'H22	//	4		Update flags with A-8bits literal

//	CLEAR
`define CLR_rA			8'H45	//	3		Clear Register A
`define CLR_rC			8'H23	//	3		Clear Register C
`define CLR_rB			8'H24	//	3		Clear Register B
`define CLR_rD			8'H25	//	3		Clear Register D

// SHIFT
`define LLSHIFT_rBC		8'H26	//	3		Logical Left Shift pair BC
`define LLSHIFT_rA		8'H27	//	3		Logical Left register A

//	ARITHMETIC
//		8 bits
`define ADD_rC_l8		8'H2A	//	4		Add C + 8 bits literal
`define ADDC_rB_l8		8'H2B	//	4		Add B + 8 bits literal + carry flag
`define ADD_rD_l8		8'H2C	//	4		Add D + 8 bits literal
`define ADD_rB_l8		8'H2D	//	4		Add B + 8 bits literal
`define	SUB_rA_l8		8'H2E	//	4		2comp' substract literal-A
`define ADD_rA_rC		8'H46	//	3		8 bits A+C->A
`define AND_rA_l8		8'H4D	//	5		Bitwise AND literal with A
`define ADD_rA_l8		8'H4E	//	4		Add A + 8 bits literal
//		16 bits
`define	SUB_rBC_rDE		8'H2F	//	3		DE-BC->BC	
`define	SUB_rBC_rGH		8'H30	//	3		GH-BC->BC	
`define	MULT_rBC_rDE	8'H31	//	3		16bitsx16bits multiplication
`define XOR_rBC_l16		8'H3F	//	6		16bits literal XOR BC
`define LRSHIFT_rBC		8'H4C	//	3		Logical Right Shift pair BC
`define AND_rBC_l16		8'H4F	//	6		16bits literal AND BC
`define ADD_rBC_rDE		8'H49	//  3		16 bits BC+DE->BC

//	JUMP
`define	GOTO_l15		8'h32	//	6		15bits absolute Jump
`define	RJMP_o8			8'h33	//	4		8bits signed Jump
`define	RJMPC_o8		8'h34	//	4		8bits signed Jump if Flag C
`define	RJMPZ_o8		8'h35	//	4		8bits signed Jump if Flag Z
`define	CALL_l15		8'h36	//	7		15bits call subrutine
`define	RETURN			8'h37	//	7		Return

//	STACK
`define POP_rBC			8'H38	//	5		Pop 16 bits from Stack to pair BC
`define PUSH_rBC		8'H39	//	4		Pop pair BC to Stack
`define POP_rDE			8'H3C	//	5		Pop 16 bits from Stack to pair DE

//	INTERRUPTS
`define EI				8'h51	//	3		Enable Interrupts
`define	DI				8'h52	//	3		Disable Interrupts
`define	RETI			8'h53	//	7		Return from interrupt Alternative Flags->Flags

`define	LDI_rBC_l15		8'h3A	//	8		Load contents of position l15 into BC
`define	LDI_l15_rBC		8'h3B	//	7		Load BC into contents of position l15
`define	LDI_rA_l15		8'h43	//	7		Load contents of position l15 into A
`define	LDI_l15_rA		8'h44	//	6		Load A into contents of position l15
`define	OUTABC			8'h50	//	3		OUT register A to Address BC
`define ADDC_rC_l8		8'h54	//	4		Add C + 8 bits literal + carry flag


// Pendientes de implementar
//Carga de un registro a otro
//Carga de un literal de 8 bits a un registro
//Carga de un literal de 16 bits a un par de registros
//Carga de un registro a la posición apuntada por un par de registros //incremento
//Carga de un literal de 8 bits a la posición apuntada por un par de registros //incremento
//Carga de la posición apuntada por un par de registros a un registro //incremento
//Intercambio de 2 registros

//Futuros OPCODE
//NOP				//00000000	// No OPeration
//ADDC	rd,8l		//0000001d	// 8 bits literal carry addition with register {A,B}
//ADD	rd,8l		//000001dd	// 8 bits literal addition with register {A,B,C,D}
//SUB	A,l8		//00001000	// 8 bits literal 2 complements substract with A
//ADD	A,rs		//00001sss	// 8 bits register addition with A (sss!=000)
//LD	pd,ps		//0001ddss	// 16 bits load	If dd=ss LD rd,literal16
//LDINC pd,rs		//00100dss	// 8 bits load and increment {A,B,C,D} to ({UP,WP})
//PUSH	ps			//001010ss	// 16 bits PUSH pair {AF,BC,DE,GH} into STACK, SP=SP-2
//POP	ps			//001011ss	// 16 bits POP from STACK to pair {AF,BC,DE,GH}, SP=SP+2
//LD	pd,(add)	//001111dd	// 16 bits load from contents of address to pair {AF,BC,DE,GH}
//BIT	rs,bs		//0100rbbb  // Copy bit bbb of register {A,B} to Z flag
//CMP	rd,rs		//10dddsss	// 8 bits compare If ddd=sss CMP rd,literal8
//LD	rd,rs		//11dddsss	// 8 bits load If ddd=sss LD rd,literal8












