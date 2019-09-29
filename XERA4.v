/*	Little test for a VGA Display
	Uses a 32KiB RAM for Video + 32KiB RAM for data
	Video is 320x200x16colors (2 pixels per byte)
	Each of 16 colors can be modified using INKs
		in a total of 4096 colors (RRRR:GGGG:BBBB)
	I've designed a small CPU to make test, it runs at a quarter of main frequency.
	The Video RAM is dual-port to ensure both CPU and Video Chip work correctly.
	WARNING: All the project is based on a 50MHz FPGA Clock
				Another frecuency may damage your monitor!!!
	Antonio Sánchez*/

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
	
	//CPU<>RAM
	wire [14:0] RAM_Add;
	wire [7:0] RAM_In;
	wire [7:0] RAM_Out;
	wire RAM_we;
	
	//CPU CLOCK (Runs at 12.5MHz)
	wire cpu_clk;
	reg [1:0]cpu_counter=0;
	assign cpu_clk=cpu_counter[1];
	always @(posedge clk) cpu_counter<=cpu_counter+2'h1;


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
	
System_RAM RAM(
	.Add(RAM_Add),
	.In_Data(RAM_Out),
	.Out_Data(RAM_In),
	.we(RAM_we),
	.clk);

XERA4_CPU CPU(
	.clk(cpu_clk),
	.RAM_Add(RAM_Add),
	.RAM_Out(RAM_Out),
	.RAM_In(RAM_In),
	.we(RAM_we),
	.Video_Add(CPU_Add),
	.Video_In(CPU_Out_Data),
	.Video_Out(CPU_In_Data),
	.Video_we(Video_we));
	
	
endmodule
