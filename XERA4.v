
//Antonio Sánchez
module XERA4(
	input clk,
	output VSync,HSync,
	output [3:0] VGA_Red,
	output [3:0] VGA_Blue,
	output [3:0] VGA_Green);
	
	//VideoChip<>VideoRam
	wire [14:0] Video_Add;
	wire [7:0] Video_Data;
	
	
	//CPU<>VideoRam
	wire [14:0] CPU_Add;
	wire [7:0] CPU_In_Data;
	wire [7:0] CPU_Out_Data;
	wire Video_we;


Video_Chip VideoChip(
	.clk(clk),
	.VSync(VSync),
	.HSync(HSync),
	.Red(VGA_Red),
	.Green(VGA_Green),
	.Blue(VGA_Blue),
	.RAM_Add(Video_Add),
	.RAM_Data(Video_Data));
	
Video_RAM VideoRAM(
	.CPU_Add(CPU_Add),
	.CPU_In_Data(CPU_In_Data),
	.CPU_Out_Data(CPU_Out_Data),
	.we(Video_we),
	.clk(clk),
	.Video_Add(Video_Add),
	.Video_Data(Video_Data));
	
XERA4_CPU CPU(
	.clk(clk),
	.Video_Add(CPU_Add),
	.Video_In_Data(CPU_Out_Data),
	.Video_Out_Data(CPU_In_Data),
	.Video_we(Video_we));
endmodule
